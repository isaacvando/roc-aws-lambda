app [main!] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.18.0/0APbwVN1_p1mJ96tXjaoiUCr8NBGamr8G8Ac_DrXR-o.tar.br" }

import pf.Stdin
import pf.Stdout
import pf.Arg exposing [Arg]
import Handler

# An example for testing lambdas locally
main! : List Arg => Result {} _
main! = \_ ->
    input = Stdin.read_to_end! {} |> try
    response = Handler.handle! input |> try
    Stdout.line! response
