module Main exposing (..)

import Browser
import Html exposing (..)

import Data exposing (Data)
import ScatterChart
import PercentileGraph

import Json.Decode as Decode


type Model
    = PercentileGraph Data PercentileGraph.Model
    | ScatterChart Data ScatterChart.Model
    | Fail


init : Decode.Value -> ( Model, Cmd Msg )
init csv =
    case Data.decodeData csv of
        Just data ->
            ( PercentileGraph data PercentileGraph.init, Cmd.none )
        Nothing ->
            ( Fail, Cmd.none )


type Msg
    = GotScatterChartMsg ScatterChart.Msg
    | GotPercentileGraphMsg PercentileGraph.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( GotScatterChartMsg subMsg, ScatterChart data scatterChart ) ->
            ( ScatterChart data (ScatterChart.update subMsg scatterChart), Cmd.none )

        ( GotPercentileGraphMsg subMsg, PercentileGraph data percentileGraph ) ->
            ( PercentileGraph data (PercentileGraph.update subMsg percentileGraph), Cmd.none )

        ( _, _ ) ->
            -- Disregard messages that arrived for the wrong page.
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    case model of
        PercentileGraph data percentileGraph ->
            PercentileGraph.view data percentileGraph 
                |> Html.map GotPercentileGraphMsg

        ScatterChart data scatterChart ->
            data
                |> ScatterChart.view
                >> Html.map GotScatterChartMsg

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