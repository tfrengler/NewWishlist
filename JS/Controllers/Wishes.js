/* eslint-disable no-useless-escape */
/* global $ */
"use strict";

import { JSUtils } from "../Utils.js";
import { Wish } from "../Wish.js";

export class Wishes {

	constructor(services=null) {

		this._services = services;
        this._wishlist = null; // Mutable
        this._linkDomainRegex = new RegExp("^(http://|https://|www\.)(.*?)/");

		this._elements = Object.freeze({
            addNewWishButton: document.getElementById("AddWish"),
            wishlistContainer: document.getElementById("WishRowContainer"),
            editWishDialog: document.getElementById("EditWish"),
            editPictureImgElement: document.getElementById("Edit_Picture"),
            editPictureURLTextElement: document.getElementById("Edit_Picture_URL"),
            editDescriptionTexarea: document.getElementById("Edit_Description"),
            editLinksTextElements: document.querySelectorAll("#Edit_Links_Container input"),
            saveWishChangesButton: document.getElementById("SaveWishChanges"),
            saveWishesLoader: document.querySelector("#SaveWishChanges i"),
			closeEditWishDialogButton: document.getElementById("CloseEditWishDialog"),
			welcomeMessageContainer: document.getElementById("WelcomeMessageRow"),
            activeWishlistOwnerNameElement: document.getElementById("ActiveWishlistOwnerName"),
            deleteWishDialogElement: document.getElementById("DeleteWishDialog"),
            confirmWishDeleteButton: document.getElementById("ConfirmWishDelete"),
            editPictureStatusIndictor: document.getElementById("EditPictureStatus")
        });

		let immutable = {
			configurable: false,
			enumerable: false,
			writable: false
		};

		Object.defineProperties(this, {
            "_services": immutable,
            "_linkDomainRegex": immutable
        });

		this._init();
		
		console.log("Wishes-controller initialized");
		return Object.seal(this);
	}

	_init() {
		this._services.get("events").subscribe(
			this._services.get("eventTypes").WISHLIST_LOADED,
			this.onWishlistLoaded,
			this
        );

        this._services.get("events").subscribe(
			this._services.get("eventTypes").LOGIN_SUCCESS,
			this.onUserLoginOrLogout,
			this
        );

        this._services.get("events").subscribe(
			this._services.get("eventTypes").LOGOUT_SUCCESS,
			this.onUserLoginOrLogout,
			this
        );
        
        $(this._elements.editWishDialog).on('show.bs.modal', (event)=> this.onOpenEditDialog(parseInt(event.relatedTarget.dataset.wishid)));
        $(this._elements.editWishDialog).on('hide.bs.modal', ()=> this.onCloseEditDialog());

        $(this._elements.deleteWishDialogElement).on('show.bs.modal', (event)=> this.onOpenDeleteDialog(parseInt(event.relatedTarget.dataset.wishid)));

        this._elements.saveWishChangesButton.addEventListener("click", ()=> this.onSaveWish());
        this._elements.confirmWishDeleteButton.addEventListener("click", ()=> this.onDeleteWish());
        this._elements.editPictureImgElement.addEventListener("error", JSUtils.onImageNotFound);
	}

	onUserLoginOrLogout() {
		if (this._eligableForEditMode()) {
			document.querySelectorAll(".wish-edit").forEach(divElement=> divElement.classList.remove("hidden"));
			document.querySelectorAll(".wish-delete").forEach(divElement=> divElement.classList.remove("hidden"));
			this._elements.addNewWishButton.classList.remove("hidden");

			return;
		}

		document.querySelectorAll(".wish-edit").forEach(divElement=> divElement.classList.add("hidden"));
		document.querySelectorAll(".wish-delete").forEach(divElement=> divElement.classList.add("hidden"));
		this._elements.addNewWishButton.classList.add("hidden");
	}
	
	onWishlistLoaded(data) {
        if (data.wishlist.constructor.name !== "Wishlist")
            throw new Error("Expected event data to be an instance of Wishlist, but it is not: " + data.wishlist.constructor.name)

		this._elements.welcomeMessageContainer.remove();
		this._elements.activeWishlistOwnerNameElement.innerText = data.wishlistOwner;
		document.querySelectorAll(".wish-row").forEach(wishRow=> wishRow.remove());

        this._wishlist = data.wishlist;

        if (this._wishlist.getWishes().size === 0)
            this._services.get("notifications").notifyWarning("Wishlist is empty, nothing to see", 3000);
        else
            this._wishlist.getWishes().forEach(wish=> this._createDOMWish(wish));
		
		if (this._eligableForEditMode())
            this._elements.addNewWishButton.classList.remove("hidden");
		else
            this._elements.addNewWishButton.classList.add("hidden");
	}
	
	_eligableForEditMode() {
		if (!this._wishlist) return false;
		return this._services.get("authentication").getUserID() === this._wishlist.getWishlistID();
	}
    
    _insertWishInDOM(wishNode) {
        const secondLastRowIndex = document.querySelectorAll(`#${this._elements.wishlistContainer.id} > div.row`).length - 1;
        this._elements.wishlistContainer.insertBefore(wishNode, this._elements.wishlistContainer.children[secondLastRowIndex]);
    }

    _removeWishFromDOM(id=0) {
        if (!(id > 0)) throw new Error("Cannot remove wish from DOM. Id is 0 or below: " + id);

        let wishNode = document.querySelector(`section[data-wishid='${id}']`);
        wishNode.parentElement.remove();
    }
	
	_createDOMWish(wishInstance) {
        if (wishInstance.constructor.name != "Wish")
			throw new Error("Argument 'wishInstance' is not an instance of Wish!");

        const wishRow = document.createElement("div");
        wishRow.classList.add("row","wish-row");

		const container = document.createElement("section");
        container.classList.add("wish","border","border-dark","rounded","p-3","d-inline-flex","flex-row","bg-light","mb-3");
        container.dataset.wishid = wishInstance.getId();

		const imageContainer = document.createElement("div");
		imageContainer.classList.add("wish-item","wish-image","border","rounded","mr-3","overflow-hidden");

		const image = document.createElement("img");
		image.classList.add("rounded");
		image.onerror = JSUtils.onImageNotFound;
		image.setAttribute("referrerPolicy", "no-referrer");
		image.setAttribute("validate", "never");
		image.setAttribute("src", wishInstance.getPicture());

		imageContainer.appendChild(image);

		const description = document.createElement("div");
		description.classList.add("wish-item","wish-description","border","rounded","overflow-hidden","p-3","mr-3");
		description.innerText = wishInstance.getDescription() || "(no description)";

		const linksContainer = document.createElement("div");
        linksContainer.classList.add("wish-item","wish-links","border","rounded","p-3","text-primary");
        
        let hasLinks = false;
        wishInstance.getLinks().forEach((linkURL)=> {
            if (linkURL.length > 0) hasLinks = true;
        });

        if (!hasLinks)
            linksContainer.innerText = "(no links)";
        else {
            this._resolveLinkText(wishInstance.getLinks()).forEach((linkPair)=> {
                if (!linkPair.URL.length) return;
                const enclosingDiv = document.createElement("div");

                const linkIcon = document.createElement("i");
                linkIcon.classList.add("fas","fa-link");

                const hyperlink = document.createElement("a");
                hyperlink.setAttribute("target", "_blank");
                hyperlink.innerText = linkPair.TEXT;
                hyperlink.href = linkPair.URL;

                enclosingDiv.appendChild(linkIcon);
                linkIcon.appendChild(hyperlink);

                linksContainer.appendChild(enclosingDiv);
            });
        }
        
        // Putting it all together
        container.appendChild(this._createDOMWishEditButton(wishInstance.getId()));
        
        container.appendChild(imageContainer);
        container.appendChild(description);
        container.appendChild(linksContainer);

        container.appendChild(this._createDOMWishDeleteButton(wishInstance.getId()));
        
		wishRow.appendChild(container);
        this._insertWishInDOM(wishRow); 
    }
    
    _resolveLinkText(linkCollection=[]) {

        const returnData = [
            {URL: "", TEXT: "LINK (unknown)"},
            {URL: "", TEXT: "LINK (unknown)"},
            {URL: "", TEXT: "LINK (unknown)"},
            {URL: "", TEXT: "LINK (unknown)"},
            {URL: "", TEXT: "LINK (unknown)"}
        ];

        if (!linkCollection.length || linkCollection.length > 5)
            return returnData;

        linkCollection.forEach((linkURL, index)=> {
            if (!linkURL.length) return;

            // Needs to have http(s) prepended or the damn thing will point at the current URL instead with the link appended
            if (linkURL.match(/^http/))
                returnData[index].URL = linkURL;
            else
                returnData[index].URL = "http://" + linkURL;
            // We are not going to assume https, but rather hope that whatever domain this is has http to https redirect in place...
            
            if (linkURL.search(this._linkDomainRegex) > -1) {

                let linkDomainMatch = linkURL.match(this._linkDomainRegex);
                if (linkDomainMatch.length > 2)
                    returnData[index].TEXT = `LINK (${linkDomainMatch[2]})`;
            }
        });

        return returnData;
    }

	_createDOMWishEditButton(id=-1) {

		const container = document.createElement("div");
		container.classList.add("wish-item","wish-edit","p-3");
		if (!this._eligableForEditMode()) container.classList.add("hidden");

		const button = document.createElement("button");
		button.classList.add("btn","btn-warning");

		button.dataset.wishid = id;
		button.dataset.toggle = "modal";
        button.dataset.target = "#EditWish";
        
		const icon = document.createElement("i");
		icon.classList.add("fas","fa-edit","fa-3x");

		container.appendChild(button);
		button.appendChild(icon);

		return container;
	}

	_createDOMWishDeleteButton(id=-1) {
		
		const container = document.createElement("div");
		container.classList.add("wish-item","wish-delete","p-3");
		if (!this._eligableForEditMode()) container.classList.add("hidden");

		const button = document.createElement("button");
		button.classList.add("btn","btn-danger"); 

        button.dataset.wishid = id;
        button.dataset.toggle = "modal"
        button.dataset.target = `#${this._elements.deleteWishDialogElement.id}`;

		const icon = document.createElement("i");
		icon.classList.add("fas","fa-trash-alt","fa-3x");

		container.appendChild(button);
		button.appendChild(icon);

		return container;
    }

    onOpenEditDialog(callingWishID=null) {
        if (isNaN(parseInt(callingWishID))) throw new Error("Could not parse wish id when opening edit dialog");

        this._elements.editWishDialog.dataset.activewish = callingWishID;
        this._elements.editPictureStatusIndictor.classList.add("hidden");
		
		if (callingWishID === 0) {
			this._elements.editPictureImgElement.src = "";
			return; // New wish, leave dialog blank
		}

        const callingWish = this._wishlist.getWish(callingWishID);
        const callingWishLinks = callingWish.getLinks();

        this._elements.editPictureImgElement.src = callingWish.getPicture();
        this._elements.editPictureURLTextElement.value = callingWish.getPicture();
        this._elements.editDescriptionTexarea.value = callingWish.getDescription();
        this._elements.editLinksTextElements.forEach((textElement, index)=> textElement.value = callingWishLinks[index] || "");
    }

    onCloseEditDialog() {
        this._elements.editWishDialog.dataset.activewish = 0;
        this._elements.editPictureImgElement.src = "";
        this._elements.editPictureURLTextElement.value = "";
        this._elements.editDescriptionTexarea.value = "";
        this._elements.editLinksTextElements.forEach((textElement)=> textElement.value = "");
    }
    
    onOpenDeleteDialog(callingWishID=null) {
        if (isNaN(parseInt(callingWishID))) throw new Error("Could not parse wish id when opening delete dialog");
        this._elements.deleteWishDialogElement.dataset.wishid = callingWishID;
    }

    async onDeleteWish() {
        $(this._elements.deleteWishDialogElement).modal("hide");

        const wishIDToDelete = parseInt(this._elements.deleteWishDialogElement.dataset.wishid);
        this._elements.deleteWishDialogElement.dataset.wishid = 0;

        if (isNaN(wishIDToDelete) || wishIDToDelete == 0) throw new Error("Could not parse wish ID to delete or it's 0");
        let backendResponse = await this._wishlist.deleteWish(wishIDToDelete, this._services.get("authentication").getToken());
        
        if (backendResponse.ERROR === true) {
            /*if (backendResponse.RESPONSE.DATA.STATUS_CODE === 1) {
                this._services.get("notifications").notifyWarning("Your login session is invalid", 3000);
                this._services.get("events").trigger(this._services.get("eventTypes").USER_SESSION_INVALID);
            }
            else*/

                console.error(backendResponse.DATA);
                this._services.get("notifications").notifyError("Failed to delete wish\nContact the admin :/", 3000);
        }
        else {
            this._removeWishFromDOM(wishIDToDelete);
            this._services.get("notifications").notifySuccess("Wish deleted");
        }
    }

    async onSaveWish() {
        this._elements.closeEditWishDialogButton.disabled = true;
        this._elements.saveWishChangesButton.disabled = true;
        this._elements.saveWishesLoader.classList.remove("hidden");

        const callingWishID = parseInt(this._elements.editWishDialog.dataset.activewish);
        let newWish = false;
        let changesSavedMessage = "Changes saved";

        if (callingWishID === 0) {
            newWish = true;
            changesSavedMessage = "New wish added";
        }

        let links = new Array(5);
        this._elements.editLinksTextElements.forEach((textElement, index)=> links[index] = textElement.value.trim());

        const modifiedWish = new Wish(
            callingWishID,
            this._elements.editPictureURLTextElement.value.trim(),
            this._elements.editDescriptionTexarea.value.trim(),
            links
        );

        // Only relevant for existing wishes
        if (!newWish && this._wishlist.getWish(callingWishID).equalTo(modifiedWish)) {
            this._elements.closeEditWishDialogButton.disabled = false;
            this._elements.saveWishChangesButton.disabled = false;
            this._elements.saveWishesLoader.classList.add("hidden");

            this._services.get("notifications").notifyWarning("Not saved: no changes made");
            return;
        }

        let validatePicture = false;

        if (newWish && modifiedWish.getPicture().length)
            validatePicture = true;
        else if (!newWish && this._wishlist.getWish(callingWishID).getPicture() !== modifiedWish.getPicture())
            validatePicture = true;

        if (validatePicture) {
            var pictureURLValid = await this._resolveNewImage(modifiedWish.getPicture());

            if (!pictureURLValid)
            {
                this._elements.closeEditWishDialogButton.disabled = false;
                this._elements.saveWishChangesButton.disabled = false;
                this._elements.saveWishesLoader.classList.add("hidden");

                return;
            }

            this._elements.editPictureImgElement.src = modifiedWish.getPicture();
        }

        let backendResponse;

        if (newWish)
            backendResponse = await this._wishlist.addNewWish(modifiedWish, this._services.get("authentication").getToken());
        else
            backendResponse = await this._wishlist.saveWish(modifiedWish, this._services.get("authentication").getToken());
        
        if (backendResponse.ERROR === true)
            this._services.get("notifications").notifyError("Failed to save wish changes\nContact the admin :/", 3000);
        else {
            this._services.get("notifications").notifySuccess(changesSavedMessage);
            if (newWish)
                this._createDOMWish(modifiedWish);
            else
                this._updateDOMWish(modifiedWish);
        }

        this._elements.closeEditWishDialogButton.disabled = false;
        this._elements.saveWishChangesButton.disabled = false;
        this._elements.saveWishesLoader.classList.add("hidden");
    }

    _updateDOMWish(wishInstance={}) {
        if (!(wishInstance instanceof Wish))
            throw new Error("Error updating wish in DOM. Argument 'wishInstance' is not an instance of Wish: " + wishInstance.constructor.name);

        const existingDOMWish = document.querySelector(`section[data-wishid='${wishInstance.getId()}']`);
        if (!existingDOMWish)
            throw new Error("Error updating wish in DOM. Can't seem to find an existing wish with ID: " + wishInstance.getId());

        existingDOMWish.querySelector("div.wish-image img").src = wishInstance.getPicture();
        existingDOMWish.querySelector("div.wish-description").innerText = wishInstance.getDescription() || "(no description)";
        const wishLinksContainer = existingDOMWish.querySelector("div.wish-links");
        wishLinksContainer.innerHTML = "";

        let hasLinks = false;
        wishInstance.getLinks().forEach((linkURL)=> {
            if (linkURL.length > 0) hasLinks = true;
        });

        if (!hasLinks)
            wishLinksContainer.innerText = "(no links)";
        else {
            this._resolveLinkText(wishInstance.getLinks()).forEach((linkPair)=> {
                if (!linkPair.URL.length) return;
                const enclosingDiv = document.createElement("div");

                const linkIcon = document.createElement("i");
                linkIcon.classList.add("fas","fa-link");

                const hyperlink = document.createElement("a");
                hyperlink.setAttribute("target", "_blank");
                hyperlink.innerText = linkPair.TEXT;
                hyperlink.href = linkPair.URL;

                enclosingDiv.appendChild(linkIcon);
                linkIcon.appendChild(hyperlink);

                wishLinksContainer.appendChild(enclosingDiv);
            });
        }
    }

    async _resolveNewImage(imageURL) {

        const successClassList = ["fa-check-circle","text-success"];
        const waitingClassList = ["fa-spinner","fa-spin","text-info"];
        const failureClassList = ["fa-times-circle","text-danger"];

        this._elements.editPictureStatusIndictor.classList.remove(...successClassList);
        this._elements.editPictureStatusIndictor.classList.remove(...waitingClassList);
        this._elements.editPictureStatusIndictor.classList.remove(...failureClassList);

        this._elements.editPictureStatusIndictor.classList.add(...waitingClassList);
        this._elements.editPictureStatusIndictor.classList.remove("hidden");

        const backendResult = await fetch(`TestImageURL.cfm?ImageURL=${encodeURIComponent(imageURL)}`, {mode: "no-cors"})
        .then(response=> response.json())
        .then(jsonResponse=> {
            if (jsonResponse.STATUS == 1) {
                this._services.get("notifications").notifyError("Couldn't verify the picture URL. The URL isn't reachable or valid", 3000);
                this._elements.editPictureStatusIndictor.classList.remove(...waitingClassList);
                this._elements.editPictureStatusIndictor.classList.add(...failureClassList);
                return false;
            }

            if (jsonResponse.STATUS == 2) {
                this._services.get("notifications").notifyError("Couldn't verify the picture URL. No data is returned or not in the right format", 3000);
                this._elements.editPictureStatusIndictor.classList.remove(...waitingClassList);
                this._elements.editPictureStatusIndictor.classList.add(...failureClassList);
                return false;
            }

            if (jsonResponse.STATUS == 3) {
                this._services.get("notifications").notifyError("Couldn't verify the picture URL. The data returned is not an image or a valid image format", 3000);
                this._elements.editPictureStatusIndictor.classList.remove(...waitingClassList);
                this._elements.editPictureStatusIndictor.classList.add(...failureClassList);
                return false;
            }

            this._elements.editPictureStatusIndictor.classList.remove(...waitingClassList);
            this._elements.editPictureStatusIndictor.classList.add(...successClassList);

            return true;
        });

        return backendResult;
    }
}