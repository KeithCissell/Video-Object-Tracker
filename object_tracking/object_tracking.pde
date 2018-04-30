import processing.video.*;
import java.nio.*;
import java.util.*;
import java.io.File;

import gab.opencv.*;
import org.opencv.core.*;
import org.opencv.features2d.*;
import org.opencv.calib3d.Calib3d;
import org.opencv.highgui.Highgui;
import org.opencv.imgproc.Imgproc;


// Movie Files
String soccerMovie = "totoro.mov";
String test1Movie = "test1.mp4";

// Test Reference Image Files
String soccerBall = "reference.jpg";
String test1Ref = "test1ref.jpg";


// SET MOVIE
String fnameMovie = soccerMovie;

// Movie Variables
Movie m;
PImage scene = new PImage(600, 400, RGB); // initialize to blank img
PImage frameImg = new PImage(600, 400, RGB); // initialize to blank img
boolean paused = false;
float playSpeed = 1.0;

// Reference Image
PImage referenceImg;
boolean referenceSet = false;
boolean selectingRef = false;
boolean displayRef = false;
float startX;
float startY;
float endX;
float endY;

// Trackers
String[] trackers = {"None", "SURF", "Exhaustive", "Logarithmic"};
int trackerIndex = 0;
SURFTracker surfer;
ExhaustiveSearch exhaust;
LogarithmicSearch logsearch;


void setup() {
  size(600, 500);
  surface.setResizable(true);
  background(0);
  System.loadLibrary(Core.NATIVE_LIBRARY_NAME); // Use native library for SURF features
  
  // Manual Test Setup
  // Setup Movie to play and image to track
  //String refFilename = soccerBall;
  //referenceImg = loadImage(refFilename);
  //surfer = new SURFTracker(referenceImg);
  //exhaust = new ExhaustiveSearch(referenceImg);
  //logsearch = new LogarithmicSearch(referenceImg);
  
  // Set drawing params  
  rectMode(CORNERS);
  noFill();
  textSize(25);
  
  // Start playing movie
  m = new Movie(this, fnameMovie);
  m.play();
  m.loop();
}

void draw() {
  if (!displayRef) {
    // Get current tracking method
    String tracker = trackers[trackerIndex];
    
    // Check if movie is available and get frame
    if (m.available()) {
      m.read();
      scene = m;
      // Run frame through current tracker
      println("Analyzing New Frame: ", tracker);
      if (referenceSet) {
        if (tracker == "SURF") frameImg = surfer.findObject(scene);
        else if (tracker == "Exhaustive") frameImg = exhaust.findObject(scene);
        else if (tracker == "Logarithmic") frameImg = logsearch.findObject(scene);
      } else frameImg = scene;
    }
    
    // UPDATE DISPLAY
    // Set frame
    surface.setSize(frameImg.width, frameImg.height+100);
    background(0);
    
    // Add GUI info
    text("Tracker: " + tracker, 25, m.height+35);
    text("Paused: " + str(paused), 25, m.height+75);
    text("Reference Set: " + str(referenceSet), m.width / 2, m.height+75);
    
    // Draw selection rect
    if (selectingRef) {
      image(scene, 0, 0); // display original image while user is selecting
      stroke(255, 0, 0);
      strokeWeight(3);
      endX = constrain(mouseX, 0.0, frameImg.width);
      endY = constrain(mouseY, 0.0, frameImg.height);
      rect(min(startX, endX), min(startY, endY), max(startX, endX), max(startY, endY));
    } else image(frameImg, 0, 0);
  } else {
    // Display the reference image
    surface.setSize(referenceImg.width, referenceImg.height);
    background(0);
    image(referenceImg, 0, 0);
  }  
}

void setReferenceImg(PImage img, int sx, int sy, int ex, int ey){
  // Build and set the reference image
  PImage ref_img = createImage(ex - sx, ey - sy, RGB);
  for(int y=sy; y<ey; y++){
    for(int x=sx; x<ex; x++){
      color cpx = img.get(x, y);
      ref_img.set(x-sx, y-sy, cpx);
    }
  }
  referenceImg = ref_img;
  referenceSet = true;
  
  // Create new trackers
  surfer = new SURFTracker(referenceImg);
  exhaust = new ExhaustiveSearch(referenceImg);
  logsearch = new LogarithmicSearch(referenceImg, sx, sy);
}

void mousePressed(){
  // Check if video paused and start drawing rect
  if (paused) {
    startX = constrain(mouseX, 0.0, frameImg.width);
    startY = constrain(mouseY, 0.0, frameImg.height);
    selectingRef = true;
  }
}

void mouseReleased(){
  if (selectingRef) {
    // Set referenceImg
    int sx = int(min(startX, endX));
    int sy = int(min(startY, endY));
    int ex = int(max(startX, endX));
    int ey = int(max(startY, endY));
    if ((sx - ex) != 0 && (sy - ey) != 0) setReferenceImg(m, sx, sy, ex, ey);
    selectingRef = false;
  }
}

void mouseWheel(MouseEvent event) {
  float sv = event.getCount();
  println(-sv);
  if(playSpeed>0){
    println(constrain(playSpeed-0.01*sv, 0.1, 2.0));
    playSpeed = constrain(playSpeed-0.01*sv, 0.1, 2.0);
  } else {
    println(constrain(playSpeed+0.01*sv, -2.0, -0.1));
    playSpeed = constrain(playSpeed+0.01*sv, -2.0, -0.1);
  }
  //println(constrain(playSpeed-0.1*sv, 0.1, 2.0));
  //playSpeed = constrain(playSpeed-0.1*sv, 0.1, 2.0);
  m.speed(playSpeed);
}

void keyReleased() {
  // Pause/Play movie
  if (key == ' ' && !displayRef) {
    if (paused && !selectingRef) {
      m.play();
      paused = false;
    } else if (!paused) {
      m.pause();
      paused = true;
    }
  }
  // Reset Object Tracker
  else if (key == 'r') {
    // reset movie
    m.play();
    m.jump(0.0);
    m.pause();
    paused = true;
    // reset tracker
    trackerIndex = 0;
    frameImg = new PImage(600, 400, RGB);
    referenceSet = false;
    selectingRef = false;
  }
  // Display the current reference image
  else if (key == 'i' && paused && referenceSet) displayRef = !displayRef;
  // Set Tracker
  else if(key == '0') trackerIndex = 0; // "None"
  else if(key == '1' && referenceSet && paused) trackerIndex = 1; // "SURF"
  else if(key == '2' && referenceSet && paused) trackerIndex = 2; // "Exhaustive"
  else if(key == '3' && referenceSet && paused) trackerIndex = 3; // "Logarithmic"
}