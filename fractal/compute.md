
# Manage VMs

You need to have defined in the environement:
- X509_USER_PROXY: your proxy 
- OCCI_ENDPOINT: the OCCI endpoint for the site you are using
- OS_TPL: VM Image to use for the VM
- RES_TPL: size of the VM

It assumes public ssh-key is available at ~/$HOME/.ssh/id_rsa.pub

Get the context file:
```
curl > master-context.sh
```

Create VM:
```
occi --endpoint $OCCI_ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action create --resource compute \
     --mixin $OS_TPL --mixin $RES_TPL  \
     --attribute occi.core.title="fractal_master_$(date +%s)" \
     --context public_key="file:///$HOME/.ssh/id_rsa.pub"
     --context user_data="file:///$PWD/master-context.sh"
```

Set `COMPUTE_ID` to the identifier returned by the create command

## Describe the VM

```
occi --endpoint $OCCI_ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action describe --resource $COMPUTE_ID
```

## Link to network

```
occi --endpoint $OCCI_ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action link --resource $COMPUTE_ID \
     --link /network/public 
```

## Log in

Change <IP_ADDR> to the IP address of your VM:
```
ssh ubuntu@<IP_ADDR>
```

Check things are running
```
sudo docker ps 
sudo docker logs faafo_api_1
```

## Worker VM

Get the context file:
```
curl -L > worker-context.sh
```

Edit the file and set the MASTER_HOST variable with the IP of the master

```
occi --endpoint $OCCI_ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action create --resource compute \
     --mixin $OS_TPL --mixin $RES_TPL  \
     --attribute occi.core.title="fractal_master_$(date +%s)" \
     --context public_key="file:///$HOME/.ssh/id_rsa.pub"
     --context user_data="file:///$PWD/worker-context.sh"
```

Set `COMPUTE2_ID` to the return value of previous command

## Delete VMs

```
occi --endpoint $OCCI_ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action delete --resource $COMPUTE_ID
occi --endpoint $OCCI_ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action delete --resource $COMPUTE2_ID
```

# Sample configurations for the training sites
## CESNET
OCCI_ENDPOINT="https://carach5.ics.muni.cz:11443"
OS_TPL="http://occi.carach5.ics.muni.cz/occi/infrastructure/os_tpl#uuid_training_fractal_docker_ubuntu_14_04_x86_64_fedcloud_warg_144"
RES_TPL="http://schema.fedcloud.egi.eu/occi/infrastructure/resource_tpl#small"

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




