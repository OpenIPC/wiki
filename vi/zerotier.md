# ZeroTier One
Package [ZeroTier One](https://www.zerotier.com) for ultimate builds.

### Start
- To start the service, execute this command:
```
/usr/sbin/zerotier-one -d &
```

### Setup
1. Register at [my.zerotier.com](https://my.zerotier.com).
2. Get the network ID, configure the network as private.
3. From the ssh console (or web console) run the following:
```
zerotier-cli join [network id]
```

4. Go to the web interface at [my.zerotier.com](https://my.zerotier.com) and authorize the newly connected camera, authorization occurs by checking the box next to the corresponding peer.

### Settings
- The configuration is stored in `/var/lib/zerotier-one`
- You can leave the network by running the following command:
```
zerotier-cli leave [network id]
```
