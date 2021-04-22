# Elm Msg-Replay Example

## Scripts

```bash
# install
deno_url=https://github.com/denoland/deno/releases/download/v1.9.1/deno-x86_64-pc-windows-msvc.zip
mkdir -p binary
curl -L $deno_url | gunzip -c > binary/deno.exe

# build
elm make --output=build/main.js src/Main/Development.elm

# run
server_url=https://deno.land/std/http/file_server.ts
binary/deno run --allow-read=. --allow-net=localhost $server_url --host=localhost
```
