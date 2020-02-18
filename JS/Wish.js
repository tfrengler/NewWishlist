"use strict";

export class Wish {

	constructor(id=0, picture="", description="", links=[]) {

		this._id = id;
		this._links = new Array(5);

		if (typeof picture === typeof "")
			this._picture = picture;
		else
			this._picture = "";

		if (typeof description === typeof "")
			this._description = description;
		else
			this._description = "";

		if (links instanceof Array)
			for(let index = 0; index <= 4; index++)
				this._links[index] = links[index] || "";
		else
			this._links = new Array(5);

		let immutable = {
			configurable: false,
			enumerable: false,
			writable: false
		};

		Object.defineProperties(this, {
			"_links": immutable,
			"_picture": immutable,
			"_description": immutable
		});

		return Object.seal(this);
	}

	setId(newId=0) {
		if (newId <= 0 || this._id > 0) return;

		this._id = newId;
		Object.defineProperty(this, "_id", {
			configurable: false,
			enumerable: false,
			writable: false
		});
	}

	getData() {
		return Object.seal({
			id: this._id,
			picture: this._picture,
			description: this._description,
			links: this._links
		})
	}

	getPicture() {
		return this._picture;
	}

	getDescription() {
		return this._description;
	}

	getLinks() {
		return this._links;
	}

	getId() {
		return this._id;
	}
	
	equalTo(wishInstance={}) {
		if (!(wishInstance instanceof Wish))
			throw new Error("Argument 'wishInstance' is expected to be an instance of Wish, but it is not: " + wishInstance.constructor.name);

		if (this._description !== wishInstance.getDescription()) return false;
		if (this._picture !== wishInstance.getPicture()) return false;

		let areLinksTheSame = true;

		wishInstance.getLinks().forEach((link, index)=> {
			if (this._links[index] !== link) areLinksTheSame = false;
		})

		return areLinksTheSame;
	}
}