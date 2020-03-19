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

        <!--- 
            * Create users
            * Change passwords
            * See logs
            * Delete logs
            * See wishes
        --->

        <!--- <cfdump var=#hash("tfrengler", "SHA-256")# label="Username" />
        <cfdump var=#hash("tf499985", "SHA-256")# label="Password" /> --->

        <form name="ToolsForm" method="POST" enctype="application/x-www-form-urlencoded" >
            <fieldset>
                <legend>USERS:</legend>
                <ul>
                    <li>Create new user</li>
                    <li>Change user details</li>
                    <li>List users</li>
                </ul>
            </fieldset>

            <fieldset>
                <legend>LOGS:</legend>
                <ul>
                    <li><button name="ShowLogs">Show log files</button></li>
                    <li><button name="DeleteLogs1D">Delete logs older than 1 day</button></li>
                    <li><button name="DeleteLogs1W">Delete logs older than 1 week</button></li>
                </ul>
            </fieldset>

            <fieldset>
                <legend>WISHES:</legend>
                <ul>
                    <li>Show wishlists and wishes</li>
                </ul>
            </fieldset>
        </form>

        <cfif NOT structIsEmpty(FORM) >
            <hr/>

            <cfdump var=#FORM# />
        </cfif>
    </body>
</html>