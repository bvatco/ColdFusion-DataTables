<cfset runEvent( event= "viewlets.filterPredefinedDateRange" , private= true ) />
<cfoutput>

<cfif structKeyExists( rc , "id" )  and rc.id eq "print">
	<cfif len( rc.sStartDate ) or len( rc.sEndDate )>
<div class= "section">

	<cfif len( rc.sStartDate )>
		<h4>Start Date</h4>
		#rc.sStartDate#

	</cfif>

	<cfif len( rc.sEndDate )>
		<h4>End Date</h4>
		#rc.sEndDate#

	</cfif>

</div>
	</cfif>


	<cfsavecontent variable= "hidden">

	<input type= "hidden"
		name= "sStartDate" id= "sStartDate"
		value= "#rc.sStartDate#" />

	<input type= "hidden"
		name= "sEndDate" id= "sEndDate"
		value= "#rc.sEndDate#" />

	</cfsavecontent>

	<cfif structKeyExists( variables , "hiddenFields" )>
		<cfset hiddenFields &= hidden />

	<cfelse>
		#hidden#

	</cfif>

<cfelse>

<div class= "section">


		<p>
		<label for= "sPredefinedRange">Predefined Range</label>
		<select name= "sPredefinedRange" id= "sPredefinedRange">
			<option></option>
			<cfloop array= "#rc.stPredefinedDateRange.DATA#"
					index=	"rc.aDateRange">
				<cfset	Period=		rc.aDateRange[ 1 ] />
				<cfset	PeriodDesc=	rc.aDateRange[ 2 ] />
			<option value="#Period#"
			<cfif rc.PredefinedRange eq Period>selected= "selected" </cfif>>#PeriodDesc#</option>
			</cfloop>

		</select>

		</p>

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

	oDateRange= #rc.oPredefinedDateRange.sJSON#;
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

	<!--- TODO: Add to Model --->
	<cfset sMinDate= dateFormat( dateAdd( "m" , "-6" , now() ) , "YYYY , M - 1 , D" ) />
	<cfset sMaxDate= dateFormat( now() , "YYYY , M - 1 , D" ) />

	var daMinDate= new Date( #sMinDate# );
	var sMinDate= ( daMinDate.getMonth() + 1 ) + '/' + daMinDate.getDate() + '/' + daMinDate.getFullYear();

	var daMaxDate= new Date( #sMaxDate# );
	var sMaxDate= ( daMaxDate.getMonth() + 1 ) + '/' + daMaxDate.getDate() + '/' + daMaxDate.getFullYear();

	var reDateYearMonthDay= new RegExp(
		'^((20)\\d\\d|\\d\\d)([- /.])(0[1-9]|1[012]|[1-9])\\3(0[1-9]|[12][0-9]|3[01]|[1-9])$' );

	var reDateMonthDayYear= new RegExp(
		'^(0[1-9]|1[012]|[1-9])([- /.])(0[1-9]|[12][0-9]|3[01]|[1-9])\\2((20)\\d\\d|\\d\\d)$' );

	var reDateDayMonthYear= new RegExp(
		'^(0[1-9]|[12][0-9]|3[01]|[1-9])([- /.])(0[1-9]|1[012]|[1-9])\\2((20)\\d\\d|\\d\\d)$' );

	function validateDateRange(){

		// Date Validation
		if( reDateYearMonthDay.test( $( "##sStartDate").val() ) == false
			&& reDateMonthDayYear.test( $( "##sStartDate").val() ) == false
			&& reDateDayMonthYear.test( $( "##sStartDate").val() ) == false )
			$( "##sStartDate").val( "" );

		if( reDateYearMonthDay.test( $( "##sEndDate").val() ) == false
			&& reDateMonthDayYear.test( $( "##sEndDate").val() ) == false
			&& reDateDayMonthYear.test( $( "##sEndDate").val() ) == false )
			$( "##sEndDate").val( "" );

		// Min & Max Validation
		var daStart= Date.parse( $( "##sStartDate").val() );
		if( daStart > daMaxDate )
			$( "##sStartDate").val( sMaxDate );

		else if( daStart < daMinDate )
			$( "##sStartDate").val( sMinDate );

		var daEnd= Date.parse( $( "##sEndDate").val() );
		if( daEnd > daMaxDate )
			$( "##sEndDate").val( sMaxDate );

		else if( daEnd < daMinDate )
			$( "##sEndDate").val( sMinDate );

		daStart= Date.parse( $( "##sStartDate").val() );
		daEnd= Date.parse( $( "##sEndDate").val() );

		if( daEnd < daStart ) {
			$( "##sEndDate").val( $( "##sStartDate").val() );
			daEnd= Date.parse( $( "##sEndDate").val() );

		}

		// Update Datepicker
		if( daStart == null )
			$( "##sStartDate").datepicker( "setDate" , daStart );

		if( daEnd == null )
			$( "##sEndDate").datepicker( "setDate" , daEnd );

	}

	function customDateRange( input ) {
		validateDateRange();

		var daStart= $( "##sStartDate" ).datepicker( "getDate" );
		var daEnd= $( "##sEndDate" ).datepicker( "getDate" );
		var sEndDate= $( "##sEndDate" ).val();
		var sID= input.id;

		var daResultMinDate= daMinDate;
		var daResultMaxDate= daMaxDate;

		if( sID == 'sEndDate' )
			daResultMinDate= daStart;

		if( sID == 'sStartDate'
			&& sEndDate != ""
			&& daEnd < daMaxDate )
			daResultMaxDate= daEnd;

		return {
			"minDate": daResultMinDate ,
			"maxDate": daResultMaxDate

		}

	}


	$.datepicker.setDefaults( {
		"minDate": daMinDate ,
		"maxDate": daMaxDate

	} );


	$( "##sStartDate" ).datepicker( { "beforeShow": customDateRange } );
	$( "##sEndDate" ).datepicker( { "beforeShow": customDateRange } );

	$( "##sStartDate" ).change( function() {
		validateDateRange();
		$.cookie( "sStartDate" , $( this ).val() );

	} );

	$( "##sEndDate" ).change( function() {
		validateDateRange();
		$.cookie( "sEndDate" , $( this ).val() );

	} );

} );
</script>

</cfif>

</cfoutput>