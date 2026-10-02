# CrispASR Home Assistant app

Run [CrispASR](https://github.com/CrispStrobe/CrispASR) as a local Wyoming
speech-to-text and text-to-speech service for Home Assistant Assist.

## Installation

1. In Home Assistant, open **Settings → Apps → App store** and add this
   repository as an app source:
   `https://github.com/CrispStrobe/crispasr-ha`.
2. Choose and install one CrispASR app for your hardware. This repository supports `amd64` hosts:
   - **CrispASR** — CPU-only (`main` image).
   - **CrispASR (Intel GPU)** — Intel oneAPI/SYCL (`main-intel`).
   - **CrispASR (NVIDIA CUDA)** — NVIDIA CUDA (`main-cuda`).
   - **CrispASR (Vulkan GPU)** — Vulkan for compatible AMD, Intel, or NVIDIA GPUs (`main-vulkan`).
   - **CrispASR (Moore Threads MUSA)** — Moore Threads MUSA (`main-musa`).

   Install only one variant. GPU variants request Home Assistant full hardware access so
   the host GPU is passed through to the app. CUDA additionally requires the host NVIDIA
   driver/runtime to be available to Home Assistant.
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

The Home Assistant Supervisor builds each thin app image from this source repository.
The CPU app uses `ghcr.io/crispstrobe/crispasr:main`; each GPU app uses the corresponding
upstream image selected above. The app does not download, update, or delete models. The
`/share` folder is mounted read-only, so the selected model remains managed by you.

## Options

| Option | Default | Meaning |
| --- | --- | --- |
| `model` | `/share/models/model.gguf` | Absolute path to a readable CrispASR-compatible GGUF model in the Home Assistant container. |
| `backend` | empty | Optional CrispASR backend override. Leave empty when the model is detected automatically. |
| `language` | `lt` | ISO 639-1 transcription language, or `auto` when the selected model supports language detection. |
| `threads` | `4` | Number of CPU threads for CrispASR. |
| `gpu_device` | `0` (GPU variants only) | Zero-based accelerator index passed to CrispASR as `-dev`. CUDA and Vulkan variants also explicitly select their matching `--gpu-backend`; Intel and MUSA images use CrispASR automatic backend selection. |

## Network behavior

CrispASR's upstream server also starts an internal HTTP API on port 8080, but
this app publishes only Wyoming TCP port `10300`. The startup bridge passes
`--wyoming-port 10300` to CrispASR, allowing it to advertise and serve the
Wyoming STT/TTS protocol expected by Home Assistant Assist.

## GPU requirements

Select the image that matches the installed GPU runtime; an image cannot add a missing
host driver. CrispASR automatically chooses the highest-priority compiled backend. This
app explicitly passes `--gpu-backend cuda` or `--gpu-backend vulkan` for those respective
variants and forwards **GPU device** as `-dev N`. Intel/SYCL and MUSA use automatic
selection because their runtime backend names are not accepted by CrispASR's documented
`--gpu-backend` selector.

GPU variants set Home Assistant's `full_access: true` so the Supervisor allows access to
the host GPU device nodes. This reduces the app security rating, so do not install a GPU
variant on systems where that hardware access is not intended. Check the app startup logs
for CrispASR's selected device; set **GPU device** to a different index for multi-GPU
hosts.
