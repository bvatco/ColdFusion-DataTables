<cffunction	name=	"scrubRequestStructure"
			output=	"false"
			access=	"private"
			hint=	"I attempt to remove attacks and setup the request">

	<cfargument	name=	"stTarget" />
	<cfargument	name=	"bDuplicate"
				required=	"false"
				default=	"true"
				hint=		"I toggle duplicating the stTarget. If set to false, I simply override values in stTarget." />

	<cfscript>
	var sKey=	"";
	var	stCopy=	stTarget;
	if(	bDuplicate )
		stCopy=	duplicate( stTarget );

	for( sKey in stTarget ) {
		if( IsStruct( stCopy[ sKey ] ) ) {
			stCopy[ sKey ]=	scrubRequestStructure( stCopy[ sKey ] );

		}
		else if ( IsSimpleValue( stCopy[ sKey ] ) ) {
			stCopy[ sKey ]=	htmlEditFormat( stCopy[ sKey ] );
			stCopy[ sKey ]=	reReplaceNoCase( stCopy[ sKey ] ,
				"<[^>]*>" , "" ,
				"all" );

		}

	}

	return	stCopy;
	</cfscript>

</cffunction>

<cffunction	name=	"scrubRequestStructureLight"
			output=	"false"
			access=	"private"
			hint=	"I attempt to remove attacks and setup the request">

	<cfargument	name=	"stTarget" />
	<cfargument	name=	"bDuplicate"
				required=	"false"
				default=	"true"
				hint=		"I toggle duplicating the stTarget. If set to false, I simply override values in stTarget." />

	<cfscript>
	var sKey=	"";
	var	stCopy=	stTarget;
	if(	bDuplicate )
		stCopy=	duplicate( stTarget );

	for( sKey in stTarget ) {
		if( IsStruct( stCopy[ sKey ] ) ) {
			stCopy[ sKey ]=	scrubRequestStructureLight( stCopy[ sKey ] );

		}
		else if ( IsSimpleValue( stCopy[ sKey ] ) ) {
			stCopy[ sKey ]=	reReplaceNoCase( stCopy[ sKey ] , '"' , "&quot;" , "all" );
			stCopy[ sKey ]=	reReplaceNoCase( stCopy[ sKey ] , "<" , "&lt;" , "all" );
			stCopy[ sKey ]=	reReplaceNoCase( stCopy[ sKey ] , ">" , "&gt;" , "all" );
			stCopy[ sKey ]=	reReplaceNoCase( stCopy[ sKey ] ,
				"<[^>]*>" , "" ,
				"all" );

		}

	}

	return	stCopy;
	</cfscript>

</cffunction>

<cffunction	name=	"scrubVariable"
			output=	"false"
			access=	"private"
			hint=	"I attempt to remove attacks and setup the request.">

	<cfargument	name=	"sTarget" />

	<cfscript>
	var	sCopy=	sTarget;
	if( IsSimpleValue( sCopy ) ) {
		sCopy=	REReplace(	sCopy ,
							'<' ,
							"&lt;" ,
							"all" );
		sCopy=	REReplace(	sCopy ,
							'>' ,
							"&gt;" ,
							"all" );
		sCopy=	REReplace(	sCopy ,
							'&' ,
							"&amp;" ,
							"all" );
		sCopy=	REReplace(	sCopy ,
							'"' ,
							"&quot;" ,
							"all" );

	}

	return	sCopy;
	</cfscript>

</cffunction>


<cffunction	name=	"grimRequestStructure"
			output=	"false"
			access=	"private"
			hint=	"I convert valid html escaped strings into their code format.">

	<cfargument	name=	"stTarget" />
	<cfargument	name=	"bDuplicate"
				required=	"false"
				default=	"true"
				hint=		"I toggle duplicating the stTarget. If set to false, I simply override values in stTarget." />

	<cfscript>
	var sKey=	"";
	var	stCopy=	stTarget;
	if(	bDuplicate )
		stCopy=	duplicate( stTarget );

	for( sKey in stTarget ) {
		if( IsStruct( stCopy[ sKey ] ) ) {
			stCopy[ sKey ]=	grimRequestStructure( stCopy[ sKey ] );

		}
		else if ( IsSimpleValue( stCopy[ sKey ] ) ) {
			stCopy[ sKey ]=	REReplace(	stCopy[ sKey ] ,
										"&lt;" ,
										'<' ,
										"all" );
			stCopy[ sKey ]=	REReplace(	stCopy[ sKey ] ,
										"&gt;" ,
										'>' ,
										"all" );
			stCopy[ sKey ]=	REReplace(	stCopy[ sKey ] ,
										"&amp;" ,
										'&' ,
										"all" );
			stCopy[ sKey ]=	REReplace(	stCopy[ sKey ] ,
										"&quot;" ,
										'"' ,
										"all" );

		}

	}

	return	stCopy;
	</cfscript>

</cffunction>

<cffunction	name=	"grimVariable"
			output=	"false"
			access=	"private"
			hint=	"I convert valid html escaped strings into their code format.">

	<cfargument	name=	"sTarget" />

	<cfscript>
	var	sCopy=	sTarget;
	if( IsSimpleValue( sCopy ) ) {
		sCopy=	REReplace(	sCopy ,
							"&lt;" ,
							'<' ,
							"all" );
		sCopy=	REReplace(	sCopy ,
							"&gt;" ,
							'>' ,
							"all" );
		sCopy=	REReplace(	sCopy ,
							"&amp;" ,
							'&' ,
							"all" );
		sCopy=	REReplace(	sCopy ,
							"&quot;" ,
							'"' ,
							"all" );

	}

	return	sCopy;
	</cfscript>

</cffunction>