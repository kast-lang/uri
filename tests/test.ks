const uri = include "../src/lib.ks";

const test = (id :: UInt32, s :: String, expected :: uri.Uri, diff_output :: Option.t[String]) => (
    with uri.ctx = {
        .warn = error => (
            dbg.print("error parsing: " + error);
            panic("test " + String.to_string(id) + " failed");
        ),
    };
    let parsed = String.parse[uri.Uri](s);
    if parsed != expected then (
        std.io.print("expected uri mismatch");
        dbg.print({ .expected, .found = parsed });
        panic("test " + String.to_string(id) + " failed");
    );
    let back_to_string = String.to_string(parsed);
    if back_to_string != s then (
        if diff_output is :Some s then (
            if back_to_string != s then (
                std.io.print("expected format mismatch");
                dbg.print({ .expected = s, .found = back_to_string });
                panic("test " + String.to_string(id) + " failed");
            )
        ) else (
            std.io.print("expected format mismatch");
            dbg.print({ .expected = s, .found = back_to_string });
            panic("test " + String.to_string(id) + " failed");
        )
    );
);

test(
    1,
    "http://example.com",
    {
        .scheme = "http",
        .authority = "example.com",
        .path = "",
        .query = "",
        .fragment = "",
    },
    :None
);

test(
    2,
    "https://example.com/path/to/resource",
    {
        .scheme = "https",
        .authority = "example.com",
        .path = "/path/to/resource",
        .query = "",
        .fragment = "",
    },
    :None
);

test(
    3,
    "https://example.com:8080/path?query=value#fragment",
    {
        .scheme = "https",
        .authority = "example.com:8080",
        .path = "/path",
        .query = "query=value",
        .fragment = "fragment",
    },
    :None
);

test(
    4,
    "http://user:pass@example.com/secure",
    {
        .scheme = "http",
        .authority = "user:pass@example.com",
        .path = "/secure",
        .query = "",
        .fragment = "",
    },
    :None
);

test(
    5,
    "file:///home/user/Downloads/",
    {
        .scheme = "file",
        .authority = "",
        .path = "/home/user/Downloads/",
        .query = "",
        .fragment = "",
    },
    :Some "file:/home/user/Downloads/"
);

test(
    6,
    "file:/C:/Program%20Files/App/",
    {
        .scheme = "file",
        .authority = "",
        .path = "/C:/Program%20Files/App/",
        .query = "",
        .fragment = "",
    },
    :None
);

test(
    7,
    "mailto:user@example.com",
    {
        .scheme = "mailto",
        .authority = "",
        .path = "user@example.com",
        .query = "",
        .fragment = "",
    },
    :None
);

test(
    8,
    "urn:isbn:0451450523",
    {
        .scheme = "urn",
        .authority = "",
        .path = "isbn:0451450523",
        .query = "",
        .fragment = "",
    },
    :None
);

test(
    9,
    "data:text/plain;base64,SGVsbG8sIFdvcmxkIQ==",
    {
        .scheme = "data",
        .authority = "",
        .path = "text/plain;base64,SGVsbG8sIFdvcmxkIQ==",
        .query = "",
        .fragment = "",
    },
    :None
);

test(
    10,
    "http://192.168.1.1/",
    {
        .scheme = "http",
        .authority = "192.168.1.1",
        .path = "/",
        .query = "",
        .fragment = "",
    },
    :None
);

test(
    11,
    "http://[2001:db8::1]/index.html",
    {
        .scheme = "http",
        .authority = "[2001:db8::1]",
        .path = "/index.html",
        .query = "",
        .fragment = "",
    },
    :None
);

test(
    12,
    "https://example.com//double//slashes///",
    {
        .scheme = "https",
        .authority = "example.com",
        .path = "//double//slashes///",
        .query = "",
        .fragment = "",
    },
    :None
);

test(
    13,
    "https://example.com/./a/../b/",
    {
        .scheme = "https",
        .authority = "example.com",
        .path = "/./a/../b/",
        .query = "",
        .fragment = "",
    },
    :None
);

test(
    14,
    "https://example.com/%7Euser",
    {
        .scheme = "https",
        .authority = "example.com",
        .path = "/%7Euser",
        .query = "",
        .fragment = "",
    },
    :None
);

test(
    15,
    "https://example.com/search?q=word&lang=en&sort=desc",
    {
        .scheme = "https",
        .authority = "example.com",
        .path = "/search",
        .query = "q=word&lang=en&sort=desc",
        .fragment = "",
    },
    :None
);

test(
    16,
    "https://example.com/?a=1&b=&c",
    {
        .scheme = "https",
        .authority = "example.com",
        .path = "/",
        .query = "a=1&b=&c",
        .fragment = "",
    },
    :None
);

test(
    17,
    "https://example.com/docs#section-2.3",
    {
        .scheme = "https",
        .authority = "example.com",
        .path = "/docs",
        .query = "",
        .fragment = "section-2.3",
    },
    :None
);

test(
    18,
    "http://example.com/#",
    {
        .scheme = "http",
        .authority = "example.com",
        .path = "/",
        .query = "",
        .fragment = "",
    },
    :Some "http://example.com/"
);

test(
    19,
    "ftp://ftp.example.com/pub/file.txt",
    {
        .scheme = "ftp",
        .authority = "ftp.example.com",
        .path = "/pub/file.txt",
        .query = "",
        .fragment = "",
    },
    :None
);

test(
    20,
    "ws://example.com/socket",
    {
        .scheme = "ws",
        .authority = "example.com",
        .path = "/socket",
        .query = "",
        .fragment = "",
    },
    :None
);

test(
    21,
    "",
    {
        .scheme = "",
        .authority = "",
        .path = "",
        .query = "",
        .fragment = "",
    },
    :None
);

std.io.print("all tests passed");
