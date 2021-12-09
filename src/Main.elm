module Main exposing (..)

import Browser
import Html exposing (..)

import Data exposing (Datapoint, datapointDecoder)
import ScatterChart
import PercentileGraph

import Json.Decode as Decode


main : Program Decode.Value Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

type alias Data =
    List Datapoint

type Model =
    Fail
    | Chart ChartType

type ChartType =
    PercentileGraph Data

decodeData : Decode.Value -> Maybe Data
decodeData json =
    case Decode.decodeValue (Decode.list datapointDecoder) json of
        Ok value ->
            Just value
        Err error ->
            let
                _ = Debug.log "error: " (Decode.errorToString error)
            in
            Nothing


init : Decode.Value -> ( Model, Cmd Msg )
init csv =
    case decodeData csv of
        Just data -> ( Chart (PercentileGraph data), Cmd.none )
        Nothing -> ( Fail, Cmd.none )


type Msg
    = Msg1 ScatterChart.Msg
    | Msg2 PercentileGraph.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg1 _ ->
            ( model, Cmd.none )

        Msg2 _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none

view : Model -> Html Msg
view model =
    case model of
        Chart (PercentileGraph data) ->
            data
            |> PercentileGraph.view
            >> Html.map Msg2
        Fail ->
            div []
            [ text "Data failed to load" ]

