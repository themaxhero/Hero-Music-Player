port module Prompt exposing(alertCmd)
import Json.Encode as E

port alert : E.Value -> Cmd msg

alertCmd : String -> Cmd msg
alertCmd =
  E.string >> alert