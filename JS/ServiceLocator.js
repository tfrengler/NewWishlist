"use strict";

export class ServiceLocator {
    
    constructor(services=Symbol("ARGUMENT_UNDEFINED")) {
        if (!(services instanceof Map))
            throw new Error("Argument 'services' is NOT an instance of Map: " + services.constructor.name);

        this.services = services;
        this.services.set = null;
        this.services.delete = null;

        return Object.freeze(this);
    }

    get(name="EMPTY_SERVICE_NAME") {
        if (this.services.has(name))
            return this.services.get(name);
        
        throw new Error("No such service: " + name);
    }
}