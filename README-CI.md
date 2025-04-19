# Project Overview

- what is the point of this project and what tools are used
- Part 4 - Diagramming goes here
  - Include a diagram (or diagrams) of your entire workflow. Meaning it should start with a project change / update, the steps that happen in between, and end with the updated version when the server is queried (web page is accessed)

# Run Project Locally

## 1. Installing Docker & Dependencies

### For **Ubuntu (Linux)**:

   **Install Docker**:  
   Update your system and install Docker:  
   `sudo apt-get update`  
   `sudo apt-get upgrade -y`  
   `sudo apt-get install -y docker.io`  

   **Start and enable Docker**  
   `sudo systemctl enable docker`  
   `sudo systemctl start docker`

   **Make sure WSL2 is installed**  
   `wsl --install`  and restart the system.  

  **Manually Setting up the Container**  
  From the project root directory run `sudo docker run -it -p 4200:4200 node:18-bullseye bash`  
  
  Flag explanation:  
  -it: Runs the container in interactive mode.  
  -p 4200:4200: Maps port 4200 inside the container to port 4200 on the host.  
  node:18-bullseye: Uses the Node 18 image with Debian Bullseye.  
  bash: Starts the container with the bash shell.  

  ** Verify that the container is successfully serving the Angular application**  
  From inside the container you should see somehting along the lines of   
  "Angular Live Development Server is listening on 0.0.0.0:4200  
  ✔ Compiled successfully."  
   
 **How to build the container**  
 First, make sure you have the github repository with the angular project cloned.  
 Go to the project's directory `cd ceg3120-cicd-schuler6`  
 Make sure your Dockerfile is included in the repo (mine is in the root of the repo)  
 Then run `docker build -t schuler6-3120 .`
 That creates the Docker image `schuler6-3120`  
 If the build hangs, you probably need to upgrade the instance to more cpu's, more ram, and more memory and repeat the previous steps  
 (I used ubuntu t2.medium with 2 cpus, 4 gb ram, and 30 gb of memory)  
 
 **How to run the container**  
 To run the container type `docker run -p 4200:4200 schuler6-3120`  
 The -p 4200:4200 maps port 4200 in the container to port 4200 on the host.  
 
 
 **How to view the project running in the container**   
 Open a browser and goto http://<your-public-ip>:4200  
 your-public-ip should be the public IP from the instance.  
 IMPORTANT:  Make sure your inbound rules allow connections to port 4200!!!  

# DockerHub

- Process to create public repo in DockerHub
- How to authenticate with DockerHub via CLI using Dockerhub credentials
  - what credentials would you recommend providing?
- How to push container to Dockerhub

# GitHub Actions

- Configuring GitHub Secrets
  - What secrets were set based on what info
- Behavior of GitHub workflow
  - what does it do and when
  - what variables in workflow are custom to your project

# Deployment

- Description of container restart script
- Setting up a webhook on the server
  - How you created you own listener
  - How you installed the [webhook on GitHub](https://github.com/adnanh/webhook)
  - How to keep the webhook running if the instance is on
- Description of Webhook task definition file
- Steps to set up a notifier in GitHub or DockerHub
