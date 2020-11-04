module Main exposing (Flags, Model, Msg, encodeMsg, init, msgDecoder, subscriptions, update, view)

import Browser
import Html
import Html.Attributes
import Html.Events
import Json.Decode
import Json.Encode


type alias Flags =
    { messages : Maybe String }


type Model
    = LoggedOut { name : String, pass : String }
    | LoggedIn { name : String }


type Msg
    = InputName String
    | InputPass String
    | LogIn
    | LogOut


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( LoggedOut { name = "", pass = "" }
    , Cmd.none
    )


view : Model -> Browser.Document Msg
view model =
    { title = "Example"
    , body =
        List.singleton <|
            case model of
                LoggedOut { name, pass } ->
                    Html.div []
                        [ Html.input
                            [ Html.Events.onInput InputName
                            , Html.Attributes.value name
                            ]
                            []
                        , Html.input
                            [ Html.Events.onInput InputPass
                            , Html.Attributes.value pass
                            , Html.Attributes.type_ "password"
                            ]
                            []
                        , Html.button [ Html.Events.onClick LogIn ] [ Html.text "Log In" ]
                        ]

                LoggedIn { name } ->
                    Html.div []
                        [ Html.text name
                        , Html.button [ Html.Events.onClick LogOut ] [ Html.text "Log Out" ]
                        ]
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model of
        LoggedOut loggedOutModel ->
            case msg of
                InputName name ->
                    ( LoggedOut { loggedOutModel | name = name }, Cmd.none )

                InputPass pass ->
                    ( LoggedOut { loggedOutModel | pass = pass }, Cmd.none )

                LogIn ->
                    ( LoggedIn { name = loggedOutModel.name }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        LoggedIn loggedInModel ->
            case msg of
                LogOut ->
                    ( LoggedOut { name = "", pass = "" }, Cmd.none )

                _ ->
                    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- Msg


encodeMsg : Msg -> Json.Encode.Value
encodeMsg msg =
    case msg of
        InputName name ->
            Json.Encode.object [ ( "InputName", Json.Encode.string name ) ]

        InputPass pass ->
            Json.Encode.object [ ( "InputPass", Json.Encode.string pass ) ]

        LogIn ->
            Json.Encode.object [ ( "LogIn", Json.Encode.null ) ]

        LogOut ->
            Json.Encode.object [ ( "LogOut", Json.Encode.null ) ]


msgDecoder : Json.Decode.Decoder Msg
msgDecoder =
    Json.Decode.oneOf
        [ Json.Decode.field "InputName" (Json.Decode.map InputName Json.Decode.string)
        , Json.Decode.field "InputPass" (Json.Decode.map InputPass Json.Decode.string)
        , Json.Decode.field "LogIn" (Json.Decode.null LogIn)
        , Json.Decode.field "LogOut" (Json.Decode.null LogOut)
        ]



-- Main


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
