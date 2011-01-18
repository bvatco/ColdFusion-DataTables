<!---
Author:
	Bradley Moore
	orangexception.com
	@orangexception on Twitter

Description:
	ColdFusion Server Methods for DataTables
	See http://www.datatables.net/usage/server-side for more details.

Language Support:
	CF8
	Railo 3.1

DataTableService.cfc Usage:
	// Single model result, Controller determines how to use the data
	qExample= oModel.getQuery();
	oDataTableResult= oDataTableService.toObject( stParameters , qExample );

	if( request.bAJAX )
		sJSON= oResult.toJSON();

	else
		qExample= oResult.toQuery();

	--
	// Straight conversion to JSON
	qExample= oModel.getQuery();
	sJSON= oDataTableService.toJSON( stParameters , qExample );

	--
	// Sort and Search a query using DataTable parameters
	qExample= oModel.getQuery();
	qExample= oDataTableService.toQuery( stParameters , qExample );

History:
	2011.1.17	Foundation

--->

<cfcomponent displayname= "DataTableService"
	output= false
	hint= "Handles server interactions for DataTables">

	<cffunction name= "toObject"
		output= false
		hint= "I convert Parameters and Query arguments into an object, which let's you export data into types later.  I am useful for outputting data based upon url variables.">

		<cfargument name= "Parameters"
			required= true
			hint= "I am a structure of unmodified parameters from a DataTables event.  I'll handle converting these into a more useful collection." />

		<cfargument name= "Query"
			required= true
			hint= "I am the query on which I perform actions." />

		<cfscript>
		var oResult= "";
		var stParameters= "";
		var qResult= "";

		stParameters= convertParameters( Parameters );

		//Total Records prior to manipulation
		stParameters.iTotalRecords= Query.recordCount;

		qResult= searchAndSortQuery( stParameters , Query );

		//Total Records of searched result
		stParameters.iTotalDisplayRecords= qResult.recordCount;

		oResult= createObject( "component" , "DataTableObject" ).init( stParameters , qResult );
		return oResult;

		</cfscript>

	</cffunction>

	<cffunction name= "toQuery"
		output= false
		hint= "I search and sort a Query based upon DataTables Parameters, which is useful for exporting data.">

		<cfargument name= "Parameters"
			required= true
			hint= "I am a structure of unmodified parameters from an event.  I'll handle converting these into a more useful collection." />

		<cfargument name= "Query"
			required= true
			hint= "I am the query on which I perform actions." />

		<cfscript>
		return toObject( argumentCollection= arguments ).toQuery();

		</cfscript>

	</cffunction>

	<cffunction name= "toJSON"
		output= false
		hint= "I convert Parameters and Query arguments into DataTables JSON Format">

		<cfargument name= "Parameters"
			required= true
			hint= "I am a structure of unmodified parameters from an event.  I'll handle converting these into a more useful collection." />

		<cfargument name= "Query"
			required= true
			hint= "I am the query on which I perform actions." />

		<cfscript>
		return toObject( argumentCollection= arguments ).toJSON();

		</cfscript>

	</cffunction>

	<cffunction name= "convertParameters"
		output= false
		access= "private"
		hint= "I convert unmodified Parameters into a more useful collection.">

		<cfargument name= "Parameters"
			required= true
			hint= "I am a structure of unmodified parameters from a DataTables event." />

		<cfscript>
		//See http://www.datatables.net/usage/server-side for more details.

		var iPosition= 1;
		var stColumn= "";
		var stParameters= "";
		var stSortingColumn= "";

		stParameters= {
			iDisplayStart= Parameters.iDisplayStart ,
			iDisplayLength= Parameters.iDisplayLength ,
			sColumns= Parameters.sColumns ,
			iColumns= Parameters.iColumns ,
			sSearch= Parameters.sSearch ,
			columns= [] ,
			iSortingCols= Parameters.iSortingCols ,
			sortingColumns= [] ,
			sEcho= Parameters.sEcho

		};

		if( structKeyExists( Parameters , "bEscapeRegex" ) )
			stParameters.bEscapeRegex= Parameters.bEscapeRegex;

		if( len( Parameters.sColumns ) ) {
			// Build Columns
			for( iPosition= 0; iPosition < Parameters.iColumns && listLen( Parameters.sColumns ) >= iPosition ; iPosition++ ) {

				if( structKeyExists( Parameters , "bSortable_#iPosition#" ) eq 0 )
					Parameters[ "bSortable_#iPosition#" ]= "";

				if( structKeyExists( Parameters , "bSearchable_#iPosition#" ) eq 0 )
					Parameters[ "bSearchable_#iPosition#" ]= "";

				if( structKeyExists( Parameters , "sSearch_#iPosition#" ) eq 0 )
					Parameters[ "sSearch_#iPosition#" ]= "";

				stColumn= {
					name= listGetAt( Parameters.sColumns , iPosition + 1 ) ,
					bSortable= Parameters[ "bSortable_#iPosition#" ] ,
					bSearchable= Parameters[ "bSearchable_#iPosition#" ] ,
					sSearch= Parameters[ "sSearch_#iPosition#" ]

				};

				if( structKeyExists( Parameters , "bEscapeRegex_#iPosition#" ) )
					stColumn.bEscapeRegex= Parameters[ "bEscapeRegex_#iPosition#" ];

				if( structKeyExists( Parameters , "iSortCol_#iPosition#" ) )
					stColumn.iSortCol= Parameters[ "iSortCol_#iPosition#" ];

				if( structKeyExists( Parameters , "sSortDir_#iPosition#" ) )
					stColumn.sSortDir= Parameters[ "sSortDir_#iPosition#" ];

				arrayAppend( stParameters.columns , duplicate( stColumn ) );

			}

			// Build SortingColumns
			for( iPosition= 0; iPosition < Parameters.iSortingCols ; iPosition++ ) {
				if( structKeyExists( Parameters , "iSortCol_#iPosition#" ) ) {
					stSortingColumn= {
						name= listGetAt( Parameters.sColumns , Parameters[ "iSortCol_#iPosition#" ] + 1 ) ,
						dir= Parameters[ "sSortDir_#iPosition#" ]

					};
					arrayAppend( stParameters.sortingColumns , duplicate( stSortingColumn ) );

				}

			}

		}

		return stParameters;

		</cfscript>

	</cffunction>

	<cffunction name= "searchAndSortQuery"
		output= false
		access= "private"
		hint= "I search and sort a Query based upon DataTables Parameters">

		<cfargument name= "stParameters"
			required= true
			output= false
			hint= "I am the result from my convertParameters function." />

		<cfargument name= "Query"
			required= true
			output= false
			hint= "I am the query on which I perform actions." />

		<cfscript>
		var bFirstColumn= true;
		var iColumnPosition= 0;
		var iSortingColumnCount= 1;
		var lsColumnNames= "";
		var qResult= "";
		var sColumnName= "";
		var sOrderBy= "";
		var stSearchColumn= "";
		var stSortingColumn= "";

		lsColumnNames= Query.columnList;

		if( len( stParameters.sColumns ) == 0 )
			stParameters.sColumns= lsColumnNames;

		</cfscript>

		<cfsavecontent variable= "sOrderBy">
		<cfoutput>
		<cfif len( stParameters.iSortingCols )
			and stParameters.iSortingCols
			and arrayLen( stParameters.sortingColumns )>

			<cfloop array= "#stParameters.sortingColumns#" index= "stSortingColumn">
				<cfif listFindNoCase( lsColumnNames , stSortingColumn.name )>
					#stSortingColumn.name#
					<cfif listFindNoCase( stSortingColumn.dir , "DESC" )>DESC<cfelse>ASC</cfif>
					<cfif iSortingColumnCount lt stParameters.iSortingCols>,</cfif>
					<cfset iSortingColumnCount++ />

				</cfif>

			</cfloop>

		</cfif>
		</cfoutput>
		</cfsavecontent>
		<cfset sOrderBy= trim( sOrderBy ) />

		<cfquery name= "qResult" dbtype= "query">
		select
		<!--- Columns to display --->
			<cfloop list= "#stParameters.sColumns#" index= "sColumnName">
				<cfset iColumnPosition= listFindNoCase( lsColumnNames , sColumnName ) />
				<cfif iColumnPosition>
					<cfif bFirstColumn eq false>,</cfif>
					#sColumnName#
					<cfset bFirstColumn= false />

				</cfif>

			</cfloop>

		  from [Query]
		 where 1= 1 <!---  any  --->

		<!--- Search --->
		<cfif len( stParameters.sSearch )>
		and (
			1= 0 <!---  none  --->

			<cfloop array= "#stParameters.columns#" index= "stSearchColumn">
				<cfif listFindNoCase( lsColumnNames , stSearchColumn.name )>
				or CAST( lower( [#stSearchColumn.name#] ) AS VARCHAR ) like
					<cfqueryparam cfsqltype= "varchar" value= "%#lcase( stParameters.sSearch )#%" />

				</cfif>

			</cfloop>

		   )
		</cfif>

		<!--- Order --->
		<cfif len( sOrderBy )>
		order by #sOrderBy#
		</cfif>

		</cfquery>

		<cfreturn qResult />

	</cffunction>

</cfcomponent>