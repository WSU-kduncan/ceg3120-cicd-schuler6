# Project Overview  
## Project Goal
The goal of this project is to implement a Continuous Integration (CI) pipeline using GitHub Actions that automatically builds and pushes a Docker image of an Angular application to a DockerHub repository whenever code is pushed to the main branch.  
 
## Tools used  
Docker: Containerizes the Angular app.  

DockerHub: Hosts the built Docker images.  

GitHub: Hosts the source code and triggers workflows on code changes.  

GitHub Actions: Automates building and pushing Docker images.  

ChatGPT was used to generate the Dockerfile, diagram, and the github/workflow file.  
Prompt for Dockerfile: "Write a Dockerfile that builds and serves an Angular application using Node.js and Angular CLI."  
Prompt for the github/workflow file:  "Set up a GitHub Actions workflow that builds and pushes a Docker image to DockerHub when a commit is pushed to the main branch using secrets for authentication."  
Prompt for diagram: "Include a Mermaid diagram of CI workflow from project update to running container"

Shortcomings:  I wasnt able to do the deployment section.  

- Part 4 - 
  [Diagram](workflow.png)

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

  **Verify that the container is successfully serving the Angular application**  
  From inside the container you should see somehting along the lines of   
  "Angular Live Development Server is listening on 0.0.0.0:4200  
  ✔ Compiled successfully." 

  From outside, you can type in your browser http://<your-public-ip>:4200  

  **Dockerfile explaination**  
  ```
  # Created by ChatGPT
  FROM node:18-bullseye  

  WORKDIR /app  

  RUN npm install -g @angular/cli@15.0.3  

  # Copy only the package files first for better layer caching  
  COPY angular-site/wsu-hw-ng-main/package*.json ./  
  RUN npm install  

  # Copy the rest of the Angular app  
  COPY angular-site/wsu-hw-ng-main/ .  

  # Run the Angular dev server and bind to all interfaces  
  CMD ["ng", "serve", "--host", "0.0.0.0"]
```

  `FROM`: Base image with Node.js.  
  `WORKDIR` Sets working directory.  
  `RUN npm install -g` Installs Angular CLI globally.  
  `COPY` Copies the Angular project into the image.  
  `RUN npm install` Installs project dependencies.  
  `CMD` Runs the Angular development server.  
   
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

  **Create Public Repo on DockerHub**  
  -Go to hub.docker.com  
  -Log in and click on "Create Repository"  
  -Choose a name, set visibility to public, and create.  
  
  **How to authenticate with DockerHub via CLI using Dockerhub credentials**  
    -Create a personal access token  
    -Go to DockerHub Security Settings  
    -Create a new token with read/write scope  
    -Authenticate with Dockerhub by `docker login`  
    -The password is your personal access token that you created
    
  **To push an image to DockerHub**  
    -Tag the image `docker tag schuler6-3120 schuler6/schuler6-3120`  
    -Push the image `docker push schuler6/schuler6-3120`  
    -Link to my repo `https://hub.docker.com/repository/docker/schuler6/schuler-3120`
  
# GitHub Actions

## Configuring GitHub Repository Secrets  

### How to Create a DockerHub Personal Access Token (PAT)  

1. Go to DockerHub Security Settings  
2. Under Access Tokens, click New Access Token  
3. Name the token  
4. Set the Access Level to Read/Write  
5. Save the token  

## How to Set Repository Secrets for GitHub Actions  

1. In the GitHub repository, go to Settings -> Secrets and Variables -> Actions  
2. Click New repository secret  

   - `DOCKER_USERNAME`:  DockerHub username  
   - `DOCKER_TOKEN`:  DockerHub Personal Access Token  

## Secrets Set for This Project  

- `DOCKER_USERNAME`: Used by GitHub Actions to authenticate with DockerHub  
- `DOCKER_TOKEN`: The token that gives GitHub Actions permission to push to the DockerHub repository  

# GitHub Workflow  

- **Trigger**: The workflow runs automatically on every push to the `main` branch.  

- **What it does**:  
  1. Checks out the repository code.  
  2. Sets up Docker Buildx for building multi-platform images.  
  3. Logs into DockerHub using the secrets (`DOCKER_USERNAME`, `DOCKER_TOKEN`).  
  4. Builds the Docker image using the local `Dockerfile`.  
  5. Tags the image with your DockerHub username and project name.  
  6. Pushes the image to your DockerHub repository.

  [Workflow Link](https://github.com/WSU-kduncan/ceg3120-cicd-schuler6/blob/main/.github/workflows/docker-build-push.yml)


