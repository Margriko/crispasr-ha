# CrispASR Home Assistant app

Run [CrispASR](https://github.com/CrispStrobe/CrispASR) as a local Wyoming
speech-to-text and text-to-speech service for Home Assistant Assist.

## Installation

1. In Home Assistant, open **Settings → Apps → App store** and add this
   repository as an app source:
   `https://github.com/CrispStrobe/crispasr-ha`.
2. Install **CrispASR**. This app currently supports `amd64` hosts.
3. Download the model yourself and copy it to the Home Assistant share folder.
   The default app setting expects:
   `/share/kmynas-pipiras-q8_0.gguf`.

   For example, use
   [`kmynas-pipiras-q8_0.gguf`](https://huggingface.co/DeimantasLT/kmynas-pipiras-gguf/tree/main)
   from DeimantasLT/kmynas-pipiras-gguf.
4. Set **Model** to the complete in-container `/share/...` path if the file has
   a different name or location. Set **Backend** only when automatic GGUF
   detection needs to be overridden.
5. Start the app and add it in Home Assistant's **Wyoming Protocol**
   integration with `tcp://<home-assistant-host>:10300`.

The Home Assistant Supervisor builds this thin app image from the source repository and
uses the upstream `ghcr.io/crispstrobe/crispasr:main` image as its base. The app does
**not** download, update, or delete models. The `/share` folder is mounted read-only,
so the selected model remains managed by you.

## Options

| Option | Default | Meaning |
| --- | --- | --- |
| `model` | `/share/kmynas-pipiras-q8_0.gguf` | Absolute path to a readable GGUF model in the Home Assistant container. |
| `backend` | empty | Optional CrispASR backend override. Normally leave empty for GGUF auto-detection. |
| `language` | `lt` | ISO 639-1 transcription language, or `auto` for language detection. |
| `threads` | `4` | Number of CPU threads for CrispASR. |

## Network behavior

CrispASR's upstream server also starts an internal HTTP API on port 8080, but
this app publishes only Wyoming TCP port `10300`. The startup bridge passes
`--wyoming-port 10300` to CrispASR, allowing it to advertise and serve the
Wyoming STT/TTS protocol expected by Home Assistant Assist.
