*This project has been created as part of the 42 curriculum by diwalaku.42.fr*

## Description
This project sets up a fully containerized WordPress website using MariaDB, PHP-FPM and NGINX.  
The goal is to allow anyone to deploy a ready-to-use WordPress website quickly using Docker. It needs to be secure, have separates services and configurations.

## Instructions
1. Clone the repository.
2. Open and log into the Virtual Machine.
3. Send the repository to the VM using: `rsync -Azr 'repository' -e 'ssh -p 2222' didi@localhost:/home/didi/Desktop/`.
	Don't use 'repository/`, because it'll send only the files in the directory to the VM, instead of the full directory.
4. On the VM Desktop, open VSCode (log in using the VM password).
5. Start the evaluation from the copied repository on the VM.

## Resources
- Official Docker docs: https://docs.docker.com/get-started/
- Nginx docs: https://nginx.org/en/docs/
- WordPress docs: https://developer.wordpress.org/
- Medium: https://medium.com/@ssterdev/inception-guide-42-project-part-i-7e3af15eb671
- YouTube: https://www.youtube.com/watch?v=_dfLOzuIg2o&t=92s
- Peers for guidance
- AI: Used to help explain new concepts and understand scripts. Also for writing comments short and clearly.

## Project Description and Choices

### Virtual Machine vs Docker
Docker is lightweight because it uses containers instead of full Virtual Machines.  
Containers start quickly, can run anywhere, and are isolated like mini Virtual Machines, without the high resource demands of a full Virtual Macine.

### Secrets vs Environment Variables
Secrets store sensitive information, such as database passwords and WordPress admin credentials in a secure directory.  
Environment variables in a `.env` file hold configuration data separately from the code.  
This allows different environments to run the same code by simply changing the `.env` file, without modifying the code itself.

### Docker Network vs Host Network
A Docker network allows containers to communicate securly within the project, without exposing port externally.
Each service can use the network name, instead of IP addresses.
The host network exposes container ports directly to the host machine, which makes it more secure.
Using a Docker network ensures service separation while the container can communication simple.

### Docker Volumes vs Bind Mounts
Docker volumes are managed by Docker and provide persistent storage for data like databases or WordPress files.  
In this project, our volumes are **named volumes with bind mounts**, meaning the actual data is stored in a specific host directory.  
This ensures persistent storage while keeping full control over the data location.  
It combines the portability and convenience of Docker volumes with the host access and backup flexibility of bind mounts.

### Choices
- I chose to also use `secrets/`, because I think it gives more security. It's great to have all needed information, such as passwords, securily so no one can just find it.
- I chose Debian, because it is very stable and beginner-friendly. It is larger and heavier than Alpine, but that needs more work and a bigger setup.
