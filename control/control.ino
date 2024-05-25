#include <Arduino.h>
#include <Servo.h>

// Servos
Servo oxVentValve;
Servo fuelVentValve;

// Servo Pins
const int PIN_FUEL_VENT_VLV = 3;
const int PIN_OX_VENT_VLV = 5;

// Relay Pins
const int PIN_SPARK_PLUG = 6;
const int PIN_OX_IGNT_VLV = 7;
const int PIN_OX_MAIN_VLV = 8;
const int PIN_OX_FILL_VLV = 9;
const int PIN_FUEL_IGNT_VLV = 12;
const int PIN_FUEL_MAIN_VLV = 11;
const int PIN_FUEL_PRES_VLV = 10;

// Positions of the servos at CLOSED and OPEN states
const int FUEL_VENT_VLV_CLOSED = 0;
const int FUEL_VENT_VLV_OPEN = 180;
const int OX_VENT_VLV_CLOSED = 0;
const int OX_VENT_VLV_OPEN = 180;

// Relay Pins
const int relayPins[] = {
    PIN_SPARK_PLUG,
    PIN_OX_IGNT_VLV,
    PIN_OX_MAIN_VLV,
    PIN_OX_FILL_VLV,
    PIN_FUEL_IGNT_VLV,
    PIN_FUEL_MAIN_VLV,
    PIN_FUEL_PRES_VLV
};

// Binary value representing the binary state of each component
uint8_t machineState = 0b000000000;

void setMachineState(uint8_t newState) {
    machineState = newState;
    
    for (size_t i = 0; i < 7; i++) {
        if ((newState >> i) & 1) {
            digitalWrite(relayPins[i], HIGH);
        } else {
            digitalWrite(relayPins[i], LOW);
        }
    }

    // Control the servos based on the machine state
    if ((newState >> 1) & 1) {
        fuelVentValve.write(FUEL_VENT_VLV_OPEN);
    } else {
        fuelVentValve.write(FUEL_VENT_VLV_CLOSED);
    }

    if ((newState >> 1) & 1) {
        oxVentValve.write(OX_VENT_VLV_OPEN);
    } else {
        oxVentValve.write(OX_VENT_VLV_CLOSED);
    }
}

void close() {
    setMachineState(0b111111110);
}

void open() {
    setMachineState(0b000000000);
}

void setup() {
    
    // Servo setup
    fuelVentValve.attach(PIN_FUEL_VENT_VLV);
    oxVentValve.attach(PIN_OX_VENT_VLV);

    // Setting digital pins as OUTPUT
    pinMode(PIN_SPARK_PLUG, OUTPUT);
    pinMode(PIN_OX_IGNT_VLV, OUTPUT);
    pinMode(PIN_OX_MAIN_VLV, OUTPUT);
    pinMode(PIN_OX_FILL_VLV, OUTPUT);
    pinMode(PIN_FUEL_IGNT_VLV, OUTPUT);
    pinMode(PIN_FUEL_MAIN_VLV, OUTPUT);
    pinMode(PIN_FUEL_PRES_VLV, OUTPUT);

    close();

    Serial.begin(9600);

}

void loop() {

    int presCC = analogRead(A0);
    int presOx = analogRead(A1);
    int presFuel = analogRead(A2);

    Serial.print(presCC);
    Serial.print(",");
    Serial.print(presOx);
    Serial.print(",");
    Serial.print(presFuel);
    Serial.print(",");
    Serial.println(machineState);

    if (Serial.available()) {
        String newStateStr = Serial.readStringUntil('\n');
        uint8_t newState = newStateStr.toInt();
        setMachineState(newState);
    }

}