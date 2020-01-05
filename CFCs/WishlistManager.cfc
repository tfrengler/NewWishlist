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

	public struct function saveWish(required numeric id, required struct data, required string token, required struct sessionHandle) {
		var user = variables.authentication.getUserByToken();
		
		if (user.getId() EQ nullValue())
			return {STATUS_CODE: 1};

		if (user.getSessionID() NEQ arguments.sessionHandle.sessionID)
			return {STATUS_CODE: 2};

		if (
			NOT structKeyExists(arguments.data, "description") OR
			NOT structKeyExists(arguments.data, "picture") OR
			NOT structKeyExists(arguments.data, "links")
		)
		return {STATUS_CODE: 3};

		var wishlistDir = "#variables.workingDir#/#user.getId()#";
		var wishlistFilePath = "#wishlistDir#/#arguments.id#";

		try {
			var existingWish = deserializeJSON(fileRead(wishlistFilePath));
		}
		catch(error) {
			// TODO(thomas): Probably need to dump this somewhere for debugging
			return {STATUS_CODE: 4};
		}

		existingWish.description = (len(arguments.data.description) GT 0 ? arguments.data.description : existingWish.description);
		existingWish.picture = (len(arguments.data.picture) GT 0 ? arguments.data.picture : existingWish.picture);
		existingWish.links = (len(arguments.data.links) GT 0 ? arguments.data.links : existingWish.links);

		try {
			fileWrite(wishlistFilePath, serializeJSON(existingWish));
		}
		catch(error) {
			// TODO(thomas): Probably need to dump this somewhere for debugging
			return {STATUS_CODE: 5};
		}

		return {STATUS_CODE: 0};
	}

	public struct function deleteWish(required numeric id, required string token, required struct sessionHandle) {
		var user = variables.authentication.getUserByToken();
		
		if (user.getId() EQ nullValue())
			return {STATUS_CODE: 1};

		if (user.getSessionID() NEQ arguments.sessionHandle.sessionID)
			return {STATUS_CODE: 2};

		var wishlistDir = "#variables.workingDir#/#user.getId()#";
		var wishlistFilePath = "#wishlistDir#/#arguments.id#";

		if (NOT fileExists(wishlistFilePath))
			return {STATUS_CODE: 1};
		
		// fileDelete(wishlistFilePath);
		return {STATUS_CODE: 0};
	}
}