module Types.Queue exposing (
  Queue,
  new, 
  play, 
  reset,
  moveLeft, 
  moveRight, 
  getLeftSong,
  getRightSong,
  current, 
  list, 
  foldl,
  foldr)
import Utils exposing (flip)
import Types.Song exposing (Song)

type alias Queue =
  (List Song, Song, List Song)

-- Public API

new : List Song -> Song -> Queue
new nextSongs currentSong =
  new3 [] currentSong nextSongs

getLeftSong : Queue -> Maybe Song
getLeftSong queue =
  case queue of
    ([], _, _) -> Nothing
    (head :: _, _, _) ->
      Just head

getRightSong : Queue -> Maybe Song
getRightSong queue =
  case queue of
    (_, _, []) -> Nothing
    (_, _, head :: _) ->
      Just head

new3 : List Song -> Song -> List Song -> Queue
new3 previous currentSong next =
  (previous, currentSong, next)

current : Queue -> Song
current (_, currentSong, _) =
  currentSong

moveLeft : Queue -> Queue
moveLeft queue =
  case queue of
    (_, _, []) ->
      queue
    (prev, currentSong, newCurrent :: next) ->
      new3 (currentSong :: prev) newCurrent next

moveRight : Queue -> Queue
moveRight queue =
  case queue of
    ([], _, _) ->
      queue
    (newCurrent :: prev, currentSong, next) ->
      new3 prev newCurrent (currentSong :: next)

reset : Queue -> Queue
reset queue =
  case queue of
    ([], _, []) ->
      queue
    (prev, currentSong, next) ->
      prev
        |> resetNext next currentSong
        |> Maybe.withDefault queue

list : Queue -> List Song
list (prev, currentSong, next) =
  currentSong
    |> flip (::) next
    |> (++) (List.reverse prev)

play : Song -> Queue -> Queue
play song queue =
  findSong song (reset queue)
  --case foldlWithSource searchReducer (song, False, reset queue) queue of
    --(_, True, newQueue) ->
      --newQueue
    --(_, False, _) ->
      --queue

foldl : (Song -> a -> a) -> a -> Queue -> a
foldl f acc queue =
  foldlHelper f acc (reset queue)

foldr : (Song -> a -> a) -> a -> Queue -> a
foldr f acc queue =
  foldrHelper f acc (finalState queue)

-- Private API

finalState : Queue -> Queue
finalState queue =
  case queue of
    ([], _, []) -> queue
    ([], _, _) -> queue
    _ -> finalState (moveRight queue)

foldlHelper : (Song -> a -> a) -> a -> Queue -> a
foldlHelper f acc queue =
  case queue of
    ([], _, []) -> acc
    (_, _, []) -> acc
    (_, currentSong, _) ->
      foldlHelper f (f currentSong acc) (moveLeft queue)

foldrHelper : (Song -> a -> a) -> a -> Queue -> a
foldrHelper f acc queue =
  case queue of
    (_, _, []) -> acc
    (_, currentSong, _) ->
      foldlHelper f (f currentSong acc) (moveRight queue)
      
findSong : Song -> Queue -> Queue
findSong song queue =
  if current queue == song then
    queue
  else
    findSong song (moveLeft queue)

resetCurrent : List Song -> Maybe Song
resetCurrent = List.reverse >> List.head

resetNextMaybe : List Song -> Song -> List Song -> List Song
resetNextMaybe next currentSong =
  List.reverse
  >> List.tail
  >> Maybe.map (flip (++) (currentSong :: next))
  >> Maybe.withDefault []

resetHelper : List Song -> Song -> Queue
resetHelper =
  flip (new3 [])

resetNext : List Song -> Song -> List Song -> Maybe Queue
resetNext next currentSong prev =
  let newNext = resetNextMaybe next currentSong prev
  in
    prev
      |> resetCurrent
      |> Maybe.map (resetHelper newNext)