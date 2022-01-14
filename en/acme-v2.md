# OpenIPC Wiki
[Table of Content](index.md)

How to install HTTPS certificates on your camera
------------------------------------------------

Make sure your camera is accessible from the Internet on both port 80 (HTTP)
and port 443 (HTTPS). You might need to set up port forwarding on your router
for that.

Create an ACME account:

```console
$ uacme -y -v new
```

Issue a certificate for your domain:

```console
$ uacme -y -v -h /usr/share/uacme/uacme.sh -t EC issue www.your.domain.com
```

If everything goes well, uacme will ask you to set up a challenge, e.g.:

```
uacme: challenge=http-01 ident=www.your.domain.com token=kZjqYgAss_sl4XXDfFq-jeQV1_lqsE76v2BoCGegFk4
key_auth=kZjqYgAss_sl4XXDfFq-jeQV1_lqsE76v2BoCGegFk4.2evcXalKLhAybRuxxE-HkSUihdzQ7ZDAKA9EZYrTXwU
```

Restart majestic and test access to https://www.your.domain.com/
