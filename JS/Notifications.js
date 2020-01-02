"use strict";

const NotificationTypes = Object.freeze({
	SUCCESS: Symbol("SUCCESS"),
	WARNING: Symbol("WARNING"),
	ERROR: Symbol("ERROR"),
	LOADING: Symbol("LOADING")
});

const CSSClassMap = {};
CSSClassMap[NotificationTypes.SUCCESS] = "test";
CSSClassMap[NotificationTypes.WARNING] = "test";
CSSClassMap[NotificationTypes.ERROR] = "test";
CSSClassMap[NotificationTypes.LOADING] = "test";
Object.freeze(CSSClassMap);

class Notifications {

	constructor() {
		this.anchor = null;

		return Object.freeze(this);
	}

	notifySuccess(message, timeout=0) {
		this.notify(NotificationTypes.SUCCESS, message, timeout);
	}

	notifyLoading(timeout=0) {
		this.notify(NotificationTypes.LOADING, "", timeout);
	}

	notifyError(message, timeout=0) {
		this.notify(NotificationTypes.ERROR, message, timeout);
	}

	notifyWarning(message, timeout=0) {
		this.notify(NotificationTypes.WARNING, message, timeout);
	}

	notify(type, message, fadeoutTime=0) {

		this.anchor.hide();
		this.removeAlertClasses(this.anchor);
		this.anchor.removeClass("ajax-loading");

		this.anchor.addClass( CSSClassMap[type] );
		this.anchor.html(message);
		this.anchor.show();

		if (fadeoutTime)
			setTimeout(function() {this.anchor.fadeOut(1000);},fadeoutTime)
	}

	onAJAXCallError(AjaxResponse) {

		var MainContentContainer = $("#" + constants.MAINCONTENT_CONTAINER_ID);
		var MessageBox = $("#Notification-Box");

		if (debug) {
			MainContentContainer.html( AjaxResponse[0].responseText );
		} else {
		
			removeAlertClasses(MessageBox);
			MessageBox.removeClass("ajax-loading");
			MessageBox.addClass("red-error-text");

			MessageBox.html("Ooops, something went wrong. Sorry about that! A team of highly trained monkeys has been dispatched to deal with the situation. If you see them tell them what you did when this happened.");
			MessageBox.fadeIn(1000);
		}

		console.warn("onAJAXCallError triggered");
		console.warn(AjaxResponse[0]);
	}

	onJavascriptError(ErrorContent, MethodName) {

		var MainContentContainer = $("#" + constants.MAINCONTENT_CONTAINER_ID);
		var MessageBox = $("#Notification-Box");
		var DebugOutput = "";
		var FriendlyErrorMessage = "Ooops, something went wrong! A team of highly trained monkeys has been dispatched to deal with the situation. If you see them tell them what you did when this happened."

		if (typeof ErrorContent === "object") {
			DebugOutput = JSON.stringify(ErrorContent);
		}

		if (debug) {
			notifyUserOfError( MessageBox, DebugOutput, 0 );

		} else {
			notifyUserOfError( MessageBox, FriendlyErrorMessage, 0 );
		}

		console.warn("onJavascriptError triggered by " + MethodName);
		console.warn(ErrorContent);
	}

	ajaxLoadButton(enableOrDisable, DOMPointer, Value) {

		if (enableOrDisable) {
			DOMPointer.prop("disabled", true);
			this.transient.ajaxLoaderValue = DOMPointer.val();
			DOMPointer.val("");
			DOMPointer.addClass("ajax-loading");
		}
		else {
			DOMPointer.prop("disabled", false);
			DOMPointer.removeClass("ajax-loading");

			if (Value !== undefined && Value.length > 0) {
				DOMPointer.val(Value.trim())
			} else {
				DOMPointer.val( this.transient.ajaxLoaderValue );
			}

			this.transient.ajaxLoaderValue = "";
		}
	}

}

export {Notifications, NotificationTypes};