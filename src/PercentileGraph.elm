module PercentileGraph exposing (view, Model, Msg, init, update)

import Data exposing (Datapoint)
import Percentile exposing (Percentile)
import SortedData exposing (SortedData)
import Data

import Chart as C
import Chart.Attributes as CA
import Chart.Item as CI
import Chart.Events as CE
import Html exposing (Html)

type alias Model = 
    { hovering : List (CI.One Datum CI.Dot) }

init : Model
init =
    { hovering = [] }

type Msg =
    OnHover (List (CI.One Datum CI.Dot))

update : Msg -> Model -> Model
update msg model =
    case msg of
        OnHover hovering ->
            { model | hovering = hovering }

-- TODO: We should constrain Percentile and MonthlySalary
-- Actually, wouldn't it be more expressive to give x and y as the property and let the
-- type define it's purpose instead?
type alias Datum =
    { percentile: Float
    , internMonthlySalary: Float
    , freshGradMonthlySalary: Float
    }

-- nearest-rank method
-- https://en.wikipedia.org/wiki/Percentile#Calculation_methods
getDatapointAtPercentile : Percentile -> SortedData -> Datapoint
getDatapointAtPercentile (Percentile.Percentile rank) data =
    let
        length = data |> SortedData.length >> toFloat
        index = ceiling (rank / 100 * length) - 1
    in
    SortedData.get index data

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
        (Percentile.range 0 100)

-- TODO: x axis label of lowest to highest pay
chart : List Datum -> Html Msg
chart data =
    let model = (init) in
    C.chart
      [ CA.height 200
      , CA.width 200
      , CE.onMouseMove OnHover (CE.getNearest CI.dots)
      , CE.onMouseLeave (OnHover [])
      ]
      [ C.xLabels []
      , C.yLabels [ CA.withGrid ]
      , C.series .percentile
          [ C.interpolated .internMonthlySalary [ CA.monotone ] []
          , C.interpolated .freshGradMonthlySalary [ CA.monotone ] []
          ]
          data
      , C.each model.hovering <| \p item ->
        [ C.tooltip item [] [] [] ]
      ]

view : List Datapoint -> Html Msg
view data =
    let
        chartData : Maybe (List Datum)
        chartData =
            data
                |> List.partition (\x -> x.status == Data.Internship)
                >> Tuple.mapBoth SortedData.init SortedData.init
                >> (\(interns, freshGrads) ->
                        case (interns, freshGrads) of
                            (Just i, Just f) -> Just (toModel (i, f))
                            _ -> Nothing
                    )
    in
    case chartData of
        Just chartModel ->
            chart chartModel
        Nothing ->
            Html.div []
            [ Html.text "Data failed to load" ]
