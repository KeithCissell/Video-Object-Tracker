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


// Get Camera
Capture cam;

// Video Variables
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
String[] trackers = {"None", "SURF"};
int trackerIndex = 0;
SURFTracker surfer;


void setup() {
  size(600, 500);
  surface.setResizable(true);
  background(0);
  System.loadLibrary(Core.NATIVE_LIBRARY_NAME); // Use native library for SURF features
  
  // Set drawing params  
  rectMode(CORNERS);
  noFill();
  textSize(25);
  
  // Setup camera
  String[] cameras = Capture.list();
  
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this, cameras[0]);
    cam.start();     
  }
}

void draw() {
  if (!displayRef) {
    // Get current tracking method
    String tracker = trackers[trackerIndex];
    
    // Check if movie is available and get frame
    if (cam.available() && !paused) {
      cam.read();
      scene = cam;
      // Run frame through current tracker
      println("Analyzing New Frame: ", tracker);
      if (referenceSet) {
        if (tracker == "SURF") frameImg = surfer.findObject(scene);
      } else frameImg = scene;
    }
    
    // UPDATE DISPLAY
    // Set frame
    surface.setSize(frameImg.width, frameImg.height+100);
    background(0);
    
    // Add GUI info
    text("Tracker: " + tracker, 25, cam.height+35);
    text("Paused: " + str(paused), 25, cam.height+75);
    text("Reference Set: " + str(referenceSet), cam.width / 2, cam.height+75);
    
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
    if ((sx - ex) != 0 && (sy - ey) != 0) setReferenceImg(cam, sx, sy, ex, ey);
    selectingRef = false;
  }
}

void keyReleased() {
  // Pause/Play movie
  if (key == ' ' && !displayRef) {
    if (paused && !selectingRef) {
      //cam.play();
      paused = false;
    } else if (!paused) {
      //cam.pause();
      paused = true;
    }
  }
  // Reset Object Tracker
  else if (key == 'r') {
    // reset movie
    //cam.play();
    //cam.jump(0.0);
    //cam.pause();
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
}