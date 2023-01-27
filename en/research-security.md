# OpenIPC Wiki
[Table of Content](../index.md)

Access to SSH, telnet, FTP and other services
---------------------------------------------

Very often stock firmware provides access to its operating system but tha access is closed with an undisclosed password.
We can recover a cryptographic hash of that password while extracting a copy of the firmware image, but then we have to
employ a password-breaking software and powerful computing resources to find the original plain-text password that could 
be used to get access to the firmware running on the camera.

When a password is found, it is wise to share it publicly, so that other developers in the field could dedicate their
cryptographic resources to discover even more yet unknown passwords. Sharing is caring, boys!

### Some passwords that we found in different firmware
```
| Hash                                  | Plain password |
|---------------------------------------|----------------|
| $1$0Me7S3z5$.uQ4Pr/QjJQ/0JUZI0w4m.    |                |
| $1$MoCJ1nRA$NfsI1wlYcWoF5MbU4t3Og0    |  ivdev         |
| $1$ZebZnWdY$QZ1Aa.7hwBshCS5k40MUE1    |  xc12345       |
| $1$d3VPdE0x$Ztn09cyReJy5Pyn           |  runtop10      |
| $1$qFa2kfke$vJob19l64Q6n8FvP8/kvJ0    |  wabjtam       |
| $1$rHWQwR5V$i4FVDvwhuzau8msvAfHEt.    |  2601hx        |
| $1$tiaLlxGM$byeTUfQgqyET5asfwwNjg0    |  hichiphx      |
| $1$vN9F.lHa$E09mbCRo70834AUfkytpX     |                |
| $1$yFuJ6yns$33Bk0I91Ji0QMujkR/DPi1    |                |
| $1$yi$FS7W5j1RJmbRHDe0El/zX/          |                |
| $1$yi$MiivC6pLdwS0zp0pa0cUq1          | qw1234qw       |
| $Dg.cUjtWGTIVkuFS0ZYbN1               | fx1805         |
| $enWsv2cbxPCrd0WeXUXtX0               | nobody         |
| $qZV4X6DTqMHUDIyZG.8PH.               |                |
| $z2VkRbfNoE/xHLBj8i2cv.               | ftp            |
| 7wtxBdUGBnuoY                         | runtop10       |
| 9B60FC59706134759DBCAEA58CAF9068      | Fireitup       |
| LHjQopX4yjf1Q                         | ls123          |
| ab8nBoH3mb8.g                         | helpme         |
| absxcfbgXtb3o                         | xc3511         |
| xt5USRjG7rEDE                         | j1/_7sxw       |
```
