module Types.Song exposing (Song, Name, URL, CoverArt, getName, getUrl, getCoverArt)


type alias Name = String
type alias URL = String
type alias CoverArt = Maybe String

type alias Song =
  { name: Name
  , url: URL
  , coverArt: CoverArt
  }

getName : Song -> Name
getName = .name

getUrl : Song -> URL
getUrl = .url

getCoverArt : Song -> CoverArt
getCoverArt = .coverArt