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
			<nav id= "exportOptions">
				<header><h3>Export Report</h3></header>

				<a href= "#Event.buildLink( "#rc.event#/export?sExportType=Excel" )#"
					class= "Excel">Excel</a>

				<a href= "#Event.buildLink( "#rc.event#/export?sExportType=CSV" )#"
					class= "CSV">CSV ( Comma Delimited )</a>

				<a href= "#Event.buildLink( "#rc.event#/export?sExportType=Tab" )#"
					class= "Tab">Tab Delimited</a>

			</nav>
			
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

<style>
#exportForm {
	display: none;

}

</style>

<form action= "#Event.buildLink( "#rc.event#/export" )#" method= "post"
	name= "exportForm" id= "exportForm">
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

</form>