# OpenIPC Wiki
[Table of Content](../README.md)

Sigmastar unbrick
---

**Locate the Sigmastar UART output and connect it to the CH341A I2C:**
- $\color{dimgray}{\texttt{GND -> GND (PIN 1-4)}}$
- $\color{deepskyblue}{\texttt{TX -> SDA I2C (PIN 5)}}$
- $\color{orange}{\texttt{RX -> SCL I2C (PIN 6)}}$

<img src="../images/sigmastar-ch341a.webp">
<img src="../images/sigmastar-uart.webp">
<img src="../images/sigmastar-example.webp">

---

**Download snander-mstar:**
- https://github.com/openipc/snander-mstar/releases

---

**Install the driver**
<img src="../images/Installing device driver.webp">

---



**Check the device flash with snander:**
- The device must be powered when connected to the programmer.
- Power cycling might help if the device can not be detected.
```
snander -i -q
```

<img src="../images/sigmastar-check.webp">

**Erase the boot partition:**
```
snander -l 0x200000 -e
```

<img src="../images/sigmastar-erase.webp">

**Write the new uboot file:**
- https://github.com/openipc/firmware/releases/tag/latest
```
snander -w u-boot-ssc338q-nand.bin
```

<img src="../images/sigmastar-write.webp">

---

**I2C devices:**
- 0x49 -> MStar ISP
- 0x59 -> MStar Debug

---

- [Alternative Raspberry method by MarioFPV](https://youtu.be/88C8UvyKQlQ)
