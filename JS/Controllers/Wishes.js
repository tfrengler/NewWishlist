"use strict";

// import { JSUtils } from "../Utils.js";

export class Wishes {

	constructor(backendEntryPoint="UNDEFINED_ARGUMENT", ajaxAuthKey="UNDEFINED_ARGUMENT", services=null) {

		this._backendEntryPoint = backendEntryPoint;
		this._ajaxAuthKey = ajaxAuthKey;
		this._services = services;

		this._elements = Object.freeze({

		});

		this._init();

		let immutable = {
            configurable: false,
            enumerable: false,
            writable: false
        };

		Object.defineProperties(this, {
			"xxx": immutable
		});
		
		console.log("Wishes-controller initialized");
		return Object.freeze(this);
	}

	_init() {
		this._services.get("events").subscribe(
			this._services.get("eventTypes").WISHLIST_LOADED,
			this._onWishlistLoaded,
			this
		);
	}
	
	_onWishlistLoaded() {

	}
}