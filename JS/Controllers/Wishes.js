/* eslint-disable no-useless-escape */
"use strict";

// import { JSUtils } from "../Utils.js";

export class Wishes {

	constructor(backendEntryPoint="UNDEFINED_ARGUMENT", ajaxAuthKey="UNDEFINED_ARGUMENT", services=null) {

		this._backendEntryPoint = backendEntryPoint;
		this._ajaxAuthKey = ajaxAuthKey;
		this._services = services;
		this._wishlist = null;
		this._linkDomainRegex = new RegExp("^(http://|https://|www\.)(.+\\..+?)(?=/|$)/");

		this._elements = Object.freeze({
            addNewWishButton: document.getElementById("AddWish"),
            wishlistContainer: document.getElementById("WishRowContainer")
		});

		let immutable = {
			configurable: false,
			enumerable: false,
			writable: false
		};

		Object.defineProperties(this, {
			"_backendEntryPoint": immutable,
			"_ajaxAuthKey": immutable,
			"_services": immutable
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
	}
	
	_onWishlistLoaded(data) {
        if (data.constructor.name !== "Wishlist")
            throw new Error("Expected event data to be an instance of Wishlist, but it is not: " + data.constructor.name)

        this._wishlist = data;
        this._wishlist.getWishes().forEach(wish=> this._createDOMWish(wish));
    }
    
    _insertWishInDOM(wishNode) {
        const secondLastRowIndex = document.querySelectorAll(`#${this._elements.wishlistContainer.id} > div.row`).length - 1;
        this._elements.wishlistContainer.insertBefore(wishNode, this._elements.wishlistContainer.children[secondLastRowIndex]);
    }
	
	_createDOMWish(wishInstance) {
        if (wishInstance.constructor.name != "Wish")
			throw new Error("Argument 'wishInstance' is not an instance of Wish!");

        const wishRow = document.createElement("div");
        wishRow.classList.add("row","wish-row-container");

		const container = document.createElement("section");
        container.classList.add("wish","border","border-dark","rounded","p-3","d-inline-flex","flex-row","bg-light","mb-3");
        container.id = "WishID_" + wishInstance.getId();

		const imageContainer = document.createElement("div");
		imageContainer.classList.add("wish-item","wish-image","border","rounded","mr-3","overflow-hidden");

		const image = document.createElement("img");
		image.classList.add("rounded");
		image.onerror = main.onImageNotFound;
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

			const enclosingDiv = document.createElement("div");

			const linkIcon = document.createElement("i");
			linkIcon.classList.add("fas","fa-link");

			const hyperlink = document.createElement("a");
			hyperlink.setAttribute("href", linkURL);

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

		const button = document.createElement("button");
		button.classList.add("btn","btn-danger"); 

		button.id = "DeleteWish_" + id;

		const icon = document.createElement("i");
		icon.classList.add("fas","fa-trash-alt","fa-3x");

		container.appendChild(button);
		button.appendChild(icon);

		return container;
    }
    
    deleteWish(id=-1) {

    }

    addWish() {
        
    }

    clear() {

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