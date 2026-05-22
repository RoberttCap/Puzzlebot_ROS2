#!/usr/bin/env python3
"""Dead-reckoning odometry node for the physical Puzzlebot.

Input:
  - right/left wheel angular velocities, normally from the robot firmware or micro-ROS.
Output:
  - nav_msgs/Odometry on /odom
  - optional TF odom -> base_footprint

This node must be the only active source of odom -> base_footprint when running the
physical robot. Do not run a Gazebo diff-drive odometry plugin at the same time.
"""

import math

import numpy as np
import rclpy
from geometry_msgs.msg import TransformStamped
from nav_msgs.msg import Odometry
from rclpy.node import Node
from rclpy.qos import qos_profile_sensor_data
from sensor_msgs.msg import JointState
from std_msgs.msg import Float32
from tf2_ros import TransformBroadcaster


def yaw_to_quaternion(yaw: float):
    return (0.0, 0.0, math.sin(yaw / 2.0), math.cos(yaw / 2.0))


class PuzzlebotLocalization(Node):
    def __init__(self):
        super().__init__('puzzlebot_localization')

        self.declare_parameter('x0', 0.0)
        self.declare_parameter('y0', 0.0)
        self.declare_parameter('theta0', 0.0)
        self.declare_parameter('wheel_radius', 0.05)
        self.declare_parameter('wheel_base', 0.181)
        self.declare_parameter('right_wheel_topic', 'wr')
        self.declare_parameter('left_wheel_topic', 'wl')
        self.declare_parameter('odom_topic', 'odom')
        self.declare_parameter('odom_frame', 'odom')
        self.declare_parameter('base_frame', 'base_footprint')
        self.declare_parameter('publish_tf', True)
        self.declare_parameter('rate_hz', 30.0)
        self.declare_parameter('right_wheel_scale', 1.0)
        self.declare_parameter('left_wheel_scale', 1.0)
        self.declare_parameter('kr', 0.002)
        self.declare_parameter('kl', 0.002)

        self.x = float(self.get_parameter('x0').value)
        self.y = float(self.get_parameter('y0').value)
        self.yaw = float(self.get_parameter('theta0').value)
        self.wheel_radius = float(self.get_parameter('wheel_radius').value)
        self.wheel_base = float(self.get_parameter('wheel_base').value)
        self.odom_frame = str(self.get_parameter('odom_frame').value)
        self.base_frame = str(self.get_parameter('base_frame').value)
        self.publish_tf_enabled = bool(self.get_parameter('publish_tf').value)
        self.right_wheel_scale = float(self.get_parameter('right_wheel_scale').value)
        self.left_wheel_scale = float(self.get_parameter('left_wheel_scale').value)
        self.kr = float(self.get_parameter('kr').value)
        self.kl = float(self.get_parameter('kl').value)

        self.wr = 0.0
        self.wl = 0.0
        self.linear_velocity = 0.0
        self.angular_velocity = 0.0
        self.P = np.zeros((3, 3), dtype=float)
        self.last_time = self.get_clock().now()

        right_topic = str(self.get_parameter('right_wheel_topic').value)
        left_topic = str(self.get_parameter('left_wheel_topic').value)
        odom_topic = str(self.get_parameter('odom_topic').value)
        rate_hz = max(1.0, float(self.get_parameter('rate_hz').value))

        self.create_subscription(Float32, right_topic, self.wr_callback, qos_profile_sensor_data)
        self.create_subscription(Float32, left_topic, self.wl_callback, qos_profile_sensor_data)
        self.odom_pub = self.create_publisher(Odometry, odom_topic, 10)
        self.tf_broadcaster = TransformBroadcaster(self)
        self.timer = self.create_timer(1.0 / rate_hz, self.timer_callback)

        self.get_logger().info(
            f'Puzzlebot localization ready. Inputs: {right_topic}, {left_topic}; output: {odom_topic}; TF: {self.publish_tf_enabled}'
        )

    def wr_callback(self, msg: Float32):
        self.wr = float(msg.data)

    def wl_callback(self, msg: Float32):
        self.wl = float(msg.data)

    def compute_robot_velocity(self):
        wr = self.wr * self.right_wheel_scale
        wl = self.wl * self.left_wheel_scale
        self.linear_velocity = self.wheel_radius * (wr + wl) / 2.0
        self.angular_velocity = self.wheel_radius * (wr - wl) / self.wheel_base

    def update_pose(self, dt: float):
        delta_yaw = self.angular_velocity * dt
        yaw_mid = self.yaw + delta_yaw / 2.0
        self.x += self.linear_velocity * math.cos(yaw_mid) * dt
        self.y += self.linear_velocity * math.sin(yaw_mid) * dt
        self.yaw += delta_yaw
        self.yaw = math.atan2(math.sin(self.yaw), math.cos(self.yaw))

    def update_covariance(self, dt: float):
        dr = self.wheel_radius * self.wr * self.right_wheel_scale * dt
        dl = self.wheel_radius * self.wl * self.left_wheel_scale * dt
        dc = (dr + dl) / 2.0
        dtheta = (dr - dl) / self.wheel_base
        theta_mid = self.yaw + dtheta / 2.0

        J_h = np.array([
            [1.0, 0.0, -dc * math.sin(theta_mid)],
            [0.0, 1.0,  dc * math.cos(theta_mid)],
            [0.0, 0.0,  1.0],
        ])

        J_delta = np.array([
            [0.5 * math.cos(theta_mid) - (dc / (2.0 * self.wheel_base)) * math.sin(theta_mid),
             0.5 * math.cos(theta_mid) + (dc / (2.0 * self.wheel_base)) * math.sin(theta_mid)],
            [0.5 * math.sin(theta_mid) + (dc / (2.0 * self.wheel_base)) * math.cos(theta_mid),
             0.5 * math.sin(theta_mid) - (dc / (2.0 * self.wheel_base)) * math.cos(theta_mid)],
            [1.0 / self.wheel_base, -1.0 / self.wheel_base],
        ])

        sigma_delta = np.array([
            [self.kr * abs(dr), 0.0],
            [0.0, self.kl * abs(dl)],
        ])
        Q = J_delta @ sigma_delta @ J_delta.T
        self.P = J_h @ self.P @ J_h.T + Q
        self.P = 0.5 * (self.P + self.P.T)

    def make_odom_msg(self, stamp):
        msg = Odometry()
        msg.header.stamp = stamp
        msg.header.frame_id = self.odom_frame
        msg.child_frame_id = self.base_frame
        msg.pose.pose.position.x = self.x
        msg.pose.pose.position.y = self.y
        msg.pose.pose.position.z = 0.0
        qx, qy, qz, qw = yaw_to_quaternion(self.yaw)
        msg.pose.pose.orientation.x = qx
        msg.pose.pose.orientation.y = qy
        msg.pose.pose.orientation.z = qz
        msg.pose.pose.orientation.w = qw
        msg.twist.twist.linear.x = self.linear_velocity
        msg.twist.twist.angular.z = self.angular_velocity

        cov = [0.0] * 36
        cov[0] = float(self.P[0, 0])
        cov[1] = float(self.P[0, 1])
        cov[5] = float(self.P[0, 2])
        cov[6] = float(self.P[1, 0])
        cov[7] = float(self.P[1, 1])
        cov[11] = float(self.P[1, 2])
        cov[30] = float(self.P[2, 0])
        cov[31] = float(self.P[2, 1])
        cov[35] = float(self.P[2, 2])
        msg.pose.covariance = cov
        msg.twist.covariance[0] = 0.01
        msg.twist.covariance[35] = 0.02
        return msg

    def publish_tf(self, stamp):
        tf_msg = TransformStamped()
        tf_msg.header.stamp = stamp
        tf_msg.header.frame_id = self.odom_frame
        tf_msg.child_frame_id = self.base_frame
        tf_msg.transform.translation.x = self.x
        tf_msg.transform.translation.y = self.y
        tf_msg.transform.translation.z = 0.0
        qx, qy, qz, qw = yaw_to_quaternion(self.yaw)
        tf_msg.transform.rotation.x = qx
        tf_msg.transform.rotation.y = qy
        tf_msg.transform.rotation.z = qz
        tf_msg.transform.rotation.w = qw
        self.tf_broadcaster.sendTransform(tf_msg)

    def timer_callback(self):
        now = self.get_clock().now()
        dt = (now - self.last_time).nanoseconds * 1e-9
        self.last_time = now
        if dt <= 0.0 or dt > 1.0:
            return

        self.compute_robot_velocity()
        self.update_pose(dt)
        self.update_covariance(dt)

        stamp = now.to_msg()
        self.odom_pub.publish(self.make_odom_msg(stamp))
        if self.publish_tf_enabled:
            self.publish_tf(stamp)


def main(args=None):
    rclpy.init(args=args)
    node = PuzzlebotLocalization()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        if rclpy.ok():
            rclpy.shutdown()
        node.destroy_node()


if __name__ == '__main__':
    main()
