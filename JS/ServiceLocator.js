"use strict";

export class ServiceLocator {
    
    constructor(services=null) {

        this.services = new Map(services);
        return Object.freeze(this);
    }

    get(name="EMPTY_SERVICE_NAME") {
        if (this.services.has(name))
            return this.services.get(name);
        
        throw new Error("No such service: " + name);
    }
}