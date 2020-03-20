"use strict";

import { Wishlist } from "../Wishlist.js";

export class MainMenu {

	constructor(backendEntryPoint="UNDEFINED_ARGUMENT", ajaxAuthKey="UNDEFINED_ARGUMENT", services=null) {

		this._backendEntryPoint = backendEntryPoint;
		this._ajaxAuthKey = ajaxAuthKey;
		this._services = services;

		this._elements = Object.freeze({
			root: document.getElementById("MainMenu"),
			usernameInput: document.getElementById("Username"),
			passwordInput: document.getElementById("Password"),
			wishlistContainer: document.getElementById("WishlistContainer"),
			loginButton: document.getElementById("LogIn"),
			loginButtonLoader: document.querySelector("#LogIn i"),
			logoutButtonLoader: document.querySelector("#LogOut i"),
			logoutButton: document.getElementById("LogOut"),
			wishlistButtons: document.querySelectorAll("#WishlistContainer button"), // An array of elements!
			wishlistLoader: document.getElementById("WishlistLoader"),
			closeMenuButton: document.getElementById("CloseMenu")
		});

		this._init();

		console.log("MainMenu-controller initialized");
		return Object.freeze(this);
	}

	_init() {
		this._elements.loginButton.addEventListener("click", (event) => this.logIn(event.srcElement));
		this._elements.logoutButton.addEventListener("click", (event) => this.logOut(event.srcElement));

		this._elements.usernameInput.addEventListener("keyup", ()=> this.onUserCredentialsInput());
		this._elements.passwordInput.addEventListener("keyup", ()=> this.onUserCredentialsInput());

		this._elements.root.addEventListener("keydown", (event)=> {
			if (event.keyCode == 13 && !this._elements.loginButton.disabled)
				this.logIn(this._elements.loginButton);
		});

		this._services.get("events").subscribe(
			this._services.get("eventTypes").USER_SESSION_INVALID,
			()=> this.logOut(this._elements.logoutButton),
			this
        );

		this._elements.wishlistButtons.forEach(button=> button.addEventListener("click", (event) => this.loadWishlist(event)));
	}

	// EVENT HANDLERS
	onUserCredentialsInput() {
		if (this._elements.usernameInput.value.trim().length > 0 && this._elements.passwordInput.value.trim().length > 0) {
			this._elements.loginButton.disabled = false;
			return;
		}

		this._elements.loginButton.disabled = true;
	}

	async loadWishlist(event) {

		this._elements.wishlistButtons.forEach(button=> button.disabled = true);
		this._elements.wishlistLoader.classList.remove("hidden");

		const wishlist = new Wishlist(this._backendEntryPoint, this._ajaxAuthKey);
        const loadWishlistResponse = await wishlist.load(event.srcElement.dataset["wishlistOwnerId"] || -1);

		if (loadWishlistResponse.ERROR) {
			this._elements.wishlistLoader.classList.add("hidden");
			this._elements.wishlistButtons.forEach(button=> button.disabled = false);
			this._services.get("notifications").notifyError("Oops, failed to load the wishlist\nContact the admin", 4000);
			return;
		}

		this._elements.wishlistLoader.classList.add("hidden");
		this._elements.wishlistButtons.forEach(button=> button.disabled = false);
		this._elements.closeMenuButton.click();

		this._services.get("notifications").notifySuccess("Wishload loaded");
		this._services.get("events").trigger(this._services.get("eventTypes").WISHLIST_LOADED, {
			wishlist: wishlist,
			wishlistOwner: event.srcElement.dataset["wishlistOwnerName"]
		});

		this._elements.closeMenuButton.click();
	}

	async logIn(loginButtonElement) {

		loginButtonElement.disabled = true;
		this._elements.loginButtonLoader.classList.remove("hidden");

		const loginResponse = await this._services.get("authentication").logIn(
			this._elements.usernameInput.value.trim(),
			this._elements.passwordInput.value.trim()
		);

		if (loginResponse.ERROR) {
			loginButtonElement.disabled = false;
			this._services.get("events").trigger(this._services.get("eventTypes").LOGIN_FAILED);
			this._elements.loginButtonLoader.classList.add("hidden");

			this._services.get("notifications").notifyError("The username or password is not correct");
			return;
		}

		loginButtonElement.innerText = "LOGGED IN: " + this._services.get("authentication").getUserDisplayName();

		this._elements.usernameInput.value = "";
		this._elements.passwordInput.value = "";

		this._elements.usernameInput.disabled = true;
		this._elements.passwordInput.disabled = true;
		this._elements.logoutButton.disabled = false;

		this._elements.loginButtonLoader.classList.add("hidden");
		this._services.get("notifications").notifySuccess("You have been logged in");

		this._services.get("events").trigger(this._services.get("eventTypes").LOGIN_SUCCESS);
	}

	async logOut(logOutButton) {

		logOutButton.disabled = true;
		this._elements.logoutButtonLoader.classList.remove("hidden");
		const logoutResponse = await this._services.get("authentication").logOut(this._services.get("authentication").getToken());

		if (logoutResponse.ERROR === true) {
			logOutButton.disabled = false;
			this._elements.logoutButtonLoader.classList.add("hidden");
			this._services.get("notifications").notifyError("Oops, failed to log out\nContact the admin", 4000);
			return;
		}

		this._elements.usernameInput.value = "";
		this._elements.passwordInput.value = "";
		this._elements.loginButton.innerText = "LOG IN";

		this._elements.usernameInput.disabled = false;
		this._elements.passwordInput.disabled = false;

		logOutButton.disabled = true;
		this._elements.logoutButtonLoader.classList.add("hidden");

		this._services.get("notifications").notifySuccess("You have been logged out");
		this._services.get("events").trigger(this._services.get("eventTypes").LOGOUT_SUCCESS);
	}
}