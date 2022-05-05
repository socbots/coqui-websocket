# https://nodejs.org/en/docs/guides/nodejs-docker-webapp/
FROM node:12
# Create app directory
WORKDIR /usr/src/app
# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./
RUN npm install

# If you are building your code for production
# RUN npm ci --only=production

# Copy the whole nodejs project into the container's filesystem
# In this case to the active WORKDIR /usr/src/app
COPY . .

# Environment variables for telling server which port to listen to
ENV websocket_port=8080

# Port to forward all traffic to. Is not necessarily the port which listens for incoming traffic
EXPOSE 8080
# Command which is called on runtime
CMD [ "node", "server.js" ]