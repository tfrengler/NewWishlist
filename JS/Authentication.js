"use strict";

import { JSUtils } from "./Utils.js";

export class AuthenticationManager {

	constructor(backendEntryPoint="UNDEFINED_ERROR", ajaxAuthKey="UNDEFINED_ERROR") {

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

		const backendRequest = await JSUtils.fetchRequest(
			this._backendEntryPoint,
			this._ajaxAuthKey,
			this._controller,
			"logIn",
			{
				"username": username || "EMPTY_USERNAME",
				"password": password || "EMPTY_PASSWORD",
				"sessionHandle": true
			}
		);

		if (backendRequest.ERROR === false) {
			this._token = backendRequest.DATA.TOKEN;
			this._displayName = backendRequest.DATA.DISPLAY_NAME;

			return {ERROR: false};
		}

		return backendRequest;
	}

	async logOut(token="UNDEFINED_ARGUMENT") {

		const backendRequest = await JSUtils.fetchRequest(
			this._backendEntryPoint,
			this._ajaxAuthKey,
			this._controller,
			"logOut",
			{
				"token": token || "INVALID_ARGUMENT",
				"sessionHandle": true
			}
		);

		if (backendRequest.ERROR === false) {
			this._token = "";
			this._displayName = "";

			return {ERROR: false};
		}

		return backendRequest;
	}

	getToken() {
		return this._token;
	}

	getUserDisplayName() {
		return this._displayName;
	}
}