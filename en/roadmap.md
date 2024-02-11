# OpenIPC Wiki
[Table of Content](../README.md)

Roadmap
-------

### Planned changes:

- Add webui-next as default interface.
- Better integration with Majestic and webui-next.
- Continued refactoring of firmware scripts and packages.
- Extend builder support.
- Extend docs support.
- Extend majestic-plugins support.
- Update buildroot to upcoming 2024 version.
- Update wiki build commands.
- Update wiki majestic commands.

### 05.02.2024:
- Added mjpeg preview to webui-next.
- Added mjpeg support for Ingenic.
- Added port 85 redirect to Majestic webserver.
- Adjusted several Majestic configuration settings for webui-next.
- Fixed night mode controls on webui-next.
- Fixed a problem with inverting single ircut.
- Set Majestic as only webserver for webui-next.
- Set webui-next as default for Sigmastar devices.

### 29.01.2024:
- Added ipctool support for various new Sony sensors.
- Added additional commands when majestic-plugins are started and stopped.
- Added various new alias commands (show_help)
- Added experimental Majestic IP6 support.
- Added a check to prevent repeated execution to night mode settings.
- Replaced building.sh with makefile.
- Refactored several firmware scripts and package makefiles.

### 22.01.2024:
- Added T40/T41 chipset detection.
- Added audio support for Sigmastar fpv.
- Added optional night color mode.
- Fixed several Majestic stability issues.
- Fixed a problem with Ingenic motion detect on sighup/reload.
- Increased stability of Majestic webserver.
- Included gkrcparams into majestic configuration.
- Updated libevent library and toolchains.
- Updated Ingenic vendor libraries.

### 15.01.2024:
- Added separated control toggle for ircut and light.
- Added sensor based day/night detection.
- Added authentication to various endpoints.
- Added initial support for Ingenic register info scan.
- Fixed an issue with Majestic not correctly reopening udp sockets.
- Fixed an issue with the Ingenic T10/T20 rtsp stream.
- Fixed a problem with setting the correct hisilicon encoder bitrate.

### 08.01.2024:
- Added Majestic sighup support for Ingenic devices.
- Added h265 support for rtmp.
- Added rtmp reconnect option.
- Added support for Sigmastar register info scan.
- Fixed several rtmp authentication problems.
- Fixed a problem with rotation on a few Sigmastar sensor drivers.
- Removed Ingenic software based day/night detection.
