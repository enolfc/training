
# Manage VMs

You need to have defined in the environement:
- `X509_USER_PROXY`: your proxy
- `OCCI_ENDPOINT`: the OCCI endpoint for the site you are using
- `OS_TPL`: VM Image to use for the VM
- `RES_TPL`: size of the VM

It assumes public ssh-key is available at `$HOME/.ssh/id_rsa.pub`

```
occi --endpoint $OCCI_ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action create --resource compute \
     --mixin $OS_TPL --mixin $RES_TPL  \
     --attribute occi.core.title="wiki_$(date +%s)" \
     --context public_key="file:///$HOME/.ssh/id_rsa.pub"
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

Check the size of VM:
```
cat /proc/cpuinfo
cat /proc/meminfo
```
Check the wiki is being edited:
```
cat /org/mywiki/data/edit-log
```

## Delete VM

```
occi --endpoint $OCCI_ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action delete --resource $COMPUTE_ID
```

# Storage

## Create
 ```
occi --endpoint $OCCI_ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action create --resource storage \
     --attribute occi.core.title="wikidata_$(date +%s)" \
     --attribute occi.storage.size='num(1)'
```

set `STORAGE_ID` to the id returned from previous command

## Describe the Volume

```
occi --endpoint $OCCI_ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action describe --resource $STORAGE_ID
```

## Link to VM

```
occi --endpoint $ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action link --resource $COMPUTE_ID --link $STORAGE_ID
```

Details of the link can be gathered with a describe to the `COMPUTE_ID`

```
occi --endpoint $ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action describe --resource $COMPUTE_ID
```

## Use the volume at VM

`DEVICE_ID` is the device where the volume is available (check describe output)

First time a volume is used, you need to create a filesystem
```
sudo mkfs.ext3 $DEVICE_ID
```

Mount the volume and copy wiki contents there
```
sudo mount $DEVICE_ID /mnt
sudo service apache2 stop
sudo cp -a /org/mywiki /mnt
sudo umount /mnt
```

Mount the volume where the wiki is expecting to find contents
```
sudo mount $DEVICE_ID /org
sudo service apache2 start
```

Reusing the volume at another VM:
```
sudo service apache2 stop
sudo mount $DEVICE_ID /org
sudo service apache2 start
```

## Delete the Volume

```
occi --endpoint $OCCI_ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action delete --resource $STORAGE_ID
```



# Sample configurations for the training sites
## CESNET
```
OCCI_ENDPOINT="https://carach5.ics.muni.cz:11443"
OS_TPL="http://occi.carach5.ics.muni.cz/occi/infrastructure/os_tpl#uuid_training_moinmoinwiki_fedcloud_warg_126"
RES_TPL="http://schema.fedcloud.egi.eu/occi/infrastructure/resource_tpl#small"
```

## BIFI
```
OCCI_ENDPOINT="http://server4-epsh.unizar.es:8787"
OS_TPL="os_tpl#46c6da01-e2cc-48f2-a283-c961f8dee35d"
RES_TPL="resource_tpl#m1-tiny"
```

## UKIM
```
OCCI_ENDPOINT="https://occi.nebula.finki.ukim.mk:443"
OS_TPL="os_tpl#uuid_wiki_ubuntu_14_04_training_168"
RES_TPL="resource_tpl#small"
```

## CIEMAT
```
OCCI_ENDPOINT="https://controller.ceta-ciemat.es:8787/"
OS_TPL="os_tpl#4162c10c-82ab-462a-9d54-67253e9d8d92"
RES_TPL="resource_tpl#m1-tiny"
```
