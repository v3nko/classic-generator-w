using Generator;

module Di {

    class ServiceRegistry {

        private const KEY_VIEW_LIFECYCLE_HANDLER = "view_lifecycle_handler";

        var container = {};

        function getGeneratorOptionsValidator() {
            return new GeneratorOptionsValidator();
        }

        function getGenerator() {
            return new Generator.RandomGenerator(getGeneratorOptionsValidator());
        }

        function getSettingsStore() {
            return new SettingsStore();
        }

        function getGeneratorStore() {
            return new GeneratorStore();
        }

        function getGeneratorController() {
            return new GeneratorController(getGenerator(), getSettingsStore(), getGeneratorStore());
        }

        function getDateTimeFormatter() {
            return new DateTimerFormatter();
        }
    }

    var registry;

    function provideServiceRegistry() {
        if (registry == null) {
            registry = new ServiceRegistry();
        }
        return registry;
    }
}
