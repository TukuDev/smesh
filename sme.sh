#!/bin/bash

###################################
## Tuku.dev smesh install script ##
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
# made for ubuntu 18.04 or similar#
###################################

# v1 - ffnet 002

apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -yq

touch /root/tuku.log

echo "installing golang"

wget https://dl.google.com/go/go1.14.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.14.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
cat >> /etc/profile<< EOF
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
EOF

mkdir ~/go
echo "GOPATH=$HOME/go" >> ~/.bashrc
echo "export GOPATH" >> ~/.bashrc
echo "PATH=\$PATH:\$GOPATH/bin # Add GOPATH/bin to PATH for scripting" >> ~/.bashrc
source ~/.bashrc

echo "golang installed" >> /root/tuku.log
echo "golang installed, installing spacemesh"

wget https://github.com/spacemeshos/go-spacemesh/archive/v0.1.3.tar.gz
tar -xvf v0.1.3.tar.gz
cd go-spacemesh-0.1.3
rm go.mod
/usr/local/go/bin/go mod init github.com/spacemeshos/go-spacemesh
go mod tidy
make install
make build

echo "spacemesh installed" >> /root/tuku.log
echo "spacemesh installed, configuring it now"

cd /root/go-spacemesh-0.1.3/build
wget http://a95220c1e575811eaa61112de75eb21f-1178855954.us-east-1.elb.amazonaws.com/ -O tnff2.toml

ls

cat > /lib/systemd/system/smesh.service << EOF
[Unit]
Description="smesh"

[Service]
User=root
Group=root
Type=simple
WorkingDirectory=/root/go-spacemesh-0.1.3/build/
ExecStart=/root/go-spacemesh-0.1.3/build/go-spacemesh --grpc-server --randcon 0 --json-server --tcp-port 7152 --config tnff2.toml -d sm_data --coinbase 0x9974281b073b1EAB3d0318a7219C1d71f42912ec --start-mining --post-datadir post_data

Restart=always

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable smesh.service
systemctl start smesh.service

echo "spacemesh configured and started" >> /root/tuku.log
echo "spacemesh configured, running it now"

