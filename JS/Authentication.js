"use strict";

export class AuthenticationManager {

	constructor(backendEntryPoint="UNDEFINED_ERROR", ajaxAuthKey="UNDEFINED_ERROR", services=null) {

		this._services = services;
		this._backendEntryPoint = backendEntryPoint;
		this._ajaxAuthKey = ajaxAuthKey;
		this._token = null; // Mutable
		this._displayName = null; // Mutable
		this._controller = "authentication";
        this._method = "call";
        
        let immutable = {
            configurable: false,
            enumerable: false,
            writable: false
        };

		Object.defineProperties(this, {
			"_backendEntryPoint": immutable,
			"_ajaxAuthKey": immutable,
			"_controller": immutable,
            "_method": immutable,
            "_services": immutable
		});

		console.log(`AuthenticationManager initialized, with backendEntryPoint '${backendEntryPoint}' and ajaxAuthKey: ${ajaxAuthKey}`);
		return Object.seal(this);
	}

	async logIn(username="UNDEFINED_ARGUMENT", password="UNDEFINED_ARGUMENT") {

		const POSTPayload = new FormData();

		POSTPayload.append("authKey", this._ajaxAuthKey);
		POSTPayload.append("controller", this._controller);
		POSTPayload.append("function", "logIn");
		POSTPayload.append("method", this._method);
		POSTPayload.append("parameters", JSON.stringify({
			"username": username || "EMPTY_USERNAME",
			"password": password || "EMPTY_PASSWORD",
			"sessionHandle": true
		}));

		const response = await window.fetch(this._backendEntryPoint, {
			credentials: "include",
			mode: "same-origin",
			method: "POST",
			headers: {
				"Accept": "application/json"
			},
			body: POSTPayload
		});
		
		if (response.status !== 200)
			return Object.freeze({ERROR: true, DATA: `HTTP-call to AjaxProxy failed for some reason (status ${response.status})`});
		
		if (!response.json)
            return Object.freeze({ERROR: true, DATA: "Return data from the backend entry point could not be parsed as JSON"});
        
        const decodedResponse = await response.json();

		if (decodedResponse.RESPONSE_CODE !== 0)
			return Object.freeze({ERROR: true, DATA: `HTTP-call to AjaxProxy failed when acting on request data (${decodedResponse.RESPONSE_CODE})`});

		if (decodedResponse.RESPONSE_CODE === 0 && decodedResponse.RESPONSE.STATUS_CODE !== 0)
            return Object.freeze({ERROR: true, DATA: decodedResponse.RESPONSE.STATUS_CODE});

		this._token = decodedResponse.RESPONSE.DATA.TOKEN;
		this._displayName = decodedResponse.RESPONSE.DATA.DISPLAY_NAME;

		return Object.freeze({ERROR: false, DATA: null});
	}

	async logOut(token="UNDEFINED_ARGUMENT") {

		const POSTPayload = new FormData();

		POSTPayload.append("authKey", this._ajaxAuthKey);
		POSTPayload.append("controller", this._controller);
		POSTPayload.append("function", "logOut");
		POSTPayload.append("method", this._method);
		POSTPayload.append("parameters", JSON.stringify({
			"token": token || "INVALID_ARGUMENT",
			"sessionHandle": true
		}));

		const response = await window.fetch(this._backendEntryPoint, {
			credentials: "include",
			mode: "same-origin",
			method: "POST",
			headers: {
				"Accept": "application/json"
			},
			body: POSTPayload
		});
		
		if (response.status !== 200)
			return Object.freeze({ERROR: true, DATA: `HTTP-call to AjaxProxy failed for some reason (status ${response.status})`});
		
		if (!response.json)
            return Object.freeze({ERROR: true, DATA: "Return data from the backend entry point could not be parsed as JSON"});
        
        const decodedResponse = await response.json();

		if (decodedResponse.RESPONSE_CODE !== 0)
			return Object.freeze({ERROR: true, DATA: `HTTP-call to AjaxProxy failed when acting on request data (${decodedResponse.RESPONSE_CODE})`});

		if (decodedResponse.RESPONSE_CODE === 0 && decodedResponse.RESPONSE.STATUS_CODE !== 0)
            return Object.freeze({ERROR: true, DATA: decodedResponse.RESPONSE.STATUS_CODE});

		this._token = "";
		this._displayName = "";

		return Object.freeze({ERROR: false, DATA: null});
	}

	getToken() {
		return this._token;
	}

	getUserDisplayName() {
		return this._displayName;
	}
}