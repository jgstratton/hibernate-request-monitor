<cfset cars = ormExecuteQuery("
	FROM Car c 
	LEFT JOIN FETCH c.Category
	LEFT JOIN FETCH c.Images")>

This is a fix for the N+1 Select using a join fetch.
<cfoutput>
	<cfloop index="car" array="#cars#">
		<cfset images = car.getImages()>
		<div>
			Car #car.getCarID()# has category id of #car.getCategory().getCategoryID()# #images.len()# images.
			<cfloop index="images" array="#images#">
				#images.getPath()#
			</cfloop>
		</div>
		<hr>
	</cfloop>
</cfoutput>