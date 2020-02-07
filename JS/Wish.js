"use strict";

export class Wish {

	constructor(id=0, picture="", description="", links=[]) {
		if ((parseInt(id) || -666) <= 0)
			throw new Error("Error instantiating new wish. ID must be greater than zero: " + parseInt(id) || -666);

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
			this.changeLinks(links);
		else
			this._links = new Array(5);

		return Object.seal(this);
	}

	changePicture(data="") {
		this._picture = data;
	}

	changeDescription(data="") {
		this._description = data;
	}

	changeLinks(data=[]) {
		for(let index = 0; index <= 4; index++)
			this._links[index] = data[index] || "";
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