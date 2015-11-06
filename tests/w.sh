#ENDPOINT=https://prisma-cloud.ba.infn.it:8787/

# this is taken from AppDB
#OS_TPL="os_tpl#05efe4ef-e1a9-4ab8-a823-8b95b48d33f3"
#RES_TPL="resource_tpl#1cpu-512mb-25dsk"


set -v
outfile=`mktemp`
# the | tee is to capture the output and analyse it within the script
# it's not needed to normally execute this

# check VOMS information
voms-proxy-info -all

# defining variables
#. ifca-vars.sh
#. bifi-vars.sh
. cesnet-vars.sh

# create my ssh-key (parameters used to use it into this script)
[ -f ~/.ssh/id_rsa ] || ssh-keygen -N "" -f ~/.ssh/id_rsa

# create the VM
occi --endpoint $ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action create --resource compute \
     --mixin $OS_TPL --mixin $RES_TPL  \
     --attribute occi.core.title="wiki" \
     --context public_key="file:///$HOME/.ssh/id_rsa.pub" | tee $outfile

COMPUTE_ID=`cat $outfile`

# sleep 30s
# Describe the VM
occi --endpoint $ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action describe --resource $COMPUTE_ID | tee $outfile

# Get the IP from the description
PRIVATE_IP_ADDR=`cat $outfile | grep occi.networkinterface.address | cut -f2 -d"=" | tr -d " "`

if [ "x$USE_PUBLIC_IP" == "x1" ]; then
	echo "(private) IP address of the VM: $PRIVATE_IP_ADDR"
	# sleep a bit to assign the public ip
	sleep 2m
	occi --endpoint $ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     	     --action link --resource $COMPUTE_ID --link /network/public | tee $outfile

	NETWORK_ID=`cat $outfile`
	occi --endpoint $ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     	     --action describe --resource $NETWORK_ID  | tee $outfile

	# Get the IP from the description
	IP_ADDR=`cat $outfile | grep occi.networkinterface.address | cut -f2 -d"=" | tr -d " "`
else
	IP_ADDR=$PRIVATE_IP_ADDR
fi

echo "IP address of the VM: $IP_ADDR"

# Sleeping just to be sure that things will be up 
# In the meantime go to the wiki and edit the front page
sleep 2m

# Options to avoid again asking anything in the script
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@$IP_ADDR \
	cat /org/mywiki/data/edit-log

# Show the VM Size
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@$IP_ADDR \
	cat /proc/cpuinfo
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@$IP_ADDR \
	cat /proc/meminfo


# Block storage addition
occi --endpoint $ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action create --resource storage \
     --attribute occi.core.title="wiki" \
     --attribute occi.storage.size='num(1)' | tee $outfile

STORAGE_ID=`cat $outfile`

# Describe the storage
occi --endpoint $ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action describe --resource $STORAGE_ID 

# Link to the VM
occi --endpoint $ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action link --resource $COMPUTE_ID --link $STORAGE_ID | tee $outfile
LINK_ID=`cat $outfile`

# Describe the link and get the device where the disk is found
occi --endpoint $ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action describe --resource $LINK_ID | tee $outfile

DEVICE_ID=`cat $outfile | grep occi.storagelink.deviceid | cut -f2 -d"=" | tr -d " "`
echo "Volume is at $DEVICE_ID"

# Do the volume thing in a single command
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@$IP_ADDR \
	"sudo mkfs.ext3 $DEVICE_ID && sudo mount $DEVICE_ID /mnt && sudo service apache2 stop && \
	 sudo cp -a /org/mywiki /mnt && sudo umount /mnt && sudo mount $DEVICE_ID /org && \
	 sudo service apache2 start"

# Go and edit again the wiki
sleep 5m 

# Umount the volume
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@$IP_ADDR \
	sudo umount /org

# Clean up: remove the volume
occi --endpoint $ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action delete --resource $LINK_ID

# and delete VM
occi --endpoint $ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action delete --resource $COMPUTE_ID

# Creating a new VM, this time with the link 
occi --endpoint $ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action create --resource compute \
     --mixin $OS_TPL --mixin $RES_TPL  \
     --attribute occi.core.title="wiki" \
     --link $STORAGE_ID \
     --context public_key="file:///$HOME/.ssh/id_rsa.pub" | tee $outfile

COMPUTE_ID=`cat $outfile`

occi --endpoint $ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action describe --resource $COMPUTE_ID | tee $outfile

# Get the IP from the description
PRIVATE_IP_ADDR=`cat $outfile | grep occi.networkinterface.address | cut -f2 -d"=" | tr -d " "`

if [ "x$USE_PUBLIC_IP" == "x1" ]; then
	echo "(private) IP address of the VM: $PRIVATE_IP_ADDR"
	# sleep a bit to assign the public ip
	sleep 2m
	occi --endpoint $ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     	     --action link --resource $COMPUTE_ID --link /network/public | tee $outfile

	NETWORK_ID=`cat $outfile`
	occi --endpoint $ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     	     --action describe --resource $NETWORK_ID  | tee $outfile

	# Get the IP from the description
	IP_ADDR=`cat $outfile | grep occi.networkinterface.address | cut -f2 -d"=" | tr -d " "`
else
	IP_ADDR=$PRIVATE_IP_ADDR
fi

echo "IP address of the VM: $IP_ADDR"

# Also get the DEVICE_ID
DEVICE_ID=`cat $outfile | grep occi.storagelink.deviceid | cut -f2 -d"=" | tr -d " "`
echo "Volume is at $DEVICE_ID"

# wait a bit for the VM to be up
sleep 5m

# Do the volume thing in a single command
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@$IP_ADDR \
	"sudo service apache2 stop && sudo mount $DEVICE_ID /org && sudo service apache2 start"

# check again your wiki
sleep 2m

# Delete 
occi --endpoint $ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action delete --resource $COMPUTE_ID

occi --endpoint $ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action delete --resource $STORAGE_ID
