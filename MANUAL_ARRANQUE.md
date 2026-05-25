# Manual de Arranque — Puzzlebot XRCX
## Navegación autónoma en robot físico

---

## PASO 0 — Verificar red

Conectar **laptop y Puzzlebot a la misma red** (hotspot del celular o WiFi del robot).

Confirmar que la Jetson responde:
```bash
# En la laptop
ping -c 3 <10.41.235.217>
```

Conectarse por SSH:
```bash
ssh puzzlebot@<10.41.235.217>
# Contraseña: Contra del robot
```

---

## PASO 1 — Sincronizar tiempo (Jetson)

Verificar si ya está sincronizada:
```bash
# En la Jetson (SSH)
timedatectl status
# Debe decir: System clock synchronized: yes
```

Si **NO** está sincronizada:
```bash
# En la laptop
sudo systemctl restart chrony
sudo ss -lunp | grep :123   # Debe mostrar chronyd escuchando

# En la Jetson (SSH)
sudo nano /etc/systemd/timesyncd.conf
# Verificar que diga:
# [Time]
# NTP=<IP_LAPTOP_EN_LA_RED>
# FallbackNTP=ntp.ubuntu.com

sudo systemctl restart systemd-timesyncd
timedatectl status   # Esperar: System clock synchronized: yes
```

Obtener IP de la laptop en la red:
```bash
# En la laptop
ip addr show | grep <subred>   # ej: grep 10.41
```

---

## PASO 2 — Variables de entorno

### En la laptop
```bash
cd ~/puzzlebot_ws
export ROS_DOMAIN_ID=0
export ROS_LOCALHOST_ONLY=0
export RMW_IMPLEMENTATION=rmw_fastrtps_cpp   # necesario con hotspot de celular
source install/setup.bash
```

### En la Jetson (SSH)
```bash
source /opt/ros/humble/setup.bash
source ~/ros2_ws/install/setup.bash
export ROS_DOMAIN_ID=0
export ROS_LOCALHOST_ONLY=0
export RMW_IMPLEMENTATION=rmw_fastrtps_cpp
```

Verificar que coincidan en ambos lados:
```bash
echo $ROS_DOMAIN_ID        # 0
echo $ROS_LOCALHOST_ONLY   # 0
echo $RMW_IMPLEMENTATION   # rmw_fastrtps_cpp
```

---

## PASO 3 — Arrancar hardware en la Jetson

Abrir **dos terminales SSH** (ambas con las variables del Paso 2).

**Terminal SSH 1 — micro-ROS (Hackerboard):**
```bash
ros2 launch puzzlebot_ros micro_ros_agent.launch.py
```

**Terminal SSH 2 — LiDAR:**
```bash
ros2 launch rplidar_ros rplidar_a1_launch.py \
  serial_port:=/dev/ttyUSB1 \
  frame_id:=laser_frame
```

Verificar puertos si hay duda:
```bash
ls -l /dev | grep ttyUSB
# ttyUSB0 → Hackerboard (micro-ROS)
# ttyUSB1 → RPLiDAR
```

---

## PASO 4 — Verificar tópicos desde la laptop

```bash
# En la laptop
ros2 topic list
```

Deben aparecer:
```
/VelocityEncR     ← micro-ROS (Hackerboard)
/VelocityEncL     ← micro-ROS (Hackerboard)
/scan             ← RPLiDAR
```

Si **no aparecen**, verificar RMW:
```bash
export RMW_IMPLEMENTATION=rmw_fastrtps_cpp
ros2 topic list
```

Verificar frecuencia del LiDAR:
```bash
ros2 topic hz /scan   # debe ser ~10 Hz
```

---

## PASO 5 — Lanzar navegación desde la laptop

```bash
# En la laptop
ros2 launch puzzlebot_real_robot nav2_real.launch.xml \
  use_micro_ros:=false \
  use_rplidar:=false
```

> `use_micro_ros:=false` y `use_rplidar:=false` porque ya corren en la Jetson.

---

## PASO 6 — Verificar árbol TF

En una terminal separada de la laptop:
```bash
ros2 run tf2_tools view_frames
```

Cadena esperada:
```
odom
└── base_footprint
    └── base_link
        ├── wheel_l_link
        ├── wheel_r_link
        ├── caster_link
        └── lidar_base_link
            └── laser_frame
```

---

## PASO 7 — Dar pose inicial en RViz

1. Abrir RViz (se abre automáticamente con el launch)
2. Verificar que el **mapa** aparezca cargado
3. Hacer click en **"2D Pose Estimate"** en la barra superior
4. Hacer click en el mapa donde está el robot físicamente
5. Arrastrar para indicar la orientación

Confirmar en los logs:
```
amcl: initialPoseReceived
amcl: Setting pose: x y theta
```

---

## PASO 8 — Enviar meta de navegación

En RViz: click en **"Nav2 Goal"** y seleccionar destino en el mapa.

O por línea de comandos:
```bash
ros2 action send_goal /navigate_to_pose \
  nav2_msgs/action/NavigateToPose \
  "{pose: {header: {frame_id: 'map'}, pose: {position: {x: 1.0, y: 0.5}}}}"
```

---

Para ayudarte a matar el nodo y que no se siga moviendo:
```bash
ros2 topic pub /cmd_vel geometry_msgs/Twist "{linear: {x: 0.0}, angular: {z: 0.0}}" 
```

---


## Diagnóstico rápido de errores

| Síntoma | Causa probable | Solución |
|---|---|---|
| `/scan` no aparece en laptop | Multicast bloqueado por hotspot | `export RMW_IMPLEMENTATION=rmw_fastrtps_cpp` |
| `/VelocityEncR` no aparece | micro_ros_agent en puerto incorrecto | Verificar `ls -l /dev \| grep ttyUSB` |
| `Invalid frame ID "odom"` | `puzzlebot_localization.py` no corre | Verificar que el launch esté activo |
| `Invalid frame ID "map"` | AMCL sin pose inicial | Dar pose con "2D Pose Estimate" en RViz |
| `Invalid frame ID "laser"` | frame_id del LiDAR incorrecto | Lanzar rplidar con `frame_id:=laser_frame` |
| Timestamps inválidos en TF | Relojes desincronizados | Repetir Paso 1 |
| Robot se desvía mucho | Drift de odometría | Ajustar `kr` y `kl` en `puzzlebot_localization.py` |
| Mapa no carga | Ruta del yaml incorrecta | Verificar `yaml_filename` en `nav2_params_real.yaml` | yaml_filename: "/home/aldemarg/puzzlebot_ws/src/puzzlebot_real_robot/maps/map_maze_real.yaml"

---

## Resumen de arquitectura

```
JETSON NANO                    LAPTOP
─────────────────              ──────────────────────────
micro_ros_agent    ──/VelocityEncR──►  puzzlebot_localization.py
                   ──/VelocityEncL──►  puzzlebot_joint_state_publisher.py
rplidar_ros        ──/scan──────────►  AMCL / SLAM Toolbox
                                       robot_state_publisher
                                       Nav2 (planner, controller)
                                       RViz
```

Comunicación: **DDS sobre WiFi compartida** (mismo `ROS_DOMAIN_ID` y `RMW_IMPLEMENTATION`)
