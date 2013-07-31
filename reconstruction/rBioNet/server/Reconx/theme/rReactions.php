<?php
/*
Template Name: rBioNet Reactions

View page for rBioNet Reactions. 

rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 

rbionet@systemsbiology.is
Stefan G. Thorleifsson
2012

*/
require_once "rFunctions.php"; // rBionet frequent functions. 




get_header();


?>

<div id="content" role="main" class="rbionet">

<?php

$array = array();

if (isset($_GET["Abbreviation"])) {
	// Get the one Reaction!
	global $wpdb;
	
	print rSimplePrint(rGetReaction($_GET["Abbreviation"]));
}
else {
	?> Number of reactions: <?php print rTableCount("reactions"); ?> </br></br><?php 
	$list_view = rBrowseLimit(rRxns_page_id);
	print $list_view["form"]; 
	$list = rGetList("reactions",$list_view["start"],$list_view["length"]);
	foreach ($list as $val) {
		print rPrintSearch($val,"reactions");
	}

} 

?>
<hr>
CS: Confidence Score - LB: Lower Bound - UB: Upper Bound </br> </br>
</div>

<?php
get_footer(); 
?>
