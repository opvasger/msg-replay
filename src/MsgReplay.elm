module MsgReplay exposing
    ( Config
    , sandbox, element, document, application
    , Program
    )

{-| This module helps you set up an Elm program with automatic message-replay.


# Configuration

@docs Config


# Programs

This API mirrors [elm/browser](https://package.elm-lang.org/packages/elm/browser/latest).

@docs sandbox, element, document, application

@docs Program

-}

import Browser
import Browser.Navigation
import Html exposing (Html)
import Json.Decode
import Json.Encode
import MsgReplay.Main as MsgReplay
import Url exposing (Url)


{-| A program with automatic message-replay enabled.
-}
type alias Program flags model msg =
    Platform.Program flags (MsgReplay.Model model) msg


{-| This is the configuration required for automatic message-MsgReplay.

Let's say your program is initialized in HTML like this:

    <script>
        const app = Elm.Main.init({
            node: document.body,
            flags: {
                messages : localStorage.getItem("msg-replay")
            }
        })

        app.ports.toCache.subscribe(messages =>
            localStorage.setItem("msg-replay", messages)
        )
    </script>

The configuration for that script would be like this:

    port toCache : Maybe String -> Cmd msg

    fromCache =
        .messages

`encodeMsg` and `msgDecoder` depends on how messages are defined.

-}
type alias Config flags msg =
    { encodeMsg : msg -> Json.Encode.Value
    , msgDecoder : Json.Decode.Decoder msg
    , fromCache : flags -> Maybe String
    , toCache : String -> Cmd msg
    }


{-| Create a “sandboxed” program that cannot communicate with the outside world. More about that [here](https://package.elm-lang.org/packages/elm/browser/latest/Browser#sandbox).
-}
sandbox :
    Config flags msg
    ->
        { init : model
        , view : model -> Html msg
        , update : msg -> model -> model
        }
    -> Program flags model msg
sandbox config app =
    Browser.element
        { update =
            MsgReplay.update (\msg model -> ( app.update msg model, Cmd.none ))
                config.toCache
                config.encodeMsg
        , subscriptions = always Sub.none
        , view = app.view << .appModel
        , init =
            \flags ->
                MsgReplay.init app.update
                    config.msgDecoder
                    (config.fromCache flags)
                    ( app.init, Cmd.none )
        }


{-| Create an HTML element managed by Elm. More about that [here](https://package.elm-lang.org/packages/elm/browser/latest/Browser#element).
-}
element :
    Config flags msg
    ->
        { init : flags -> ( model, Cmd msg )
        , view : model -> Html msg
        , update : msg -> model -> ( model, Cmd msg )
        , subscriptions : model -> Sub msg
        }
    -> Program flags model msg
element config app =
    Browser.element
        { update = MsgReplay.update app.update config.toCache config.encodeMsg
        , subscriptions = app.subscriptions << .appModel
        , view = app.view << .appModel
        , init =
            \flags ->
                MsgReplay.init (MsgReplay.replay app.update)
                    config.msgDecoder
                    (config.fromCache flags)
                    (app.init flags)
        }


{-| Create an HTML document managed by Elm. More about that [here](https://package.elm-lang.org/packages/elm/browser/latest/Browser#document).
-}
document :
    Config flags msg
    ->
        { init : flags -> ( model, Cmd msg )
        , subscriptions : model -> Sub msg
        , update : msg -> model -> ( model, Cmd msg )
        , view : model -> Browser.Document msg
        }
    -> Program flags model msg
document config app =
    Browser.document
        { update = MsgReplay.update app.update config.toCache config.encodeMsg
        , subscriptions = app.subscriptions << .appModel
        , view = app.view << .appModel
        , init =
            \flags ->
                MsgReplay.init (MsgReplay.replay app.update)
                    config.msgDecoder
                    (config.fromCache flags)
                    (app.init flags)
        }


{-| Create an application that manages Url changes. More about that [here](https://package.elm-lang.org/packages/elm/browser/latest/Browser#application).
-}
application :
    Config flags msg
    ->
        { init : flags -> Url -> Browser.Navigation.Key -> ( model, Cmd msg )
        , update : msg -> model -> ( model, Cmd msg )
        , subscriptions : model -> Sub msg
        , view : model -> Browser.Document msg
        , onUrlChange : Url -> msg
        , onUrlRequest : Browser.UrlRequest -> msg
        }
    -> Program flags model msg
application config app =
    Browser.application
        { update = MsgReplay.update app.update config.toCache config.encodeMsg
        , subscriptions = app.subscriptions << .appModel
        , view = app.view << .appModel
        , onUrlChange = app.onUrlChange
        , onUrlRequest = app.onUrlRequest
        , init =
            \flags url key ->
                MsgReplay.init (MsgReplay.replay app.update)
                    config.msgDecoder
                    (config.fromCache flags)
                    (app.init flags url key)
        }
