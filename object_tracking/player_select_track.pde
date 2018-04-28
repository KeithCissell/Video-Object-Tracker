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

// Movies
String soccerMovie = "totoro.mov";
String test1Movie = "test1.mp4";

// Reference Images
String soccerBall = "reference.jpg";
String test1Ref = "test1ref.jpg";

// Setup Movie to play and image to track
String fnameMovie = soccerMovie;
String refFilename = soccerBall;
PImage frame_img;
Movie m;

PImage referenceImg;
SURFTracker surfer;
ExhaustiveSearch exhaust;
LogarithmicSearch logsearch;
boolean paused = false;
float playSpeed = 1.0;
int startX, startY;

boolean[] flags = new boolean[] {false, false, false};  // sift, exhaustive, logarithmic
ArrayList<PImage> images = new ArrayList<PImage>();

String curr_algo_disp = "";
boolean finished = false;

void setup() {
  size(500, 500);
  background(0);
  System.loadLibrary(Core.NATIVE_LIBRARY_NAME); // Use native library for SURF features
  
  referenceImg = loadImage(refFilename);
  surfer = new SURFTracker(referenceImg);
  exhaust = new ExhaustiveSearch(referenceImg);
  logsearch = new LogarithmicSearch(referenceImg);
  
  surface.setResizable(true);
  frame_img = createImage(width, height, RGB);
  //frameRate(30);
  
  rectMode(CORNERS);
  noFill();
  textSize(25);
  
  m = new Movie(this, fnameMovie);
  m.play();
}

void draw() {  
  if(paused && mousePressed){
    color sc = color(255,0,0);
    stroke(sc);
    rect(startX, startY, mouseX, mouseY);
  } else{
    if(flags[0]==true){
      //println(flags);
      println("Analyzing New Frame");
      //referenceImg = loadImage(refFilename);
      //surfer = new SURFTracker(referenceImg);
      frame_img = surfer.findObject(m);
      curr_algo_disp = "SURF";
    }
    if(finished==true && flags[1]==true){
      //println("hi");
      curr_algo_disp = "exhaustive search";
      for(int fimg=0; fimg<images.size(); fimg++){
        frame_img = exhaust.exhaustive_search(images.get(fimg));
      }
    }
    if(finished==true && flags[2]==true){
      println("hi");
      curr_algo_disp = "logarithmic search";
      for(int fimg=0; fimg<images.size(); fimg++){
        frame_img = logsearch.logarithmic_search(images.get(fimg), fimg);
      }
    }
  }
  //println(images.size());
  
  image(frame_img, 0, 0);
  text(curr_algo_disp, 50, m.height+25);
  
  if(m.time() == m.duration()){
    finished = true;
    //println(finished);
  }
}

void movieEvent(Movie m) {
  //Your code here to read the new frame
  if(m.available()){
    m.read();
    //The following tells you the frame size; not needed for the given videos
    //println(m.width + "; " + m.height);
    frame_img = m.get();  //Copy the new frame into frame_img
    images.add(frame_img);
    surface.setSize(frame_img.width, frame_img.height+100);
  }
}

void keyReleased() {
  if (key == ' ') {
    paused ^= true;
    if (paused) {
    //Your code here to start the video playing again
    m.play();
   } else {
    //Your code here to pause the video
    m.pause();
   }
  } else if(key == 's'){
    //m.speed(playSpeed/10);
    for(int fg = 0; fg<flags.length; fg++){
      flags[fg] = false;
    }
    flags[0] = true;
  } else if(key == 'e'){
    m.speed(playSpeed);
    for(int fg = 0; fg<flags.length; fg++){
      flags[fg] = false;
    }
    flags[1] = true;
  } else if(key == 'l'){
    m.speed(playSpeed);
    for(int fg = 0; fg<flags.length; fg++){
      flags[fg] = false;
    }
    flags[2] = true;
  }
  else if(key == '0'){
    for(int fg = 0; fg<flags.length; fg++){
      flags[fg] = false;
    }
  }
}

void mousePressed(){
  startX = mouseX;
  startY = mouseY;
}

void mouseReleased(){
  int endX, endY;
  if (mouseX < startX) {
    endX = startX;
    startX = mouseX;
  } else {
    endX = mouseX;
  }
  if (mouseY < startY) {
    endY = startY;
    startY = mouseY;
  } else {
    endY = mouseY;
  }
  if(endX - startX == 0 || endY - startY == 0){
    
  } else{
    save_ref_img(m, startX, startY, endX, endY);
  }
}

void save_ref_img(PImage img, int sx, int sy, int ex, int ey){
  PImage ref_img = createImage(ex - sx, ey - sy, RGB);
  for(int y=sy; y<ey; y++){
    for(int x=sx; x<ex; x++){
      color cpx = img.get(x, y);
      ref_img.set(x-sx, y-sy, cpx);
    }
  }
  image(ref_img,0,0);
  ref_img.save("data/ref_img.jpg");
  referenceImg = loadImage("ref_img.jpg");
}

void mouseWheel(MouseEvent event) {
  float sv = event.getCount();
  println(-sv);
  if(playSpeed>0){
    println(constrain(playSpeed-0.01*sv, 0.1, 2.0));
    playSpeed = constrain(playSpeed-0.01*sv, 0.1, 2.0);
  } else{
    println(constrain(playSpeed+0.01*sv, -2.0, -0.1));
    playSpeed = constrain(playSpeed+0.01*sv, -2.0, -0.1);
  }
  //println(constrain(playSpeed-0.1*sv, 0.1, 2.0));
  //playSpeed = constrain(playSpeed-0.1*sv, 0.1, 2.0);
  m.speed(playSpeed);
}