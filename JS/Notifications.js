"use strict";

const NotificationTypes = Object.freeze({
	SUCCESS: Symbol("SUCCESS"),
	WARNING: Symbol("WARNING"),
	ERROR: Symbol("ERROR"),
	LOADING: Symbol("LOADING")
});

const CSSClassMap = Object.create(null);
CSSClassMap[NotificationTypes.SUCCESS] = "TEST_SUCCESS";
CSSClassMap[NotificationTypes.WARNING] = "TEST_WARNING";
CSSClassMap[NotificationTypes.ERROR] = "TEST_ERROR";
CSSClassMap[NotificationTypes.LOADING] = "TEST_LOADING";
Object.freeze(CSSClassMap);

class NotificationManager {

	constructor(anchor=Symbol("ARGUMENT_EMPTY"), timeout=0, services=null) {
		if (!(anchor instanceof HTMLElement))
			throw new Error("Argument 'anchor' is NOT an instance of HTMLElement: " + anchor.constructor.name);

		this.anchor = anchor || Symbol("ARGUMENT_UNDEFINED");
		this.timeout = timeout || 1000;
		this.services = services;
		this.ajaxLoadValueMap = new Map();

		console.log("NotificationManager initialized");
		return Object.freeze(this);
	}

	notifySuccess(message, timeout=0) {
		this._notify(NotificationTypes.SUCCESS, message, timeout);
	}

	notifyLoading(message, timeout=0) {
		this._notify(NotificationTypes.LOADING, message, timeout);
	}

	notifyError(message, timeout=0) {
		this._notify(NotificationTypes.ERROR, message, timeout);
	}

	notifyWarning(message, timeout=0) {
		this._notify(NotificationTypes.WARNING, message, timeout);
	}

	_notify(type, message, timeout=0) {

		this._hide();
		this.anchor.classList.remove(...Object.keys(CSSClassMap));
		this.anchor.classList.add(CSSClassMap[type]);
		this.anchor.innerText = message;
		this._show();

		setTimeout(function() {this._hide()}, timeout || this.timeout);
	}

	_hide() {
		this.anchor.style.display = "hidden";
	}

	_show() {
		this.anchor.style.display = "flex";
	}

	onAJAXCallError() {

	}

	onJavascriptError() {

	}

	ajaxLoadButton(enableOrDisable, buttonElement, id=0) {
		if (!(buttonElement instanceof HTMLButtonElement))
			throw new Error("Argument 'buttonElement' is NOT an instance of HTMLButtonElement");

		if (enableOrDisable === true) {

			let newId = this.services.get("utils").hash(buttonElement.value);
			buttonElement.disabled = true;
			this.ajaxLoadValueMap.set(newId, buttonElement.value);
			buttonElement.value = "";
			buttonElement.classList.add(NotificationTypes.LOADING);

			return newId;
		}

		buttonElement.disabled = false;

		if (this.ajaxLoadValueMap.has(id)) {

			buttonElement.value = this.ajaxLoadValueMap.get(id);
			this.ajaxLoadValueMap.delete(id);
		}

		buttonElement.classList.remove(NotificationTypes.LOADING);
	}

}

export {NotificationManager, NotificationTypes};