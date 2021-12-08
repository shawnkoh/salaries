module PercentileGraph exposing (..)

import Data exposing (Datapoint)

-- assume rank is 0...1
-- TODO: Enforce constraint on rank with type
percentile : Float -> List Datapoint -> Maybe Datapoint
percentile rank data =
    let
        sortedData = data |> List.sortBy .monthlySalary
        index = round rank * (data |> List.length)
    in
    sortedData
    |> List.drop (index - 1)
    >> List.head


