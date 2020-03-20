<cfinclude template="CheckAuth.cfm" />

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

        <fieldset>
            <legend>USERS:</legend>

            <ol>
                <cfscript>
                    allUsers = application.authentication.getAllUsers();

                    for (userName in allUsers) {
                        currentUser = allUsers[userName];
                        writeOutput("<li><a href='EditUsers.cfm?User=#encodeForURL(currentUser.getId())#'>#currentUser.getName()# | #currentUser.getId()#</a></li>");
                    }
                </cfscript>
            </ol>
        </fieldset>
        <br/>

        <cfif structKeyExists(URL, "User") >
            <cfset UserBeingEdited = application.authentication.getUserById(val(URL.User)) />

            <form name="EditUserForm" method="POST" enctype="application/x-www-form-urlencoded" >
                <cfoutput>
                <input type="hidden" name="UserID" value="#val(URL.User)#" />

                <div>
                    <label>Name:</label><input name="Name" type="text" value="#UserBeingEdited.getName()#" />
                </div>
                <br/>

                <div>
                    <label>Display name:</label><input name="DisplayName" type="text" value="#UserBeingEdited.getDisplayName()#" />
                </div>
                <br/>

                <div>
                    <label>Password:</label><input name="Password" type="text" value="" />
                </div>
                </cfoutput>

                <p>
                    <button name="Go">EDIT</button>
                </p>
            </form>
        </cfif>

        <cfif NOT structIsEmpty(FORM) >
            <hr/>
            <cfdump var=#FORM# label="INPUT" abort="false" />

            <cfset FORM.Name = trim(FORM.Name) />
            <cfset FORM.DisplayName = trim(FORM.DisplayName) />
            <cfset FORM.Password = trim(FORM.Password) />

            <cfset user = application.authentication.getUserById(val(FORM.UserID)) />
            <cfset userDataDir = application.mapping.userData />
            <cfset newPassword = {} />

            <cfif user.getName() EQ FORM.Name AND user.getDisplayName() EQ FORM.DisplayName AND len(FORM.Password) IS 0 >
                <p>WARNING: Nothing saved, as nothing changed</p>
                <cfabort/>
            </cfif>

            <cfif len(FORM.Password) GT 0 >
                <cfset newPassword = application.security.generateSaltedPassword(FORM.Password) />
                <p>New password generated</p>
            </cfif>

            <cfset editedUser = {
                "id": user.getId(),
                "name": len(FORM.Name) GT 0 ? FORM.Name : user.getName(),
                "displayName": len(FORM.DisplayName) GT 0 ? FORM.DisplayName : user.getDisplayName(),
                "password": structIsEmpty(newPassword) ? user.getPassword() : newPassword.password,
                "salt": structIsEmpty(newPassword) ? user.getSalt() : newPassword.salt
            } />

            <cfdump var=#editedUser# label="OUTPUT" />

            <cfif user.getName() NEQ FORM.Name >
                <cfset existingUserFile = "#userDataDir#/#user.getName()#.json" />

                <p>User name changed, deleting old file first</p>
                <cfif fileExists(existingUserFile) >
                    <cfset fileDelete(existingUserFile) />
                <cfelse>
                    <p>WARNING: User file didn't exist, couldn't delete</p>
                </cfif>
            </cfif>

            <cfset fileWrite("#userDataDir#/#FORM.Name#.json", serializeJSON(editedUser)) />
            <p>Edit user file written to disk</p>

            <cfset application.authentication.reload() />
            <p>application.authentication has been reloaded</p>
        </cfif>
        
    </body>

</html>