module PercentileGraph exposing (view, Model, Msg, init, update)

import Data exposing (Data, Datapoint, Status(..))
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
    { percentile: Percentile
    , intern: Datapoint
    , freshGrad: Datapoint
    }

-- nearest-rank method
-- https://en.wikipedia.org/wiki/Percentile#Calculation_methods
getDatapointAtPercentile : Percentile -> Data -> Datapoint
getDatapointAtPercentile (Percentile.Percentile rank) data =
    let
        length = data |> SortedData.length >> toFloat
        index = ceiling (rank / 100 * length) - 1
    in
    SortedData.get index data

toDatum : Percentile -> (SortedData Datapoint, SortedData Datapoint) -> Datum
toDatum percentile (interns, freshGrads) =
    let
        _ = Debug.log "percentile" percentile
        _ = Debug.log "intern" getDatapointAtPercentile percentile interns
        _ = Debug.log "freshGrad" getDatapointAtPercentile percentile freshGrads
    in
    { percentile = percentile
    , intern = getDatapointAtPercentile percentile interns
    , freshGrad = getDatapointAtPercentile percentile freshGrads
    }

toModel : (Data, Data) -> List Datum
toModel sortedDatas =
    List.foldl
        (\percentile acc -> (toDatum percentile sortedDatas) :: acc)
        []
        (Percentile.range 0 100)

-- TODO: x axis label of lowest to highest pay
chart : List Datum -> Model -> Html Msg
chart data model =
    C.chart
      [ CA.height 200
      , CA.width 200
      , CE.onMouseMove OnHover (CE.getNearest CI.dots)
      , CE.onMouseLeave (OnHover [])
      ]
      [ C.xLabels []
      , C.yLabels [ CA.withGrid ]
      , C.series (.percentile >> Percentile.rawValue)
          [ C.interpolated (.intern >> .monthlySalary) [ CA.monotone ] []
          , C.interpolated (.freshGrad >> .monthlySalary) [ CA.monotone ] []
          ]
          data
      , C.each model.hovering <| \p item ->
        [ C.tooltip item [] [] [] ]
      ]

view : Data -> Model -> Html Msg
view data model =
    let
        toData = SortedData.init .monthlySalary
        chartData : Maybe (List Datum)
        chartData =
            data
                |> SortedData.partition (\x -> x.status == Internship)
                >> Tuple.mapBoth toData toData
                >> (\(interns, freshGrads) ->
                        case (interns, freshGrads) of
                            (Just i, Just f) -> Just (toModel (i, f))
                            _ -> Nothing
                    )
    in
    case chartData of
        Just chartModel ->
            chart chartModel model
        Nothing ->
            Html.div []
            [ Html.text "Data failed to load" ]
