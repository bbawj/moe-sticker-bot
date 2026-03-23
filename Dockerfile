# Stage 1: base image with runtime dependencies
FROM debian:bookworm-slim AS base

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libwebp-dev \
        libheif-dev \
        imagemagick \
        curl \
        gifsicle \
        libarchive-dev \
        libarchive-tools \
        ffmpeg
        bsdtar \
        python3 \
        python3-pip \
        gcc && \
    pip3 install --break-system-packages emoji rlottie-python Pillow && \
    apt-get purge -y gcc && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Stage 2: build stage (Go binary + ffmpeg fetch)
FROM golang:bookworm AS builder

WORKDIR /src
COPY . .

# Build Go binary
RUN go build -o moe-sticker-bot cmd/moe-sticker-bot/main.go

# Stage 3: final image
FROM base

COPY --from=builder /src/moe-sticker-bot /moe-sticker-bot
COPY tools/msb_kakao_decrypt.py /usr/local/bin/msb_kakao_decrypt.py
COPY tools/msb_emoji.py         /usr/local/bin/msb_emoji.py
COPY tools/msb_rlottie.py       /usr/local/bin/msb_rlottie.py

CMD ["/moe-sticker-bot"]
