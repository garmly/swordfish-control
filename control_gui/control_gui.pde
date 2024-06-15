import processing.serial.*;
import java.io.*;
import processing.serial.Serial;
import java.io.*;

Serial myPort;  // The serial port
int[] data = new int[4];  // Array to store the input data
int machineState = 0;  // Variable to store the machine state
boolean[] buttonStates = new boolean[9];  // Array to store button states
int[][] timeGraphData = new int[3][300];  // Buffer to store the graph data
long timestamp = System.currentTimeMillis(); // UNIX timestamp for the data file
String filename;  // Filename for the data file
String sketchPath;  // Path to the sketch folder
String inputState = "";
boolean isInputActive = false;

void setup() {
  size(1200, 900);
  String portName = "COM3";
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');
  sketchPath = sketchPath("");
  filename = sketchPath + "/out/pread_" + timestamp + ".bin";
  
  for (int i = 0; i < 9; i++) {
    buttonStates[i] = false;
  }
}

int[][] buttonPositions = {
  {745, 450}, // Spark plug / CDI
  {830, 500}, // Ox Ignition Valve
  {910, 550}, // Ox Main Valve
  {985, 495}, // Ox Fill Valve
  {950, 100}, // Ox Vent Valve
  {675, 555}, // Fuel Ignition Valve
  {601, 505}, // Fuel Main Valve
  {665, 80},  // Fuel Pressure Valve
  {535, 75},  // Fuel Vent Valve
};

float currentReading = 1;
float scalingFactor = 1;
boolean lock = true;

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
      if (i == 3 || i == 8 || i == 4) {
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
    for (int j = 299; j > 0; j--) {
      vertex(400 - j, 450 + i * 100 + 50 - timeGraphData[i][j] / 10);
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

  // At the bottom left of the screen, have a console that displays the current state of the machine and allows input
  rect(100, 800, 300, 50);
  fill(255);
  textAlign(LEFT, CENTER);
  textSize(20);
  if (isInputActive) {
    text("Input State: " + inputState, 110, 825);
  }
  else {
    text("Machine State: " + machineState, 110, 825);
  }

  // Add button to lock input at the top right
  PImage lockImage;
  if (lock) {
    lockImage = loadImage("locked.png");
  } else {
    lockImage = loadImage("unlocked.png");
  }
  image(lockImage, width - 60, 10, 50, 50);
  image(lockImage, width - 60, 10, 50, 50);

}

void keyPressed() {
  if (isInputActive && !lock) {
    if (key >= '0' && key <= '9') {
      inputState += key;
    } else if (key == BACKSPACE) {
      inputState = inputState.substring(0, max(0, inputState.length() - 1));
    } else if (key == ENTER) {
      machineState = Integer.parseInt(inputState);
      inputState = inputState + "\n";
      myPort.write(machineState + "\n");
      inputState = "";
      isInputActive = false;
    }
  }
}

void mousePressed() {
  if (mouseX > 100 && mouseX < 400 && mouseY > 800 && mouseY < 850) {
    isInputActive = true;
  }
  else {
    isInputActive = false;
  }
  if (mouseX > width - 60 && mouseX < width - 10 && mouseY > 10 && mouseY < 60) {
    lock = !lock;
  }
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
      myPort.write("65534\n");
    }

    // Check if the "Cold Flow (NO IGNT)" button is pressed
    if (mouseX > 100 && mouseX < 400 && mouseY > 250 && mouseY < 300) {
      myPort.write("65533\n");
    }

    // Check if the "Fire" button is pressed
    if (mouseX > 100 && mouseX < 400 && mouseY > 175 && mouseY < 225) {
      myPort.write("65532\n");
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
      machineState = int(inputs[3]);
      for (int i = 0; i < 9; i++) {
        buttonStates[i] = (machineState & (1 << i)) != 0;
      }
      updateGraphData();
      writeData();
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

void writeData() {
  // Check if the out folder exists and create it if it doesn't
  File folder = new File(sketchPath + "/out");
  if (!folder.exists()) {
    folder.mkdir();
  }

  try {
    // Create a FileOutputStream to append data to the file
    FileOutputStream fos = new FileOutputStream(filename, true);

    // Convert the data array to bytes
    byte[] bytes = new byte[data.length * 4];
    for (int i = 0; i < data.length - 1; i++) {
      int value = data[i];
      bytes[i * 4] = (byte) (value >> 24);
      bytes[i * 4 + 1] = (byte) (value >> 16);
      bytes[i * 4 + 2] = (byte) (value >> 8);
      bytes[i * 4 + 3] = (byte) value;
    }

    // Write the timestamp to the file
    long timestampBytes = System.currentTimeMillis();
    byte[] timestampBytesArray = new byte[8];
    for (int i = 0; i < 8; i++) {
      timestampBytesArray[i] = (byte) (timestampBytes >> (56 - i * 8));
    }
    fos.write(timestampBytesArray);

    // Write the data to the file
    fos.write(bytes);

    // Close the FileOutputStream
    fos.close();
  } catch (IOException e) {
    e.printStackTrace();
  }

}



