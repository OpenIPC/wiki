# OpenIPC Wiki
[Table of Content](../README.md)

Board specific GPIO settings list
---------------------------------

### Anjoy boards

| Processor   | IRCUT1 | IRCUT2 | LIGHT | I/O | TESTED BOARDS    |
|-------------|--------|--------|-------|-----|------------------|
| SSC335      | 78     | 79     | 61    | 52  | MS-J10, YM200J10 |
| SSC337      | 78     | 79     | 61    | 52  | MC-F40, YM-J10D  |
| SSC337DE    | 78     | 79     | 61    |     | MC500L8          |

### CamHi/Xin boards

| Processor   | IRCUT1 | IRCUT2 | IRSTATUS | IRCTL | USB_ENA | UART2_RTS/RS485_DE | UART2_RXD/RS485_RO | UART2_TXD/RS485_DI | AUDIO_ENA | RESET | PWM | SD_VCC |
|-------------|--------|--------|----------|-------|---------|--------------------|--------------------|--------------------|-----------|-------|-----|--------|
| Gk7205v200  | 14     | 15     | 8        | 4     | 9i      | 54                 | 12                 | 13                 |
| Gk7205v300  | 10     | 11     | 8        | 72    | 7i      |                    |                    |                    | 52        | 42    |
|             |        |        |          |       |         |
| Hi3516Cv100 |        |        |          |       |         |
| Hi3516Cv200 |        |        |          |       |         |
| Hi3516Cv300 |        |        |          |       |         |
| Hi3516Ev100 |        |        |          |       |         |
| Hi3516Ev200 |        |        |          |       | 9i      |
| Hi3516Ev300 | 10     | 11     |          |       | 7i      | 63                 |                    |                    |           | 42    |
| Hi3518Ev200 | 1      | 2      | 48       |       |         |
| Hi3518Ev300 |        |        |          |       |         |
|             |        |        |          |       |         |
| T31         | 58     | 57     |          | 49    | 61i     | 53                 | 55                 | 56                 |           | 11    | 50  | 62     |

> _i - inverted value_

```
Tested on Gk7205v200:
  mux 12->UART2_RXD/RS485_RO: devmem 0x112c0070 32 2 
  mux 13->UART2_TXD/RS485_DI: devmem 0x112c0074 32 2
```

```
Tested on GK7205V200 for /dev/ttyАМА1
  devmem 0x112c0070 32 2
  devmem 0x112c0074 32 2
```


### GSA boards

| Processor   | IRCUT1 | IRCUT2 | IRSTATUS | IRCTL | USB_ENA |
|-------------|--------|--------|----------|-------|---------|
| T31L        | 58     | 57     |          |       |         |


### Herospeed/Longse/Cantonk boards

| Processor   | IRCUT1 | IRCUT2 | IRSTATUS | IRCTL | ALM_IN | ALM_OUT | USB_ENA |
|-------------|--------|--------|----------|-------|--------|---------|---------|
| Gk7205v200  | 12     | 13     |          | 4     | 15     | 14      |         |
|             |        |        |          |       |        |         |         |
| Hi3516Cv100 | 18     | 19     |
| Hi3516Cv200 |
| Hi3516Cv300 | 1      |  2     | 24       |
| Hi3518Ev200 | 65     | 64     | 63       |
| Hi3516Ev200 | 12     | 13     |          | 4     |
| Hi3516Av300 | 5      | 6      |

### Jabsco boards

| Processor   | IRCUT1 | IRCUT2 | IRSTATUS |
|-------------|--------|--------|----------|
| Hi3516Ev200 | 52     | 53     | 9        |

### Jovision boards

| Processor   | IRCUT1 | IRCUT2 | LIGHT |  TESTED BOARDS                     |
|-------------|--------|--------|-------|------------------------------------|
| Hi3516Ev200 | 53     | 52     | 4     |                                    |
| Hi3516Cv100 | 42     | 43     | 6     | IPG5020A-H-V1.0, 5013A-CF/5020A-FF |

### JUAN boards (Sannce)

| Processor   | IRCUT1 | IRCUT2 | IRSTATUS      | TESTED BOARDS | DEVICE ID |
|-------------|--------|--------|---------------|---------------|-----------|
| Hi3518Ev200 | 65     | 64     | 62 (inverted) | 18EV200_V205P | N18EV2W   |

### JVT boards

| Processor   | IRCUT1 | IRCUT2 | LIGHT |
|-------------|--------|--------|-------|
| Hi3516Cv100 |
| Hi3516Cv200 | 64     | 65     | 62    |
| Hi3516Cv300 |
| Hi3516Ev200 |
| Hi3518Ev200 | 64     | 65     | 47    |

### iSNATCH (HeySmart) mini "cube" camera

| Processor   | IRCUT1 | IRCUT2 | IRSTATUS | IRLED    | RESET  |
|-------------|--------|--------|----------|----------|---------
| T10         | 25     | 26     | -        | 19       |  60i   |

### Netcam NVT boards

| Processor   | IRCUT1 | IRCUT2 | IRSTATUS | IRLED    |
|-------------|--------|--------|----------|----------|
| T10         | 25     | 26     | 81       | 80       |

### Rostelecom IPC2122SR3-RU04

| Processor   | IRCUT1 | IRCUT2 |
|-------------|--------|--------|
| Hi3516Cv300 | 58     | 59     |

### Rotek Switcam E200/T200 JXF23 sensor

| Processor   | IRCUT1 | IRCUT2 | IRSTATUS |
|-------------|--------|--------|----------|
| Hi3518Ev200 | 63     | 64     | 65       |

### Tiandy boards

| Processor   | IRCUT1 | IRCUT2 | IRSTATUS | IRCTL | RESET |
|-------------|--------|--------|----------|-------|-------|
| SSC335      | 78     | 79     | ---      | 37    |       |

### Uniview boards

| Processor   | IRCUT1 | IRCUT2 | RESET | DEVICE ID                |
|-------------|--------|--------|-------|--------------------------|
| Hi3516Ev300 | 63     | 67     | 64    | Rostelecom IPC8232SWC-WE |

### Wansview

| Processor   | IRCUT1 | IRCUT2 | IR LEDs | RESET | ETH_GREEN | ETH_ORANGE| DEVICE ID              |
|-------------|--------|--------|---------|-------|-----------|-----------|------------------------|
| T21         | 80     | 79     |  49     | 50    |    73     |     72    |   Wansview W5/W6       |

### XM boards

| Processor       | IRCUT1 | IRCUT2 | IRSTATUS | IRCTL | ALM_IN | ALM_OUT | ETH_ACT | ETH_STA | RESET | USB_ENA | AUDIO_POW | RS485_CTL |  NOTES |
|-----------------|--------|--------|----------|-------|--------|---------|---------|---------|-------|---------|-----------|-----------|--------|
| GK7205V200      | 8      | 9      | 15       | 16    | 4, 53  | 55      | 14      | 12      | 0     |         |
| GK7205V201      | 8      | 9      | 15       | 16    | 4, 53  | 55      | 14      | 12      | 0     |         |
| GK7205V300      | 10     | 11     | 66       | 52    | 4      |         | 30      | 31      | 0     |         | 60        | 24        |        |
| GK7605V100      | 10     | 11     | 66       | 52    | 4      |         | 30      | 31      | 0     |         | 60        | 24        |        |
|                 |        |        |          |       |        |         |         |         |       |         |
| Hi3516Cv100     | 38     | 39     | 24       |       | 49     | 26      |         |         |       |         |
| Hi3516Dv100[^1] | 14     | 15     |  3       |       |        |         |         |         |       |         |
| Hi3516Dv100[^2] | 121    | 120    |  3       |       |        |         |         |         |       |         |
| Hi3516Cv200     |        |        |          |       |        |         |         |         |       |         |
| Hi3516Cv300     | 53     | 54     | 64       | 66    | 55     | 1       |         |         | 2     | 63      |
| Hi3516Ev100     | 53     | 54     | 64       |       |        |         |         |         |       |         |
| Hi3516Ev200     | 8      | 9      | 15       | 16    | 4, 53  | 55      | 14      | 12      | 0     |         |
| Hi3516Ev300     | 10     | 11     | 66       | 52    | 4, 67  | 65      | 30      | 31      | 0     |         |
| Hi3518Ev200     | 33     | 34     |          |       | 61     | 35      |         |         |       |         |
| Hi3518Ev300[^3] | 8      |        |  55      |       | 13     |         |         |         | 15    |         | 3       |

[^1]: HI3516D_N81820, 00014914 firmware
[^2]: Hi3516Dv100 for IPC_HI3516D_83H20 00014911
[^3]: Hi3518EV300 for 50H20L

### Zenotech/Videopark

| Processor   | IRCUT1 | IRCUT2 | IRLED | DEVICE ID                |
|-------------|--------|--------|-------|--------------------------|
| GK7205V200  | 58     | 59     | 8     | ZN-CM-GK200S1L-P         |
|             |        |        |       |                          |
| Hi3516Ev300 | 14     | 12     |       | ZN-CM-HSC500S1L-PZ       |
| Hi3516Ev300 | 40     | 41     | 65    | unknown                  |


### Zosi

| Processor   | IRCUT1 | IRCUT2 | IRSTATUS     | DEVICE ID     |
|-------------|--------|--------|--------------|---------------|
| Hi3518Ev200 | 61     | 60     | 1 (inverted) | ZG2622MW      |
