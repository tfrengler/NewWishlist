<cfinclude template="CheckAuth.cfm" />

<!DOCTYPE html>
<html>

    <head>
        <title>Create new user</title>
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
        <h1>Create new user</h1>

        <form name="CreateUserForm" method="POST" enctype="application/x-www-form-urlencoded" >
            <cfoutput>
            <div>
                <label>Name:</label><input name="Name" type="text" value="#structKeyExists(FORM, "Name") ? FORM.Name : ""#" />
            </div>
            <br/>

            <div>
                <label>Display name:</label><input name="DisplayName" type="text" value="#structKeyExists(FORM, "DisplayName") ? FORM.DisplayName : ""#" />
            </div>
            <br/>

            <div>
                <label>Password:</label><input name="Password" type="text" value="#structKeyExists(FORM, "Password") ? FORM.Password : ""#" />
            </div>
            </cfoutput>

            <p>
                <button name="Go">CREATE USER</button>
            </p>
        </form>

        <cfif NOT structIsEmpty(FORM) >
            <hr/>
            <cfdump var=#FORM# label="INPUT" />

            <cfif 
                len(FORM.DisplayName) IS 0 OR
                len(FORM.Name) IS 0 OR
                len(FORM.Password) IS 0
            >

                <p>ERROR: Name, display name or password is empty...</p>
                <cfabort/>

            </cfif>

            <cfset userDataDir = application.mapping.userData />
            <cfset wishlistDataDir = application.mapping.wishlistData />
            <cfset userIDs = [] />
            <cfset regexPattern = createObject("java", "java.util.regex.Pattern").compile('"id":\s*(\d+?)') />

            <cfscript> 
                for(userDataFile in directoryList(path=userDataDir, recurse=false, listInfo="path", filter="*.json", type="file")) {

                    if (find(FORM.Name & ".json", userDataFile) > 0) {
                        writeOutput("<p>ERROR: User already exists with the same name: #FORM.Name#</p>");
                        abort;
                    }

                    userDataContents = fileRead(userDataFile);
                    matcher = regexPattern.matcher(userDataContents);
                    matcher.find();
                    arrayAppend(userIDs, val(matcher.group(1)));
                }
            </cfscript>
    
            <cfset newUserID = arrayMax(userIDs) + 1 />
            <cfset securedPassword = application.security.generateSaltedPassword(FORM.Password) />

            <cfset newUser = {
                "id": newUserID,
                "name": FORM.Name,
                "displayName": FORM.DisplayName,
                "password": securedPassword.password,
                "salt": securedPassword.salt
            } />

            <cfdump var=#newUser# label="OUTPUT" />

            <cftry><cfset directoryCreate("#wishlistDataDir#/#newUserID#", false, false) />
            <cfcatch>
                <p>ERROR: Unable to create wishlist directory:</p>
                <cfrethrow/>
                <cfabort/>
            </cfcatch>
            </cftry>
            
            <cfoutput>
                <p>Wishlist directory created: #encodeForHTML("#wishlistDataDir#/#newUserID#")#</p>
                <cfset fileWrite("#userDataDir#/#FORM.Name#.json", serializeJSON(newUser)) />
                <p>User file created: #encodeForHTML("#userDataDir#/#FORM.Name#.json")#</p>
            </cfoutput>

            <cfset application.authentication.reload() />
            <p>application.authentication has been reloaded</p>
        </cfif>
        
    </body>

</html>