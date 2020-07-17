module Component.Player exposing (view, update, subscriptions, Msg(..))
import Tuple
import Component.Common exposing (btnOpts)
import Utils exposing (flip)
import Element exposing (
  Element,
  Attribute,
  el,
  px,
  text,
  column,
  row,
  width,
  height,
  fill,
  shrink,
  padding,
  paddingXY,
  paddingEach,
  spacing,
  centerX,
  alignRight,
  rgb255)
import Element.Input as Input exposing (button, slider)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Audio
import Model exposing (Model, Volume)
import Types.Song as Song

-- Msg

type Msg
  = Resume
  | Pause
  | Stop
  | Prev
  | Next
  | Volume Volume
  | RepeatToggle
  | Mute
  | ChangePlayerTime Float
  | UpdatePlayerTime Float


-- update

type alias UpdateOutput =
  (Model, Cmd Msg)

update : Msg -> Model -> UpdateOutput
update msg model = 
  case msg of
    Resume ->
      handleResume model

    Pause ->
      handlePause model

    Stop ->
      handleStop model

    Prev ->
      handlePrev model

    Next ->
      handleNext model

    Volume value ->
      handleVolumeChange value model

    Mute ->
      handleMute model

    RepeatToggle ->
      handleRepeat model

    ChangePlayerTime _ ->
      (model, Cmd.none)

    UpdatePlayerTime  time ->
      handleUpdatePlayerTime time model

updateAudioSourceHelper : (Model -> Model) -> Model -> UpdateOutput
updateAudioSourceHelper f model =
  let
    newModel = f model
    cmd =
      newModel
        |> Model.getCurrentSong
        |> Song.getUrl
        |> Audio.updateAudioSourceCmd
  in
    (newModel, cmd)

handleResume : Model -> UpdateOutput
handleResume =
  Model.resume >> flip Tuple.pair Audio.resumeCmd

handlePause : Model -> UpdateOutput
handlePause =
  Model.pause >> flip Tuple.pair Audio.pauseCmd

handleStop : Model -> UpdateOutput
handleStop =
  Model.stop >> flip Tuple.pair Audio.stopCmd

handlePrev : Model -> UpdateOutput
handlePrev =
  updateAudioSourceHelper Model.prev

handleNext : Model -> UpdateOutput
handleNext =
  updateAudioSourceHelper Model.next

handleVolumeChange : Volume -> Model -> UpdateOutput
handleVolumeChange value =
  Model.changeVolume value
  >> flip Tuple.pair (Audio.changeVolumeCmd value)

handleMute : Model -> UpdateOutput
handleMute model =
  let
    cmd =
      model
        |> Model.isMuted
        |> not 
        |> Audio.muteCmd
  in
    model
      |> Model.toggleMute
      |> flip Tuple.pair cmd

handleRepeat : Model -> UpdateOutput
handleRepeat =
  Model.toggleRepeat >> flip Tuple.pair Cmd.none

handleUpdatePlayerTime : Float -> Model -> UpdateOutput
handleUpdatePlayerTime time = 
  Model.setPlayerTime time >> flip Tuple.pair Cmd.none

-- subscriptions
subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.batch
    [ Audio.listenPlayerTimeSub UpdatePlayerTime
    , Audio.finishedSongSub (always Next)
    , Audio.playSub (always Resume)
    ]

-- view

controlBtnAttr : List (Attribute Msg)
controlBtnAttr =
  [ Background.color (rgb255 0x28 0x28 0x28)
  , Font.color (rgb255 0xD4 0xD4 0xD4)
  , Border.rounded 16
  , padding 16
  ]

controlBtn : Msg -> String -> Element Msg
controlBtn msg label =
  button controlBtnAttr (btnOpts msg label)

playBtn : Element Msg
playBtn = controlBtn Resume "►"

stopBtn : Element Msg
stopBtn = controlBtn Stop "⏹️"

pauseBtn : Element Msg
pauseBtn = controlBtn Pause "⏸️"

prevBtn : Element Msg
prevBtn = controlBtn Prev "⏮️"

nextBtn : Element Msg
nextBtn = controlBtn Next "⏭️"

repeatToggleBtn : Element Msg
repeatToggleBtn = controlBtn RepeatToggle "⟳"


volumeOnLabel : Model -> String
volumeOnLabel model =
  let
    volume = Model.getVolume model
  in
    if volume == 0.0 then
      "🔈"
    else if volume <= 0.49 then
      "🔉"
    else
      "🔊"

volumeLabel : Model -> String
volumeLabel model =
  if Model.isMuted model then
    "🔇"
  else
    volumeOnLabel model

volumeBtn : Model -> Element Msg
volumeBtn =
  volumeLabel >> controlBtn Mute

volumeSlider : Model -> Element Msg
volumeSlider model =
  slider 
    [ width (px 128)
    , Element.behindContent
        (el
            [ width fill
            , height (px 2)
            , Element.centerY
            , Background.color (rgb255 0xD4 0xD4 0xD4)
            , Border.rounded 2
            ]
            Element.none
        )
    ]
    { onChange = Volume
    , label = Input.labelHidden "Volume"
    , min = 0.0
    , max = 1.0
    , value = Model.getVolume model
    , thumb = Input.defaultThumb
    , step = Just 0.001
    }

songTimeSlider : Model -> Element Msg
songTimeSlider model =
  slider 
    [ width fill
    , Element.behindContent
        (el
            [ width fill
            , height (px 2)
            , Element.centerY
            , Background.color (rgb255 0xD4 0xD4 0xD4)
            , Border.rounded 2
            ]
            Element.none
        )
    ]
    { onChange = ChangePlayerTime
    , label = Input.labelHidden "Song Time"
    , min = 0.0
    , max = Model.getTotalSongTime model
    , value = Maybe.withDefault 0.0 <| Model.getCurrentTime model
    , thumb = Input.defaultThumb
    , step = Just 0.01
    }

playPauseBtn : Model -> Element Msg
playPauseBtn model =
  if Model.isPlaying model then
    pauseBtn
  else
    playBtn

buttonBarAttr : List (Attribute Msg)
buttonBarAttr =
  let
    paddingRules =
      { top = 8
      , left = 8
      , right = 256
      , bottom = 8
      }
  in
    [ width shrink, centerX, paddingEach paddingRules]

buttonBarRow : Model -> Element Msg
buttonBarRow model =
  row [ padding 8, spacing 8 ] 
    [ repeatToggleBtn
    , stopBtn
    , prevBtn
    , playPauseBtn model
    , nextBtn
    , volumeBtn model
    , volumeSlider model
    ]

buttonBar : Model -> Element Msg
buttonBar = 
  buttonBarRow >> el buttonBarAttr

playerDisplayAttr : List (Attribute Msg)
playerDisplayAttr =
  [ paddingXY 256 8
  , alignRight
  , width fill
  , Font.color (rgb255 0xD4 0xD4 0xD4)
  ]

playerDisplay : Model -> Element Msg
playerDisplay = 
  Model.getCurrentSong
    >> Song.getName
    >> text
    >> el playerDisplayAttr

attr : List (Attribute Msg)
attr = 
  [ padding 8
  , width fill
  ]

view : Model -> Element Msg
view model =
  column attr
    [ playerDisplay model
    , songTimeSlider model
    , buttonBar model
    ]