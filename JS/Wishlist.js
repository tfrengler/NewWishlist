"use strict";

import { Wish } from "./Wish.js";

export class Wishlist {

    constructor(backendEntryPoint="UNDEFINED_ARGUMENT", ajaxAuthKey="UNDEFINED_ARGUMENT") {
        
        this._wishes = new Map();
        this._backendEntryPoint = backendEntryPoint;
        this._ajaxAuthKey = ajaxAuthKey;
        this._backendController = "wishlists";
        this._method = "call";

        return Object.freeze(this);
    }

    async load(userID=-1) {

        const POSTPayload = new FormData();

		POSTPayload.append("authKey", this._ajaxAuthKey);
		POSTPayload.append("controller", this._backendController)
		POSTPayload.append("function", "getWishes");
		POSTPayload.append("method", this._method);
		POSTPayload.append("parameters", JSON.stringify({userID: parseInt(userID)}));

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
        
        for (let wishID in decodedResponse.RESPONSE.DATA) {
            let currentWish = decodedResponse.RESPONSE.DATA[wishID];
            this._wishes.set(parseInt(wishID), new Wish(parseInt(wishID), currentWish.picture, currentWish.description, currentWish.links));
        }

        return Object.freeze({ERROR: false, DATA: null});
    }

    addNewWish() {
        const newWishID = Math.max(...this._wishes.keys()) + 1;
        this._wishes.set(newWishID, new Wish(newWishID));

        return newWishID;
    }

    async deleteWish(id=-1, token="UNDEFINED_ARGUMENT") {
        const POSTPayload = new FormData();

		POSTPayload.append("authKey", this._ajaxAuthKey);
		POSTPayload.append("controller", this._backendController)
		POSTPayload.append("function", "deleteWish");
		POSTPayload.append("method", this._method);
		POSTPayload.append("parameters", JSON.stringify({
            id: id,
            token: token,
            sessionHandle: true
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
        
        this._wishes.delete(id);

        return Object.freeze({ERROR: false, DATA: null});
    }

    async editWish(wish={}, token="UNDEFINED_ARGUMENT") {
        if (!(wish instanceof Wish))
            return Object.freeze({ERROR: true, DATA: `Argument 'wish' is not an instance of Wish (${wish.constructor.name})`});

        const POSTPayload = new FormData();

		POSTPayload.append("authKey", this._ajaxAuthKey);
		POSTPayload.append("controller", this._backendController)
		POSTPayload.append("function", "saveWish");
		POSTPayload.append("method", this._method);
		POSTPayload.append("parameters", JSON.stringify({
            id: wish.getId(),
            token: token,
            data: wish.serialize(),
            sessionHandle: true
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
        
        this._wishes.set(wish.id, wish);
        return Object.freeze({ERROR: false, DATA: null});
    }
}