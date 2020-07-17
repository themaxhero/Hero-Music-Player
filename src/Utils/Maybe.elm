module Utils.Maybe exposing (uncurry3)

uncurry3 : Maybe a -> Maybe b -> Maybe c -> Maybe (a, b, c)
uncurry3 ma mb mc =
  case (ma, mb, mc) of
    (Just a, Just b, Just c) ->
      Just (a, b, c)
    _ ->
      Nothing