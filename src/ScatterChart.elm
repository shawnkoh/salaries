module ScatterChart exposing (view, Model, Msg, update, init)

import Data exposing (Data)
import Chart as C
import Chart.Attributes as CA
import Chart.Item as CI
import Chart.Events as CE
import Dict
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

type alias Datum =
    { index: Float
    , company: String
    , monthlySalary: Float
    }

chartData : Data -> List Datum
chartData data =
    data
    |> Data.companySalaries
    >> Dict.toList
    >> List.indexedMap f1
    >> List.concat

f1 : Int -> (String, List Float) -> List Datum
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

view : Data -> Html Msg
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