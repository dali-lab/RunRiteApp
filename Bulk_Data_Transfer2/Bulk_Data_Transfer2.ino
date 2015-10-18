
/*
This sketch demonstrates how to do error free bulk data
transfer over Bluetooth Low Energy 4.
The data rate should be approximately:
  - 32 kbit/sec at 1.5ft (4000 bytes per second)
  - 24 kbit/sec at 40ft (3000 bytes per second)
  
This sketch attempts to send a 2x5 matrix as 10 individual integers using
RFduinoBLE.sendInt
*/

#include <RFduinoBLE.h>

// sends 10 int packets, two rows of 5
int rows = 2; 
int cols = 5;

// flag used to start sending
//int flag = false;
int flag = true;

// variables used in packet generation
int row;
int col;

int start;

int ForceMatrix[2][5] = {1,2,3,4,5,6,7,8,9,0};

void setup() {
  Serial.begin(9600);
  Serial.println("Waiting for connection...");
  RFduinoBLE.begin();
  RFduinoBLE.advertisementData = "Mark 1"; // shouldnt be more than 10 characters long
  RFduinoBLE.deviceName = "RunRite";
}

void RFduinoBLE_onConnect() {
  row = 0;
  col = 0;
  start = 0;
  flag = true;
  Serial.println("Sending");
  // first send is not possible until the iPhone completes service/characteristic discovery
}

void loop() {
  if (flag)
  {
    // generate the next packet
    for(row = 0; row < 2; row++)
    {
      int buf;
      for (col = 0; col < 5;col++)
      {
        buf = ForceMatrix[row][col];
        
        // send is queued (the ble stack delays send to the start of the next tx window)
        while (! RFduinoBLE.sendInt(buf))
          ;  // all tx buffers in use (can't send - try again later)
    
        if (! start)
          start = millis();
      }
       
      if (row >= rows)
      {
        int end = millis();
        float secs = (end - start) / 1000.0;
        int bps = ((row*col * 20) * 8) / secs; 
        Serial.println("Finished");
        Serial.println(start);
        Serial.println(end);
        Serial.println(secs);
        Serial.println(bps / 1000.0);
        flag = false;
      }
    }
  }
}
