module [handle!]

handle! : List U8 => Result Str []
handle! = \_ ->
    Ok
        """
        {"statusCode": 200,"headers":{"Content-Type": "text/html"},"body":"<h1>Hello, World!</h1>"}
        """
