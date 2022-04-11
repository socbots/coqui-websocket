# Coqui STT Websocket Backend
Source code modified from coqui-ai's [STT-Examples](https://github.com/coqui-ai/STT-examples/tree/r1.0/web_microphone_websocket)

Download a pre-trained model and scorer from the [Coqui Model Zoo](https://coqui.ai/models) and place them in `coqui-stt-models/` as `model.tflite` and `scorer.scorer`.

#### Install
Tested to work on Node.js 14.

```
npm install
```
#### Run the server
Listens on port 4000.
```
node server.js
```

## Configuring the WebSocket handshake
It is recommended to use a reverse proxy to handle the traffic encryption, such as nginx, or in our production usecase, Rahti.


In addition to normal SSL and reverse proxy configuration, there needs to be additional headers
to process the WebSocket connection upgrade from http to wss.
Otherwise, the connection may work but all requests will be sent as GET and POST over regular HTTP.

[Howto with Nginx](https://www.nginx.com/blog/websocket-nginx/)

Rahti to be seen...