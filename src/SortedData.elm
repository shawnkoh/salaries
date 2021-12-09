module SortedData exposing (..)

-- TODO: This can be optimised by leveraging a different data structure
-- like a record type.
type SortedData a = Sorted a (List a)

init : (a -> comparable) -> List a -> Maybe (SortedData a)
init comparison list =
    case (list |> List.sortBy comparison) of
        [] -> Nothing
        a::b -> Just (Sorted a b)

head : SortedData a -> a
head (Sorted hd _) =
    hd

-- Edge case: dropping more than length - what happens?
get : Int -> SortedData a -> a
get index (Sorted hd list) =
    case index of
        0 -> hd
        1 -> Maybe.withDefault hd (List.head list)
        _ ->
            list
                |> List.drop(index - 1)
                >> List.head
                >> Maybe.withDefault hd

-- Warning: This is O(N)
length : SortedData a -> Int
length (Sorted _ list) =
    1 + List.length list


toList : SortedData a -> List a
toList (Sorted hd list) =
    hd :: list

foldl : (a -> b -> b) -> b -> SortedData a -> b
foldl accumulator initialResult (Sorted hd list) =
    List.foldl accumulator (accumulator hd initialResult) list

partition : (a -> Bool) -> SortedData a -> ( List a, List a )
partition predicate data =
    data
    |> toList
    >> List.partition predicate