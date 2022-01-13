## Configuration requirements

To prevent accidental stream termination on temporary connection drops schedule live streaming with a start date in the far future (e.g. 31 December of the current year). It will work smoothly when you go live, disconnect the camera and then continue streaming.

### HLS + H.265

Follow up [Delivering Content via HLS](https://developers.google.com/youtube/v3/live/guides/hls-ingestion) for more information.

### Create new stream

- Navigate https://developers.google.com/youtube/v3/live/code_samples page

- Select Resource 'liveStreams' and Method 'insert'

- In table below click on 'insert' use case

- Fill on right side on the page:
  - in 'cdn' object change "frameRate" from "60fps" to "variable", 
  - "resolution" from "1080p" to "variable" 
  - and "ingestionType" from "rtmp" to "hls":

```
    "cdn": {
    "ingestionType": "hls",
    "frameRate": "variable",
    "resolution": "variable"
    }
```

- in Credentials section make sure you've selected 'Google OAuth 2.0' and 'https://www.googleapis.com/auth/youtube' scope (use 'Show scopes') and deselect 'API Key' option, then press 'Execute' button below

- Authorize yourself using your YouТube connected account

- Make sure that you got 200 response otherwise check errors and repeat. Trivial error is when [live streaming](https://support.google.com/youtube/answer/2474026?hl=en was not priviosly enabled  in your account.

- Save "channelId" from the response (it looks like this "UCPJRjbxYlq6h2cCqy8RCRjg")

### Create new broadcast:

- Navigate https://developers.google.com/youtube/v3/live/code_samples page

- Select Resource 'liveBroadcast' and Method 'insert'

- In table below click on 'insert' use case

- Fill on right side on the page:

  - 'title' field for your broadcast like 'My Hometown Camera'

  - 'scheduledStartTime' like '2020-04-21T00:00:00.000Z' (ensure that this time in the future),

  - 'scheduledEndTime' like '2020-04-21T01:00:00.000Z' (scheduled end time should be after the scheduled start time)

  - also press blue plus button inside "snippet" block and add "channelId" with given from stream step value

```
  "snippet": {`
    `"title": "My Hometown Camera",`
    `"scheduledStartTime": "2021-04-12T00:00:00.000Z",`
    `"scheduledEndTime": "2021-04-13T00:00:00.000Z",`
    `"channelId": "MCpZqkqqEZw806aGGHUdepIl"`
  `},
```

  - in Credentials section make sure you've selected 'Google OAuth 2.0' and 'https://www.googleapis.com/auth/youtube' scope (use 'Show scopes') and deselect 'API Key' option, then press 'Execute' button below

- Authorize yourself using your YouTube connected account

- Make sure that you got 200 response otherwise check errors and repeat

### Bind the broadcast to the stream:

- Navigate https://developers.google.com/youtube/v3/live/code_samples page

- Select Resource 'liveBroadcast' and Method 'bind'

- In table below click on 'Bind a broadcast to a stream' use case

- Fill on right side on the page:

  - 'id' - ID of the broadcast (can be found in server response in step 'Create new broadcast', field 'id')

  - 'streamId' - ID of the stream (can be found in server response in step 'Create new stream', field 'id')

  - in Credentials section make sure you've selected 'Google OAuth 2.0' and 'https://www.googleapis.com/auth/youtube' scope (use 'Show scopes') and deselect 'API Key' option, then press 'Execute' button below

- Authorize yourself using your YouTube connected account

- Make sure that you got 200 response otherwise check errors and repeat

### Go live!

Navigate https://studio.youtube.com/

On right side click on 'CREATE' button and then 'Go live'

credits (c) Victor
Origin
https://github.com/OpenIPC/camerasrnd/blob/master/streaming/youtube.md
