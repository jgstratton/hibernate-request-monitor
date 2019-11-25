<cfset service = application.beanfactory.getBean("sampleRequestService")>

<cfoutput>
	<div  class="nav-item"><a href="/plugins/hibernateRequestMonitor/index.cfm" target="_blank">View Log</a></div>
	<hr>
	<cfloop index="link" array="#service.getSampleRequestsArray()#">	
		<div class="nav-item"><a href="#link.path#">#link.name#</a></div>
	</cfloop>
	
</cfoutput>
