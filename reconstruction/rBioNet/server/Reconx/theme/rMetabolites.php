<?php
/*
Template Name: rBioNet Metabolites

View page for rBioNet Metabolites. 

rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 

rbionet@systemsbiology.is
Stefan G. Thorleifsson
2012

*/
require_once "rFunctions.php"; // rBionet frequent functions. 

$array = array();

if (isset($_GET["Abbreviation"])) {
	// Get the one Reaction!
	global $wpdb;
	$array = $wpdb->get_row("SELECT * FROM metabolites WHERE Abbreviation = '"
	.rSanitize($_GET["Abbreviation"])."'",ARRAY_A);
	
}



get_header();


?>

<div id="content" role="main" class="rbionet">



<?php
$list_view = rBrowseLimit(rRxns_page_id);


if (!empty($array)) {
	print rSimplePrint($array);
	
	$rxns = rMetInRxns($array["Abbreviation"]);
	
	?> <h3 class="entry-title">Appears in</h3> <?php
	foreach ($rxns as $val) {
		print rPrintSearch($val,"reactions");
	}
}
else {	
	
	?> Number of metabolites: <?php print rTableCount("metabolites"); ?> </br></br> <?php 
	$list = rGetList("metabolites",$list_view["start"],$list_view["length"]);
	print $list_view["form"]; 
	foreach ($list as $val) {
		print rPrintSearch($val,"metabolites");
	}
	
}


?>


</div>

<?php
get_footer(); 
?>

