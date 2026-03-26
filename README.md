# URI

A URI parser in Kast.

## Usage

```nim
const uri = include "src/lib.ks";

with uri.ctx = {
    .warn = msg => std.io.eprint(msg),
};
let uri :: uri.Uri = String.parse("https://example.com:8080/path?query=value#fragment");

uri |> dbg.print;
# {
#   .scheme = "https",
#   .authority = "example.com:8080",
#   .path = "/path",
#   .query = "query=value",
#   .fragment = "fragment",
# }

String.to_string(uri) |> std.io.print;
# https://example.com:8080/path?query=value#fragment
```

## Test

```sh
$ kast run tests/test.ks
all tests passed
# tests don't work on JS target because `==` doesn't perform structural equality
```
