# Elm Msg-Replay Example

## Scripts

```bash
# install
deno_url=https://github.com/denoland/deno/releases/download/v1.9.1/deno-x86_64-pc-windows-msvc.zip
elm_url=https://github.com/elm/compiler/releases/download/0.19.1/binary-for-windows-64-bit.gz
mkdir -p binary
curl -L $deno_url | gunzip -c > binary/deno.exe
curl -L $elm_url | gunzip -c > binary/elm.exe

# build
binary/elm make --output=build/main.js src/Main/Development.elm

# run
server_url=https://deno.land/std/http/file_server.ts
binary/deno run --allow-read=. --allow-net=localhost $server_url --host=localhost
```
