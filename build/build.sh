#!/bin/sh
# Build dropbear for the TP-Link Archer AX10 (glibc-2.26 ARMv7) using the shared
# newstack cross toolchain (pulled from its public Release — no GHCR image required).
# Matches the vendored binary's version (2019.78). Output: build/out/dropbear.
set -e

DB_VER="${DB_VER:-2019.78}"
TC_URL="${TC_URL:-https://github.com/lee-soft/newstack/releases/download/toolchain-2017.11/toolchain.tar.xz}"
HERE="$(cd "$(dirname "$0")" && pwd)"
WORK="${WORK:-$HERE/work}"; OUT="${OUT:-$HERE/out}"
rm -rf "$WORK" "$OUT"; mkdir -p "$WORK" "$OUT"; cd "$WORK"

asroot() { if [ "$(id -u)" = 0 ]; then sh -c "$1"; else sudo sh -c "$1"; fi; }

# --- newstack toolchain (the shared build stack) ---
if [ -z "$CROSS" ]; then
  echo ">> fetching newstack toolchain"
  curl -fsSL "$TC_URL" -o tc.tar.xz
  mkdir -p tc && tar -C tc -xf tc.tar.xz          # -> tc/toolchain/
  TCROOT="$WORK/tc/toolchain"
  # register the toolchain's i386 gcc-dep libs in the (per-arch) i386 linker cache;
  # x86-64 host binaries are unaffected.
  asroot "echo '$TCROOT/lib' > /etc/ld.so.conf.d/newstack.conf && ldconfig"
  export PATH="$TCROOT/bin:$PATH"
  CROSS=arm-linux-
fi
echo ">> $(${CROSS}gcc --version | head -1)"

# --- dropbear source: the OFFICIAL 2019.78 release tarball, mirrored to our own Release
#     so the build never depends on a third-party URL. Upstream: https://matt.ucc.asn.au/dropbear/ ---
DB_SRC="${DB_SRC:-https://github.com/lee-soft/ax10-dropbear/releases/download/src-2019.78/dropbear-2019.78.tar.bz2}"
curl -fsSL "$DB_SRC" -o db.tar.bz2
tar xjf db.tar.bz2
cd "dropbear-${DB_VER}"
# Vanilla recipe: --disable-zlib --disable-wtmp --disable-lastlog. The router's STOCK
# dropbear carries a TP-Link MAC-based pre-auth lockout mod; this clean upstream build
# bypasses it entirely (that's why the vendored binary is "dropbear_vanilla").
./configure --host=arm-buildroot-linux-gnueabi CC="${CROSS}gcc" \
  --disable-zlib --disable-wtmp --disable-lastlog
make -j"$(nproc)" PROGRAMS="dropbear dbclient dropbearkey dropbearconvert scp"
"${CROSS}strip" dropbear 2>/dev/null || true
cp dropbear "$OUT/dropbear"
echo ">> built:"; file "$OUT/dropbear"
