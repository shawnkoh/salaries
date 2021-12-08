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

companyNames =
    Dict.fromList
        [ ("tiktok", "TikTok")
        , ("alphalab capital", "AlphaLab Capital")
        , ("bank of america", "Bank of America")
        , ("govtech", "GovTech")
        ]

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
            data |> scatter
        Nothing ->
            div []
            [ text "Data failed to load" ]

-- x axis: company
-- y axis: salary
scatter : List Datapoint -> Html Msg
scatter data =
    C.chart
      [ CA.height 300
      , CA.width 300
      ]
      [ C.xLabels [ CA.withGrid ]
      , C.yLabels [ CA.withGrid ]
      , C.series .index
          [ C.scatter .monthlySalary []
          ]
          (data |> chartData)
      ]

--series : (data -> Float) -> List (Property data CS.Interpolation CS.Dot) -> List data -> Element data msg
--series toX properties data =

-- the objective of scatter is provide a lens into how to manipulate the data type.
--scatter : (data -> Float) -> List (Attribute CS.Dot) -> Property data inter CS.Dot
--scatter y =

type alias ChartDatum =
    { index: Float -- maybe this needs to be a float?
    , company: String
    , monthlySalary: Float
    }

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

chartData : List Datapoint -> List ChartDatum
chartData data =
    data
    |> companySalaries
    |> Dict.toList
    |> List.indexedMap f1
    |> List.concat

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
