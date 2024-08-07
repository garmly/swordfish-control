#include <Arduino.h>
#include <Servo.h>

// Servos
Servo fuelPresValve;
Servo fuelVentValve;

// Servo Pins
const int PIN_FUEL_VENT_VLV = 3;
const int PIN_FUEL_PRES_VLV = 5;

// Relay Pins
const int PIN_SPARK_PLUG = 6;
const int PIN_OX_IGNT_VLV = 7;
const int PIN_OX_MAIN_VLV = 8;
const int PIN_OX_FILL_VLV = 9;
const int PIN_OX_VENT_VLV = 10;
const int PIN_FUEL_MAIN_VLV = 11;
const int PIN_FUEL_IGNT_VLV = 12;

// Positions of the servos at CLOSED and OPEN states
const int FUEL_VENT_VLV_CLOSED = 0;
const int FUEL_VENT_VLV_OPEN = 180;
const int FUEL_PRES_VLV_CLOSED = 0;
const int FUEL_PRES_VLV_OPEN = 180;



// Pressure sensor values
int presCC = 0;
int presOx = 0;
int presFuel = 0;

// Relay Pins
const int relayPins[] = {
    PIN_SPARK_PLUG,
    PIN_OX_IGNT_VLV,
    PIN_OX_MAIN_VLV,
    PIN_OX_FILL_VLV,
    PIN_OX_VENT_VLV,
    PIN_FUEL_IGNT_VLV,
    PIN_FUEL_MAIN_VLV
};

/*
Order:
    1. PIN_SPARK_PLUG,
    2. PIN_OX_IGNT_VLV
    3. PIN_OX_MAIN_VLV
    4. PIN_OX_FILL_VLV
    5. PIN_OX_VENT_VLV
    6. PIN_FUEL_IGNT_VLV
    7. PIN_FUEL_MAIN_VLV
    8. PIN_FUEL_PRES_VLV
    9. PIN_FUEL_VENT_VLV
*/

// Binary value representing the binary state of each component
uint16_t machineState = 0b000000000;

static unsigned long lastCommandTime = millis();
const unsigned long COMMAND_TIMEOUT = 120000000; // 20 minutes in milliseconds

void setMachineState(uint16_t newState) {
    machineState = newState;

    if (newState == 65535) {
        open();
        return;
    }
    else if (newState == 65534) {
        cold_flow();
        return;
    }
    else if (newState == 65533) {
        cold_flow_no_ignt();
        return;
    }
    else if (newState == 65532) {
        fire();
        return;
    }

    else if (newState == 65531) {
        fuel_calibration();
        return;
    }

    else if (newState == 65530) {
        ox_calibration();
        return;
    }
    else if (newState == 65529) {
        test_connections();
        return;
    }

    else if (newState >= 512 && newState <= 65528) {
        close();
        return;
    }

    for (size_t i = 0; i < 7; i++) {
        if ((newState >> i) & 1) {
            digitalWrite(relayPins[i], HIGH);
        } else {
            digitalWrite(relayPins[i], LOW);
        }
    }

    // Control the servos based on the machine state
    if ((newState >> 8) & 1) {
        fuelVentValve.write(FUEL_VENT_VLV_OPEN);
    } else {
        fuelVentValve.write(FUEL_VENT_VLV_CLOSED);
    }

    if ((newState >> 7) & 1) {
        fuelPresValve.write(FUEL_PRES_VLV_OPEN);
    } else {
        fuelPresValve.write(FUEL_PRES_VLV_CLOSED);
    }
}

void close() {
    setMachineState(0b000000000);
}

void open() {
    setMachineState(272);
}

void fire() {
    unsigned long startTime = millis();

    while (millis() - startTime < 81) {
        setMachineState(161);
        printState();
    }

    startTime = millis();
    while (millis() - startTime < 1010) {
        setMachineState(163);
        printState();
    }

    startTime = millis();
    while (millis() - startTime < 1375) {
        setMachineState(227);
        printState();
    }

    startTime = millis();
    while (millis() - startTime < 2305) {
        setMachineState(231);
        printState();
    }

    startTime = millis();
    while (millis() - startTime < 2474) {
        setMachineState(228);
        printState();
    }

    startTime = millis();
    while (millis() - startTime < 3000) {
        setMachineState(196);
        printState();
    }


}

void cold_flow() {
    unsigned long startTime = millis();

    while (millis() - startTime < 81) {
        setMachineState(160);
        printState();
    }

    startTime = millis();
    while (millis() - startTime < 1010) {
        setMachineState(162);
        printState();
    }

    startTime = millis();
    while (millis() - startTime < 1375) {
        setMachineState(226);
        printState();
    }

    startTime = millis();
    while (millis() - startTime < 2305) {
        setMachineState(230);
        printState();
    }

    startTime = millis();
    while (millis() - startTime < 2474) {
        setMachineState(228);
        printState();
    }

    startTime = millis();
    while (millis() - startTime < 3000) {
        setMachineState(196);
        printState();
    }
}

void cold_flow_no_ignt() {
    unsigned long startTime = millis();

    while (millis() - startTime < 365) {
        setMachineState(192);
        printState();
    }

    startTime = millis();
    while (millis() - startTime < 1000) {
        setMachineState(196);
        printState();
    }
}

void fuel_calibration() {
    unsigned long startTime = millis();

    while(millis() - startTime < 1000) {
    setMachineState(192);
    printState();
    }

    startTime = millis();
    while(millis() - startTime < 1000) {
    setMachineState(0);
    printState();
    }
}

void ox_calibration() {
    unsigned long startTime = millis();

    while(millis() - startTime < 1000) {
    setMachineState(132);
    printState();
    }

    startTime = millis();
    while(millis() - startTime < 1000) {
    setMachineState(0);
    printState();
    }
}

void test_connections() {
    unsigned long startTime = millis();

    while (millis() - startTime < 1000) {
        setMachineState(2);
        printState();
    }

    startTime = millis();
    while (millis() - startTime < 1000) {
        setMachineState(4);
        printState();
    }

    startTime = millis();
    while (millis() - startTime < 1000) {
        setMachineState(8);
        printState();
    }

    startTime = millis();
    while (millis() - startTime < 1000) {
        setMachineState(16);
        printState();
    }

    startTime = millis();
    while (millis() - startTime < 1000) {
        setMachineState(32);
        printState();
    }

    startTime = millis();
    while (millis() - startTime < 1000) {
        setMachineState(64);
        printState();
    }

    startTime = millis();
    while (millis() - startTime < 1000) {
        setMachineState(128);
        printState();
    }

    startTime = millis();
    while (millis() - startTime < 1000) {
        setMachineState(256);
        printState();
    }

    startTime = millis();
    while (millis() - startTime < 1000) {
        setMachineState(1);
        printState();
    }

    startTime = millis();
    while (millis() - startTime < 1000) {
        setMachineState(0);
        printState();
    }
}


void setup() {
    
    // Servo setup
    fuelPresValve.attach(PIN_FUEL_PRES_VLV);
    fuelVentValve.attach(PIN_FUEL_VENT_VLV);

    // Setting digital pins as OUTPUT
    pinMode(PIN_SPARK_PLUG, OUTPUT);
    pinMode(PIN_OX_IGNT_VLV, OUTPUT);
    pinMode(PIN_OX_MAIN_VLV, OUTPUT);
    pinMode(PIN_OX_FILL_VLV, OUTPUT);
    pinMode(PIN_OX_VENT_VLV, OUTPUT);
    pinMode(PIN_FUEL_IGNT_VLV, OUTPUT);
    pinMode(PIN_FUEL_MAIN_VLV, OUTPUT);

    close();

    Serial.begin(9600);

}

void printState() {
  
    presCC = analogRead(A0);
    presOx = analogRead(A1);
    presFuel = analogRead(A2);

    Serial.print(presCC);
    Serial.print(",");
    Serial.print(presOx);
    Serial.print(",");
    Serial.print(presFuel);
    Serial.print(",");
    Serial.println(machineState);
}

void loop() {
    printState();

    if (Serial.available()) {
        String newStateStr = Serial.readStringUntil('\n');
        uint16_t newState = newStateStr.toInt();
        lastCommandTime = millis();
        if (newState >= 0 && newState <= 65535) {
            setMachineState(newState);
        }
    }

    // Check if the command timeout has occurred
    if (millis() - lastCommandTime >= COMMAND_TIMEOUT) {
        open();
    }

}
