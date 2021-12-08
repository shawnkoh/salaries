module ScatterChart exposing (view, Msg)

import Data exposing (..)
import Chart as C
import Chart.Attributes as CA
import Dict
import Html exposing (Html)

type alias ChartDatum =
    { index: Float
    , company: String
    , monthlySalary: Float
    }

chartData : List Datapoint -> List ChartDatum
chartData data =
    data
    |> companySalaries
    >> Dict.toList
    >> List.indexedMap f1
    >> List.concat

f1 : Int -> (String, List Float) -> List ChartDatum
f1 index (company, salaries) =
    let
        _ = Debug.log "company: " company
    in
    
    List.map
        (\salary -> 
            {index=index |> toFloat
            , company=company
            , monthlySalary=salary
            }
        )
        salaries

type Msg =
    Msg


view : List Datapoint -> Html Msg
view data =
    C.chart
      [ CA.height 200
      , CA.width 200
      ]
      [ C.xLabels [ CA.format (\x -> String.fromFloat x) ]
      , C.yLabels [ CA.withGrid ]
      , C.series .index
          [ C.scatter .monthlySalary []
          ]
          (data |> chartData)
      ]