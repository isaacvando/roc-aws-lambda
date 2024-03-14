interface Handler
    exposes [handle]
    imports [pf.Task.{Task}]

handle : List U8 -> Task Str Str
handle = \_ -> 
    Task.ok "Hello, World!"
