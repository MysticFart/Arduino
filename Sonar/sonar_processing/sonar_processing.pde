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
