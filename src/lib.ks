# yuri mentioned
module:

# Uniform Resource Identifier (URI) :: RFC 3986
const Uri = newtype {
    .scheme :: String,
    .authority :: String,
    .path :: String,
    .query :: String,
    .fragment :: String,
};

const is_empty = s => String.length(s) == 0;

impl Uri as module = (
    module:
    
    # Construct a URI that just contains a path
    const new_path = (path :: String) -> Uri => {
        .scheme = "",
        .authority = "",
        .path,
        .query = "",
        .fragment = ""
    };
    
    # Construct a URI with a schema and a path
    const spec_path = (scheme :: String, path :: String) -> Uri => {
        .scheme,
        .authority = "",
        .path,
        .query = "",
        .fragment = ""
    };
    
    # String representation of the URI
    const to_string = (self :: Uri) -> String => (
        let mut s = "";
        if not is_empty(self.scheme) then (
            s += self.scheme;
            s += ":";
        );
        if not is_empty(self.authority) then (
            s += "//";
            s += self.authority;
        );
        s += self.path;
        if not is_empty(self.query) then (
            s += "?";
            s += self.query;
        );
        if not is_empty(self.fragment) then (
            s += "#";
            s += self.fragment;
        );
        s
    );
);

const Option = (
    module:
    use Option.*;
    
    # Opposite of `and_then`, here :Some is the effect
    const if_not = [T] (opt :: t[T], f :: () -> t[T]) -> t[T] => (
        match opt with (
            | :Some x => :Some x
            | :None => f()
        )
    );
    
    const expect = [T] (opt :: t[T], msg :: String) -> T => (
        match opt with (
            | :Some x => x
            | :None => panic("Unwrapped :None: " + msg)
        )
    );
);

# String representation of the URI
impl Uri as ToString = {
    .to_string = Uri.to_string,
};

const ContextT = newtype {
    .warn :: String -> (),
};
const ctx = @context ContextT;

# Parse a URI from a string
impl Uri as FromString = {
    .from_string = mut str => with_return (
        # index_of that returns :None instead of -1
        const index_of = (s :: String, c :: Char) => (
            let i = String.index_of(s, c);
            if i == -1 then :None else :Some i
        );
        # remove the first `amt` characters of a string mutable
        const skip = (s :: &mut String, amt :: UInt32) => (
            s^ = s^ |> String.substring(amt, String.length(s^) - amt);
        );
        
        const substring = String.substring;
        const length = String.length;
        const at = String.at;
        
        let { mut skip_path, mut skip_query, mut skip_fragment } = { false, false, false };
        
        let scheme = (
            let delim = str |> index_of(':');
            if delim is :Some delim then (
                let scheme = str |> substring(0, delim);
                &mut str |> skip(delim + 1);
                scheme
            ) else (
                
                ""
            )
        );
        
        let authority = (
            if length(str) >= 2 and str |> substring(0, 2) == "//" then (
                str = str |> substring(2, length(str) - 2);
                
                const restart_this = (o :: Option.t[UInt32]) => Option.map(o, c => { c, c });
                const restart_next = (o :: Option.t[UInt32]) => Option.map(o, c => { c, c + 1 });
                
                let { delim, restart } = (str |> index_of('/') |> restart_this)
                    |> Option.if_not(
                        () => (
                            skip_path = true;
                            str |> index_of('?') |> restart_next
                        )
                    )
                    |> Option.if_not(
                        () => (
                            skip_query = true;
                            str |> index_of('#') |> restart_next
                        )
                    )
                    |> Option.if_not(
                        () => (
                            skip_fragment = true;
                            :Some length(str) |> restart_this
                        )
                    )
                    |> Option.expect("last if_not returns :Some");
                let authority = str |> substring(0, delim);
                &mut str |> skip(restart);
                authority
            ) else (
                
                ""
            )
        );
        
        let path = (
            if skip_path then "" else (
                let delim = (str |> index_of('?'))
                    |> Option.if_not(
                        () => (
                            skip_query = true;
                            str |> index_of('#')
                        )
                    )
                    |> Option.if_not(
                        () => (
                            skip_fragment = true;
                            :Some length(str)
                        )
                    )
                    |> Option.expect("last if_not returns :Some");
                let path = str |> substring(0, delim);
                &mut str |> skip(delim);
                if not is_empty(str) then (&mut str |> skip(1));
                path
            )
        );
        
        # Authority x Path validation errors are raised as warnings
        if not is_empty(authority) and not is_empty(path) and at(path, 0) != '/' then (
            (@current ctx).warn("URI contains an authority component and the path component is neither empty nor beginning with a slash (\"/\")");
        ) else if is_empty(authority) and length(path) >= 2 and substring(path, 0, 2) == "//" then (
            (@current ctx).warn("URI does not contain an authority component and the path begins with two slash characters (\"//\")");
        );
        
        let query = (
            if skip_query then "" else (
                let delim = (str |> index_of('#'))
                    |> Option.if_not(
                        () => (
                            skip_fragment = true;
                            :Some length(str)
                        )
                    )
                    |> Option.expect("last if_not returns :Some");
                let query = str |> substring(0, delim);
                &mut str |> skip(delim);
                if not is_empty(str) then (&mut str |> skip(1));
                query
            )
        );
        
        let fragment = (
            if skip_fragment then "" else (
                let delim = length(str);
                let fragment = str |> substring(0, delim);
                &mut str |> skip(delim);
                if not is_empty(str) then (&mut str |> skip(1));
                fragment
            )
        );
        
        {
            .scheme,
            .authority,
            .path,
            .query,
            .fragment,
        }
    ),
};
