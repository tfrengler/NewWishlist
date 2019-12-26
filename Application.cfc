<cfcomponent output="false" >

	<cfset this.name = "Wishlist v4" />
	<cfset this.applicationTimeout = createTimeSpan( 7, 0, 0, 0 ) />
	<cfset this.sessionTimeout = createTimespan(0, 1, 0, 0) />
	<cfset this.sessionType = "JEE" />
	<cfset this.sessionManagement = true />
	<cfset this.sessionStorage = "cookie" />
    <cfset this.setClientCookies = true />

	<cfset this.root = getDirectoryFromPath( getCurrentTemplatePath() ) />

	<cffunction name="onApplicationStart" returnType="boolean" output="true" >

		<cfset application["normalizePath"] = function(required string path) {
			<!--- We do two passes to catch any double-forward slashes that are created in the first pass --->
			arguments.path = reReplace(arguments.path, "/{2,}|\\{1,}", "/", "ALL");
			return reReplace(arguments.path, "/{2,}|\\{1,}", "/", "ALL");
		} />

		<cfset application.mapping = {
            logs: application.normalizePath(path=this.root & "/Logs") 
        } />

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

	<cffunction name="onSessionStart" returnType="void" output="true" >
		<cfdump var="Session-scope started!" />
	</cffunction>

	<cffunction name="onSessionEnd" returnType="void" output="false" >
        <cfargument name="sessionScope" type="struct" required="true" />
        <cfargument name="applicationScope" type="struct" required="true" />

        
    </cffunction>
    
    <cffunction name="onSessionEnd" returnType="void" output="false" >
        <cfargument name="sessionScope" type="struct" required="true" />
        <cfargument name="applicationScope" type="struct" required="true" />
        

	</cffunction>

</cfcomponent>