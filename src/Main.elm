module Main exposing (..)

import Browser
import Html exposing (..)
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Json.Print
import Chart as C
import Chart.Attributes as CA
import Set exposing (Set)
import Dict exposing (Dict)


main : Program Decode.Value Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { data: Maybe (List Datapoint) }


type alias Datapoint =
    { status : String
    , company : String
    , role : String
    , monthlySalary : Float
    }


type Status
    = FreshGrad
    | Internship

datapointDecoder : Decode.Decoder Datapoint
datapointDecoder =
    Decode.succeed Datapoint
    |> Pipeline.required "Type" Decode.string
    |> Pipeline.required "Company" Decode.string
    |> Pipeline.required "Role" Decode.string
    |> Pipeline.required "Monthly/Annual Salary (Specify if not SGD)" stringThenFloat

stringThenFloat : Decode.Decoder Float
stringThenFloat =
    Decode.string
    |> Decode.andThen (\str ->
        case String.toFloat str of
            Just f -> Decode.succeed f
            Nothing -> Decode.fail <| "Expected a float in a string but got '" ++ str ++ "'"
        )



decodeModel : Decode.Value -> Model
decodeModel json =
    let
        _ = Debug.log "json: " (Json.Print.prettyValue (Json.Print.Config 4 4) json)
    in
    case Decode.decodeValue (Decode.list datapointDecoder) json of
        Ok value ->
            let
                _ = Debug.log "value: " value
            in
            Model (Just value)
        Err error ->
            let
                _ = Debug.log "error: " (Decode.errorToString error)
            in
            Model Nothing


init : Decode.Value -> ( Model, Cmd Msg )
init csv =
    ( decodeModel csv, Cmd.none )


type Msg
    = Msg1
    | Msg2


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg1 ->
            ( model, Cmd.none )

        Msg2 ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    case model.data of
        Just data ->
            div []
            [ text "Data loaded" ]
        Nothing ->
            div []
            [ text "Data failed to load" ]

-- x axis: company
-- y axis: salary
--scatter : List Datapoint -> Html.Html Msg
--scatter data =
--    let
--        companies : List (Int, (String, List Float))
--        companies = data
--            |> companySalaries
--            >> Dict.toList
--            >> List.indexedMap Tuple.pair

--    in
--    C.chart
--      [ CA.height 300
--      , CA.width 300
--      ]
--      [ C.xLabels [ CA.withGrid ]
--      , C.yLabels [ CA.withGrid ]
----      -- series .company determines x value
--      , C.series .first
--          [ C.scatter .second []
--          ]
--          companies
--      ]

type alias CompanySalaries =
    Dict String (List Float)

companySalaries : List Datapoint -> CompanySalaries
companySalaries data =
    List.foldl
        (\datum acc ->
            let
                alter : Maybe (List Float) -> Maybe (List Float)
                alter maybeCurrent =
                    case maybeCurrent of
                        Just current ->
                            Just (datum.monthlySalary :: current)
                        Nothing ->
                            Just [datum.monthlySalary]
            in
            Dict.update 
                datum.company
                alter
                acc
        )
        Dict.empty
        data

-- MVP: Scatter chart
-- x-axis: company name
-- y-axis: monthlySalary



