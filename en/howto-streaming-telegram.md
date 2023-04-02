# OpenIPC Wiki
[Table of Content](../README.md)

## Live streaming to Telegram

Open the channel you want to translate to. Start a streaming session.

![](../images/howto-streaming-telegram-1.webp)

Copy Server URL and Stream key from Settings.

![](../images/howto-streaming-telegram-2.webp)

Open `/etc/majestic.yaml` on camera and add the URL and the key into `outgoing` section of the config.

**Note:** Dont forget add `-` sign before paramethers!

**Note:** `outgoing` section may affect another section addition. Remember it!

![](../images/howto-streaming-telegram-3.webp)
![](../images/howto-streaming-telegram-4.webp)

Restart majestic streamer.

![](../images/howto-streaming-telegram-5.webp)

Enjoy the stream.

![](../images/howto-streaming-telegram-6.webp)
