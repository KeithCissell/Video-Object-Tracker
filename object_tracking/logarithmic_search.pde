class LogarithmicSearch{
  PImage reference_img;
  float min_correl = Float.POSITIVE_INFINITY;
    //println(min_correl);
  int bestrow = 0, bestcolumn = 0;
  
  LogarithmicSearch(PImage ref_img){
    reference_img = ref_img;
  }
  
  PImage logarithmic_search(PImage displayImage, int frame){
    //displayImage = loadImage(original_images.get(0));
    PImage marked_img = createImage(displayImage.width, displayImage.height, RGB);
    
    // followed the link here with correlation equation: https://en.wikipedia.org/wiki/Template_matching
    
    if(frame==0){
      println("if selected");
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
    int sx = bestcolumn - reference_img.width/2, sy = bestrow - reference_img.height/2, ex = bestcolumn +reference_img.width/2, ey = bestrow +reference_img.height/2;
    for(int y=0; y<displayImage.height; y++){
      for(int x=0; x<displayImage.width; x++){
        if(sx<=x && x<=ex && y==sy || sx<=x && x<=ex && y==ey
        || sy<=y && y<=ey && x==sx || sy<=y && y<=ey && x==ex){
          marked_img.set(x, y, color(255,0,0));
        } else{
          color cpx = displayImage.get(x, y);
          marked_img.set(x, y, cpx);
        }
      }
    }
    }
    //print(original_images.size());
    ///done with the first image
    else{
      println("else selected");
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
      //println("frame "+ (f+1)+": "+ bestrow +" " + bestcolumn);
      println(min_correl, bestrow, bestcolumn);
      int sx = bestcolumn - reference_img.width/2, sy = bestrow - reference_img.height/2, ex = bestcolumn +reference_img.width/2, ey = bestrow +reference_img.height/2;
      for(int y=0; y<displayImage.height; y++){
        for(int x=0; x<displayImage.width; x++){
          if(sx<=x && x<=ex && y==sy || sx<=x && x<=ex && y==ey
          || sy<=y && y<=ey && x==sx || sy<=y && y<=ey && x==ex){
            marked_img.set(x, y, color(255,0,0));
          } else{
            color cpx = displayImage.get(x, y);
            marked_img.set(x, y, cpx);
          }
        }
      }
    }
    //else{
    //  println("else selected");
    //  println(min_correl, bestrow, bestcolumn);
    //}
      
      return marked_img;
    
    
  }

}