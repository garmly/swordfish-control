#include <Arduino.h>
#include <Servo.h>

// Servos
Servo gn2PresValve;
Servo gn2VentValve;

// Relay Pins
const int PIN_GN2_PRES_VLV = 5; // Servo
const int PIN_GN2_VENT_VLV = 6; // Servo
const int PIN_FUEL_IGNT_VLV = 7;
const int PIN_FUEL_MAIN_VLV = 8;
const int PIN_OX_FILL_VLV = 9;
const int PIN_OX_VENT_VLV = 10;
const int PIN_OX_IGNT_VLV = 11;
const int PIN_OX_MAIN_VLV = 13;
const int PIN_SPARK_PLUG = 12;

// Positions of the servos at CLOSED and OPEN states
const int GN2_PRES_VLV_CLOSED = 0;
const int GN2_PRES_VLV_OPEN = 180;
const int GN2_VENT_VLV_CLOSED = 0;
const int GN2_VENT_VLV_OPEN = 180;

void setup() {
    
    // Servo setup
    gn2PresValve.attach(PIN_GN2_PRES_VLV);
    gn2VentValve.attach(PIN_GN2_VENT_VLV);

    // Setting digital pins as OUTPUT
    pinMode(PIN_FUEL_IGNT_VLV, OUTPUT);
    pinMode(PIN_FUEL_MAIN_VLV, OUTPUT);
    pinMode(PIN_OX_FILL_VLV, OUTPUT);
    pinMode(PIN_OX_VENT_VLV, OUTPUT);
    pinMode(PIN_OX_IGNT_VLV, OUTPUT);
    pinMode(PIN_OX_MAIN_VLV, OUTPUT);
    pinMode(PIN_SPARK_PLUG, OUTPUT);

    Serial.begin(9600);
}

void loop() {
    // Read command from serial port
    if (Serial.available() > 0) {
        String command = Serial.readStringUntil('\n');
        int pin = command.charAt(0) - 'A' + 5;
        int state = command.charAt(1) - '0';

        // Check for invalid commands
        if (pin < 0 || pin > 13 || state < 0 || state > 1) {
            Serial.println("Invalid command");
            return;
        }

        // Servo pin control
        if (pin == PIN_GN2_PRES_VLV) {
            if (state == 1) {
                gn2PresValve.write(GN2_PRES_VLV_OPEN);
            } else if (state == 0) {
                gn2PresValve.write(GN2_PRES_VLV_CLOSED);
            }
        } else if (pin == PIN_GN2_VENT_VLV) {
            if (state == 1) {
                gn2VentValve.write(GN2_VENT_VLV_OPEN);
            } else if (state == 0) {
                gn2VentValve.write(GN2_VENT_VLV_CLOSED);
            }
        }

        // Relay pin control
        if (state == 1) {
            digitalWrite(pin, HIGH);
            printPinState(pin, state);
        } else if (state == 0) {
            digitalWrite(pin, LOW);
            printPinState(pin, state);
        }
    }
}


// Lookup table for which pin was toggled
void printPinState(int pin, int state) {
    switch (pin) {
        case PIN_GN2_PRES_VLV:
            Serial.print("GN2 Pressure Valve ");
            break;
        case PIN_GN2_VENT_VLV:
            Serial.print("GN2 Vent Valve ");
            break;
        case PIN_FUEL_IGNT_VLV:
            Serial.print("Fuel Ignition Valve ");
            break;
        case PIN_FUEL_MAIN_VLV:
            Serial.print("Fuel Main Valve ");
            break;
        case PIN_OX_FILL_VLV:
            Serial.print("Oxidizer Fill Valve ");
            break;
        case PIN_OX_VENT_VLV:
            Serial.print("Oxidizer Vent Valve ");
            break;
        case PIN_OX_IGNT_VLV:
            Serial.print("Oxidizer Ignition Valve ");
            break;
        case PIN_OX_MAIN_VLV:
            Serial.print("Oxidizer Main Valve ");
            break;
        case PIN_SPARK_PLUG:
            Serial.print("Spark Plug ");
            break;
        default:
            Serial.print("Unknown Relay ");
            break;
    }
    
    if (state == 1) {
        Serial.println("ON");
    } else if (state == 0) {
        Serial.println("OFF");
    } else {
        Serial.println("Invalid state");
    }
}