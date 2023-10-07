# OpenIPC Wiki
[Table of Content](../README.md)

Sigmastar unbrick
---

**Locate the Sigmastar UART output and connect it to the CH341A I2C:**
- $\color{black}{\texttt{GND -> GND (PIN 1-4)}}$
- $\color{deepskyblue}{\texttt{TX -> SDA I2C (PIN 5)}}$
- $\color{orange}{\texttt{RX -> SCL I2C (PIN 6)}}$

<img src="../images/sigmastar-ch341a.webp">
<img src="../images/sigmastar-uart.webp">
<img src="../images/sigmastar-example.webp">

---

**Download snander-mstar:**
- https://github.com/viktorxda/snander-mstar/releases

---

**Check the device flash with snander:**
```
snander -i
```

<img src="../images/sigmastar-check.webp">

**Erase, write and verify new uboot:**
```
snander -l 0x200000 -e
snander -w u-boot-ssc338q-nand.bin -v
```

<img src="../images/sigmastar-write.webp">
