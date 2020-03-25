<cfinclude template="CheckAuth.cfm" />

<!DOCTYPE html>
<html>

    <head>
        <title>Toolz Box</title>
        <meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
        <meta name="author" content="Thomas Frengler" />
    </head>

    <body>
        <h1>Wishlist TOOLS</h1>

        <form name="ToolsForm" method="POST" enctype="application/x-www-form-urlencoded" >
            <fieldset>
                <legend>USERS:</legend>
                <ul>
                    <li><a href="CreateUser.cfm">Create new user</a></li>
                    <li><a href="EditUsers.cfm">Change user details</a></li>
                    <li><a href="ListUsers.cfm">List users</a></li>
                </ul>
            </fieldset>

            <fieldset>
                <legend>LOGS:</legend>
                <ul>
                    <li><button name="ShowLogs">Show log files</button></li>
                    <li><button name="DeleteLogs" value="1D">Delete logs older than 1 day</button></li>
                    <li><button name="DeleteLogs" value="1W">Delete logs older than 1 week</button></li>
                </ul>
            </fieldset>

            <fieldset>
                <legend>WISHES:</legend>
                <ul>
                    <li><button name="ShowWishes">Show wishlists and wishes</button></li>
                </ul>
            </fieldset>
        </form>

        <cfif NOT structIsEmpty(FORM) >
            <hr/>
            <!--- <cfdump var=#FORM# /> --->

            <cfif structKeyExists(FORM, "ShowLogs") >
                <cfset logFiles = directoryList(path=application.mapping.logs, listInfo="name", filter="*.txt|*.html", type="file") />
                
                <h2>Log files:</h2>

                <ol>
                <cfscript>
                    for(logFile in logFiles)
                        writeOutput("<li><a target='_blank' href='ShowLog.cfm?LogFile=#encodeForURL(logFile)#'>#encodeForHTML(logFile)#</a></li>")
                </cfscript>
                </ol>

            </cfif>

            <cfif structKeyExists(FORM, "DeleteLogs") >
                <cfset logFiles = directoryList(path=application.mapping.logs, listInfo="query", filter="*.txt|*.html", type="file") />
                
                <cfif FORM.DeleteLogs EQ "1D" >
                    <cfset DatePart = "d" />
                <cfelseif FORM.DeleteLogs EQ "1W" >
                    <cfset DatePart = "w" />
                <cfelse>
                    <p>ERROR: No matching date part found for deleting logs</p>
                    <cfabort/>
                </cfif>

                <cfset filesToDelete = [] />

                <cfscript>
                    for(logFile in logFiles)
                        if (dateDiff(DatePart, logFile.dateLastModified, now()) > 1)
                            filesToDelete.append(logFile.name);
                </cfscript>

                <cfif arrayLen(filesToDelete) IS 0 >
                    <p>No log files to delete</p>
                    <cfabort/>
                </cfif>
                    
                <cfscript>
                    for(logFile in filesToDelete)
                        fileDelete("#application.mapping.logs#/#logFile#");
                </cfscript>

                <cfdump var=#filesToDelete# label="FILES DELETED" />
            </cfif>

            <cfif structKeyExists(FORM, "ShowWishes") >
                <h2>WISHES:</h2>

                <cfscript>
                    wishlistDir = application.mapping.wishlistData;
                    wishIndex = {};

                    if (NOT directoryExists(wishlistDir)) {
                        writeOutput("<p>ERROR: Wishlist dir does not exist: #wishlistDir#</p>")
                        abort;
                    }

                    for(wishFile in directoryList(path=wishlistDir, recurse=true, listInfo="path", filter="*.json", type="file")) {
                        
                        wishFileParts = listToArray(wishFile, "\/");
                        wishlistID = val(wishFileParts[ arrayLen(wishFileParts) - 1 ]);

                        if (!structKeyExists(wishIndex, wishlistID))
                            wishIndex[wishlistID] = {};

                        try {
                            wishIndex[wishlistID][arrayLast(wishFileParts)] = deserializeJSON( fileRead(wishFile) );
                        }
                        catch(error) {
                            wishIndex[wishlistID][arrayLast(wishFileParts)] = "ERROR: Unable to deserialize file";
                        }
                    }

                    writeDump(wishIndex);
                </cfscript>
            </cfif>
        </cfif>
    </body>
</html>