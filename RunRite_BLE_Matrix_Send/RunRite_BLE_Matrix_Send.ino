/* FSR testing sketch. 
 
Connect one end of FSR to power, the other end to Analog 0.
Then connect one end of a 10K resistor from Analog 0 to ground 
 
For more information see www.ladyada.net/learn/sensors/fsr.html */

/*
Sketch uses 16,108 bytes (12%) of program storage space. Maximum is 131,072 bytes.
Global variables use 6,840 bytes of dynamic memory
*/

/*
RFduino runs on 3.3V, 16MHz
 */

#include <RFduinoBLE.h>


int fsrPin2 = 2;     // the FSR and 10K pulldown are connected to a2
int fsrReading2;     // the analog reading from the FSR resistor divider
int fsrVoltage2;     // the analog reading converted to voltage
unsigned long fsrResistance2;  // The voltage converted to resistance, can be very big so make "long"
unsigned long fsrConductance2; 
int fsrForce2;       // Finally, the resistance converted to force

int fsrPin3 = 3;     // the FSR and 10K pulldown are connected to a3
int fsrReading3;     // the analog reading from the FSR resistor divider
int fsrVoltage3;     // the analog reading converted to voltage
unsigned long fsrResistance3;  // The voltage converted to resistance, can be very big so make "long"
unsigned long fsrConductance3; 
int fsrForce3;       // Finally, the resistance converted to force

int fsrPin4 = 4;     // the FSR and 10K pulldown are connected to a4
int fsrReading4;     // the analog reading from the FSR resistor divider
int fsrVoltage4;     // the analog reading converted to voltage
unsigned long fsrResistance4;  // The voltage converted to resistance, can be very big so make "long"
unsigned long fsrConductance4; 
int fsrForce4;       // Finally, the resistance converted to force

int fsrPin5 = 5;     // the FSR and 10K pulldown are connected to a5
int fsrReading5;     // the analog reading from the FSR resistor divider
int fsrVoltage5;     // the analog reading converted to voltage
unsigned long fsrResistance5;  // The voltage converted to resistance, can be very big so make "long"
unsigned long fsrConductance5; 
int fsrForce5;       // Finally, the resistance converted to force

int fsrPin6 = 6;     // the FSR and 10K pulldown are connected to a6
int fsrReading6;     // the analog reading from the FSR resistor divider
int fsrVoltage6;     // the analog reading converted to voltage
unsigned long fsrResistance6;  // The voltage converted to resistance, can be very big so make "long"
unsigned long fsrConductance6; 
int fsrForce6;       // Finally, the resistance converted to force

int ForceMatrix[250][5] = {0}; //matrix. This fills up in about 30 seconds with wait = 115
int count; //count for matrix

//BLE variables
int packets = 250; //250 packets for 250 rows of ForceMatrix
boolean sending = false;
int start; //timing variable
int flag = false;

void setup(void) {
  Serial.begin(9600);   // We'll send debugging information via the Serial monitor
  Serial.println("Waiting for connection...");
  RFduinoBLE.advertisementData = "Mark 2"; // shouldnt be more than 10 characters long
  RFduinoBLE.deviceName = "RunRite";
  RFduinoBLE.begin();
  count = 0; //initializes the matrix count
}

void RFduinoBLE_onConnect() {
  flag = true;
  Serial.println("Sending");
  // first send is not possible until the iPhone completes service/characteristic discovery
}
 
void loop(void) {
  if (sending == false)
  {
    fsrReading2 = analogRead(fsrPin2);  
    
    fsrReading3 = analogRead(fsrPin3);  
  
    fsrReading4 = analogRead(fsrPin4);  
  
    fsrReading5 = analogRead(fsrPin5);  
    
    fsrReading6 = analogRead(fsrPin6);  
   
    // analog voltage reading ranges from about 0 to 1023 which maps to 0V to 5V (= 5000mV)
     
    fsrVoltage2 = map(fsrReading2, 0, 1023, 0, 5000);
    
    fsrVoltage3 = map(fsrReading3, 0, 1023, 0, 5000);
  
    fsrVoltage4 = map(fsrReading4, 0, 1023, 0, 5000);
  
    fsrVoltage5 = map(fsrReading5, 0, 1023, 0, 5000);
    
    fsrVoltage6 = map(fsrReading6, 0, 1023, 0, 5000);
   
   
    
    
    if (fsrVoltage2 == 0) {
      //Serial.print(0);  
      //Serial.print(" ");
    } else {
      // The voltage = Vcc * R / (R + FSR) where R = 10K and Vcc = 5V
      // so FSR = ((Vcc - V) * R) / V        yay math!
      fsrResistance2 = 5000 - fsrVoltage2;     // fsrVoltage is in millivolts so 5V = 5000mV
      fsrResistance2 *= 10000;                // 10K resistor
      fsrResistance2 /= fsrVoltage2;
   
      fsrConductance2 = 1000000;           // we measure in micromhos so 
      fsrConductance2 /= fsrResistance2;
   
      // Use the two FSR guide graphs to approximate the force
      if (fsrConductance2 <= 1000) {
        fsrForce2 = fsrConductance2 / 80;
        //Serial.print(fsrForce2); 
        //Serial.print(" ");                
      } else {
        fsrForce2 = fsrConductance2 - 1000;
        fsrForce2 /= 30;
        //Serial.print(fsrForce2);    
        //Serial.print(" ");                   
      }
    }
    
    if (fsrVoltage3 == 0) {
      //Serial.print(0);  
      //Serial.print(" ");
    } else {
      // The voltage = Vcc * R / (R + FSR) where R = 10K and Vcc = 5V
      // so FSR = ((Vcc - V) * R) / V        yay math!
      fsrResistance3 = 5000 - fsrVoltage3;     // fsrVoltage is in millivolts so 5V = 5000mV
      fsrResistance3 *= 10000;                // 10K resistor
      fsrResistance3 /= fsrVoltage3;
   
      fsrConductance3 = 1000000;           // we measure in micromhos so 
      fsrConductance3 /= fsrResistance3;
   
      // Use the two FSR guide graphs to approximate the force
      if (fsrConductance3 <= 1000) {
        fsrForce3 = fsrConductance3 / 80;
        //Serial.print(fsrForce3); 
        //Serial.print(" ");                
      } else {
        fsrForce3 = fsrConductance3 - 1000;
        fsrForce3 /= 30;
        //Serial.print(fsrForce3);   
        //Serial.print(" ");                    
      }
    }
  
  
    if (fsrVoltage4 == 0) {
      //Serial.print(0);  
    } else {
      // The voltage = Vcc * R / (R + FSR) where R = 10K and Vcc = 5V
      // so FSR = ((Vcc - V) * R) / V        yay math!
      fsrResistance4 = 5000 - fsrVoltage4;     // fsrVoltage is in millivolts so 5V = 5000mV
      fsrResistance4 *= 10000;                // 10K resistor
      fsrResistance4 /= fsrVoltage4;
   
      fsrConductance4 = 1000000;           // we measure in micromhos so 
      fsrConductance4 /= fsrResistance4;
   
      // Use the two FSR guide graphs to approximate the force
      if (fsrConductance4 <= 1000) {
        fsrForce4 = fsrConductance4 / 80;
        //Serial.print(fsrForce4); 
        //Serial.print(" ");   
      } else {
        fsrForce4 = fsrConductance4 - 1000;
        fsrForce4 /= 30;
        //Serial.print(fsrForce4); 
        //Serial.print(" ");    
      }
    }
  
    if (fsrVoltage5 == 0) {
      //Serial.print(0);  
      //Serial.print(" ");
    } else {
      // The voltage = Vcc * R / (R + FSR) where R = 10K and Vcc = 5V
      // so FSR = ((Vcc - V) * R) / V        yay math!
      fsrResistance5 = 5000 - fsrVoltage5;     // fsrVoltage is in millivolts so 5V = 5000mV
      fsrResistance5 *= 10000;                // 10K resistor
      fsrResistance5 /= fsrVoltage5;
   
      fsrConductance5 = 1000000;           // we measure in micromhos so 
      fsrConductance5 /= fsrResistance5;
   
      // Use the two FSR guide graphs to approximate the force
      if (fsrConductance5 <= 1000) {
        fsrForce5 = fsrConductance5 / 80;
        //Serial.print(fsrForce5); 
        //Serial.print(" ");    
      } else {
        fsrForce5 = fsrConductance5 - 1000;
        fsrForce5 /= 30;
        //Serial.print(fsrForce5); 
        //Serial.print(" ");           
      }
    }
    
    
    if (fsrVoltage6 == 0) {
      //Serial.print(0);  
    } else {
      // The voltage = Vcc * R / (R + FSR) where R = 10K and Vcc = 5V
      // so FSR = ((Vcc - V) * R) / V        yay math!
      fsrResistance6 = 5000 - fsrVoltage6;     // fsrVoltage is in millivolts so 5V = 5000mV
      fsrResistance6 *= 10000;                // 10K resistor
      fsrResistance6 /= fsrVoltage6;
   
      fsrConductance6 = 1000000;           // we measure in micromhos so 
      fsrConductance6 /= fsrResistance6;
   
      // Use the two FSR guide graphs to approximate the force
      if (fsrConductance6 <= 1000) {
        fsrForce6 = fsrConductance6 / 80;
        //Serial.print(fsrForce6); 
                      
      } else {
        fsrForce6 = fsrConductance6 - 1000;
        fsrForce6 /= 30;
        //Serial.print(fsrForce6);                      
      }
    }
    ForceMatrix[count][0] = {fsrForce2};
    ForceMatrix[count][1] = {fsrForce3};
    ForceMatrix[count][2] = {fsrForce4};
    ForceMatrix[count][3] = {fsrForce5};
    ForceMatrix[count][4] = {fsrForce6};
    //Serial.println("Testing Force Matrix");
    //Serial.print(ForceMatrix[count][0]);
    
    /*for (int i = 0; i < 5; i = i + 1) {
    Serial.print(ForceMatrix[count][i]);
    Serial.print(" ");
    }
    Serial.println();
    Serial.println(count);
    */
    Serial.print("Count = ");
    Serial.println(count);
    if (count == 250){
      for (int i=0; i<count; i++){
            for (int j=0; j<5; j++){
              Serial.print(ForceMatrix[i][j]);
              Serial.print(" ");
            }
            Serial.println();
      }
    }
    if (count < 250) {
      count++;
    }else{
      count = 0;
      sending = true;
    }
    delay(15); //faster so Hanyu doesn't have to wait
    //delay(115); // 115 is about 8 Hz
  }

  if (sending == true)
  {
    char buf[20];
    char separate = ':';
    char buf1[3], buf2[3], buf3[3], buf4[3], buf5[3];
    String str,str1,str2,str3,str4,str5;
    String cat;
    int f = 0;
        str1 = String(ForceMatrix[f][0]);
        str1.toCharArray(buf1,3);
        str2 = String(ForceMatrix[f][1]);
        str2.toCharArray(buf2,3);
        str3 = String(ForceMatrix[f][2]);
        str3.toCharArray(buf3,3);
        str4 = String(ForceMatrix[f][3]);
        str4.toCharArray(buf4,3);
        str5 = String(ForceMatrix[f][4]);
        str5.toCharArray(buf5,3);
        cat = str1+separate+str2+separate+str3+separate+str4+separate+str5;
        cat.toCharArray(buf,15);
        Serial.print("first concat = ");
        Serial.println(cat);
        Serial.print("buf = ");
        Serial.println(buf);
      

    // send is queued (the ble stack delays send to the start of the next tx window)
    while (! RFduinoBLE.send(buf,20))
      ;  // all tx buffers in use (can't send - try again later)

    if (! start)
      start = millis();
    
    f++;
    if (f >= packets)
    {
      int ended = millis();
      float secs = (ended - start) / 1000.0;
      int bps = ((packets * 20) * 8) / secs; 
      Serial.println("Finished");
      Serial.println(secs);
      Serial.println(bps / 1000.0);
      f = 0;
      sending = false;
    } 
  }
}


