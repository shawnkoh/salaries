module Main exposing (..)

import Browser
import Html exposing (..)
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Json.Print


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
    |> Pipeline.required "Monthly/Annual Salary (Specify if not SGD)" Decode.float


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


