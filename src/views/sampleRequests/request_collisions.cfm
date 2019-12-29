<cfif !form.keyExists('collisionRequest') >

	<cfscript>
		sampleRequestService = new models.services.sampleRequestService();
		thisUrl = samplerequestService.getUrlFromFileName('request_collisions.cfm');
	</cfscript>

	<p>
		Since the hibernate statistics are cumulative, and this tool is designed to keep track of 
		orm stats by request, we need to reset the statistics for each request.  However, since 
		multiple requests can occur at the same time even in a single user environment, this tool will
		keep track of overlapping request so that you can take this into consideration when debugging.	
	</p>

	<p>
		Use the below form to simulate overlapping requests, then view the results in the log.
	</p>
	
	<cfoutput>
		<form id="frmCollisionCreator" action="#thisurl#" method="post">
			<input type="hidden" name="collisionRequest" value="let's try to break stuff">
			<input type="input" name="sleep" value="3"> Request time (seconds)
			<input type="submit" value="submit">
		</form>
		<div id="results">
	
		</div>
	</cfoutput>
	
	<script>

		$("#frmCollisionCreator").submit(function(){
			var $currentRequest = $("<div></div>");
			$currentRequest.html('started');
			$("#results").append($currentRequest);
			$.ajax({
				url:$(this).action,
				data:$(this).serialize(),
				method: 'POST',
				success: function(){
					$currentRequest.html('finished');
				}
			});
			return false;
		});
	
	</script>

	
<cfelse>

	<cfscript>
		staff = entityload("Staff");
		if (form.keyExists('sleep')) {
			sleep(form.sleep * 1000);
		}
	</cfscript>

</cfif>


