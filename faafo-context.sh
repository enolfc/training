#!/usr/bin/env bash
apt-get -y install curl
curl -L -s https://git.openstack.org/cgit/stackforge/faafo/plain/contrib/install.sh | bash -s -- \
        -i faafo -i messaging -r api -r worker -r demo
