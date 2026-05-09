FROM hugomods/hugo:latest AS builder
WORKDIR /src
COPY . .
# Build the static site
RUN hugo --minify

FROM caddy:2-alpine
# Copy the compiled static site from the builder stage
COPY --from=builder /src/public /usr/share/caddy
EXPOSE 80
