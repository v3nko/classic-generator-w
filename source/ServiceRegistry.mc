using Generator;

module Di {

    class ServiceRegistry {

        function getGeneratorOptionsValidator() {
            return new GeneratorOptionsValidator();
        }

        function getGenerator() {
            return new Generator.RandomGenerator(getGeneratorOptionsValidator());
        }

        function getSettingsStore() {
            return new SettingsStore();
        }

        function getGeneratorController() {
            return new GeneratorController(getGenerator(), getSettingsStore());
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
