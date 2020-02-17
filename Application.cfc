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

		<cfset application["normalizePath"] = function(required string path) {
			<!--- We do two passes to catch any double-forward slashes that are created in the first pass --->
			arguments.path = reReplace(arguments.path, "/{2,}|\\{1,}", "/", "ALL");
			return reReplace(arguments.path, "/{2,}|\\{1,}", "/", "ALL");
        } />

        <cfset var configFileLocation = this.root & "config.json" />

        <cfif NOT fileExists(configFileLocation) >
            <cfthrow message="Error initializing application" detail="Config-file does not exist: #configFileLocation#" />
        </cfif>
        <cfset var config = deserializeJSON(fileRead(configFileLocation)) />

		<cfset application.mapping = {
            logs: application.normalizePath(path=this.root & config.logFolder),
            userData: application.normalizePath(path=this.root & config.userDataFolder),
            wishlistData: application.normalizePath(path=this.root & config.wishlistDataFolder),
            tempFiles: application.normalizePath(path=this.root & config.tempFiles)
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

        <cfset application.security = new CFCs.SecurityManager() />
        <cfset application.authentication = new CFCs.Authentication(application.security, application.mapping.userData) />
        <cfset application.wishlists = new CFCs.WishlistManager(application.security, application.authentication, application.mapping.wishlistData) />

		<cfreturn true />
	</cffunction>

	<cffunction name="onRequestStart" returnType="boolean" output="false" >
		<cfargument type="string" name="targetPage" required="true" />

		<cfif structKeyExists(URL, "Restart") >
			<cfset applicationStop() />
			<cfset sessionInvalidate() />
			<cflocation url=#CGI.SCRIPT_NAME# addtoken="false" />
		</cfif>

		<cfreturn true />
	</cffunction>

	<cffunction name="onSessionStart" returnType="void" output="false" >
		<!--- <cfdump var="Session-scope started!" /> --->
	</cffunction>

	<cffunction name="onSessionEnd" returnType="void" output="false" >
        <cfargument name="sessionScope" type="struct" required="true" />
        <cfargument name="applicationScope" type="struct" required="true" />

        <cfif structKeyExists(arguments.sessionScope, "token") >
            <cfset application.authentication.logOut(arguments.sessionScope.token) />
        </cfif>
    </cffunction>

</cfcomponent>