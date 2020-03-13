<cfparam name="URL.DevMode" type="boolean" default="0" />

<!DOCTYPE html>
<html lang="en">

	<cfoutput>
	<head>
		<title>Wishlist</title>
		<meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
		<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

		<!--- 3rd Party --->
		<link #URL.DevMode ? "" : 'integrity="sha384-Di7COCxiGf5cCNlWvilzYruB8I/QphvEsI4Z5WpO7eKhaDuvB5UI4QCtTl6hYUz1"'# rel="stylesheet" href="CSS/font_awesome/css/all.css" />
		<link #URL.DevMode ? "" : 'integrity="sha384-4bTenJziBfRum8FDNUospyhSSix1d2YpYdU/mMpDqEoa79df7KP2ptTsYrz6XMWR"'# rel="stylesheet" href="CSS/bootstrap/bootstrap.min.css" />
		<!--- 3rd Party --->
		<script #URL.DevMode ? "" : 'integrity="sha384-pkoRnrXNgdq2HZ+4rl5xWYyNF60aFp2DgiMpMlWoa+NyC4XXJEhjXEVKM2gTkBW6"'# src="JS/bootstrap/jquery-3.4.1.slim.min.js"></script>
		<script #URL.DevMode ? "" : 'integrity="sha384-LsC345MdEcKqeNkjUm1MZY2zfeALf4Iqn+DbI/5gdhCoWMoTVQvkd/0n+yOSie0F"'# src="JS/bootstrap/popper.min.js"></script>
		<script #URL.DevMode ? "" : 'integrity="sha384-GQt+azJYTXdZSGjGyhmO+xX875BtpqCQkaEYDeJwkpi2L7UqEky8qS08BUVla9dc"'# src="JS/bootstrap/bootstrap.min.js"></script>

        <cfsilent>
            <cfset authKey = application.security.generateAuthKey(sessionid=session.sessionid) />
            <cfset session.ajaxAuthKey = authKey />
        </cfsilent>

		<link #URL.DevMode ? "" : 'nonce="#application.nonce#"'# rel="stylesheet" href="CSS/main.css" />
        <script #URL.DevMode ? "" : 'nonce="#application.nonce#"'# ><cfset writeOutput("const CFAjaxAuthKey = '#authKey#';") /></script>
		<script #URL.DevMode ? "" : 'integrity="sha384-+8VJ4wxgctUll9F61SXcXx69yO0RvAF4lvGeKRw9Co0XR1y3d6SordlAMf3RWEFU"'# type="module" defer src="JS/main.js" ></script>
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
						<i class="fas fa-user"></i>&nbsp;
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

--->