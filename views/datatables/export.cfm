<cfoutput>
<div class= "section" id= "export-data">
	<div class= "section">

	<form action= "#Event.buildLink( "#rc.event#&id=export" )#" method= "post"
			name= "exportForm" id= "exportForm">
		<div class= "nav" id= "export-options">
			<div class= "header"><h3>Export Data</h3></div>

			<p>
				<label	for=	"sExportType">
					Download Format

				</label>
				<select	name=	"sExportType"
						id=		"sExportType"
						style=	"width:	180px">
					<option	value=	"Excel">
						Excel

					</option>
					<option	value=	"CSV">
						CSV ( Comma Delimited )

					</option>
					<option	value=	"Tab">
						Tab Delimited

					</option>
					<option	value=	"PIPE">
						Pipe Delimited

					</option>
					<option	value=	"PDF">
						Acrobat PDF

					</option>

				</select>

			<a	href=	"##export"
				class=	"button-white"
				id=		"export-submit"
				data-role=		"button"
				data-inline=	"true">Export</a>

			</p>

		</div>


			#renderView( "DataTables/export-fields" )#

		</form>

	</div>
	<!---

	<div class= "section">
		<div class= "nav">
			<div class= "header"><h3>Print View</h3></div>
			<a href= "#Event.buildLink( "#rc.event#/print" )#"
				class= "print">Print</a>

		</div>

	</div>

	<div class= "section">
		<form action= "#Event.buildLink( "#rc.event#/export" )#" method= "POST">
			<div class= "section">
				<div class= "header"><h3>Export Report</h3></div>
				#renderView( "viewlets/export" )#
			</div>

		</form>

	</div>

	<div class= "section">
		<div class= "header"><h3>Print</h3></div>
		#renderView( "viewlets/print" )#
	</div>
	--->
	<div class= "clear"></div>

</div>
</cfoutput>


<script>
$( document ).ready( function(){

	$( "#export-options a" ).click( function() {

		$( "#export-custom-filters" ).html( "" );
		$(	"#filters select" ).each( function() {
			var	domFilter=	$( this );
			var	sValue=	domFilter.val();
			var	sName=	domFilter.data( "name" );

			//	Remove Prior Filters
			$( "#export-custom-filters input[name='" + sName + "']" ).remove();
			//	Set Current Filters
			$( "#export-custom-filters" ).append( '<input type="hidden" value="' + sValue + '" name="' + sName + '" />' );

		} );

		$( "#exportForm" ).submit();

		return false;

	} );

} );

</script>