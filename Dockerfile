#  Created with help from ChatGPT

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
