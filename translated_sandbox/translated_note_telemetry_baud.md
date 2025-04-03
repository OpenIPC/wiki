## Note on different uart speed for telemetry than 115200
  
TipoMan encountered a problem: the camera hung when sending telemetry to uart at a speed different from 115200. Solution: setting the desired speed in `/etc/inittab`.

![inittab](notes_files/baud38400.jpg)