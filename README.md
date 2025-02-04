# devsecops-series

# k8s based DevSecOps playground

Hello everyone! I started to write a blog about DevSecOps walkthrough, which includes a local DevOps + Security Tools environment.

## Components (yet)
```
SCM: GitLab
CI/CD: Jenkins
Image Repository: Nexus 
Ticketing: Jira Free Version
Kubernetes distribution: k3s 
Target Application: DVJA - Damn Vulnerable Java Application 
```

## Tested Environment (Unstable atm, need to fine-tune the yaml files) 
```
CPU: AMD Ryzen 9 5900X (24) @ 5.619GHz 
Memory: 23909MiB 
Swap: 4GB 
OS: ArchLinux 6.12.4-zen1-1-zen
Terminal: 5.2.37 
Docker version 27.3.1, build ce1223035a 
k3s version v1.31.3+k3s1 (6e6af988)
go version go1.22.8
```

# IMPORTANT WARNING

ATTENTION! `The configurations will make your machine vulnerable`.

All configurations are done in order to setup the environment with easiness. You should take notes what you changed, no responsibilities are
taken if you break something, you warned...

# Repository Explained

1) `./scripts/change_hosts_file.sh` - This script will overwrite your `/etc/hosts/` file with new IPs of applications, run the script whenever you add a new tool!
2) `./scripts/create_directories.sh` - [ VULNERABLE CONFIG ] This script will create persistent directories for each tool.
3) `./yamls/basic/` - This directory has the minimal DevOps setup. You can deploy this setup with `sudo k3s kubectl apply -f ./base_yamls/`. The detailed installation steps are in the second blog.
4) `./yamls/app/deployment.yaml` - You should put this deployment configuration file into your local copy of `dvja`, which is also located at your local GitLab instance.
5) `./jenkinsfiles/Jenkinsfile.basic` - This Jenkinsfile configuration has the minimal CI/CD steps. Which are; `Pull Code` -> `Build Code` -> `Create Docker Image` -> `Push Docker Image` -> `Deploy` 

## Series 

1) [DevSecOps Series - Introduction](https://devilinside.me/blogs/devsecops-series-introduction)
2) [My First Pipeline - the Simple DevOps Environment]()


## Basic Troubleshooting

### The Most Probable Problems:

* `/var/run/docker.sock` must be there all operations before, start your docker daemon first!

    * VULNERABLE ADVICE: you can also run `sudo chmod 777 /var/run/docker.sock` to work without root.

    * BETTER: add yourself to docker group to work with daemon. 

* HTTP response for HTTPS service 

You have to define insecure-registries both in `/etc/rancher/k3s/registries.yaml` and `/etc/docker/daemon.json` 
Check your nexus.local entry `/etc/hosts` and refresh it with change_hosts_file.sh (you can delete /etc/hosts if needed) 

* Domains in jenkins steps 
Domains are just for requests from docker.sock and yourself, `/etc/hosts` rows are not valid for the pods, watch out. 

* If you are in doubt just erase all of them and start again:
	`$ sudo k3s kubectl delete -f base_yamls/` 

* Jenkins Plugins are important, check again if something is broken or not found.

*  Check your credentials if they are saved correctly

Used Credentials;

	1) One private key for the SSH connection (Jenkins)
	2) One private key for the Git SSH (Jenkins)
	3) One user:passwd for the nexus login (Jenkins)
	4) One nexus kubectl secret docker-registry, configured from the CLI 

* Check Jenkins Plugins

    1) Docker API Plugin 
    2) Docker Commons Plugin 
    3) Docker Pipeline 
    4) Docker plugin 
    5) Config File Provider Plugin 
    6) Maven Integration plugin 
    7) Pipeline Maven Integration Plugin
    8) Pipeline Maven Plugin API 
    10) SSH Agent 

* Delete the deployed DVJA before new build: 

	`$ sudo k3s kubectl delete -f /tmp/deployment.yaml # from your host machine` 

* If something is broken, and you would like to setup it again you can seperately delete them too!

```
	$ sudo k3s kubectl delete -f base_yamls/nexus-deployment.yaml  
	$ sudo k3s kubectl delete -f base_yamls/nexus-data-persistentvolumeclaim.yaml  
	$ sudo k3s kubectl delete -f base_yamls/nexus-service.yaml  
```

* You cant commit something or pull:

Just edit `~/.ssh/config`:

```
Host gitlab.local 
	HostName gitlab.local 
	Port 2222
	User git
```
* Add `yamls/app/deployment.yaml` file into local dvja's repository.
* Also add the `nexus_pass` secret to login nexus from the host itself.

    `$ sudo k3s kubectl create secret docker-registry nexus_pass --docker-server=nexus.local:8082 --docker-username=admin --docker-password='wowsuchchar8!'`


