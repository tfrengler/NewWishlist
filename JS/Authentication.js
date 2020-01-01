"use strict";

export class Authentication {

    constructor(backendEntryPoint="ERROR", ajaxAuthKey="ERROR", services=null) {

        this.services = services;
        this.backendEntryPoint = backendEntryPoint;
        this.ajaxAuthKey = ajaxAuthKey;
        this.token = null;
        this.services = null;

        Object.defineProperties(this, {
            "backendEntryPoint": {
                configurable: false,
                enumerable: false,
                writable: false
            },

            "ajaxAuthKey": {
                configurable: false,
                enumerable: false,
                writable: false
            }
        });

        return Object.seal(this);
    }

    async logIn(username, password) {

        const POSTPayload = new FormData();

        POSTPayload.append("authKey", this.ajaxAuthKey);
        POSTPayload.append("controller", "authentication");
        POSTPayload.append("function", "logIn");
        POSTPayload.append("method", "call");
        POSTPayload.append("parameters", JSON.stringify({
            "username": username,
            "password": password || "EMPTY_PASSWORD",
            "sessionHandle": true
        }));

        const response = await window.fetch(this.backendEntryPoint, {
            credentials: "include",
            mode: "same-origin",
            method: "POST",
            headers: {
                "Accept": "application/json"
            },
            body: POSTPayload
        });
        
        let decodedResponse;

        if (response.status !== 200)
            this.services.get("events").trigger(
                this.services.get("eventTypes").LOGIN_FAILED,
                {message: "Internal server error :("}
            );
        
        if (response.json)
            decodedResponse = await response.json();
        else
            this.services.get("events").trigger(
                this.services.get("eventTypes").LOGIN_FAILED,
                {message: "Internal server error :("}
            );

        if (decodedResponse.RESPONSE_CODE == 0 && decodedResponse.DATA.TOKEN)
            this.token = decodedResponse.DATA.TOKEN;
        else
            this.services.get("events").trigger(
                this.services.get("eventTypes").LOGIN_FAILED,
                {message: "Internal server error :("}
            );

    }

    async logOut() {

    }

    getToken() {
        return this.token;
    }
}