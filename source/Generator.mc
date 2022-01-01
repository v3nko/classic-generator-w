using Toybox.Lang;

typedef Generator as interface {
    function generateNum(max as Integer) as Result;
    function generateRange(min as Integer, max as Integer) as Result;
    function generateNumFixed(len as Integer) as Result;
    function generateAlphanum(len as Integer) as Result;
    function generateHex(len as Integer) as Result;
};

class RandomGenerator {

    private const CHARS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".toCharArray();
    private const HEX_CHARS_SUBSTRING_LENGTH = 16;
    private const FIXED_VALUE_THRESHOLD = 5;

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

    function generateHex1(len as Integer) as Result {
        // TODO add validation
        var result = new Array<Char>[len];
        for (var i = 0; i < result.size(); i++) {
            result[i] = generateCharFromPool(CHARS, HEX_CHARS_SUBSTRING_LENGTH);
        }
        return new Success(StringUtil.charArrayToString(result));
    }

    private function generateCharFromPool(pool as Array<Char>, poolLenLimit as Integer) as Char {
        return pool[nextInt(poolLenLimit)];
    }

    private function nextInt(limit as Integer) as Integer {
        return Math.rand() % limit;
    }

}
