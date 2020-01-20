<cfset requestMonitor = application.hibernateMonitor>
<cfset requestStatistics = requestMonitor.getRequestStatistics()>
<cfset hasExecutedQueries = requestMonitor.isFeatureSupported('executedQueries')>

<html>
<head>
	<cfoutput>
		<cfset path = requestMonitor.getClientPath()>

		<script
			src="https://code.jquery.com/jquery-3.4.1.min.js"
			integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo="
			crossorigin="anonymous"></script>

		<script 
			src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js" 
			integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" 
			crossorigin="anonymous"></script>

		<script 
			src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js" 
			integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" 
			crossorigin="anonymous"></script>

		<script 
			src="https://cdnjs.cloudflare.com/ajax/libs/jquery-jgrowl/1.4.6/jquery.jgrowl.min.js" 
			integrity="sha256-n9wTGJrOSb/K8c7f+uyeiKukiyYhBzCvSc0Yk/JwrJg=" 
			crossorigin="anonymous"></script>

		<link 
			rel="stylesheet" 
			href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" 
			integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" 
			crossorigin="anonymous">

		<link 
			rel="stylesheet" 
			href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.11.2/css/all.css" 
			integrity="sha256-46qynGAkLSFpVbEBog43gvNhfrOj+BmwXdxFgVK/Kvc=" 
			crossorigin="anonymous" />
		
		<link 
			rel="stylesheet" 
			href="https://cdnjs.cloudflare.com/ajax/libs/jquery-jgrowl/1.4.6/jquery.jgrowl.min.css" 
			integrity="sha256-rRGO8pY78yb6wxrYHTrqfv0moskCfq+kv9GLCfE/1oc=" 
			crossorigin="anonymous" />

		<script type="text/javascript" src="#path#/assets/monitor.js"></script>

		<link href="#requestMonitor.getClientPath()#/assets/monitor.css" rel="stylesheet">

	</cfoutput>
</head>
<body>
	<h3>Hibernate Request Statistics Monitor</h3>
	<cfoutput>
		<cfloop index="error" array="#requestMonitor.getErrors()#">
			<div class="alert alert-danger">#error.message#</div>
		</cfloop>
		<div class="content-body">
			<div class="row">
				<div class="col-sm-5">
					<div class="card">
						<div class="card-header">Request Log</div>
						<div class="panel-resizable" style="height:700px">
							<table class="table table-condensed ACTIVE" id="requestLog">
								<thead>
									<tr>
										<th></th>
										<th>Request</th>
										<th></th>
										<th></th>
									</tr>
								</thead>
								<tbody>
									<cfloop from="#requestStatistics.len()#" to="1" index="i" step="-1">
										<cfset requestStatistic = requestStatistics[i]>
										<tr 
											data-request-id="#requestStatistic.getRequestId()#"
											data-collisions="#requestStatistic.getCollisions().len()#">
											<td>#i#</td>
											<td>
												#requestStatistic.getRequestName()#
												<cfif requestStatistic.getCollisions().len()>
													<div class="alert alert-warning collision-warning">
														<i class="fa fa-exclamation-triangle"></i> #requestStatistic.getCollisions().len()# overlapping requests.
														<ul>
															<cfloop index="collisionRequest" array="#requestStatistic.getCollisions()#">
																<li>#collisionRequest#</li>
															</cfloop>
														</ul>
													</div>
												</cfif>
											</td>
											<td class="text-right">#requestStatistic.getRequestTime()# ms</td>
											<td>
												<table class="stats-table pull-right">
													<tr>
														<td>Fetches</td>
														<td class="text-right">#requestStatistic.getTotalFetchCount()#</td>
													</tr>
													<tr>
														<td>Loads</td>
														<td class="text-right">#requestStatistic.getTotalLoadCount()#</td>
													</tr>
													<tr>
														<td>HQL Statistics</td>
														<td class="text-right" data-fetch="queryStatistics" data-count="#requestStatistic.getOrmQueryStatistics().len()#"></td>
													</tr>
													<tr>
														<td>Entity Statistics</td>
														<td class="text-right" data-fetch="entityStatistics" data-count="#requestStatistic.getEntityStatistics().len()#"></td>
													</tr>
													<cfif hasExecutedQueries>
														<tr>
															<td>Executed Queries</td>
															<td class="text-right" data-fetch="executedQueries" data-count="#requestStatistic.getExecutedQueries().recordcount#"></td>													
														</tr>
													</cfif>
												</table>
											</td>
										</tr>
									</cfloop>
								</tbody>
							</table>
						</div>
					</div>
				</div>
				<div class="col-sm-7">
					<div class="row">
						<div class="col-sm-12">
							<div class="card">
								<div class="card-header">HQL Statistics</div>
								<div class="panel-resizable" id="queryStatistics">
								</div>
							</div>
						</div>
						<div class="col-sm-12" id="loadedStats">
							<div class="card">
								<div class="card-header">Entity Statistics</div>
								<div class="panel-resizable" id="entityStatistics">
								</div>
							</div>
						</div>
						<cfif hasExecutedQueries>
							<div class="col-sm-12" id="loadedStats">
								<div class="card">
									<div class="card-header">Executed Queries</div>
									<div class="panel-resizable" id="executedQueries">
									</div>
								</div>
							</div>
						</cfif>
					</div>
				</div>	
			</div>
		</div>	
	</cfoutput>
	
	<div class="modal" id="sqlViewModal">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<h4 class="modal-title">View SQL</h4>
					<button type="button" class="close" data-dismiss="modal">&times;</button>
				</div>
				<div class="modal-body">
					<span id="sqlCopyBtn" class="btn btn-primary btn-sm float-right"><i class="fas fa-copy"></i> Copy SQL</span>
					<pre id="sqlCodeView"></pre>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-danger" data-dismiss="modal">Close</button>
				</div>
			</div>
		</div>
	</div>

	<script>
		var clientUrl = '';
		var url = <cfoutput>'#requestMonitor.getClientPath()#/index.cfm'</cfoutput>;

		$("[data-request-id]").each(function(){
			var $tr = $(this);
			var requestId = $tr.data('requestId');
			var fetches = [];
			var skipfetch = [];
				
			$tr.find("[data-fetch]").each(function(){
				$td = $(this);
				if ($td.data('count') > 0) {
					$(this).html($td.data('count'));
						fetches.push($td.data('fetch'));
				} else {
					$td.html('---');
					skipfetch.push($td.data('fetch'));
				}
			});

			$tr.on("click", function(){
				for (var i = 0; i < fetches.length; i++) {
					fetchStatistics(requestId, fetches[i], $("#" + fetches[i]));
				}
				for (var i = 0; i < skipfetch.length; i++) {
					$("#" + skipfetch[i]).html('(no data)');
				}
			});
		});

		$("#sqlCopyBtn").on("click", function(){
			if (copyToClipboard($("#sqlCodeView"))) {
				$.jGrowl("SQL Copied");
			} else {
				$.jGrowl("Failed to copy SQL");
			}
		});

		$("body").on("click", ".sqlLink", function(){
			showSql($(this));
		});

		function fetchStatistics(requestId, type, $element) {
			$.ajax({
				url:url,
				data: {
					api: type,
					requestId: requestId
				},
				success: function(response) {
					$element.html('');
					$element.append(createTable(response.data));
				},
				error: function(jqXhr, textStatus, errorThrown) {
					alert(errorThrown);
				}
			});
		}

		function createTable(data) {
			if (data.length > 0) {
				var $table = $("<table></table>").addClass('table').addClass('loaded-data').addClass('table-condensed');
				var $tbody = $("<tbody></tbody>");
				var $thead = $("<thead></thead>");
				var $theadRow = $("<tr></tr>");
				var keys = [];
				for( var key in data[0]) {
					keys.push(key);		
					$theadRow.append($("<th></th>").html(key));
					$thead.append($theadRow);
				}
				for( var i = 0; i < data.length; i++) {
					var item = data[i];
					var $tr = $("<tr></tr>");
					for( var j = 0; j < keys.length; j++) {
						var key = keys[j];
						var $td = $("<td></td>");
						var $content = $("<div class='data-div'></div>");

						if (stringContainsSql(item[key])) {
							var $sqlLink = $('<span class="btn btn-link sqlLink p-0"><i class="far fa-file-code"></i> SQL</span>');
							$sqlLink.data('sql',item[key]);
							$content.html($sqlLink);	
						} else {
							$content.html(formatTableCell(item[key]));
						}

						$td.append($content);
						$tr.append($td);
					}
					$tbody.append($tr);
				}
				$table.append($thead).append($tbody);
				return $table;
			}
			return '';
		}

		function showSql($sqlLink) {
			$("#sqlViewModal").modal('show');
			$("#sqlCodeView").html($sqlLink.data('sql'));
		}
	</script>
</body>
</html>