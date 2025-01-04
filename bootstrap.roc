app [main!] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.18.0/0APbwVN1_p1mJ96tXjaoiUCr8NBGamr8G8Ac_DrXR-o.tar.br" }

import pf.Env
import pf.Http
import pf.Arg exposing [Arg]
import Handler

# bootstrap.roc provides the runtime that fetches requests from AWS Lambda and passes them to the handler
main! : List Arg => Result {} _
main! = \_ ->
    runtimeApi = Env.var! "AWS_LAMBDA_RUNTIME_API" |> try

    # Task.forever (respond runtimeApi)
    respond! runtimeApi

respond! : Str => Result {} _
respond! = \runtimeApi ->
    event =
        { Http.default_request &
            uri: "http://$(runtimeApi)/2018-06-01/runtime/invocation/next",
        }
        |> Http.send!

    requestId =
        List.findFirst event.headers \{ name } ->
            name == "lambda-runtime-aws-request-id"
        |> Result.map .value
        |> try

    response = Handler.handle! event.body |> try

    _ =
        { Http.default_request &
            uri: "http://$(runtimeApi)/2018-06-01/runtime/invocation/$(requestId)/response",
            body: Str.toUtf8 response,
            method: Post,
        }
        |> Http.send!

    Ok {}
