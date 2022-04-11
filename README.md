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