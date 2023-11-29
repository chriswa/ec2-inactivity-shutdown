# ec2-inactivity-shutdown

Shuts down your server after 5 minutes when nobody is tty'd in.

Starting it up again is your problem.

After startup, a 1 hour grace period is provided.

## Installation

Run this shell command on the target machine:

```
curl -s https://raw.githubusercontent.com/chriswa/ec2-inactivity-shutdown/main/install.sh | sudo bash
```

## Details

This script installs a systemd service which will run on every startup. The service monitors for logged in "psuedoterminal" users every 60 seconds using the command below.

```
who | grep -q 'pts/'
```

A shutdown timer is set for 1 hour when the service starts. If activity is detected, the shutdown timer is reset to 5 minutes.

## Caveats

### Short sessions can be missed by polling

If you tty in for less than 60 seconds, you may be missed by the activity detection mechanism, and therefore the shutdown timer may not be updated. This could result in the 1 hour grace period not being cancelled, or the 5 minute timer not being reset.
