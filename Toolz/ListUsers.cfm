<cfinclude template="CheckAuth.cfm" />

<!DOCTYPE html>
<html>

    <head>
        <title>List users</title>
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
        <h1>List users</h1>

        <cfset userDataDir = application.mapping.userData />

        <fieldset>
            <legend>USERS ON DISK:</legend>

            <cfscript>
                for(userFile in directoryList(path=userDataDir, recurse=false, listInfo="path", filter="*.json", type="file")) {
                    try {
                        userData = deserializeJSON(fileRead(userFile));
                    }
                    catch(error) {
                        writeOutput("<p>Unable to parse user file: #userFile#</p>");
                    }
        
                    writeDump(var=userData, label="#userFile#");
                }
            </cfscript>
        </fieldset>
        <hr/>
        <fieldset>
            <legend>USERS IN MEMORY:</legend>

            <cfscript>
                allUsers = application.authentication.getAllUsers();

                for (userName in allUsers) {
                    currentUser = allUsers[userName];
                    writeDump(var=currentUser, label="#userName#");
                }
            </cfscript>
        </fieldset>
    </body>

</html>