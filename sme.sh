#!/bin/bash

#public testnet v2

###################################
#  Tuku.dev smesh install script  #
###################################
#       ...    *    .   _  .      #
#    *  .  *     .   * (_)   *    #
#      .      |*  ..   *   ..     #
#       .  * \|  *  ___  . . *    #
#    *   \/   |/ \/{o,o}     .    #
#      _\_\   |  / /)  )* _/_ *   #
#          \ \| /,--"-"---  ..    #
#    _-----`  |(,__,__/__/_ .     #
#           \ ||      ..          #
#            ||| .            *   #
#            |||                  #
#    ejm98   |||                  #
#      , -=-~' .-^- _             #
#               `                 #
###################################
## meant to be run as root user ###
##### on ubuntu 18.04.3 only ######
###################################

#ansible: systemctl stop smesh.service

#cleanup: delete post and spacemesh if found
if [ -d /root/post ]; then
rm -rf /root/post
fi

if [ -d /root/spacemesh ]; then
rm -rf /root/spacemesh
fi

if [ -d /root/go-spacemesh-0.1.3 ]; then
rm -rf /root/go-spacemesh-0.1.3
fi

#install: get smeshbin and make dirs
    if [ ! -d /root/smesh18-2 ]; then
mkdir /root/smesh18-2
wget http://tuku.blue/go-spacemesh-v0.1.8-linux -O /root/smesh18-2/go-spacemesh-v0.1.8-linux
chmod +x /root/smesh18-2/go-spacemesh-v0.1.8-linux

if [ ! -d /root/smesh18-2/sm_data ]; then
mkdir /root/smesh18-2/sm_data
fi

if [ ! -d /root/smesh18-2/post_data ]; then
mkdir /root/smesh18-2/post_data
fi

if [ ! -d /root/smeshlogs/ ]; then
mkdir /root/smeshlogs/
touch /root/smeshlogs/log_file
touch /root/smeshlogs/err_file
fi
echo "spacemesh installed" >> /root/tuku.log
    fi

echo "spacemesh installed, configuring it now"
wget http://ae7809a90692211ea8d4d0ea80dce922-597797094.us-east-1.elb.amazonaws.com/ -O /root/smesh18-2/smeshtest.toml

if [ ! -f /etc/rsyslog.d/smeshlog.conf ]; then
OUTFILE=/etc/rsyslog.d/smeshlog.conf
(
cat << 'EOF'
if $programname == 'smeshlog' then /var/log/smesh.log
& stop
EOF
) > $OUTFILE
fi

if [ ! -f /lib/systemd/system/smesh.service ]; then
rm /lib/systemd/system/smesh.service
fi

cat > /lib/systemd/system/smesh.service << EOF
[Unit]
Description="smesh"

[Service]
User=root
Group=root
ExecStart=/root/smesh18-2/go-spacemesh-v0.1.8-linux --grpc-server --json-server --acquire-port=false --tcp-port 7152 --config /root/smesh18-2/smeshtest.toml -d /root/smesh18-2/sm_data --coinbase <your address here> --start-mining --post-datadir /root/smesh18-2/post_data
Restart=always
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=smeshlog

[Install]
WantedBy=multi-user.target
EOF

ufw allow out 7152
ufw allow in 7152
ufw reload

systemctl daemon-reload
sudo systemctl restart rsyslog
systemctl enable smesh.service
systemctl start smesh.service

echo "spacemesh configured and started" >> /root/tuku.log
echo "spacemesh configured, running it now"
