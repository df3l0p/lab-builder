# Using the vagrant environment
1. Connect to ansible host
```bash
vagrant ssh ansible
```
2. Switch to ansible user (default: ansible)
```bash
sudo su - ansible
```
3. execute ansible commands
```bash
cd /vagrant/res/playbooks
```


# Using the docker environment
In addition to the vagrant environment, a docker environment can be used.
To do so, execute the `deploy-docker.sh` script.

Create n containers
```bash
deploy-docker.sh --create n
```

Start containers
```bash
deploy-docker.sh --start
```

Drop containers
```bash
deploy-docker.sh --drop
```
