# OpenIPC Wiki
[Table of Content](../README.md)

SSH access using public key authentication
==========================================
## Introduction
OpenIPC uses a package called Dropbear for managing **S**ecure **SH**ell (SSH) client connections. By default this is configured to use the root username and associated password however it can be made both more secure and simpler by making it passwordless.

If you are new to understanding SSH and PKI then it is suggested you read the ssh guide [here](https://www.ssh.com/academy/ssh) for a full understanding however unless you need to debug why connections are failing or some other in depth issue then the basic understanding of the terms client, server and keys should be sufficient.

The term PKI is used to describe all of the elements used for creating a secure encrypted connection between two devices. These devices are referred to as clients or servers. In simple terms the target machine you are connecting to is the server and the host machine you are connecting from is the client.

To create a secure connection your client is setup with a 'private' key and each server you access is setup with a matching 'public' key. The public key is exchanged during the connection process and tested to make sure it matches with the private key.

Your private key is the only thing that can decrypt data that has been encoded with the matching public key hence why your private key must be safely guarded and the public key part is what we share.

In the initial connection phase there is also a check that the server is the correct device and so these identities are stored in a 'known_hosts' file.

There are many algorithms that have been implemented over the years to ensure connections are extremely hard to break into and so with modern computing power this has meant some of the earlier ones are no longer supported. Modern popular public key encryption standards include RSA (Rivest–Shamir–Adleman) and EdDSA (Edwards-curve Digital Signature Algorithm).

This article has been written on how to achieve this using the standard SSH clients included with most modern Linux and Windows distributions i.e. OpenSSH.

## OpenIPC camera with public key (most common setup)
For the most common configuration we first need to generate a key pair and securely get our key to the camera into the authorized_key file.

#### Step 1: connect to the camera
Establish a terminal connection to the camera using the traditional way with your current root password (as per the Majestic web login) e.g. ``` ssh root@<camera_ip_address> ```

#### Step 2: check there is a symlink to the dropbear files
When using SSH there are two key files, authorized_keys and known_hosts, which are expected to be found in the users home **.ssh** directory in both Windows and Linux systems. 

As OpenIPC uses Dropbear, and not OpenSSH, these files are actually located in the cameras **/etc/dropbear** directory and so there is a link in the **root user home directory (/root)** that points to the required files and will look like this **.ssh -> /etc/dropbear/**. 

If this is missing then it is critical to recreate it with the command **ln -s ~/.ssh /etc/dropbear**

Logout again from the camera.

#### Step 3: create a key pair
To create our private and public key pair we use **ssh-keygen**. This gives us options on what type of key to create and it is recommended you use either the RSA or EdDSA type with EdDSA being the newest and potentially will take longer to break than the older RSA format.

To create the key pair on your **client** machine open a terminal window enter ```ssh-keygen -t ed25519``` .

You will be prompted with a few questions, simply press enter to accept the defaults.

You should see an output similar to this.

```Generating public/private ed25519 key pair.
Enter file in which to save the key (/home/<yourusername>/.ssh/id_ed25519): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/<yourusername>/.ssh/id_ed25519
Your public key has been saved in /home/<yourusername>/.ssh/id_ed25519.pub
The key fingerprint is:
SHA256:caaCz/2+eXiIbIPTkIo0/1+7njo8+7tHzaVVA4gworc <yourusername>@<yourmachinename>
The key's randomart image is:
+--[ED25519 256]--+
|     . o. . ...  |
|    . . .. .   ..|
|   . .  . o     o|
|    ...  =      o|
|    .E..S    o + |
|  o  ooo    . +  |
| . + .o*...+     |
|  . o o Xoo++    |
|     ..++X&O     |
+----[SHA256]-----+
```

If using windows then you will see /users/<yourusername> instead of the Linux /home/xxx format.

####  Step 4: get the public key on the camera
So we now have a private key and the associated public key on our host machine and the challenge is how to securely get this onto our target, in this case our camera, and added to the authorized_keys file in the target .ssd folder.

Thankfully this has been thought of and there is a utility called ssh-copy-id which allows us to do that.
Enter the following substituting your camera ip address and username:
```
ssh-copy-id -i /home/<yourusername>/.ssh/id_ed25519 root@<camera_ip_address>

```

You should get the following 
```ssh-copy-id -i /home/<yourusername>/.ssh/id_ed25519 root@<camera_ip_address>
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/<yourusername>/.ssh/id_ed25519.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
root@<yourcameraip>'s password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'root@<camera_ip_address>'"
and check to make sure that only the key(s) you wanted were added.
```

Now test it is working by trying to access the camera. You should find it will successfully login without asking for a password.
```~$ ssh root@<camera_ip_address>

   .d88888b.                             8888888 8888888b.   .d8888b.
  d88P" "Y88b                              888   888   Y88b d88P  Y88b
  888     888                              888   888    888 888    888
  888     888 88888b.   .d88b.  88888b.    888   888   d88P 888
  888     888 888 "88b d8P  Y8b 888 "88b   888   8888888P"  888
  888     888 888  888 88888888 888  888   888   888        888    888
  Y88b. .d88P 888 d88P Y8b.     888  888   888   888        Y88b  d88P
   "Y88888P"  88888P"   "Y8888  888  888 8888888 888         "Y8888P"
              888
              888
              888                            local+build, 2024-10-04

 Please help the OpenIPC Project to cover the cost of development and
 long-term maintenance of what we believe is going to become a stable,
 flexible Open IP Network Camera Framework for users worldwide.

 Your contributions could help us to advance the development and keep
 you updated on improvements and new features more regularly.

 Please visit https://openipc.org/sponsor/ to learn more. Thank you.

root@openipc-hi3516ev300:~# 
````

Now if you enter ```cd .ssh``` and ```ls -la``` you will see similar to the following 

```
drwxr-xr-x    1 root     root             0 Oct  4 14:54 .
drwxr-xr-x    1 root     root             0 Oct  4 12:28 ..
-rw-------    1 root     root           101 Oct  4 14:54 authorized_keys
-rw-------    1 root     root            83 Oct  4 12:29 dropbear_ed25519_host_key
```

####  Step 4: Troubleshooting
There are few reasons why if you have followed the above that this will not work however the main issue faced is if for some reason the permissions are not correct on the .ssh folder and the files within it.

Ensure the .ssh folder has 700 permissions and the authorized_keys file 600 or similar in Windows, only your user and administrators have permission.  

To get a clue how to resolve issues then when entering the ssh command add -vvv which gives verbose debug output and usually will highlight where things are failing.

#### Finally
Remember the private key should never be duplicated or moved.
