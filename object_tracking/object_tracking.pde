import java.nio.*;
import java.util.*;
import java.io.File;

import processing.video.*;

import gab.opencv.*;
import org.opencv.core.*;
import org.opencv.features2d.*;
import org.opencv.calib3d.Calib3d;
import org.opencv.highgui.Highgui;
import org.opencv.imgproc.Imgproc;

// GLOBALS
PImage displayImage;
Movie myMovie;
PImage referenceImg;
SURFTracker surfer;

int framecount = 1;
boolean finished = false;
List<String> original_images = new ArrayList<String>();
//int num_of_frames;

// Movies
String soccerMovie = "totoro.mov";
String test1Movie = "test1.mp4";

// Reference Images
String soccerBall = "reference.jpg";
String test1Ref = "test1ref.jpg";

// Sample Items
String bookObject = "bookobject.jpg";
String bookScene = "bookscene.jpg";

// Setup Movie to play and image to track
String fnameMovie = test1Movie;
String refFilename = test1Ref;


void setup() {
  size(500, 500);
  surface.setResizable(true);
  System.loadLibrary(Core.NATIVE_LIBRARY_NAME); // Use native library for SURF features
  //referenceImg = loadImage(bookObject);
  referenceImg = loadImage(refFilename);
  surfer = new SURFTracker(referenceImg);
  //referenceImg.filter(GRAY);
  background(255);
  myMovie = new Movie(this, fnameMovie);
  myMovie.play();
  //PImage sceneImg = loadImage(bookScene);
  //displayImage = surfer.objectImg;
  //displayImage = surfer.objectFeaturesImg;
  //displayImage = surfer.findObject(sceneImg);
  displayImage = referenceImg;
}

void draw() {
  if (myMovie.available()) {
    myMovie.read();
    println("Analyzing New Frame");
    displayImage = surfer.findObject(myMovie);
  }
  //displayImage = surfer.objectFeaturesImg;
  surface.setSize(displayImage.width, displayImage.height);
  image(displayImage, 0, 0);
  println();
  
  //if (myMovie.available()) {
  //  myMovie.read();
  //  surface.setSize(myMovie.width, myMovie.height);
  //}
  
  //if(!finished) {
  //  background(255);
  //  image(myMovie, 0, 0);
  //}
  
  //if(myMovie.time()<myMovie.duration()){
  //  framecount += 1;
  //  saveFrame("data/original_frame-#####.png");
  //  println(framecount);
  //}
  //if(myMovie.time() == myMovie.duration()){
  //  finished = true;
  //  for(int i=1; i<framecount; i++){
  //    String fileserial = String.format("%05d", i);
  //    String filename = "original_frame-"+fileserial+".png";
  //    original_images.add(filename);
  //  }
  //}
}

void keyPressed(){
  if(finished){
    if(key=='e') exhaustive_search();
    else if(key=='l')logarithmic_search();
  }
}

void exhaustive_search(){
  for(int f=0; f< (original_images.size()/10); f+=10){//original_images.size()
    println(original_images.get(f));
    displayImage = loadImage(original_images.get(f));
    //displayImage.filter(GRAY);
    
    
    // followed the link here with correlation equation: https://en.wikipedia.org/wiki/Template_matching
    float min_correl = Float.POSITIVE_INFINITY;
    println(min_correl);
    int bestrow = 0, bestcolumn = 0;
    
    for(int y=0; y<(displayImage.height - referenceImg.height); y++){
      for(int x=0; x<(displayImage.width - referenceImg.width); x++){
        
        float correl = 0.0;
        
        for(int i=0; i<referenceImg.height; i++){
          for(int j=0; j<referenceImg.width;j++){
            color cpx = displayImage.get(y+i, x+j);
            float c = (red(cpx)+green(cpx)+blue(cpx))/3.0;
            color rpx = referenceImg.get(i, j);
            float r = (red(rpx)+green(rpx)+blue(rpx))/3.0;
            //println("cpx: "+cpx+"rpx: "+rpx);
            correl += abs(c - r);
          }
        }
        //println(correl);
        if(min_correl>correl){
          //println("change");
          min_correl = correl;
          bestrow = y;
          bestcolumn = x;
        }
        
      }
    }
    println(min_correl, bestrow, bestcolumn);
    println();
  }
}

void logarithmic_search(){
  displayImage = loadImage(original_images.get(0));
  
  // followed the link here with correlation equation: https://en.wikipedia.org/wiki/Template_matching
  float min_correl = Float.POSITIVE_INFINITY;
  //println(min_correl);
  int bestrow = 0, bestcolumn = 0;
  
  for(int y=0; y<displayImage.height - referenceImg.height; y++){
    for(int x=0; x<displayImage.width - referenceImg.width; x++){
      
      float correl = 0.0;
      
      for(int i=0; i<referenceImg.height; i++){
        for(int j=0; j<referenceImg.width;j++){
          color cpx = displayImage.get(y+i, x+j);
          float c = (red(cpx)+green(cpx)+blue(cpx))/3.0;
          color rpx = referenceImg.get(i, j);
          float r = (red(rpx)+green(rpx)+blue(rpx))/3.0;
          //println("cpx: "+cpx+"rpx: "+rpx);
          correl += abs(c - r);
        }
      }
      
      if(min_correl>correl){
        //println("change");
        min_correl = correl;
        bestrow = y;
        bestcolumn = x;
      }
      
    }
  }
  println(min_correl, bestrow, bestcolumn);
  //print(original_images.size());
  ///done with the first image
  println(framecount);
  for(int f=0; f<framecount; f++){//original_images.size()
    displayImage = loadImage(original_images.get(f));
    int p = 8;
    
    while(p != 1){
      int k = int(ceil(log(p)/log(2)));
      int d = int(pow(2,(k-1)));
      int x = bestcolumn, y = bestrow;
      
      int[][] points = {{x-d, y-d},{x, y-d},{x+d, y-d},
                        {x-d, y  },{x, y  },{x+d, y  },
                        {x-d, y+d},{x, y+d},{x+d, y+d}};
      
      min_correl = Float.POSITIVE_INFINITY;
      for(int pnt=0; pnt<9; pnt++){
        int x_coord = points[pnt][0];
        int y_coord = points[pnt][1];
        
        float correl = 0.0;
        
        for(int i=0; i<referenceImg.height; i++){
          for(int j=0; j<referenceImg.width;j++){
            color cpx = displayImage.get(y_coord+i, x_coord+j);
            float c = (red(cpx)+green(cpx)+blue(cpx))/3.0;
            color rpx = referenceImg.get(i, j);
            float r = (red(rpx)+green(rpx)+blue(rpx))/3.0;
            //println("cpx: "+cpx+"rpx: "+rpx);
            correl += abs(c - r);
          }
        }
        
        if(min_correl>correl){
          //println("change");
          min_correl = correl;
          bestrow = y_coord;
          bestcolumn = x_coord;
        }
      }
      p = int(round(p/2));
    }
    println("frame "+ (f+1)+": "+ bestrow +" " + bestcolumn);
  }
  
}