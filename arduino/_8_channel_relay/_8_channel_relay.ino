#define RELAY_ON 0
#define RELAY_OFF 1

int incomingByte = 0;   // for incoming serial data
String readString;

void setup() {
  Serial.begin(9600);
  for (int i=0; i < 8; i++) {
    int relayNumber = i + 2; //Account for the TX/RX pins
    Serial.println(String("Setting up ") + relayNumber);
    //Set relay to off by default
    Serial.println(String("Writing ") + relayNumber + String(" as OFF with value ") + RELAY_OFF);
    digitalWrite(relayNumber, RELAY_OFF);
    Serial.println(String("Writing ") + relayNumber + String(" as OUTPUT with value ") + OUTPUT);
    pinMode(relayNumber, OUTPUT);
  }
}

void loop() {
  while (Serial.available()) {
    delay(3);  
    char c = Serial.read();
    readString += c; 
  }
  readString.trim();
  if (readString.length() > 0) {
    Serial.println(String("Got item: ") + readString);
    int commaIndex = readString.indexOf(',');
    Serial.println(String("Comma index: ") + commaIndex);
    if (commaIndex >= 0) {
      int desiredRelay = readString.substring(0, commaIndex).toInt();
      String offOrOn = readString.substring(commaIndex + 1);
      if (desiredRelay < 2 || desiredRelay > 9) {
        Serial.println(String("Desired relay of ") + desiredRelay + String(" was invalid. Expected `2 <= DESIRED_RELAY <= 9`"));
      } else {
        if (offOrOn == "off") {
          Serial.println(String("Turning ") + desiredRelay + String(" off"));
          digitalWrite(desiredRelay, RELAY_OFF);
        } else if (offOrOn == "on") {
          Serial.println(String("Turning ") + desiredRelay + String(" on"));
          digitalWrite(desiredRelay, RELAY_ON);
        } else {
          Serial.println(String("Desired offOrOn of ") + offOrOn + String(" was invalid. Expected `off` or `on`"));
        }
      }
    } else {
      Serial.println(String("Command given of `") + readString + String("` was invalid"));
    }
    readString="";
  }
}
