module Utils.Tuple exposing (flat, reverse, triple, mapTripleFirst, mapTripleSecond, mapTripleThird)

flat : ((a, b), c) -> (a, b, c)
flat ((a,b), c) = (a, b, c)

reverse : (a, b) -> (b, a)
reverse (a, b) = (b, a)

triple : a -> b -> c -> (a, b, c)
triple a b c = (a, b, c)

mapTripleFirst : (a, b, c) -> (a -> d) -> (d, b, c)
mapTripleFirst (a, b, c) f = (f a, b, c)

mapTripleSecond : (a, b, c) -> (b -> d) -> (a, d, c)
mapTripleSecond (a, b, c) f = (a, f b, c)

mapTripleThird : (a, b, c) -> (c -> d) -> (a, b, d)
mapTripleThird (a, b, c) f = (a, b, f c)