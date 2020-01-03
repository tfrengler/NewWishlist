"use strict";

export class AuthenticationManager {

	constructor(backendEntryPoint="UNDEFINED_ERROR", ajaxAuthKey="UNDEFINED_ERROR", services=null) {

		this.services = services;
		this.backendEntryPoint = backendEntryPoint;
		this.ajaxAuthKey = ajaxAuthKey;
		this.token = null;
		this.controller = "authentication";
		this.method = "call";

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
			},
			"controller": {
				configurable: false,
				enumerable: false,
				writable: false
			},
			"method": {
				configurable: false,
				enumerable: false,
				writable: false
			}
		});

		console.log(`AuthenticationManager initialized, with backendEntryPoint '${backendEntryPoint}' and ajaxAuthKey: ${ajaxAuthKey}`);
		return Object.seal(this);
	}

	async logIn(username, password) {

		const POSTPayload = new FormData();

		POSTPayload.append("authKey", this.ajaxAuthKey);
		POSTPayload.append("controller", this.controller);
		POSTPayload.append("function", "logIn");
		POSTPayload.append("method", this.method);
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

		if (response.status !== 200) {
			this.services.get("events").trigger(
				this.services.get("eventTypes").LOGIN_FAILED,
				{
					error: true,
					friendlyMessage: "Internal server error :(",
					actualError: `HTTP-call to AjaxProxy failed for some reason (status ${response.status})`
				}
			);
			return;
		}
		
		if (response.json)
			decodedResponse = await response.json();
		else {
			this.services.get("events").trigger(
				this.services.get("eventTypes").LOGIN_FAILED,
				{
					error: true,
					friendlyMessage: "Internal server error :(",
					actualError: "Return data from the backend entry point could not be parsed as JSON"
				}
			);
			return;
		}

		if (decodedResponse.RESPONSE_CODE != 0) {
			this.services.get("events").trigger(
				this.services.get("eventTypes").LOGIN_FAILED,
				{
					error: true,
					friendlyMessage: "Internal server error :(",
					actualError: `HTTP-call to AjaxProxy failed when acting on request data (${decodedResponse.RESPONSE_CODE})`
				}
			);
			return;
		}

		if (decodedResponse.RESPONSE_CODE == 0 && decodedResponse.DATA.TOKEN) {
			this.token = decodedResponse.DATA.TOKEN || Symbol("EMPTY_RETURN_DATA");
			this.services.get("events").trigger(this.services.get("eventTypes").LOGIN_SUCCESS);
			return
		}

		this.services.get("events").trigger(
			this.services.get("eventTypes").LOGIN_FAILED,
			{
				error: false,
				message: "Username or password incorrect"
			}
		);
	}

	async logOut() {

	}

	getToken() {
		return this.token;
	}
}