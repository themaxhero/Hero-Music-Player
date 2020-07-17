module Decoder.Song exposing (song, songList)
import Types.Song exposing (Song)
import Json.Decode as D exposing (Decoder)
import Json.Decode.Pipeline exposing (required, optional)


song : Decoder Song
song =
  D.succeed Song
    |> required "name" D.string
    |> required "url" D.string
    |> optional "coverArt" (D.maybe D.string) Nothing 

songList : Decoder (List Song)
songList =
  D.list song