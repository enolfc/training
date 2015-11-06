#!/bin/sh


set -v

echo $OS_TPL
echo $RES_TPL
echo $OCCI_ENDPOINT

export USE_PUBLIC_IP=1

outfile=`mktemp`


[ -f fedcloudkey ] || ssh-keygen -N "" -f fedcloudkey

./occi --action create --resource compute \
       --mixin $OS_TPL --mixin $RES_TPL  \
       --attribute occi.core.title="wiki" \
       --context public_key="file:///data/fedcloudkey.pub" | tee $outfile

set -- $(echo $(cat $outfile))
COMPUTE_ID=$1

sleep 30s
# Describe the VM
./occi --action describe --resource $COMPUTE_ID | tee $outfile

# Get the IP from the description
PRIVATE_IP_ADDR=$(cat $outfile | grep occi.networkinterface.address | cut -f2 -d"=" | tr -d " ")

if [ "x$USE_PUBLIC_IP" = "x1" ]; then
    echo "(private) IP address of the VM: $PRIVATE_IP_ADDR"
    # sleep a bit to assign the public ip
    sleep 2m
    ./occi --action link --resource $COMPUTE_ID --link /network/public | tee $outfile

    set -- $(cat $outfile)
    NETWORK_ID=$1
    ./occi --action describe --resource $NETWORK_ID  | tee $outfile

    # Get the IP from the description
    IP_ADDR=$(cat $outfile | grep occi.networkinterface.address | cut -f2 -d"=" | tr -d " ")
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

./occi --action delete --resource $COMPUTE_ID

rm $outfile
