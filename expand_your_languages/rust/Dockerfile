####################################################################################################
## Builder
####################################################################################################
FROM rust:latest AS builder

RUN rustup target add x86_64-unknown-linux-musl
RUN apt update && apt install -y musl-tools musl-dev
RUN update-ca-certificates
# A hack to make sure crates.io index is downloaded soon

# Create appuser
ENV USER=fizzbuzz
ENV UID=10001

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"


WORKDIR /fizzbuzz

COPY / .

RUN cargo build --target x86_64-unknown-linux-musl --release

####################################################################################################
## Final image
####################################################################################################
FROM scratch

# Import from builder.
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

WORKDIR /fizzbuzz

# Copy our build
COPY --from=builder /fizzbuzz/target/x86_64-unknown-linux-musl/release/rust ./fizzbuzz

# Use an unprivileged user.
USER fizzbuzz:fizzbuzz

EXPOSE 4566
CMD ["/fizzbuzz/fizzbuzz"]
