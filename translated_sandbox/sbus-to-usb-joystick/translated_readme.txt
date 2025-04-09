## USB joystick from regular radio equipment with SBUS receiver on arduino pro micro

![photo_2023-03-30_04-58-32.jpg](photo_2023-03-30_04-58-32.jpg)

Connect the SBUS signal from the receiver to rx, you need a non-inverted one. If you have a "regular" inverted one, you will have to use a transistor for inversion.

![sbus-inverter-diagram-schematics.jpg](sbus-inverter-diagram-schematics.jpg)

I use "digital" transistors dtc144eka or bcr533 and do not put a resistor in the base. As a transmitter and receiver sbus I use qczek, you can use any receiver.
Its task is to transmit channel values ​​from the equipment to the USB recorder via [arduino](https://docs.arduino.cc/hardware/micro) to 32u4 ([ali](https://aliexpress.ru/item/1005003622414316.html)), which is defined as hid-usb-joystick. At the same time, the delay increases slightly due to the additional
process of receiving and transmitting values, but you are not tied to the recorder by a wire, which is convenient.

Sketch, a joystick library modified for 10 axis channels (the remaining channels are filled with buttons), [here](https://github.com/OpenIPC/sandbox-fpv/tree/master/sbus-to-usb-joystick).