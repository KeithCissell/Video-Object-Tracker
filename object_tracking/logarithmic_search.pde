/*
LogarithmicSearch
This class creates an instance of a logarithmic search tracker. This tracker is given an object to track,
it can then be passed a scene that it will search for the object in and return any results.

Detection method following this example: https://en.wikipedia.org/wiki/Template_matching
*/

class LogarithmicSearch{
  
  // ATRIBUTES
  PImage reference_img;
  int bestrow;
  int bestcolumn;
  
  // CONSTRUCTOR
  LogarithmicSearch(PImage ref_img, int startRow, int startCol){
    reference_img = ref_img;
    bestrow = startRow;
    bestcolumn = startCol;
  }
  
  // FIND OBJECT
  // Takes in a scene and tries to find object
  PImage findObject(PImage sceneImg){
    // Keep a copy of the original scene img to mark and return
    PImage marked_img = sceneImg.copy();
    
    // Convert scene to grayscale
    sceneImg.filter(GRAY);
    
    // Set Minimum SAD (Sum of Absolute Differences)
    float minSAD = Float.POSITIVE_INFINITY;

    // Perform a logrithm area based search
    int p = 8;
    while(p != 1){
      int k = int(ceil(log(p)/log(2)));
      int d = int(pow(2,(k-1)));
      int x = bestcolumn;
      int y = bestrow;
      
      int[][] points = {{x-d, y-d},{x, y-d},{x+d, y-d},
                        {x-d, y  },{x, y  },{x+d, y  },
                        {x-d, y+d},{x, y+d},{x+d, y+d}};
      
      for(int pnt = 0; pnt < points.length; pnt++){
        int x_coord = points[pnt][0];
        int y_coord = points[pnt][1];
        
        float currentSAD = 0.0;
        
        // Iterate through reference image
        for(int i = 0; i < referenceImg.height; i++){
          for(int j = 0; j < referenceImg.width; j++){
            color sceneColor = sceneImg.get(y_coord+i, x_coord+j);
            color refColor = referenceImg.get(i, j);
            currentSAD += abs(red(sceneColor) - red(refColor));
          }
        }
        
        // Update best SAD
        if(currentSAD < minSAD){
          minSAD = currentSAD;
          bestrow = y_coord;
          bestcolumn = x_coord;
        }
      }
      p = int(round(p/2));
    }
    
    // Draw a rectangle around the best match found
    int startY = bestcolumn;
    int startX = bestrow;
    int endY = bestcolumn + reference_img.width;
    int endX = bestrow + reference_img.height;
    
    // Draw top and bottom of rect (stroke of 2px wide)
    for(int x = startX; x <= endX; x++){
      marked_img.set(x, startY, color(255,0,0));
      marked_img.set(x, startY-1, color(255,0,0));
      marked_img.set(x, endY, color(255,0,0));
      marked_img.set(x, endY+1, color(255,0,0));
    }
    // Draw left and right of rect (stroke of 2px wide)
    for(int y = startY; y <= endY; y++){
      marked_img.set(startX, y, color(255,0,0));
      marked_img.set(startX-1, y, color(255,0,0));
      marked_img.set(endX, y, color(255,0,0));
      marked_img.set(endX+1, y, color(255,0,0));
    }
    
    // Returned the marked image
    return marked_img;    
  }

}