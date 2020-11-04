port module Main.Development exposing (main)

import Main
import MsgReplay


port toCache : String -> Cmd msg


replayConfig : MsgReplay.Config Main.Flags Main.Msg
replayConfig =
    { encodeMsg = Main.encodeMsg
    , msgDecoder = Main.msgDecoder
    , fromCache = .messages
    , toCache = toCache
    }


main : MsgReplay.Program Main.Flags Main.Model Main.Msg
main =
    MsgReplay.document replayConfig
        { init = Main.init
        , subscriptions = Main.subscriptions
        , update = Main.update
        , view = Main.view
        }
