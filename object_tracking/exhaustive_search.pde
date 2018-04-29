/*
ExhauxtiveSearch
This class creates an instance of a exhaustive search tracker. This tracker is given an object to track,
it can then be passed a scene that it will search for the object in and return any results.

Detection method following this example: https://en.wikipedia.org/wiki/Template_matching
*/

class ExhaustiveSearch{
  
  // ATRIBUTES
  PImage reference_img;
  
  // CONSTRUCTOR
  ExhaustiveSearch(PImage ref_img){
    reference_img = ref_img;
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
    // Set row and col of best SAD found
    int bestrow = 0;
    int bestcolumn = 0;
    
    // Iterate through the scene image
    for(int y = 0; y <= (sceneImg.height - referenceImg.height); y++){
      for(int x = 0; x <= (sceneImg.width - referenceImg.width); x++){
        
        float currentSAD = 0.0;
        
        // Iterate through reference image
        for(int i = 0; i < referenceImg.height; i++){
          for(int j = 0; j < referenceImg.width; j++){
            color sceneColor = sceneImg.get(y+i, x+j);
            color refColor = referenceImg.get(i, j);
            currentSAD += abs(red(sceneColor) - red(refColor));
          }
        }
        
        // Update best SAD
        if(currentSAD < minSAD){
          minSAD = currentSAD;
          bestrow = y;
          bestcolumn = x;
        }
      }
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