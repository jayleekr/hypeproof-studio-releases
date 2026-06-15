# hypeproof-studio-releases

Public mirror of HypeProof Studio release artifacts. The source repository
(`jayleekr/hypeproof-studio`) is private; this public repo exists solely so
workshop participants can install the app without GitHub access.

## Install

### macOS

```bash
curl -fsSL https://raw.githubusercontent.com/jayleekr/hypeproof-studio-releases/main/install-mac.sh | bash
```

The script downloads the latest release zip, unzips, copies to `/Applications`,
clears the Gatekeeper quarantine attribute, and launches the app.

### Windows

```powershell
iwr -useb https://raw.githubusercontent.com/jayleekr/hypeproof-studio-releases/main/install-win.ps1 | iex
```

The script downloads the latest unsigned Windows x64 installer from Releases,
verifies the release asset SHA256 digest, and launches it.

## Releases

See [releases](https://github.com/jayleekr/hypeproof-studio-releases/releases).

Each release corresponds to a tagged build of the private source repo. We
mirror artifacts here; no source is duplicated.
