module Data exposing (Data, Datapoint, decodeData, companySalaries, Status(..))

import Dict exposing (Dict)
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import SortedData exposing (SortedData)

type Status
    = FreshGrad
    | Internship

type alias Datapoint =
    { status : Status
    , company : String
    , role : String
    , monthlySalary : Float
    }

type alias Data =
    SortedData Datapoint

decodeData : Decode.Value -> Maybe Data
decodeData json =
    case Decode.decodeValue (sortedDataDecoder) json of
        Ok value ->
            Just value
        Err error ->
            let
                _ = Debug.log "error: " (Decode.errorToString error)
            in
            Nothing

sortedDataDecoder : Decode.Decoder (SortedData Datapoint)
sortedDataDecoder =
    Decode.list datapointDecoder
    |> Decode.map (SortedData.init .monthlySalary)
    >> Decode.andThen (\a ->
        case a of
            Just data -> Decode.succeed data
            Nothing -> Decode.fail <| "Expected SortedData but got empty data"
    )

datapointDecoder : Decode.Decoder Datapoint
datapointDecoder =
    Decode.succeed Datapoint
    |> Pipeline.required "Type" statusDecoder
    |> Pipeline.required "Company" companyDecoder
    |> Pipeline.required "Role" Decode.string
    |> Pipeline.required "Monthly/Annual Salary (Specify if not SGD)" stringThenFloat

companyDecoder : Decode.Decoder String
companyDecoder =
    Decode.string
    |> Decode.map formatCompanyName

statusDecoder : Decode.Decoder Status
statusDecoder =
    Decode.string
    |> Decode.andThen (\str ->
        case str of
           "Fresh Grad" -> Decode.succeed FreshGrad
           "Internship" -> Decode.succeed Internship
           _ -> Decode.fail <| "Expected Fresh Grad or Internship but got '" ++ str ++ "'"
    )

stringThenFloat : Decode.Decoder Float
stringThenFloat =
    Decode.string
    |> Decode.andThen (\str ->
        case String.toFloat str of
            Just f -> Decode.succeed f
            Nothing -> Decode.fail <| "Expected a float in a string but got '" ++ str ++ "'"
        )

companyNames : Dict String String
companyNames =
    Dict.fromList
        [ ("tiktok", "TikTok")
        , ("alphalab capital", "AlphaLab Capital")
        , ("bank of america", "Bank of America")
        , ("govtech", "GovTech")
        ]

formatCompanyName : String -> String
formatCompanyName company =
    Maybe.withDefault company (Dict.get company companyNames)

type alias CompanySalaries =
    Dict String (List Float)

companySalaries : Data -> CompanySalaries
companySalaries data =
    SortedData.foldl
        (\datum acc ->
            let
                alter : Maybe (List Float) -> Maybe (List Float)
                alter maybeCurrent =
                    case maybeCurrent of
                        Just current -> Just (datum.monthlySalary :: current)
                        Nothing -> Just [datum.monthlySalary]
            in
            Dict.update
                (case Dict.get (datum.company |> String.toLower) companyNames of
                    Just name -> name
                    Nothing -> datum.company
                )
                alter
                acc
        )
        Dict.empty
        data