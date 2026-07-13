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

## Built from source

The `data/opt/ax10-dropbear/dropbear` binary is **built from source in CI** with the shared
[newstack](../../../newstack) glibc-2.26 toolchain: `build/build.sh` pulls the official dropbear
2019.78 tarball (mirrored to this repo's Releases so no third-party URL is needed) and
configures it `--disable-zlib --disable-wtmp --disable-lastlog`. This clean upstream build
deliberately **bypasses the TP-Link MAC-based pre-auth lockout** baked into the router's *stock*
dropbear — which is why the original was named `dropbear_vanilla`. Validated on the router via a
real SSH client.

## License

MIT for the packaging (see LICENSE). Dropbear itself is under its own MIT-style license — see
[THIRD-PARTY.md](../../../archer-ax10/THIRD-PARTY.md).
