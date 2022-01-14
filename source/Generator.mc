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

const GENERATOR_TYPES_COUNT = GENARATOR_HEX + 1;

class RandomGenerator {

    private const CHARS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        .toCharArray();
    private const HEX_CHARS_SUBSTRING_LENGTH = 16;
    private const FIXED_VALUE_THRESHOLD = 10;

    private var validator;

    function initialize(validator as GeneratorOptionsValidator) {
        me.validator = validator;
    }

    function generateNum(max as Integer) as Result {
        return generateRange(0, max);
    }

    function generateRange(min as Integer, max as Integer) as Result {
        var validationResult = validator.validateRange(min, max);
        if (validationResult == VALIDATION_OK) {
            return new Success((nextInt(max - min + 1) + min).toString());
        } else {
            return new Error(new InvalidArgumentError(validationResult));
        }
    }
    
    function generateNumFixed(len as Integer) as Result {
        var validationResult = validator.validateFixedLen(len);
        if (validationResult == VALIDATION_OK) {
            var result = "";
            for (var i = 0; i < len; i++) {
                result += nextInt(FIXED_VALUE_THRESHOLD).toString();
            }
            return new Success(result);
        } else {
            return new Error(new InvalidArgumentError(validationResult));
        }
    }

    function generateAlphanum(len as Integer) as Result {
        return generateFixedLenFromPool(len, CHARS, CHARS.size());
    }

    function generateHex(len as Integer) as Result {
        return generateFixedLenFromPool(len, CHARS, HEX_CHARS_SUBSTRING_LENGTH);
    }

    private function generateFixedLenFromPool(
        len as Integer, 
        pool as Array<Char>, 
        poolUpBoundary as Integer
    ) as Result {
        var validationResult = validator.validateFixedLen(len);
        if (validationResult == VALIDATION_OK) {
            var result = new Array<Char>[len];
            for (var i = 0; i < result.size(); i++) {
                result[i] = generateCharFromPool(pool, poolUpBoundary);
            }
            return new Success(StringUtil.charArrayToString(result));
        } else {
            return new Error(new InvalidArgumentError(validationResult));
        }
    }

    private function generateCharFromPool(pool as Array<Char>, poolUpBoundary as Integer) as Char {
        return pool[nextInt(poolUpBoundary)];
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
