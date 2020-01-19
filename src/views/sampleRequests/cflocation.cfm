<cfif url.keyExists('relocated')>
	Did you know that when you use cflocation that the "onRequestEnd" method is not called?  Instead, the "onAbort" function is called.
	Because of this, we need to call the "requestEnd" function from there too, otherwise the tool will keep waiting for the request to end.
	.... If you're seeing this message, then the request was reloacted using cflocation.	
<cfelse>
	<cflocation url="#buildUrl(action='sampleRequests.cflocation', queryString="relocated=true")#">
</cfif>
