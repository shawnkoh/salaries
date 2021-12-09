module Percentile exposing (..)

type Percentile = Percentile Float

init : Float -> Maybe Percentile
init rank =
    if rank >= 0 && rank <= 100 then
        Just (Percentile rank)
    else
        Nothing

rawValue : Percentile -> Float
rawValue (Percentile rank) =
    rank
