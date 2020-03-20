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

// Debug mode, expose the stuff to the user so we can access stuff via the console
if (window.location.href.indexOf("?DevMode=1") > -1) {
	window.main = main;
	window.main.authentication = authentication;
}

Object.freeze(main);
Object.freeze(main.controllers);
console.log("Everything's initialized and ready to rock and roll");