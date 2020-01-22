
<!DOCTYPE html>
<html lang="en">

	<head>
		<title>Wishlist</title>
		<meta content="text/html; charset=utf-8" http-equiv="Content-Type" />
		<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

		<link rel="stylesheet" href="CSS/font_awesome/css/all.css" />
		<link rel="stylesheet" href="CSS/bootstrap/bootstrap.min.css" />
		<!--- <link rel="stylesheet" href="Assets/css/main.css" /> --->

		<!--- 3rd Party --->
		<script src="JS/bootstrap/jquery-3.4.1.slim.min.js"></script>
		<script src="JS/bootstrap/popper.min.js"></script>
		<script src="JS/bootstrap/bootstrap.min.js"></script>

		<link rel="stylesheet" href="CSS/main.css" />

        <!--- todo(thomas): Debuggery --->
        <cfsilent>
            <cfset authKey = application.security.generateAuthKey(sessionid=session.sessionid) />
            <cfset session.ajaxAuthKey = authKey />
        </cfsilent>

        <script>
            <cfoutput>const CFAjaxAuthKey = "#authKey#";</cfoutput>

			const onImageNotFound = function(imgElement) {
				imgElement.src = "Media/Images/ImageNotFound.jpeg";
			}
		</script>

		<script type="module" defer src="JS/main.js" ></script>
	</head>

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
						<!--- TODO(thomas): Get users from authentication in application, enumerate and generate a button per user --->
						<p>
							<button data-wishlist-owner-id="1" data-wishlist-owner-name="CARLETTE" class="btn btn-info btn-block">CARLETTE</button>
						</p>
						<p>
							<button data-wishlist-owner-id="2" data-wishlist-owner-name="THOMAS" class="btn btn-info btn-block">THOMAS</button>
						</p>
					</div>

					<div class="modal-header">
						<h5 class="modal-title">SIGN IN (ONLY FOR EDITING)</h5>
					</div>

					<div class="modal-body">
						<input type="text" id="Username" class="form-control" placeholder="Username" />
						<input type="text" id="Password" class="form-control" placeholder="Password" />

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
		<div class="modal fade" id="EditWish" data-backdrop="static" tabindex="-1" >
			<div class="modal-dialog" >
				<div class="modal-content">

					<div class="modal-header bg-primary text-white">
						<h5 class="modal-title">PICTURE</h5>
					</div>

					<div class="modal-body">
						<div class="d-flex justify-content-center mb-2" >
							<img onerror="onImageNotFound(this)" id="Edit_Picture" class="border rounded" src="Media/Images/ImageNotFound.jpeg" referrerpolicy="no-referrer" validate="never" />
						</div>

						<b>UPLOAD A FILE:</b>
						<div class="d-flex align-items-center" >
							<input id="Edit_Picture_File" type="file" class="form-control mb-2" />
							&nbsp;
							<!--- <i class="fas fa-spinner fa-spin fa-2x text-info invisible"></i> --->
							<!--- <i class="far fa-times-circle fa-2x text-danger invisible"></i> --->
							<i class="far fa-check-circle fa-2x text-success invisible"></i>
						</div>


						<b>OR PROVIDE A LINK:</b>
						<div class="d-flex align-items-center" >
							<input id="Edit_Picture_URL" type="text" class="form-control" placeholder="www.someurl.com/somepicture" />
							&nbsp;
							<!--- <i class="fas fa-spinner fa-spin fa-2x text-info invisible"></i> --->
							<!--- <i class="far fa-times-circle fa-2x text-danger invisible"></i> --->
							<i class="far fa-check-circle fa-2x text-success invisible"></i>
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

					<div class="modal-body">
						<input type="text" class="form-control mb-1" id="Edit_Link1" />
						<input type="text" class="form-control mb-1" id="Edit_Link2" />
						<input type="text" class="form-control mb-1" id="Edit_Link3" />
						<input type="text" class="form-control mb-1" id="Edit_Link4" />
						<input type="text" class="form-control mb-1" id="Edit_Link5" />
					</div>

					<div class="modal-footer">
						<button type="button" id="SaveWishChanges" class="btn btn-primary" >
							<span>SAVE</span>
							<i class="fas fa-cog fa-spin text-warning"></i>
						</button>
						<button type="button" class="btn btn-info" data-dismiss="modal">CLOSE</button>
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
					<button id="EditMode" class="btn btn-warning" >
						<i class="fas fa-pen-square"></i>&nbsp;EDIT-MODE
					</button>
				</section>
				<h2 class="info-box" id="HeaderTitle">WISHLISTS</h2>

			</nav>
		</header>

		<!--- MAIN CONTAINER --->
        <main class="container-fluid">
            <!--- <cfdump var=#session# /> --->
			
			<div class="row">

				<section id="WishID_X" class="wish border border-dark rounded p-3 d-inline-flex flex-row bg-light mb-3">

					<div class="wish-item wish-edit p-3" >
						<button id="EditWish_X" class="btn btn-warning" data-toggle="modal" data-target="#EditWish" >
							<i class="fas fa-edit fa-3x"></i>
						</button>
					</div>

					<div class="wish-item wish-image border rounded mr-3 overflow-hidden">
						<img onerror="onImageNotFound(this)" class="rounded" src="Media/Images/xxx.jpg" referrerpolicy="no-referrer" validate="never" />
					</div>

					<div class="wish-item wish-description border rounded overflow-hidden p-3 mr-3" >
						The Other Kind of Life<br/>
						by Shamus Young<br/>
						ISBN-10: 1790478510<br/>
						ISBN-13: 978-1790478514<br/>
					</div>

					<div class="wish-item wish-links border rounded p-3 text-primary" >
						<div><i class="fas fa-link">
							<a href="#">LINK</a>
						</i></div>
						<div><i class="fas fa-link">
							<a href="#">LINK</a>
						</i></div>
						<div><i class="fas fa-link">
							<a href="#">LINK</a>
						</i></div>
					</div>

					<div class="wish-item wish-delete p-3" >
						<button id="DeleteWish_X" class="btn btn-danger" >
							<i class="fas fa-trash-alt fa-3x"></i>
						</button>
					</div>
				</section>

			</div>

			<div class="row">
				<section id="WishID_X" class="wish border border-dark rounded p-3 d-inline-flex flex-row bg-light mb-3">

					<div class="wish-item wish-edit p-3" >
						<button id="EditWish_X" class="btn btn-warning" data-toggle="modal" data-target="#EditWish" >
							<i class="fas fa-edit fa-3x"></i>
						</button>
					</div>

					<div class="wish-item wish-image border rounded mr-3 overflow-hidden">
						<img onerror="onImageNotFound(this)" class="rounded" src="Media/Images/TheGang.jpg" referrerpolicy="no-referrer" validate="never" />
					</div>

					<div class="wish-item wish-description border rounded overflow-hidden p-3 mr-3" >
						Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, "Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32.
						The standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from "de Finibus Bonorum et Malorum" by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham.
					</div>

					<div class="wish-item wish-links border rounded p-3 text-primary" >
						<div>
							<a href="#">
								<i class="fas fa-link">&nbsp;LINK</i>
							</a>
						</div>
						<div>
							<a href="#">
								<i class="fas fa-link">&nbsp;LINK</i>
							</a>
						</div>
						<div>
							<a href="#">
								<i class="fas fa-link">&nbsp;LINK</i>
							</a>
						</div>
						<div>
							<a href="#">
								<i class="fas fa-link">&nbsp;LINK</i>
							</a>
						</div>
						<div>
							<a href="#">
								<i class="fas fa-link">&nbsp;LINK</i>
							</a>
						</div>
					</div>

					<div class="wish-item wish-delete p-3" >
						<button id="DeleteWish_X" class="btn btn-danger" >
							<i class="fas fa-trash-alt fa-3x"></i>
						</button>
					</div>
				</section>
			</div>

			<div class="row">
				<button id="AddWish" class="btn btn-success" data-toggle="modal" data-target="#EditWish" >
					<i class="fas fa-plus-square fa-3x"></i>
				</button>
			</div>

		</main>

		<!--- NOTIFICATIONS --->
		<div id="Notifications"></div>

		<ol id="Footer" class="breadcrumb fixed-bottom rounded-0 pt-3 mb-0">
			<div class="breadcrumb-item">WISHLIST</div>
			<div class="breadcrumb-item">CARLETTE</div>
			<div class="breadcrumb-item active">EDIT</div>
		</ol>
	</body>

</html>