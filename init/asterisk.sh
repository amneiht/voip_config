#!/bin/sh
if [ ! -f /etc/asterisk/extensions.conf ]
then
	cp -r /root/asterisk/*  /etc/asterisk
fi
#tao config
cat << EOF > /etc/asterisk/iax.conf
[general]
bindaddr=0.0.0.0
jitterbuffer=no
calltokenoptional=0.0.0.0/0.0.0.0
requirecalltoken=no
maxcallnumbers=16382

[iaxuser](!)
type=friend
context=voice
host=dynamic
allow=!all,gsm
qualify=yes
transfer=yes
dtmfmode=auto

#tryinclude "iax_user.conf"
EOF
#edit extenson.conf
cat << EOF > /etc/asterisk/extensions.conf
[general]
static = yes
writeprotect = no
clearglobalvars = yes
requirecalltoken = no
maxcallnumbers = 16382

#tryinclude "dialplan.conf"
EOF

if [ ! -f /tmp/config/iax_user.conf ]
then 
cat << EOF > /tmp/config/iax_user.conf
; using [iaxuser] template
; example
; [<user>](iaxuser)
; username=<username>
; secret=<your password>

; demo user

[00001](iaxuser)
username=00001
secret=kfdjbssosdfwe

EOF

fi

if [ ! -f /tmp/config/dialplan.conf ]
then 
   cat << EOF  > /tmp/config/dialplan.conf
;using [voice] context
[voice]
exten => _XXX,1,Answer()
 same => n,Dial(IAX2/\${EXTEN})

EOF
fi
ln -s /tmp/config/iax_user.conf /etc/asterisk/iax_user.conf
ln -s /tmp/config/dialplan.conf /etc/asterisk/dialplan.conf

/etc/init.d/asterisk stop
rm -rf /var/run/asterisk/*
asterisk
sleep infinity
bash
