"use strict";

const NotificationTypes = Object.freeze({
	SUCCESS: Symbol("SUCCESS"),
	WARNING: Symbol("WARNING"),
	ERROR: Symbol("ERROR"),
	LOADING: Symbol("LOADING")
});

const CSSClassMap = Object.create(null);
CSSClassMap[NotificationTypes.SUCCESS] = "notification-success";
CSSClassMap[NotificationTypes.WARNING] = "notification-warning";
CSSClassMap[NotificationTypes.ERROR] = "notification-error";
Object.freeze(CSSClassMap);

class NotificationManager {

	constructor(anchor=Symbol("ARGUMENT_EMPTY"), timeout=0, services=null) {
		if (!(anchor instanceof HTMLElement))
			throw new Error("Argument 'anchor' is NOT an instance of HTMLElement: " + anchor.constructor.name);

		this._anchor = anchor || Symbol("ARGUMENT_UNDEFINED");
		this._globalTimeout = timeout || 1000;
		this._services = services;
		this._ajaxLoadValueMap = new Map();

		console.log("NotificationManager initialized");
		return Object.freeze(this);
	}

	_createNotification() {
		const newNotification = document.createElement("span");
		newNotification.className = "notification-message p-3 rounded hidden";
		this._anchor.appendChild(newNotification);

		return newNotification;
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

		const notification = this._createNotification();

		notification.classList.remove(...Object.keys(CSSClassMap));
		notification.classList.add(CSSClassMap[type]);
		notification.innerText = message;
		notification.classList.remove("hidden");

		setTimeout(
			()=> {
				notification.classList.add("fade-out");
				setTimeout(()=> this._anchor.removeChild(notification), 1500);
			},
			timeout || this._globalTimeout
		);
	}
}

export {NotificationManager, NotificationTypes};