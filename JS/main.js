/* 
global
	CFAjaxAuthKey
*/
"use strict";

const backendEntryPoint = "CFCs/AjaxProxy.cfc";
const main = Object.create(null);

import { AuthenticationManager } from "./Authentication.js";
import * as Events from "./EventManager.js";
import { ServiceLocator } from "./ServiceLocator.js";
import { NotificationManager } from "./Notifications.js";
import { MainMenu } from "./Controllers/MainMenu.js";

main.controllers = Object.create(null);

let eventManager = new Events.EventManager(backendEntryPoint, CFAjaxAuthKey);
let controllerServices = new ServiceLocator();

// Services
let notifications = new NotificationManager(document.getElementById('Notifications'), 2000);
let authentication = new AuthenticationManager(backendEntryPoint, CFAjaxAuthKey);

controllerServices.provide("notifications", notifications);
controllerServices.provide("events", eventManager);
controllerServices.provide("eventTypes", Events.EventTypes);

// Controllers
main.controllers.menuDialog = new MainMenu(authentication, backendEntryPoint, CFAjaxAuthKey, controllerServices);

// Object.freeze(main);
// Object.freeze(main.controllers);
console.log("Everything's initialized and ready to rock and roll");

// TODO(thomas): debugging
window.main = main;

/*
	image/jpeg
	image/bmp
	image/png
	image/tiff
	image/webp
*/

/*

main: {

	// All controllers have an element-map with an internal string name as key, and the value is a handle to each permanent/static DOM element
	// All controllers also have an init-function which serves to set up all initial, permanent event handlers

	controllers: {
		menuDialog: {
			authentication: {}
			loadWishlist()
			logIn()
			logOut()
			onLogIn()
			onLogOut()
		}

		headersAndFooters: {
			onLoadWishlist()
			onLoggedIn()
			onLoggedOut()
			onEnableEditMode()
			onDisableEditMode()
		}

		wishlist: {
			state: {wishlist}
			addNewWish()
			delete()
			edit()
			onOpenAddDialog()
			onOpenEditDialog()
			onSaveChanges()
			onAddedNewWish()
			onDeletedWish()
			onWishlistLoaded()
			renderWish()
			removeRenderedWish()
			onLoggedIn()
			onLoggedOut()
			onEnableEditMode()
			onDisableEditMode()
		}

		editWishDialog: {
			onSelectPictureForUpload()
			onProvidePictureLink()
			onPictureValidated()
			onPictureNotValidate()
			onSaveChanges()
			onCloseDialog()
		}
	}
}
*/