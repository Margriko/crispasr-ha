# CrispASR Home Assistant app

Run [CrispASR](https://github.com/CrispStrobe/CrispASR) as a local Wyoming
speech-to-text and text-to-speech service for Home Assistant Assist.

## Installation

1. In Home Assistant, open **Settings → Apps → App store** and add this
   repository as an app source:
   `https://github.com/CrispStrobe/crispasr-ha`.
2. Install **CrispASR**. This app currently supports `amd64` hosts.
3. Copy a CrispASR-compatible GGUF model to the Home Assistant share folder.
   The default app setting expects `/share/models/model.gguf`. The app does
   not download models, so the configured path must exactly match the file in
   `/share`.
4. Set **Model** to the complete in-container `/share/...` path if the file has
   a different name or location. Leave **Backend** empty unless the selected
   model requires an explicit CrispASR backend. Set **Language** to the model's
   language code or `auto` when supported.
5. Start the app and wait until the log shows that the backend has loaded and
   Wyoming is listening. Then add it in Home Assistant's **Wyoming Protocol**
   integration using host `127.0.0.1` and port `10300`.

The Home Assistant Supervisor builds this thin app image from the source repository and
uses the upstream `ghcr.io/crispstrobe/crispasr:main` image as its base. The app does
**not** download, update, or delete models. The `/share` folder is mounted read-only,
so the selected model remains managed by you.

## Options

| Option | Default | Meaning |
| --- | --- | --- |
| `model` | `/share/models/model.gguf` | Absolute path to a readable CrispASR-compatible GGUF model in the Home Assistant container. |
| `backend` | empty | Optional CrispASR backend override. Leave empty when the model is detected automatically. |
| `language` | `lt` | ISO 639-1 transcription language, or `auto` when the selected model supports language detection. |
| `threads` | `4` | Number of CPU threads for CrispASR. |

## Network behavior

CrispASR's upstream server also starts an internal HTTP API on port 8080, but
this app publishes only Wyoming TCP port `10300`. The startup bridge passes
`--wyoming-port 10300` to CrispASR, allowing it to advertise and serve the
Wyoming STT/TTS protocol expected by Home Assistant Assist.
