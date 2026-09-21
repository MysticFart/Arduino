/*
 * Processing 4 Java code for a Radar Display
 *
 * This sketch reads angle and distance data from an Arduino
 * over the serial port and visualizes it as a classic radar screen.
 *
 * Arduino data format:
 *     angle,distance.
 *
 * Example:
 *     45,12.
 *     46,13.
 *     47,11.
 *
 * IMPORTANT FOR WINDOWS:
 *     Change PORT below to your Arduino COM port.
 *
 * Example:
 *     "COM5"
 */

import processing.serial.*;


// Global Variables


// Serial port object
Serial serialPort;
String PORT = "";

// Font for displaying text
PFont font;

// String used to buffer incoming serial data
String inString = "";


// Window Dimensions


int screenWidth = 800;
int screenHeight = 450;


// Radar Properties


float radarRadius = 350;

// Center coordinates of the radar
float radarCenterX = screenWidth / 2.0;

// Position the radar baseline near the bottom of the window
float radarCenterY = screenHeight - 100;


// Serial / Arduino Settings

String PORT_NAME = PORT;

// Must match Serial.begin(...) in your Arduino code
int BAUD_RATE = 9600;


// Current Radar Data


int currentAngle = 0;
int currentDistance = 0;


// Point History


// Stores previously detected points so that they can fade away.
ArrayList<RadarPoint> pointHistory = new ArrayList<RadarPoint>();


// Setup


void setup() {


  // Window and Graphics Setup


  size(800, 450);

  smooth();

  // Create a font for text display
  font = createFont("Monospaced", 20);
  textFont(font);

  // Serial Communication Setup

  println("Available Serial Ports:");
  printArray(Serial.list());

  println();
  println("Trying to connect to: " + PORT_NAME);

  try {

    serialPort = new Serial(this, PORT_NAME, BAUD_RATE);

    // Clear anything that may already be in the serial buffer
    serialPort.clear();

    /*
     * The Arduino terminates every measurement with '.'
     *
     * Example:
     *     90,15.
     *
     * Processing will call serialEvent() whenever a complete
     * measurement ending in '.' has been received.
     */
    serialPort.bufferUntil('.');

    println("Connected successfully to " + PORT_NAME);

  } 
  catch (Exception e) {

    println();
    println("ERROR: Could not open serial port.");
    println("Port: " + PORT_NAME);
    println("Error: " + e.getMessage());
    println();
    println("Available ports are:");
    printArray(Serial.list());
    println();
    println("Make sure:");
    println("1. The Arduino is connected.");
    println("2. PORT_NAME is set to the correct COM port.");
    println("3. The Arduino IDE Serial Monitor is closed.");
  }
}

//Draw

void draw (){
  
  // Dark green background
  background(0, 20, 0);

  // Draw radar grid
  drawRadarGrid();

  // Draw text information
  drawTextLabels();

  // Draw current sweep line
  drawSweepLine(currentAngle);

  // Draw current detected object
  drawDetectedPoints();

  // Draw fading history
  updateAndDrawHistory();
  
}

//Radar Grid

void drawRadarGrid() {
  
  /*
   * Draws the concentric semi-circles and radial lines
   * of the radar.
   */

  stroke(0, 150, 0);
  noFill();
  strokeWeight(2);


  // Draw 2 concentric semi-circles


  for (int i = 1; i < 3; i++) {

    float radius = i * (radarRadius / 2.0);

    /*
     * Draw only the top half of the circle.
     *
     * PI     = 180 degrees
     * TWO_PI = 360 degrees
     */
    arc(
      radarCenterX,
      radarCenterY,
      radius * 2,
      radius * 2,
      PI,
      TWO_PI
      );
  }


  // Horizontal closing line


  line(
    radarCenterX - radarRadius,
    radarCenterY,
    radarCenterX + radarRadius,
    radarCenterY
    );


  // Draw 5 radial lines


  /*
   * These correspond to:
   *
   * 180°
   * 135°
   * 90°
   * 45°
   * 0°
   *
   * across the 180-degree radar.
   */

  for (int i = 0; i < 5; i++) {

    float angle = radians((i * 45) - 180);

    float x2 =
      radarCenterX +
      radarRadius * cos(angle);

    float y2 =
      radarCenterY +
      radarRadius * sin(angle);

    line(
      radarCenterX,
      radarCenterY,
      x2,
      y2
      );
  }
}

//Text Labels

void drawTextLabels() {
  
  /*
   * Displays information about the current radar reading.
   */

  fill(0, 200, 0);
  noStroke();


  // Distance labels


  for (int i = 1; i < 3; i++) {

    float radiusText =
      i * (radarRadius / 2.0);

    text(
      i * 10 + " cm",
      radarCenterX + radiusText + 5,
      radarCenterY - 5
      );
  }


  // Current angle


  text(
    "Angle: " + currentAngle + " deg",
    20,
    40
    );


  // Current distance


  text(
    "Distance: " + currentDistance + " cm",
    20,
    70
    );


  // Title


  text(
    "Radar Display",
    width / 2 - 80,
    40
    );

}


//Sweep Line

void drawSweepLine(int angle) {
  
  /*
   * Draws the moving line that sweeps across the radar.
   */

  stroke(0, 255, 0, 150);
  strokeWeight(3);

  /*
   * The Arduino reports:
   *
   *     0°   -> left
   *     90°  -> center
   *     180° -> right
   *
   * The original Python sketch converted this using:
   *
   *     radians(angle - 180)
   */

  float radAngle = radians(angle - 180);

  float endX =
    radarCenterX +
    radarRadius * cos(radAngle);

  float endY =
    radarCenterY +
    radarRadius * sin(radAngle);

  line(
    radarCenterX,
    radarCenterY,
    endX,
    endY
    );
}


//Detected Points

void drawDetectedPoints(){
  /*
   * Draws a point on the radar for the current detection.
   */

  float maxDist = 20.0;

  // Only display objects between 0 and 20 cm
  if (currentDistance > 0 &&
      currentDistance < maxDist) {

    // Current detection = red
    stroke(255, 0, 0);
    strokeWeight(5);

    // Convert angle to radians
    float radAngle =
      radians(currentAngle - 180);

    // Convert distance from 0-20 cm
    // into 0-radarRadius pixels
    float mappedDist =
      map(
        currentDistance,
        0,
        maxDist,
        0,
        radarRadius
        );

    // Calculate point coordinates
    float pointX =
      radarCenterX +
      mappedDist * cos(radAngle);

    float pointY =
      radarCenterY +
      mappedDist * sin(radAngle);

    // Draw current detection
    point(pointX, pointY);

    // Add point to fading history
    pointHistory.add(
      new RadarPoint(
        pointX,
        pointY,
        255
        )
      );
  }
}


//Update and Draw History

void updateAndDrawHistory(){

  /*
   * Draws and fades out old points to create a trail effect.
   */

  // Go backwards so that removing elements is safe
  for (int i = pointHistory.size() - 1; i >= 0; i--) {

    RadarPoint p = pointHistory.get(i);

    // Draw fading point
    stroke(0, p.age, 0);
    strokeWeight(4);

    point(
      p.x,
      p.y
      );

    // Reduce brightness
    p.age -= 2;

    // Remove old points
    if (p.age <= 0) {
      pointHistory.remove(i);
    }
  }
}

//Serial event

void serialEvent(Serial port){

  /*
   * Processing calls this function whenever the serial
   * buffer reaches the delimiter defined by bufferUntil().
   *
   * Arduino sends:
   *
   *     angle,distance.
   *
   * Example:
   *
   *     90,12.
   */

  String incoming = port.readStringUntil('.');

  if (incoming == null) {
    return;
  }

  // Remove the final '.'
  incoming = incoming.substring(
    0,
    incoming.length() - 1
    );

  // Remove whitespace/newlines
  incoming = trim(incoming);

  // Ignore empty messages
  if (incoming.length() == 0) {
    return;
  }

  // Split:
  //
  // "90,12"
  //
  // into:
  //
  // ["90", "12"]

  String[] values =
    split(incoming, ',');

  // We expect exactly two values
  if (values.length == 2) {

    try {

      int angle =
        Integer.parseInt(
          trim(values[0])
          );

      int distance =
        Integer.parseInt(
          trim(values[1])
          );

      // Update radar data
      currentAngle = angle;
      currentDistance = distance;

    } 
    catch (NumberFormatException e) {

      // Ignore malformed serial data
      println(
        "Invalid serial data: " +
        incoming
        );
    }
  }
}


// Stop Serial Port When Sketch Exits

void dispose() {

  if (serialPort != null) {
    serialPort.stop();
    println("Serial port closed.");
  }

  super.dispose();

}



//RadarPoint class

class RadarPoint {
  
  float x;
  float y;
  float age;
  
  RadarPoint(float x, float y, float age) {
    this.x = x;
    this.y = y;
    this.age = age;
  }
}
