"use strict";

export class Wish {

    constructor(picture="", description="", links=[]) {
        this.picture = picture;
        this.description = description;
        this.links = links;

        return Object.seal(this);
    }

    changePicture() {}
    changeDescription() {}
    changeLinks() {}
}