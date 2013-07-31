<?php 

/* rBioNet Functions file

Store simple functions I use more than once. 
In futur it might be good to create an rBioNet object.

Stefan G Thorleifsson
2012


*/

// Needs to be filled out for search system to work
define('rSearch_page_id','4');
define('rRxns_page_id','6');
define('rMets_page_id','8');
define('rModel_id','1'); // To start with only one model. In the future we might have more possible more. 

// Clear out escape characters and anything harmful for sql input. 
function rSanitize($str) {
	return preg_replace('/[^-a-zA-Z0-9()_]/','',$str);
}

// Print associative array and use Abbreviation key as header. 
function rSimplePrint($array) {
	$abb = ""; // Abbreviation for title
	$str = '';
	foreach ($array as $key => $value) {
		if ($value == "null") {
			$value = "";
		}
		if ($key == "Abbreviation") {
			$abb = $value;
		}
		// Some fields are irrelevant. 
		if ($key == "model_id" || $key == "AddedBy" || $key == "met_id" || $key == "rxn_id") {
			continue;
		}
		$str .= "<span class='columnName'>".$key.":</span> ".rSpecialPrinting($key,$value)."</br>";
	}
	$str ='<h3 class="entry-title">'.$abb.'</h3>'.$str.'</br>';
	return $str;
}

// Special printing cases
// INPUT 	- key name of field, and value from foreach of a associative array 
function rSpecialPrinting($key,$value) {
	if ($key == "Formula") {
		$b = explode(" ",$value);
		$str = "";
		foreach($b as $obj) {
			$split = explode("[",$obj);
			if (count($split) == 2) {
				$str .= "<a href='?page_id=".rMets_page_id."&Abbreviation=".$split[0]."'>".$obj."</a>"; 
			}	
			else {
				$str .=" ".$obj." ";
			}
		}
		return $str;
	}
	else if ($key == "CheBlID") {
		return "<a href='http://www.ebi.ac.uk/chebi/searchId.do?chebiId=CHEBI:".$value."'>".$value."</a>";
	}
	else if ($key == "HMDB") {
		return "<a href='http://www.hmdb.ca/metabolites/".$value."'>".$value."</a>";
	}
	else if ($key == "PubChemID" ) {
		return "<a href='http://pubchem.ncbi.nlm.nih.gov/summary/summary.cgi?sid=".substr($value,1)."'>".$value."</a>";
	}
	else if ($key == "KeggID" ) {
		return "<a href='http://www.genome.jp/dbget-bin/www_bget?cpd:".$value."'>".$value."</a>";
	}
	else {
		return $value;
	}
}

// Check GET for fields to search
function check_constraints($array) {
	$return = array();
	foreach($array as $key => $value) {
		if (isset($_GET[$key])) {
			$return[$key] = $_GET[$key];
		}
	}
	return $return;
}

// The search function. 
// INPUT
// 		constraints - associative array key = search field and value = search phrase
//		model_id 	- id of reconstruction to search for (when searching for reactions).
// OUTPUT
//		associative array, columns are keys and value is value.
function rSearch($constraints,$model_id) {
	global $wpdb;
	$str = "";
	if (empty($constraints)) {
		die("constraints are empty");
	}
	$array = check_constraints($constraints);
	
	if ($_GET["type"] == "metabolites") {
		$str = "SELECT * FROM metabolites WHERE ";
	}
	else if ($_GET["type"] == "reactions") {
		$str = "SELECT * FROM reactions,recon WHERE recon.rxn_id = reactions.rxn_id AND model_id = "
		.$model_id." AND ";
	}
	foreach ($array as $key => $value) {
		//baeta vid streng
		$str.= " ".$key." LIKE '%".rSanitize($value)."%' AND";
	}
	$str = substr($str,0,-3). " ORDER BY Abbreviation ASC"; // Cut out the last "AND"
	return $wpdb->get_results($str,ARRAY_A);
}

// INPUT - reaction abbreviation.
//			model id is model id.  
function rGetReaction($str) {
	global $wpdb;
	$model_id = rModel_id;
	return $wpdb->get_row("SELECT * FROM reactions, recon WHERE Abbreviation = '"
		.rSanitize($_GET["Abbreviation"])."' AND recon.rxn_id = reactions.rxn_id AND model_id = "
		.$model_id. " ORDER BY Abbreviation ASC",ARRAY_A);
}


// Get a list of metabolites or reactions to brows. 
function rGetList($type,$start,$end) {
	global $wpdb;
	return $wpdb->get_results("SELECT Abbreviation, Description FROM ".$type." ORDER BY Abbreviation Limit ".$start.",".$end,ARRAY_A);
}

// Simple way to print search results with hyperlinks. 
// INPUT - array (associative, keys Abbreviation and description are used)
// OUTPUT - html string ready to for website. 
function rPrintSearch($array,$type) {
	$str = "";
	$hyper = "";
	// direct to metabolite or reaction site. 
	if($type == "reactions") $hyper = rRxns_page_id; elseif ($type == "metabolites") $hyper = rMets_page_id; else  die("rPrintSearch wrong type!");

	foreach ($array as $key => $value) {
		if ($key == "Abbreviation") {
			
			$str .= "<a href='?page_id=".$hyper."&Abbreviation=".$value."'>".$value."</a> ";
		}
		else if ($key == "Description") {
			$str .= " - ".$value."</br>";
			break;
		}
	}
	return $str;
}


// Get all reactions metabolite appears in.
// Input - Metabolite abbreviation
// Ouput - Assoc array of reaction abbreviations. 
function rMetInRxns($met) {
	global $wpdb;
	return $wpdb->get_results(
"select Abbreviation, Description from reactions,
(
select distinct rxn_id from smatrix
where met_id =
(
SELECT met_id
FROM metabolites
WHERE Abbreviation = '".$met."'
)
) as ids

where ids.rxn_id = reactions.rxn_id ORDER BY Abbreviation ASC",
ARRAY_A);
}

// Browser material
function rBrowseLimit($page_id)  {

	if( isset($_GET["start"]) && isset($_GET["end"]) ) {
		$start = $_GET["start"];
		$end = $_GET["end"];
		if(!is_numeric($start) || !is_numeric($end)) {
			$start = "0";
			$end = "100";	
		}
		else if ( $start > $end ) { // This is Aokey
			$temp = $start;
			$start = $end;
			$end = $temp;
		}
	}
	else {
		$start = "0";
		$end = "100";
	}
	$length = $end - $start;
	
	// String 
	$form = '
<form name="input" method="get">
	<input type="hidden" name="page_id" value="'.$page_id.'">
	<table>
		<tr height="30">
		<td width="50"> View: </td>
		<td width="50"><input type="text" name="start" value="'.$start.'" size="5"></td>
		<td width="20"> << </td>
		<td width="90"><input type="text" name="end" value="'.$end.'" size="5"></td>
		<td><input type="submit" value="Submit"></td>
		</tr>
		</table>
<br><hr>		
</form>

';
	return array("start" => $start, "end" => $end, "length" => $length, "form" => $form);
}



// Get count of a table. 
function rTableCount($table) {
	global $wpdb;
	$var = $wpdb->get_row("SELECT COUNT(*) FROM ".$table,ARRAY_N);
	return $var[0];
}
?>