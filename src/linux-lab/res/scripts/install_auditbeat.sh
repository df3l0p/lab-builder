if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    ID=$ID

    case $ID in
    ubuntu)
        echo "Installing auditbeat repo"
        wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
        sudo apt-get install apt-transport-https
        sudo cp -f /vagrant/res/conf/repo/elastic.list /etc/apt/sources.list.d/
        echo "Installing auditbeat"
        sudo apt-get update && sudo apt-get install -y auditbeat
        echo "Enabling auditbeat at statup"
        sudo update-rc.d auditbeat defaults 95 10
        ;;
    centos)
        echo "Installing auditbeat repo"
        sudo rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
        sudo cp -f /vagrant/res/conf/repo/elastic.repo /etc/yum.repos.d/
        echo "Installing auditbeat"
        sudo yum -y install auditbeat
        echo "Enabling auditbeat at statup"
        sudo chkconfig --add auditbeat
        ;;
    *)
        echo "Not managed"
        exit 1
        ;;
    esac

    echo "Installing auditd rules"
    sudo rm -rf /etc/auditbeat/audit.rules.d/*
    sudo cp -f /vagrant/res/conf/auditbeat/*.conf /etc/auditbeat/audit.rules.d/
    echo "Installing auditbeat configuration"
    sudo cp -f /vagrant/res/conf/auditbeat/auditbeat.yml /etc/auditbeat/
    echo "Stopping auditd"
    sudo service auditd stop
    echo "Starting auditbeat"
    sudo service auditbeat restart

else
    echo "Unknown linux version"
fi
