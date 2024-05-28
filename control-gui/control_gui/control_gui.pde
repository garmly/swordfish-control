import processing.serial.*;

Serial myPort;  // The serial port
int[] data = new int[4];  // Array to store the input data
boolean[] buttonStates = new boolean[9];  // Array to store button states
int[][] timeGraphData = new int[3][300];  // Buffer to store the graph data

void setup() {
  size(800, 600);
  String portName = "COM3";
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');
  
  for (int i = 0; i < 9; i++) {
    buttonStates[i] = false;
  }
}

void draw() {
  background(255);
  
  // Draw buttons
  for (int i = 0; i < 9; i++) {
    if (buttonStates[i]) {
      fill(0, 255, 0);  // Green
    } else {
      fill(255, 0, 0);  // Red
    }
    rect(50 + i * 80, 50, 60, 60);
  }
  
  // Draw the time graph for the first three inputs
  for (int i = 0; i < 3; i++) {
    stroke(i * 100, 0, 255 - i * 100);
    noFill();
    beginShape();
    for (int j = 0; j < 299; j++) {
      vertex(100 + j, 200 + i * 100 + 50 - timeGraphData[i][j] / 10);
    }
    endShape();
  }
}

void mousePressed() {
  for (int i = 0; i < 9; i++) {
    if (mouseX > 50 + i * 80 && mouseX < 110 + i * 80 && mouseY > 50 && mouseY < 110) {
      buttonStates[i] = !buttonStates[i];
      updateMachineState();
    }
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
