/*
SURFTracker
This class creates an instance of a SURF tracker. This tracker is given an object to track,
it can then be passed a scene that it will search for the image and return any results.

Detection method following this example: http://dummyscodes.blogspot.com/2015/12/using-siftsurf-for-object-recognition.html
PImage <--> Mat conversion methods from: https://gist.github.com/Spaxe/3543f0005e9f8f3c4dc5
*/
class SURFTracker {
  
  // Object Items
  PImage objectImg;
  Mat object;
  MatOfKeyPoint objectKeypoints = new MatOfKeyPoint();
  MatOfKeyPoint objectDescriptors = new MatOfKeyPoint();
  PImage objectFeaturesImg;

  // Extractors, Matchers
  FeatureDetector featureDetector = FeatureDetector.create(FeatureDetector.SURF);
  DescriptorExtractor descriptorExtractor = DescriptorExtractor.create(DescriptorExtractor.SURF);
  DescriptorMatcher descriptorMatcher = DescriptorMatcher.create(DescriptorMatcher.FLANNBASED);
  
  // Other Attributes
  int numObjectKeypoints;
  int numObjectDescriptors;
  int matchConfidence = 7; // number of matches needed to classify an object "match" in a scene


  SURFTracker(PImage obj) {
    // Set object that will be tracked
    objectImg = obj;
    object = toMat(obj);
    
    // Extract features from object
    // Detect keypoints
    featureDetector.detect(object, objectKeypoints);
    numObjectKeypoints = objectKeypoints.toArray().length;
    // Detect Descriptors
    descriptorExtractor.compute(object, objectKeypoints, objectDescriptors);
    numObjectDescriptors = objectDescriptors.toArray().length;
    
    // Create an image showing object features
    // Convert objectImg from RGBA -> RGB
    Mat objectRGB = new Mat(object.rows(), object.cols(), CvType.CV_8UC3);
    Imgproc.cvtColor(object, objectRGB, Imgproc.COLOR_RGBA2RGB);
    // Draw Keypoints on image
    Mat outputRGB = new Mat(object.rows(), object.cols(), CvType.CV_8UC3);
    Scalar keypointColor = new Scalar(255, 255, 255);
    Features2d.drawKeypoints(objectRGB, objectKeypoints, outputRGB, keypointColor, 0);
    // Convert output to RGBA and save
    Mat outputRGBA = new Mat(object.rows(), object.cols(), CvType.CV_8UC4);
    Imgproc.cvtColor(outputRGB, outputRGBA, Imgproc.COLOR_RGB2RGBA);
    objectFeaturesImg = toPImage(outputRGBA);
  }
  
  // Takes in a scene and tries to find object
  PImage findObject(PImage sceneImg) {
    // Create a matrix from the scene
    Mat scene = toMat(sceneImg);
    PImage sceneOutput;
    
    // Extract scene features
    // Detect keypoints
    MatOfKeyPoint sceneKeypoints = new MatOfKeyPoint();
    featureDetector.detect(scene, sceneKeypoints);    
    // Detect Descriptors
    MatOfKeyPoint sceneDescriptors = new MatOfKeyPoint();
    descriptorExtractor.compute(scene, sceneKeypoints, sceneDescriptors);
  
    // Find matching features in scene with object
    List<MatOfDMatch> matches = new LinkedList<MatOfDMatch>();
    descriptorMatcher.knnMatch(objectDescriptors, sceneDescriptors, matches, 2);
  
    // Determine good matches
    LinkedList<DMatch> goodMatchesList = new LinkedList<DMatch>();
    float nndrRatio = 0.7f;
    for (int i = 0; i < matches.size(); i++) {
      MatOfDMatch matofDMatch = matches.get(i);
      DMatch[] dmatcharray = matofDMatch.toArray();
      DMatch m1 = dmatcharray[0];
      DMatch m2 = dmatcharray[1];

      if (m1.distance <= m2.distance * nndrRatio) {
        goodMatchesList.addLast(m1);
      }
    }
    
    // Determine if there are enough matches to classify object
    if (goodMatchesList.size() >= matchConfidence) {
      // Match Found!
      
      // Create feature match images
      // Find corresponding matches b/t object and scene
      List<KeyPoint> objKeypointlist = objectKeypoints.toList();
      List<KeyPoint> scnKeypointlist = sceneKeypoints.toList();

      LinkedList<Point> objectPoints = new LinkedList();
      LinkedList<Point> scenePoints = new LinkedList();

      for (int i = 0; i < goodMatchesList.size(); i++) {
        objectPoints.addLast(objKeypointlist.get(goodMatchesList.get(i).queryIdx).pt);
        scenePoints.addLast(scnKeypointlist.get(goodMatchesList.get(i).trainIdx).pt);
      }

      MatOfPoint2f objMatOfPoint2f = new MatOfPoint2f();
      objMatOfPoint2f.fromList(objectPoints);
      MatOfPoint2f scnMatOfPoint2f = new MatOfPoint2f();
      scnMatOfPoint2f.fromList(scenePoints);

      Mat homography = Calib3d.findHomography(objMatOfPoint2f, scnMatOfPoint2f, Calib3d.RANSAC, 3);

      // Draw borders around the object match
      Mat obj_corners = new Mat(4, 1, CvType.CV_32FC2);
      Mat scene_corners = new Mat(4, 1, CvType.CV_32FC2);

      obj_corners.put(0, 0, new double[]{0, 0});
      obj_corners.put(1, 0, new double[]{object.cols(), 0});
      obj_corners.put(2, 0, new double[]{object.cols(), object.rows()});
      obj_corners.put(3, 0, new double[]{0, object.rows()});

      Core.perspectiveTransform(obj_corners, scene_corners, homography);

      Mat img = toMat(sceneImg);
      Scalar edgeColor = new Scalar(255, 255, 255, 255);

      Core.line(img, new Point(scene_corners.get(0, 0)), new Point(scene_corners.get(1, 0)), edgeColor, 4);
      Core.line(img, new Point(scene_corners.get(1, 0)), new Point(scene_corners.get(2, 0)), edgeColor, 4);
      Core.line(img, new Point(scene_corners.get(2, 0)), new Point(scene_corners.get(3, 0)), edgeColor, 4);
      Core.line(img, new Point(scene_corners.get(3, 0)), new Point(scene_corners.get(0, 0)), edgeColor, 4);

      // Draw matching features b/t object and scene
      Mat matchoutputRGB = new Mat(scene.rows() * 2, scene.cols() * 2, CvType.CV_8UC3);
      MatOfDMatch goodMatches = new MatOfDMatch();
      goodMatches.fromList(goodMatchesList);
      Scalar matchColor = new Scalar(0, 255, 0);
      Scalar nonMatchColor = new Scalar(0, 0, 255);
      Features2d.drawMatches(object, objectKeypoints, scene, sceneKeypoints, goodMatches, matchoutputRGB, matchColor, nonMatchColor, new MatOfByte(), 2);
      // Convert matchoutput photo to RGBA
      Mat matchoutputRGBA = new Mat(matchoutputRGB.rows(), matchoutputRGB.cols(), CvType.CV_8UC4);
      Imgproc.cvtColor(matchoutputRGB, matchoutputRGBA, Imgproc.COLOR_RGB2RGBA);

      //sceneOutput = toPImage(matchoutputRGBA);
      sceneOutput = toPImage(img);
    } else {
      // Object not found :(
      
      sceneOutput = sceneImg;
    }
    return sceneOutput;
  }
  
  // Convert PImage (ARGB) to Mat (CvType = CV_8UC4)
  Mat toMat(PImage image) {
    int w = image.width;
    int h = image.height;
    
    Mat mat = new Mat(h, w, CvType.CV_8UC4);
    byte[] data8 = new byte[w*h*4];
    int[] data32 = new int[w*h];
    arrayCopy(image.pixels, data32);
    
    ByteBuffer bBuf = ByteBuffer.allocate(w*h*4);
    IntBuffer iBuf = bBuf.asIntBuffer();
    iBuf.put(data32);
    bBuf.get(data8);
    mat.put(0, 0, data8);
    
    return mat;
  }
  
  // Convert Mat (CvType=CV_8UC4) to PImage (ARGB)
  PImage toPImage(Mat mat) {
    int w = mat.width();
    int h = mat.height();
    
    PImage image = createImage(w, h, ARGB);
    byte[] data8 = new byte[w*h*4];
    int[] data32 = new int[w*h];
    mat.get(0, 0, data8);
    ByteBuffer.wrap(data8).asIntBuffer().get(data32);
    arrayCopy(data32, image.pixels);
    
    return image;
  }
}