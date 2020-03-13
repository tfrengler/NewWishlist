<cfcomponent modifier="final" hint="Utility component, used for common security related tasks. Note that a secretKey is generated upon instantiation which is used for the authKey as well as encryption/decryption during the instance's lifetime" >

    <!--- PROPERTIES --->
    <cfset variables.encoding = "UTF-8" />
    <cfset variables.cipherStrength = 128 />
	<cfset variables.characterInterface = createObject("java", "java.lang.Character") />
	<cfset variables.XORCharDelimiter = "|" />
    <cfset variables.validChecksumAlgorithms = ["MD2","MD5","SHA-1","SHA-256","SHA-384","SHA-512"] />
    <cfset variables.defaultHashAlgorithm = validChecksumAlgorithms[6] />
    <cfset variables.secretKey = generateSecretKey("AES", variables.cipherStrength) />
    <cfset variables.messageDigestInstance = {} />

	<!--- PUBLIC --->
	<cffunction name="getXOREncodedString" returntype="string" access="public" >
		<cfargument name="mask" type="string" required="true" hint="A string of exactly 24 characters" />
		<cfargument name="stringToEncode" type="string" required="true" hint="The value you wish to encode" />

		<cfif len(arguments.stringToEncode) IS 0 >
			<cfreturn "" />
		</cfif>

		<cfif len(arguments.mask) IS NOT len(arguments.stringToEncode) >
			<cfthrow message="Error generating XOR encoded string" detail="Argument 'mask' and 'stringToEncode' must be the same length" />
		</cfif>

		<cfset var currentIndex = 0 />
		<cfset var charCode = 0 />
		<cfset var maskKeyToUse = 0 />
		<cfset var maskKeyCode = 0 />
		<cfset var charCodeMasked = 0 />
		<cfset var hexedChar = "" />
		<cfset var returnData = [] />

		<cfloop from="0" to=#len(arguments.stringToEncode)-1# index="currentIndex" >

			<cfset charCode = variables.characterInterface.codePointAt(stringToEncode, currentIndex) />
			<cfset maskKeyToUse = currentIndex mod len(arguments.mask) />
			<cfset maskKeyCode = variables.characterInterface.codePointAt(arguments.mask, maskKeyToUse) />
			<cfset charCodeMasked = bitXor(charCode, maskKeyCode) />
			<cfset hexedChar = formatBaseN(charCodeMasked, 16) />

			<cfset arrayAppend(returnData, hexedChar) />
			<cfset arrayAppend(returnData, variables.XORCharDelimiter) />

		</cfloop>

		<cfset returnData = arrayToList(returnData, "") />
		<cfreturn left(returnData, len(returnData)-1) />
	</cffunction>

	<cffunction name="getXORDecodedString" returntype="string" access="public" >
		<cfargument name="mask" type="string" required="true" hint="The masking key used to encode the string" />
		<cfargument name="stringToDecode" type="string" required="true" hint="The value you wish to decode" />

		<cfif len(arguments.stringToDecode) IS 0 OR len(arguments.mask) IS 0 >
			<cfreturn arguments.stringToDecode />
		</cfif>

		<cfset var maskKeyToUse = 0 />
		<cfset var maskKeyCode = 0 />
		<cfset var maskedCharCode = 0 />
		<cfset var unmaskedCharCode = 0 />
		<cfset var char = "" />
		<cfset var index = 0 />
		<cfset var decoded = [] />

		<cfloop from="0" to=#listLen(arguments.stringToDecode, variables.XORCharDelimiter)-1# index="index" >

			<cfset maskKeyToUse = index mod len(arguments.mask) />
			<cfset maskKeyCode = variables.characterInterface.codePointAt(arguments.mask, maskKeyToUse) />
			<cfset maskedCharCode = inputBaseN(listGetAt(arguments.stringToDecode, index+1, variables.XORCharDelimiter), 16) />
			<cfset unmaskedCharCode = bitXor(maskedCharCode, maskKeyCode) />

			<cfset char = variables.characterInterface.toChars(unmaskedCharCode) />

			<cfset arrayAppend(decoded, char) />
		</cfloop>

		<cfreturn arrayToList(decoded, "") />
	</cffunction>

	<cffunction name="createChecksum" returntype="string" access="public" >
		<cfargument name="filePath" type="string" required="false" default="" hint="The absolute path and name of a file you want to create a checksum for. Takes precedence over 'stringContent'" />
		<cfargument name="stringContent" type="string" required="false" default="" hint="The string content you want to create a checksum from" />
		<cfargument name="algorithm" type="string" required="false" default=#variables.validChecksumAlgorithms[5]# hint="Algorithm to use. By default SHA-384 is used" />

		<cfif arrayFind(variables.validChecksumAlgorithms, arguments.algorithm) IS 0 >
			<cfthrow message="Unable to generate checksum" detail="The algorithm you passed is invalid (#arguments.algorithm#). Valid algorithms are: #arrayToList(variables.validChecksumAlgorithms)#" />
		</cfif>

		<cfif NOT isInstanceOf(variables.messageDigestInstance, "java.security.MessageDigest") >
			<cfset variables.messageDigestInstance = createObject("java", "java.security.MessageDigest").getInstance(arguments.algorithm) />
		<cfelseif variables.messageDigestInstance.getAlgorithm() IS NOT arguments.algorithm >
			<cfset variables.messageDigestInstance = createObject("java", "java.security.MessageDigest").getInstance(arguments.algorithm) />
		</cfif>

		<cfif len(arguments.filePath) GT 0 AND fileExists(arguments.filePath) >
			<cfset arguments.stringContent = fileRead(arguments.filePath, variables.encoding) />
		<cfelseif len(arguments.stringContent) IS 0 >
			<cfreturn "STRING_IS_EMPTY" />
		</cfif>

		<cfreturn toBase64(variables.messageDigestInstance.digest(arguments.stringContent.getBytes()), variables.encoding) />
	</cffunction>

	<cffunction name="getCSPPolicy" returntype="string" access="public" hint="Generates a CSP policy for use with 'Content-Security-Policy'-http headers" >
		<cfargument name="includeNonce" type="string" required="false" default="" />

		<cfset var CSPPolicy = "" />

		<cfoutput>
		<cfsilent>
			<cfsavecontent variable="CSPPolicy">
				default-src 'self';
				frame-src data: 'self';
				font-src 'self';
				img-src https: data: 'self';
				media-src 'self';
				object-src 'none';
				script-src 'self' <cfif len(arguments.includeNonce) GT 0 >'nonce-#arguments.includeNonce#'</cfif>;
				style-src 'self' <cfif len(arguments.includeNonce) GT 0 >'nonce-#arguments.includeNonce#'</cfif>;
				form-action 'self';
				<!--- require-sri-for 'script'; Require integrity attrib --->
				<!--- report-uri CSPViolation.cfm; --->
			</cfsavecontent>
		</cfsilent>
		</cfoutput>

		<cfreturn CSPPolicy />
	</cffunction>

	<cffunction name="getNonce" returntype="string" access="public" hint="Returns a cryptographic nonce for use with inline JS" >
		<cfreturn toBase64(generateSecretKey("AES", variables.cipherStrength)) />
	</cffunction>

	<cffunction name="encryptValue" returntype="string" access="public" hint="Encrypts the given string value, returned as a base64 string" >
		<cfargument name="value" type="string" required="true" default="The string value to encrypt" />

		<cfif len(arguments.value) IS 0 >
			<cfreturn "" />
		</cfif>

		<cfreturn encrypt(arguments.value, variables.secretKey, "AES", "base64") />
	</cffunction>

	<cffunction name="decryptValue" returntype="string" access="public" hint="Decrypts the given string value" >
		<cfargument name="value" type="string" required="true" default="The string value to decrypt, base64 encoded" />

		<cfif len(arguments.value) IS 0 >
			<cfreturn "" />
		</cfif>

		<cfreturn decrypt(arguments.value, variables.secretKey, "AES", "base64") />
	</cffunction>

	<cffunction name="generateAuthKey" returntype="string" access="public" hint="Returns an authKey, typically used for AJAX calls, based on the caller's sessionID" >
		<cfargument name="sessionID" type="string" required="true" default="" />
		<cfargument name="algorithm" type="string" required="false" default=#variables.validChecksumAlgorithms[6]# hint="Algorithm to use. By default SHA-512 is used" />

		<cfif len(arguments.sessionID) IS 0 >
			<cfthrow message="Unable to generate auth key" detail="Argument 'sessionID' is empty" />
		</cfif>

		<cfif arrayFind(variables.validChecksumAlgorithms, arguments.algorithm) IS 0 >
			<cfthrow message="Unable to generate auth key" detail="The algorithm you passed is invalid (#arguments.algorithm#). Valid algorithms are: #arrayToList(variables.validChecksumAlgorithms)#" />
		</cfif>

		<cfreturn hash(arguments.sessionid & generateSecretKey("AES", variables.cipherStrength), arguments.algorithm) />
    </cffunction>

    <cffunction name="getSaltString" returntype="string" access="public" >
		<cfreturn hash(generateSecretKey("AES"), variables.defaultHashAlgorithm) />
	</cffunction>

	<cffunction name="generateRandomPassword" returntype="string" access="public" >

		<cfset var validLowerCaseAlpha = "abcdefghijklmnopqrstuvwxyz" />
		<cfset var validUpperCaseAlpha = UCase( validLowerCaseAlpha ) />
		<cfset var validNumbers = "0123456789" />
		<cfset var validSpecialChars = "~!@##$%^&*" />

		<cfset var allValidChars = (validLowerCaseAlpha & validUpperCaseAlpha & validNumbers & validSpecialChars) />
		<cfset var password = [] />
		<cfset var randomPasswordValue = "" />

		<cfloop from="1" to="8" index="index" >
			<cfset randomPasswordValue = mid(
				allValidChars,
				randRange(1, len(allValidChars)),
				1
			) />

			<cfset arrayAppend(password, randomPasswordValue) />
		</cfloop>

		<cfreturn arrayToList(password, "") />
    </cffunction>

    <cffunction name="generateSaltedPassword" returntype="struct" access="public" >
        <cfargument name="plainPassword" type="string" required="true" hint="The new password, in plain text (non-hashed)" />

        <cfif len(arguments.plainPassword) IS 0 >
			<cfthrow message="Unable to generate salted password" detail="Argument 'plainPassword' is empty" />
		</cfif>

        <cfset var passwordSalt = variables.getSaltString() />
        <cfset var hashedPasswordWithSalt = hash(
            hash(arguments.plainPassword, variables.defaultHashAlgorithm, variables.encoding) & passwordSalt,
            variables.defaultHashAlgorithm,
            variables.encoding
        ) />

        <cfreturn {
            "salt": passwordSalt,
            "password": hashedPasswordWithSalt
        } />
	</cffunction>

	<cffunction name="validatePassword" returntype="boolean" access="public"  hint="Checks the password you pass against the user's password" >
        <cfargument name="plainPassword" type="string" required="true" hint="The password, in plain text (non-hashed)" />
        <cfargument name="salt" type="string" required="true" hint="The string used to salt the password" />
        <cfargument name="securedPassword" type="string" required="true" hint="The hashed and salted password to validate against" />

        <cfif len(arguments.plainPassword) IS 0 >
			<cfthrow message="Unable to validate password" detail="Argument 'plainPassword' is empty" />
        </cfif>

        <cfif len(arguments.salt) IS 0 >
			<cfthrow message="Unable to validate password" detail="Argument 'salt' is empty" />
        </cfif>

        <cfif len(arguments.securedPassword) IS 0 >
			<cfthrow message="Unable to validate password" detail="Argument 'securedPassword' is empty" />
		</cfif>

        <cfset var hashedPasswordWithSalt = hash(
            hash(arguments.plainPassword, variables.defaultHashAlgorithm, variables.encoding) & arguments.salt,
            variables.defaultHashAlgorithm,
            variables.encoding
        ) />

        <cfreturn hashedPasswordWithSalt IS arguments.securedPassword />
	</cffunction>

</cfcomponent>