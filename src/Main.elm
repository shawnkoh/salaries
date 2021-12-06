module Main exposing (main)

import Browser
import Html exposing (..)
import Csv.Decode as Decode exposing (Decoder)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { csv : Maybe String }


type alias Data =
    { status : Status
    , company : String
    , role : String
    , monthlySalary : Float
    }


type Status
    = FreshGrad
    | Internship

decoder : Decoder Data =
    Decode.into Data


init : () -> ( Model, Cmd Msg )
init () =
    ( Model Maybe.Nothing, Cmd.none )


type Msg
    = Msg1
    | Msg2


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg1 ->
            ( model, Cmd.none )

        Msg2 ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    div []
        [ text "New Element" ]
