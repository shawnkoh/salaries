module Percentile exposing (..)

type Percentile = Percentile Float

init : Float -> Maybe Percentile
init rank =
    if rank > 0 && rank <= 100 then
        Just (Percentile rank)
    else
        Nothing

rawValue : Percentile -> Float
rawValue (Percentile rank) =
    rank

-- TODO: This should accept a count input instead
range : Int -> Int -> List Percentile
range start end =
    List.range start end
        |> List.filterMap (toFloat >> init)