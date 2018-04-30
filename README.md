# Video-Object-Tracker
This is a group project for CSC 645 - Computer Speech, Music and Images through Missouri State University.

This project will allow a user to track a selected object in a video. The user will first select a portion of a still video frame, the tracker will then attempt to find the selected object in each frame of the video using various recognition algorithms.


## Setup

1. Must be using [Processing 3](https://processing.org/download/) with the following libraries installed:
  - Video
  - OpenCV for Processing

2. Download/Clone this repo to your local machine

3. Open `object_tracker.pde` in Processing

4. Reference a video file by setting `fnameMovie` to the title of the movie file, at the top of `object_tracker.pde`.
  - _Note: you can add your own videos into the `data` folder for use_

5. Run the project in Processing


## Usage

The project will begin playing the given video in a loop. The user can pause the video to select a segment of the current frame to use as a reference image for an object to track, as well as select an algorithm they would like to use for tracking.

### Basic Commands
```
KEY   FUNCTION

p     pause/play the video
r     reset the video, reference image and algorithm choice
i     display the current reference image (video must be paused)

0     set algorithm to "None"**
1     set algorithm to "SURF"**
2     set algorithm to "Exhaustive Search"**
3     set algorithm to "Logarithmic Search"**
```
_** In order to set to a particular algorithm, the video must be paused and the user must have already selected a reference image_

### Selecting a Reference Image
To set a reference image, first pause the video. Now, you can use the mouse to click and drag to highlight a segment of the current frame that contains the object you would like to track. Making a new selection will override any previous reference image created.
