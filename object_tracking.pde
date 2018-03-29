import processing.video.*;
import java.util.*;

Movie myMovie;
int framecount = 1;
boolean finished = false;
List<String> original_images = new ArrayList<String>();

PImage reference_img, curr_img;
String ref_filename = "reference.jpg";



void setup() {
  size(500, 500);
  surface.setResizable(true);
  reference_img = loadImage(ref_filename);
  reference_img.filter(GRAY);
  background(255);
  myMovie = new Movie(this, "totoro.mov");
  myMovie.play();
}

void draw() {
  background(255);
  if (myMovie.available()) {
    myMovie.read();
    surface.setSize(myMovie.width, myMovie.height);
  }
  
  image(myMovie, 0, 0);
  
  if(myMovie.time()<myMovie.duration()){
    framecount += 1;
    saveFrame("data/original_frame-#####.png");
    println(framecount);
  }
  if(myMovie.time() == myMovie.duration()){
    finished = true;
    for(int i=1; i<framecount; i++){
      String fileserial = String.format("%05d", i);
      String filename = "original_frame-"+fileserial+".png";
      original_images.add(filename);
    }
  }
}

void keyPressed(){
  if(finished){
    if(key=='e'){
      for(int f=0; f<original_images.size(); f++){//original_images.size()
        println(original_images.get(f));
        curr_img = loadImage(original_images.get(f));
        curr_img.filter(GRAY);
        image(curr_img, 0, 0);
        
        
        // followed the link here with correlation equation: https://en.wikipedia.org/wiki/Template_matching
        double best_match = Double.POSITIVE_INFINITY;
        println(best_match);
        int bestx = 0, besty = 0;
        
        for(int y=0; y<curr_img.height - reference_img.height; y++){
          for(int x=0; x<curr_img.width - reference_img.width; x++){
            
            double correl = 0.0;
            
            for(int i=0; i<reference_img.height; i++){
              //println(i);
              for(int j=0; j<reference_img.width;j++){
                //println("j: "+j);
                //int val = curr_img.get(i, j)*reference_img.get(i-x, j-y);
                correl += sq(curr_img.get(y+i, x+j) - reference_img.get(i, j));
              }
            }
            
            if(best_match>correl){
              //println("change");
              best_match = correl;
              bestx = x;
              besty = y;
            }
            
          }
        }
        println(best_match, bestx, besty);
        //image(curr_img, 0, 0);
        //background(255);
        //fill(0);
        //rect(bestx, besty, reference_img.width, reference_img.height);
            
      }
      
    }
  }
}

void exhaustive_search(){
}