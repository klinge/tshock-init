## Terraria (Tshock) startup script for Linux

Init script for the Tshock Terrara server on Debian(-like) Linux. Also works on Ubuntu. 

I have also used this with modification to start a minecraft server. 

Based on example from [nooblet.org] (http://www.nooblet.org/blog/2013/installing-tshock-terraria-server-on-debian-wheezy/)

### Features
SysV-style init script for a terraria server. 

- Support standard start/stop/restart commands
- Starts the server in a screen session
- Also has a nice "connect" command to connect to screen bypassing tty issues

### Known bugs/problems

1. The stop command returns an error
2. 