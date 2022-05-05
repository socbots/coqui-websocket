# Coqui STT Websocket Backend
Source code modified from coqui-ai's [STT-Examples](https://github.com/coqui-ai/STT-examples/tree/r1.0/web_microphone_websocket)

Download a pre-trained model and scorer from the [Coqui Model Zoo](https://coqui.ai/models) and place them in `coqui-stt-models/` as `model.tflite` and `scorer.scorer`.

## Local deployment
### Install
Tested to work on Node.js 14.

```
npm install
```
### Run the server
Listens on port 4000.
```
node server.js
```

## Building and deploying with Docker to Rahti
Deployed URL:
https://coqui-nodejs-socbots-flask.rahtiapp.fi/

The Dockerfile provided in this repo works well for building this project, it was made following the official NodeJS documentation:
https://nodejs.org/en/docs/guides/nodejs-docker-webapp/
The guide is excellent to follow for containerizing your personal node apps as well.

### Building & Publishing
First, clone and cd into the project directory. Follow the previous instructions to download the ASR models.

Build the image with
```
docker build . -t <docker.io/<username>>/coqui-websocket
```
You don't have to necessarily give a username to the image name, but Rahti pulls images from the [Docker hub](https://hub.docker.com/) and thus you need an account there and substitute your docker username into the docker command above.

If the language models have been downloaded to the Node project, these files will be incorporated to the image as well. They are quite large, about 1 GB in size, but Docker Hub does not seem to have any problem hosting it. If using a larger model that the Hub won't allow, then you'll need to create a [persistent volume](#persistent-volume).

Login to docker hub using `$ docker login`

Useful commands
```
# Get list of build docker images
docker images
# List all running containers
docker ps
# Stop and delete a container
docker stop <id or name>
docker rm <id or name>
# Print stdout from a container
docker logs <id or name>
```

To make the image available for Rahti, publish it to the docker hub
```
docker push docker.io/<username>/coqui-websocket
```
It is now available for Rahti use.


### Rahti Deployment
https://docs.csc.fi/cloud/rahti/
Install the `oc` OpenShift CLI tool according to https://docs.csc.fi/cloud/rahti/usage/cli/

Create a Rahti project on https://my.csc.fi/ if not already existing.

Login to CSC by copying the login command in the [in the Rahti console](https://rahti.csc.fi:8443) and pasting it in a terminal. `oc` will be used to expose the container to the WWW.
![341ce3c8dc8ab4932b6d8bad7379469e.png](:/419773fb86f74554ac8444af5db81711)

#### Project creation and setup
Add to Project -> Deploy Image
Choose Image Name and supply "docker.io/\<username\>/coqui-websocket", then click the search button.

You only have to give the deployment a name, env variables are already handled by the Dockerfile.

Now in the terminal expose a route
```
# Expose to internet
oc expose svc/coqui-websocket
# Print out the URL
oc get route coqui-websocket
```
The route does not get HTTPS automatically, so in the web interface, navigate in the sidebar Applications->Routes->coqui-websocket.
In top right go to Actions->Edit.
Check off "Secure Route", choose "Edge" for TLS Termination and "Redirect" for Insecure Traffic. Save and exit.
Click the URL on the coqui route page and make sure it is working.

The application is now deployed!

## Additional Configuration

### Persistent Volume
A separate storage solution for the models might be needed if they become too large to bundle upp into the Docker image itself. If it's currently working, ignore this section.

https://docs.csc.fi/cloud/rahti/storage/ Tells what storage options are available
- Persistent volume was the simplest option since you don't need any additional libraries. The mounted volume is accessed like any other directory in the file system.
- Object storage is like AWS's buckets. It's accessed with s3 compatible libraries.

#### Configure Dockerfile
You must add an additional environment variable so that coqui-websocket knows where to find the model files.

Edit the ENV line so it looks like:
```
ENV websocket_port=8080 models_dir=/data/models
```

#### Create and attach volume
On Rahti
- Storage->Create Storage
- Set a name, access mode to shared access, give appropriate size. Ignore storage class.
- Applications->Deployments->{deployment-name}->Configuration->Add Storage
- Mount path to /data and give the volume a name
	- Subpath is not necessary, but "foo/" would turn into `/data/foo`

#### Sync data
https://docs.csc.fi/cloud/rahti/tutorials/transfer_data_rahti/ Gives instructions for syncing data, we already made the persistent volume through the web interface.

The `oc` tool is needed to sync, so follow instructions here for installation: https://docs.csc.fi/cloud/rahti/usage/cli/

In order to upload files you must first authenticate the `oc` program with csc. Login using the same steps as in [Rahti Deployment](#rahti-deployment)

There must be an online pod with the mounted volume to sync data to the persistent storage. The data will not only be bound to that pod, it'll get saved to the storage and every new deployment will also automatically mount the volume.

Find the pod with `oc get pods` 
Example output:
```
fredde-example-1-build              0/1       Init:Error   0          21h
fredde-example-1-pmbs8              1/1       Running      0          21h
fredde-example-2-build              0/1       Completed    0          21h
socbots-flask-production-1-build    0/1       Init:Error   0          1d
socbots-flask-production-12-s9bpb   1/1       Running      0          50m
socbots-flask-production-2-build    0/1       Init:Error   0          1d
socbots-flask-production-2-deploy   0/1       Error        0          1d
socbots-flask-production-3-build    0/1       Init:Error   0          1d
```
"socbots-flask-production-12-s9bpb" is the current deployment here.

A local directory and its files within is uploaded with
```
oc rsync ./local/dir/ POD:/remote/dir
```
`POD` is the pod name, followed by where it should be uploaded to. `/data` in our case.
So servings the local directory "models" to the pod's "/data" looks like
```
oc rsync ./models socbots-flask-production-12-s9bpb:/data
```
oc might output an error about failing to set permissions, but the data still got synced. Setting the path to /data/foo allows oc to set its permissions, just not in the root directory apparently.

#### Access persistent storage through Flask
As per the example above, the data exists in `/data/models`, so coqui-websocket can now access the content like any other file on the filesystem.
