<!---
Author
	Bradley Moore
	orangexception.com
	@orangexception on Twitter

Description
	ColdFusion Server Methods for DataTables
	See http://www.datatables.net/usage/server-side for more details on DataTables.
	See README for language support, usage, and history.

--->

<!---
Usage
	Include this page on same page as your DataTables table.

	Add the following code to the "fnServerData" function.
		// Update Export Filters
		$.each( aoData , function( index , value ) {
			$( "input[id=" + value.name + "]" ).val( value.value );

		} );

	Intercept export requests and submit #exportForm
		ColdBox Example
			<div class= "nav" id= "exportOptions">
				<div class= "header"><h3>Export Report</h3></div>

				<a href= "#Event.buildLink( "#rc.event#/export&sExportType=Excel" )#"
					class= "Excel">Excel</a>

				<a href= "#Event.buildLink( "#rc.event#/export&sExportType=CSV" )#"
					class= "CSV">CSV ( Comma Delimited )</a>

				<a href= "#Event.buildLink( "#rc.event#/export&sExportType=Tab" )#"
					class= "Tab">Tab Delimited</a>

			</div>

			<script>
			$( document ).ready( function(){
				// Intercept Export Requests
				$( "#exportOptions a" ).click( function() {
					$( "#sExportType" ).val( $( this ).attr( "class" ) );
					$( "#exportForm" ).submit();

					return false;

				} );

			} );

			</script>

--->
<cfoutput>
	<input type= "hidden"
		name= "sExportType" id= "sExportType" />

	<input type= "hidden"
		name= "sEcho" id= "sEcho" />

	<input type= "hidden"
		name= "iColumns" id= "iColumns" />

	<input type= "hidden"
		name= "sColumns" id= "sColumns" />

	<input type= "hidden"
		name= "iDisplayStart" id= "iDisplayStart" />

	<input type= "hidden"
		name= "iDisplayLength" id= "iDisplayLength" />

	<input type= "hidden"
		name= "sSearch" id= "sSearch" />

	<input type= "hidden"
		name= "bRegex" id= "bRegex" />

	<input type= "hidden"
		name= "iSortingCols" id= "iSortingCols" />


	<div	id=		"export-custom-filters"
			style=	"display:none;"></div>
	<div	id=		"export-custom-fields"
			style=	"display:none;"></div>

</cfoutput>

<script>
$( document ).ready( function(){
	$( ".dataTables_filter label input" ).change( onDataTableSearchFilterChangeHandler );
	onDataTableSearchFilterChangeHandler();

} );

function onDataTableSearchFilterChangeHandler () {
	$( "#sSearch" ).val(
		$( ".dataTables_filter label input" ).val() );

	if( typeof( oTable ) === "undefined" )
		return;

	var	aaSorting=	oTable.fnSettings().aaSorting;

	$( "#iSortingCols" ).val(	aaSorting.length );

	for(	var	iOuterRow=	0;
			iOuterRow < aaSorting.length;
			iOuterRow++ ) {
		if( $( "#exportForm input[name='iSortCol_" + iOuterRow + "']" ).length == 0 )
			$( "#exportForm" ).append( '<input	type=	"hidden"	name=	"iSortCol_' + iOuterRow + '" id=	"iSortCol_' + iOuterRow + '" />' )
		if( $( "#exportForm input[name='sSortDir_" + iOuterRow + "']" ).length == 0 )
			$( "#exportForm" ).append( '<input	type=	"hidden"	name=	"sSortDir_' + iOuterRow + '" id=	"sSortDir_' + iOuterRow + '" />' )

		$( "#iSortCol_" + iOuterRow ).val(	aaSorting[ iOuterRow ][ 0 ] );
		$( "#sSortDir_" + iOuterRow ).val(	aaSorting[ iOuterRow ][ 1 ] );

	}


}

</script>