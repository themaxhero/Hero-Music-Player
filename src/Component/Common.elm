module Component.Common exposing (ButtonOptions, btnOpts)
import Element exposing (Element, text)

type alias ButtonOptions msg =
  { onPress : Maybe msg
  , label: Element msg
  }
btnOpts : msg -> String -> ButtonOptions msg
btnOpts msg label =
  { onPress = Just msg, label = text label }
