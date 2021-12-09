module SortedData exposing (..)

import Data exposing (Datapoint)

type SortedData = Sorted Datapoint (List Datapoint)

init : List Datapoint -> Maybe SortedData
init list =
    case (list |> List.sortBy .monthlySalary) of
        [] -> Nothing
        a::b -> Just (Sorted a b)

head : SortedData -> Datapoint
head (Sorted hd _) =
    hd

-- Edge case: dropping more than length - what happens?
get : Int -> SortedData -> Datapoint
get index (Sorted hd datapoints) =
    case index of
        0 -> hd
        1 -> Maybe.withDefault hd (List.head datapoints)
        _ -> 
            datapoints
            |> List.drop(index - 1)
            >> List.head
            >> Maybe.withDefault hd

length : SortedData -> Int
length (Sorted _ datapoints) =
    1 + List.length datapoints


toList : SortedData -> List Datapoint
toList (Sorted hd datapoints) =
    hd :: datapoints

-- foldl : (a -> b -> b) -> b -> List a -> b
foldl : (Datapoint -> b -> b) -> b -> SortedData -> b
foldl accumulator initialResult data =
    -- TODO: quick hack using List.foldl
    data
        |> toList 
        >> List.foldl accumulator initialResult
