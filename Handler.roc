module [handle!]

handle! : List U8 => Result Str _
handle! = \_ ->
    Ok "Hello, World!"
