component output="false" accessors="false" persistent="true" modifier="final" {

	property name="security"	type="SecurityManager"	getter="false"	setter="false";
	property name="users"		type="struct"			getter="true"	setter="false";
	property name="workingDir"	type="string"			getter="false"	setter="false";
	
	public Authentication function init(required SecurityManager securityManager, required string workingDir) {
		if (NOT directoryExists(arguments.workingDir))
			throw(message="Error initializing Authentication", detail="Directory from argument 'workingDir' does not exist: #arguments.workingDir#");
		
		variables.security = arguments.SecurityManager
        variables.workingDir = arguments.workingDir;
        
        for(var userFile in directoryList(path=variables.workingDir, recurse=false, listInfo="name", filter="*.json", type="file"))
            variables.users[listFirst(userFile, ".")] = new User(data=deserializeJSON(fileRead(variables.workingDir & "/" & userFile)))

		return this;
	}

	// PUBLIC
	public struct function logIn(required string username, required string password, required struct sessionHandle) {

		if (NOT variables.isUser(arguments.username)) return {STATUS_CODE: 1};
		var user = variables.getUserByName(arguments.username);

		if (variables.isLoggedIn(arguments.username, arguments.sessionHandle))
			return {STATUS_CODE: 0, DATA: {
                TOKEN: user.getToken(),
                DISPLAY_NAME: user.getDisplayName()
            }};

		var passwordCorrect = variables.security.validatePassword(
            plainPassword=arguments.password, 
            salt=user.getSalt(),
            securedPassword=user.getPassword()
        );

		if (NOT passwordCorrect) return {STATUS_CODE: 2};

		var token = hash(arguments.sessionHandle.sessionID & createUUID(), "SHA-256");
        user.setToken(token);
        user.setSessionID(arguments.sessionHandle.sessionID);
        arguments.sessionHandle.token = token;

		return {STATUS_CODE: 0, DATA: {
            TOKEN: token,
            DISPLAY_NAME: user.getDisplayName()
        }};
    };
    
    public boolean function isValidSession(required string token, required struct sessionHandle) {
		for(var username in variables.users) {
            var currentUser = variables.users[username];

            if (currentUser.getToken() EQ arguments.token AND currentUser.getSessionID() EQ arguments.sessionHandle.sessionID)
                return true;
            
            // if (currentUser.getToken() EQ arguments.token AND currentUser.getSessionID() NEQ arguments.sessionHandle.sessionID)
                // TODO(thomas): User is already logged in, but not at this location (session). Log to somewhere?
        }

        return false;
	};

	public struct function logOut(required string token, required struct sessionHandle) {
		for(var username in variables.users) {
            var currentUser = variables.users[username];

            if (currentUser.getToken() EQ arguments.token AND currentUser.getSessionID() EQ arguments.sessionHandle.sessionID) {

                currentUser.setToken("");
                currentUser.setSessionID("");
                return {STATUS_CODE: 0, DATA: null};

            }
        }

        return {STATUS_CODE: 1, DATA: null};
    };

    public User function getUserByName(required string name) {
        for(var username in variables.users) {
            var currentUser = variables.users[username];

            if (currentUser.getName() EQ arguments.name)
                return currentUser;
        }

        return new User(data={dummy: true});
    };
    
    public User function getUserByToken(required string token) {
        for(var username in variables.users) {
            var currentUser = variables.users[username];

            if (currentUser.getToken() EQ arguments.token)
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
    
    // PRIVATE
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