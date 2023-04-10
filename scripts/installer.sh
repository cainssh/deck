#!/bin/bash
PACKAGE_NAME="multipass"
PACKAGE_URL="https://github.com/canonical/multipass/releases/download/v1.8.1/multipass-1.8.1+mac-Darwin.pkg"
VM_NAME="deck-app"
VM_CPUS=4
VM_DISK_SIZE="10G"
VM_MEMORY="4G"


function install_package {
    echo "Installing $PACKAGE_NAME, this will take a few seconds ..."
    curl -L -C - $PACKAGE_URL --output /tmp/$PACKAGE_NAME.pkg
    sudo installer -pkg /tmp/$PACKAGE_NAME.pkg -target /Applications
}

function create_vm {
    echo "Creating a lightweight Ubuntu VM, this will take a few minutes ..."
    multipass launch --name $VM_NAME -c $VM_CPUS -d $VM_DISK_SIZE -m $VM_MEMORY
    multipass umount $VM_NAME
}

function configure_vm {
    echo "Configuring VM settings ..."
    multipass set client.primary-name=$VM_NAME
    multipass set client.gui.autostart=false
}

function install_docker {
    echo "Installing Docker on VM ..."
    multipass exec $VM_NAME -- bash -c "curl https://raw.githubusercontent.com/deck-app/multipass-install/master/multipass-install.sh | sh"
}

function configure_nfs {
    echo "Configuring NFS settings ..."
    multipass exec $VM_NAME -- bash -c "mkdir -p /home/ubuntu/`whoami` && sudo touch /etc/auto.projects && 
                                    sudo chown `multipass exec $VM_NAME whoami`:`multipass exec $VM_NAME whoami` /etc/auto.projects && 
                                    echo /home/ubuntu/`whoami` -fstype=nfs,rw,nolock,nosuid,proto=tcp,resvport `ifconfig -l | xargs -n1 ipconfig getifaddr`:/Users/`whoami` | tee /etc/auto.projects"
}


if [ "$(which $PACKAGE_NAME)" == "" ]; then
    install_package
else
    echo "Skipping download, $PACKAGE_NAME is already installed."
fi

while [ ! -S /var/run/multipass_socket ]; do
    sleep 1
done

create_vm

configure_vm

install_docker

configure_nfs

# Done!
echo "Script execution complete."
