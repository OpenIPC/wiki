# OpenIPC Wiki
[Table of Content](../README.md)

Frequently Asked Questions for FPV
----------------------------------

<p align="center">
  <img src="https://github.com/OpenIPC/wiki/blob/master/images/fpv-logo.jpg?raw=true" alt="Logo"/>
</p>

### What’s the lowest possible latency?

With wfb-ng, the project's glass-to-glass tests measured about 60 ms for 720p@60, about 80 ms for 1080p@60 on mid-budget cameras, and about 100 ms for 1080p@30 on the most budget cameras; see the Benefits section of [OpenIPC as FPV system](../en/fpv.md). Lower latency requires encoding and decoding at 120 fps and using a 120 Hz display. Results depend on the camera SoC, sensor, ground station and decoder, so the project does not publish an official figure. With APFPV (video over a regular Wi-Fi access point), latency can be as low as about 25 ms at 720p 120 fps, depending on the ground station.

See the [OpenIPC FAQ](https://docs.openipc.org/resources/faq/) and the [APFPV questions](https://docs.openipc.org/use-cases/fpv/apfpv/gregs_apfpv/) on the docs site.

### What’s the maximum achievable range?

Range depends on the Wi-Fi adapters, antennas, transmit power, channel width, MCS and terrain, not on the firmware itself. Community flights with wfb-ng have reached [25 km](https://www.youtube.com/watch?v=c7XtKujrzSg) and [15 km](https://www.youtube.com/watch?v=6__OMDvJ6o0). See [the YouTube list](../en/fpv-youtube.md) for more. For APFPV, the confirmed range is 2 km at low altitude with an RTL8812EU module on the drone side.

Use the [wfb-ng calculator](https://docs.openipc.org/use-cases/fpv/wfb-ng/wfb-ng-calculator/) to estimate the link budget for your setup.

### How much does it weigh?

It depends on the board:

- OpenIPC Thinker, main unit with camera module: about 8.8 g, or 13.4 g with the heat sink ([details](https://docs.openipc.org/hardware/openipc/vtx/fpv-thinker-aio/)).
- RunCam WiFiLink v2: 25 g, or 30 g with the fan ([details](https://docs.openipc.org/hardware/runcam/vtx/runcam-wifilink-v2/)).
- EMAX Wyvern Link VRX (ground side): 71.6 g without antenna, 101.2 g as a complete kit ([details](https://docs.openipc.org/hardware/emax/vrx/emax-wyvern-link-vrx/)).
