import java.io.File;
import java.nio.*;
import java.util.LinkedList;
import java.util.List;

import gab.opencv.*;
import org.opencv.core.*;
import org.opencv.features2d.*;
import org.opencv.calib3d.Calib3d;
import org.opencv.highgui.Highgui;
import org.opencv.imgproc.Imgproc;

// Images created
PImage inputObject;
PImage inputScene;

PImage objectFeatures;
PImage featureMatches;
PImage sceneOutput;

PImage currImg;

void setup() {
  size(1080, 720);
  // Use native library for SURF features
  System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
  
  // Load in images and convert to matrices
  println("Started....");
  println("Loading images...");
  PImage object = loadImage("bookobject.jpg");
  PImage scene = loadImage("bookscene.jpg");
  inputObject = object.copy();
  inputScene = scene.copy();
  Mat objectImage = toMat(object);
  Mat sceneImage = toMat(scene);
  
  // Detect Keypoints in object
  MatOfKeyPoint objectKeypointsMat = new MatOfKeyPoint();
  FeatureDetector featureDetector = FeatureDetector.create(FeatureDetector.SURF);
  println("Detecting key points...");
  featureDetector.detect(objectImage, objectKeypointsMat);
  //KeyPoint[] keypoints = objectKeypointsMat.toArray();
  //println("Number of keypoints:", keypoints.length);
  
  // Detect Descriptors of object
  MatOfKeyPoint objectDescriptors = new MatOfKeyPoint();
  DescriptorExtractor descriptorExtractor = DescriptorExtractor.create(DescriptorExtractor.SURF);
  println("Computing descriptors...");
  descriptorExtractor.compute(objectImage, objectKeypointsMat, objectDescriptors);

  // Create the matrix for output image
  Mat objectRGB = new Mat(objectImage.rows(), objectImage.cols(), CvType.CV_8UC3);
  Mat outputRGB = new Mat(objectImage.rows(), objectImage.cols(), CvType.CV_8UC4);
  Mat outputRGBA = new Mat(objectImage.rows(), objectImage.cols(), CvType.CV_8UC4);
  Scalar newKeypointColor = new Scalar(255, 0, 0);
  
  println("Drawing key points on object image...");
  Imgproc.cvtColor(objectImage, objectRGB, Imgproc.COLOR_RGBA2RGB);
  Features2d.drawKeypoints(objectRGB, objectKeypointsMat, outputRGB, newKeypointColor, 0);
  Imgproc.cvtColor(outputRGB, outputRGBA, Imgproc.COLOR_RGB2RGBA);
  
  
  
  
  
  // Match object image with the scene image
  MatOfKeyPoint sceneKeyPoints = new MatOfKeyPoint();
  MatOfKeyPoint sceneDescriptors = new MatOfKeyPoint();
  println("Detecting key points in background image...");
  featureDetector.detect(sceneImage, sceneKeyPoints);
  println("Computing descriptors in background image...");
  descriptorExtractor.compute(sceneImage, sceneKeyPoints, sceneDescriptors);

  List<MatOfDMatch> matches = new LinkedList<MatOfDMatch>();
  DescriptorMatcher descriptorMatcher = DescriptorMatcher.create(DescriptorMatcher.FLANNBASED);
  println("Matching object and scene images...");
  descriptorMatcher.knnMatch(objectDescriptors, sceneDescriptors, matches, 2);

  println("Calculating good match list...");
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

  if (goodMatchesList.size() >= 7) {
      println("Object Found!!!");

      List<KeyPoint> objKeypointlist = objectKeypointsMat.toList();
      List<KeyPoint> scnKeypointlist = sceneKeyPoints.toList();

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

      Mat obj_corners = new Mat(4, 1, CvType.CV_32FC2);
      Mat scene_corners = new Mat(4, 1, CvType.CV_32FC2);

      obj_corners.put(0, 0, new double[]{0, 0});
      obj_corners.put(1, 0, new double[]{objectImage.cols(), 0});
      obj_corners.put(2, 0, new double[]{objectImage.cols(), objectImage.rows()});
      obj_corners.put(3, 0, new double[]{0, objectImage.rows()});

      println("Transforming object corners to scene corners...");
      Core.perspectiveTransform(obj_corners, scene_corners, homography);

      Mat img = toMat(scene.copy());

      Core.line(img, new Point(scene_corners.get(0, 0)), new Point(scene_corners.get(1, 0)), new Scalar(0, 255, 0), 4);
      Core.line(img, new Point(scene_corners.get(1, 0)), new Point(scene_corners.get(2, 0)), new Scalar(0, 255, 0), 4);
      Core.line(img, new Point(scene_corners.get(2, 0)), new Point(scene_corners.get(3, 0)), new Scalar(0, 255, 0), 4);
      Core.line(img, new Point(scene_corners.get(3, 0)), new Point(scene_corners.get(0, 0)), new Scalar(0, 255, 0), 4);

      println("Drawing matches image...");
      MatOfDMatch goodMatches = new MatOfDMatch();
      goodMatches.fromList(goodMatchesList);
      
      Mat matchoutput = new Mat(sceneImage.rows() * 2, sceneImage.cols() * 2, CvType.CV_8UC3);
      Scalar matchestColor = new Scalar(0, 255, 0);
      
      Features2d.drawMatches(objectImage, objectKeypointsMat, sceneImage, sceneKeyPoints, goodMatches, matchoutput, matchestColor, newKeypointColor, new MatOfByte(), 2);
      Mat matchoutputRGBA = new Mat(matchoutput.rows(), matchoutput.cols(), CvType.CV_8UC4);
      Imgproc.cvtColor(matchoutput, matchoutputRGBA, Imgproc.COLOR_RGB2RGBA);


      println("Converting outputRGBA....");
      objectFeatures = toPImage(outputRGBA);
      println("Converting matchoutput....");
      featureMatches = toPImage(matchoutputRGBA);
      println("Converting img....");
      sceneOutput = toPImage(img);
      
  } else {
      println("Object Not Found");
  }
  currImg = inputObject;
  println("Ended....");
}


void draw() {
  // Draw current image
  surface.setSize(currImg.width, currImg.height);
  image(currImg, 0, 0);
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

// Handle keypresses
void keyReleased() {
  if (key == '1') currImg = inputObject;
  else if (key == '2') currImg = inputScene;
  else if (key == '3') currImg = objectFeatures;
  else if (key == '4') currImg = featureMatches;
  else if (key == '5') currImg = sceneOutput;
}