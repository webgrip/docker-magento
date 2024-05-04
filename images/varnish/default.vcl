# Very advanced implementation of default.vcl for a magento production server


vcl 4.1;

import std;

backend default {
    .host = "nginx";  // Adjust to your setup
    .port = "80";
    .first_byte_timeout = 600s;
    .probe = {
        .url = "/health_check.php";
        .timeout = 2s;
        .interval = 5s;
        .window = 10;
        .threshold = 5;
   }
}

acl purge {
    "localhost";
}

sub vcl_recv {
    if (req.method == "PURGE") {
        if (!client.ip ~ purge) {
            return(synth(405,"Not allowed."));
        }
        return (purge);
    }

    if (req.method != "GET" &&
      req.method != "HEAD" &&
      req.method != "PUT" &&
      req.method != "POST" &&
      req.method != "TRACE" &&
      req.method != "OPTIONS" &&
      req.method != "DELETE") {
        return (pipe);
    }

    if (req.method != "GET" && req.method != "HEAD") {
        return (pass);
    }

    if (req.http.Authorization || req.http.Cookie ~ "PHPSESSID") {
        return (pass);
    }
}

sub vcl_backend_response {
    if (bereq.http.cookie ~ "PHPSESSID") {
        unset beresp.http.set-cookie;
    }
}

sub vcl_deliver {
    if (obj.hits > 0) {
        set resp.http.X-Cache = "HIT";
    }
    else {
        set resp.http.X-Cache = "MISS";
    }
}

sub vcl_backend_response {
    # Cache images and AVIF files
    if (bereq.url ~ "\.(jpeg|jpg|png|gif|ico|svg|avif)$") {
        set beresp.ttl = 1w;  # Cache for 1 week
        set beresp.http.Cache-Control = "public, max-age=604800";  # 1 week in seconds
    }

    # Existing code...
    if (bereq.http.cookie ~ "PHPSESSID") {
        unset beresp.http.set-cookie;
    }
}
# Not sure about this
if (bereq.http.cookie) {
    set bereq.http.cookie = regsuball(bereq.http.cookie, "(^|;\s*)(_[_a-z]+|has_js)=[^;]*", "");  // Strip all cookies except the essentials
}
