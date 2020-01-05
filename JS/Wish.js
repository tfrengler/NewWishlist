"use strict";

export class Wish {

    constructor(id=0, picture="", description="", links=[]) {
        if ((parseInt(id) || -666) <= 0)
            throw new Error("Error instantiating new wish. ID must be greater than zero: " + parseInt(id) || -666);

        this._id = id;

        if (typeof picture === typeof "")
            this._picture = picture;
        else
            this._picture = "";

        if (typeof description === typeof "")
            this._description = description;
        else
            this._description = "";

        if (links instanceof Array)
            this._links = links;
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
        this._links = data;
    }

    serialize() {
        return JSON.stringify({
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
}