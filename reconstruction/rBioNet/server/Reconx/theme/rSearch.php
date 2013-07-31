<?php
/*
Template Name: rBioNet Search

rBioNet Search 
Search for reactions or metabolite in a model and display results. 

rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 

rbionet@systemsbiology.is
Stefan G. Thorleifsson
2012

*/

require_once "rFunctions.php"; // rBionet frequent functions. 


// Model variable
// ReconX is the only model now. 
// $model_id variable is used to make expansion easier later on. 
$model_id = rModel_id;




$rxns = array("Abbreviation" => "",
	"Description" => "",
	"Formula" => "",
	"Reversible" => "",
	"GPR" => "",
	"LB" => "",
	"UB" => "",
	"CS" => "",
	"SubSystem" => "",
	"Notes" => "",
	"ECNumber" => "",
	"KeggID" => "");
	
$mets = array("Abbreviation" => "",
	"Description" => "",
	"NeutralFormula" => "",
	"ChargedlFormula" => "",
	"Charge" => "",
	"KeggID" => "",
	"PubChemID" => "",
	"CheBlID" => "",
	"InchiString" => "",
	"Smile" => "",
	"HMDB" => "",
	"LastModified" => "");

$constraints = array();
$results = array();
if (isset($_GET["type"])) {
	// Leita og birta nidurstodur. 
	if ("reactions" == $_GET["type"]) {
		$type = $rxns;
	}
	else if ("metabolites" == $_GET["type"]) {
		$type = $mets;
	}
	else {
		die("type wrong!");
	}
	$results = rSearch($type,$model_id); // Get ARRAY_A (associative array);
}

get_header();
?>



<div id="content" action="">
	<form name="input" method="get">
		<input type="hidden" name="page_id" value="<?php print rSearch_page_id; ?>">
		<table>
		<tr><td>Metabolite: </td><td>  <input type="radio" name="type" value="metabolites"> </td></tr>
		<tr><td>Reaction:   </td><td>  <input type="radio" name="type" value="reactions">   </td></tr>
		</table>
		<br>
		<table>
		<tr height="30" ><td width="100">Abbreviation </td><td><input type="text" name="Abbreviation"></td></tr>
		<tr height="30"><td width="100">Description </td><td><input type="text" name="Description"></td></tr>
		</table>
		<br><br>
		<input type="submit" value="Search">
	</form>
	</br>

	
	<!--CS: Confidence Score - LB: Lower Bound - UB: Upper Bound </br> -->
	<hr>
	
	<?php
		if (!empty($results)) {
			foreach ($results as $value) {
				print rPrintSearch($value,$_GET["type"]);
			}
		}
	?>

<br>

</div>





<?php
get_footer(); 
?>
