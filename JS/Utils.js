"use strict";

const JSUtils = Object.create(null);

JSUtils.deepFreeze = function(object) {
	var propNames = Object.getOwnPropertyNames(object);

	// Freeze properties before freezing self
	for (const name of propNames) {
		let value = object[name];
		typeof value === typeof {} ? this.deepFreeze(value) : value;
	}

	return Object.freeze(object);
};

JSUtils.XORDecode = function(encodedString, mask, separator='|') {
	let unmaskedCharCode = 0;
	const inputString = encodedString.split(separator);
	const decoded = [];

	for (let index = 0; index < inputString.length; index++) {
		unmaskedCharCode = parseInt(inputString[index], 16) ^ mask.charCodeAt(index % mask.length);
		decoded.push(String.fromCharCode(unmaskedCharCode));
	}

	return decoded.join('');
};

JSUtils.XOREncode = function(rawString, mask, separator='|') {
    const encoded = [];
    let charCodeMasked;
    let hexedChar;
    
    for (let index = 0; index < rawString.length; index++) {
        charCodeMasked = rawString.charCodeAt(index) ^ mask.charCodeAt(index % mask.length);
        hexedChar = charCodeMasked.toString(16);

        encoded.push(hexedChar);
        encoded.push(separator);
    }

    encoded.pop();
    return encoded.join('');
};

JSUtils.escapeString = function(stringValue) {
    if (stringValue && stringValue.replace)
        return stringValue.replace(/(["'])/g,'\\$1');
};

JSUtils.htmlEscapeString = function(stringValue) {
    return String(stringValue).replace(/'/g, '&apos;').replace(/"/g, '&quot;');
};

JSUtils.htmlUnescapeString = function(stringValue) {
    return String(stringValue).replace(/&apos;/g, "'").replace(/&quot;/g, '"');
};

JSUtils.deepClone = function(object) {
    return JSON.parse(JSON.stringify(object))
};

// NOTE: Is not able to display hours. Anything above 59 minutes will be shown as minutes
JSUtils.getReadableTime = function(time) {
    time = Math.round(time);
    const minutes = (time / 60 > 0 ? parseInt(time / 60) : 0);
    const seconds = (time >= 60 ? time % 60 : time);
    return `${minutes > 9 ? minutes : "0" + minutes}:${seconds > 9 ? seconds : "0" + seconds}`;
};

JSUtils.getReadableBytes = function(bytes) {
    const i = Math.floor(Math.log(bytes) / Math.log(1024)),
    sizes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    return (bytes / Math.pow(1024, i)).toFixed(2) * 1 + ' ' + sizes[i];
};

// NOTE: Modifies the original array, so make sure you don't pass a frozen/immutable array
JSUtils.shuffleArray = function(array) {
    for (let i = array.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [array[i], array[j]] = [array[j], array[i]];
    }
};

JSUtils.wait = async function(ms) {
    return new Promise((resolve)=> setTimeout(resolve, parseFloat(ms) || 1000));
};

JSUtils.fetchWithTimeout = function(url, timeout, requestOptions=0) {

    return new Promise( (resolve, reject) => {

        const abortController = new AbortController();
        if (typeof requestOptions === typeof {})
            requestOptions.signal = abortController.signal;
        else
            requestOptions = {signal: abortController.signal};

        let timer = setTimeout(
            () => {
                abortController.abort();
                reject( new Error(`Request timed out (${timeout} ms)`) )
            },
            timeout
        );

        fetch(new Request(url, requestOptions)).then(
            response => resolve( response ),
            error => reject( error )
        ).finally( () => clearTimeout(timer) );
    })
};

Object.freeze(JSUtils);