module PercentileGraph exposing (view, Msg)

import Data exposing (Datapoint)
import Percentile exposing (Percentile)
import SortedData exposing (SortedData)
import Data

import Chart as C
import Chart.Attributes as CA
import Html exposing (Html)

-- nearest-rank method
-- https://en.wikipedia.org/wiki/Percentile#Calculation_methods
getDatapointAtPercentile : Percentile -> SortedData -> Datapoint
getDatapointAtPercentile (Percentile.Percentile rank) data =
    let
        length = data |> SortedData.length >> toFloat
        index = ceiling (rank / 100 * length) - 1
    in
    SortedData.get index data

type alias Model = List Datum

-- TODO: We should constrain Percentile and MonthlySalary
-- Actually, wouldn't it be more expressive to give x and y as the property and let the
-- type define it's purpose instead?
type alias Datum =
    { percentile: Float
    , internMonthlySalary: Float
    , freshGradMonthlySalary: Float
    }

type Msg = Msg

-- TODO: This should accept a count input instead
percentiles : List Percentile
percentiles =
    List.range 0 100
        |> List.filterMap (toFloat >> Percentile.init)

toDatum : Percentile -> (SortedData, SortedData) -> Datum
toDatum percentile (interns, freshGrads) =
    let
        _ = Debug.log "percentile" percentile
        _ = Debug.log "intern" (getDatapointAtPercentile percentile interns).monthlySalary
        _ = Debug.log "freshGrad" (getDatapointAtPercentile percentile freshGrads).monthlySalary
    in
    { percentile = percentile |> Percentile.rawValue
    , internMonthlySalary = (getDatapointAtPercentile percentile interns).monthlySalary
    , freshGradMonthlySalary = (getDatapointAtPercentile percentile freshGrads).monthlySalary
    }

toModel : (SortedData, SortedData) -> List Datum
toModel sortedDatas =
    List.foldl
        (\percentile acc -> (toDatum percentile sortedDatas) :: acc)
        []
        percentiles

-- TODO: x axis label of lowest to highest pay
chart : Maybe (List Datum) -> Html Msg
chart data =
    case data of
        Just chartModel ->
            C.chart
              [ CA.height 200
              , CA.width 200
              ]
              [ C.xLabels []
              , C.yLabels [ CA.withGrid ]
              , C.series .percentile
                  [ C.interpolated .internMonthlySalary [ CA.monotone ] []
                  , C.interpolated .freshGradMonthlySalary [ CA.monotone ] []
                  ]
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
                |> List.partition (\x -> x.status == Data.Internship)
                >> Tuple.mapBoth SortedData.init SortedData.init
                >> (\(interns, freshGrads) ->
                        case (interns, freshGrads) of
                            (Just i, Just f) -> Just (toModel (i, f))
                            _ -> Nothing
                    )
    in
    chart model
