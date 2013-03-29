<cfoutput>
<cfif thisTag.executionMode eq "start">
	<cfset caller.hiddenFields= "" />

<div	id=		"filters"
		class=	"section" style="display:none;">

<cfelse>

	<div class= "clear"></div>

</div>
<div class= "clear"></div>

	<cfif len( trim( thisTag.GeneratedContent ) ) eq 0>
	<script>
	$( document ).ready( function() {
		$( "##filters" ).hide();

	} );

	</script>

	</cfif>

	#caller.hiddenFields#

</cfif>
</cfoutput>