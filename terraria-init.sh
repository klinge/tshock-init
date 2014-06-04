#!/bin/bash
### BEGIN INIT INFO
# Provides:		terraria_server
# Required-Start:	$local_fs $remote_fs $network
# Required-Stop:	$local_fs $remote_fs $network
# Default-Start:	2 3 4 5
# Default-Stop:		0 1 6
# X-Interactive:	true
# Short-Description: Start/stop terraria_server
### END INIT INFO

DESC="TShock Terraria Server"
NAME=terraria_server
USERID=terraria
BINDIR=/home/terraria/bin
SCREENDAEMON=$(which screen)
MONODAEMON=$(which mono)
#MONODAEMON=$(which mono-sgen) # an experimental version of mono with a more efficient memory handler: apt-get install mono-sgen
DAEMON=${BINDIR}/TerrariaServer.exe
PIDFILE=${BINDIR}/tshock/tshock.pid
WORLDFILE=world1.wld
PORT=9999

# All important args for TerrariaServer.exe
DAEMONARGS="-ip 0.0.0.0 -port ${PORT} -world ${BINDIR}/Terraria/Worlds/${WORLDFILE} -maxplayers 8"

# Command sent to server to exit, try just "exit" to save world before exit. You WILL need to increase EXIT_TIMEOUT (try 30+)
EXIT_COMMAND="exit-nosave"
# wait X seconds for terraria to exit
EXIT_TIMEOUT=5

# Exit if not lib functions
[ -r /lib/lsb/init-functions ] || exit 0
. /lib/lsb/init-functions

# Exit if screen cant be found
[ -x "${SCREENDAEMON}" ] || exit 0
# Exit if mono cant be found
[ -x "${MONODAEMON}" ] || exit 0
# Exit if daemon cant be found
[ -r "${DAEMON}" ] || exit 0
# Exit if bin folder cant be found
[ -d "${BINDIR}" ] || exit 0

checkScreen() {
	if [ -e /var/run/screen/S-${USERID}/*.${NAME} ]; then return 0; fi
	return 1
}

checkPID() {
	if [ -e ${BINDIR}/tshock/tshock.pid ] && kill -0 $(cat ${PIDFILE} 2>/dev/null) > /dev/null 2>&1; then return 0; fi
	return 1
}

cd ${BINDIR}
case "$1" in
  start)
	log_daemon_msg "Starting ${DESC}" "${NAME}"
	EC=1
	if checkScreen || checkPID; then
	log_progress_msg "(already running)";
	else
		su ${USERID} -c "cd ${BINDIR}; ${SCREENDAEMON} -dmS ${NAME} ${MONODAEMON} ${DAEMON} ${DAEMONARGS}";
		# Wait up to 5 seconds for it to start
		for i in {0..5}; do
			if checkPID; then EC=0; break; fi # found running PID
			sleep 1
		done
	fi
	log_end_msg $EC
    ;;
  stop)
	log_daemon_msg "Stopping ${DESC}" "${NAME}"
	EC=1
	if ! checkScreen || ! checkPID; then
		log_progress_msg "(not running, or stale pidfile)"
	else
		# Use screen to stuff text to console
		su "${USERID}" -c 'screen -dr '${NAME}' -X stuff "'${EXIT_COMMAND}'$(printf \\r)"'
		# Wait for the process to end
		n=${EXIT_TIMEOUT}
		for (( i=0; i<n; i++ )); do
			if ! checkScreen; then EC=0; break; fi;
			sleep 1;
		done
		fi
	log_end_msg $EC
    ;;
  restart)
	$0 stop
	$0 start
    ;;
  connect)
	if checkScreen; then
		# Use script to bypass TTY issues
		su "${USERID}" -c "script -qc \"screen -dr ${NAME}\" /dev/null"
	else
		echo "${NAME}: Connect failed. (screen not running)"
	fi
    ;;

  *)
		echo "Usage: ${NAME} {start|stop|restart|connect}" 2>&1
		;;
esac
