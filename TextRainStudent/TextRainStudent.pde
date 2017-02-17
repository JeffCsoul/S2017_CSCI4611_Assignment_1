/**
    CSCI 4611 Spring '17 Assignment #1: Text Rain
**/


import processing.video.*;

// Global variables for input selection and data
String[] cameras;
Capture cam;
PImage mov;
PImage inputImage;
PImage output_img;
boolean inputMethodSelected = false;
int startTime;
int frame;
boolean turn_on_filter = false;
float filter_val = 0.5;
int ht, wd;
ArrayList rains;

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

class TextRain{
  int x;
  int y;
  char letter;
  int upspeed;
  int downspeed;
  int tsize;
  color c;

  TextRain() {
    y = 0;
    x = (int) random(0, wd);
    if (random(0, 2) < 1) {
      letter = char(int(random(0,26)) + 'a');
    }
    else {
      letter = char(int(random(0,26)) + 'A');
    }
    upspeed = max(4, 0);
    downspeed = max(5, int(random(5, 10)));
    tsize = int(random(10, 20));
    c = color(int(random(0, 255)), int(random(0, 255)), int(random(0, 255)));
  }

  void downLetter(PImage bw_img) {
    int index = x + bw_img.width * y;

    int mid_u_test_point = (x + tsize / 2) + bw_img.width * (y + tsize - 2);
    int left_check_point = (x) + bw_img.width * (y + tsize / 5 * 4);
    int right_check_point = (x + tsize) + bw_img.width * (y + tsize / 5 * 4);
    int mid_d_test_point = (x + tsize / 2) + bw_img.width * (y + tsize);

    boolean mid_up = (bw_img.pixels[mid_u_test_point] != color(0,0,0));
    boolean left_p = (bw_img.pixels[left_check_point] != color(0,0,0));
    boolean right_p = (bw_img.pixels[right_check_point] != color(0,0,0));
    boolean bottom_mid = (bw_img.pixels[mid_d_test_point] != color(0,0,0));

    if (bottom_mid)
      y += downspeed;
    if (left_p)
      x -= upspeed;
    if (right_p)
      x += upspeed;
    if (!mid_up)
      y -= upspeed;
    x = min(x, bw_img.width - tsize - 1);
    x = max(0, x);
    y = max(0, y);
  }

  void drawLetter() {
    textSize(tsize);
    fill(c);
    text(letter, x, y);
  }

  boolean is_valid(PImage bw_img) {
    if (x < 0) return false;
    if (x + tsize >= bw_img.width) return false;
    if (y < 0) return false;
    if (y + tsize >= bw_img.height) return false;
    return true;
  }

}


void setup() {
  size(1280, 720);
  inputImage = createImage(width, height, RGB);
  rains = new ArrayList();
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

PImage copy_image (PImage inputImage) {
  PImage return_img = createImage(inputImage.width, inputImage.height, RGB);
  for (int j = 0; j < inputImage.height; j++)
    for (int i = 0; i < inputImage.width; i++) {
      int index = i + inputImage.width * j;
      return_img.pixels[index] = inputImage.pixels[index];
    }
  return return_img;
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
  wd = inputImage.width;
  ht = inputImage.height;

  // Fill in your code to implement the rest of TextRain here..
  inputImage = flip_photo(inputImage);
  PImage bw_img;
  bw_img = copy_image(inputImage);
  bw_img.filter(THRESHOLD, filter_val);
  // Tip: This code draws the current input image to the screen
  if (turn_on_filter) {
    output_img = copy_image(bw_img);
  }
  else {
    output_img = copy_image(inputImage);
  }
  set(0, 0, output_img);
  for (int i = rains.size() - 1; i >= 0; i--) {
    TextRain atext = (TextRain) rains.get(i);
    if (!atext.is_valid(bw_img)) rains.remove(i);
  }
  if (rains.size() < 8192) {
    if (random(0, 2) < 0.5) {
      int num_of_new = (int) random(0,5);
      for (int i = 0; i < num_of_new; i++) {
          rains.add(new TextRain());
      }
    }
  }
  for (int i = rains.size() - 1; i >= 0; i--) {
    TextRain atext = (TextRain) rains.get(i);
    atext.downLetter(bw_img);
    atext.drawLetter();
  }
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
