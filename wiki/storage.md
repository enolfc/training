
# Storage
You need to have defined in the environement:
- X509_USER_PROXY: your proxy 
- OCCI_ENDPOINT: the OCCI endpoint for the site you are using
It assumes public ssh-key is available at ~/$HOME/.ssh/id_rsa.pub


## Create
occi --endpoint $OCCI_ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action create --resource storage \
     --attribute occi.core.title="wiki" \
     --attribute occi.storage.size='num(1)' 

set STORAGE_ID to the id returned from previous command 

## Describe the Volume

occi --endpoint $OCCI_ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action describe --resource $STORAGE_ID

## Link to VM

occi --endpoint $ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action link --resource $COMPUTE_ID --link $STORAGE_ID 

Details of the link can be gathered with a describe to the COMPUTE_ID

occi --endpoint $ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action describe --resource $COMPUTE_ID

## Use the volume at VM

DEVICE_ID is the devude where the volume is available (check describe output)

First time a volume is used, you need to create a filesystem
sudo mkfs.ext3 $DEVICE_ID

Mount the volume and copy wiki contents there
sudo mount $DEVICE_ID /mnt
sudo service apache2 stop 
sudo cp -a /org/mywiki /mnt
sudo umount /mnt

Mount the volume where the wiki is expecting to find contents
sudo mount $DEVICE_ID /org
sudo service apache2 start

## Delete the Volume

occi --endpoint $OCCI_ENDPOINT --auth x509 --user-cred $X509_USER_PROXY --voms \
     --action delete --resource $STORAGE_ID

