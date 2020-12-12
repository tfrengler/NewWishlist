"use strict";

import { Wish } from "./Wish.js";
import { JSUtils } from "./Utils.js";

export class Wishlist {

    constructor(backendEntryPoint="UNDEFINED_ARGUMENT", ajaxAuthKey="UNDEFINED_ARGUMENT") {

		this._wishlistID = 0; // Mutable
        this._wishes = new Map();
        this._backendEntryPoint = backendEntryPoint;
        this._ajaxAuthKey = ajaxAuthKey;
		this._backendController = "wishlists";

		let immutable = {
			configurable: false,
			enumerable: false,
			writable: false
		};

		Object.defineProperties(this, {
			"_wishes": immutable,
			"_backendEntryPoint": immutable,
            "_ajaxAuthKey": immutable,
            "_backendController": immutable
        });

        return Object.seal(this);
    }

    async load(userID=-1) {
		userID = parseInt(userID);

		const backendRequest = await JSUtils.fetchRequest(
			this._backendEntryPoint,
			this._ajaxAuthKey,
			this._backendController,
			"getWishes",
			{userID: userID}
		);

		if (backendRequest.ERROR === false) {
			this._wishlistID = userID;

			let sortedWishIDs = Object.keys(backendRequest.DATA);
			sortedWishIDs.sort((a, b) => a - b);

			sortedWishIDs.forEach(wishID=> {
				let currentWish = backendRequest.DATA[wishID];
				this._wishes.set(parseInt(wishID), new Wish(parseInt(wishID), currentWish.picture, currentWish.description, currentWish.links));
			});

			return {ERROR: false};
		}

		return backendRequest;
    }

    async addNewWish(wish={}, token="UNDEFINED_ARGUMENT") {
        if (!(wish instanceof Wish))
            return Object.freeze({ERROR: true, DATA: `Argument 'wish' is not an instance of Wish (${wish.constructor.name})`});

		const backendRequest = await JSUtils.fetchRequest(
			this._backendEntryPoint,
			this._ajaxAuthKey,
			this._backendController,
			"addWish",
			{
				token: token,
				data: wish.getData(),
				sessionHandle: true
			}
		);

		if (backendRequest.ERROR === false) {
            wish.setId(backendRequest.DATA.WISH_ID);
            this._wishes.set(backendRequest.DATA.WISH_ID, wish);

            return {ERROR: false};
		}

        return backendRequest;
    }

    getWishes() {
        return this._wishes;
    }

    getNewWishID() {
        return Math.max(...this._wishes.keys()) + 1;
    }

    getWish(id=-1) {
        return this._wishes.get(id);
	}

	getWishlistID() {
		return this._wishlistID;
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

    async saveWish(wish={}, token="UNDEFINED_ARGUMENT") {
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
			this._wishes.set(wish.getId(), wish);
			return {ERROR: false};
		}

        return backendRequest;
    }
}