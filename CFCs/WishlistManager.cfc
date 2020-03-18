component output="false" accessors="false" persistent="true" modifier="final" {

    property name="logger"              type="LogManager"       getter="false"	setter="false";
	property name="security"			type="SecurityManager"	getter="false"	setter="false";
	property name="authentication"		type="Authentication"	getter="false"	setter="false";
	property name="workingDir"			type="string"			getter="false"	setter="false";

	public WishlistManager function init(required SecurityManager securityManager, required Authentication authenticationManager, required string workingDir, LogManager logger) {
		if (NOT directoryExists(arguments.workingDir))
			throw(message="Error initializing WishlistManager", detail="Directory from argument 'workingDir' does not exist: #arguments.workingDir#");

		variables.authentication = arguments.authenticationManager;
		variables.security = arguments.SecurityManager
        variables.workingDir = arguments.workingDir;
        if (structKeyExists(arguments, "logger")) variables.logger = arguments.logger;

		return this;
	}

    // ************ PUBLIC ************
    // REMOTE API
	public struct function getWishes(required string userID) {
		var wishlistDir = "#variables.workingDir#/#arguments.userID#";

		if (NOT directoryExists("#variables.workingDir#/#arguments.userID#"))
			return {STATUS_CODE: 1, DATA: NULL};

		var returnData = {STATUS_CODE: 0, DATA: {}};
		var wishContents = {};

		for(var wishFile in directoryList(path=wishlistDir, recurse=false, listInfo="name", filter="*.json", type="file")) {
			try {
				wishContents = deserializeJSON( fileRead("#wishlistDir#/#wishFile#") );
				returnData.DATA[wishContents.id] = wishContents;
			}
			catch(error) {
                if (!isNull(variables.logger)) variables.logger.logSimple("Unable to parse wish file #wishFile# for user #arguments.userID#", "CRITICAL", getFunctionCalledName());
			}
		}

		return returnData;
    }
    // REMOTE API
    public struct function addWish(required struct data, required string token, required struct sessionHandle) {
        if (!variables.authentication.isValidSession(arguments.token, arguments.sessionHandle))
			return {STATUS_CODE: 1, DATA: NULL};

		if (
			NOT structKeyExists(arguments.data, "description") OR
			NOT structKeyExists(arguments.data, "picture") OR
			NOT structKeyExists(arguments.data, "links")
		)
		return {STATUS_CODE: 2, DATA: NULL};

        var user = variables.authentication.getUserByToken(token=arguments.token);
        var wishlistDir = "#variables.workingDir#/#user.getId()#";
        var wishlistFilePath = "#wishlistDir#/#createUUID()#.json";
        var regexPattern = createObject("java", "java.util.regex.Pattern").compile('"id":\s*(\d+),');
        var wishIDs = [];
        var newWishID = 0;
        var matcher = {};

        for(var wishFile in directoryList(path=wishlistDir, recurse=false, listInfo="name", filter="*.json", type="file")) {

            wishContents = fileRead("#wishlistDir#/#wishFile#");
            matcher = regexPattern.matcher(wishContents);
            matcher.find();
            arrayAppend(wishIDs, val(matcher.group(1)));
        }

        newWishID = arrayMax(wishIDs) + 1;
        if (newWishID EQ 0)
            return {STATUS_CODE: 3, DATA: NULL}

        try {
            fileWrite(wishlistFilePath, serializeJSON({
                id: newWishID,
                description: arguments.data.description,
                picture: arguments.data.picture,
                links: arguments.data.links
            }));
        }
        catch(error) {
            if (!isNull(variables.logger)) variables.logger.logSimple("Unable to add new wish, see complex log for details", "CRITICAL", getFunctionCalledName());
            if (!isNull(variables.logger)) variables.logger.logComplex({ARGUMENTS: arguments, CATCH: cfcatch}, "CRITICAL", getFunctionCalledName());
            return {STATUS_CODE: 4, DATA: NULL}
        }

        return {STATUS_CODE: 0, DATA: {WISH_ID: newWishID}};
    }
    // REMOTE API
	public struct function saveWish(required numeric id, required struct data, required string token, required struct sessionHandle) {
		if (!variables.authentication.isValidSession(arguments.token, arguments.sessionHandle)) {
            if (!isNull(variables.logger)) variables.logger.logSimple("Unable to save wish (#arguments.id#), user not authenticated: #token#", "CRITICAL", getFunctionCalledName());
            return {STATUS_CODE: 1, DATA: NULL};
        }

		if (
			NOT structKeyExists(arguments.data, "description") OR
			NOT structKeyExists(arguments.data, "picture") OR
			NOT structKeyExists(arguments.data, "links")
		) {
            if (!isNull(variables.logger)) variables.logger.logSimple("Unable to save wish. Argument 'data' is missing description, picture or links. See complex log for details", "CRITICAL", getFunctionCalledName());
            if (!isNull(variables.logger)) variables.logger.logComplex(arguments, "CRITICAL", getFunctionCalledName());
            return {STATUS_CODE: 2, DATA: NULL};
        }

        var user = variables.authentication.getUserByToken(token=arguments.token);
        var wishlistDir = "#variables.workingDir#/#user.getId()#";
        var wishlistFilePath = "";
        var existingWishFile = variables.getExistingWish(arguments.id, user.getId());

		if (len(existingWishFile) GT 0) {
            wishlistFilePath = "#wishlistDir#/#existingWishFile#";
            try {
                fileDelete(wishlistFilePath);
            }
            catch(error) {
                if (!isNull(variables.logger)) variables.logger.logSimple("Unable to save wish, could not delete existing wish (#wishlistFilePath#): #cfcatch.message#", "CRITICAL", getFunctionCalledName());
                return {STATUS_CODE: 3, DATA: NULL};
            }
        }
        else {
            if (!isNull(variables.logger)) variables.logger.logSimple("Unable to save wish, could not find existing wish file: #wishlistFilePath#", "CRITICAL", getFunctionCalledName());
            return {STATUS_CODE: 4, DATA: NULL};
        }

        try {
            fileWrite(wishlistFilePath, serializeJSON({
                id: arguments.id,
                description: arguments.data.description,
                picture: arguments.data.picture,
                links: arguments.data.links
            }));
        }
        catch(error) {
            if (!isNull(variables.logger)) variables.logger.logSimple("Unable to save wish (#wishlistFilePath#), see complex log for details", "CRITICAL", getFunctionCalledName());
            if (!isNull(variables.logger)) variables.logger.logComplex({ARGUMENTS: arguments, CATCH: cfcatch}, "CRITICAL", getFunctionCalledName());
            return {STATUS_CODE: 5, DATA: NULL};
        }

		return {STATUS_CODE: 0, DATA: NULL};
	}
    // REMOTE API
	public struct function deleteWish(required numeric id, required string token, required struct sessionHandle) {
		if (!variables.authentication.isValidSession(arguments.token, arguments.sessionHandle)) {
            if (!isNull(variables.logger)) variables.logger.logSimple("Unable to delete wish (#arguments.id#), user not authenticated: #arguments.token#", "CRITICAL", getFunctionCalledName());
            return {STATUS_CODE: 1, DATA: NULL};
        }

        var user = variables.authentication.getUserByToken(token=arguments.token);
        var existingWishFile = variables.getExistingWish(arguments.id, user.getId());
		var wishlistDir = "#variables.workingDir#/#user.getId()#";
		var wishlistFilePath = "#wishlistDir#/#existingWishFile#";

		if (NOT fileExists(wishlistFilePath)) {
            if (!isNull(variables.logger)) variables.logger.logSimple("Unable to delete wish, as file does not exist: #wishlistFilePath#", "CRITICAL", getFunctionCalledName());
            return {STATUS_CODE: 2, DATA: NULL};
        }

        try {
            fileDelete(wishlistFilePath);
        }
        catch(error) {
            if (!isNull(variables.logger)) variables.logger.logSimple("Unable to delete wish (#wishlistFilePath#), see complex log for details", "CRITICAL", getFunctionCalledName());
            if (!isNull(variables.logger)) variables.logger.logComplex({ARGUMENTS: arguments, CATCH: cfcatch}, "CRITICAL", getFunctionCalledName());
            return {STATUS_CODE: 3, DATA: NULL};
        }

		return {STATUS_CODE: 0, DATA: NULL};
    }
    
    // ************ PRIVATE ************
    private string function getExistingWish(required numeric id, required string userID) {
        var wishlistDir = "#variables.workingDir#/#arguments.userID#";

        for(var wishFile in directoryList(path=wishlistDir, recurse=false, listInfo="name", filter="*.json", type="file")) {

            wishContents = fileRead("#wishlistDir#/#wishFile#");
            if (arrayLen(reMatch('"id":\s*#id#,', wishContents)) GT 0)
                return wishFile;
        }

        return "";
    }
}