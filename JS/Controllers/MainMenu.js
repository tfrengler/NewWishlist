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
			logoutButton: document.getElementById("LogOut")
		});

		this._setupEventHandlers();
		
		console.log(`MainMenu-controller initialized with backendEntryPoint '${backendEntryPoint}' and ajaxAuthKey: ${ajaxAuthKey}`);
		return Object.freeze(this);
	}

	_setupEventHandlers() {
		this._elements.loginButton.addEventListener("click", (event) => this.logIn(event));
		this._elements.logoutButton.addEventListener("click", (event) => this.logOut(event));
		
		Array.from(this._elements.wishlistContainer.getElementsByTagName("button")).forEach(button=> {
			button.addEventListener("click", (event) => this.loadWishlist(event) )
		})
	}

	// EVENT HANDLERS
	loadWishlist(event) {
		const wishlist = new Wishlist(this._backendEntryPoint, this._ajaxAuthKey);
		wishlist.load(event.srcElement.dataset["wishlistOwnerId"] || -1)
		.then(response=> {
			if (response.ERROR === true) {
				// TODO(thomas): What to do?
				console.error("Loading the wishlist failed :(");
				return;
			}

			this._services.get("events").trigger(this._services.get("eventTypes").WISHLIST_LOADED, wishlist);
		});
	}

	logIn(event) {
		event.srcElement.disabled = true;

		this._authentication.logIn(
			this._elements.usernameInput.value,
			this._elements.passwordInput.value
		)
		.then(response => {
			if (!response.ERROR) {
				this._elements.usernameInput.value = "";
				this._elements.passwordInput.value = "";
				event.srcElement.innerText = "LOGGED IN AS: " + this._authentication.getUserDisplayName();
				this._elements.usernameInput.disabled = true;
				this._elements.passwordInput.disabled = true;

				this._services.get("events").trigger(
					this._services.get("eventTypes").LOGIN_SUCCESS, 
					{
						token: this._authentication.getToken(),
						userDisplayName: this._authentication.getUserDisplayName()
					}
				)
				return;
			}

			// TODO(thomas): What happens if there's an error?
			this._services.get("events").trigger(this._services.get("eventTypes").LOGIN_FAILED);
			event.srcElement.disabled = false;

			return;
		});
	}

	logOut(event) {
		event.srcElement.disabled = true;

		this._authentication.logOut(this._authentication.getToken())
		.then(response => {
			if (response.ERROR === true) {
				// TODO(thomas): What to do? This is quite serious
				console.error("Logout failed...? Wut?");
				return;
			}

			this._elements.usernameInput.value = "";
			this._elements.passwordInput.value = "";
			this._elements.loginButton.innerText = "LOG IN";

			this._elements.loginButton.disabled = false;
			this._elements.usernameInput.disabled = false;
			this._elements.passwordInput.disabled = false;

			this._services.get("events").trigger(this._services.get("eventTypes").LOGOUT_SUCCESS);
			event.srcElement.disabled = false;

			return;
		});
	}

	// CALLBACKS
	onLogIn() {

	}

	onLogOut() {

	}

	onLoadWishlist() {

	}

	onCloseMenu() {

	}
}