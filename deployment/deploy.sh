#! /bin/bash

# kill the old container process - stopped & then removed
docker stop birdapp || true
docker rm || true
# pull fresh image
docker pull schuler6/schuler6-3120:latest
# run new container by name, with restart automatic
docker run -d -p 4200:4200 --name birdapp --restart always schuler6/schuler6-3120:latest
