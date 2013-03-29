<cfset runEvent( event= "viewlets.filterPredefinedDateRange" , private= true ) />
<cfoutput>
<!---

<p>
<label for= "PredefinedRange">Predefined</label>
<select name= "PredefinedRange" id= "PredefinedRange">
	<option></option>
	<cfloop query= "rc.oPredefinedDateRange.query">
	<option value="#Period#"
	<cfif rc.PredefinedRange eq Period>selected= "selected" </cfif>>#PeriodDesc#</option>
	</cfloop>

</select>

</p>
 --->

<div id= "dates">
<p>
<label for= "sStartDate">Start Date</label>
<input type= "text"
	name= "sStartDate" id= "sStartDate"
	value= "#rc.sStartDate#" />

</p>

<p>
<label for= "sEndDate">End Date</label>
<input type= "text"
	name= "sEndDate" id= "sEndDate"
	value= "#rc.sEndDate#" />

</p>

</div>
<script>
$(document).ready(function() {

	oDateRange= #rc.oPredefinedDateRange.json#;
	$( "##sPredefinedRange" ).change( function () {
		var sPeriod= $( this ).val();
		$.cookie( "sPredefinedRange" , $( this ).val() );

		$.each( oDateRange.DATA , function( index , value ) {
			if( sPeriod == value[ 0 ] ) {
				$( "##sStartDate" ).val( value[ 2 ] ).change();
				$( "##sEndDate" ).val( value[ 3 ] ).change();

			}

		} );

	} );

	$( "##sStartDate" ).change( function() {
		$.cookie( "sStartDate" , $( this ).val() );

	} );

	$( "##sEndDate" ).change( function() {
		$.cookie( "sEndDate" , $( this ).val() );

	} );

} );
</script>
</cfoutput>