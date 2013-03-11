component	name=		"DataTableStoredProcedureService"
			output=		"false"
			accessors=	"true"
			hint=		"I am a stored procedure service for a DataTable page" {

	property	name=	"storedProcedureName";
	property	name=	"astProcedureParameters";
	property	name=	"lsColumnsToExcludeFromExport";
	property	name=	"lsColumnNamesForExcelExport";

	include	"scrubRequestHelper.cfm";

	function init (	storedProcedureName ,
					astProcedureParameters ,
					lsColumnsToExcludeFromExport ,
					lsColumnNamesForExcelExport ) {
		setStoredProcedureName( storedProcedureName );
		setASTProcedureParameters( astProcedureParameters );
		setLSColumnsToExcludeFromExport( lsColumnsToExcludeFromExport );
		setLSColumnNamesForExcelExport( lsColumnNamesForExcelExport );

		return	this;
	}

	function	getQuery () {
		var	sp=	new StoredProc();
			sp.setProcedure( getStoredProcedureName() );
			sp.setDataSource( application.DSN );
			sp.addProcResult(	name=		"rs1" ,
								resultset=	1 );

		var	stResult=	{};

		if( IsArray( getASTProcedureParameters() ) ) {
			var	astProcedureParameters=	getASTProcedureParameters();
			for( var stProcedureParameter in astProcedureParameters ) {
				stProcedureParameter=	grimRequestStructure( stProcedureParameter , false );

				param	name=	"stProcedureParameter.type"
						default=	"in";
				param	name=	"stProcedureParameter.null"
						default=	"false";

				if(	stProcedureParameter.type eq "in" ) {
					sp.addParam(	cfsqltype=	stProcedureParameter.cfsqltype ,
									type=		stProcedureParameter.type ,
									value=		stProcedureParameter.value ,
									null=		stProcedureParameter.null );

				}
				else {
					sp.addParam(	cfsqltype=	stProcedureParameter.cfsqltype ,
									type=		stProcedureParameter.type ,
									variable=	stProcedureParameter.variable ,
									null=		stProcedureParameter.null );

					stResult[ "#stProcedureParameter.variable#" ]=	"";

				}

			}

		}

		sp=	sp.execute();

		stResult.qResult=		sp.getProcResultSets().rs1;
		var	stProcOutVariables=	sp.getProcOutVariables();

		for(	var	stKey in stResult ) {
			if( stKey != "qResult" )
				stResult[ stKey ]=	stProcOutVariables[ stKey ];

		}

		return	stResult;
	}


	function	json ( stParameters ) {
		var	oDataTableService=	createObject( "lib.orangexception.ColdFusionDataTables.DataTableService" );
		var stResult=	getQuery( argumentCollection= arguments );

		return	oDataTableService.toJSON( stParameters , stResult.qResult );
	}

	function	excel ( stParameters ) {
		var	oDataExportService=	createObject( "app.models.service.DataExportService" ).initWithoutArguments();
		var	stResult=	prepareForExport( argumentCollection=	arguments );
			stResult.oResult.sContent=
				oDataExportService.QueryToExcel(
					Query=			stResult.qResult ,
					ColumnList=		stParameters.sColumns ,
					ColumnNames=	getLSColumnNamesForExcelExport() );

		return stResult.oResult;
	}

	function	CSV ( stParameters ) {
		var	oDataExportService=	createObject( "app.models.service.DataExportService" ).initWithoutArguments();
		var	stResult=	prepareForExport( argumentCollection=	arguments );
			stResult.oResult.sContent=
				oDataExportService.QueryToCSV(
					Query=				stResult.qResult ,
					Fields=				stParameters.sColumns ,
					Delimiter=			"," ,
					CreateHeaderRow=	false );

		return stResult.oResult;
	}

	function	tabDelimited ( stParameters ) {
		var	oDataExportService=	createObject( "app.models.service.DataExportService" ).initWithoutArguments();
		var	stResult=	prepareForExport( argumentCollection=	arguments );

			stResult.oResult.sContent=
				oDataExportService.QueryToCSV(
					Query=				stResult.qResult ,
					Fields=				stParameters.sColumns ,
					Delimiter=			"	" ,
					CreateHeaderRow=	false );

		return stResult.oResult;
	}

	function	pipeDelimited ( stParameters ) {
		var	oDataExportService=	createObject( "app.models.service.DataExportService" ).initWithoutArguments();
		var	stResult=	prepareForExport( argumentCollection=	arguments );
			stResult.oResult.sContent=
				oDataExportService.QueryToCSV(
					Query=				stResult.qResult ,
					Fields=				stParameters.sColumns ,
					Delimiter=			"|" ,
					CreateHeaderRow=	false );

		return stResult.oResult;
	}

	function	prepareForExport ( stParameters ) {
		var	oDataTableService=	createObject( "lib.orangexception.ColdFusionDataTables.DataTableService" );
		var oResult=	new	app.models.service.ResultService();
			oResult=	oResult.new();
		var	stResult=	getQuery( argumentCollection= arguments );
		var	qResult=	oDataTableService.toQuery( stParameters , stResult.qResult );

		var	lsColumnsToExcludeFromExport=	ListChangeDelims( getLSColumnsToExcludeFromExport() , "|,?" );

		if( len( lsColumnsToExcludeFromExport ) )
			stParameters.sColumns=
				stParameters.sColumns
					.ReplaceAll( ",?" & lsColumnsToExcludeFromExport , "" );

		var	asColumns=		ListToArray( stParameters.sColumns );
		var	iColumnCount=	ArrayLen( asColumns );
		for(	var	iCurrentRow=	1;
				iCurrentRow <= qResult.RecordCount;
				iCurrentRow++ ) {
			for(	var	iCurrentColumn=	1;
					iCurrentColumn <= iColumnCount;
					iCurrentColumn++ ) {
				QuerySetCell(	qResult ,
								asColumns[ iCurrentColumn ] ,
								grimVariable( qResult[ asColumns[ iCurrentColumn ] ][ iCurrentRow ] ) ,
								iCurrentRow );



			}

		}

		oResult.qResult=	qResult;
		stResult=	{	oResult=	oResult ,
						qResult=	qResult };

		return	stResult;
	}

}