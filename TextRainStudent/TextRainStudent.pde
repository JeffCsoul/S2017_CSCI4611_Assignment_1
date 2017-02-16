/**
    CSCI 4611 Spring '17 Assignment #1: Text Rain
**/


import processing.video.*;

// Global variables for input selection and data
String[] cameras;
Capture cam;
PImage mov;
PImage inputImage;
boolean inputMethodSelected = false;
int startTime;
int frame;
boolean turn_on_filter = false;
float filter_val = 0.5;


void loadFrame() {
  int newFrame = 1 + (millis() - startTime)/100; // get new frame every 0.1 sec
  if (newFrame == frame)
    return;
  frame = newFrame;
  String movieName = "TextRainInput";
  String filePath = movieName + "/" + nf((frame % 271) + 1, 3) + ".jpg";
  mov = loadImage(filePath);
  if (mov == null) {
    startTime = millis();
    loadFrame();
  }
}


void setup() {
  size(1280, 720);
  inputImage = createImage(width, height, RGB);
}

PImage flip_photo (PImage in_image) {
  PImage return_photo;
  return_photo = createImage(in_image.width, in_image.height, RGB);
  for (int j = 0; j < in_image.height; j++) {
    for (int i = 0; i < in_image.width; i++) {
      int index = (in_image.width - i - 1) + in_image.width*j;
      int new_index = i + in_image.width*j;
      return_photo.pixels[new_index] = in_image.pixels[index];
    }
  }
  return return_photo;
}

void draw() {
  // When the program first starts, draw a menu of different options for which camera to use for input
  // The input method is selected by pressing a key 0-9 on the keyboard
  if (!inputMethodSelected) {
    cameras = Capture.list();
    int y=40;
    text("O: Offline mode, test with TextRainInput.mov movie file instead of live camera feed.", 20, y);
    y += 40;
    for (int i = 0; i < min(9,cameras.length); i++) {
      text(i+1 + ": " + cameras[i], 20, y);
      y += 40;
    }
    return;
  }


  // This part of the draw loop gets called after the input selection screen, during normal execution of the program.


  // STEP 1.  Load an image, either from the image sequence or from a live camera feed. Store the result in the inputImage variable
  if (cam != null) {
    if (cam.available())
      cam.read();
    inputImage.copy(cam, 0,0,cam.width,cam.height, 0,0,inputImage.width,inputImage.height);
  }
  else if (mov != null) {
    loadFrame();
    inputImage.copy(mov, 0,0,mov.width,mov.height, 0,0,inputImage.width,inputImage.height);
  }


  // Fill in your code to implement the rest of TextRain here..
  inputImage = flip_photo(inputImage);


  // Tip: This code draws the current input image to the screen
  if (turn_on_filter)
    inputImage.filter(THRESHOLD, filter_val);
  set(0, 0, inputImage);


}


void keyPressed() {

  if (!inputMethodSelected) {
    // If we haven't yet selected the input method, then check for 0 to 9 keypresses to select from the input menu
    if ((key >= '0') && (key <= '9')) {
      int input = key - '0';
      if (input == 0) {
        println("Offline mode selected.");
        startTime = millis();
        loadFrame();
        inputMethodSelected = true;
      }
      else if ((input >= 1) && (input <= 9)) {
        println("Camera " + input + " selected.");
        // The camera can be initialized directly using an element from the array returned by list():
        cam = new Capture(this, cameras[input-1]);
        cam.start();
        inputMethodSelected = true;
      }
    }
    return;
  }

  // This part of the keyPressed routine gets called after the input selection screen during normal execution of the program
  // Fill in your code to handle keypresses here..

  if (key == CODED) {
    if (keyCode == UP) {
      // up arrow key pressed
      if (turn_on_filter) {
        if (filter_val + 0.005 <= 1)
          filter_val += 0.005;
      }
    }
    else if (keyCode == DOWN) {
      // down arrow key pressed
      if (turn_on_filter) {
        if (filter_val - 0.005 >= 0)
          filter_val -= 0.005;
      }
    }
  }
  else if (key == ' ') {
    // space bar pressed
    turn_on_filter = !turn_on_filter;
  }

}
