<cfparam name="URL.DevMode" type="boolean" default="0" />

<!DOCTYPE html>
<html lang="en">

	<cfoutput>
	<head>
		<title>Wishlist</title>
		<meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
		<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

		<!--- 3rd Party --->
		<link #URL.DevMode ? "" : 'integrity="sha384-#application.integrityList["all.css"]#"'# rel="stylesheet" href="CSS/font_awesome/css/all.css" />
		<link #URL.DevMode ? "" : 'integrity="sha384-#application.integrityList["bootstrap.min.css"]#"'# rel="stylesheet" href="CSS/bootstrap/bootstrap.min.css" />
		<!--- 3rd Party --->
		<script #URL.DevMode ? "" : 'integrity="sha384-#application.integrityList["jquery-3.4.1.slim.min.js"]#"'# src="JS/bootstrap/jquery-3.4.1.slim.min.js"></script>
		<script #URL.DevMode ? "" : 'integrity="sha384-#application.integrityList["popper.min.js"]#"'# src="JS/bootstrap/popper.min.js"></script>
		<script #URL.DevMode ? "" : 'integrity="sha384-#application.integrityList["bootstrap.min.js"]#"'# src="JS/bootstrap/bootstrap.min.js"></script>

        <cfsilent>
            <cfset authKey = application.security.generateAuthKey(sessionid=session.sessionid) />
            <cfset session.ajaxAuthKey = authKey />
        </cfsilent>

		<link #URL.DevMode ? "" : 'integrity="sha384-#application.integrityList["main.css"]#"'# rel="stylesheet" href="CSS/main.css" />
        <script #URL.DevMode ? "" : 'nonce="#application.nonce#"'# ><cfset writeOutput("const CFAjaxAuthKey = '#authKey#';") /></script>
		<script #URL.DevMode ? "" : 'integrity="sha384-#application.integrityList["main.js"]#"'# type="module" defer src="JS/main.js" ></script>
	</head>
	</cfoutput>

	<body>
		<!--- MENU MODAL --->
		<div class="modal fade" id="MainMenu" data-backdrop="static" tabindex="-1" >
			<div class="modal-dialog" >
				<div class="modal-content">

					<div class="modal-header">
						<h5 class="modal-title">WISHLISTS</h5>
						<i id="WishlistLoader" class="fas fa-spinner fa-spin text-warning fa-2x hidden"></i>
					</div>

					<div class="modal-body" id="WishlistContainer" >
						<cfset allUsers = application.authentication.getAllUsers() />
						<cfloop collection=#allUsers# item="userName" >
							<cfset currentUser = allUsers[userName] />

							<cfoutput>
							<p><button data-wishlist-owner-id="#currentUser.getId()#" data-wishlist-owner-name="#currentUser.getDisplayName()#" class="btn btn-info btn-block">#currentUser.getDisplayName()#</button></p>
							</cfoutput>
						</cfloop>
					</div>

					<div class="modal-header">
						<h5 class="modal-title">SIGN IN (ONLY FOR EDITING)</h5>
					</div>

					<div class="modal-body">
						<input type="text" id="Username" class="form-control" placeholder="Username" />
						<input type="password" id="Password" class="form-control" placeholder="Password" />

						<button id="LogIn" type="button" class="btn btn-primary" disabled>
							LOG IN
							<i class="fas fa-cog fa-spin text-warning hidden"></i>
						</button>
						<button id="LogOut" type="button" class="btn btn-info" disabled>
							LOG OUT
							<i class="fas fa-cog fa-spin text-warning hidden"></i>
						</button>
					</div>

					<div class="modal-footer">
						<button type="button" id="CloseMenu" class="btn btn-primary" data-dismiss="modal">CLOSE</button>
					</div>
				</div>
			</div>
		</div>

		<!--- EDIT-WISH MODAL --->
		<div class="modal fade" id="EditWish" data-backdrop="static" tabindex="-1" data-activewish="0" >
			<div class="modal-dialog" >
				<div class="modal-content">

					<div class="modal-header bg-primary text-white">
						<h5 class="modal-title">PICTURE</h5>
					</div>

					<div class="modal-body">
						<div class="d-flex justify-content-center mb-2" >
							<img id="Edit_Picture" class="border rounded" referrerpolicy="no-referrer" validate="never" src="Media/Images/ImageNotFound.jpeg" />
						</div>

						<b>PROVIDE A LINK:</b>
						<div class="d-flex align-items-center" >
							<input id="Edit_Picture_URL" type="url" class="form-control" placeholder="www.someurl.com/somepicture.jpeg" />
							&nbsp;
							<i id="EditPictureStatus" class="fas far fa-2x hidden"></i>
						</div>
					</div>

					<div class="modal-header bg-primary text-white">
						<h5 class="modal-title">DESCRIPTION</h5>
					</div>

					<div class="modal-body">
						<textarea id="Edit_Description" rows="4"></textarea>
					</div>

					<div class="modal-header bg-primary text-white">
						<h5 class="modal-title">LINKS</h5>
					</div>
                    <!--- Do valid URL checking here --->
					<div id="Edit_Links_Container" class="modal-body">
						<input type="url" class="form-control mb-1" id="Edit_Link1" />
						<input type="url" class="form-control mb-1" id="Edit_Link2" />
						<input type="url" class="form-control mb-1" id="Edit_Link3" />
						<input type="url" class="form-control mb-1" id="Edit_Link4" />
						<input type="url" class="form-control mb-1" id="Edit_Link5" />
					</div>

					<div class="modal-footer">
						<button type="button" id="SaveWishChanges" class="btn btn-primary" >
							<span>SAVE</span>
							<i class="fas fa-cog fa-spin text-warning hidden"></i>
						</button>
						<button type="button" id="CloseEditWishDialog" class="btn btn-info" data-dismiss="modal">CLOSE</button>
					</div>
				</div>
			</div>
        </div>

        <!--- DELETE WISH CONFIRMATION MODAL --->
        <div id="DeleteWishDialog" data-wishid="0" class="modal" tabindex="-1" role="dialog">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title">DELETE WISH</h5>
                </div>
                <div class="modal-body">
                    <p>You sure? Beware that this cannot be undone</p>
                </div>
                <div class="modal-footer">
                    <button type="button" id="ConfirmWishDelete" class="btn btn-success" data-dismiss="modal">YES</button>
                    <button type="button" class="btn btn-warning" data-dismiss="modal">CANCEL</button>
                </div>
                </div>
            </div>
        </div>

		<!--- TOP HEADER --->
		<header>
			<nav class="navbar fixed-top navbar-dark bg-primary">

				<section>
					<button id="MenuButton" class="btn btn-info" data-toggle="modal" data-target="#MainMenu" >
						<i class="fas fa-bars"></i>
					</button>
					<span id="ActiveWishlistOwnerNameContainer" class="btn btn-warning" >
						<i class="fas fa-clipboard-list"></i>&nbsp;
						<span id="ActiveWishlistOwnerName"></span>
					</span>
				</section>
				<h2 class="info-box" id="HeaderTitle">WISHLISTS</h2>

			</nav>
		</header>

		<!--- MAIN CONTAINER --->
		<main id="WishRowContainer" class="container-fluid">

            <div id="WelcomeMessageRow" class="d-flex lead flex-column align-items-center row">
				<div>Welcome! No wishlist has been selected yet</div>
				<div>Open the <b>main menu</b> in the top left to find all available wishlists.</div>
            </div>

			<div class="row" id="AddWishRow">
				<button id="AddWish" data-wishid="0" class="btn btn-success hidden" data-toggle="modal" data-target="#EditWish" >
					<i class="fas fa-plus-square fa-3x"></i>
				</button>
			</div>
		</main>

		<!--- NOTIFICATIONS --->
		<div id="Notifications">
            <!--- <span class="notification-message p-3 rounded hidden">TESTING!!!!</span> --->
        </div>
	</body>

</html>

<!--- BUGS/POTENTIAL CHANGES:

	* Split controller Wishes into stuff that happens in the main window, and what happens in the edit-dialog
	* Change all event handlers from just passing the raw event, to passing the proper arguments instead
	* Move notifications to the side or maybe the bottom?
	* When loading wishlists, signing in, editing wishes should the dialog maybe close?
	* Log users out when performing unauthenticated actions. 
		- NOTE: Need to react to the status code returned by WishlistManager (1 for invalid sessions), and also need to take into account the expiration of the auth key

	BACKEND DATA FLOW:

	Front end call via JSUtils.fetchRequest():
	
	-> calls AjaxProxy, which always returns a struct with RESPONSE and RESPONSE_CODE.
	- By RESPONSE_CODE the call is considered successfull if it's 0, with anything else being an error.
	- RESPONSE contains data from the backend as a struct. If the backend returns void (or an error happened) it contains null.
	
	-> fetchRequest returns a structure with ERROR and DATA.

	- If AjaxProxy response code is not 0 then ERROR is true, otherwise false.
	- If an error happened the DATA structure will contain MESSAGE and STATUS:
		-> the former contains a text message describing the error.
		-> the latter containing the backend controller's STATUS_CODE or the HTTP status code.

	-----AJAX PROXY:
	{
		RESPONSE_CODE: int,
		RESPONSE: {
			DATA: {} or null,
			STATUS_CODE: int
		}
	}

	- If the call succeeds then DATA contains a structure with whatever data the backend passed back OR null if the backend returns void.

		-----FETCHREQUEST:
		{
			ERROR: false,
			DATA: {} or null
		}

		-----FETCHREQUEST:
		{
			ERROR: true,
			DATA: {
				MESSAGE: string,
				STATUS: int
			}
		}
--->