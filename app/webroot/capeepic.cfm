<cfscript>


/*

TODO 

- check status code for status bar - cfswitch 

- check reposne time and log if bloody slow

*/



// if statement for the two events running off this server 


ss_eventid = 8;
ss_raceid = 17538;
fourcol = 'catplace';
stage = 'Prologue';

todayssplits = [
				
			{
				"id" = 2,
				"name" = "Start"

			},
			
			{
				"id" = 8,
				"name" = "18KM "

			},
			{
				"id" = 11,
				"name" = "21KM "

			},
			
			{
				"id" = 12,
				"name" = "29KM "

			},
			{
				"id" = 3,
				"name" = "33KM "

			},
			{
				"id" = 4,
				"name" = "45KM "

			},
			{
				"id" = 13,
				"name" = "52KM "

			},
			{
				"id" = 14,
				"name" = "58KM "

			},

			{
				"id" = 1,
				"name" = "FINISH "

			}

];
}

</cfscript>



<!---
	set up some basic structures and arrays to append to 

--->


<cfset results = {}>
<cfset "results.items" = [] >
<cfset splits = {
					"type" = "splits",
					"entries" = []
				}>


<cfset starttick = getTickCount()>


<cfscript>

ifriders = "";

</cfscript>

<cfif listfind(ifriders,"#url.bib#") >

		<cfinclude template="ifrider.cfm">

<cfelse>


		<cfhttp url="https://api.sportsplits.com/v2/races/17538/events/#ss_eventid#/results/teams/race_no/#url.bib#?splits=true" method="get" result="httpresponse">
			<cfhttpparam type="header" name="X-API-KEY" value="BGE7FS8EY98DFAT57K7XL527F6CA58CJ">
		</cfhttp>




<cfset data = #DeserializeJSON(httpresponse.filecontent)#>


<!--- do some calcs --->
<cfset endtick = getTickCount()>

<cfset tickcount = endtick-starttick>

<!---

	Process the result 

	CFIF statement if there is an error 

--->

<cfif httpresponse.status_code  eq 200>


			<cfset data = #DeserializeJSON(httpresponse.filecontent)#>
			<cfset data = data.race_event_team>
			<cfset teamsplits = data.splits>
			<cfset status = 'nys'>






<cfif arraylen(teamsplits) >

	<cfset status = 'started'>

</cfif>

<cfif !isnull(data.finish_time)>

	<cfset status = 'finished'>

</cfif>

<!---

Summary box at the top 

--->

<cfscript>

			if (  isdefined('data.finish_time') && (data.finish_time neq '')) 
					{
						// define a structure to house result 
						summary =

						{
							"type": "summary",
							"result": "#data.finish_time#",
							"items": [{
									"name": "Stage",
									"value": "PROLOGUE"
								},
								{
									"name": "Climbing",
									"value": ""
								},
								{
									"name": "Distance",
									"value": "24KM"
								}
							]
							}

						// now add it to main data object 

						arrayappend(results.items,summary)

					}

</cfscript>


<!---

	Create a status bar 
--->

<cfswitch expression="#status#">

	<cfcase value="nys">

		<cfset arrayappend(splits.entries,
			{
					"style": "split_grey",
					"data": [
						"STATUS : Awaiting Start"
					]
				}

				)>

	</cfcase>

	<cfcase value="started">

		<cfset arrayappend(splits.entries,
			{
					"style": "split_green",
					"data": [
						"STATUS : Started"
					]
				}

				)>

	</cfcase>


	<cfcase value="finished">

		<cfset arrayappend(splits.entries,
			{
					"style": "split_black",
					"data": [
						"STATUS : FINISHED"
					]
				}

				)>

	</cfcase>

	<cfcase value="dnf">

		<cfset arrayappend(splits.entries,
			{
					"style": "split_orange",
					"data": [
						"STATUS : DNF"
					]
				}

				)>

	</cfcase>
</cfswitch>


<!---

	Create a header section 

	Last column is a variable 

--->

<cfset arrayappend(splits.entries,
			{
					"style": "header",
					"data": [
						"Point",
						"Race Time",
						"Time",
						"Place"
					]
				}

				)>

<!---

	Split Entries 

--->

<cfloop array="#todayssplits#" index="i">


<!--- check that we have a match id on splits results --->
	 <cfscript>

	    arrayIndex = ArrayFind(teamsplits, function(struct){ 
	        return struct.split_id == i.id; 
	        });


	    if (arrayisdefined(teamsplits,arrayindex))
	    {

	    	racetime = tostring(teamsplits[arrayIndex].race_time);
	    	tod = tostring(teamsplits[arrayIndex].tod);
	    	fourcol = tostring(teamsplits[arrayIndex].split_type_pos);

	    }
	    else {

	    	racetime = "";
	    	tod = "";
	    	fourcol = "";

	    }

			
		 arrayappend(splits.entries,
					{
					"data": [
						"#i.name#",
						"#racetime#",
						"#tod#",
						"#fourcol#"
					]
				} );

	</cfscript>


</cfloop>

<cfscript>


/*
 arrayappend(splits.entries,
					{
						"style":"separator",
					"data": [
						"#tickcount# ms #url.bib#"
					]
				} );
*/

					

					// now add splits it to main data object 

					arrayappend(results.items,splits);

</cfscript>


<!---

	Add an summary box if finished 

--->





<cfelse>
<!--- do an error here ---> 







</cfif>


</cfif>






<cfscript>

api.mimeType = 'application/json';
api.content = serializeJSON(results);

</cfscript>


<cfcontent
	type="#api.mimeType#"
	variable="#charsetDecode(api.content,'utf-8')#"
	/>




