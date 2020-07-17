module Component.Playlist exposing (Msg(..), update, view, subscriptions)
import Model exposing (Model)
import Types.Song as Song exposing (Song)
import Decoder.Song as SongD
import Http
import Audio
import Prompt
import Utils exposing (flip)
import Component.Common exposing (btnOpts)
import Element exposing (Element,
  Attribute,
  column,
  row,
  text,
  padding,
  spacing,
  shrink,
  centerX,
  rgb255,
  width,
  height,
  fill,
  el,
  px,
  paddingXY)
import Element.Input as Input exposing (button)
import Element.Events as Events
import Element.Background as Background
import Element.Font as Font
import Element.Border as Border

type Msg
  = Play Song
  | SetTotalSongTime Float
  | EnterPlaylistUrl
  | HandlePlaylist (List Song)
  | LoadPlaylist
  | UpdateTypingUrl String
  | Alert String

getPlaylistCmdErrorHandling : Result Http.Error (List Song) -> Msg
getPlaylistCmdErrorHandling result =
  case result of
    Ok playlist ->
      HandlePlaylist playlist
    Err (Http.BadUrl string) ->
      Alert ("Bad URL: " ++ string)
    Err (Http.Timeout) ->
      Alert "Timeout while trying to get the Playlist"
    Err _ ->
      Alert "Could not fetch Playlist"

getPlaylistCmd : String -> Cmd Msg
getPlaylistCmd url =
  Http.get 
    { url = url
    , expect = Http.expectJson getPlaylistCmdErrorHandling SongD.songList
    }

type alias UpdateOutput = (Model, Cmd Msg)

update : Msg -> Model -> UpdateOutput
update msg model = 
  case msg of
    Play song ->
      handlePlay song model
    EnterPlaylistUrl ->
      handleEnterPlaylistUrl model
    LoadPlaylist ->
      handleLoadPlaylist model
    HandlePlaylist playlist ->
      handlePlaylist playlist model
    SetTotalSongTime time ->
      handleSetTotalSongTime time model
    UpdateTypingUrl url ->
      handleUpdateTypingUrl url model
    Alert message ->
      sendAlert message model

handlePlay : Song -> Model -> UpdateOutput
handlePlay song model =
  let
    newModel = Model.goTo song model
    cmd =
      newModel
        |> Model.getCurrentSong
        |> Song.getUrl
        |> Audio.updateAudioSourceCmd
  in
    (newModel, cmd)
    

handlePlaylist : List Song -> Model -> UpdateOutput
handlePlaylist playlist =
  Model.setPlaylist playlist >> flip Tuple.pair Audio.resumeCmd

handleSetTotalSongTime : Float -> Model -> UpdateOutput
handleSetTotalSongTime time =
  Model.setTotalSongTime time >> flip Tuple.pair Cmd.none

handleUpdateTypingUrl : String -> Model -> UpdateOutput
handleUpdateTypingUrl url =
  Model.setEditingUrl url >> flip Tuple.pair Cmd.none

handleEnterPlaylistUrl : Model -> UpdateOutput
handleEnterPlaylistUrl =
  Model.toggleUrlEditing >> flip Tuple.pair Cmd.none

handleLoadPlaylist : Model -> UpdateOutput
handleLoadPlaylist model =
  model
    |> Model.getEditingUrl
    |> Maybe.withDefault ""
    |> getPlaylistCmd
    |> Tuple.pair (Model.stopEditing model)

sendAlert : String -> Model -> UpdateOutput
sendAlert text =
  flip Tuple.pair (Prompt.alertCmd text)

-- view

btn : List (Attribute Msg) -> Msg -> String -> Element Msg
btn btnAttr msg label =
  button btnAttr (btnOpts msg label)

loadPlaylistBtnAttr : List (Attribute Msg)
loadPlaylistBtnAttr =
  [ Background.color (rgb255 0x58 0x58 0x58)
  , Font.color (rgb255 0xD4 0xD4 0xD4)
  , Border.rounded 8
  , padding 8
  ]

loadPlaylistBtn : Element Msg
loadPlaylistBtn =
  btn loadPlaylistBtnAttr EnterPlaylistUrl "📂"


insertPlaylistLinkDialogRow : Model -> Element Msg
insertPlaylistLinkDialogRow model =
  row [ spacing 8 ]
    [ Input.text  [ width fill , height (px 32) , padding 4 ]
      { onChange = UpdateTypingUrl
      , text = Maybe.withDefault "" <| Model.getEditingUrl model
      , placeholder = Nothing
      , label = Input.labelHidden "Enter Playlist URL"
      }
    , button
      [ padding 8
      , height <| px 32
      , Background.color <| rgb255 0x58 0x58 0x58
      , Font.size 14
      , Border.rounded 8
      ]
      { onPress = Just LoadPlaylist
      , label = text "Load"
      }
    ]

insertPlaylistLinkDialog : Model -> Element Msg
insertPlaylistLinkDialog model =
  column [ paddingXY 24 16, spacing 8 ]
    [ el [ Font.size 14 ] (text "Please Enter the url for the playlist json")
    , insertPlaylistLinkDialogRow model
    ]

playlistMemberColor : Song -> Model -> Attribute Msg
playlistMemberColor song model =
  if Model.isCurrentSong song model then
    Font.color (rgb255 0xFF 0xa5 0x00)
  else
    Font.color (rgb255 0xD4 0xD4 0xD4)

playlistMemberAttr : Song -> Model -> List (Attribute Msg)
playlistMemberAttr song model =
  [ padding 8
  , width fill
  , playlistMemberColor song model
  , Font.size 16
  , Events.onClick <| Play song
  ]

playlistMember : Song -> Model -> List (Element Msg) -> Element Msg
playlistMember song model =
  row (playlistMemberAttr song model)

playlistMemberMapper : Song -> Model -> Element Msg
playlistMemberMapper song model =
  song
    |> Song.getName
    |> text
    |> List.singleton 
    |> playlistMember song model

titleBarRow : Element Msg
titleBarRow =
  row 
    [ width shrink
    , centerX
    , Font.center
    , spacing 16
    ] 
    [ text "Playlist"
    , loadPlaylistBtn
    ]

editingUrl : Model -> Element Msg
editingUrl model =
  if Model.isEnteringUrl model then
    insertPlaylistLinkDialog model
  else
    text ""


titleBar : Model -> Element Msg
titleBar model =
  column 
    [ width fill
    , paddingXY 8 16
    , Background.color (rgb255 0x38 0x38 0x38)
    , Font.color (rgb255 0xD4 0xD4 0xD4)
    ]
    [ titleBarRow
    , editingUrl model
    ]

songListAttr : List (Attribute Msg)
songListAttr =
  [ padding 8 ]

songList : List (Element Msg) -> Element Msg
songList =
  column songListAttr

attr : List (Attribute Msg)
attr =
  [ width (px 360)
  , height fill
  , Background.color (rgb255 0x28 0x28 0x28)
  ]

view : Model -> Element Msg
view model =
  model
    |> Model.getPlaylist
    |> List.map (flip playlistMemberMapper model)
    |> songList
    |> List.singleton
    |> (::) (titleBar model)
    |> column attr

subscriptions : Model -> Sub Msg
subscriptions _ =
  Audio.refreshSub SetTotalSongTime