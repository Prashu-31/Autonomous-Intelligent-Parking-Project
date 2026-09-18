/*
  ============================================================
       AUTONOMOUS PARKING VEHICLE - ESP32
  ============================================================

  Hardware:
  - ESP32 DevKit
  - 4 x HC-SR04 ultrasonic sensors
  - 8-bit IR sensor array
  - 74HC165 shift register
  - L298N motor driver
  - 4 DC motors
  - 6V battery + buck converter

  Ultrasonic:
  Front : TRIG 25, ECHO 34
  Rear  : TRIG 26, ECHO 35
  Left  : TRIG 27, ECHO 32
  Right : TRIG 14, ECHO 33

  L298N:
  ENA : GPIO 4
  IN1 : GPIO 16
  IN2 : GPIO 17
  IN3 : GPIO 18
  IN4 : GPIO 19
  ENB : GPIO 21

  74HC165:
  DATA : GPIO 22
  CLOCK: GPIO 23
  LOAD : GPIO 13
*/

// ============================================================
// ULTRASONIC SENSOR PINS
// ============================================================

#define FRONT_TRIG 25
#define FRONT_ECHO 34

#define REAR_TRIG 26
#define REAR_ECHO 35

#define LEFT_TRIG 27
#define LEFT_ECHO 32

#define RIGHT_TRIG 14
#define RIGHT_ECHO 33


// ============================================================
// MOTOR DRIVER PINS - L298N
// ============================================================

#define ENA 4

#define IN1 16
#define IN2 17

#define IN3 18
#define IN4 19

#define ENB 21


// ============================================================
// 74HC165 PINS
// ============================================================

#define IR_DATA 22
#define IR_CLOCK 23
#define IR_LOAD 13


// ============================================================
// MOTOR SPEED
// ============================================================

int normalSpeed = 170;
int slowSpeed   = 120;
int turnSpeed   = 150;


// ============================================================
// PARKING PARAMETERS
// ============================================================

const float EMERGENCY_DISTANCE = 20.0;   // cm
const float SAFE_DISTANCE      = 40.0;   // cm

const float PARKING_DISTANCE   = 12.0;   // cm


// ============================================================
// PARKING STATES
// ============================================================

enum ParkingState
{
  APPROACH,
  ALIGN,
  POSITIONING,
  REVERSE_PARKING,
  PARKED,
  EMERGENCY_STOP
};

ParkingState state = APPROACH;


// ============================================================
// SENSOR VARIABLES
// ============================================================

float frontDistance;
float rearDistance;
float leftDistance;
float rightDistance;


// ============================================================
// SETUP
// ============================================================

void setup()
{
  Serial.begin(115200);

  // Ultrasonic TRIG
  pinMode(FRONT_TRIG, OUTPUT);
  pinMode(REAR_TRIG, OUTPUT);
  pinMode(LEFT_TRIG, OUTPUT);
  pinMode(RIGHT_TRIG, OUTPUT);

  // Ultrasonic ECHO
  pinMode(FRONT_ECHO, INPUT);
  pinMode(REAR_ECHO, INPUT);
  pinMode(LEFT_ECHO, INPUT);
  pinMode(RIGHT_ECHO, INPUT);

  // Motor driver
  pinMode(ENA, OUTPUT);

  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);

  pinMode(IN3, OUTPUT);
  pinMode(IN4, OUTPUT);

  pinMode(ENB, OUTPUT);

  // 74HC165
  pinMode(IR_DATA, INPUT);
  pinMode(IR_CLOCK, OUTPUT);
  pinMode(IR_LOAD, OUTPUT);

  digitalWrite(IR_CLOCK, LOW);
  digitalWrite(IR_LOAD, HIGH);

  stopMotors();

  Serial.println();
  Serial.println("=================================");
  Serial.println(" AUTONOMOUS PARKING VEHICLE");
  Serial.println(" ESP32 SYSTEM STARTING...");
  Serial.println("=================================");

  delay(2000);

  Serial.println("System Ready");
}


// ============================================================
// MAIN LOOP
// ============================================================

void loop()
{
  // Read ultrasonic sensors
  readUltrasonicSensors();

  // Read 8-bit IR array
  byte irData = readIRArray();

  // Print sensor information
  printSensorData(irData);

  // Safety check
  if (checkEmergency())
  {
    state = EMERGENCY_STOP;
  }

  // Execute parking state
  switch (state)
  {
    case APPROACH:
      approachParkingArea();
      break;

    case ALIGN:
      alignVehicle();
      break;

    case POSITIONING:
      positionVehicle();
      break;

    case REVERSE_PARKING:
      reverseParking();
      break;

    case PARKED:
      parkedState();
      break;

    case EMERGENCY_STOP:
      emergencyStop();
      break;
  }

  delay(100);
}


// ============================================================
// ULTRASONIC DISTANCE FUNCTION
// ============================================================

float getDistance(int trigPin, int echoPin)
{
  digitalWrite(trigPin, LOW);
  delayMicroseconds(3);

  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);

  digitalWrite(trigPin, LOW);

  long duration = pulseIn(echoPin, HIGH, 25000);

  if (duration == 0)
  {
    return 999.0;
  }

  float distance = duration * 0.0343 / 2.0;

  return distance;
}


// ============================================================
// READ ALL ULTRASONIC SENSORS
// ============================================================

void readUltrasonicSensors()
{
  frontDistance = getDistance(FRONT_TRIG, FRONT_ECHO);

  delay(10);

  rearDistance = getDistance(REAR_TRIG, REAR_ECHO);

  delay(10);

  leftDistance = getDistance(LEFT_TRIG, LEFT_ECHO);

  delay(10);

  rightDistance = getDistance(RIGHT_TRIG, RIGHT_ECHO);
}


// ============================================================
// 74HC165 - READ 8 IR SENSORS
// ============================================================

byte readIRArray()
{
  byte data = 0;

  // Load parallel inputs
  digitalWrite(IR_LOAD, LOW);
  delayMicroseconds(5);

  digitalWrite(IR_LOAD, HIGH);

  // Read 8 bits
  for (int i = 0; i < 8; i++)
  {
    data <<= 1;

    if (digitalRead(IR_DATA))
    {
      data |= 1;
    }

    digitalWrite(IR_CLOCK, HIGH);
    delayMicroseconds(2);

    digitalWrite(IR_CLOCK, LOW);
    delayMicroseconds(2);
  }

  return data;
}


// ============================================================
// PRINT SENSOR DATA
// ============================================================

void printSensorData(byte irData)
{
  Serial.println("--------------------------------");

  Serial.print("Front : ");
  Serial.print(frontDistance);
  Serial.println(" cm");

  Serial.print("Rear  : ");
  Serial.print(rearDistance);
  Serial.println(" cm");

  Serial.print("Left  : ");
  Serial.print(leftDistance);
  Serial.println(" cm");

  Serial.print("Right : ");
  Serial.print(rightDistance);
  Serial.println(" cm");

  Serial.print("IR    : ");

  for (int i = 7; i >= 0; i--)
  {
    Serial.print(bitRead(irData, i));
  }

  Serial.println();

  Serial.print("STATE : ");
  printState();

  Serial.println();
}


// ============================================================
// PRINT STATE
// ============================================================

void printState()
{
  switch (state)
  {
    case APPROACH:
      Serial.println("APPROACH");
      break;

    case ALIGN:
      Serial.println("ALIGN");
      break;

    case POSITIONING:
      Serial.println("POSITIONING");
      break;

    case REVERSE_PARKING:
      Serial.println("REVERSE PARKING");
      break;

    case PARKED:
      Serial.println("PARKED");
      break;

    case EMERGENCY_STOP:
      Serial.println("EMERGENCY STOP");
      break;
  }
}


// ============================================================
// EMERGENCY SAFETY
// ============================================================

bool checkEmergency()
{
  if (frontDistance < EMERGENCY_DISTANCE)
  {
    Serial.println("!!! FRONT OBSTACLE !!!");
    return true;
  }

  if (rearDistance < EMERGENCY_DISTANCE)
  {
    Serial.println("!!! REAR OBSTACLE !!!");
    return true;
  }

  if (leftDistance < EMERGENCY_DISTANCE)
  {
    Serial.println("!!! LEFT OBSTACLE !!!");
    return true;
  }

  if (rightDistance < EMERGENCY_DISTANCE)
  {
    Serial.println("!!! RIGHT OBSTACLE !!!");
    return true;
  }

  return false;
}


// ============================================================
// STATE 1 - APPROACH
// ============================================================

void approachParkingArea()
{
  Serial.println("Approaching parking area...");

  if (frontDistance > SAFE_DISTANCE)
  {
    moveForward(normalSpeed);
  }
  else
  {
    stopMotors();

    Serial.println("Parking area detected.");

    delay(500);

    state = ALIGN;
  }
}


// ============================================================
// STATE 2 - ALIGN
// ============================================================

void alignVehicle()
{
  Serial.println("Aligning vehicle...");

  stopMotors();

  delay(300);

  /*
     Basic alignment logic.

     If left side is too close:
     move slightly right.

     If right side is too close:
     move slightly left.
  */

  if (leftDistance < 25)
  {
    turnRight(turnSpeed);
    delay(250);
  }

  else if (rightDistance < 25)
  {
    turnLeft(turnSpeed);
    delay(250);
  }

  else
  {
    stopMotors();

    Serial.println("Vehicle aligned.");

    delay(500);

    state = POSITIONING;
  }
}


// ============================================================
// STATE 3 - POSITIONING
// ============================================================

void positionVehicle()
{
  Serial.println("Positioning vehicle...");

  if (leftDistance < 20)
  {
    turnRight(slowSpeed);

    delay(150);

    stopMotors();
  }

  else if (rightDistance < 20)
  {
    turnLeft(slowSpeed);

    delay(150);

    stopMotors();
  }

  else
  {
    stopMotors();

    delay(300);

    Serial.println("Position ready.");

    state = REVERSE_PARKING;
  }
}


// ============================================================
// STATE 4 - REVERSE PARKING
// ============================================================

void reverseParking()
{
  Serial.println("Reverse parking...");

  /*
     Rear ultrasonic sensor controls
     the reverse movement.
  */

  if (rearDistance > PARKING_DISTANCE)
  {
    moveBackward(slowSpeed);
  }

  else
  {
    stopMotors();

    delay(500);

    Serial.println("Parking position reached.");

    state = PARKED;
  }
}


// ============================================================
// STATE 5 - PARKED
// ============================================================

void parkedState()
{
  stopMotors();

  Serial.println("=================================");
  Serial.println("          VEHICLE PARKED");
  Serial.println("=================================");

  delay(1000);
}


// ============================================================
// STATE 6 - EMERGENCY STOP
// ============================================================

void emergencyStop()
{
  stopMotors();

  Serial.println();
  Serial.println("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
  Serial.println("       EMERGENCY STOP");
  Serial.println("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");

  delay(500);

  /*
     Vehicle remains stopped until
     all obstacles move away.
  */

  readUltrasonicSensors();

  if (frontDistance > SAFE_DISTANCE &&
      rearDistance > SAFE_DISTANCE &&
      leftDistance > SAFE_DISTANCE &&
      rightDistance > SAFE_DISTANCE)
  {
    Serial.println("Area clear.");

    delay(1000);

    state = APPROACH;
  }
}


// ============================================================
// MOTOR CONTROL
// ============================================================

void moveForward(int speedValue)
{
  // Left side forward
  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);

  // Right side forward
  digitalWrite(IN3, HIGH);
  digitalWrite(IN4, LOW);

  analogWrite(ENA, speedValue);
  analogWrite(ENB, speedValue);
}


void moveBackward(int speedValue)
{
  // Left side reverse
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, HIGH);

  // Right side reverse
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, HIGH);

  analogWrite(ENA, speedValue);
  analogWrite(ENB, speedValue);
}


void turnLeft(int speedValue)
{
  // Left side reverse
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, HIGH);

  // Right side forward
  digitalWrite(IN3, HIGH);
  digitalWrite(IN4, LOW);

  analogWrite(ENA, speedValue);
  analogWrite(ENB, speedValue);
}


void turnRight(int speedValue)
{
  // Left side forward
  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);

  // Right side reverse
  digitalWrite(IN3, LOW);
  digitalWrite(IN4, HIGH);

  analogWrite(ENA, speedValue);
  analogWrite(ENB, speedValue);
}


// ============================================================
// STOP MOTORS
// ============================================================

void stopMotors()
{
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);

  digitalWrite(IN3, LOW);
  digitalWrite(IN4, LOW);

  analogWrite(ENA, 0);
  analogWrite(ENB, 0);
}