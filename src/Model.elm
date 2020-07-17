module Model exposing (
  Model,
  Volume,
  initialModel,
  getTotalSongTime,
  setTotalSongTime,
  toggleUrlEditing,
  stopEditing,
  getCurrentTime,
  getEditingUrl,
  setEditingUrl,
  editUrl,
  isEnteringUrl,
  leftCoverArt,
  rightCoverArt,
  centerCoverArt,
  getLeftSong,
  getRightSong,
  isPlaying,
  goTo,
  resume,
  pause,
  stop,
  prev,
  next,
  setPlayerTime,
  isCurrentSong,
  changeVolume,
  getVolume,
  toggleMute,
  toggleRepeat,
  getPlaylist,
  setPlaylist,
  isMuted,
  updateTime,
  getCurrentSong)
import Utils exposing (flip)
import Types.Song as Song exposing (Song, CoverArt)
import Types.Queue as Queue exposing (Queue)

type alias Volume = Float
type alias Time = Float

type EditingUrlState
  = Editing String
  | NotEditing

type State
  = Playing Time
  | Paused Time
  | StandBy

type alias Model =
  { state: State
  , volume: Volume
  , queue: Queue
  , enteringUrl: EditingUrlState
  , muted: Bool
  , totalSongTime: Float
  , repeat: Bool
  }

dummyQueue : Queue
dummyQueue =
  let
    previous =
      [ Song
          "SoundHelix Song 1"
          "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"
          (Just "https://static.billboard.com/files/media/The-Beatles-Abbey-Road-album-covers-billboard-1000x1000-compressed.jpg")
      ]
    currentSong =
      Song
        "SoundHelix Song 2"
        "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3"
        (Just "https://i.pinimg.com/736x/b3/4d/80/b34d80d0fd9052988f18e63ae338d201--queen-queen-vinyl-lp.jpg")
    
    next_ =
      [ Song
          "SoundHelix Song 3"
          "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3"
          (Just "http://www.progarchives.com/progressive_rock_discography_covers/1755/cover_21311424102016_r.jpg")
      ]
  in
    (previous, currentSong, next_)

-- Public API
initialModel : Model
initialModel =
  { state = Paused 0.0
  , volume = 1.0
  , queue = dummyQueue
  , enteringUrl = NotEditing
  , muted = False
  , totalSongTime = 0.0
  , repeat = False
  }

isPlaying : Model -> Bool
isPlaying model =
  case model.state of
     Playing _ -> True
     _ -> False

toggleUrlEditing : Model -> Model
toggleUrlEditing model =
  case model.enteringUrl of
    NotEditing ->
      { model | enteringUrl = Editing "" }

    Editing _ ->
      { model | enteringUrl = NotEditing }


editUrl : Model -> Model 
editUrl model =
  case model.enteringUrl of
    NotEditing ->
      { model | enteringUrl = Editing "" }

    Editing _ ->
      model

stopEditing : Model -> Model
stopEditing model =
  case model.enteringUrl of
    NotEditing ->
      model

    Editing _ ->
      { model | enteringUrl = NotEditing }

isEnteringUrl : Model -> Bool
isEnteringUrl model = 
  case model.enteringUrl of
    NotEditing -> False
    Editing _ -> True

getEditingUrl : Model -> Maybe String
getEditingUrl model =
  case model.enteringUrl of
    Editing string -> Just string
    NotEditing -> Nothing

setEditingUrl : String -> Model -> Model
setEditingUrl url model =
  case model.enteringUrl of
    Editing _ ->
      { model | enteringUrl = Editing url }

    NotEditing ->
      model

isCurrentSong : Song -> Model -> Bool
isCurrentSong song =
  getQueue >> Queue.current >> (==) song

getCurrentTime : Model -> Maybe Time
getCurrentTime model =
  case model.state of
    Playing time -> Just time
    Paused time -> Just time
    _ -> Nothing

getTotalSongTime : Model -> Float
getTotalSongTime = .totalSongTime

setTotalSongTime : Float -> Model -> Model
setTotalSongTime time model =
  { model | totalSongTime = time }

getLeftSong : Model -> Maybe Song
getLeftSong =
  getQueue >> Queue.getLeftSong

getRightSong : Model -> Maybe Song
getRightSong =
  getQueue >> Queue.getRightSong

leftCoverArt : Model -> CoverArt
leftCoverArt =
  getLeftSong >> Maybe.andThen Song.getCoverArt

centerCoverArt : Model -> CoverArt
centerCoverArt =
  getCurrentSong >> Song.getCoverArt

rightCoverArt : Model -> CoverArt
rightCoverArt =
  getRightSong >> Maybe.andThen Song.getCoverArt

isMuted : Model -> Bool
isMuted = .muted

getVolume : Model -> Volume
getVolume = .volume

setPlayerTime : Float -> Model -> Model
setPlayerTime time model =
  case model.state of
    Playing _ -> 
      setState (Playing time) model
    Paused _ ->
      setState (Paused time) model
    _ ->
      model

resume : Model -> Model
resume model =
  case model.state of
    Paused time ->
      { model | state = Playing time }
    _ ->
      model

pause : Model -> Model
pause model =
  case model.state of 
    Playing time ->
      { model | state = Paused time }
    _ ->
      model

stop : Model -> Model
stop ({ queue } as model) =
  { model | state = StandBy, queue = Queue.reset queue }

updateTime : Float -> Model -> Model
updateTime time model =
  case model.state of
    Playing _ ->
      { model | state = Playing time }
    _ ->
      model

prev : Model -> Model
prev model =
  model
    |> getQueue
    |> Queue.moveRight
    |> flip setQueue model

next : Model -> Model
next model =
  model
    |> getQueue
    |> Queue.moveLeft
    |> flip setQueue model

changeVolume : Volume -> Model -> Model
changeVolume value model =
  { model | volume = value }

toggleMute : Model -> Model
toggleMute model =
  { model | muted = not model.muted }

toggleRepeat : Model -> Model
toggleRepeat model =
  { model | repeat = not model.repeat }

getCurrentSong : Model -> Song
getCurrentSong =
  getQueue >> Queue.current

getPlaylist : Model -> List Song
getPlaylist =
  getQueue >> Queue.list

setPlaylist : List Song -> Model -> Model
setPlaylist playlist model =
  case playlist of
    [] -> model
    head :: tail ->
      setQueue (Queue.new tail head) model

goTo : Song -> Model -> Model
goTo song model =
  model
    |> getQueue
    |> Queue.play song
    |> flip setQueue model
    

-- Private API

setState : State -> Model -> Model
setState state model =
  { model | state = state }

getQueue : Model -> Queue
getQueue =
  .queue

setQueue : Queue -> Model -> Model
setQueue queue model =
  { model | queue = queue }
