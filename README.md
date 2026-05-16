<<<<<<< HEAD
# XRCX_Puzzlebot

Stack de navegación autónoma en ROS 2 para el robot Puzzlebot, con soporte para SLAM, simulación en Gazebo y navegación con Nav2.

## Integrantes
=======
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
>>>>>>> origin/main

| Nombre | GitHub |
| --- | --- |
| Sofía Blanco Prigmore | `AifosWhite` |
| Josué Aldemar Garduño Gómez | `aldemar3002` |
| Karina Fernanda Maldonado Murillo | `thephoeniix` |
| Roberto Carlos Pedraza Miranda | `RoberttCap` |

<<<<<<< HEAD
## Descripción general

Este repositorio contiene el stack de navegación en ROS 2 para el robot Puzzlebot, estructurado en tres paquetes con responsabilidades claramente separadas:

- `puzzlebot_description` define cómo es el robot: modelo, URDF/Xacro, mallas y frames.
- `puzzlebot_gazebo` define cómo se ejecuta el robot en simulación: mundo, bridge ROS-Gazebo y spawn.
- `puzzlebot_navigation` define cómo se comporta el stack de SLAM y navegación: `slam_toolbox`, Nav2, RViz y mapas.

Nota: aunque a veces se le mencione como `puzzlebot_navigation2`, en este repositorio el nombre real del paquete es `puzzlebot_navigation`.

## Estructura del repositorio

```text
puzzlebot_ros2/
=======
---

## 3) Estructura del repositorio

```text
puzzlebot_ws/
>>>>>>> origin/main
├── puzzlebot_description/
│   ├── launch/
│   ├── meshes/
│   ├── rviz/
│   └── urdf/
├── puzzlebot_gazebo/
│   ├── config/
│   ├── launch/
│   └── worlds/
<<<<<<< HEAD
└── puzzlebot_navigation/
    ├── config/
    ├── launch/
    ├── maps/
    └── rviz/
```

## Requisitos

Antes de correr el proyecto, asegúrate de tener instalado:

- ROS 2 con `colcon`
- `xacro`
- `robot_state_publisher`
- `rviz2`
- `joint_state_publisher_gui`
- `ros_gz_sim`
- `ros_gz_bridge`
- `slam_toolbox`
- `nav2_bringup`
- `teleop_twist_keyboard`
- `xterm`

También necesitas tener este repositorio dentro de la carpeta `src` de un workspace de ROS 2.

## Compilación

Desde la raíz del workspace, por ejemplo `~/puzzlebot_ws`, ejecuta:

```bash
rosdep install --from-paths src --ignore-src -r -y
colcon build --packages-select puzzlebot_description puzzlebot_gazebo puzzlebot_navigation
source install/setup.bash
```

Si ya compilaste antes y abriste una nueva terminal, recuerda volver a hacer:

```bash
source ~/puzzlebot_ws/install/setup.bash
```

## Paquetes

### `puzzlebot_description`

Este paquete contiene la descripción del robot.

Incluye:

- `urdf/puzzlebot.xacro`: modelo principal del Puzzlebot.
- `meshes/`: mallas STL de la base y ruedas.
- `rviz/puzzlebot_description.rviz`: configuración de RViz para visualizar el robot.
- `launch/puzzlebot_description.launch.xml`: lanza `robot_state_publisher` y, opcionalmente, RViz, Gazebo y la GUI de joints.

Comando base:

```bash
ros2 launch puzzlebot_description puzzlebot_description.launch.xml rviz:=true
```

Argumentos útiles:

- `rviz:=true` abre RViz con la configuración del robot.
- `joint_gui:=true` abre `joint_state_publisher_gui`.
- `gazebo:=true` levanta una simulación vacía y spawnea el robot.
- `use_sim_time:=true` usa el reloj de simulación.

Ejemplo:

```bash
ros2 launch puzzlebot_description puzzlebot_description.launch.xml rviz:=true joint_gui:=true
```

### `puzzlebot_gazebo`

Este paquete contiene la simulación del robot en Gazebo.

Incluye:

- `worlds/maze.world`: mundo de simulación.
- `config/gazebo_bridge.yaml`: bridge entre tópicos de Gazebo y ROS 2.
- `launch/puzzlebot_gazebo.launch.xml`: abre el mundo, publica la descripción del robot, lo inserta en Gazebo y activa el bridge.

Este launch:

- carga el mundo `maze.world`
- spawnea al robot en la pose inicial
- publica `/clock`, `/odom`, `/tf`, `/joint_states` y `/scan`
- recibe `/cmd_vel` desde ROS 2 para mover el robot en la simulación

Comando base:

```bash
ros2 launch puzzlebot_gazebo puzzlebot_gazebo.launch.xml
```

Argumentos útiles:

- `headless:=false` abre la interfaz gráfica de Gazebo.
- `headless:=true` corre Gazebo sin interfaz.
- `use_sim_time:=true` usa tiempo de simulación.

Ejemplo:

```bash
ros2 launch puzzlebot_gazebo puzzlebot_gazebo.launch.xml headless:=false
```

### `puzzlebot_navigation`

Este paquete contiene la parte de percepción y navegación autónoma.

Incluye:

- `config/slam_toolbox.yaml`: parámetros de SLAM.
- `config/nav2_params.yaml`: parámetros de Nav2 y AMCL.
- `maps/map.yaml` y `maps/map.pgm`: mapa por defecto para localización y navegación.
- `rviz/slam.rviz`: configuración de RViz para mapeo.
- `rviz/nav2.rviz`: configuración de RViz para navegación.
- `launch/slam_core.launch.xml`: corre `slam_toolbox`, RViz y teleoperación por teclado.
- `launch/slam.launch.xml`: levanta Gazebo y luego el flujo de SLAM.
- `launch/nav2_core.launch.xml`: levanta Nav2 con un mapa y RViz.
- `launch/nav2.launch.xml`: levanta Gazebo y luego Nav2.

## Cómo correr el proyecto

### 1. Visualizar solo el robot

Útil para verificar que el modelo, frames y mallas cargan correctamente.
=======
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
>>>>>>> origin/main

```bash
ros2 launch puzzlebot_description puzzlebot_description.launch.xml rviz:=true
```

<<<<<<< HEAD
### 2. Correr solo la simulación en Gazebo

Útil para validar el mundo, sensores y bridge sin levantar navegación.
=======
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
>>>>>>> origin/main

```bash
ros2 launch puzzlebot_gazebo puzzlebot_gazebo.launch.xml headless:=false
```

<<<<<<< HEAD
### 3. Ejecutar SLAM en simulación

Este flujo levanta:

- Gazebo con el mundo `maze.world`
- el robot Puzzlebot
- `slam_toolbox`
- RViz para mapeo
- teleoperación por teclado

Comando:

```bash
ros2 launch puzzlebot_navigation slam.launch.xml headless:=false
```

Notas:

- El launch abre `teleop_twist_keyboard` usando `xterm -e`.
- Usa `use_sim_time:=true` por defecto.
- Puedes modificar el archivo de parámetros con `slam_params_file:=...`.

Ejemplo con archivo de parámetros explícito:
=======
Argumentos útiles:

- `headless:=false`: abre la interfaz gráfica de Gazebo.
- `headless:=true`: corre Gazebo sin interfaz gráfica.
- `use_sim_time:=true`: usa tiempo de simulación.

---

## 7) Fase 1: SLAM / Mapeo

Objetivo:

- Mover el robot en el laberinto y generar un mapa 2D del entorno.

Lanzamiento recomendado:
>>>>>>> origin/main

```bash
ros2 launch puzzlebot_navigation slam.launch.xml \
  headless:=false \
<<<<<<< HEAD
  slam_params_file:=/home/karinam/puzzlebot_ws/src/puzzlebot_ros2/puzzlebot_navigation/config/slam_toolbox.yaml
```

### 4. Guardar el mapa generado

Después de mapear el entorno con SLAM, puedes guardar el mapa para usarlo con Nav2:

```bash
ros2 run nav2_map_server map_saver_cli -f ~/puzzlebot_ws/src/puzzlebot_ros2/puzzlebot_navigation/maps/map
```

Esto actualiza los archivos `map.pgm` y `map.yaml` dentro de `puzzlebot_navigation/maps/`.

### 5. Ejecutar navegación con Nav2

Este flujo levanta:

- Gazebo con el robot
- `nav2_bringup`
- AMCL
- costmaps, planner, controller y behavior tree de Nav2
- RViz para enviar metas de navegación

Comando:
=======
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
>>>>>>> origin/main

```bash
ros2 launch puzzlebot_navigation nav2.launch.xml headless:=false
```

<<<<<<< HEAD
Si quieres usar otro mapa:
=======
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
>>>>>>> origin/main

```bash
ros2 launch puzzlebot_navigation nav2.launch.xml \
  headless:=false \
<<<<<<< HEAD
  map_path:=/home/karinam/puzzlebot_ws/src/puzzlebot_ros2/puzzlebot_navigation/maps/map.yaml
```

Una vez abierto RViz:

1. Usa `2D Pose Estimate` para indicar la pose inicial del robot.
2. Usa `Nav2 Goal` para enviar un objetivo de navegación.

## Launch files principales

| Archivo | Propósito |
| --- | --- |
| `puzzlebot_description/launch/puzzlebot_description.launch.xml` | Publica la descripción del robot y opcionalmente abre RViz, GUI de joints o una simulación vacía. |
| `puzzlebot_gazebo/launch/puzzlebot_gazebo.launch.xml` | Abre Gazebo con el mundo del laberinto, spawnea el robot y activa el bridge ROS-Gazebo. |
| `puzzlebot_navigation/launch/slam_core.launch.xml` | Ejecuta el núcleo de SLAM: `slam_toolbox`, RViz y teleoperación. |
| `puzzlebot_navigation/launch/slam.launch.xml` | Combina simulación + SLAM. |
| `puzzlebot_navigation/launch/nav2_core.launch.xml` | Ejecuta el núcleo de navegación con Nav2 y RViz usando un mapa. |
| `puzzlebot_navigation/launch/nav2.launch.xml` | Combina simulación + Nav2. |

## Flujo recomendado de uso

Para probar todo el stack de forma ordenada:

1. Compila el workspace y haz `source` del entorno.
2. Lanza `slam.launch.xml` para mapear el entorno.
3. Guarda el mapa en `puzzlebot_navigation/maps/`.
4. Lanza `nav2.launch.xml` usando el mapa guardado.
5. En RViz, fija la pose inicial y envía metas de navegación.

## Observaciones

- `slam.launch.xml` y `nav2.launch.xml` ya incluyen la simulación, así que no hace falta correr `puzzlebot_gazebo` por separado para esos flujos.
- `nav2.launch.xml` tiene `headless:=true` por defecto en el archivo, por lo que normalmente conviene correrlo con `headless:=false` si quieres ver Gazebo.
- `slam_core.launch.xml` y `nav2_core.launch.xml` están pensados para reutilizar la parte central del stack incluso fuera del flujo completo de simulación.
=======
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

## CORRECCIONES POR HACER
### puzzlebot_navigation/config/nav2_params.yaml
- Quitar voxel_layer del local_costmap.
- Quitar voxel_layer y obstacle_layer del global_costmap, dejando sólo static_layer e inflation_layer.
- Eliminar secciones completas:
  - collision_monitor
  - velocity_smoother
- Ajustar RPP para laberinto pequeño:
  - bajar lookahead_dist, min_lookahead_dist, max_lookahead_dist
  - activar use_cost_regulated_linear_velocity_scaling
  - reducir regulated_linear_scaling_min_radius
  - reducir rotate_to_heading_min_angle
- Ajustar tolerancias:
  - required_movement_radius de 0.5 a algo menor
  - xy_goal_tolerance menor a 0.1
  - yaw_goal_tolerance más estricto
- En behavior_server, dejar sólo:
  - spin
  - backup
  - wait
- En planner_server:
  - allow_unknown: false
  - tolerance menor, por ejemplo 0.1.

### README.md
  - Agregar una sección de tabla comparativa del planner global, porque en el repo no encontré una tabla comparativa existente. Pondría una tabla breve comparando NavfnPlanner, SmacPlanner2D y ThetaStar, y justificaría que usan NavfnPlanner.
>>>>>>> origin/main
