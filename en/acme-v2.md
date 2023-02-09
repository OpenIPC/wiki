# OpenIPC Wiki
[Table of Content](../index.md)

How to install HTTPS certificates on your camera
------------------------------------------------

Make sure your camera is accessible from the Internet on both port 80 (HTTP)
and port 443 (HTTPS). You might need to set up port forwarding on your router
for that.

### Create an ACME account:

__on camera:__
```console
$ uacme -y -v new
```

### Give your camera a FQDN

Secure HTTP (Hypertext Transfer Protocol Secure, HTTPS) cannot be issued to a bare IP address,
you need a Fully Qualified Domain Name (FQDN) for your camera. That is how your camera will
be accessed over HTTPS.

Create an account with any Domain Name Register and register a domain name, e.g. _mysuperduperdomain.com_.

Set up a DNS zone for that domain name and create a record for your camera in that domain zone.
```
DNS Records
mysuperduperdomain.com
---------------------------------------
Type    Host       IP Address       TTL
A       ipc-001    75.123.45.555    600
```
where `75.123.45.555` is your public IP address.

### Set up port forwarding if your camera is behind NAT.

Add port forwarding from port 80 of WAN interface to port 80 of your camera's local IP address.

```
75.123.45.555:80 => 192.168.1.10:80
```

If you have several devices on your network serving public HTTP requests then add your
camera domain name to HTTP proxy.

### Issue a certificate for your domain:

__on camera__:
```console
$ uacme -y -v -h /usr/share/uacme/uacme.sh -t EC issue ipc-001.mysuperduperdomain.com
```

### Set up a local DNS record override

You can add an override record to `/etc/hosts` file on your machine
```
echo "192.168.1.10  ipc-001.mysuperduperdomain.com" >> /etc/hosts
```
or you could create a record on your local DNS server like [pi.hole](https://pi-hole.net/)
so that anyone using that DNS server could have secure access to the camera, too.

### Restart majestic and test access

Open your favorite web browser and go to https://ipc-001.mysuperduperdomain.com/
