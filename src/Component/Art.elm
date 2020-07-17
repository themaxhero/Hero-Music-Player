module Component.Art exposing (Msg(..), subscriptions, update, view)
import Model exposing (Model)
import Types.Song as Song exposing (Song)
import Utils exposing (flip)
import Audio
import Element exposing (Element, el, row, px, width, height, fill, padding, spacing, text, centerX, paddingXY)
import Element.Events as Event
type Msg
  = Play (Maybe Song)

type alias UpdateOutput =
  (Model, Cmd Msg)

update : Msg -> Model -> UpdateOutput
update msg model =
  case msg of
    Play song ->
      handlePlay song model

handlePlay : Maybe Song -> Model -> UpdateOutput
handlePlay song model =
  let
    newModel = 
      Maybe.map (flip Model.goTo model) song
    cmd =
      newModel
        |> Maybe.withDefault model
        |> Model.getCurrentSong
        |> Song.getUrl
        |> Audio.updateAudioSourceCmd
  in
    (Maybe.withDefault model newModel, cmd)

subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none

placeholderImage : String
placeholderImage = "https://f4.bcbits.com/img/0018490865_10.jpg"

imageCover : 
  (Model -> Maybe Song) 
  -> (String -> Model -> Element Msg) 
  -> Model 
  -> Element Msg
imageCover songGetter coverArtCreator model =
  model
    |> songGetter 
    |> Maybe.map Song.getCoverArt 
    |> Maybe.map (Maybe.withDefault placeholderImage)
    |> Maybe.map (flip coverArtCreator model)
    |> Maybe.withDefault (text "")

leftCoverArt : String -> Model -> Element Msg
leftCoverArt image model =
  Element.image
    [ width (px 256)
    , height (px 256)
    , Event.onClick <| Play (Model.getLeftSong model)
    ]
    { src = image
    , description = ""
    }

centerCoverArt : Model -> Element Msg
centerCoverArt model =
  Element.image
    [ width (px 320)
    , height (px 320)
    , centerX
    ]
    { src = Maybe.withDefault placeholderImage (Model.centerCoverArt model)
    , description = ""
    }

rightCoverArt : String -> Model -> Element Msg
rightCoverArt image model =
  Element.image
    [ width (px 256)
    , height (px 256)
    , Event.onClick <| Play (Model.getRightSong model)
    ]
    { src = image
    , description = ""
    }

leftImagePadding : Model -> Int
leftImagePadding = 
  Model.getLeftSong >> Maybe.map (always 0) >> Maybe.withDefault 128

view : Model -> Element Msg
view model =
  el 
    [ width fill
    , height fill
    ]
    (row 
      [ padding 256
      , spacing 16
      ]
      [ el [ paddingXY (leftImagePadding model) 0] (imageCover Model.getLeftSong leftCoverArt model)
      , centerCoverArt model
      , imageCover Model.getRightSong rightCoverArt model
      ])