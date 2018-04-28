class ExhaustiveSearch{
  PImage reference_img;
  
  ExhaustiveSearch(PImage ref_img){
    reference_img = ref_img;
  }
  
  PImage exhaustive_search(PImage displayImage){
    //for(int f=0; f< (original_images.size()/10); f+=10){//original_images.size()
    //  println(original_images.get(f));
    //  displayImage = loadImage(original_images.get(f));
    //displayImage.filter(GRAY);
    PImage marked_img = createImage(displayImage.width, displayImage.height, RGB);
    
    // followed the link here with correlation equation: https://en.wikipedia.org/wiki/Template_matching
    float min_correl = Float.POSITIVE_INFINITY;
    //println(min_correl);
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
    //println();
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
    
    return marked_img;
  }
  //}
  
}