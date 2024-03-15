app "bootstrap"
    packages {
        pf: "./platform/main.roc",
    }
    imports [
        pf.Stdout,
        pf.Task.{ Task },
        pf.Env,
        pf.Http.{ Header },
        Handler,
    ]
    provides [main] to pf

# bootstrap.roc provides the runtime that fetches requests from AWS Lambda and passes them to the handler
main : Task {} I32
main =
    runtimeApi <- Env.var "AWS_LAMBDA_RUNTIME_API"
        |> try "Fetching the aws runtime api env var"

    Task.forever (respond runtimeApi)

respond : Str -> Task {} I32
respond = \runtimeApi ->
    event <- { Http.defaultRequest &
            url: "http://$(runtimeApi)/2018-06-01/runtime/invocation/next",
        }
        |> Http.send
        |> try "Fetching the request"

    requestId <- extractRequestId event.headers
        |> Task.fromResult
        |> try "Extracting the request id"

    response <- Handler.handle event.body
        |> try "Handling the request"

    _ <- { Http.defaultRequest &
            url: "http://$(runtimeApi)/2018-06-01/runtime/invocation/$(requestId)/response",
            body: Str.toUtf8 response,
            method: Post,
        }
        |> Http.send
        |> try "Sending the response to AWS"

    Task.ok {}

extractRequestId : List Header -> Result Str [NotFound]
extractRequestId = \headers ->
    List.findFirst headers \Header key _ ->
        key == "lambda-runtime-aws-request-id"
    |> Result.map \Header _ val -> 
        val

# If the task failed, print the error and exit, otherwise continue normally
try : Task a b, Str, (a -> Task c I32) -> Task c I32 where b implements Inspect
try = \task, message, callback ->
    Task.onErr task \error ->
        {} <- Stdout.line "$(message) failed with error: $(Inspect.toStr error)" |> Task.await
        Task.err 1
    |> Task.await callback
