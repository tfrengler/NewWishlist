"use strict";

import { Wish } from "./Wish.js";
import { JSUtils } from "./Utils.js";

export class Wishlist {

    constructor(backendEntryPoint="UNDEFINED_ARGUMENT", ajaxAuthKey="UNDEFINED_ARGUMENT") {
        
        this._wishes = new Map();
        this._backendEntryPoint = backendEntryPoint;
        this._ajaxAuthKey = ajaxAuthKey;
        this._backendController = "wishlists";

        return Object.freeze(this);
    }

    async load(userID=-1) {

		const backendRequest = await JSUtils.fetchRequest(
			this._backendEntryPoint,
			this._ajaxAuthKey,
			this._backendController,
			"getWishes",
			{userID: parseInt(userID)}
		);

		if (backendRequest.ERROR === false) {
			for (let wishID in backendRequest.DATA) {
				let currentWish = backendRequest.DATA[wishID];
				this._wishes.set(parseInt(wishID), new Wish(parseInt(wishID), currentWish.picture, currentWish.description, currentWish.links));
			}

			return {ERROR: false};
		}

		return backendRequest;
    }

    addNewWish() {
        const newWishID = Math.max(...this._wishes.keys()) + 1;
        this._wishes.set(newWishID, new Wish(newWishID));

        return newWishID;
    }

    async deleteWish(id=-1, token="UNDEFINED_ARGUMENT") {
		
		const backendRequest = await JSUtils.fetchRequest(
			this._backendEntryPoint,
			this._ajaxAuthKey,
			this._backendController,
			"deleteWish",
			{
				id: id,
				token: token,
				sessionHandle: true
			}
		);

		if (backendRequest.ERROR === false) {
			this._wishes.delete(id);
			return {ERROR: false}; 
		}

		return backendRequest;
    }

    async editWish(wish={}, token="UNDEFINED_ARGUMENT") {
        if (!(wish instanceof Wish))
            return Object.freeze({ERROR: true, DATA: `Argument 'wish' is not an instance of Wish (${wish.constructor.name})`});

		const backendRequest = await JSUtils.fetchRequest(
			this._backendEntryPoint,
			this._ajaxAuthKey,
			this._backendController,
			"saveWish",
			{
				id: wish.getId(),
				token: token,
				data: wish.getData(),
				sessionHandle: true
			}
		);

		if (backendRequest.ERROR === false) {
			this._wishes.set(wish.id, wish);
			return {ERROR: false};
		}

        return backendRequest;
    }
}