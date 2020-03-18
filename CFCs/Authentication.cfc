component output="false" accessors="false" persistent="true" modifier="final" {

    property name="security"	type="SecurityManager"	getter="false"	setter="false";
    property name="logger"      type="LogManager"       getter="false"	setter="false";
	property name="users"		type="struct"			getter="true"	setter="false";
	property name="workingDir"	type="string"			getter="false"	setter="false";
	
	public Authentication function init(required SecurityManager securityManager, required string workingDir, LogManager logger) {
		if (NOT directoryExists(arguments.workingDir))
			throw(message="Error initializing Authentication", detail="Directory from argument 'workingDir' does not exist: #arguments.workingDir#");
		
		variables.security = arguments.SecurityManager
        variables.workingDir = arguments.workingDir;
        if (structKeyExists(arguments, "logger")) variables.logger = arguments.logger;
        
        for(var userFile in directoryList(path=variables.workingDir, recurse=false, listInfo="name", filter="*.json", type="file")) {
            try {
                var userData = deserializeJSON(fileRead(variables.workingDir & "/" & userFile));
            }
            catch(error) {
                if (!isNull(variables.logger)) variables.logger.logSimple("Unable to parse user file: #userFile#", "CRITICAL", getFunctionCalledName());
            }

            variables.users[listFirst(userFile, ".")] = new User(data=userData);
        }

		return this;
	}

    // ************ PUBLIC ************
    
    // REMOTE API
	public struct function logIn(required string username, required string password, required struct sessionHandle) {

		if (NOT variables.isUser(arguments.username)) return {STATUS_CODE: 1, DATA: NULL};
		var user = variables.getUserByName(arguments.username);

        if (variables.isLoggedIn(arguments.username, arguments.sessionHandle)) {
            if (!isNull(variables.logger)) variables.logger.logSimple("User already logged in, retrieving session (#user.getDisplayName()# | #user.getSessionID()#)", "INFO", getFunctionCalledName());

			return {STATUS_CODE: 0, DATA: {
                TOKEN: user.getToken(),
                DISPLAY_NAME: user.getDisplayName(),
                USER_ID: user.getId()
            }};
        }

		var passwordCorrect = variables.security.validatePassword(
            plainPassword=arguments.password, 
            salt=user.getSalt(),
            securedPassword=user.getPassword()
        );

		if (NOT passwordCorrect) return {STATUS_CODE: 2, DATA: NULL};

		var token = hash(arguments.sessionHandle.sessionID & createUUID(), "SHA-256");
        user.setToken(token);
        user.setSessionID(arguments.sessionHandle.sessionID);
        arguments.sessionHandle.token = token;

        if (!isNull(variables.logger)) variables.logger.logSimple("User logged in (#user.getDisplayName()# | #user.getSessionID()#)", "INFO", getFunctionCalledName());

		return {STATUS_CODE: 0, DATA: {
            TOKEN: token,
            DISPLAY_NAME: user.getDisplayName(),
            USER_ID: user.getId()
        }};
    };
    // REMOTE API
	public struct function logOut(required string token, required struct sessionHandle) {
		for(var username in variables.users) {
            var currentUser = variables.users[username];

            if (currentUser.getToken() EQ arguments.token AND currentUser.getSessionID() EQ arguments.sessionHandle.sessionID) {

                if (!isNull(variables.logger)) variables.logger.logSimple("User logged out (#currentUser.getDisplayName()# | #currentUser.getSessionID()#)", "INFO", getFunctionCalledName());
                currentUser.setToken("");
                currentUser.setSessionID("");

                return {STATUS_CODE: 0, DATA: NULL};

            }
        }

        return {STATUS_CODE: 1, DATA: NULL};
    };

    public boolean function isValidSession(required string token, required struct sessionHandle) {
		for(var username in variables.users) {
            var currentUser = variables.users[username];

            if (currentUser.getToken() EQ arguments.token AND currentUser.getSessionID() EQ arguments.sessionHandle.sessionID)
                return true;
            
            if (currentUser.getToken() EQ arguments.token AND currentUser.getSessionID() NEQ arguments.sessionHandle.sessionID)
                if (!isNull(variables.logger)) variables.logger.logSimple("User is already logged in, but not at this location (Stored session: #currentUser.getSessionID()# | #arguments.sessionHandle.sessionID#)", "WARNING", getFunctionCalledName());
        }

        return false;
	};

    public User function getUserByToken(required string token) {
        for(var username in variables.users) {
            var currentUser = variables.users[username];

            if (currentUser.getToken() EQ arguments.token)
                return currentUser;
        }

        return new User(data={dummy: true});
    };

    
    public User function getUserByName(required string name) {
        for(var username in variables.users) {
            var currentUser = variables.users[username];

            if (currentUser.getName() EQ arguments.name)
                return currentUser;
        }

        return new User(data={dummy: true});
    };
    
    public User function getUserBySessionID(required string sessionID) {
        for(var username in variables.users) {
            var currentUser = variables.users[username];

            if (currentUser.getSessionID() EQ arguments.sessionID)
                return currentUser;
        }

        return new User(data={dummy: true});
    };
    
    public struct function getAllUsers() {
        return variables.users;
    }
    
    // ************ PRIVATE ************
	private boolean function isLoggedIn(required string username, required struct sessionHandle) {
        var user = variables.getUserByName(arguments.username);
        return len(user.getToken()) GT 0 AND user.getSessionID() EQ arguments.sessionHandle.sessionID;
	};

	private boolean function isUser(required string username) {
        for(var username in variables.users) {
            var currentUser = variables.users[username];

            if (currentUser.getName() EQ arguments.username)
                return true;
        }

        return false;
	};
}