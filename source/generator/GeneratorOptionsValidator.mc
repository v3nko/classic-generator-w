enum ValidationResult {
    VALIDATION_OK,
    VALIDATION_ERROR_NULL,
    VALIDATION_ERROR_ZERO_OR_LESS_LENGTH,
    VALIDATION_ERROR_LENGTH_EXCESS,
    VALIDATION_INVALID_RANGE
}

class GeneratorOptionsValidator {

    private const MAX_ARG_LENGTH = 6;

    function validateFixedLen(len as Integer) as ValidationResult {
        if (len == null) {
            return VALIDATION_ERROR_NULL;
        } else if (len <= 0) {
            return VALIDATION_ERROR_ZERO_OR_LESS_LENGTH;
        } else if (len > MAX_ARG_LENGTH) {
            return VALIDATION_ERROR_LENGTH_EXCESS;
        } else {
            return VALIDATION_OK;
        }
    }

    function validateRange(min as Integer, max as Integer) as validationResult {
        if (min == null || max == null) {
            return VALIDATION_ERROR_NULL;
        } else if (min >= max) {
            return VALIDATION_INVALID_RANGE;
        } else if (getLength(min) > MAX_ARG_LENGTH || getLength(max) > MAX_ARG_LENGTH) {
            return VALIDATION_ERROR_LENGTH_EXCESS;
        } else {
            return VALIDATION_OK;
        }
    }

    private function getLength(value as Integer) as Integer {
        return Math.floor(1 + Math.log(value.abs(), 10));
    }

    function getMaxArgLength() {
        return MAX_ARG_LENGTH;
    }
}
