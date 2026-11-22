% The COBRAToolbox: testGetMIRIAMAnnotations.m
%
% Purpose:
%     - getMIRIAMAnnotations collects, for the reactions, metabolites, genes or the model itself,
%       the MIRIAM annotations stored in the database fields (rxnKEGGID, metChEBIID, ...) and
%       in the qualifier-named fields (rxnisbrendaID, modelmisDerivedFrom...ID) as a struct
%       array of controlled-vocabulary terms with their resources. Quarantined: no behaviour of
%       getMIRIAMAnnotations is asserted until the defects below are fixed. The opening below
%       still calls prepareTest() because it is the standard opening of every COBRA test.
%
% Function under test:
%     src/analysis/exploration/getMIRIAMAnnotations.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model look-ups, no solver; a test would use hand-built two-reaction models with
%     database fields (brenda, kegg, pubmed) and model-level qualifier fields (the smallest
%     models that reach every branch); no internet access is needed by the function.
%
% Coverage exemptions:
%     every line - getMIRIAMAnnotations is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Resources of an earlier controlled-vocabulary term leak into a later term with fewer identifiers
%       SEVERITY: wrong-result
%       TRIGGER: any call in which a later term (a later element, or a later qualifier of the
%         same element) has fewer identifiers than an earlier one, for example a two-reaction
%         model (rxns R1, R2) with rxnBRENDAID = {'1.1.1.1; 2.2.2.2'; '3.3.3.3'} and
%         getMIRIAMAnnotations(model, 'rxn')
%       OBSERVED: MATLAB R2025a: R2 reports two resources, 3.3.3.3 twice, instead of one (R1
%         correctly 1.1.1.1 and 2.2.2.2); with rxnBRENDAID = {'1.1.1.1; 2.2.2.2; 3.3.3.3';
%         '4.4.4.4; 5.5.5.5'} the call stops with "The number of outputs should match the
%         number of inputs." (deal, called from line 172); within one reaction, rxnBRENDAID
%         {'1.1.1.1; 2.2.2.2'} with rxnReferences {'12345'} gives the isDescribedBy term the
%         resources 12345, 12345. Line 170 assigns the empty template to cRessourcestruct
%         (lower-case s) while lines 171-174 fill cRessourceStruct, which keeps the elements of
%         the previous term; with increasing sizes ({'1.1.1.1'; '2.2.2.2; 3.3.3.3'}) and with
%         one identifier per term everywhere the result is correct
%       EXPECTED: one resource per identifier of the term, as documented for
%         .annotation.cvterms.ressources
%       LINES: 170-174
%     - DEFECT: A character vector for the ids option stops the call
%       SEVERITY: error
%       TRIGGER: getMIRIAMAnnotations(model, 'rxn', 'ids', 'R1') on a two-reaction model with
%         rxnBRENDAID = {'1.1.1.1'; '2.2.2.2'}; the option is documented as "A specific ID or
%         IDs" and its validator accepts a character vector
%       OBSERVED: MATLAB R2025a: "Dimensions of arrays being concatenated are not consistent."
%         at line 92, because numElements = length(ids) counts the two characters of 'R1' while
%         relPos selects one reaction; a one-character id 'R' stops at the same line with
%         "Unable to perform assignment because the size of the left side is 1-by-1-by-4 and the
%         size of the right side is 1-by-3."; the cell form {'R1'} returns the brenda term
%         1.1.1.1 as expected
%       EXPECTED: the annotations of that one reaction, as for the cell form {'R1'}
%       LINES: 54, 92, 138
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetMIRIAMAnnotations'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
