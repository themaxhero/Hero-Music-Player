module Message exposing (Msg(..))
import Component.Art as Art
import Component.Player as Player
import Component.Playlist as Playerlist

type Msg
  = ArtMsg Art.Msg
  | PlayerMsg Player.Msg
  | PlaylistMsg Playerlist.Msg
  | SendSource