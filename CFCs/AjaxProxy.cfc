<cfcomponent persistent="true" accessors="false" modifier="final" >

	<cfheader name="access-control-allow-credentials" value="false" />
	<cfheader name="access-control-allow-methods" value="GET, HEAD, POST, OPTIONS" />
	<cfheader name="access-control-allow-origin" value="*" />
	<cfheader name="access-control-max-age" value="600" />

	<cffunction name="call" returntype="struct" returnformat="JSON" access="remote" hint="Acts as a interface for frontend Javascript via ajax to call backend CFC methods, passing along argument data as well." >
		<cfargument name="controller" type="string" required="false" default="" hint="The name of the CFC you want to call." />
		<cfargument name="function" type="string" required="false" default="" hint="The name of the CFC you want to call." />
		<cfargument name="parameters" type="string" required="false" default="{}" hint="A structure of key/value pairs of arguments to the method you're calling." />
		<cfargument name="authKey" type="string" required="false" default="<:EMPTY:>" hint="A unique hash key that is checked against an internal validator. This exists to prevent people from using this proxy remotely without authorization." />

		<cfset var returnData = {RESPONSE_CODE: 0, RESPONSE: nullValue()} />
        <cfset var deserializedParameters = {} />

		<cftry>
            <cfset deserializedParameters = deserializeJSON(arguments.parameters) />
            <!--- Include a 'sessionHandle'-key of any value in argument 'parameters' and the current session will be passed to the invoked method --->
            <cfif structKeyExists(deserializedParameters, "sessionHandle") >
                <cfset deserializedParameters["sessionHandle"] = SESSION />
            </cfif>

            <cfcatch>
                <cfif NOT isNull(application.logger)><cfset application.logger.logSimple("Unable to deserialize parameters: #cfcatch.message#", "CRITICAL", "AjaxProxy") /></cfif>
				<cfreturn {RESPONSE_CODE: 1, RESPONSE: nullValue()} />
			</cfcatch>
        </cftry>
        
        <cftry>
            <!--- Include an 'uploadFiles'-key of any value in argument 'parameters' and the files on the form will be uploaded. The result of the upload will be put in uploadFiles-key in the parameters --->
            <cfif structKeyExists(deserializedParameters, "uploadFiles") AND isArray(deserializedParameters.uploadFiles, 1) >
                <cfset var uploadedFiles = {} />

                <cfloop array=#deserializedParameters.uploadFiles# index="currentFormFileField" >
                    <cfset uploadedFiles[currentFormFileField] = fileUpload(
                        destination=application.mapping.tempFiles,
                        filefield=currentFormFileField,
                        nameConflict="makeunique"
                    ) />
                </cfloop>

                <cfset deserializedParameters.uploadFiles = uploadedFiles />
            </cfif>

            <cfcatch>
                <cfif NOT isNull(application.logger)><cfset application.logger.logSimple("Unable to upload files: #cfcatch.message#", "CRITICAL", "AjaxProxy") /></cfif>
                <cfreturn {RESPONSE_CODE: 2, RESPONSE: nullValue()} />
            </cfcatch>
        </cftry>

        <cfif len(arguments.controller) IS 0 >
            <cfif NOT isNull(application.logger)><cfset application.logger.logSimple("No controller defined in arguments (empty string)", "CRITICAL", "AjaxProxy") /></cfif>            
			<cfreturn {RESPONSE_CODE: 3, RESPONSE: nullValue()} />
		</cfif>

        <cfif len(arguments.function) IS 0 >
            <cfif NOT isNull(application.logger)><cfset application.logger.logSimple("No function defined in arguments (empty string)", "CRITICAL", "AjaxProxy") /></cfif>            
			<cfreturn {RESPONSE_CODE: 4, RESPONSE: nullValue()} />
		</cfif>

        <cfif   NOT structKeyExists(session, "ajaxAuthKey")
                OR (structKeyExists(session, "ajaxAuthKey") AND session.ajaxAuthKey IS NOT arguments.authKey) >

            <cfif NOT isNull(application.logger)><cfset application.logger.logSimple("No auth key in response or auth key not valid. See complex log for details.", "CRITICAL", "AjaxProxy") /></cfif>
            <cfif NOT isNull(application.logger)><cfset application.logger.logComplex(arguments, "CRITICAL", "AjaxProxy") /></cfif>
			<cfreturn {RESPONSE_CODE: 5, RESPONSE: nullValue()} />
		</cfif>

		<!--- The following 2 checks need to be coupled with a struct called allowedAJAXControllers in the application scope, where each index is the name of a CFC, and each key is an array of method names --->
        <cfif NOT structKeyExists(application.allowedAJAXControllers, arguments.controller) >
            <cfif NOT isNull(application.logger)><cfset application.logger.logSimple("Controller is not on the allowed-list: #arguments.controller#", "CRITICAL", "AjaxProxy") /></cfif>
			<cfreturn {RESPONSE_CODE: 6, RESPONSE: nullValue()} />
		</cfif>

        <cfif NOT arrayFind(application.allowedAJAXControllers[arguments.controller], arguments.function) >
            <cfif NOT isNull(application.logger)><cfset application.logger.logSimple("Controller method not on the allowed-list: #arguments.function#", "CRITICAL", "AjaxProxy") /></cfif>
			<cfreturn {RESPONSE_CODE: 7, RESPONSE: nullValue()} />
		</cfif>
		
        <cftry>
            <!--- If your controllers live somewhere else change this line to reflect that --->
            <!--- Whatever is returned by the invoked method is expected to be able to be serialized --->
            <cfset var controllerResponse = invoke(application[arguments.controller], arguments.function, deserializedParameters) />
			
            <!--- If the invoked method is void... --->
            <cfif NOT isDefined("controllerResponse") OR isNull(controllerResponse) >
				<cfreturn returnData />
            </cfif>
            
            <cfif NOT isSimpleValue(controllerResponse) >
                <cfset serializeJSON(controllerResponse) />
            </cfif>

            <cfcatch>
                <!--- Error upon invoking the method or serializing the response. Put some sort of logging in here for the catch if you want to know what's going on --->
                <cfif NOT isNull(application.logger)><cfset application.logger.logSimple("Error calling the controller, see complex log for more detail", "CRITICAL", "AjaxProxy") /></cfif>
                <cfif NOT isNull(application.logger)><cfset application.logger.logComplex(cfcatch, "CRITICAL", "AjaxProxy") /></cfif>
				<cfreturn {RESPONSE_CODE: 8, RESPONSE: nullValue()} />
			</cfcatch>
		</cftry>

        <cfif isStruct(controllerResponse) >
            <cfset returnData["RESPONSE"] = controllerResponse />
            <cfreturn returnData />
        </cfif>
        
        <cfif NOT isNull(application.logger)><cfset application.logger.logSimple("Controller did not return a struct as expected (#arguments.controller#.#arguments.function#)", "CRITICAL", "AjaxProxy") /></cfif>
        <cfreturn {RESPONSE_CODE: 9, RESPONSE: nullValue()} />
	</cffunction>

</cfcomponent>