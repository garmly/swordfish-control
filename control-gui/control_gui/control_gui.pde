import processing.serial.*;

Serial myPort;  // The serial port
int[] data = new int[4];  // Array to store the input data
boolean[] buttonStates = new boolean[9];  // Array to store button states
int[][] timeGraphData = new int[3][300];  // Buffer to store the graph data

void setup() {
  size(1200, 900);
  String portName = "COM3";
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');
  
  for (int i = 0; i < 9; i++) {
    buttonStates[i] = false;
  }
}

int[][] buttonPositions = {
  {745, 450}, // Spark plug / CDI
  {830, 500}, // Ox Ignition Valve
  {910, 550}, // Ox Main Valve
  {985, 495}, // Ox Fill Valve
  {675, 555}, // Fuel Ignition Valve
  {601, 505}, // Fuel Main Valve
  {665, 80}, // Fuel Pressure Valve
  {535, 75}, // Fuel Vent Valve
  {950, 100} // Ox Vent Valve
};

float currentReading = 1;
float scalingFactor = 1;
boolean lock = false;

PImage backgroundImage;

void draw() {
  background(0);
  stroke(255);

  backgroundImage = loadImage("background.png");
  image(backgroundImage, 0, 0);
  
  // Draw buttons
  for (int i = 0; i < 9; i++) {
    if (buttonStates[i]) {
      fill(0, 255, 0);  // Green
    } else {
      fill(255, 0, 0);  // Red
    }
    if (i == 0) {
      rect(buttonPositions[i][0], buttonPositions[i][1], 60, 60);
      fill(255);
      textAlign(CENTER, CENTER);
      text("CDI", buttonPositions[i][0] + 30, buttonPositions[i][1] + 30);
    } else {
      if (i == 7 || i == 8 || i == 3) {
      displayIsoValve(buttonPositions[i][0] + 30, buttonPositions[i][1] + 30, true);
      } else {
      displayIsoValve(buttonPositions[i][0] + 30, buttonPositions[i][1] + 30, false);
      }
    }
  }

  // Draw the SCALE button
  fill(255);
  rect(100, 700, 300, 50);
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(20);
  text("SCALE", 250, 725);
  
  // Draw a white square behind the pressure reading graph
  fill(0);
  rect(100, 400, 300, 300);

  // Draw the time graph for the first three inputs
  for (int i = 0; i < 3; i++) {
    stroke(255);
    noFill();
    beginShape();
    for (int j = 0; j < 299; j++) {
      vertex(100 + j, 450 + i * 100 + 50 - timeGraphData[i][j] / 10);
    }
    endShape();

    // Display pressure reading text with scaled data
    fill(255);
    textAlign(LEFT, CENTER);
    textSize(16);
    text("Pressure " + (i+1) + ": \n" + nf(data[i] * scalingFactor, 0, 3) + " psia", 10, 420 + i * 100 + 50);
  }

  // Draw protocol buttons.
  fill(255);
  rect(100, 325, 300, 50);
  rect(100, 250, 300, 50);
  rect(100, 175, 300, 50);

  fill(0);
  textAlign(CENTER, CENTER);
  textSize(20);
  text("Cold Flow", 250, 350);
  text("Cold Flow (NO IGNT)", 250, 275);
  text("Fire", 250, 200);

}

  void mousePressed() {
  if (lock) {
    return;
  }
    for (int i = 0; i < 9; i++) {
      if (mouseX > buttonPositions[i][0] && mouseX < buttonPositions[i][0] + 60 && mouseY > buttonPositions[i][1] && mouseY < buttonPositions[i][1] + 60) {
        buttonStates[i] = !buttonStates[i];
        updateMachineState();
      }
    }

    // Check if the "SCALE" button is pressed
    if (mouseX > 100 && mouseX < 400 && mouseY > 700 && mouseY < 750) {
      // Calculate the average of the three channel readings
      currentReading = (data[0] + data[1] + data[2]) / 3.0;

      // Calculate the scaling factor
      scalingFactor = 14.6 / currentReading;
    }

    // Check if the "Cold Flow" button is pressed
    if (mouseX > 100 && mouseX < 400 && mouseY > 325 && mouseY < 375) {
      myPort.write("1023\n");
    }

    // Check if the "Cold Flow (NO IGNT)" button is pressed
    if (mouseX > 100 && mouseX < 400 && mouseY > 250 && mouseY < 300) {
      myPort.write("1022\n");
    }

    // Check if the "Fire" button is pressed
    if (mouseX > 100 && mouseX < 400 && mouseY > 175 && mouseY < 225) {
      myPort.write("1021\n");
    }
  }

void serialEvent(Serial p) {
  String input = p.readStringUntil('\n');
  if (input != null) {
    input = trim(input);
    String[] inputs = split(input, ',');
    if (inputs.length == 4) {
      for (int i = 0; i < 3; i++) {
        data[i] = int(inputs[i]);
      }
      int machineState = int(inputs[3]);
      for (int i = 0; i < 9; i++) {
        buttonStates[i] = (machineState & (1 << i)) != 0;
      }
      updateGraphData();
    }
  }
}

void displayIsoValve(int x, int y, boolean isVertical) {
  pushMatrix();
  translate(x, y);
  if (isVertical) {
    rotate(HALF_PI);
  }
  triangle(-30, 30, 30, 30, 0, 0);
  triangle(-30, -30, 30, -30, 0, 0);
  popMatrix();
}

void updateMachineState() {
  int machineState = 0;
  for (int i = 0; i < 9; i++) {
    if (buttonStates[i]) {
      machineState |= (1 << i);
    }
  }
  myPort.write(machineState + "\n");
}

void updateGraphData() {
  for (int i = 0; i < 3; i++) {
    for (int j = 299; j > 0; j--) {
      timeGraphData[i][j] = timeGraphData[i][j - 1];
    }
    timeGraphData[i][0] = data[i];
  }
}
