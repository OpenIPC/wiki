ToDo
----

## Bugfix

* Need fix the problem that caused syslogd and logread to stop working on hi35{16ev200,16ev300,18ev300} profile


## Improvement and Features

* Urgently add support for Goke processors
* Make a check for the presence of binary components in the majestic, mini_snmpd, telnetd and other scripts
* Build the new [motors-openipc](https://github.com/OpenIPC/motors/tree/master/XM) package
* Integrate the new version of [libjson](https://github.com/json-c/json-c/tree/json-c-0.15) according to the OpenIPC standard and remove the old symlinks
* Create an Initramfs and cpio build for all platforms
* Optimize Busybox applets and disable all unnecessary ones
* Add the launch of the Crond daemon
* Add the Telegram bot script from the old OpenIPC project
* Optimize the show_modules script to show dynamically consumed memory
* ~
* Integrate Hi3516Av300/Hi3516Cv500/Hi3516Dv300
* Integrate Hi3516Cv200/Hi3518Ev200/Hi3518Ev201
* Integrate Hi3516Av100/Hi3516Dv100
    * Connect the script for initializing modules and starting the system


## Monitoring and Management

* Upload to the repository examples of working with Ansible
* Install a local prometheus server
* Achieve stable telemetric responses from ZFT Lab. devices


## Documentation

* Create a Wiki page for entering data of boards with motors and protocol specifics
