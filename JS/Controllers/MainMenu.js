"use strict";

import { Wishlist } from "../Wishlist.js";

export class MainMenu {

	constructor(authenticationManager={}, backendEntryPoint="UNDEFINED_ARGUMENT", ajaxAuthKey="UNDEFINED_ARGUMENT", services=null) {
		if (authenticationManager.constructor.name != "AuthenticationManager")
			throw new Error("Argument '' is not an instance of AuthenticationManager!");

		this._backendEntryPoint = backendEntryPoint;
		this._ajaxAuthKey = ajaxAuthKey;
		this._authentication = authenticationManager;
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
		this._elements.loginButton.addEventListener("click", (event) => this.logIn(event));
		this._elements.logoutButton.addEventListener("click", (event) => this.logOut(event));

		this._elements.usernameInput.addEventListener("keyup", ()=> this.onUserCredentialsInput());
		this._elements.passwordInput.addEventListener("keyup", ()=> this.onUserCredentialsInput());
		
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
		this._services.get("events").trigger(this._services.get("eventTypes").WISHLIST_LOADED, wishlist);
	}

	async logIn(event) {

		event.srcElement.disabled = true;
		this._elements.loginButtonLoader.classList.remove("hidden");

		const loginResponse = await this._authentication.logIn(
			this._elements.usernameInput.value.trim(),
			this._elements.passwordInput.value.trim()
		);

		if (loginResponse.ERROR) {
			event.srcElement.disabled = false;
			this._services.get("events").trigger(this._services.get("eventTypes").LOGIN_FAILED);
			this._elements.loginButtonLoader.classList.add("hidden");

			this._services.get("notifications").notifyError("The username or password is not correct");
			return;
		}

		event.srcElement.innerText = "LOGGED IN: " + this._authentication.getUserDisplayName();

		this._elements.usernameInput.value = "";
		this._elements.passwordInput.value = "";

		this._elements.usernameInput.disabled = true;
		this._elements.passwordInput.disabled = true;
		this._elements.logoutButton.disabled = false;

		this._elements.loginButtonLoader.classList.add("hidden");
		this._services.get("notifications").notifySuccess("You have been logged in");

		this._services.get("events").trigger(
			this._services.get("eventTypes").LOGIN_SUCCESS, 
			{
				token: this._authentication.getToken(),
				userDisplayName: this._authentication.getUserDisplayName()
			}
		)
	}

	async logOut(event) {

		event.srcElement.disabled = true;
		this._elements.logoutButtonLoader.classList.remove("hidden");
		const logoutResponse = await this._authentication.logOut(this._authentication.getToken());

		if (logoutResponse.ERROR === true) {
			event.srcElement.disabled = false;
			this._elements.logoutButtonLoader.classList.add("hidden");
			this._services.get("notifications").notifyError("Oops, failed to log out\nContact the admin", 4000);
			return;
		}

		this._elements.usernameInput.value = "";
		this._elements.passwordInput.value = "";
		this._elements.loginButton.innerText = "LOG IN";

		this._elements.usernameInput.disabled = false;
		this._elements.passwordInput.disabled = false;

		event.srcElement.disabled = false;
		this._elements.logoutButtonLoader.classList.add("hidden");

		this._services.get("notifications").notifySuccess("You have been logged out");
		this._services.get("events").trigger(this._services.get("eventTypes").LOGOUT_SUCCESS);
	}
}