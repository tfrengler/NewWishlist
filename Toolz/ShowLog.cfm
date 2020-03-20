<cfinclude template="CheckAuth.cfm" />
<cfparam name="URL.LogFile" type="string" default="" />

<!DOCTYPE html>
<html>

    <head>
        <title>Edit user</title>
        <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
        <meta name="author" content="Thomas Frengler" />

        <style>
            label {
                width: 15rem;
                display: inline-block;
                text-align: left;
            }
        </style>
    </head>

    <body>
        <h1>Edit user</h1>
        <p>
            <h2><a href="main.cfm">BACK</a></h2>
        </p>

        <cfif len(URL.LogFile) IS 0 >
            <p>ERROR: LogFile-param is empty :/</p>
        </cfif>

        <cfset filePath = "#application.mapping.logs#/#URL.LogFile#" />

        <cfif fileExists(filePath) >
            <p>ERROR: Log file does not exist: <cfset writeOutput(filePath) /> :/</p>
        </cfif>

        <cfcontent file=#filePath# type="#fileGetMimeType(filePath)#" reset="true" />
    </body>
</html>