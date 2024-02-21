# OpenIPC Wiki
[Table of Content](../README.md)

Roadmap
-------

### Quick access to Git logs for popular repositories:

- [firmware](https://github.com/OpenIPC/firmware/commits/master), [builder](https://github.com/OpenIPC/builder/commits/master), [coupler](https://github.com/OpenIPC/coupler/commits/main)
- [ipctool](https://github.com/OpenIPC/ipctool/commits/master), [webui](https://github.com/OpenIPC/webui/commits/master), [webui-next](https://github.com/OpenIPC/webui-next/commits/master), [wiki](https://github.com/OpenIPC/wiki/commits/master)

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

### 19.02.2024:
- [hisilicon/goke] Fix muxing unneeded GPIOs which were burning IRCUTs on XM boards

### 12.02.2024:
- Added an enhancement that allows Majestic to run cgi scripts detached from the sdk.
- Fixed an issue that prevented rebinding the rtsp port.
- Fixed a problem with the Majestic webserver home directory.
- Fixed an exception on the codec selection.
- Improved stability if majestic.yaml is not available.
- Reduced time frame for Majestic shutdown on Ingenic devices.

### 05.02.2024:
- Added mjpeg preview to webui-next.
- Added mjpeg support for Ingenic.
- Added port 85 redirect to Majestic webserver.
- Adjusted several Majestic configuration settings for webui-next.
- Fixed night mode controls on webui-next.
- Fixed a problem with inverting single ircut.
- Set Majestic as only webserver for webui-next.
- Set majestic-webui as default for Sigmastar devices.
- Note: majestic-webui extensions are not available for now.

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
