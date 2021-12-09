module Main exposing (..)

import Browser
import Html exposing (..)

import Data exposing (Data)
import ScatterChart
import PercentileGraph

import Json.Decode as Decode


type Model
    = PercentileGraph Data
    | Fail


init : Decode.Value -> ( Model, Cmd Msg )
init csv =
    case Data.decodeData csv of
        Just data -> ( PercentileGraph data, Cmd.none )
        Nothing -> ( Fail, Cmd.none )


type Msg
    = GotScatterChartMsg ScatterChart.Msg
    | GotPercentileGraphMsg PercentileGraph.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotScatterChartMsg _ ->
            ( model, Cmd.none )

        GotPercentileGraphMsg chartMsg ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    case model of
        PercentileGraph data ->
            data
            |> PercentileGraph.view
            >> Html.map GotPercentileGraphMsg
        Fail ->
            div []
            [ text "Data failed to load" ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


main : Program Decode.Value Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }