module Utils exposing (flip, curry, uncurry)

flip : (a -> b -> c) -> b -> a -> c
flip f b a = f a b

uncurry : (a -> b -> c) -> (a, b) -> c
uncurry f (a, b) =
  f a b

curry: ((a,  b) -> c) -> a -> b -> c
curry f a b =
  f (a, b)