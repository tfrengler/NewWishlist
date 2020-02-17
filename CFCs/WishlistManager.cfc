component output="false" accessors="false" persistent="true" modifier="final" {

	property name="security"			type="SecurityManager"	getter="false"	setter="false";
	property name="authentication"		type="Authentication"	getter="false"	setter="false";
	property name="workingDir"			type="string"			getter="false"	setter="false";
	
	public WishlistManager function init(required SecurityManager securityManager, required Authentication authenticationManager, required string workingDir) {
		if (NOT directoryExists(arguments.workingDir))
			throw(message="Error initializing WishlistManager", detail="Directory from argument 'workingDir' does not exist: #arguments.workingDir#");
		
		variables.authentication = arguments.authenticationManager;
		variables.security = arguments.SecurityManager
		variables.workingDir = arguments.workingDir;

		return this;
	}

	// PUBLIC
	public struct function getWishes(required string userID) {
		var wishlistDir = "#variables.workingDir#/#arguments.userID#";

		if (NOT directoryExists("#variables.workingDir#/#arguments.userID#"))
			return {STATUS_CODE: 1};

		var returnData = {STATUS_CODE: 0, DATA: {}};
		var wishContents = {};

		for(var wishFile in directoryList(path=wishlistDir, recurse=false, listInfo="name", filter="*.json", type="file")) {
			try {
				wishContents = deserializeJSON( fileRead("#wishlistDir#/#wishFile#") );
				returnData.DATA[wishContents.id] = wishContents;
			}
			catch(error) {
				// TODO(thomas): Probably need to dump this somewhere for debugging
			}
		}

		return returnData;
    }
    
    private string function getExistingWish(required numeric id, required string userID) {
        var wishlistDir = "#variables.workingDir#/#arguments.userID#";

        for(var wishFile in directoryList(path=wishlistDir, recurse=false, listInfo="name", filter="*.json", type="file")) {

            wishContents = fileRead("#wishlistDir#/#wishFile#");
            if (arrayLen(reMatch('"id":\s*#id#,', wishContents)) GT 0)
                return wishFile;
        }

        return "";
    }

    public struct function addWish(required struct data, required string token, required struct sessionHandle) {
        if (!variables.authentication.isValidSession(arguments.token, arguments.sessionHandle))
			return {STATUS_CODE: 1};

		if (
			NOT structKeyExists(arguments.data, "description") OR
			NOT structKeyExists(arguments.data, "picture") OR
			NOT structKeyExists(arguments.data, "links")
		)
		return {STATUS_CODE: 2};

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
            return {STATUS_CODE: 3} 
        
        try {
            fileWrite(wishlistFilePath, serializeJSON({
                id: newWishID,
                description: arguments.data.description,
                picture: arguments.data.picture,
                links: arguments.data.links
            }));
        }
        catch(error) {
            // TODO(thomas): Dump somewhere?
            return {STATUS_CODE: 4}
        }

        return {STATUS_CODE: 0, WISH_ID: newWishID};
    }

	public struct function saveWish(required numeric id, required struct data, required string token, required struct sessionHandle) {
		if (!variables.authentication.isValidSession(arguments.token, arguments.sessionHandle))
			return {STATUS_CODE: 1};

		if (
			NOT structKeyExists(arguments.data, "description") OR
			NOT structKeyExists(arguments.data, "picture") OR
			NOT structKeyExists(arguments.data, "links")
		)
		return {STATUS_CODE: 2};

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
                // TODO(thomas): Dump somewhere?
                return {STATUS_CODE: 3}
            }
        }
        else
            return {STATUS_CODE: 4}

        try {
            fileWrite(wishlistFilePath, serializeJSON({
                id: arguments.id,
                description: arguments.data.description,
                picture: arguments.data.picture,
                links: arguments.data.links
            }));
        }
        catch(error) {
            // TODO(thomas): Dump somewhere?
            return {STATUS_CODE: 5}
        }

		return {STATUS_CODE: 0};
	}

	public struct function deleteWish(required numeric id, required string token, required struct sessionHandle) {
		if (!variables.authentication.isValidSession(arguments.token, arguments.sessionHandle))
			return {STATUS_CODE: 1};

		var wishlistDir = "#variables.workingDir#/#user.getId()#";
		var wishlistFilePath = "#wishlistDir#/#arguments.id#";

		if (NOT fileExists(wishlistFilePath))
			return {STATUS_CODE: 2};
		
		// fileDelete(wishlistFilePath);
		return {STATUS_CODE: 0};
	}
}