app "bootstrap"
    packages {
        pf: "./platform/main.roc",
    }
    imports [
        pf.Stdout,
        pf.Task.{ Task },
        pf.Stdin,
        Handler,
    ]
    provides [main] to pf

# local.roc provides a way to test lambdas locally
main : Task {} I32
main =
    input <- readAllStdin |> Task.await
    response <- Handler.handle (Str.toUtf8 input)
        |> Task.onErr \error ->
            {} <- Stdout.line error |> Task.await
            Task.err 1
        |> Task.await
    Stdout.line response

readAllStdin : Task Str I32
readAllStdin =
    Task.loop "" \lines ->
        result <- Stdin.line |> Task.await
        state =
            when result is
                Input line -> Step (Str.joinWith [lines, line] "\n")
                End -> Done lines
        Task.ok state
