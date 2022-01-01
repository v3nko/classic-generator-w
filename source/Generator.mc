using Toybox.Lang;

typedef Generator as interface {
    function generateNum(max as Integer) as Result;
    function generateRange(min as Integer, max as Integer) as Result;
    function generateNumFixed(len as Integer) as Result;
    function generateAlphanum(len as Integer) as Result;
    function generateHex(len as Integer) as Result;
};

enum GeneratorType {
    GENERATOR_NUM,
    GENERATOR_RANGE,
    GENERATOR_NUM_FIXED,
    GENERATOR_ALPHANUM,
    GENARATOR_HEX
}

class RandomGenerator {

    private const CHARS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".toCharArray();
    private const HEX_CHARS_SUBSTRING_LENGTH = 16;
    private const FIXED_VALUE_THRESHOLD = 10;

    private var validator;

    function initialize(validator as GeneratorOptionsValidator) {
        me.validator = validator;
    }

    function generateNum(max as Integer) as Result {
        return null;
    }

    function generateRange(min as Integer, max as Integer) as Result {
        return null;
    }
    
    function generateNumFixed(len as Integer) as Result {
        return null;
    }

    function generateAlphanum(len as Integer) as Result {
        return null;
    }

    function generateHex(len as Integer) as Result {
        var validationResult = validator.validateHex(len);
        if (validationResult == VALIDATION_OK) {
            var result = new Array<Char>[len];
            for (var i = 0; i < result.size(); i++) {
                result[i] = generateCharFromPool(CHARS, HEX_CHARS_SUBSTRING_LENGTH);
            }
            return new Success(StringUtil.charArrayToString(result));
        } else {
            return new Error(new InvalidArgumentError(validationResult));
        }
    }

    private function generateCharFromPool(pool as Array<Char>, poolLenLimit as Integer) as Char {
        return pool[nextInt(poolLenLimit)];
    }

    private function nextInt(limit as Integer) as Integer {
        return Math.rand() % limit;
    }

}

class InvalidArgumentError {
    var reason as ValidationResult;

    function initialize(reason) {
        me.reason = reason;
    }
}
