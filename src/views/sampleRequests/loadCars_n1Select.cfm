<cfset cars = entityload("Car")>

This is an example of an N+1 Select issue Caused by referencing the related entities after the initial query was executed.
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