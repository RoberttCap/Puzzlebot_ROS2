# XRCX Puzzlebot ROS 2 Workspace

Este repositorio contiene un workspace de ROS 2 para simular, mapear y navegar un robot Puzzlebot diferencial en Gazebo Sim.

El proyecto está organizado como un stack multi-paquete y contempla dos modos principales de operación:

1. **Fase 1: SLAM / Mapeo**, usando `slam_toolbox`.
2. **Fase 2: Localización + Navegación**, usando Navigation2 (Nav2) con un mapa previamente generado.

---

## 1) Descripción del sistema

El sistema simula un Puzzlebot con:

- Cinemática diferencial mediante comandos de velocidad en `/cmd_vel`.
- Sensor LiDAR 2D publicado como `/scan`.
- Odometría en `/odom`.
- Árbol de transforms para los frames principales del robot y navegación.
- Mundo de laberinto cargado en Gazebo Sim.
- Visualización en RViz para descripción, SLAM y navegación.

El repositorio está basado principalmente en configuración:

- Los launch files están escritos en XML.
- El modelo del robot está definido con URDF/Xacro.
- El mundo y los obstáculos se definen con SDF.
- Los parámetros de SLAM, Nav2, mapas y bridge ROS-Gazebo se configuran con YAML.

No se implementan nodos personalizados en C++ o Python; el comportamiento se construye componiendo paquetes estándar de ROS 2.

---

## 2) Integrantes

| Nombre | GitHub |
| --- | --- |
| Sofía Blanco Prigmore | `AifosWhite` |
| Josué Aldemar Garduño Gómez | `aldemar3002` |
| Karina Fernanda Maldonado Murillo | `thephoeniix` |
| Roberto Carlos Pedraza Miranda | `RoberttCap` |

---

## 3) Estructura del repositorio

```text
puzzlebot_ws/
├── puzzlebot_description/
│   ├── launch/
│   ├── meshes/
│   ├── rviz/
│   └── urdf/
├── puzzlebot_gazebo/
│   ├── config/
│   ├── launch/
│   └── worlds/
├── puzzlebot_navigation/
│   ├── config/
│   ├── launch/
│   ├── maps/
│   └── rviz/
├── LICENSE
└── README.md
```

### `puzzlebot_description`

Define el modelo del robot y publica su descripción.

Contenido principal:

- `urdf/puzzlebot.xacro`: modelo principal del Puzzlebot.
- `urdf/base/`: descripción de la base del robot.
- `urdf/control/`: configuración de control diferencial.
- `urdf/sensors/`: macros y parámetros del LiDAR.
- `meshes/`: mallas STL de base, ruedas, caster y sensor.
- `rviz/puzzlebot_description.rviz`: configuración para visualizar el modelo.
- `launch/puzzlebot_description.launch.xml`: publica `robot_description` y puede abrir RViz, Gazebo o `joint_state_publisher_gui`.

### `puzzlebot_gazebo`

Levanta la simulación en Gazebo y conecta los tópicos de Gazebo con ROS 2.

Contenido principal:

- `launch/puzzlebot_gazebo.launch.xml`: launch principal de simulación.
- `config/gazebo_bridge.yaml`: bridge para `/clock`, `/cmd_vel`, `/odom`, `/tf`, `/joint_states` y `/scan`.
- `worlds/maze.world`: mundo principal del laberinto. Gazebo lo carga directamente; no se inserta un modelo de laberinto por separado.

### `puzzlebot_navigation`

Contiene los flujos de SLAM y navegación autónoma.

Contenido principal:

- `launch/slam.launch.xml`: simulación + SLAM.
- `launch/slam_core.launch.xml`: núcleo de SLAM con `slam_toolbox`, RViz y teleoperación.
- `launch/nav2.launch.xml`: simulación + Nav2.
- `launch/nav2_core.launch.xml`: núcleo de navegación con Nav2 y RViz.
- `config/slam_toolbox.yaml`: parámetros de SLAM.
- `config/nav2_params.yaml`: parámetros de Nav2, AMCL, pose inicial y costmaps.
- `maps/map.yaml` y `maps/map.pgm`: mapa por defecto alineado con `puzzlebot_gazebo/worlds/maze.world`.
- `rviz/slam.rviz` y `rviz/nav2.rviz`: vistas de RViz para cada fase.

---

## 4) Requisitos

### Plataforma recomendada

- Ubuntu 22.04 LTS
- ROS 2 Humble
- Gazebo Sim compatible con `ros_gz_sim`

### Paquetes necesarios

- `ros-humble-desktop`
- `ros-humble-navigation2`
- `ros-humble-nav2-bringup`
- `ros-humble-slam-toolbox`
- `ros-humble-ros-gz-sim`
- `ros-humble-ros-gz-bridge`
- `ros-humble-teleop-twist-keyboard`
- `ros-humble-xacro`
- `python3-colcon-common-extensions`
- `xterm`

Instalación típica:

```bash
sudo apt update
sudo apt install -y \
  ros-humble-desktop \
  ros-humble-navigation2 \
  ros-humble-nav2-bringup \
  ros-humble-slam-toolbox \
  ros-humble-ros-gz-sim \
  ros-humble-ros-gz-bridge \
  ros-humble-teleop-twist-keyboard \
  ros-humble-xacro \
  python3-colcon-common-extensions \
  xterm
```

---

## 5) Compilación y setup

Ubica este repositorio dentro de la carpeta `src` de un workspace de ROS 2. Por ejemplo:

```text
~/puzzlebot_ws/
└── src/
    └── puzzlebot_ws/
```

Desde la raíz del workspace:

```bash
cd ~/puzzlebot_ws
source /opt/ros/humble/setup.bash
rosdep install --from-paths src --ignore-src -r -y
colcon build --symlink-install --packages-select \
  puzzlebot_description \
  puzzlebot_gazebo \
  puzzlebot_navigation
source install/setup.bash
```

Comprobación opcional:

```bash
ros2 pkg list | grep -E "puzzlebot_description|puzzlebot_gazebo|puzzlebot_navigation"
```

Si abres una terminal nueva, vuelve a cargar el entorno:

```bash
source /opt/ros/humble/setup.bash
source ~/puzzlebot_ws/install/setup.bash
```

---

## 6) Uso del proyecto

### Visualizar únicamente el robot

Sirve para verificar que el URDF/Xacro, las mallas y los frames cargan correctamente.

```bash
ros2 launch puzzlebot_description puzzlebot_description.launch.xml rviz:=true
```

Argumentos útiles:

- `rviz:=true`: abre RViz con la configuración del robot.
- `joint_gui:=true`: abre `joint_state_publisher_gui`.
- `gazebo:=true`: abre una simulación vacía y spawnea el robot.
- `use_sim_time:=true`: usa el reloj de simulación.

Ejemplo con GUI de joints:

```bash
ros2 launch puzzlebot_description puzzlebot_description.launch.xml \
  rviz:=true \
  joint_gui:=true
```

### Correr solo la simulación en Gazebo

Sirve para validar el mundo, el spawn del robot, los sensores y el bridge ROS-Gazebo.

```bash
ros2 launch puzzlebot_gazebo puzzlebot_gazebo.launch.xml headless:=false
```

Argumentos útiles:

- `headless:=false`: abre la interfaz gráfica de Gazebo.
- `headless:=true`: corre Gazebo sin interfaz gráfica.
- `use_sim_time:=true`: usa tiempo de simulación.

---

## 7) Fase 1: SLAM / Mapeo

Objetivo:

- Mover el robot en el laberinto y generar un mapa 2D del entorno.

Lanzamiento recomendado:

```bash
ros2 launch puzzlebot_navigation slam.launch.xml \
  headless:=false \
  teleop:=true
```

Este flujo levanta:

- Gazebo con el mundo y el Puzzlebot.
- Bridge ROS-Gazebo.
- `slam_toolbox` en modo de mapeo.
- RViz con la vista de SLAM.
- Teleoperación por teclado mediante `teleop_twist_keyboard`.

Para operar:

1. Usa la terminal de teleoperación para recorrer los pasillos del laberinto.
2. Revisa en RViz que el mapa se vaya construyendo a partir de `/scan`.
3. Verifica que los transforms se mantengan estables.
4. Guarda el mapa cuando hayas recorrido el entorno.

Guardar el mapa:

```bash
ros2 run nav2_map_server map_saver_cli \
  -f ~/puzzlebot_ws/src/puzzlebot_ws/puzzlebot_navigation/maps/map
```

Esto genera o actualiza:

- `puzzlebot_navigation/maps/map.pgm`
- `puzzlebot_navigation/maps/map.yaml`

También puedes usar otro nombre para conservar distintos mapas:

```bash
ros2 run nav2_map_server map_saver_cli \
  -f ~/puzzlebot_ws/src/puzzlebot_ws/puzzlebot_navigation/maps/my_maze
```

---

## 8) Fase 2: Localización y navegación con Nav2

Objetivo:

- Localizar el robot en un mapa conocido y enviar metas de navegación desde RViz.

Lanzamiento recomendado:

```bash
ros2 launch puzzlebot_navigation nav2.launch.xml headless:=false
```

Este flujo levanta:

- Gazebo con `maze.world` y el robot en la pose inicial configurada.
- Bridge ROS-Gazebo.
- AMCL para localización.
- Costmaps, planner, controller y behavior tree de Nav2.
- RViz con herramientas para pose inicial y metas.

La pose inicial usada por Gazebo y AMCL se mantiene sincronizada en:

- `puzzlebot_gazebo/launch/puzzlebot_gazebo.launch.xml`
- `puzzlebot_navigation/config/nav2_params.yaml`

El mapa de navegación está alineado con el mundo mediante el `origin` de `puzzlebot_navigation/maps/map.yaml`.

Para usar un mapa específico:

```bash
ros2 launch puzzlebot_navigation nav2.launch.xml \
  headless:=false \
  map_path:=~/puzzlebot_ws/src/puzzlebot_ws/puzzlebot_navigation/maps/my_maze.yaml
```

En RViz:

1. Usa `2D Pose Estimate` sólo si necesitas corregir manualmente la localización.
2. Selecciona `Nav2 Goal` para enviar una meta de navegación.
3. Observa el plan global, el `LocalCostmap` y la trayectoria local.

La vista `nav2.rviz` muestra el `LocalCostmap` alrededor del robot y deja oculto el `GlobalCostmap` para no cubrir todo el PGM. Nav2 sigue usando el costmap global internamente para planear.

---

## 9) Launch files principales

| Archivo | Propósito |
| --- | --- |
| `puzzlebot_description/launch/puzzlebot_description.launch.xml` | Publica la descripción del robot y puede abrir RViz, Gazebo o la GUI de joints. |
| `puzzlebot_gazebo/launch/puzzlebot_gazebo.launch.xml` | Abre Gazebo con `maze.world`, spawnea el robot y activa el bridge. |
| `puzzlebot_navigation/launch/slam_core.launch.xml` | Ejecuta `slam_toolbox`, RViz y teleoperación. |
| `puzzlebot_navigation/launch/slam.launch.xml` | Combina simulación + SLAM. |
| `puzzlebot_navigation/launch/nav2_core.launch.xml` | Ejecuta Nav2 y RViz usando un mapa. |
| `puzzlebot_navigation/launch/nav2.launch.xml` | Combina simulación + Nav2. |

---

## 10) Tópicos principales

| Tópico | Dirección | Uso |
| --- | --- | --- |
| `/clock` | Gazebo -> ROS 2 | Reloj de simulación. |
| `/cmd_vel` | ROS 2 -> Gazebo | Comandos de velocidad para el robot. |
| `/odom` | Gazebo -> ROS 2 | Odometría del Puzzlebot. |
| `/tf` | Gazebo -> ROS 2 | Transformaciones del robot. |
| `/joint_states` | Gazebo -> ROS 2 | Estados de las articulaciones. |
| `/scan` | Gazebo -> ROS 2 | Lecturas del LiDAR 2D. |

---

## 11) Flujo recomendado

Para probar el stack completo de forma ordenada:

1. Compila el workspace y carga el entorno.
2. Lanza `puzzlebot_description` para validar el modelo.
3. Lanza `puzzlebot_gazebo` para validar simulación, sensores y bridge.
4. Ejecuta `slam.launch.xml` con `teleop:=true`.
5. Recorre el laberinto y guarda el mapa.
6. Ejecuta `nav2.launch.xml` con el mapa guardado.
7. En RViz, fija la pose inicial y envía metas de navegación.

---

## 12) Notas y solución de problemas

- `slam.launch.xml` y `nav2.launch.xml` ya incluyen la simulación; no necesitas lanzar `puzzlebot_gazebo` por separado para esos flujos.
- `nav2.launch.xml` usa `headless:=true` por defecto, así que usa `headless:=false` si quieres ver Gazebo.
- Si `teleop_twist_keyboard` no abre, revisa que `xterm` esté instalado.
- Si RViz no muestra datos, confirma que ejecutaste `source ~/puzzlebot_ws/install/setup.bash`.
- Si Nav2 no navega, revisa que la pose inicial de AMCL coincida con el spawn de Gazebo y que el goal esté en una zona libre del mapa.
- Si cambias el PGM o el `.world`, revisa también el `origin` en `puzzlebot_navigation/maps/map.yaml` para mantener RViz y Gazebo alineados.
- Si cambias archivos de launch, URDF, config o mapas, recompila con `colcon build --symlink-install` y vuelve a hacer `source install/setup.bash`.

---

## 13) Licencia

Este proyecto incluye un archivo `LICENSE` en la raíz del repositorio.


-> puzzlebot_navigation/config/nav2_params.yaml
Quitar voxel_layer del local_costmap.
Quitar voxel_layer y obstacle_layer del global_costmap, dejando sólo static_layer e inflation_layer.
Eliminar secciones completas:
  collision_monitor
  velocity_smoother
Ajustar RPP para laberinto pequeño:
  bajar lookahead_dist, min_lookahead_dist, max_lookahead_dist
  activar use_cost_regulated_linear_velocity_scaling
  reducir regulated_linear_scaling_min_radius
  reducir rotate_to_heading_min_angle
Ajustar tolerancias:
  required_movement_radius de 0.5 a algo menor
  xy_goal_tolerance menor a 0.1
  yaw_goal_tolerance más estricto
En behavior_server, dejar sólo:
  spin
  backup
  wait
En planner_server:
  allow_unknown: false
  tolerance menor, por ejemplo 0.1.

-> README.md
  Agregar una sección de tabla comparativa del planner global, porque en el repo no encontré una tabla comparativa existente. Pondría una tabla breve comparando NavfnPlanner, SmacPlanner2D y ThetaStar, y justificaría que usan NavfnPlanner.