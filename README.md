# Hero Music Player

## Introduction
I've made this music player for exercising my elm skills.

![Image of Hero Music Player](https://i.imgur.com/MWreKdx.png)

## How to Run
```
$ npm i
$ make dev
```
## Playlists
This App accepts playlists using the following format:

```
[ 
  { 
    "name": "SoundHelix Song 1",
    "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
    "coverArt": "https://static.billboard.com/files/media/The-Beatles-Abbey-Road-album-covers-billboard-1000x1000-compressed.jpg"
  }, 
  { 
    "name": "SoundHelix Song 2",
    "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
    "coverArt": "https://i.pinimg.com/736x/b3/4d/80/b34d80d0fd9052988f18e63ae338d201--queen-queen-vinyl-lp.jpg"
  }, 
  { 
    "name": "SoundHelix Song 3",
    "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
    "coverArt": "http://www.progarchives.com/progressive_rock_discography_covers/1755/cover_21311424102016_r.jpg"
  }, 
  { 
    "name": "SoundHelix Song 4",
    "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3",
    "coverArt": "https://images-na.ssl-images-amazon.com/images/I/712rNEMlyQL.jpg"
  }
]
```
The `coverArt` property is optional.
