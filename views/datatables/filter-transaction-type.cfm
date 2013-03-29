<cfparam	name=		"rc.filter.transaction.type"
			default=	"" />

<cfset	runEvent(	event=		"viewlets.transactionTypes" ,
					private=	true ) />
<cfscript>
if( StructKeyExists( cookie , "filter_transaction_type" ) )
	rc.filter.transaction.type= cookie.filter_transaction_type;

</cfscript>

<cfoutput>
<div class= "section">
	<label	for=	"filter_transaction_type">
		Type

	</label>
	<select	name=	"filter[transaction][type]"
			id=		"filter_transaction_type"
			data-name=	"transType">
		<option	value=	"">All</option>
		<cfloop	query=	"rc.qTransactionTypes">
		<option	value=	"#rc.qTransactionTypes.transactionTypeID#"
				data-description=	"#rc.qTransactionTypes.name#"
				<cfif	rc.qTransactionTypes.transactionTypeID eq rc.filter.transaction.type>
				selected=	"selected"

				</cfif>>
			#rc.qTransactionTypes.name#

		</option>

		</cfloop>

	</select>

</div>
</cfoutput>