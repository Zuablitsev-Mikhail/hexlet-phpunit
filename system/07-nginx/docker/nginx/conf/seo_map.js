function affiliate_subdomain(req, res) {
    var subDomain = "",
        host;

    host = req.variables['host'];

    var hostPart = host.split('.');

    subDomain = hostPart[0];

    return subDomain;
}


function normalize_uri(req, res) {
    var s;
    s = req.uri;
    if (s.endsWith('/')) {
        s = s.slice(0, -1);
    }
    return s;
}

function redirect_uri(req, res) {
    var origUri = req.uri,
        normalizedUri,
        mappedUri,
        redirectUri = "";

    normalizedUri = req.variables.normalize_uri;
    mappedUri = req.variables.map_uri;

    if (mappedUri) {
        redirectUri = mappedUri;
    }
    if (redirectUri && redirectUri === normalizedUri) {
        if (!origUri.endsWith('/')) {
            redirectUri = "";
        }
    }

    if (redirectUri.toString() === "" && origUri.match('christian-dior-') ) {
        redirectUri = origUri;
    }

    redirectUri = redirectUri.replace('christian-dior-','dior-');

    return redirectUri;
}
