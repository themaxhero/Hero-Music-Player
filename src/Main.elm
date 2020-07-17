module Main exposing (init, main)
import Browser
import Audio
import Types.Song as Song
import Html exposing (Html)
import Model exposing (Model, initialModel)
import Message exposing (Msg(..))
import Element exposing (Element, Attribute, row, column, width, height, fill, rgb255)
import Element.Background as Background
import Component.Art as Art
import Component.Player as Player
import Component.Playlist as Playlist

type alias Flags = {}

type alias UpdateOutput =
  (Model, Cmd Msg)

mapToCoreUpdate: (msg -> Msg) -> (Model, Cmd msg) -> (Model, Cmd Msg)
mapToCoreUpdate f (model, cmd) =
  (model, Cmd.map f cmd)

update : Msg -> Model -> UpdateOutput
update msg model = 
  case msg of
    ArtMsg artMsg ->
      mapToCoreUpdate ArtMsg (Art.update artMsg model)
    PlayerMsg playerMsg ->
      mapToCoreUpdate PlayerMsg (Player.update playerMsg model)
    PlaylistMsg playlistMsg ->
      mapToCoreUpdate PlaylistMsg (Playlist.update playlistMsg model)
    SendSource ->
      handleUpdateAudioSource model

handleUpdateAudioSource : Model -> UpdateOutput
handleUpdateAudioSource model =
  let
    cmd =
      model
        |> Model.getCurrentSong
        |> Song.getUrl
        |> Audio.updateAudioSourceCmd
  in
    (model, cmd)

playerColumn : Model -> Element Msg
playerColumn model =
  column [ height fill, width fill ]
    [ Element.map ArtMsg (Art.view model)
    , Element.map PlayerMsg (Player.view model)
    ]

attr : List (Attribute Msg)
attr =
  [ height fill
  , width fill
  ]

view : Model -> Element Msg
view model =
  row attr
    [ Element.map PlaylistMsg (Playlist.view model)
    , playerColumn model
    ]

init : Flags -> (Model, Cmd Msg)
init _ =
  (initialModel, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Sub.map PlayerMsg <| Player.subscriptions model
    , Sub.map PlaylistMsg <| Playlist.subscriptions model
    , Audio.requestSourceSub (always SendSource)
    ]

mainNodeAttr : List (Attribute Msg)
mainNodeAttr =
  [ width fill, height fill, Background.color (rgb255 0x18 0x18 0x18) ]

elmUIWrapper : Model -> Html Msg
elmUIWrapper =
  view >> Element.layout mainNodeAttr

main : Program Flags Model Msg
main =
  Browser.element
    { init = init
    , view = elmUIWrapper
    , update = update
    , subscriptions = subscriptions
    }