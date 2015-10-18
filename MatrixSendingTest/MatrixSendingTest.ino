#include <RFduinoBLE.h>
#include <string.h>


int ForceMatrix[2][5] = {1,2,3,4,5,6,7,8,9,0};
int flag = false;

void setup(void) {
  Serial.begin(9600);   // We'll send debugging information via the Serial monitor
  RFduinoBLE.advertisementData = "Mark 2"; // shouldnt be more than 10 characters long
  RFduinoBLE.deviceName = "RunRite";
  RFduinoBLE.begin();
  flag = true;
  for(int h = 0; h < 2; h++)
  {
    for (int g = 0; g < 5; g++)
        {
          Serial.print(ForceMatrix[h][g]);
        }
    Serial.println();
  } 
}


void loop() {

if (flag)
{

char buf[15];
char buf1[3], buf2[3], buf3[3], buf4[3], buf5[3];
String str,str1,str2,str3,str4,str5;
String cat;

    int f = 1;
//    for (int h = 0; h < 250; h++)
//    { 
        str1 = String(ForceMatrix[0][0]);
        str.toCharArray(buf1,3);
        str2 = String(ForceMatrix[0][1]);
        str.toCharArray(buf2,3);
        str3 = String(ForceMatrix[0][2]);
        str.toCharArray(buf3,3);
        str4 = String(ForceMatrix[0][3]);
        str.toCharArray(buf4,3);
        str5 = String(ForceMatrix[0][4]);
        str.toCharArray(buf5,3);
        Serial.print("buf1 = ");
        Serial.println(buf1);
        Serial.print("buf2 = ");
        Serial.println(buf2);
        Serial.print("ForceMatrix = ");
        Serial.println(ForceMatrix[1][4]);
        cat = str1+str2+str3+str4+str5;
        Serial.print("first concat = ");
        Serial.println(cat);
        cat.toCharArray(buf,15);
        Serial.print("buf = ");
        Serial.println(buf);
        

      flag = false;
}

}
