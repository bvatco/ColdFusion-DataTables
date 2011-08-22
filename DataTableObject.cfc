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

<cfcomponent displayname= "DataTableObject"
	output= false
	hint= "Handles data output for DataTable results">

	<cffunction name= "init"
		output= false
		hint= "I am the constructor.">

		<cfargument name= "stParameters"
			required= true
			hint= "I am a useful collection of Parameters for dealing with qResult." />

		<cfargument name= "qResult"
			required= true
			hint= "I am the searched and sorted query result." />

		<cfargument name= "aQueryMetaData"
			required= true
			hint= "I am the meta data from the original query." />

		<cfscript>
		set( "stParameters" , stParameters );
		set( "qResult" , qResult );
		set( "aQueryMetaData" , aQueryMetaData );

		return this;

		</cfscript>

	</cffunction>

	<cffunction name= "toQuery"
		output= false
		hint= "I return a query of the sorted and search DataTable event.">

		<cfscript>
		return get( "qResult" );

		</cfscript>

	</cffunction>

	<cffunction name= "toJSON"
		output= false
		hint= "I convert my parameters and query results into DataTables JSON Format">

		<cfscript>
		var stParameters= get( "stParameters" );
		var qResult= get( "qResult" );

		var pqResult= "";

		//Paginate and Format Query
		pqResult= paginateQuery();

		return paginatedResultToJSON( pqResult );

		</cfscript>

	</cffunction>

	<cffunction name= "paginateQuery"
		output= false
		access= "private"
		hint= "I paginate the qResult">

		<cfscript>
		var stParameters= get( "stParameters" );
		var qResult= duplicate( get( "qResult" ) );
		var aQueryMetaData= get( "aQueryMetaData" );

		var iLastPage= 1;
		var iPage= 1;
		var iPageSize= 1;

		if( stParameters.iDisplayLength > 0 ) {
			iPage= int( stParameters.iDisplayStart / stParameters.iDisplayLength ) + 1;
			iPageSize= stParameters.iDisplayLength;

		}
		else {
			iPage= 1;
			iPageSize= qResult.recordCount;

		}

		//Last page may contain less than iDisplayLength
		iLastPage= int( qResult.recordCount / stParameters.iDisplayLength ) + 1;
		if( iPage == iLastPage )
			iPageSize= qResult.recordCount % iPageSize;

		qResult= QueryConvertForGrid( qResult , iPage , iPageSize );

		return qResult;

		</cfscript>

	</cffunction>

	<cffunction name= "paginateAndFormatQuery"
		output= false
		access= "private"
		hint= "I paginate the qResult">

		<cfscript>
		var stParameters= get( "stParameters" );
		var qResult= duplicate( get( "qResult" ) );
		var aQueryMetaData= get( "aQueryMetaData" );

		var pqResult= "";

		var bFirstColumn= true;
		var iColumnPosition= 1;
		var iLastPage= 1;
		var iPage= 1;
		var iPageSize= 1;
		var sColumnName= "";
		var sColumnNames= "";
		var stColumn= "";

		lsColumnNames= qResult.columnList;

		if( len( stParameters.sColumns ) == 0 )
			stParameters.sColumns= lsColumnNames;

		</cfscript>

		<!--- Columns to Select --->
		<cfsavecontent variable= "sSelect">
		<cfoutput>
		<cfloop list= "#stParameters.sColumns#" index= "sColumnName">
			<cfset iColumnPosition= listFindNoCase( lsColumnNames , sColumnName ) />
			<cfif iColumnPosition>
				<cfif bFirstColumn eq false>,</cfif>
				<cfif listFindNoCase( "java.lang.String" , getMetaData( qResult[ sColumnName ][ 1 ] ).getName() )>
					#sColumnName#
				<cfelse>
					cast( #sColumnName# as VARCHAR ) as #sColumnName#
				</cfif>
				<cfset bFirstColumn= false />

			</cfif>

		</cfloop>
		</cfoutput>
		</cfsavecontent>
		<cfset sSelect= trim( sSelect ) />

		<cfif len( sSelect ) eq 0>
			<cfset sSelect= lsColumnNames />

		</cfif>


		<!--- Convert Everything to VARCHAR to format --->
		<cfquery name= "pqResult" dbtype= "query">
		select
			#sSelect#

		  from [qResult]

		</cfquery>

		<cfscript>
		if( stParameters.iDisplayLength > 0 ) {
			iPage= int( stParameters.iDisplayStart / stParameters.iDisplayLength ) + 1;
			iPageSize= stParameters.iDisplayLength;

		}
		else {
			iPage= 1;
			iPageSize= pqResult.recordCount;

		}

		//Last page may contain less than iDisplayLength
		iLastPage= int( pqResult.recordCount / stParameters.iDisplayLength ) + 1;
		if( iPage == iLastPage )
			iPageSize= pqResult.recordCount % iPageSize;

		pqResult= QueryConvertForGrid( pqResult , iPage , iPageSize );

		</cfscript>

		<!--- Custom Formatting --->
		<cfloop query= "pqResult.Query">
			<cfloop array= "#aQueryMetaData#" index= "stColumn">

				<!--- Dollar Format --->
				<!--- TODO: Change DollarFormat to work with Canadian currency --->
				<cfif listFindNoCase( "money,smallmoney" , stColumn.TypeName )>
					<cfset querySetCell( pqResult.Query ,
						stColumn.Name ,
						dollarFormat( pqResult.Query[ stColumn.Name ][ currentRow ] ) ,
						currentRow ) />

				<!--- Date & Time Format --->
				<cfelseif listFindNoCase( "datetime,timestamp" , stColumn.TypeName )>
					<cfset querySetCell( pqResult.Query ,
						stColumn.Name ,
						dateFormat( pqResult.Query[ stColumn.Name ][ currentRow ] , "mm/dd/yyyy" )
						& timeFormat( pqResult.Query[ stColumn.Name ][ currentRow ] , " h:mm tt" ) ,
						currentRow ) />

				</cfif>

			</cfloop>

		</cfloop>

		<cfreturn pqResult />

	</cffunction>

	<cffunction name= "paginatedResultToJSON"
		output= false
		access= "private"
		hint= "I turn a paginated query into DataTables JSON Format">

		<cfargument name= "pqResult"
			required= true
			hint= "I am the pqResult from paginateAndFormatQuery" />

		<cfscript>
		var stParameters= get( "stParameters" );

		var bLastColumn= false;
		var iColumnCount= 1;
		var iColumnLength= 1;
		var iColumnPosition= 1;
		var lsColumnNames= "";
		var sJSON= "";
		var sColumnName= "";

		// This is a quick and simple XSS check. You should implement your own XSS prevention.
		if( isValid( "integer" , stParameters.sEcho ) eq false )
			return "sEcho is invalid. Possible XSS attack.";

		lsColumnNames= pqResult.Query.columnList;

		if( len( stParameters.sColumns ) == 0 )
			stParameters.sColumns= lsColumnNames;

		iColumnLength= listLen( stParameters.sColumns );

		</cfscript>

<cfsavecontent variable= "sJSON"><cfoutput>{
	"sEcho": #stParameters.sEcho# ,
	"iTotalRecords": #stParameters.iTotalRecords# ,
	"iTotalDisplayRecords": #stParameters.iTotalDisplayRecords# ,
	"aaData": [
<cfloop query= "pqResult.Query"><cfsilent>
	<cfset iColumnCount= 1 />
	<cfset bLastColumn= false />
</cfsilent>		[<cfloop list= "#stParameters.sColumns#" index= "sColumnName"><cfsilent>
			<cfset iColumnPosition= listFindNoCase( lsColumnNames , sColumnName ) />

			<cfif sColumnName eq "null">
				<cfset iColumnPosition= -1/>

			</cfif>
</cfsilent>
			<cfif iColumnPosition><cfif iColumnPosition eq -1>""<cfelse>"#pqResult.Query[ sColumnName ][ currentrow ]#"</cfif></cfif><cfsilent>
			</cfsilent><cfif bLastColumn eq false>,</cfif><cfsilent>
				<cfset iColumnCount++ />
				<cfif iColumnCount gte iColumnLength>
					<cfset bLastColumn= true />

				</cfif>

</cfsilent></cfloop>
		]<cfif currentRow neq recordCount>,</cfif>
</cfloop>	]
}</cfoutput></cfsavecontent>

		<cfreturn trim( sJSON ) />
	</cffunction>














	<!--- Unrelated Functions --->
	<cffunction	name= "instance"
		output= false
		returntype= "struct"
		hint= "I access the component properties">

		<cfif structKeyExists( variables , "properties" ) eq false>
			<cfset variables.properties= structNew() />
		</cfif>

		<cfreturn variables.properties />
	</cffunction>

	<cffunction name= "get"
		output= false
		hint= "I return the requested variable or an empty string.">

		<cfargument	name= "name"
			required= true
			default= ""	/>

		<cfif structKeyExists( variables.properties , name )>
			<cfreturn variables.properties[ name ] />
		</cfif>

		<cfreturn "" />
	</cffunction>

	<cffunction	name= "set"
		output= false
		hint= "Sets the instance value and return a pointer to the wrapper.">

		<cfargument name= "name"
			required= true
			default= ""
			hint= "I am the instance variable name"	/>

		<cfargument name= "value"
			required= true
			default= ""
			hint= "I am the instance variable value"/>

		<cfset variables.properties[ name ]= value />

		<cfreturn this />
	</cffunction>

	<cffunction name= "OnMissingMethod"
		output= false
		hint= "Handles missing method exceptions.">

		<cfargument name= "MissingMethodName"
			required= "true"
			hint= "The name of the missing method."	/>

		<cfargument name= "MissingMethodArguments"
			required= "true"
			hint= "The arguments that were passed to the missing method. This might be a named argument set or a numerically indexed set." />

		<cfset var keyCount= structcount( MissingMethodArguments ) />

		<cfif keyCount eq 0>
			<cfreturn get( MissingMethodName ) />

		<cfelseif keyCount eq 1>
			<cfreturn set( MissingMethodName , MissingMethodArguments[ 1 ] )	/>

		</cfif>

		<cfthrow message = "I need pie " detail = "#MissingMethodName#" />
	</cffunction>


</cfcomponent>