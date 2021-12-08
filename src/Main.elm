module Main exposing (..)

import Browser
import Html exposing (..)

import Data exposing (Datapoint, datapointDecoder)
import ScatterChart

import Json.Decode as Decode


main : Program Decode.Value Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { data: Maybe (List Datapoint) }


decodeModel : Decode.Value -> Model
decodeModel json =
    case Decode.decodeValue (Decode.list datapointDecoder) json of
        Ok value ->
            Model (Just value)
        Err error ->
            let
                _ = Debug.log "error: " (Decode.errorToString error)
            in
            Model Nothing


init : Decode.Value -> ( Model, Cmd Msg )
init csv =
    ( decodeModel csv, Cmd.none )


type Msg
    = Msg1 ScatterChart.Msg
    | Msg2


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg1 _ ->
            ( model, Cmd.none )

        Msg2 ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

view : Model -> Html Msg
view model =
    case model.data of
        Just data ->
            data
            |> ScatterChart.view
            >> Html.map Msg1 
        Nothing ->
            div []
            [ text "Data failed to load" ]

