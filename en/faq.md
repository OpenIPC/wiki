# OpenIPC Wiki
[Table of Content](../index.md)

Questions and answers
----------------

### How to sign in into camera via SSH?

`ssh root@<camera_ip_address>`

There is no password by default.

### How to sign in into camera web UI?

Open http://<camera_ip_address>:85/ and sign in using default username _admin_ and default password _12345_.
You will be asked to change the password after successful login. __Please note, it will also change your ssh root password!__

### How to find information about the camera hardware and software?

Sign in on camera via `ssh` and run `ipctool`.

### I don't see ipctool on camera. Why?

You don't see it because initially it is not there, but there is a shell command of the same name. _(Since it's a shell command, it won't work from Web Console in web UI. Sign in to the camera via SSH and run the command in there.)_ When you run this command, the latest available version of `ipctool` utility gets downloaded into `/tmp/` directory and runs from there. Since the utility resides in `/tmp/`, it won't survive a reboot, thus won't take any useful space on the camera afterwards.

If you need to know what's in the command, search for `ipctool` in `/etc/profile` file.

### How to find original MAC address in a firmware dump

```
strings dumpfile.bin | grep ^ethaddr
```

### How to configure ssh session authorization by key

__On the camera__: Sign in into web UI on port 85 of your camera.
```
passwd
```

__On the desktop__: Copy the public key to the camera by logging in with the password created above.
```
ssh-copy-id root@192.168.1.666
```

__On the camera__: Create a `.ssh` folder in the root user's home directory and copy the file with the authorized keystore into it.
```
mkdir ~/.ssh
cp /etc/dropbear/authorized_keys ~/.ssh/
```

__On the desktop__: Open a new session to verify that the authorization is passed using the public key not requesting a password.
```
ssh root@192.168.1.666
```

### Majestic

#### How to get a memory dump for debugging?
Enable and configure Core Dump in the menu Majestic > Majestic Debugging.

#### Camera image has a pink tint
You need to specify the GPIO pins to control the infrared filter.
The settings for some cameras can be found in the [table](https://openipc.org/wiki/en/gpio-settings.html).
If your camera is not in the table, then you will need the [ipctool](https://github.com/OpenIPC/ipctool/releases/download/latest/ipctool) utility.

The OpenIPC firmware will automatically download the latest version of the utility to the /tmp directory when `ipctool` is invoked first time.
On native firmware, you will need to download the utility to the camera yourself using the tools available in the system: wget, curl, tftp...
For example, download the ipctool utility to TFTP server on the local network, then download it to the camera:
```
tftp -g -r ipctool -l /tmp/ipctool 192.168.1.1
chmod +x /tmp/ipctool
/tmp/ipctool

```
If the camera has internet access, you can try to mount a public NFS sharing and run the utility from it, without downloading to the camera:
```
mkdir -p /tmp/utils
mount -o nolock 95.217.179.189:/srv/ro /tmp/utils/
/tmp/utils/ipctool
```

After the utility is downloaded to the camera, run the `ipctool gpio scan` command in the terminal and open-close the camera lens a couple of times with your palm.
Watch the output of ipctool to determine the pins responsible for controlling the IR filter curtain.
Enter the values obtained in the settings for the night mode Majestic. If the pink tint still persists, you may need to enable sensor signal inversion.

Don't forget to add the camera model and found GPIO values to the table!

#### Is it possible to display the data for setting the auto focus of lenses instead of the current sample_af in the standard /metrics?
No, this is a difficult algorithm, it does not have a sense to run it this way.

#### Copy files from Linux system to camera
Sometimes you need to transfer files to the camera. In addition to the above method using NFS (Network File System)
you can use the standard Linux scp command to copy files over an SSH connection:
```
scp ~/myfile root@192.168.1.65:/tmp/
```
This command will copy myfile from the home directory to the /tmp directory on the camera.
On recent Linux systems the following error may occur:
```
sh: /usr/libexec/sftp-server: not found
scp: Connection closed
```

Add -O option in this case:
```
scp -O ~/myfile root@192.168.1.65:/tmp/
```
