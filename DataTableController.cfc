component	name=		"DataTableController"
			output=		"false"
			accessors=	"true"
			extends=	"coldbox.system.EventHandler"
			hint=		"I am a controller for a DataTable page" {

	property	name=	"DataTableService";
	property	name=	"layout";
	property	name=	"view";
	property	name=	"exportFileNamePrefix";
	property	name=	"PDFExportEvent";

	function init (	controller ,
					oDataTableService ,
					layout ,
					view ,
					PDFExportEvent=	"" ,
					exportFileNamePrefix=	CreateUUID() ) {
		super.init( controller );

		setDataTableService( oDataTableService );
		setLayout( layout );
		setView( view );
		setPDFExportEvent( PDFExportEvent );
		setExportFileNamePrefix( exportFileNamePrefix );

		return	this;
	}

	function index ( Event ) {
		var	rc=	Event.getCollection();

		Event.paramValue( "id" , "" );
		if( rc.id eq "json" )
			return	json( Event );

		else if( rc.id eq "export" )
			return	export( Event );

		Event.setLayout( getLayout() );
		Event.setView( getView() );

	}


	function	json ( Event ) {
		var	rc=	Event.getCollection();
			rc.stParameters=	duplicate( rc );
			rc.sJSON=
				getDataTableService().json( argumentCollection= rc );

		Event.setLayout(	"json" );
		Event.setView(		"json" );

	}

	function	export ( Event ) {
		var rc= Event.getCollection();
			rc.iDisplayLength=		-1;
			rc.iDisplayStart=		0;
			rc.stParameters=		duplicate( rc );
			rc.oResult.sContent=	'';
			rc.sExportType=			replace( rc.sExportType , " slvzr-hover" , "" );

		if( rc.sExportType == "Excel" ) {
			rc.oResult= 	getDataTableService().Excel( argumentCollection= rc );
			rc.sContent=	rc.oResult.sContent.sFilename;

			Event.setLayout( "export" );

			return;
		}
		else if( rc.sExportType == "CSV" )
			rc.oResult= getDataTableService().CSV( argumentCollection= rc );

		else if( rc.sExportType == "TAB" )
			rc.oResult= getDataTableService().TabDelimited( argumentCollection= rc );


		else if( rc.sExportType == "PIPE" )
			rc.oResult= getDataTableService().PipeDelimited( argumentCollection= rc );

		else if( rc.sExportType == "PDF" ) {
			rc.FileName=	getExportFileNamePrefix();

			rc.oResult=		getDataTableService().prepareForExport( argumentCollection= rc );
			rc.qResult=		rc.oResult.qResult;

			Event.setLayout( "Layout_nomenu1" );
			return	Event.setView( getPDFExportEvent() );
		}

		rc.sContent= rc.oResult.sContent;

		Event.setLayout( "export" );

	}


}