enum ValidationResult {
    VALIDATION_OK,
    VALIDATION_ERROR_NULL,
    VALIDATION_ERROR_ZERO_OR_LESS_LENGTH,
    VALIDATION_ERROR_LENGTH_EXCESS
}

class GeneratorOptionsValidator {

    private const MAX_ARG_LENGTH = 6;

    function validateHex(len as Integer) as ValidationResult {
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
}
