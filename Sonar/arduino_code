#include <Servo.h>

// Define Pins
const int SERVO_PIN = 11;
const int TRIG_PIN = 8;
const int ECHO_PIN = 9;

// constants for Servo
const int MIN_ANGLE = 0;
const int MAX_ANGLE = 180;
const int ANGLE_STEP = 1;
const int SWEEP_DELAY = 15;

//Speed of sound is 343 m/s or 29.1 microseconds per centimeter
//The pulseIn() func measures the RTT
//The distance in cm is (duration / 2) / 29.1 = duration / 58.2
const float SPEED_COEF = 58.2;

Servo myServo;

void setup() {
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  myServo.attach(SERVO_PIN);
  Serial.begin(9600);
}

void loop() {
  sweepAndMeasure(MIN_ANGLE, MAX_ANGLE, ANGLE_STEP);

  sweepAndMeasure(MAX_ANGLE, MIN_ANGLE, -ANGLE_STEP);

}

/*
@brief Sweeps and measures the distance
@param start_angle the angle at which the servo starts
@param end_angle the angle at which the servo should stop
@param steps the increment at which the servo should stop to measure
*/
void sweepAndMeasure(int start_angle, int end_angle, int steps){
    for (int curr_angle = start_angle; (steps > 0) ? (curr_angle <= end_angle) : (curr_angle >= end_angle); 
    curr_angle += steps){
        myServo.write(curr_angle);
        delay(SWEEP_DELAY);
        int distance = calculate_distance();
        printData(curr_angle, distance);
    }
}

/*
@brief calculates the distance using the Ultrasonic sensor
@return returns the distance calculated in cm
*/
int calculate_distance(){
    //sending out a pulse of high freq
    digitalWrite(TRIG_PIN, LOW);
    delay(2);
    digitalWrite(TRIG_PIN, HIGH);
    delay(10);
    digitalWrite(TRIG_PIN, LOW);

    //recive the echo pulse
    long rtt = pulseIn(ECHO_PIN, HIGH);

    //calculate the distance and return it
    return static_cast<int>(rtt / SPEED_COEF);
}

/*
@brief prints the data and angle to the serial monitor
@param angle the angle at which was measured
@param the distance that was measured
*/
void printData(int angle, int dist){
    Serial.print(angle);
    Serial.print(",");
    Serial.print(dist);
    Serial.print(".");
}