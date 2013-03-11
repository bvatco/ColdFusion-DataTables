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

<cfcomponent displayname= "DataTableService"
	output= false
	hint= "Handles server interactions for DataTables">

	<cfinclude	template=	"scrubRequestHelper.cfm" />

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
		var aQueryMetaData= "";

		aQueryMetaData= getMetaData( Query );

		stParameters= convertParameters( Parameters );

		//Total Records prior to manipulation
		stParameters.iTotalRecords= Query.recordCount;

		qResult= searchAndSortQuery( stParameters , Query , aQueryMetaData );

		qResult= formatQuery( qResult , aQueryMetaData );

		//Total Records of searched result
		stParameters.iTotalDisplayRecords= qResult.recordCount;

		oResult= createObject( "component" , "DataTableObject" ).init( stParameters , qResult , aQueryMetaData );
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

		param	name=	"Parameters.iColumns"
				default=	"#ListLen( Parameters.sColumns )#";
		param	name=	"Parameters.sSearch"
				default=	"";
		param	name=	"Parameters.sEcho"
				default=	"";
		param	name=	"Parameters.iSortingCols"
				default=	"0";

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

		if( len( Parameters.iColumns ) == 0 )
			Parameters.iColumns=	ListLen( Parameters.sColumns );

		if( len( Parameters.sColumns ) ) {
			// Build Columns
			for( iPosition= 0; iPosition < Parameters.iColumns && listLen( Parameters.sColumns ) > iPosition ; iPosition++ ) {

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

		<cfargument name= "aQueryMetaData"
			required= true
			hint= "I am the meta data from the original query." />

		<cfscript>
		var bFirstColumn= true;
		var iColumnPosition= 0;
		var iSortingColumnCount= 1;
		var lsColumnNames= "";
		var qResult= "";
		var sColumnName= "";
		var sOrderBy= "";
		var sSelect= "";
		var sTypeName= "";
		var stColumn= "";
		var stSearchColumn= "";
		var stSortingColumn= "";
		var	bShownNothingMatch=	false;

		lsColumnNames= Query.columnList;

		if( len( stParameters.sColumns ) == 0 )
			stParameters.sColumns= lsColumnNames;

		</cfscript>

		<!--- Columns to Select --->
		<cfsavecontent variable= "sSelect">

		<cfoutput>

		<cfloop array= "#aQueryMetaData#" index= "stColumn">
			<cfif listFindNoCase( lsColumnNames , stColumn.Name )>
				<cfif bFirstColumn eq false>
					,

				</cfif>

				[Query].[#stColumn.Name#]

				<cfset bFirstColumn= false />

			</cfif>

		</cfloop>

		<!---	Create Case Insensitive Order By Columns	--->
		<cfif len( stParameters.iSortingCols )
			and stParameters.iSortingCols
			and arrayLen( stParameters.sortingColumns )>
			,

			<cfloop array= "#stParameters.sortingColumns#" index= "stSortingColumn">
				<cfif listFindNoCase( lsColumnNames , stSortingColumn.name )>
					UPPER( [Query].[#stSortingColumn.name#] ) AS [OrderBy#stSortingColumn.name#]

					<cfif iSortingColumnCount lt stParameters.iSortingCols>
						,

					</cfif>

					<cfset iSortingColumnCount++ />

				</cfif>

			</cfloop>

		</cfif>

		</cfoutput>

		</cfsavecontent>

		<cfif len( trim( sSelect ) ) eq 0>
			<cfset sSelect= lsColumnNames />

		</cfif>

		<!--- Columns to Order By --->
		<cfsavecontent variable= "sOrderBy">

		<cfoutput>

		<!---	Reset Sorting Column Counter	--->
		<cfset iSortingColumnCount=	1 />

		<!---	Create Order By	--->
		<cfif len( stParameters.iSortingCols )
			and stParameters.iSortingCols
			and arrayLen( stParameters.sortingColumns )>

			<cfloop array= "#stParameters.sortingColumns#" index= "stSortingColumn">
				<cfif listFindNoCase( lsColumnNames , stSortingColumn.name )>
					[OrderBy#stSortingColumn.name#]

					<cfif listFindNoCase( stSortingColumn.dir , "DESC" )>
						DESC

					<cfelse>
						ASC

					</cfif>

					<cfif iSortingColumnCount lt stParameters.iSortingCols>
						,

					</cfif>

					<cfset iSortingColumnCount++ />

				</cfif>

			</cfloop>

		</cfif>

		</cfoutput>

		</cfsavecontent>

		<cfquery name= "qResult" dbtype= "query">
		select
			#sSelect#

		  from [Query]
		 where 1= 1	<!---  Matches everything.  Allows for conditional AND syntax below.  --->

		<!--- Search --->
		<cfif len( stParameters.sSearch )>
		and (
			1= 0	<!---  Matches nothing. Allows for conditional OR syntax below. --->

			<cfloop array= "#stParameters.columns#" index= "stSearchColumn">
				<cfif listFindNoCase( lsColumnNames , stSearchColumn.name )>
				<!--- TODO: Possible SQL Injection here? [#stSearchColumn.name#] Try and queryparam it. --->
				or CAST( lower( [Query].[#stSearchColumn.name#] ) AS VARCHAR ) like
					<cfqueryparam cfsqltype= "varchar" value= "%#lcase( stParameters.sSearch )#%" />
				or CAST( lower( [Query].[#stSearchColumn.name#] ) AS VARCHAR ) like
					<cfqueryparam cfsqltype= "varchar" value= "%#lcase( grimVariable( stParameters.sSearch ) )#%" />

				</cfif>

			</cfloop>

		   )

		<cfelse>
			<cfloop array= "#stParameters.columns#" index= "stSearchColumn">
				<cfif	len( stSearchColumn.sSearch )
						and	listFindNoCase( lsColumnNames , stSearchColumn.name )>
					<cfif	bShownNothingMatch eq false>
					and (
						1= 0	<!---  Matches nothing. Allows for conditional OR syntax below. --->

						<cfset	bShownNothingMatch=	true />

					</cfif>

					<!--- TODO: Possible SQL Injection here? [#stSearchColumn.name#] Try and queryparam it. --->
					or CAST( lower( [Query].[#stSearchColumn.name#] ) AS VARCHAR ) like
						<cfqueryparam cfsqltype= "varchar" value= "%#lcase( stSearchColumn.sSearch )#%" />
					or CAST( lower( [Query].[#stSearchColumn.name#] ) AS VARCHAR ) like
						<cfqueryparam cfsqltype= "varchar" value= "%#lcase( grimVariable( stSearchColumn.sSearch ) )#%" />

				</cfif>

			</cfloop>

			<cfif	bShownNothingMatch>
		   )

			</cfif>

			<cfloop array= "#stParameters.columns#" index= "stSearchColumn">
				<cfif	len( stSearchColumn.sSearch )
						and	listFindNoCase( lsColumnNames , stSearchColumn.name )>
				and [Query].[#stSearchColumn.name#] IS NOT NULL

				</cfif>

			</cfloop>

		</cfif>

		<!--- Order --->
		<cfif len( trim( sOrderBy ) )>
		order by #sOrderBy#

		</cfif>

		</cfquery>

		<cfreturn qResult />
	</cffunction>

	<cffunction name= "formatQuery"
		output= false
		access= "private"
		hint= "I apply custom formating to a Query">

		<cfargument name= "Query"
			required= true
			output= false
			hint= "I am the query on which I perform actions." />

		<cfargument name= "aQueryMetaData"
			required= true
			hint= "I am the meta data from the original query." />

		<!--- This function converts all columns to VARCHAR data types
			in order to apply formatting. --->

		<cfscript>
		var bFirstColumn= true;
		var lsColumnNames= "";
		var sSelect= "";
		var stColumn= "";

		lsColumnNames= Query.columnList;

		</cfscript>

		<!--- Columns to Select --->
		<cfsavecontent variable= "sSelect">

		<cfoutput>

		<cfloop array= "#aQueryMetaData#" index= "stColumn">
			<cfif listFindNoCase( lsColumnNames , stColumn.Name )>
				<cfif bFirstColumn eq false>
					,

				</cfif>

				cast( [Query].[#stColumn.Name#] as VARCHAR ) [#stColumn.Name#]

				<cfset bFirstColumn= false />

			</cfif>

		</cfloop>

		</cfoutput>

		</cfsavecontent>

		<cfif len( trim( sSelect ) ) eq 0>
			<cfset sSelect= lsColumnNames />

		</cfif>

		<cfquery name= "Query" dbtype= "query">
		select
			#sSelect#

		  from [Query]

		</cfquery>

		<!--- TODO: Move loop below into query of query above. --->
		<cfloop query= "Query">
			<cfloop array= "#aQueryMetaData#" index= "stColumn">

				<!--- Dollar Format --->
				<!--- TODO: Change DollarFormat to work with International currencies --->
				<cfif listFindNoCase( "money,smallmoney" , stColumn.TypeName )>
					<cfset querySetCell( Query ,
						stColumn.Name ,
						dollarFormat( Query[ stColumn.Name ][ currentRow ] ) ,
						currentRow ) />

				<!--- Date & Time Format --->
				<cfelseif listFindNoCase( "datetime,timestamp" , stColumn.TypeName )>
					<cfset querySetCell( Query ,
						stColumn.Name ,
						dateFormat( Query[ stColumn.Name ][ currentRow ] , "mm/dd/yyyy" )
						& timeFormat( Query[ stColumn.Name ][ currentRow ] , " h:mm tt" ) ,
						currentRow ) />

				</cfif>

			</cfloop>

		</cfloop>

		<cfreturn Query />

	</cffunction>

</cfcomponent>