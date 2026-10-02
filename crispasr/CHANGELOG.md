# Changelog

## 0.1.1

- Run the app entrypoint as root so it can read Home Assistant's
  Supervisor-provided `/data/options.json` configuration file.

## 0.1.0

- Initial Home Assistant app for the CrispASR upstream container.
- Exposes CrispASR's Wyoming STT/TTS endpoint on TCP port 10300.
- Adds configurable local GGUF model path, language, backend, and CPU thread count.
