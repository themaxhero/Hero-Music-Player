port module Audio exposing (
  resumeCmd,
  changeVolumeCmd,
  pauseCmd,
  muteCmd,
  stopCmd,
  updateDurationCmd,
  updateAudioSourceCmd,
  requestSourceSub,
  listenPlayerTimeSub,
  refreshSub,
  finishedSongSub,
  playSub)
import Json.Encode as E

-- Ports
port requestSource : (String -> msg) -> Sub msg
port updateAudioSource : E.Value -> Cmd msg
port play : (Bool -> msg) -> Sub msg
port updateDuration : E.Value -> Cmd msg
port pause : E.Value -> Cmd msg
port resume : E.Value -> Cmd msg
port stop : E.Value -> Cmd msg
port changeVolume : E.Value -> Cmd msg
port refresh : (Float -> msg) -> Sub msg
port mute : E.Value -> Cmd msg
port listenPlayerTime : (Float -> msg) -> Sub msg
port finishedSongSub : (Bool -> msg) -> Sub msg

changeVolumeCmd : Float -> Cmd msg
changeVolumeCmd value =
  changeVolume (E.float value)

requestSourceSub : (String -> msg) -> Sub msg
requestSourceSub =
  requestSource

playSub : (Bool -> msg) -> Sub msg
playSub =
  play

updateAudioSourceCmd : String -> Cmd msg
updateAudioSourceCmd =
  E.string >> updateAudioSource

refreshSub : (Float -> msg) -> Sub msg
refreshSub =
  refresh

listenPlayerTimeSub : (Float -> msg) -> Sub msg
listenPlayerTimeSub =
  listenPlayerTime

resumeCmd : Cmd msg
resumeCmd =
  resume (E.bool True)

updateDurationCmd : Cmd msg
updateDurationCmd = updateDuration (E.bool True)

muteCmd : Bool -> Cmd msg
muteCmd muted = mute (E.bool muted)

pauseCmd : Cmd msg
pauseCmd = pause (E.bool True)

stopCmd : Cmd msg
stopCmd = stop (E.bool True)
