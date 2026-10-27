FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        software-properties-common \
        gnupg \
    && add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y --no-install-recommends \
        python3.14 \
        python3.14-dev \
        python3.14-venv \
        build-essential \
        pkg-config \
        librocksdb-dev \
        libsnappy-dev \
        zlib1g-dev \
        libbz2-dev \
        liblz4-dev \
        libzstd-dev \
        libgflags-dev \
        curl \
    && rm -rf /var/lib/apt/lists/* \
    && curl -sS https://bootstrap.pypa.io/get-pip.py | python3.14 \
    && python3.14 -m pip install --upgrade build

WORKDIR /src
COPY . /src

# Install and import against Ubuntu 24.04's librocksdb 8.9, then write a
# cp314 wheel. A py3-none-any wheel would be installed on the wrong interpreter.
RUN python3.14 -m pip install . \
    && python3.14 -c "import rocksdb; db = rocksdb.DB('/tmp/py3-rocksdb-smoke', rocksdb.Options(create_if_missing=True)); db.put(b'a', b'data'); assert db.get(b'a') == b'data'; print(rocksdb.__file__)" \
    && python3.14 -m build --wheel --outdir /out
