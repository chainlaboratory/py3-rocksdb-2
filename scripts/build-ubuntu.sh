#!/bin/bash
# Build py3-rocksdb against the system librocksdb and the python3.14 on PATH.
# Intended for an Ubuntu 24.04 container that already has CPython 3.14.
set -euo pipefail

cd "$(dirname "$0")/.."

export DEBIAN_FRONTEND=noninteractive

if command -v apt-get >/dev/null 2>&1; then
    apt-get update
    apt-get install -y --no-install-recommends \
        build-essential \
        pkg-config \
        librocksdb-dev \
        libsnappy-dev \
        zlib1g-dev \
        libbz2-dev \
        liblz4-dev \
        libzstd-dev \
        libgflags-dev
fi

PYTHON="${PYTHON:-python3.14}"
"$PYTHON" -m pip install --upgrade pip build
"$PYTHON" -m pip uninstall -y py3-rocksdb || true
"$PYTHON" -m pip install .
"$PYTHON" -c "import rocksdb; db = rocksdb.DB('/tmp/py3-rocksdb-smoke', rocksdb.Options(create_if_missing=True)); db.put(b'k', b'v'); assert db.get(b'k') == b'v'; print(rocksdb.__file__)"

mkdir -p pip-package
"$PYTHON" -m build --wheel --outdir pip-package
echo "Wheel:"
ls -l pip-package/*.whl
