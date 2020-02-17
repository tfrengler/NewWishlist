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
import { Wishes } from "./Controllers/Wishes.js";

main.controllers = Object.create(null);

let eventManager = new Events.EventManager(backendEntryPoint, CFAjaxAuthKey);
let controllerServices = new ServiceLocator();

// Services
let notifications = new NotificationManager(document.getElementById('Notifications'), 2000);
let authentication = new AuthenticationManager(backendEntryPoint, CFAjaxAuthKey);

controllerServices.provide("notifications", notifications);
controllerServices.provide("events", eventManager);
controllerServices.provide("eventTypes", Events.EventTypes);
controllerServices.provide("authentication", authentication);

// Controllers
main.controllers.menuDialog = new MainMenu(backendEntryPoint, CFAjaxAuthKey, controllerServices);
main.controllers.wishlist = new Wishes(controllerServices);

// Object.freeze(main);
// Object.freeze(main.controllers);
console.log("Everything's initialized and ready to rock and roll");

// TODO(thomas): debugging
window.main = main;
document.getElementById("MenuButton").click();
document.querySelector("[data-wishlist-owner-id='1']").click();
document.getElementById("Username").value = "tfrengler";
document.getElementById("Password").value = "tf499985";
main.controllers.menuDialog.logIn({srcElement: document.getElementById("LogIn")});

/*
	image/jpeg
	image/bmp
	image/png
	image/tiff
	image/webp
*/