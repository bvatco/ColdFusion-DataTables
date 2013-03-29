<!---	Viewlet	--->
<cfset runEvent( event= "viewlets.filterCustomer" , private= true ) />

<cfoutput>
<!---	Print View?	--->
<cfif	structKeyExists( rc , "id" )
	and	rc.id eq "print">
	<cfif len( rc.sCustomer )>
		<div class= "section">
			<div class= "header"><h3>Customer</h3></div>

			<h4>Customer Name</h4>
			#rc.sCustomer#

		</div>

	</cfif>

	<cfsavecontent variable= "hidden">
		<input type= "hidden"
			name= "sCustomer" id= "sCustomer"
			value= "#rc.Customer#" />

	</cfsavecontent>

	<cfif structKeyExists( variables , "hiddenFields" )>
		<cfset hiddenFields &= hidden />

	<cfelse>
		#hidden#

	</cfif>

<!---	Standard View	--->
<cfelse>
	<div class= "section">
		<div class= "header"><h3>Customer</h3></div>

		<p>
		<label for= "sCustomer">Name</label>
		<input type= "text"
			name= "sCustomer" id= "sCustomer"
			value= "#rc.sCustomer#" />

		</p>

	</div>

	<script>
	$(document).ready(function() {
		$( "##sCustomer" ).change( function() {
			$.cookie( "sCustomer" , $( this ).val() );

		} );

	} );
	</script>

</cfif>

</cfoutput>