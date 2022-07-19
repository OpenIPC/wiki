# OpenIPC Wiki
[Table of Content](../index.md)

GPIO Settings
-------------

### Anjoy boards

| Processor   | IRCUT1 | IRCUT2 | LIGHT | TESTED BOARDS    |
|-------------|--------|--------|-------|------------------|
| SSC335      | 78     | 79     | 61    | MS-J10, YM200J10 |
| SSC337      | 78     | 79     | 61    | MC-F40, YM-J10D  |
| SSC337DE    | 78     | 79     | 61    | MC500L8          |

### CamHi/Xin boards

| Processor   | IRCUT1 | IRCUT2 | IRSTATUS | IRCTL | USB_ENA | RS485_DE | UART2_RXD/RS485_RO | UART2_TXD/RS485_DI |
|-------------|--------|--------|----------|-------|---------|----------|--------------------|--------------------|
| Gk7205v200  | 14     | 15     | 8        | 4     | 9i      | 54       | 12                 | 13                 |
| Gk7205v300  | 10     | 11     |          |       | 7i      |
|             |        |        |          |       |         |
| Hi3516Cv100 |        |        |          |       |         |
| Hi3516Cv200 |        |        |          |       |         |
| Hi3516Cv300 |        |        |          |       |         |
| Hi3516Ev100 |        |        |          |       |         |
| Hi3516Ev200 |        |        |          |       | 9i      |
| Hi3516Ev300 | 10     | 11     |          |       | 7i      | 63       |
| Hi3518Ev200 | 1      | 2      | 48       |       |         |
| Hi3518Ev300 |        |        |          |       |         |
|             |        |        |          |       |         |
| T31         | 57     | 58     |          |       |         |

_i - inverted value_

```
Tested on Gk7205v200:
  mux 12->UART2_RXD/RS485_RO: devmem 0x112c0070 32 2 
  mux 13->UART2_TXD/RS485_DI: devmem 0x112c0074 32 2
```


### Herospeed/Longse/Cantonk boards

| Processor   | IRCUT1 | IRCUT2 | IRSTATUS | IRCTL | ALM_IN | ALM_OUT | USB_ENA |
|-------------|--------|--------|----------|-------|--------|---------|---------|
| Gk7205v200  | 12     | 13     |          | 4     | 15     | 14      |         |
|             |        |        |          |       |        |         |         |
| Hi3516Cv100 | 18     | 19     |
| Hi3516Cv200 |
| Hi3516Cv300 |
| Hi3518Ev200 | 64     | 65     |
| Hi3516Ev200 | 12     | 13     |          | 4     |
| Hi3516Av300 | 5      | 6      |

### Jabsco boards

| Processor   | IRCUT1 | IRCUT2 | IRSTATUS |
|-------------|--------|--------|----------|
| Hi3516Ev200 | 52     | 53     | 9        |

### JVT boards

| Processor   | IRCUT1 | IRCUT2 | LIGHT |
|-------------|--------|--------|-------|
| Hi3516Cv100 |
| Hi3516Cv200 | 64     | 65     | 62    |
| Hi3516Cv300 |
| Hi3516Ev200 |
| Hi3518Ev200 | 64     | 65     | 47    |

### JUAN boards (Sannce)

| Processor   | IRCUT1 | IRCUT2 | IRSTATUS      | TESTED BOARDS | DEVICE ID |
|-------------|--------|--------|---------------|---------------|-----------|
| Hi3518Ev200 | 65     | 64     | 62 (inverted) | 18EV200_V205P | N18EV2W   |

### Tiandy boards

| Processor   | IRCUT1 | IRCUT2 | IRSTATUS | IRCTL | RESET |
|-------------|--------|--------|----------|-------|-------|
| SSC335      | 78     | 79     | ---      | 37    |       |

### Uniview boards

| Processor   | IRCUT1 | IRCUT2 | RESET | DEVICE ID                |
|-------------|--------|--------|-------|--------------------------|
| Hi3516Ev300 | 63     | 67     | 64    | Rostelecom IPC8232SWC-WE |

### XM boards

| Processor    | IRCUT1 | IRCUT2 | IRSTATUS | IRCTL | ALM_IN | ALM_OUT | ETH_ACT | ETH_STA | RESET | USB_ENA |
|--------------|--------|--------|----------|-------|--------|---------|---------|---------|-------|---------|
| GK7205V200   | 8      | 9      | 15       | 16    | 4, 53  | 55      | 14      | 12      | 0     |         |
| GK7205V300   | 10     | 11     | 66       | 52    | 4      |         | 30      | 31      |       |         |
|              |        |        |          |       |        |         |         |         |       |         |
| Hi3516Cv100  | 38     | 39     | 24       |       | 49     | 26      |         |         |       |         |
| Hi3516Dv100* | 14     | 15     |          |       |        |         |         |         |       |         |
| Hi3516Cv200  |        |        |          |       |        |         |         |         |       |         |
| Hi3516Cv300  | 53     | 54     | 64       | 66    | 55     | 1       |         |         | 2     | 63      |
| Hi3516Ev100  | 53     | 24     |          |       |        |         |         |         |       |         |
| Hi3516Ev200  | 8      | 9      | 15       | 16    | 4, 53  | 55      | 14      | 12      | 0     |         |
| Hi3516Ev300  | 10     | 11     | 66       | 52    | 4, 67  | 65      | 30      | 31      | 0     |         | 
| Hi3518Ev200  | 33     | 34     |          |       | 61     | 35      |         |         |       |         |

* HI3516D_N81820, 00014914 firmware

### Zenotech/Videopark

| Processor   | IRCUT1 | IRCUT2 | IRLED | DEVICE ID                |
|-------------|--------|--------|-------|--------------------------|
| Hi3516Ev300 | 40     | 41     | 65    | unknown                  |


### Jovision boards

| Processor   | IRCUT1 | IRCUT2 | LIGHT |  TESTED BOARDS  |
|-------------|--------|--------|-------|-----------------|
| Hi3516Ev200 | 53     | 52     | 4     |                 |
| Hi3516Cv100 | 42     | 43     | 6     | IPG5020A-H-V1.0 |


### Rotek Switcam E200/T200 JXF23 sensor

| Processor   | IRCUT1 | IRCUT2 | IRSTATUS |
|-------------|--------|--------|----------|
| Hi3516Ev200 | 63     | 64     | 65       |
