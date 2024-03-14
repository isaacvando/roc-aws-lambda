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

main =
    lambdaTaskRoot <- Env.var "LAMBDA_TASK_ROOT"
        |> Task.mapErr \_ -> 1
        |> Task.await

    handler <- Env.var "_HANDLER"
        |> Task.mapErr \_ -> 1
        |> Task.await

    runtimeApi <- Env.var "AWS_LAMBDA_RUNTIME_API"
        |> Task.mapErr \_ -> 1
        |> Task.await

    Task.forever (respond runtimeApi)

respond = \runtimeApi ->
    eventResult <- { Http.defaultRequest & url: "http://$(runtimeApi)/2018-06-01/runtime/invocation/next" }
        |> Http.send
        |> Task.attempt

    when eventResult is
        Err e -> Stdout.line "Error during request: $(Inspect.toStr e)"
        Ok event ->
            when extractRequestId event.headers is
                Err _ -> Task.err 1
                Ok id ->
                    result <- Handler.handle event.body |> Task.attempt
                    when result is
                        Err e ->
                            {} <- Stdout.line e |> Task.await
                            Task.err 1

                        Ok msg ->
                            { Http.defaultRequest & url: "http://$(runtimeApi)/2018-06-01/runtime/invocation/$(id)/response", body: Str.toUtf8 msg, method: Post }
                            |> Http.send
                            |> Task.onErr \e ->
                                {} <- Stdout.line "$(Inspect.toStr e)" |> Task.await
                                Task.err 1
                            |> Task.map \_ -> {}

# extractRequestId : List Header -> Result Str [NoHeaderFound]
extractRequestId = \headers ->
    List.findFirst headers \Header key _ ->
        key == "lambda-runtime-aws-request-id"
    |> Result.map \Header _ val ->
        val

