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
