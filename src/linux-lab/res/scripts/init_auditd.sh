if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    ID=$ID

    case $ID in
    ubuntu)
        echo "Installing auditd"
        sudo apt-get install -y auditd
        ;;
    centos)
        echo "Auditd is installed by default on centos"
        echo "disabling selinux"
        setenforce 0
        ;;
    *)
        echo "Not managed"
        exit 1
        ;;
    esac

    echo "Installing auditd rules"
    rm -rf /etc/audit/rules.d/*
    cp -f /vagrant/res/conf/auditd/*.rules /etc/audit/rules.d/
    echo "Restarting auditd"
    service auditd restart

else
    echo "Unknown linux version"
fi
