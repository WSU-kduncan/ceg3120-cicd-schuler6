# Project 5 

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
