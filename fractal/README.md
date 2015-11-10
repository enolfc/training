
# Manage VMs

You need to have defined in the environement:
- X509_USER_PROXY: your proxy 
- ENDPOINT: the OCCI endpoint for the site you are using
- OS_TPL: VM Image to use for the VM
- RES_TPL: size of the VM

It assumes public ssh-key is available at $PWD/fedcloudkey.pub

Get the context file:
```
curl -L https://raw.githubusercontent.com/enolfc/training/master/fractal/master-context.sh > master-context.sh
```

Create VM:
```
occi --endpoint $ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action create --resource compute \
     --mixin $OS_TPL --mixin $RES_TPL  \
     --attribute occi.core.title="fractal_master_$(date +%s)" \
     --context public_key="file:///$PWD/fedcloudkey.pub" \
     --context user_data="file:///$PWD/master-context.sh"
```

Set `COMPUTE_ID` to the identifier returned by the create command

## Describe the VM

```
occi --endpoint $ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action describe --resource $COMPUTE_ID
```

## Link to network

```
occi --endpoint $ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action link --resource $COMPUTE_ID \
     --link /network/public 
```

## Log in

Change <IP_ADDR> to the IP address of your VM:
```
ssh -i fedcloud ubuntu@<IP_ADDR>
```

Check things are running
```
sudo docker ps 
sudo docker logs faafo_api_1
```

Create new fractals:
```
sudo docker run --link faafo_api_1:faafo_api_1 egifedcloud/training-fractal \
	 faafo --endpoint-url http://faafo_api_1 create
```

## Worker VM

Get the context file:
```
curl -L https://raw.githubusercontent.com/enolfc/training/master/fractal/worker-context.sh > worker-context.sh
```

Edit the file and set the MASTER_HOST variable with the IP of the master

```
occi --endpoint $ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action create --resource compute \
     --mixin $OS_TPL --mixin $RES_TPL  \
     --attribute occi.core.title="fractal_master_$(date +%s)" \
     --context public_key="file:///$PWD/fedcloudkey.pub" \
     --context user_data="file:///$PWD/worker-context.sh"
```

Set `COMPUTE2_ID` to the return value of previous command

## Delete VMs

```
occi --endpoint $ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action delete --resource $COMPUTE_ID
occi --endpoint $ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action delete --resource $COMPUTE2_ID
```

# Sample configurations for the training sites
## CESNET
```
ENDPOINT="https://carach5.ics.muni.cz:11443"
OS_TPL="http://occi.carach5.ics.muni.cz/occi/infrastructure/os_tpl#uuid_training_fractal_docker_ubuntu_14_04_x86_64_fedcloud_warg_144"
RES_TPL="http://schema.fedcloud.egi.eu/occi/infrastructure/resource_tpl#small"
```

## BIFI
```
ENDPOINT="http://server4-epsh.unizar.es:8787"
OS_TPL="os_tpl#d9de116e-821c-4230-8a80-4744868541cb"
RES_TPL="resource_tpl#m1-tiny"
```
