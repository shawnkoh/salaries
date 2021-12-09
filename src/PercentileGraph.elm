module PercentileGraph exposing (..)

import Data exposing (Datapoint)
import Percentile exposing (Percentile)
import SortedData exposing (SortedData)

import Chart as C
import Chart.Attributes as CA
import Html exposing (Html)

getDatapointAtPercentile : Percentile -> SortedData -> Datapoint
getDatapointAtPercentile (Percentile.Percentile rank) data =
    let index = round rank * (data |> SortedData.length) in
    SortedData.get index data

type alias Model = List Datum

-- TODO: We should constrain Percentile and MonthlySalary
-- Actually, wouldn't it be more expressive to give x and y as the property and let the
-- type define it's purpose instead?
type alias Datum =
    { percentile: Float
    , monthlySalary: Float
    }

type Msg = Msg

-- TODO: This should accept a count input instead
percentiles : List Percentile
percentiles =
    List.range 0 100
        |> List.filterMap (toFloat >> Percentile.init)

toDatum : Percentile -> SortedData -> Datum
toDatum percentile sortedData =
    { percentile = percentile |> Percentile.rawValue
    , monthlySalary = (getDatapointAtPercentile percentile sortedData).monthlySalary
    }

toModel : SortedData -> List Datum
toModel sortedData =
    List.foldl
        (\percentile acc -> (toDatum percentile sortedData) :: acc)
        []
        percentiles

chart : Maybe (List Datum) -> Html Msg
chart data =
    case data of
        Just chartModel ->
            C.chart
              [ CA.height 200
              , CA.width 200
              ]
              [ C.xLabels [ CA.format (\x -> String.fromFloat x) ]
              , C.yLabels [ CA.withGrid ]
              , C.series .percentile
                  [ C.scatter .monthlySalary [] ]
                  chartModel
              ]
        Nothing ->
            Html.div []
            [ Html.text "Data failed to load" ]

view : List Datapoint -> Html Msg
view data =
    let
        model : Maybe (List Datum)
        model =
            data
                |> SortedData.init
                >> Maybe.map toModel
    in
    chart model
