<cfset staff = entityload("Staff")>

<cfoutput>
	#staff.len()# staff were loaded.
</cfoutput>