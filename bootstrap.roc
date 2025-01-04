app [main!] { pf: platform "https://github.com/roc-lang/basic-cli/releases/download/0.18.0/0APbwVN1_p1mJ96tXjaoiUCr8NBGamr8G8Ac_DrXR-o.tar.br" }

import pf.Env
import pf.Http
import pf.Arg exposing [Arg]
import Handler

# bootstrap.roc provides the runtime that fetches requests from AWS Lambda and passes them to the handler
main! : List Arg => Result {} _
main! = \_ ->
    runtime_api =
        Env.var! "AWS_LAMBDA_RUNTIME_API"
        |> Result.mapErr \_ -> Exit 1 "Unable to read AWS_LAMBDA_RUNTIME_API"
        |> try

    loop! = \{} ->
        try respond! runtime_api
        loop! {}
    loop! {}

respond! : Str => Result {} _
respond! = \runtime_api ->
    event =
        Http.default_request
        |> &uri "http://$(runtime_api)/2018-06-01/runtime/invocation/next"
        |> Http.send!

    request_id =
        List.findFirst event.headers \{ name } ->
            name == "lambda-runtime-aws-request-id"
        |> Result.map .value
        |> Result.mapErr \_ -> MissingRequestIdHeader
        |> try

    response =
        when Handler.handle! event.body is
            Ok msg -> msg
            Err tag -> Inspect.toStr tag

    _ =
        Http.default_request
        |> &uri "http://$(runtime_api)/2018-06-01/runtime/invocation/$(request_id)/response"
        |> &body (Str.toUtf8 response)
        |> &method Post
        |> Http.send!

    Ok {}
