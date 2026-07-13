# ax10-dropbear

**Dropbear SSH** for the TP-Link Archer AX10, listening on **port 22**, supervised by
`ax10-svc`. Separate from the lifeline dropbear that `boot.sh` starts on :2222.

Part of the [archer-ax10](../../../archer-ax10) project. Depends on
[ax10-svc](../../../ax10-svc).

## Install

```sh
opkg install ax10-dropbear
```

Registers `dropbear -p 22 -R -E` with `ax10-svc` (foreground; init keeps it alive). Log in with
your web-GUI password — see the [archer-ax10 README](../../../archer-ax10#password).

## Building from source

dropbear is a **glibc-2.26** binary, so it's built with the shared
[newstack](../../../newstack) cross toolchain (the same stack that builds the LuCI binaries) —
CI runs inside the newstack container image. The recipe lives under `build/`. The prebuilt
binary is vendored here so the package installs without a local build.

## License

MIT for the packaging (see LICENSE). Dropbear itself is under its own MIT-style license — see
[THIRD-PARTY.md](../../../archer-ax10/THIRD-PARTY.md).
