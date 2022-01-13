# How to setup HTTPS certificates on your camera

Make sure your camera is accessible from the Internet and both 80 (HTTP) and 443 (HTTPS) ports are redirected on your router to the camera. 

Create an ACME account:

```console
$ uacme -y -v new
```

then issue a certificate for your domain by doing

```console
$ uacme -y -v -h /usr/share/uacme/uacme.sh -t EC issue www.your.domain.com
```

If everything goes well uacme asks you to set up a challenge, for example

```
uacme: challenge=http-01 ident=www.your.domain.com token=kZjqYgAss_sl4XXDfFq-jeQV1_lqsE76v2BoCGegFk4
key_auth=kZjqYgAss_sl4XXDfFq-jeQV1_lqsE76v2BoCGegFk4.2evcXalKLhAybRuxxE-HkSUihdzQ7ZDAKA9EZYrTXwU
```

Then restart majestic and test access to https://www.your.domain.com