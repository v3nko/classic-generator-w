typedef Result as interface {
    var data;

    function onSuccess(m as Method(data)) as Result;
    function onError(m as Method(error)) as Result;
};

class Success {
    var data;

    function initialize(data) {
        me.data = data;
    }

    function onSuccess(m as Method(data)) as Result {
        m.invoke(data);
        return me;
    }

    function onError(m as Method(error)) as Result {
        // no-op
        return me;
    }
}

class Error {
    var data = null;
    var error;

    function initialize(error) as Result {
        me.error = error;
    }

    function onSuccess(m as Method(data)) as Result {
        // no-op
        return me;
    }

    function onError(m as Method(error)) {
        m.invoke(error);
        return me;
    }
}

function splitFirst(src, delimiter, segmentsLimit) {
    var tokens = [];
    var segment = src.find(delimiter);
    while (segment != null && tokens.size() < segmentsLimit) {
        var token = src.substring(0, segment);
        tokens.add(token);
        src = src.substring(segment + delimiter.length(), src.length());
        segment = src.find(delimiter);
    }
    tokens.add(src);
    return tokens;
}

function split(src, delimiter) {
    splitFirst(src, delimiter, src.length());
}
