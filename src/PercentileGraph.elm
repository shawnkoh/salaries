module PercentileGraph exposing (..)

import Data exposing (Datapoint)
import Percentile exposing (Percentile)
import SortedData exposing (SortedData)

import Chart as C
import Chart.Attributes as CA
import Html exposing (Html)

-- assume rank is 0...1
-- TODO: Enforce constraint on rank with type
getDatapointAtPercentile : Percentile -> SortedData -> Datapoint
getDatapointAtPercentile (Percentile.Percentile rank) data =
    let index = round rank * (data |> SortedData.length) in
    SortedData.get index data

type alias Model = List Datum

type alias Datum =
    { percentile: Float
    , monthlySalary: Float
    }

type Msg = Msg

--view : List Datapoint -> Html Msg
--view data =
--    let
--        sorted : SortedData
--        sorted = data |> SortedData.init

--        toDatum : Float -> Datapoint -> Datum
--        toDatum datapoint =
--            { percentile = getDatapointAtPercentile 0.1 sorted
--            , monthlySalary = datapoint.monthlySalary
--            }

--        model : SortedData -> List Datum
--        model sortedData =
--            sortedData
--                |> SortedData.toList
--                |> List.map toDatum
--            )
--    in
--    C.chart
--        [ CA.height 200
--        , CA.width 200
--        ]
--        [ C.xLabels [ CA.withGrid ]
--        , C.yLabels [ CA.withGrid ]
--        , C.series .percentile
--          [ C.interpolated .monthlySalary [] [] ]
--          model
--        ]
