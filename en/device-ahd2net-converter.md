## AHD 2 NET converter


![AHD2NET_pinout](/images/AHD2NET_pinout_CPU.png)
![AHD2NET_pinout](/images/AHD2NET_pinout_TP.jpg)

## Hardware

GK7205V200  

TP9950

8Mb flash

| Name | pins |Description| GPIO | Usage |
| --- | --- | --- |---|---|
|**tp**||| gpio15 |ipctool gpio mux 15 gpio
|**led**|20|led| gpio69 |ipctool gpio mux 69 gpio
|**button**|70|pwm 0|  |
||

### [ipctool](https://github.com/OpenIPC/ipctool) output (8Mb flash):

```
---
chip:
  vendor: Goke
  model: 7205V200
  id: 22619808020855e3
board:
  vendor: OpenIPC
  version: 2.4.10.14
ethernet:
  mac: "00:b9:47:77:a7:ac"
  u-mdio-phyaddr: 1
  phy-id: 0x20669906
  d-mdio-phyaddr: 0
rom:
- type: nor
  block: 64K
  partitions:
    - name: boot
      size: 0x40000
      sha1: 784cff96
    - name: env
      size: 0x10000
      sha1: c39eab8e
      contains:
        - name: uboot-env
          offset: 0x0
    - name: kernel
      size: 0x200000
      sha1: 7cddc566
    - name: rootfs
      size: 0x500000
      sha1: d716df93
    - name: rootfs_data
      size: 0xb0000
      path: /overlay,jffs2,rw
  size: 8M
  addr-mode: 3-byte
ram:
  total: 64M
  media: 32M
firmware:
  kernel: "4.9.37 (Mon Oct 14 22:46:14 UTC 2024)"
  toolchain: buildroot-gcc-13.2.0
```





## Flashing OpenIPC

Flashed using a tftpboot
stop stock uboot by ENTER key

setenv serverip 192.168.1.209

setenv ipaddr 192.168.1.203

 tftpboot 0x40800000 192.168.1.209:openipc-gk7205v200-lite-8mb.bin
 
sf probe 0

sf erase 0x0 0x800000

sf write 0x40800000 0x0 0x800000


//need set sensor as bt656  by hand

setenv sensor bt656

saveenv

reset

## Autodetect video type scripts

[script.sh](https://github.com/OpenIPC/sandbox/tree/main/scripts/bt656/tp9950)

## Warning 

after first booting GPIO_3 with a button connected, muxed as PWM0, pressing the button may damage the port !
 

### [ipctool](https://github.com/OpenIPC/ipctool) pinmux 

```

./ipctool reginfo
muxctrl_reg0 0x100c0000 0x1 GPIO0_1 [UART0_RXD]
muxctrl_reg1 0x100c0004 0x1 GPIO0_2 [UART0_TXD]
muxctrl_reg2 0x100c0008 0 [GPIO0_0] UPDATE_MODE
muxctrl_reg3 0x100c000c 0 [GPIO0_3] PWM0 UART1_TXD I2C1_SCL
muxctrl_reg4 0x100c0010 0 [GPIO0_4] PWM1 UART1_RXD I2C1_SDA
muxctrl_reg5 0x100c0014 0x1 EMMC_CLK [SFC_CLK] SFC_DEVICE_MODE
muxctrl_reg6 0x100c0018 0x1 EMMC_CMD [SFC_MOSI_IO0]
muxctrl_reg7 0x100c001c 0x1 EMMC_DATA0 [SFC_MISO_IO1]
muxctrl_reg8 0x100c0020 0x1 EMMC_DATA3 [SFC_WP_IO2]
muxctrl_reg9 0x100c0024 0x1 EMMC_DATA2 [SFC_HOLD_IO3]
muxctrl_reg10 0x100c0028 0x1 EMMC_DATA1 [SFC_CSN]
muxctrl_reg11 0x100c002c 0 [SYS_RSTN_OUT]
muxctrl_reg12 0x100c0040 0x1 GPIO4_0 [SDIO0_CCLK_OUT] JTAG_TCK EMMC_CLK SDIO1_CCLK_OUT reserved VO_BT1120_DATA10 SFC_INPUT_SEL
muxctrl_reg13 0x100c0044 0x1 GPIO4_1 [SDIO0_CCMD] reserved EMMC_CMD SDIO1_CCMD reserved VO_BT1120_DATA11
muxctrl_reg14 0x100c0048 0x1 GPIO4_2 [SDIO0_CDATA0] JTAG_TMS EMMC_DATA1 SDIO1_CDATA3 reserved VO_BT1120_DATA12
muxctrl_reg15 0x100c004c 0x1 GPIO4_3 [SDIO0_CDATA1] JTAG_TDO EMMC_DATA2 SDIO1_CDATA2 reserved VO_BT1120_DATA13
muxctrl_reg16 0x100c0050 0x1 GPIO4_4 [SDIO0_CDATA2] JTAG_TDI EMMC_DATA3 SDIO1_CDATA1 reserved VO_BT1120_DATA14
muxctrl_reg17 0x100c0054 0x1 GPIO4_5 [SDIO0_CDATA3] JTAG_TRSTN EMMC_DATA0 SDIO1_CDATA0 reserved VO_BT1120_DATA15
muxctrl_reg18 0x100c005c 0x1 GPIO4_7 [SDIO0_CARD_DETECT] reserved EMMC_RST_N
muxctrl_reg19 0x112c0000 0x2 MIPI_RX_CK0N reserved [VI_CLK]
muxctrl_reg20 0x112c0004 0x2 MIPI_RX_CK0P reserved [VI_DATA7]
muxctrl_reg21 0x112c0008 0x2 MIPI_RX_D0N reserved [VI_DATA8]
muxctrl_reg22 0x112c000c 0x2 MIPI_RX_D0P reserved [VI_DATA9]
muxctrl_reg23 0x112c0010 0x2 MIPI_RX_D2N reserved [VI_DATA11]
muxctrl_reg24 0x112c0014 0x2 MIPI_RX_D2P reserved [VI_DATA10]
muxctrl_reg25 0x112c0028 0x2 TEST_CLK SENSOR_CLK [VI_DATA6] reserved GPIO5_4
muxctrl_reg26 0x112c002c 0x2 GPIO5_5 SENSOR_RSTN [VI_DATA4]
muxctrl_reg27 0x112c0030 0x2 GPIO5_6 I2C0_SDA [VI_DATA3]
muxctrl_reg28 0x112c0034 0x2 GPIO5_7 I2C0_SCL [VI_DATA5]
muxctrl_reg29 0x112c0038 0x2 GPIO6_2 I2C2_SDA [VI_DATA2] reserved reserved reserved reserved SPI0_SDO
muxctrl_reg30 0x112c003c 0x2 GPIO6_3 I2C2_SCL [VI_DATA1] reserved reserved reserved reserved SPI0_SCLK
muxctrl_reg31 0x112c0040 0x2 GPIO5_0 ETH_LINK_STA_LED [VI_DATA0] reserved reserved reserved reserved SPI0_CSN
muxctrl_reg32 0x112c0044 0x1 GPIO5_1 [ETH_LINK_ACT_LED] TEST_MODE
muxctrl_reg33 0x112c0048 0 [GPIO8_7] BOOT_SEL1 SENSOR_RSTN VO_BT656_CLK SDIO1_CCLK_OUT LCD_CLK VO_BT1120_CLK SPI1_SCLK
muxctrl_reg34 0x112c004c 0 [GPIO8_5] reserved VI_HS VO_BT656_DATA0 SDIO1_CCMD LCD_HS VO_BT1120_DATA8 SPI1_SDI
muxctrl_reg35 0x112c0050 0 [GPIO8_6] reserved VI_VS VO_BT656_DATA1 reserved LCD_VS VO_BT1120_DATA9 SPI1_SDO
muxctrl_reg36 0x112c0054 0x2 GPIO8_4 BOOT_SEL0 [SENSOR_CLK] PWM2 reserved LCD_DE reserved SPI1_CSN0
muxctrl_reg37 0x112c0058 0 [GPIO7_0] reserved I2C2_SCL VO_BT656_DATA4 SDIO1_CDATA3 LCD_DATA4 VO_BT1120_DATA4 SPI1_CSN1
muxctrl_reg38 0x112c005c 0 [GPIO7_1] reserved I2C2_SDA VO_BT656_DATA5 SDIO1_CDATA2 LCD_DATA5 VO_BT1120_DATA5
muxctrl_reg39 0x112c0060 0x2 GPIO7_2 reserved [I2C0_SDA] VO_BT656_DATA6 SDIO1_CDATA1 LCD_DATA6 VO_BT1120_DATA6
muxctrl_reg40 0x112c0064 0x2 GPIO7_3 reserved [I2C0_SCL] VO_BT656_DATA7 SDIO1_CDATA0 LCD_DATA7 VO_BT1120_DATA7
muxctrl_reg41 0x112c0068 0 [GPIO6_7] reserved reserved VO_BT656_DATA3 reserved LCD_DATA3 VO_BT1120_DATA3 SPI0_CSN
muxctrl_reg42 0x112c006c 0 [GPIO6_6] SFC_BOOT_MODE PWM3 VO_BT656_DATA2 reserved LCD_DATA2 VO_BT1120_DATA2 SPI0_SDO
muxctrl_reg43 0x112c0070 0 [GPIO6_5] reserved UART1_RXD reserved reserved LCD_DATA1 VO_BT1120_DATA1 SPI0_SDI
muxctrl_reg44 0x112c0074 0 [GPIO6_4] reserved UART1_TXD reserved reserved LCD_DATA0 VO_BT1120_DATA0 SPI0_SCLK
muxctrl_reg45 0x120c0000 0x1 GPIO1_0 [LSADC_CH0]
muxctrl_reg46 0x120c0004 0 [GPIO1_1] LSADC_CH1
muxctrl_reg47 0x120c0010 0 [JTAG_TRSTN] SPI1_CSN0 GPIO1_4 reserved UART2_RXD I2S_MCLK
muxctrl_reg48 0x120c0014 0 [JTAG_TCK] SPI1_SCLK GPIO1_5 reserved UART2_TXD I2S_BCLK
muxctrl_reg49 0x120c0018 0 [JTAG_TMS] SPI1_SDI GPIO1_6 PWM2 UART2_CTSN I2S_WS
muxctrl_reg50 0x120c001c 0 [JTAG_TDO] SPI1_SDO GPIO1_7 reserved UART2_RTSN I2S_SD_RX
muxctrl_reg51 0x120c0020 0x3 JTAG_TDI SPI1_CSN1 GPIO2_0 [SDIO0_CARD_POWER_EN] PWM3 I2S_SD_TX
```





