#!/bin/bash
#amneiht: setting enviromen
# -----------check enviroment
if [ -z ${MAX_PORT+x} ]
then
	echo " set max port"
	MAX_PORT=10900
fi

if [ -z ${MIN_PORT+x} ]
then
	echo " set min port"
	MIN_PORT=10000
fi

if [ -z ${IP_ADDRESS+x} ]
then
	echo "set ip addr"
	IP_ADDRESS="192.168.1.210"
fi

if [ -z ${SIP_PORT+x} ]
then
	SIP_PORT=5060
fi
if [ -z ${SIPS_PORT+x} ]
then
	SIPS_PORT=5061
fi
if [ -z ${SQL_PORT+x} ]
then
	SQL_PORT=3306
fi
if [ -z ${RTP_ADDRESS+x} ]
then
	RTP_ADDRESS=${IP_ADDRESS}
fi
#--------------------end check env-----------
rtpstart()
{
	RID=$(pgrep rtpproxy)
	if [ ! -z ${RID} ]
	then
		kill -9 ${RID}

	fi
	if [  "x$ENABLE_NAT" = "xtrue" ]
	then
		CONTROL_SOCK="udp:127.0.0.1:7722"
		EXTRA_OPTS="-l 0.0.0.0  -m ${MIN_PORT} -M ${MAX_PORT}"
		NAME=rtpproxy
		DAEMON=/usr/local/bin/$NAME
		PIDFILE="/var/run/$NAME/$NAME.pid"
		rm $PIDFILE
		$DAEMON -s $CONTROL_SOCK -u $NAME  -p $PIDFILE $EXTRA_OPTS
	fi
}
create_config()
{
	#copy config
	if [ ! -f /usr/local/etc/kamailio/kamailio.cfg ]
	then
		cp -r /tmp/backup/kamailio/* /usr/local/etc/kamailio
	fi

	LFILE=/usr/local/etc/kamailio/kamailio-local.cfg
	cat << EOF > ${LFILE}
#!define AM_DOMAIN "${IP_ADDRESS}"
#!define AM_SSLPORT ${SIPS_PORT}
#!define AM_PORT ${SIP_PORT}
#!define WITH_TLS
#!define RTP_ADDRESS "${RTP_ADDRESS}"
#!define WITH_MYSQL
#!trydef DBURL "mysql://kamailio:kamailiorw@127.0.0.1:${SQL_PORT}/kamailio"
EOF

	if [  "x$ENABLE_NAT" = "xtrue" ]
	then
		echo "#!define WITH_NAT" >> ${LFILE}
	fi
	if [  "x$ENABLE_AUTH" = "xtrue" ]
	then
		cat << EOF >> ${LFILE}
#!define WITH_AUTH
EOF
	fi
	
	cat << EOF > /usr/local/etc/kamailio/kamctlrc
SIP_DOMAIN=${IP_ADDRESS}
DBENGINE=MYSQL
DBHOST=127.0.0.1
DBPORT=${SQL_PORT}
DBNAME=kamailio
DBRWUSER="kamailio"
DBRWPW="kamailiorw"
DBROUSER="kamailioro"
DBROPW="kamailioro"
DBACCESSHOST=%
DBROOTUSER="root"
DBROOTPW="${DBPASS}"
CHARSET="latin1"
RPCFIFOPATH="/run/kamailio/kamailio_rpc.fifo"

INSTALL_PRESENCE_TABLES=no
INSTALL_EXTRA_TABLES=no
INSTALL_DBUID_TABLES=no

EOF
}
kamstart()
{	
	# disablle old run
	kamctl stop
	rm -rf /var/run/kamailio/*
	kamctl start
}
create_config
rtpstart
kamstart


sleep infinity