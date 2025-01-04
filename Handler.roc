module [handle!]

handle! : List U8 => Result Str []
handle! = \_ ->
    Ok "Hello, World!"
