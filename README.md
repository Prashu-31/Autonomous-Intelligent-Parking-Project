🚗 Autonomous Parking Vehicle — ESP32
An IoT-based Autonomous Parking Vehicle using ESP32, ultrasonic distance sensors, an 8-bit IR sensor array, and a motor driver. The system detects obstacles, maintains vehicle alignment, and performs an automated reverse-parking sequence.
📌 Project Overview
The vehicle uses multiple sensors to understand its surroundings:
- 4 × HC-SR04 Ultrasonic Sensors — front, rear, left, and right obstacle detection
- 8-bit IR Sensor Array — boundary/line detection
- ESP32 — main controller
- L298N Motor Driver — controls the DC motors
- 4 × DC Motors — vehicle movement
- Buck Converter — regulated power for the ESP32
- 4 × 1.5 V Batteries — vehicle power source
⚙️ Features
- Front obstacle detection
- Rear obstacle detection during reverse parking
- Left/right distance detection
- Automatic emergency stop
- Vehicle alignment
- Automatic reverse parking
- 8-bit IR boundary detection
- State-machine-based control
- Serial Monitor sensor monitoring
🧠 Parking Control Logic
The system operates through the following states:
APPROACH
   ↓
ALIGN
   ↓
POSITION
   ↓
REVERSE PARK
   ↓
PARKED
If an obstacle is detected at an unsafe distance:
Any Parking State
       ↓
EMERGENCY STOP
       ↓
Obstacle Clear
       ↓
Resume
🔌 ESP32 Pin Configuration
Ultrasonic Sensors
Sensor	Position	TRIG	ECHO
HC-SR04 #1	Front	GPIO 25	GPIO 34
HC-SR04 #2	Rear	GPIO 26	GPIO 35
HC-SR04 #3	Left	GPIO 27	GPIO 32
HC-SR04 #4	Right	GPIO 14	GPIO 33


L298N Motor Driver
L298N	ESP32
ENA	GPIO 4
IN1	GPIO 16
IN2	GPIO 17
IN3	GPIO 18
IN4	GPIO 19
ENB	GPIO 21


74HC165 for 8-bit IR Array
74HC165	ESP32
DATA	GPIO 22
CLOCK	GPIO 23
LOAD	GPIO 13


🔋 Power Connections
The four 1.5 V cells are assumed to be connected in series:
4 × 1.5 V ≈ 6 V
Power architecture:
              6 V Battery
                  │
        ┌─────────┴─────────┐
        │                   │
        ▼                   ▼
   Motor Driver        Buck Converter
        │                   │
     Motors               5 V
                            │
                            ▼
                          ESP32
Important: Adjust the buck converter to approximately 5 V before connecting it to the ESP32 VIN/5V input.
Four ultrasonic sensors require:
- 4 × 1 kΩ resistors
- 4 × 2 kΩ resistors
💻 Software Requirements
Arduino IDE
Install:
- Arduino IDE
- ESP32 board package
Select:
Board:
ESP32 Arduino → ESP32 Dev Module
Select the correct COM port before uploading.
📂 Project Structure
Recommended GitHub repository structure:
Autonomous-Intelligent-Parking-Vehicle/
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
│   └── project_report.pdf
│
└── Images/
    └── prototype.jpg
🚀 How to Upload the ESP32 Code
1. Download/install Arduino IDE.
2. Install the ESP32 board package.
3. Open:
ESP32/autonomous_parking.ino
4. Connect the ESP32 using a USB data cable.
5. Select:
Tools → Board → ESP32 Arduino → ESP32 Dev Module
6. Select:
Tools → Port → COMx
7. Click Upload.
If the IDE gets stuck at:
Connecting........
press and hold the BOOT button on the ESP32 while uploading, then release it once the upload begins.
🖥️ Serial Monitor
After uploading:
Tools → Serial Monitor
Set the baud rate to:
115200
Example output:
F:85.2cm  R:91.4cm  L:43.8cm  Rt:45.1cm  IR:11111111
STATE: APPROACH

F:37.5cm  R:90.2cm  L:40.1cm  Rt:41.8cm  IR:11111111
STATE: ALIGN

F:30.1cm  R:88.4cm  L:31.2cm  Rt:33.0cm  IR:11111111
STATE: POSITION

STATE: REVERSE PARKING

==============================
        VEHICLE PARKED
==============================
🛡️ Safety
- Do not connect HC-SR04 ECHO directly to ESP32 GPIO when using 5 V logic.
- Verify the buck converter output with a multimeter before connecting the ESP32.
- Ensure all modules share a common GND.
- Check the motor driver's current capability before connecting two motors to one output channel.
- Test the vehicle with the wheels lifted before the first full-power movement.
- Keep the emergency-stop logic enabled during testing.
🔧 Future Improvements
- Wi-Fi-based vehicle monitoring
- Web/mobile dashboard
- Real-time sensor visualization
- Improved parking-slot detection
- PID-based steering/control
- Camera-based parking detection
- Automatic parking-space identification
- Battery voltage monitoring
- IoT cloud data logging
- Mobile app control
👨‍💻 Project
Autonomous Parking Vehicle Using ESP32
Domain: IoT • Embedded Systems • Autonomous Vehicles • Robotics
Controller: ESP32
Development: Arduino IDE + MATLAB Simulation
