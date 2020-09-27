# Elm Msg-Replay
Automatic message-replay for Elm!

This project sets out to solve the same problems as "hot-reloading" known from JavaScript.

![Demo Gif](https://raw.githubusercontent.com/opvasger/msg-replay/0293828e73ef1b764a700bd8b003da202402871e/demo.gif)

As [the Elm architecture](https://guide.elm-lang.org/architecture/) makes you model your interactions (usually dubbed `Msg`), I've designed the programs in this module to record those interactions, and then replay them instantly when the program is reloaded. This enables some very nice features:
1. You can change **any part** of your program without breaking replay. Even if you modify/remove a message, it will still replay every message up until the first that is not part of the program anymore.
2. Replaying messages rather than storing the state of your application makes for very interactive programming, where you can change bits of logic and instantly see the results of the change you made without having to get the application back into the right state.
3. This approach has no weird edge-cases that can cause confusion during development. It simply remembers the messages that flow through your program and replay them without performing commands.

This makes for reliable and immediate feedback during development.

As this project makes no assumptions about how your persist your messages in between reloads, you have to clear that cache yourself to reinitialize the program. If you, for example, decided to use `localStorage`, you can call `localStorage.clear() & location.reload()` in the developer-console to do so.