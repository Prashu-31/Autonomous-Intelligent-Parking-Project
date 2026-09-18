**# 🚗 Autonomous Parking Vehicle Using ESP32**

An IoT-based autonomous parking vehicle developed using **ESP32, ultrasonic sensors, an 8-bit IR sensor array, L298N motor driver, and DC motors**. The system detects obstacles and boundaries around the vehicle and performs an automated parking sequence using a state-machine-based control algorithm.

---

**## 📌 Project Overview**

The **Autonomous Parking Vehicle** is designed to demonstrate how embedded systems and sensor-based decision-making can be used to achieve autonomous vehicle parking.

The vehicle continuously monitors its surroundings using four ultrasonic sensors positioned at the **front, rear, left, and right** sides. An **8-bit IR sensor array** is used for boundary/line detection.

The ESP32 processes the sensor information and controls four DC motors through an L298N motor driver.

The parking algorithm operates through different states:

**Approach → Align → Position → Reverse Parking → Parked**

An emergency-stop mechanism is also implemented to stop the vehicle when an obstacle is detected at an unsafe distance.

---

**## ✨ Features**

- 🚗 Autonomous parking operation
- 📡 Four-direction obstacle detection
- 📏 Front, rear, left, and right distance measurement
- 🔴 Emergency obstacle detection
- 🛑 Automatic emergency stop
- ↔️ Vehicle alignment
- 🔄 Automatic reverse parking
- 📍 Boundary/line detection using 8-bit IR array
- ⚙️ Four-wheel drive control
- 🧠 State-machine-based autonomous control
- 📊 Real-time sensor monitoring through Serial Monitor
- 🔌 ESP32-based embedded control system

---

**# 🧠 System Architecture**

                         ┌─────────────────────┐
                         │      6V BATTERY     │
                         │     4 × 1.5V Cells  │
                         └──────────┬──────────┘
                                    │
                    ┌───────────────┴───────────────┐
                    │                               │
                    ▼                               ▼
             ┌─────────────┐                 ┌─────────────┐
             │ L298N Motor │                 │    Buck     │
             │   Driver    │                 │  Converter  │
             └──────┬──────┘                 └──────┬──────┘
                    │                               │ 5V
                    ▼                               ▼
              ┌───────────┐                  ┌─────────────┐
              │ 4 × DC     │                  │    ESP32    │
              │  Motors    │                  │ Controller  │
              └───────────┘                  └──────┬──────┘
                                                    │
                    ┌───────────────────────────────┼────────────────────┐
                    │                               │                    │
                    ▼                               ▼                    ▼
             ┌──────────────┐                ┌──────────────┐     ┌──────────────┐
             │ 4 × HC-SR04  │                │ 8-bit IR     │     │ Parking       │
             │ Ultrasonic   │                │ Sensor Array │     │ Algorithm     │
             └──────────────┘                └──────────────┘     └──────────────┘

**🔧 Hardware Components**
| Component | Quantity | Purpose |
|---|---:|---|
| ESP32 Development Board | 1 | Main controller |
| HC-SR04 Ultrasonic Sensor | 4 | Obstacle and distance detection |
| 8-bit IR Sensor Array | 1 | Boundary/line detection |
| 74HC165 Shift Register | 1 | Reading the 8-bit IR array |
| L298N Motor Driver | 1 | DC motor control |
| DC Motors | 4 | Vehicle movement |
| Buck Converter | 1 | Regulated 5V supply |
| 1.5V Battery Cells | 4 | Power source |
| 1 kΩ Resistors | 4 | Ultrasonic ECHO voltage divider |
| 2 kΩ Resistors | 4 | Ultrasonic ECHO voltage divider |
| Jumper Wires | As required | Circuit connections |
| Robot Vehicle Chassis | 1 | Mechanical structure |

**🔌 ESP32 Pin Configuration**
Ultrasonic Sensors
Four HC-SR04 sensors are positioned around the vehicle.
| Sensor | Position | TRIG | ECHO |
|---|---|---:|---:|
| HC-SR04 #1 | Front | GPIO 25 | GPIO 34 |
| HC-SR04 #2 | Rear | GPIO 26 | GPIO 35 |
| HC-SR04 #3 | Left | GPIO 27 | GPIO 32 |
| HC-SR04 #4 | Right | GPIO 14 | GPIO 33 |

Sensor Arrangement

                    FRONT                   
                      │
                 ┌────▼────┐
                 │ HC-SR04 │
                 │  FRONT  │
                 └────┬────┘
                      │
          ┌───────────┴───────────┐
          │                       │
     ┌────▼────┐             ┌────▼────┐
     │ HC-SR04 │             │ HC-SR04 │
     │  LEFT   │             │  RIGHT  │
     └────┬────┘             └────┬────┘
          │                       │
          │      ┌─────────┐      │
          └──────► VEHICLE ◄──────┘
                 │         │
                 │  ESP32  │
                 │         │
                 │  L298N  │
                 └────┬────┘
                      │
                 ┌────▼────┐
                 │ HC-SR04 │
                 │  REAR   │
                 └────┬────┘
                      │
                     REAR
                     
**🚘 Motor Driver Connections**
The project uses an L298N motor driver.

    | L298N Pin | ESP32 GPIO |
    |---|---:|
    | ENA | GPIO 4 |
    | IN1 | GPIO 16 |
    | IN2 | GPIO 17 |
    | IN3 | GPIO 18 |
    | IN4 | GPIO 19 |
    | ENB | GPIO 21 |
    Motor Connections
    L298N OUT1 ───── Left Motor 1
    L298N OUT2 ───── Left Motor 2
    L298N OUT3 ───── Right Motor 1
    L298N OUT4 ───── Right Motor 2

The two motors on each side operate together.
             FRONT

       M1                 M3
    LEFT FRONT        RIGHT FRONT

       M2                 M4
    LEFT REAR         RIGHT REAR

             REAR

🔴 8-bit IR Sensor Array
The IR sensor array contains:
VCC
GND
D1
D2
D3
D4
D5
D6
D7
D8
The eight digital outputs are connected to a 74HC165 8-bit parallel-in/serial-out shift register.

    IR Array → 74HC165
    IR ARRAY              74HC165
    
    VCC  ──────────────── VCC
    GND  ──────────────── GND
    
    D1   ──────────────── D0
    D2   ──────────────── D1
    D3   ──────────────── D2
    D4   ──────────────── D3
    D5   ──────────────── D4
    D6   ──────────────── D5
    D7   ──────────────── D6
    D8   ──────────────── D7
    74HC165 → ESP32
    74HC165	ESP32
    DATA / Q7	GPIO 22
    CLOCK / CP	GPIO 23
    LOAD / PL	GPIO 13

The shift register allows all eight IR sensor states to be read using only three ESP32 GPIO pins.
⚡ Power Supply
The project uses four 1.5V cells.
1.5V + 1.5V + 1.5V + 1.5V ≈ 6V
Power distribution:

                  6V BATTERY
                      │
            ┌─────────┴─────────┐
            │                   │
            ▼                   ▼
       L298N MOTOR         BUCK CONVERTER
         DRIVER                 │
            │                   │
            ▼                   ▼
        4 × MOTORS             5V
                                │
                                ▼
                              ESP32
The buck converter is adjusted to provide approximately 5V for the ESP32 power input.
All modules must share a common ground.

    Battery GND
     │
     ├──── L298N GND
     ├──── Buck Converter GND
     ├──── ESP32 GND
     ├──── Ultrasonic GND
     └──── IR Array GND

🧩 Complete GPIO Table
Function	ESP32 GPIO
Front TRIG	GPIO 25
Front ECHO	GPIO 34
Rear TRIG	GPIO 26
Rear ECHO	GPIO 35
Left TRIG	GPIO 27
Left ECHO	GPIO 32
Right TRIG	GPIO 14
Right ECHO	GPIO 33
Motor ENA	GPIO 4
Motor IN1	GPIO 16
Motor IN2	GPIO 17
Motor IN3	GPIO 18
Motor IN4	GPIO 19
Motor ENB	GPIO 21
IR DATA	GPIO 22
IR CLOCK	GPIO 23
IR LOAD	GPIO 13


🧠 Autonomous Parking Algorithm
The vehicle uses a finite-state-machine approach.

                    ┌──────────────┐
                    │   APPROACH   │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │     ALIGN    │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │   POSITION   │
                    └──────┬───────┘
                           │
                           ▼
                  ┌──────────────────┐
                  │ REVERSE PARKING  │
                  └────────┬─────────┘
                           │
                           ▼
                    ┌──────────────┐
                    │    PARKED    │
                    └──────────────┘
At any point where an unsafe obstacle is detected:

              ┌─────────────────┐
              │  EMERGENCY STOP │
              └────────┬────────┘
                       │
                Area becomes clear
                       │
                       ▼
                   Resume
📏 Distance Thresholds
The current embedded control program uses:
Parameter	Value
Emergency distance	15 cm
Safe distance	35 cm
Parking distance	12 cm
Normal motor speed	170
Turning speed	150
Slow parking speed	110
These values can be adjusted according to the physical vehicle, sensor placement, and parking environment.

💻 Software
Development Environment
- Arduino IDE
- ESP32 Arduino Core
- C/C++ for ESP32
Simulation
The autonomous parking concept was also developed and tested in MATLAB before moving toward the hardware implementation.
The simulation includes:
- Vehicle model
- Parking slot
- Obstacles
- Virtual distance sensors
- Boundary detection
- Parking state machine
- Emergency-stop logic
- Vehicle trajectory

📂 Recommended Repository Structure

    Autonomous-Parking-Vehicle/
    │
    ├── README.md
    │
    ├── ESP32/
    │   └── autonomous_parking.ino
    │
    ├── MATLAB/
    │   └── autonomous_parking_simulation.m
    │
    ├── Circuit/
    │   └── circuit_diagram.png
    │
    ├── Documentation/
        └── project_report.pdf
        
🚀 How to Upload the ESP32 Program
1. Install Arduino IDE
Install Arduino IDE on your computer.
2. Install ESP32 Board Support
Add the ESP32 board package through the Arduino IDE Board Manager.
3. Open the Project
Open:
ESP32/autonomous_parking.ino
4. Select the Board
Select:
ESP32 Arduino → ESP32 Dev Module
5. Select the COM Port
Select the COM port corresponding to the connected ESP32.
6. Upload
Click:
Upload
If the board remains at:
Connecting........
press and hold the BOOT button on the ESP32 for a few seconds until uploading starts.

🖥️ Serial Monitor
After uploading the program, open the Serial Monitor.
Set:
Baud Rate: 115200
The ESP32 displays real-time sensor measurements.
Example:
F:85.2cm  R:91.4cm  L:43.8cm  Rt:45.1cm  IR:11111111
STATE: APPROACH

F:37.5cm  R:90.2cm  L:40.1cm  Rt:41.8cm  IR:11111111
STATE: ALIGN

STATE: POSITION

STATE: REVERSE PARKING

    ==============================
            VEHICLE PARKED
    ==============================

🛠️ Testing Procedure
The vehicle should be tested in stages:
Test 1 — Ultrasonic Sensors
Verify front, rear, left, and right distance measurements through the Serial Monitor.
Test 2 — IR Array
Verify the eight IR sensor outputs.
Test 3 — Motor Driver
Test forward, reverse, left, and right movement with the vehicle wheels lifted.
Test 4 — Obstacle Detection
Place an object in front of the vehicle and verify that the emergency-stop mechanism activates.
Test 5 — Autonomous Parking
Place the vehicle in the test area and allow the state machine to execute the parking sequence.

🛡️ Safety Considerations
- Always test motor movement with the wheels lifted initially.
- Verify battery polarity before powering the circuit.
- Set the buck converter output to approximately 5V before connecting it to the ESP32.
- Do not connect 5V HC-SR04 ECHO signals directly to ESP32 GPIOs.
- Use the recommended voltage-divider circuit.
- Maintain a common ground between the ESP32, sensors, motor driver, and power system.
- Check the motor driver's current capability before operating all four motors.
- Keep the emergency-stop mechanism active during testing.
- Stop testing immediately if the motor driver, battery, or wiring becomes excessively hot.

🔮 Future Enhancements
The project can be further developed with:
- 📱 Wi-Fi-based vehicle control
- 🌐 Web-based monitoring dashboard
- 📊 Real-time sensor dashboard
- 📷 Camera-based parking-space detection
- 🤖 Computer vision
- 📍 Automatic parking-slot identification
- 🎯 Improved parking accuracy
- ⚡ Battery voltage monitoring
- 📡 IoT cloud connectivity
- 📱 Mobile application
- 🧠 Advanced path-planning algorithms
- 🎛️ PID-based motion control

🎯 Applications
The concept can be applied to:
- Smart parking systems
- Autonomous vehicles
- Robotic vehicles
- Indoor parking robots
- Warehouse automation
- Intelligent transportation systems
- Embedded-system education
- Robotics research
- EV automation projects

📚 Project Highlights
Hardware
ESP32 + 4 Ultrasonic Sensors + 8-bit IR Array + L298N + 4 DC Motors
Control
State-machine-based autonomous parking
Detection
Distance sensing + boundary/line detection
Development
Arduino IDE + MATLAB
Domain
IoT | Embedded Systems | Robotics | Autonomous Vehicles

👨‍💻 Project Information
Project: Autonomous Parking Vehicle Using ESP32
Controller: ESP32
Programming: C/C++
Simulation: MATLAB
Sensors: HC-SR04 + 8-bit IR Array
Motor Driver: L298N
Application: Autonomous Parking

⭐ Project Goal
The primary goal of this project is to develop a compact autonomous vehicle capable of detecting its surroundings, avoiding obstacles, identifying boundaries, and performing an automated parking maneuver using an ESP32-based embedded control system.
📜 License
This project is intended for educational, academic, and prototype-development purposes.
