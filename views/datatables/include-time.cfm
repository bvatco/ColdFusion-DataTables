<cfset runEvent( event= "viewlets.filterIncludeTime" , private= true ) />
<cfoutput>
<div class= "section" id= "toggle">
	<div class= "header"><h3>Toggles</h3></div>

	<p>
	<input type= "checkbox"
		name= "bIncludeTime" id= "bIncludeTime"
		<cfif rc.bIncludeTime>checked= "checked" </cfif> />
	<label for= "bIncludeTime">Include Time</label>

	</p>

</div>

<script>
$(document).ready(function() {
	$( "##bIncludeTime" ).change( function() {
		$.cookie( "bIncludeTime" , $( this ).val() );

	} );

	$( "##bIncludeTime" ).val( $.cookie( "bIncludeTime" ) );

} );
</script>
</cfoutput>