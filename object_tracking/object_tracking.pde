import processing.video.*;
import java.util.*;

Movie myMovie;
int framecount = 1;
boolean finished = false;
List<String> original_images = new ArrayList<String>();

PImage reference_img, curr_img;
String ref_filename = "reference.jpg";

//int num_of_frames;



void setup() {
  size(500, 500);
  surface.setResizable(true);
  reference_img = loadImage(ref_filename);
  //reference_img.filter(GRAY);
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
      exhaustive_search();
    }
    
    if(key=='l'){
      logarithmic_search();
    }
    
  }
}

void exhaustive_search(){
  for(int f=0; f<original_images.size(); f++){//original_images.size()
    println(original_images.get(f));
    curr_img = loadImage(original_images.get(f));
    //curr_img.filter(GRAY);
    image(curr_img, 0, 0);
    
    
    // followed the link here with correlation equation: https://en.wikipedia.org/wiki/Template_matching
    float min_correl = Float.POSITIVE_INFINITY;
    println(min_correl);
    int bestrow = 0, bestcolumn = 0;
    
    for(int y=0; y<curr_img.height - reference_img.height; y++){
      for(int x=0; x<curr_img.width - reference_img.width; x++){
        
        float correl = 0.0;
        
        for(int i=0; i<reference_img.height; i++){
          for(int j=0; j<reference_img.width;j++){
            color cpx = curr_img.get(y+i, x+j);
            float c = (red(cpx)+green(cpx)+blue(cpx))/3.0;
            color rpx = reference_img.get(i, j);
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
        
  }
}

void logarithmic_search(){
  curr_img = loadImage(original_images.get(0));
  
  // followed the link here with correlation equation: https://en.wikipedia.org/wiki/Template_matching
  float min_correl = Float.POSITIVE_INFINITY;
  //println(min_correl);
  int bestrow = 0, bestcolumn = 0;
  
  for(int y=0; y<curr_img.height - reference_img.height; y++){
    for(int x=0; x<curr_img.width - reference_img.width; x++){
      
      float correl = 0.0;
      
      for(int i=0; i<reference_img.height; i++){
        for(int j=0; j<reference_img.width;j++){
          color cpx = curr_img.get(y+i, x+j);
          float c = (red(cpx)+green(cpx)+blue(cpx))/3.0;
          color rpx = reference_img.get(i, j);
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
    curr_img = loadImage(original_images.get(f));
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
        
        for(int i=0; i<reference_img.height; i++){
          for(int j=0; j<reference_img.width;j++){
            color cpx = curr_img.get(y_coord+i, x_coord+j);
            float c = (red(cpx)+green(cpx)+blue(cpx))/3.0;
            color rpx = reference_img.get(i, j);
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