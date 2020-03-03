<cfparam name="URL.ImageURL" type="string" default="NOT_VALID" />
<cfheader name="Content-Type" value="application/json" />

<cfset ReturnData = {STATUS: 0} />

<cfset ValidImages = [
    "image/jpeg",
	"image/bmp",
	"image/png",
	"image/tiff",
	"image/webp"
] />

<cfhttp url=#URL.ImageURL# result="ImageTest" method="HEAD" timeout="3" />

<cfif ImageTest.status_code NEQ 200 >
    <cfset ReturnData.STATUS = 1 />
    <cfcontent reset="true" />
    <cfset writeOutput(serializeJSON(ReturnData)) />
    <cfabort/>
</cfif>

<cfif NOT structKeyExists(ImageTest.responseheader, "Content-Type") >
    <cfset ReturnData.STATUS = 2 />
    <cfcontent reset="true" />
    <cfset writeOutput(serializeJSON(ReturnData)) />
    <cfabort/>
</cfif>

<cfif arrayFind(ValidImages, ImageTest.responseheader["Content-Type"]) EQ 0 >
    <cfset ReturnData.STATUS = 3 />
    <cfcontent reset="true" />
    <cfset writeOutput(serializeJSON(ReturnData)) />
    <cfabort/>
</cfif>

<cfcontent reset="true" />
<cfset writeOutput(serializeJSON(ReturnData)) />