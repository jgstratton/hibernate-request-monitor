<html>
<head>
	<script 
			src="https://code.jquery.com/jquery-3.2.1.min.js" 
			integrity="sha384-xBuQ/xzmlsLoJpyjoggmTEz8OWUFM0/RC5BsqQBDX2v5cMvDHcMakNTNrHIW2I5f" 
			crossorigin="anonymous"></script>

	<script 
		src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js" 
		integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" 
		crossorigin="anonymous"></script>

	<script 
		src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js" 
		integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" 
		crossorigin="anonymous"></script>

	<link 
		rel="stylesheet" 
		href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" 
		integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" 
		crossorigin="anonymous">
	<link
		rel="stylesheet"
		href="./assets/monitor-demo.css">
</head>
<body>
	<h3>Hibernate Request Statistics Monitor - DEMO App</h3>
	<div id="layout">
		<cfoutput>
			<nav>
				#view("nav/requestNavigation")#
			</nav>
			<div id="content">
				#body#
			</div>
		</cfoutput>
	</div>
</body>
</html>