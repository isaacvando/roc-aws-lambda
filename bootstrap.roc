app "bootstrap"
    packages {
        pf: "./platform/main.roc",
    }
    imports [
        pf.Stdout,
        pf.Task.{ Task },
        pf.Env,
        pf.Http,
    ]
    provides [main] to pf

main =
    {} <- Stdout.line "hello world!" |> Task.await
    lambdaTaskRoot <- Env.var "LAMBDA_TASK_ROOT"
        |> Task.mapErr \_ -> 1
        |> Task.await
    handler <- Env.var "_HANDLER"
        |> Task.mapErr \_ -> 1
        |> Task.await

    runtimeApi <- Env.var "AWS_LAMBDA_RUNTIME_API"
        |> Task.mapErr \_ -> 1
        |> Task.await

    {} <- Stdout.line "$(runtimeApi)" |> Task.await

    {} <- Stdout.line "task root: $(lambdaTaskRoot) - handler: $(handler)" |> Task.await

    Task.forever (handle runtimeApi)

handle = \runtimeApi ->
    {} <- Stdout.line "in handle" |> Task.await
    eventResult <- { Http.defaultRequest & url: "http://$(runtimeApi)/2018-06-01/runtime/invocation/next" }
        |> Http.send
        |> Task.attempt

    when eventResult is
        Err e -> Stdout.line "Error during request: $(Inspect.toStr e)"
        Ok event ->
            headerString = Inspect.toStr event.headers
            Stdout.line "headers: $(headerString)"

