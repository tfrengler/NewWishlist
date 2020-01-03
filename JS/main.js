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
import { JSUtils } from "./Utils.js";
import { NotificationManager } from "./Notifications.js";
import { Wishlist } from "./Wishlist.js";
import { Wish } from "./Wish.js";

let models = Object.freeze({
    Wishlist: Wishlist,
    Wish: Wish
});

main.controllers = Object.freeze({
    menuDialog: Symbol("NOT_IMPLEMENTED"),
    headersAndFooters: Symbol("NOT_IMPLEMENTED"),
    wishlist: Symbol("NOT_IMPLEMENTED"),
    editWishDialog: Symbol("NOT_IMPLEMENTED")
});

let eventManager = new Events.EventManager(backendEntryPoint, CFAjaxAuthKey);
let serviceBundle = new Map();

serviceBundle.set("events", eventManager);
serviceBundle.set("eventTypes", Events.EventTypes);
serviceBundle.set("utils", JSUtils);
serviceBundle.set("models", models);

let serviceLocator = new ServiceLocator(serviceBundle);

main.authentication = new AuthenticationManager(backendEntryPoint, CFAjaxAuthKey, serviceLocator);
main.notifications = new NotificationManager(document.getElementById('Notifications'), 2000, serviceLocator);

// Object.freeze(main);
console.log("Everything's initialized and ready to rock and roll");

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

    authentication: {}
}
*/