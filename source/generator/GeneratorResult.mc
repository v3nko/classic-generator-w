class GeneratorResult {
    var data as String;
    var type as GeneratorType;
    var time as Moment;

    function initialize(type, time, data) {
        me.type = type;
        me.time = time;
        me.data = data;
    }

    function toString() {
        return Lang.format(
            "GeneratorResult(type=$1$, time=$2$, data=$3$)", 
            [type, time.value(), data]
        );
    }
}
