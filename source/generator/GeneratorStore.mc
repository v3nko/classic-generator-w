using Toybox.Application.Storage as Storage;
using Toybox.Time;  

class GeneratorStore {

    private static const KEY_GEN_HISTORY = "gen_history";
    private static const RAW_RESULT_DELIMITER = ";";

    function getGeneratorHistory() as Array {
        var history = Storage.getValue(KEY_GEN_HISTORY);
        if (history == null) {
            history = [];
        }
        return history;
    }

    function saveGeneratorHistory(value as Array) {
        Storage.setValue(KEY_GEN_HISTORY, value);
    }

    function appenHistoryRecord(result, type, time) {
        var history = getGeneratorHistory();
        history.add(type + RAW_RESULT_DELIMITER + time + RAW_RESULT_DELIMITER + result);
        saveGeneratorHistory(history);
    }

    function parseHistoryRecord(rawResult) as GeneratorResult {
        var resultSegments = splitFirst(rawResult, RAW_RESULT_DELIMITER, 3);
        if (resultSegments.size() > 3) {
            System.println("Unexpected result format: " + rawResult);
            return null;
        } else {
            return new GeneratorResult(
                resultSegments[0].toNumber(), 
                new Time.Moment(resultSegments[1].toNumber()),
                resultSegments[2]
            );
        }
    }
}
