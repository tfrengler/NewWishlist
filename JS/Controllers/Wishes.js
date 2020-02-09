/* eslint-disable no-useless-escape */
/* global $ */
"use strict";

import { JSUtils } from "../Utils.js";
import { Wish } from "../Wish.js";

export class Wishes {

	constructor(services=null) {

		this._services = services;
        this._wishlist = null; // Mutable
		this._linkDomainRegex = new RegExp("^(http://|https://|www\.)(.+\\..+?)(?=/|$)/");

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
			activeWishlistOwnerNameElement: document.getElementById("ActiveWishlistOwnerName")
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
			this._onWishlistLoaded,
			this
        );

        this._services.get("events").subscribe(
			this._services.get("eventTypes").LOGIN_SUCCESS,
			this._onUserLoginOrLogout,
			this
        );

        this._services.get("events").subscribe(
			this._services.get("eventTypes").LOGOUT_SUCCESS,
			this._onUserLoginOrLogout,
			this
        );
        
        $(this._elements.editWishDialog).on('show.bs.modal', (event)=> this.onOpenEditDialog(event));
        $(this._elements.editWishDialog).on('hide.bs.modal', (event)=> this.onCloseEditDialog(event));
        this._elements.saveWishChangesButton.addEventListener("click", (event)=> this.onSaveWish(event));

        this._elements.editPictureImgElement.addEventListener("error", JSUtils.onImageNotFound)
	}

	_onUserLoginOrLogout() {
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
	
	_onWishlistLoaded(data) {
        if (data.wishlist.constructor.name !== "Wishlist")
            throw new Error("Expected event data to be an instance of Wishlist, but it is not: " + data.wishlist.constructor.name)

		this._elements.welcomeMessageContainer.remove();
		this._elements.activeWishlistOwnerNameElement.innerText = data.wishlistOwner;
		document.querySelectorAll(".wish-row").forEach(wishRow=> wishRow.remove());

        this._wishlist = data.wishlist;
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
		description.innerText = wishInstance.getDescription();

		const linksContainer = document.createElement("div");
		linksContainer.classList.add("wish-item","wish-links","border","rounded","p-3","text-primary");

		wishInstance.getLinks().forEach((linkURL)=> {
			if (!linkURL.length) return;
			const enclosingDiv = document.createElement("div");

			const linkIcon = document.createElement("i");
			linkIcon.classList.add("fas","fa-link");

			const hyperlink = document.createElement("a");
			hyperlink.setAttribute("href", linkURL);

            // TODO(thomas): Improve this to make it more failsafe
			let linkText;
			if (linkURL.search(this._linkDomainRegex) > -1)
				linkText = `LINK (${linkURL.match(this._linkDomainRegex)[2]})`;
			else
				linkText = "LINK";
			
			hyperlink.innerText = linkText;

			enclosingDiv.appendChild(linkIcon);
			linkIcon.appendChild(hyperlink);

			linksContainer.appendChild(enclosingDiv);
		});
        
        // Putting it all together
        container.appendChild(this._createDOMWishEditButton(wishInstance.getId()));
        
        container.appendChild(imageContainer);
        container.appendChild(description);
        container.appendChild(linksContainer);

        container.appendChild(this._createDOMWishDeleteButton(wishInstance.getId()));
        
		wishRow.appendChild(container);
        this._insertWishInDOM(wishRow); 
	}

	_createDOMWishEditButton(id=-1) {

		const container = document.createElement("div");
		container.classList.add("wish-item","wish-edit","p-3");
		if (!this._eligableForEditMode()) container.classList.add("hidden");

		const button = document.createElement("button");
		button.classList.add("btn","btn-warning");

		button.id = "EditWish_" + id;
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

		button.id = "DeleteWish_" + id;

		const icon = document.createElement("i");
		icon.classList.add("fas","fa-trash-alt","fa-3x");

		container.appendChild(button);
		button.appendChild(icon);

		return container;
    }

    onOpenEditDialog(event) {

		const callingWishID = parseInt(event.relatedTarget.dataset.wishid);
        this._elements.editWishDialog.dataset.activewish = callingWishID;
		
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
    
    deleteWish(id=-1) {

    }

    addWish() {
        
    }

    async onSaveWish() {
        this._elements.closeEditWishDialogButton.disabled = true;
        this._elements.saveWishChangesButton.disabled = true;
        this._elements.saveWishesLoader.classList.remove("hidden");

        const callingWishID = parseInt(this._elements.editWishDialog.dataset.activewish);

        let links = new Array(5);
        this._elements.editLinksTextElements.forEach((textElement, index)=> links[index] = textElement.value.trim());

        const modifiedWish = new Wish(
            callingWishID,
            this._elements.editPictureURLTextElement.value.trim(),
            this._elements.editDescriptionTexarea.value.trim(),
            links
        );

        if (this._wishlist.getWish(callingWishID).equalTo(modifiedWish)) {
            this._elements.closeEditWishDialogButton.disabled = false;
            this._elements.saveWishChangesButton.disabled = false;
            this._elements.saveWishesLoader.classList.add("hidden");

            this._services.get("notifications").notifyWarning("Not saved: no changes made");
            return;
        }

        const saveWishResponse = await this._wishlist.saveWish(modifiedWish, this._token);
        
        if (saveWishResponse.ERROR === true)
            this._services.get("notifications").notifyError("Failed to save wish changes\nContact the admin :/", 3000);
        else
            this._services.get("notifications").notifySuccess("Changes saved");

        this._elements.closeEditWishDialogButton.disabled = false;
        this._elements.saveWishChangesButton.disabled = false;
        this._elements.saveWishesLoader.classList.add("hidden");
    }
}

/*

<section id="WishID_X" class="wish border border-dark rounded p-3 d-inline-flex flex-row bg-light mb-3">

	<div class="wish-item wish-edit p-3" >
		<button id="EditWish_X" class="btn btn-warning" data-toggle="modal" data-target="#EditWish" >
			<i class="fas fa-edit fa-3x"></i>
		</button>
	</div>

	<div class="wish-item wish-image border rounded mr-3 overflow-hidden">
		<img onerror="onImageNotFound(this)" class="rounded" src="Media/Images/xxx.jpg" referrerpolicy="no-referrer" validate="never" />
	</div>

	<div class="wish-item wish-description border rounded overflow-hidden p-3 mr-3" >
		The Other Kind of Life<br/>
		by Shamus Young<br/>
		ISBN-10: 1790478510<br/>
		ISBN-13: 978-1790478514<br/>
	</div>

	<div class="wish-item wish-links border rounded p-3 text-primary" >
		<div><i class="fas fa-link">
			<a href="#">LINK</a>
		</i></div>
		<div><i class="fas fa-link">
			<a href="#">LINK</a>
		</i></div>
		<div><i class="fas fa-link">
			<a href="#">LINK</a>
		</i></div>
	</div>

	<div class="wish-item wish-delete p-3" >
		<button id="DeleteWish_X" class="btn btn-danger" >
			<i class="fas fa-trash-alt fa-3x"></i>
		</button>
	</div>
</section>

*/