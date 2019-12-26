<cfcomponent output="false" >
<cfprocessingdirective pageEncoding="utf-8"  />

	<cfset recipePicturePath = "" />
	<cfset recipeThumbnailPath = "" />
	<cfset tempDirectory = "" />
	<cfset maxUploadSizeInBytes = "5242880" />
	<cfset validImageMimeTypes = "image/gif,image/png,image/jpeg" />
	<cfset alphaNumericOnlyRegex = "[^A-Za-z0-9_]" />

	<cfset recipeImageDimensions = {
		width: 450,
		height: 300
	} />

	<cfset recipeThumbnailDimensions = {
		width: 50,
		height: 50
	} />

	<cffunction name="deleteTempFile" access="public" returntype="void" output="false" hint="" >
		<cfargument name="file" type="string" required="true" />

		<cfset var fullPathToFile = variables.tempDirectory & "\" & arguments.file />

		<cfif fileExists( fullPathToFile ) >
			<cfset fileDelete(fullPathToFile) />
		<cfelse>
			<!--- TODO(thomas): Replace with a log entry in an error log or something --->
			<!--- <cfthrow message="Error deleting temp file" detail="File '#fullPathToFile#' does not exist" /> --->
		</cfif>
	</cffunction>

	<cffunction name="deleteImage" access="public" returntype="void" output="false" hint="" >
		<cfargument name="file" type="string" required="true" />

		<cfset var fullPathToFile = variables.recipePicturePath & "\" & arguments.file />

		<cfif fileExists( fullPathToFile ) >
			<cfset fileDelete(fullPathToFile) />
		<cfelse>
			<!--- TODO(thomas): Replace with a log entry in an error log or something --->
			<!--- <cfthrow message="Error deleting image" detail="File '#fullPathToFile#' does not exist" /> --->
		</cfif>
	</cffunction>

	<cffunction name="uploadImage" access="public" returntype="string" output="false" hint="" >
		<cfargument name="fileName" type="string" required="true" />

		<cfset var newFileName = "#createUUID()#.png" />
		<cfset var newImage = "" />
		<cfset var newFileAttempts = 0 />
		<cfset var maxNewFileAttempts = 50 />
		<cfset var fullTempFilePathAndName = "#variables.tempDirectory#\#arguments.fileName#" />

		<cfif fileExists(fullTempFilePathAndName) IS false >
			<cfthrow message="Error uploading image" detail="The image file appears not to exist: #fullTempFilePathAndName#" />
		</cfif>

		<cfimage action="read" source=#fullTempFilePathAndName# name="newImage" />
		<cfset imageScaleTofit(newImage, variables.recipeImageDimensions.width, variables.recipeImageDimensions.height) />

		<cfloop from="1" to=#maxNewFileAttempts# index="newFileAttempts" >

			<cfif fileExists(fullTempFilePathAndName) IS true >
				<cfset newFileName = "#createUUID()#.png" />
			<cfelse>
				<cfbreak />
			</cfif>

		</cfloop>

		<cfif newFileAttempts EQ maxNewFileAttempts >
			<cffile action="delete" file=#fullTempFilePathAndName# />
			<cfthrow message="Error uploading image" detail="Unable to create a unique name for the new image file" />
		</cfif>

		<cfimage action="write" source=#newImage# destination="#variables.recipePicturePath#/#newFileName#" />
		<cffile action="delete" file=#fullTempFilePathAndName# />

		<cfreturn newFileName />
	</cffunction>

	<cffunction name="getMaxFileSize" access="public" returntype="numeric" output="false" hint="" >
		<cfreturn variables.maxUploadSizeInBytes />
	</cffunction>

	<cffunction name="getAcceptedMimeTypes" access="public" returntype="string" output="false" hint="" >
		<cfreturn variables.validImageMimeTypes />
	</cffunction>

	<cffunction name="init" access="public" returntype="Components.FileManager" output="false" hint="" >
		<cfargument name="recipePicturePath" type="string" required="true" />
		<cfargument name="recipeThumbnailPath" type="string" required="true" />
		<cfargument name="tempDirectory" type="string" required="true" />

		<cfif len(arguments.recipePicturePath) IS 0 >
			<cfthrow message="Error initializing file manager" detail="Argument 'recipePicturePath' appears to be empty!" />
		</cfif>

		<cfif len(arguments.recipeThumbnailPath) IS 0 >
			<cfthrow message="Error initializing file manager" detail="Argument 'recipeThumbnailPath' appears to be empty!" />
		</cfif>

		<cfif len(arguments.tempDirectory) IS 0 >
			<cfthrow message="Error initializing file manager" detail="Argument 'tempDirectory' appears to be empty!" />
		</cfif>

		<cfset variables.recipePicturePath = arguments.recipePicturePath />
		<cfset variables.recipeThumbnailPath = arguments.recipeThumbnailPath />
		<cfset variables.tempDirectory = arguments.tempDirectory />

		<cfreturn this />
	</cffunction>

</cfcomponent>