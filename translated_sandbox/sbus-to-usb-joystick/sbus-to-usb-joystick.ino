#include "sbus.h"
#include <JoystickMHX.h>

//#define SERIAL_DEBUG

//Joystic settings
Joystick_ Joystick(JOYSTICK_DEFAULT_REPORT_ID,JOYSTICK_TYPE_JOYSTICK,
  32, 2,                  // Button Count, Hat Switch Count
  true, true, true,     // X and Y, Z Axis
  true, true, true,   // Rx, Ry,  Rz
  true, true, true, true,  // slider, dial, rudder and throttle
  false, false, false);  // accelerator, brake, and steering

bfs::SbusRx sbus_rx(&Serial1);
bfs::SbusData data;

void setup() {
  #ifdef SERIAL_DEBUG
  Serial.begin(115200);
  while (!Serial) {}
  Serial.println("Started");
  #else
  Joystick.begin();
  //range
  Joystick.setXAxisRange(0, 2000);
  Joystick.setYAxisRange(0, 2000);
  Joystick.setZAxisRange(0, 2000);
  Joystick.setRxAxisRange(0, 2000);
  Joystick.setRyAxisRange(0, 2000);
  Joystick.setRzAxisRange(0, 2000);
  Joystick.setSliderRange(0, 2000);
  Joystick.setDialRange(0, 2000);
  Joystick.setRudderRange(0, 2000);
  Joystick.setThrottleRange(0, 2000);
  //default
  //Joystick.setRudder(1500);
  //Joystick.setAccelerator(0);
  //Joystick.setBrake(1500);
  //Joystick.setSteering(1500);
  #endif
  sbus_rx.Begin();
}

void loop() {
  if (sbus_rx.Read()) {
   data = sbus_rx.data();

   #ifdef SERIAL_DEBUG
    for (int8_t i = 0; i < data.NUM_CH; i++) {
      Serial.print(data.ch[i]);
      Serial.print("\t");
    }
   Serial.println();
   #else
   Joystick.setXAxis    (data.ch[0]);
   Joystick.setYAxis    (data.ch[1]);
   Joystick.setZAxis    (data.ch[2]);
   Joystick.setRxAxis   (data.ch[3]);
   Joystick.setRyAxis   (data.ch[4]);
   Joystick.setRzAxis   (data.ch[5]);
   Joystick.setSlider   (data.ch[6]);
   Joystick.setRudder   (data.ch[7]);
   Joystick.setThrottle (data.ch[8]);
   Joystick.setDial     (data.ch[9]);
   if(data.ch[10] > 1490) Joystick.setButton(0, 255); else Joystick.setButton(0, 0);
   if(data.ch[11] > 1490) Joystick.setButton(1, 255); else Joystick.setButton(1, 0);
   if(data.ch[12] > 1490) Joystick.setButton(2, 255); else Joystick.setButton(2, 0);
   if(data.ch[13] > 1490) Joystick.setButton(3, 255); else Joystick.setButton(3, 0);
   if(data.ch[14] > 1490) Joystick.setButton(4, 255); else Joystick.setButton(4, 0);
   Joystick.sendState();
   #endif
  } //sbus_rx.Read
}
