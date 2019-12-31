USER="{{ansible_user}}"
#!/bin/bash
function create_sudo_user(){
    # Create user and puts it in sudo group
    # param $1: name of the user

    # handle sudo group name
    cat /etc/os-release | grep -i "debian" 2>& 1 > /dev/null
    if [ $? -eq 0 ]; then
        group="sudo"
    else
        group="wheel"
    fi

    echo "[+] adding user: $1"
    useradd -s /bin/bash -m $1 -G $group
}


function setup_sudoers_for_user(){
    # Create nopasswd sudoers permission for user
    # param $1: the user to create the sudoers config file

    echo "[+] creating sudo file: /etc/sudoers.d/$1"
    echo "$1 ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$1
}

create_sudo_user $USER
setup_sudoers_for_user $USER