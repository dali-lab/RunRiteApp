
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
int flag = false;
//int flag = true;

// variables used in packet generation
int row;
int col;

int start;


int ForceMatrix[2][5] = {12,23,34,45,56,67,78,89,90,101};

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
//    for(row = 0; row < 2; row++)
//    {
      char buf[20];
      char separate = ':';
      char buf1[3], buf2[3], buf3[3], buf4[3], buf5[3];
      String str,str1,str2,str3,str4,str5;
      String cat;
//      for (col = 0; col < 5;col++)
//      {
        str1 = String(ForceMatrix[0][0]);
        str1.toCharArray(buf1,3);
        str2 = String(ForceMatrix[0][1]);
        str2.toCharArray(buf2,3);
        str3 = String(ForceMatrix[0][2]);
        str3.toCharArray(buf3,3);
        str4 = String(ForceMatrix[0][3]);
        str4.toCharArray(buf4,3);
        str5 = String(ForceMatrix[0][4]);
        str5.toCharArray(buf5,3);
        cat = str1+separate+str2+separate+str3+separate+str4+separate+str5;
        //cat = str1+str2+str3+str4+str5;
        cat.toCharArray(buf,15);
        Serial.print("first concat = ");
        Serial.println(cat);
        Serial.print("buf = ");
        Serial.println(buf);
        
        // send is queued (the ble stack delays send to the start of the next tx window)
        while (! RFduinoBLE.send(buf, 20))
        //while (! RFduinoBLE.send(buf1, 20))
          ;  // all tx buffers in use (can't send - try again later)
    
        if (! start)
          start = millis();
      
       
//      if (row >= rows)
//      {
//        int end = millis();
//        float secs = (end - start) / 1000.0;
//        int bps = ((row*col * 20) * 8) / secs; 
//        Serial.println("Finished");
//        Serial.println(start);
//        Serial.println(end);
//        Serial.println(secs);
//        Serial.println(bps / 1000.0);
//        
//      }
        flag = true;
        delay(1000);
    
  }
}
