
# Manage VMs

You need to have defined in the environement:
- X509_USER_PROXY: your proxy 
- OCCI_ENDPOINT: the OCCI endpoint for the site you are using
- OS_TPL: VM Image to use for the VM
- RES_TPL: size of the VM
It assumes public ssh-key is available at ~/$HOME/.ssh/id_rsa.pub

occi --endpoint $OCCI_ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action create --resource compute \
     --mixin $OS_TPL --mixin $RES_TPL  \
     --attribute occi.core.title="wiki" \
     --context public_key="file:///$HOME/.ssh/id_rsa.pub"

Set COMPUTE_ID to the identifier returned by the create command

## Describe the VM

occi --endpoint $OCCI_ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action describe --resource $COMPUTE_ID

## Link to network

occi --endpoint $OCCI_ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action link --resource $COMPUTE_ID \
     --link /network/public 

## Log in

Change <IP_ADDR> to the IP address of your VM:

ssh ubuntu@<IP_ADDR>

Check the size of VM:
cat /proc/cpuinfo
cat /proc/meminfo

Check the wiki is being edited:
cat /org/mywiki/data/edit-log

## Delete VM

occi --endpoint $OCCI_ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action delete --resource $COMPUTE_ID


# Sample configurations for the training sites
## CESNET
OCCI_ENDPOINT="https://carach5.ics.muni.cz:11443"
OS_TPL=""
RES_TPL=""

## BIFI
OCCI_ENDPOINT=
OS_TPL=""
RES_TPL=""

## UKIM
OCCI_ENDPOINT=
OS_TPL=""
RES_TPL=""

## CIEMAT
OCCI_ENDPOINT=
OS_TPL=""
RES_TPL=""

## CATANIA




