#!/bin/bash

echo "********* Doing Web Tools clone ******************************\n\n"

sudo git clone "https://github.com/supr4s/WebHackingTools.git"

echo "********* Done cloning Web Tools  ******************************\n\n"

echo "********* Doing F.T.W clone ******************************\n\n"

sudo git clone "https://github.com/six2dez/reconftw.git"

echo "********* Doing F.T.W cloning ******************************\n\n"

cd WebHackingTools

echo "********* installing Web Tools  ******************************\n\n"

sudo ./installer.sh 

echo "********* Done installing Web Tools  ******************************\n\n"

cd ..

cd reconftw

echo "********* installing F.T.W  ******************************\n\n"

sudo sudo ./install.sh 

echo "********* Done installing F.T.W ******************************\n\n"

echo "****************** Installing Naabu *********************************************"

sudo go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest

echo "****************** Done Installing Naabu *********************************************"


echo "****************** Installing Katana *********************************************"

go install github.com/projectdiscovery/katana/cmd/katana@latest

echo "****************** Done Installing Katana *********************************************"


echo "****************** Installing DNS Validator *********************************************"

sudo git clone "https://github.com/vortexau/dnsvalidator.git"

cd dnsvalidator 

sudo python3 setup.py install
dnsvalidator -tL https://public-dns.info/nameservers.txt -threads 20 -o resolvers.txt
sudo mv resolvers.txt /root/
echo "****************** Done Installing DNS Validator *********************************************"

