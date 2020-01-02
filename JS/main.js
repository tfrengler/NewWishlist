/* 
global
    CFAjaxAuthKey
*/
"use strict";

const backendEntryPoint = "CFCs/AjaxProxy.cfc";
const main = Object.create(null);
const services = Object.create(null);

import { Authentication } from "./Authentication.js";
import * as Events from "./EventManager.js";
import { ServiceLocator } from "./ServiceLocator.js";

main.events = new Events.EventManager(backendEntryPoint, CFAjaxAuthKey);

services.events = main.events;
services.eventTypes = Events.EventTypes;

let serviceBundle = new Map();
for(let serviceName in services) serviceBundle.set(serviceName, services[serviceName]);
let serviceLocator = new ServiceLocator(serviceBundle);

main.authentication = new Authentication(backendEntryPoint, CFAjaxAuthKey, serviceLocator);

// Object.freeze(main);

window.main = main;
/*
    image/jpeg
    image/bmp
    image/png
    image/tiff
    image/webp
*/

/*

Authentication: class
Events: namespace
ServiceLocator: class

main: {

    controllers: {
        menuDialog: {
            elements: {}
            loadWishlist()
            logIn()
            logOut()
            onLogIn()
            onLogOut()
            init()
        }

        headersAndFooters: {
            onLoadWishlist()
            onLoggedIn()
            onLoggedOut()
            onEnableEditMode()
            onDisableEditMode()
        }

        notifications: {
            elements: {}
            init()
        }

        wishlist: {
            elements: {}
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
            init()
        }

        editWishDialog: {
            elements: {}
            onSelectPictureForUpload()
            onProvidePictureLink()
            onPictureValidated()
            onPictureNotValidate()
            onSaveChanges()
            onCloseDialog()
            init()
        }
    }

    models: {
        wishlist: {
            wishes: [],
            load(),
            addNewWish(),
            deleteWish(),
        }
        wish: {

            picture: "",
            description: "",
            links: string[]

            changePicture(),
            changeDescription(),
            changeLinks()
        }

        authentication: {
            token: ""
            logIn()
            logOut()
        }
    }

    events: ()
}
*/