#include <Adafruit_PN532_Curie.h>

#include <CurieIMU.h>
#include <CurieBLE.h>
#include <MadgwickAHRS.h>

#define M_PI        3.141592653589793
#define RST_PIN     9
#define SS_PIN      10
#define PN532_IRQ   2
#define PN532_RESET 3
#define DISPLAY_PIN 6
#define FSR_PIN     0

int fsrReading; // Variable to store force value
int fsrThreshold = 300;
bool isTouchingSomethingS = true; // Delete once force sensor is used

long millisPerWritingDisplaySearching = 1000, millisPreviousDisplaySearching = 0;
int ledState = LOW;

static volatile float accelometerValues[3];
static volatile float gyroValues[3];
static volatile bool valueUpdated = false;
int SAMPLE_RATE = 25; //25, 50, 100, 200, 400, 800, 1600 Hz
float temperature = 0;
float startAngle = 0;
Madgwick filter;

Adafruit_PN532 nfc(PN532_IRQ, PN532_RESET);
unsigned long millisPerReadingNFC = 50, millisPreviousNFC = 0;
unsigned long millisBeforeUpdateFirstInteraction = 3000, millisPreviousUpdateInteraction = 0;
String heldObjectId;
bool isTagDetected = false;
bool isSecondTimeNotHolding = true;
bool isInteractionActiveOld = false;
bool isFirstLoopSinceTagDetection = false;

bool isSwitchOn = false;

static constexpr size_t AngleCharacteristicSize = 5;
static constexpr size_t ObjectCharacteristicSize = 14;

BLEPeripheral blePeripheral;
BLEService objectMotionService("e11f4373-fcd3-4e07-b132-c25933f051b0");
BLECharacteristic angleCharacteristic("b7fe7c89-0b13-4d28-a744-9895a12b1c11", BLERead | BLENotify, AngleCharacteristicSize);
BLECharacteristic objectStartCharacteristic("9eb72828-1710-43c8-a4f8-277770ab697d", BLERead | BLENotify, ObjectCharacteristicSize);
BLECharacteristic objectEndCharacteristic("9053c01e-e9b9-4970-93db-6c605b2f6498", BLERead | BLENotify, ObjectCharacteristicSize);

void setup() {
  Serial.begin(9600);
  // while the serial stream is not open, do nothing:
  //while (!Serial);

  setupNFC();
  setupMotionSensor();
  setupBluetooth();
  setupDisplay();
}

bool isTouchingSomething() {
  
  // Delete 'return true' and uncommend below once force sensor works
  return true;
  
  fsrReading = analogRead(FSR_PIN);
  return fsrReading > fsrThreshold;
}

void loop() {
  isTouchingSomethingS = true; // Delete once using force sensor
  
  // ##### When bluetooth is connected #######
  BLECentral central = blePeripheral.central();
  if (central) {
    
    setDisplaySearching();
    
    while (central.connected()) {
      isTouchingSomethingS = true; // Delete once using force sensor
      
      setDisplayBluetoothConnected();
      
      while (isTouchingSomethingS) {
        
        scanForTags();
        
        if (isTagDetected) {
          
          sendStartObjectId();
          setDisplayHoldingObject();
          startAngle = gyroValues[2];
          
          while (isTouchingSomethingS) {
            
            updateMotionValues();
            
            // Only send if there is new motion data
            if (valueUpdated) { 
              sendAngleValue();
              valueUpdated = false;
            }
          }
          
          sendEndObjectId();
        }
      }
    }
  }
  
  // ##### When no bluetooth is connected, for debugging #######
  if (isTouchingSomethingS) {
    scanForTags();
    
    if (isTagDetected) {
      
      setDisplayHoldingObject();
      startAngle = gyroValues[2];
      
      while (isTouchingSomethingS) {
        updateMotionValues();
        valueUpdated = false;
      }
      
      sendEndObjectId();
    }
  }
}

void sendAngleValue() {
  float angle = angleDifference(gyroValues[2], startAngle);
  String angleString = String(angle);
  char angleArray[AngleCharacteristicSize];
  
  angleString.toCharArray(angleArray, AngleCharacteristicSize);

  noInterrupts();
  angleCharacteristic.setValue(reinterpret_cast<unsigned char *>(angleArray), AngleCharacteristicSize);
  interrupts();
}

void sendStartObjectId() {
  char objectId[ObjectCharacteristicSize];

  heldObjectId.toCharArray(objectId, ObjectCharacteristicSize);

  noInterrupts();
  objectStartCharacteristic.setValue(reinterpret_cast<unsigned char *>(objectId), ObjectCharacteristicSize);
  interrupts();
}

void sendEndObjectId() {
  char objectId[ObjectCharacteristicSize];

  heldObjectId.toCharArray(objectId, ObjectCharacteristicSize);

  objectEndCharacteristic.setValue(reinterpret_cast<unsigned char *>(objectId), ObjectCharacteristicSize);
}

void updateMotionValues() {
  if (valueUpdated) return;
  if (!CurieIMU.dataReady(ACCEL | GYRO)) return;
  int values[6];
  float convertedValues[6];

  noInterrupts();
  CurieIMU.readMotionSensor(values[0], values[1], values[2], values[3], values[4], values[5]);
  interrupts();

  // convert from raw data to gravity and degrees/second units
  for (int i = 0; i < 3; ++i) convertedValues[i] = convertRawAcceleration(values[i]);
  for (int i = 3; i < 6; ++i) convertedValues[i] = convertRawGyro(values[i]);

  // update the filter, which computes orientation
  filter.updateIMU(convertedValues[3], convertedValues[4], convertedValues[5], convertedValues[0], convertedValues[1], convertedValues[2]);

  // save gyro values
  gyroValues[0] = filter.getYaw();
  gyroValues[1] = filter.getPitch();
  gyroValues[2] = filter.getRoll();

  // save accel values
  for (int i = 0; i < 3; ++i) accelometerValues[i] = convertedValues[i];
  Serial.println("Acceleromater data read");

  valueUpdated = true;
}

void scanForTags() {
  unsigned long millisNow = millis();
  if (millisNow - millisPreviousNFC <= millisPerReadingNFC) {
    return;
  }
  millisPreviousNFC = millisPreviousNFC + millisPerReadingNFC;

  byte success;
  byte uid[] = { 0, 0, 0, 0, 0, 0, 0 };  // Buffer to store the returned UID
  byte uidLength;                        // Length of the UID (4 or 7 bytes depending on ISO14443A card type)

  // Wait for an NTAG203 card.  When one is found 'uid' will be populated with
  // the UID, and uidLength will indicate the size of the UUID (normally 7)
  success = nfc.readPassiveTargetID(PN532_MIFARE_ISO14443A, uid, &uidLength);

  if (success) {
    String idString = "";
    for (int i = 0; i < uidLength; i++) {
      idString.concat(String(uid[i] & 0xff, HEX));
    }
    heldObjectId = idString;

  } 
  isTagDetected = success;
}

void setupNFC() {
  nfc.begin();

  uint32_t versiondata = nfc.getFirmwareVersion();
  if (! versiondata) {
    Serial.print("Didn't find PN53x board");
    while (1); // halt
  }
  // Got ok data, print it out!
  Serial.print("Found chip PN5"); Serial.println((versiondata >> 24) & 0xFF, HEX);
  Serial.print("Firmware ver. "); Serial.print((versiondata >> 16) & 0xFF, DEC);
  Serial.print('.'); Serial.println((versiondata >> 8) & 0xFF, DEC);

  // configure board to read RFID tags
  nfc.SAMConfig();
  nfc.setPassiveActivationRetries(0);

  // initialize variables to pace updates to correct rate
  millisPerReadingNFC = 1000 / 2;
  millisPreviousNFC = millis();

  Serial.println("Waiting for an ISO14443A Card ...");
}

void setupBluetooth() {
  blePeripheral.setLocalName("Manypulo-0815");
  blePeripheral.setDeviceName("Manypulo-0815");
  blePeripheral.setAdvertisedServiceUuid(objectMotionService.uuid());  // add the service UUID
  blePeripheral.addAttribute(objectMotionService);
  blePeripheral.addAttribute(angleCharacteristic);
  blePeripheral.addAttribute(objectStartCharacteristic);
  blePeripheral.addAttribute(objectEndCharacteristic);

  const uint8_t initialValue[AngleCharacteristicSize] = { 0 };

  angleCharacteristic.setValue(initialValue, AngleCharacteristicSize);
  objectStartCharacteristic.setValue(initialValue, ObjectCharacteristicSize);
  objectEndCharacteristic.setValue(initialValue, ObjectCharacteristicSize);

  blePeripheral.begin();

  Serial.println("Bluetooth device active, waiting for connections...");
}

void setupMotionSensor() {
  // Initialize IMU
  CurieIMU.begin();
  
  CurieIMU.attachInterrupt(stopInteraction);

  CurieIMU.setDetectionThreshold(CURIE_IMU_SHOCK, 1500); // 1.5g = 1500 mg
  CurieIMU.setDetectionDuration(CURIE_IMU_SHOCK, 50);   // 50ms

  // Enable Double-Tap detection
  CurieIMU.interrupts(CURIE_IMU_SHOCK);

  CurieIMU.setAccelerometerRange(2);  // Max: 2G
  CurieIMU.setGyroRange(250);     // Max: 250 [deg/s]

  CurieIMU.setAccelerometerRate(SAMPLE_RATE);
  CurieIMU.setGyroRate(SAMPLE_RATE);

  filter.begin(SAMPLE_RATE);
}

// For curie interrupt
void stopInteraction() {
  isTouchingSomethingS = false;
}

void setupDisplay() {
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW);
}

void setDisplaySearching() {
  unsigned long millisNow = millis();

  if (millisNow - millisPreviousDisplaySearching >= millisPerWritingDisplaySearching) {
    millisPreviousDisplaySearching = millisNow;

    if (ledState == LOW) {
      ledState = HIGH;
    } else {
      ledState = LOW;
    }

    digitalWrite(LED_BUILTIN, ledState);
  }
}

void setDisplayBluetoothConnected() {
  digitalWrite(LED_BUILTIN, HIGH);
}

void setDisplayHoldingObject() {
  digitalWrite(LED_BUILTIN, LOW);
}

size_t my_itoa( char *s, unsigned int n ) {
  const unsigned base = 10;
  unsigned digit = n % base;
  size_t i = 0;

  if ( n /= base ) i += my_itoa( s, n );

  s[i++] = digit + '0';

  return i;
}


float convertRawAcceleration(int aRaw) {
  // since we are using 2G range
  // -2g maps to a raw value of -32768
  // +2g maps to a raw value of 32767

  float a = (aRaw * 2.0) / 32768.0;
  return a;
}

float convertRawGyro(int gRaw) {
  // since we are using 250 degrees/seconds range
  // -250 maps to a raw value of -32768
  // +250 maps to a raw value of 32767

  float g = (gRaw * 250.0) / 32768.0;
  return g;
}

float angleDifference(float angleA, float angleB) {
  float difference = angleA - angleB;
  if (difference > 90) {
    difference -= 180;
  } else if (difference < -90) {
    difference += 180;
  }
  return difference;
}