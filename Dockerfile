# Dockerfile

# Specify the base image with the desired platform
FROM ghcr.io/prefix-dev/pixi:0.16.0 AS build
COPY . /tmp/build

WORKDIR /tmp/build

# Need this to avoid SSL errors. Can this be done only with pixi?
RUN apt-get update && apt-get -y install ca-certificates

# Build branchwater-server
RUN pixi run -e build build-server

# Final image is based on debian, because we need a libgcc.
# We only copy the server binary, no need for pixi anymore
FROM docker.io/debian:bookworm-slim

COPY --from=build /tmp/build/target/release/branchwater-server /app/bin/branchwater-server

WORKDIR /data

EXPOSE 80/tcp

CMD ["/app/bin/branchwater-server", "--port", "80", "-k21", "--location", "/data/sigs.zip", "/data/sigs_indexed"]