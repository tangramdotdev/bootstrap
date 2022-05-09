#!/bin/bash
set -euo pipefail
log "Downloading toolchain..."

BUILD_LOGFILE=$LOGDIR/3.1-download-tools.log

pushd "$LFS"/sources

case "$FETCH_TOOLCHAIN_MODE" in
  "0")
    log "Downloading packges..."
    wget --input-file="$LFS"/tools/wget-list --continue --directory-prefix="$LFS"/sources

    log "Check hashes..."
    md5sum -c "$LFS"/tools/md5sums | sudo tee -a "$BUILD_LOGFILE"
    ;;
  "1")
    log "Assuming tools already in place!!"
    # TODO - would be nice to verify this is the case and fail if not.
    ;;
  *)
    log "Undefined toolchain fetch mode!!!"
    false
    ;;
esac

popd
