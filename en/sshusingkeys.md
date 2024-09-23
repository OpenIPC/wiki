# OpenIPC Wiki
[Table of Content](../README.md)

SSH access using public key authentication
==========================================
In OpenIPC remote access via SSH is handled by the Dropbear module [see https://github.com/mkj/dropbear]

To enable password free access and enhance security you can simply configure the required key details by completing the following steps:

#### Step 1: connect to the camera
First we need to establish a terminal connection to the camera using the traditional way with your current root password 
e.g. ssh root@192.168.1.10. This is because we need to find the existing private key file so we can get the public key for our client end configuration. 

#### Step 2: check there is a symlink to the dropbear files
When using clients for remote login they look for two key files, authorized_keys and known_hosts, which reside in the users .ssh directory in both Windows and Linux systems. 
In OpenIPC these files are actually located in the /etc/dropbear directory and so by default there is a link created in the root user home directory (/root) that points to the required files 
and will look like this **.ssh -> /etc/dropbear/**

If this has been deleted or changed in your camera then create it with the command **ln -s ~/.ssh /etc/dropbear**

#### Step 3: get the public key
There are two keys used in the public key authentication process a private key and a public key. As their names suggest the private key must be kept secure and not shared with anyone however the public key is what we want to get and use in the client end.

By default dropbear creates a file named **dropbear_ed25519_host_key** with is located in the the **/etc/dropbear** directory and this is the private key.

We need to use the dropbearkey tool to get the public key

at the prompt enter dropbearkey -y -f /etc/dropbear/dropbear_ed25519_host_key

This will display the public key which we need. Simply highlight the text on screen after the statement Public key portion is: and copy it to your clipboard or a text file for temporary storage.

#### Step 4: configure your client
On your client machine find your .ssh directory typically in the user home direcotry so on linux ~/.ssh or in windows the /users/yourloginnanme/.ssh

Paste in the copied text on a single line and save the file

#### Step 5: test the connection for no password challenge
Now when you reconnect to the camera you should find that after a short delay that you are logged in without being asked for your password.

If you connect to the camera from multiple clients then configure the clients as above.

#### Trouble shooting
SSH access is very strict about ensuring that the keys in use are protected and therefore secure so if the permissions on the directories and files are not correct this can cause failures

To check what is going on and find any issues then use the -v option in ssh to get a verbose output
