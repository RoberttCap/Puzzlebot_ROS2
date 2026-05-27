# Puzzlebot real: AMCL/Nav2

Para el robot fisico usa el bringup completo:

```bash
ros2 launch puzzlebot_real_robot nav2_full_real.launch.xml
```

Este launch primero levanta micro-ROS, RPLiDAR, `robot_state_publisher`,
odometria por dead reckoning y `joint_states`. Despues espera unos segundos y
arranca Nav2/AMCL. Esto evita que AMCL inicie antes de que existan `/scan`,
`/odom` y la TF `odom -> base_footprint`.

Si AMCL no aparece o Nav2 no localiza, revisa:

```bash
ros2 topic hz /scan
ros2 topic hz /odom
ros2 topic echo /VelocityEncR --once
ros2 topic echo /VelocityEncL --once
ros2 run tf2_ros tf2_echo odom base_footprint
ros2 run tf2_ros tf2_echo base_link laser_frame
```

En RViz tambien debes mandar una pose inicial con `2D Pose Estimate`; AMCL no
publica `map -> odom` de forma util hasta tener una pose inicial o hasta que se
configure `set_initial_pose`.

Nota importante: en simulacion Gazebo publica `/odom` y TF desde el plugin de
diff drive. En el robot real eso lo hace `puzzlebot_localization.py` usando
`/VelocityEncR` y `/VelocityEncL`. No mezcles Gazebo con el bringup real al mismo
tiempo porque tendrias dos fuentes de odometria/TF.
