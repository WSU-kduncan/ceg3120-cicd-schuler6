### Project 5  

## Documentation  

# Part 1 - Semantic Versioning




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

**Part 1 - Semantic Versioning**  

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
