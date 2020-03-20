<cfcomponent output="false" >

	<cfset this.name = "NewWishlist" />
	<cfset this.applicationTimeout = createTimeSpan( 7, 0, 0, 0 ) />
	<cfset this.sessionTimeout = createTimespan(0, 1, 0, 0) />
	<cfset this.sessionType = "JEE" />
	<cfset this.sessionManagement = true />
    <cfset this.sessionStorage = "cookie" />
    <!--- We will exclusively be using the JSESSIONID as client identifier --->
    <cfset this.setClientCookies = false />

	<cfset this.root = getDirectoryFromPath( getCurrentTemplatePath() ) />

    <cffunction name="onApplicationStart" returnType="boolean" output="true" >

        <cfset application.nonce = "" />

		<cfset application["normalizePath"] = function(required string path) {
			<!--- We do two passes to catch any double-forward slashes that are created in the first pass --->
			arguments.path = reReplace(arguments.path, "/{2,}|\\{1,}", "/", "ALL");
			return reReplace(arguments.path, "/{2,}|\\{1,}", "/", "ALL");
        } />

        <cfset var configFileLocation = this.root & "config.json" />

        <cfif NOT fileExists(configFileLocation) >
            <cfthrow message="Error initializing application" detail="Config-file does not exist" />
        </cfif>

        <cfset var config = deserializeJSON(fileRead(configFileLocation)) />

		<cfset application.mapping = {
            logs: application.normalizePath(path=this.root & config.logFolder),
            userData: application.normalizePath(path=this.root & config.userDataFolder),
            wishlistData: application.normalizePath(path=this.root & config.wishlistDataFolder)
        } />

        <cfset var mapping = "" />
        <cfloop collection=#application.mapping# item="mapping" >
            <cfif NOT directoryExists(application.mapping[mapping]) >
                <cfthrow message="Error initializing application" detail="Mapped folder does not exist: #application.mapping[mapping]#" />
            </cfif>
        </cfloop>

        <cfset application.allowedAJAXControllers = {
            "authentication": ["logIn", "logOut"],
            "wishlists": ["getWishes","saveWish","addWish","deleteWish"]
        } />

        <cfset application.logger = new CFCs.LogManager(application.mapping.logs) />
        <cfset application.security = new CFCs.SecurityManager() />
        <cfset application.authentication = new CFCs.Authentication(application.security, application.mapping.userData, application.logger) />
        <cfset application.wishlists = new CFCs.WishlistManager(application.security, application.authentication, application.mapping.wishlistData) />

        <cfset application.logger.logSimple("Application started", "INFO", "Application.cfc") />
		<cfreturn true />
	</cffunction>

	<cffunction name="onRequestStart" returnType="boolean" output="true" >
        <cfargument type="string" name="targetPage" required="true" />

		<cfif structKeyExists(URL, "Restart") >
			<cfset applicationStop() />
			<cfset sessionInvalidate() />
			<cflocation url=#CGI.SCRIPT_NAME# addtoken="false" />
        </cfif>

        <cfif find("index.cfm", arguments.targetPage) GT 0 >
            <cfset application.nonce = application.security.getNonce() />

            <cfif (structKeyExists(URL, "DevMode") AND URL.DevMode EQ false) OR NOT structKeyExists(URL, "DevMode") >
                <cfheader name="Content-Security-Policy" value=#application.security.getCSPPolicy(includeNonce=application.nonce)# />
            </cfif>
        </cfif>

		<cfreturn true />
	</cffunction>

	<!--- <cffunction name="onSessionStart" returnType="void" output="false" >
        <cfset application.logger.logSimple("New session started: #session.sessionID#", "INFO", "Application.cfc") />
	</cffunction> --->

	<cffunction name="onSessionEnd" returnType="void" output="false" >
        <cfargument name="sessionScope" type="struct" required="true" />
        <cfargument name="applicationScope" type="struct" required="true" />

        <cfset arguments.applicationScope.logger.logSimple("Session timed out: #sessionScope.sessionID#", "INFO", "Application.cfc") />
        
        <cfif structKeyExists(arguments.sessionScope, "token") >
            <cfset arguments.applicationScope.authentication.logOut(arguments.sessionScope.token) />
        </cfif>
    </cffunction>

    <cffunction name="onApplicationEnd" returnType="void">
        <cfargument name="applicationScope" required=true/>

        <cfset arguments.applicationScope.logger.logSimple("Application shutting down", "WARNING", "Application.cfc") />
        <cfset arguments.applicationScope.logger.dispose() />
    </cffunction>

</cfcomponent>