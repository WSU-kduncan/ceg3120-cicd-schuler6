# Project 5 

# Continuous Deployment Project Overview  

##  Project Goal
The goal of this Continuous Deployment (CD) project is to automate the process of building, tagging, publishing, and deploying a Docker Angular application to an EC2 instance. Whenever a semantic version tag is pushed to GitHub, the system automatically builds a new image, uploads it to DockerHub, and redeploys the updated container on an EC2 instance.  

## Tools & Their Roles  
GitHub Actions - Automates CI/CD pipeline and triggers workflows on version tags  
Docker - Containerizes the Angular app for portability and deployment  
DockerHub - Hosts and distributes container images  
EC2 (AWS) - Hosts production server for running the deployed container  
webhook (adnanh) - Listens for GitHub payloads and triggers container refresh  
systemd - Ensures webhook runs as a background service on EC2  

## Documentation  

### Part 1 - Semantic Versioning  

### Tags in Github  
To see tags in a git repository run `git tag`  
To generate a version controlled tag run `git tag -a v1.0.0 -m "Release version 1.0.0"` (replace with current verion)  
Use semantic versioning format which is `v<MAJOR>.<MINOR>.<PATCH>`  
To push a tag to Github run `git push origin v1.0.0`  

### Workflow Summary  
Workflow is triggered on a `push` of the tag  
This builds a Docker image of the app     
This also pushes 4 semantic version tags to Dockerhub  (e.g. latest, vMAJOR, vMINOR, and vPATCH)  

### Workflow Steps  
1. Checkout the code with Github Actions to pull the latest state of the repository  
2. Set up Docker with DockerHub credentials using Github Secrets  
3. Extract version metadata from the Git tag  
4. Build Docker image and tag it as:  
  -latest (the newest image)  
  -vMAJOR  (v1)   
  -vMAJOR.MINOR  (v1.0)  
  -vMAJOR.MINOR.PATCH  (v1.0.0)  
5. Push all tags to DockerHub  
6. Send webhook to your production server to refresh the running container.  

### If reusing this workflow on another repository you must update:  
* `DOCKER_USERNAME` - add or update the secret with your Dockerhub username  
* `DOCKER_TOKEN` - add or update the secret with a new Dockerhub access token  
* Update any references to the image name in the workflow (In particular the docker build and tag steps)  
* Update the Webhook URL in the final step of the workflow to the new server IP and port  

[Workflow Link](.github/workflows/docker-build-push.yml)  

### Testing and Validating the Workflow  
1. Push a tag to trigger the workflow  
2. Check the Github actions tab in the repository  
     - Look for a green checkmark (this means it worked)  
     - Look at logs showing the Docer image was built and pushed  
3. Check Dockerhub repository to see if the tags are received (should see the 4 versioned tags)  
4. Run `sudo journalctl -u webhook` to check if the deploy script was triggered

### Verify the Image works in Dockerhub  
1. Pull the tagged image from Dockerhub with `docker pull schuler6/schuler-3120:latest`   
2. Run the Docker container `docker run -d -p 4200:4200 --name birdapp schuler6/schuler6-3120:latest`  
3. Test the app in the browser by going to `http://44.206.46.241:4200`  
4. Verify the site works (and the possible changes were applied)  

## Part 2 - Deployment  

### EC2 Configuration Details  
* AMI ID and Name  
  - `ami-084568db4383264d4`  
  - `ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250305`  

* Instance Type - `t2.medium`  
* Specs  
  - 2 CPU cores  
  - 4 GB ram   
  - 30 GB storage volume  
* Security Group info  
  Inbound rules allow ports:  
  - 22 for ssh access  
  - 80 for http serving web app  
  - 443 for https connections (didn't really use this so could be removed)  
  - 4200 for local angular development  
  - 9000 for webhook connections  
  - 9001 for the webhook listener

### How to install docker on Ubuntu EC2 instance  
`sudo apt update`  
`sudo apt install -y docker.io`  
`sudo systemctl enable docker`  
`sudo systemctl start docker`  

Confirm download by running `docker --version`  
Test by running `docker run hello-world`  
- if it can run that successfully, then you can run containers

### Testing Docker on the EC2 instance   
Pull the latest image by `docker pull schuler6/schuler6-3120:latest`  
Run the container `docker run -d -p 4200:4200 --name birdapp schuler6/schuler6-3120:latest`  
or `docker run -it -p 4200:4200 --name birdapp schuler6/schuler6-3120:latest`  
* `-d` flag runs the container detached and in the bacground (for running in production after testing)  
* `-it` flag allows interaction with the container (helpful for debugging or testing)  

### How to verify the container is serving the application  
* From the Container Side  
  - `docker ps` this shows the container running  
* From the Host Side (EC2)  
  - `curl http://localhost:4200`  
* From External Connection  
  - Open a browser and go to `http://44.206.46.241:4200`  

### How to Manually Refresh a Container with a New Image  
1. Stop and remove the current container  
   - `docker stop birdapp`  
   - `docker rm birdapp`  
2. Pull the latest image  
   - `docker pull schuler6/schuler6-3120:latest`  
3. Run the new container  
   - `docker run -d -p 4200:4200 --name birdapp schuler6/schuler6-3120:latest`

### Bash Script for Container Application Refresh  
[Bash Script](deployment/deploy.sh)  

How to test the bash script  
- You can manually test the bash script by running `./deployment/deploy.sh`  
- Check log messages to confirme each step  
- Verify the container is running with `docker ps`

### Setup Webhook listener on EC2 Instance  
run:  
`sudo apt update`  
`sudo apt install webhook -y`   
  - To verify install run `webhook --version` and you should see a version number

### Webhook Configuration Summary  

### Summary of the Webhook Definition File  
The deploy-hook.json file defines how the EC2 instance reacts when it receives a webhook from GitHub  
It specifies:  
* The command to execute (deploy.sh)  
* The working directory  
* A SHA1 signature validation using a GitHub secret to ensure the request is genuine  
* A success message returned upon triggering  

This configuration allows the EC2 server to automatically update and redeploy the Docker container when a new tag is pushed to the GitHub repository  

### How to check the Definition File was loaded by the Webhook  
run `sudo journalctl -u webhook -b` and you should see the hook file was parsed and hooks were loaded  

### To check if a Webhook is recieving Payloads  
run `sudo journalctl -u webhook -f`  
- If the webhook is running correctly you should see a log saying there's a matched hook and executing of the deploy.sh  
- Monitor the logs in real time using `sudo journalctl -u webhook -f`  
- Run `docker ps` to see if the container is up, running the latest image, and times match the recent webhook trigger  
[Definition File](deployment/deploy-hook.json)  

### Configuring Github as the Payload Sender  
Github was chosen as the payload sender because I am more familiar with it than Docker.  

### Steps for Enabling GitHub to Send Payloads to the EC2 Webhook Listener  
1. Go to the GitHub repository  
2. Navigate to Settings --> Webhooks  
3. Click "Add webhook":  
4. Payload URL: http://44.206.46.241:9001/hooks/deploy-container  
5. Content type: application/json  
6. Secret: Match the secret in your deploy-hook.json  
7. Select "Let me select individual events" and check Pushes  
8. Save the webhook  

A git tag push will trigger a payload to be sent  
To verify a successful payload delivery, logs can be checked by running `sudo journalctl -u webhook -f`  

### Webhook Service on EC2 Instance  
Summary:  
* Listens on port 9001
* Uses the deploy-hook.json to determine trigger and script behavior
* Auto-restarts on failure
* Runs as ubuntu user

### To Enable and Start the Webhook Service  
run `sudo systemctl enable webhook`  
`sudo systemctl start webhook`  

### To confirm the Webhook Service is running  
`sudo systemctl status webhook`  
Push a tag to test and see if the deploy.sh script runs  
[Webhook Service](deployment/webhook.service)

**Project Summary**  
You change your code on your laptop.  
You push that change to GitHub.  
GitHub runs a workflow (GitHub Actions) that:  
Builds a new Docker image for your project.  
Tags it with a version and latest.  
Pushes it to DockerHub.  
GitHub sends a webhook to your server (an EC2 instance).  
Your server is always listening with a webhook service.  
When it receives the webhook, it:  
Pulls the new Docker image.  
Stops the old container.  
Starts a fresh container with the updated version.  
Website is updated automatically, no manual steps needed!  


**Demonstration Notes**  
To view current state of site  
http://44.206.46.241:4200  

Check Docker Status  
docker ps  

Make changes and tag  
git tag -a v1.0.1 -m "Release version 1.0.1"  
git push origin v1.0.1  

To see the Github action triggering  
Go to github repo -> actions  

To see new set of changed images in dockerhub  
Go to dockerhub repo and check "tags"  
Should see the updated tag for the image  

Payload sent log from github  
Check logs in github by settings->Webhooks->webhook URL port 9001  
Should see recent deliveries  

Status of webhook running as a service on the server  
sudo systemctl status webhook  

webhook logs that validate container refresh has been triggered  
sudo journalctl -u webhook.service -n 50  

Check site again  
http://44.206.46.241:4200  

Check docker status  
docker ps
