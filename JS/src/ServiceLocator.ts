class ServiceLocator {

    private services: Map<String, Object>;

    constructor(services: Map<String, Object>) {
        this.services = services;
        return this;
    }

    public get(type: String): Object {
        if (this.services.has(type))
            return this.services.get(type)!;

        throw new Error(`Service with name ${type} does not exist`);
    }
}