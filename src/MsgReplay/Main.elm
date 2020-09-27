module MsgReplay.Main exposing (Model, decoder, encode, init, initModel, replay, update)

import Json.Decode
import Json.Encode


type alias Model model =
    { appModel : model
    , appMsgs : List Json.Encode.Value
    }


initModel : model -> Model model
initModel appModel =
    { appModel = appModel
    , appMsgs = []
    }


init :
    (msg -> model -> model)
    -> Json.Decode.Decoder msg
    -> Maybe String
    -> ( model, Cmd msg )
    -> ( Model model, Cmd msg )
init replayUpdate msgDecoder fromCache ( appModel, appCmd ) =
    case Maybe.andThen (Result.toMaybe << Json.Decode.decodeString (decoder replayUpdate msgDecoder appModel)) fromCache of
        Just model ->
            ( model
            , Cmd.none
            )

        Nothing ->
            ( initModel appModel
            , appCmd
            )


update :
    (msg -> model -> ( model, Cmd msg ))
    -> (String -> Cmd msg)
    -> (msg -> Json.Encode.Value)
    -> msg
    -> Model model
    -> ( Model model, Cmd msg )
update updateApp toCache encodeMsg appMsg model =
    let
        ( appModel, appCmd ) =
            updateApp appMsg model.appModel

        updatedModel =
            { model
                | appModel = appModel
                , appMsgs = encodeMsg appMsg :: model.appMsgs
            }
    in
    ( updatedModel
    , Cmd.batch
        [ appCmd
        , toCache (Json.Encode.encode 0 (encode updatedModel))
        ]
    )


encode : Model model -> Json.Encode.Value
encode model =
    Json.Encode.list identity
        model.appMsgs


decoder :
    (msg -> model -> model)
    -> Json.Decode.Decoder msg
    -> model
    -> Json.Decode.Decoder (Model model)
decoder replayUpdate msgDecoder appModel =
    Json.Decode.map (decoderReplayHelper replayUpdate msgDecoder (initModel appModel))
        (Json.Decode.map List.reverse (Json.Decode.list Json.Decode.value))


decoderReplayHelper :
    (msg -> model -> model)
    -> Json.Decode.Decoder msg
    -> Model model
    -> List Json.Encode.Value
    -> Model model
decoderReplayHelper replayUpdate msgDecoder model appMsgs =
    case appMsgs of
        appMsg :: moreAppMsgs ->
            case Json.Decode.decodeValue msgDecoder appMsg of
                Ok decodedAppMsg ->
                    decoderReplayHelper replayUpdate
                        msgDecoder
                        { model
                            | appModel = replayUpdate decodedAppMsg model.appModel
                            , appMsgs = appMsg :: model.appMsgs
                        }
                        moreAppMsgs

                Err _ ->
                    model

        [] ->
            model


replay : (msg -> model -> ( model, Cmd msg )) -> msg -> model -> model
replay updateApp msg =
    Tuple.first << updateApp msg
