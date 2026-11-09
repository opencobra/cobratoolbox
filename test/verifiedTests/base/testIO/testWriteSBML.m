% The COBRAToolbox: testWriteSBML.m
%
% Purpose:
%     - read in a model from a .xml file, write it as a .sbml file,
%       read it back in and assess any differences
%
% Authors:
%     - Partial original file: Joseph Kang 04/07/09
%     - CI integration: Laurent Heirendt
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%
% Function under test:
%     src/base/io/utilities/writeSBML.m
%
% Coverage exemptions:
%     Lines 473-476: dead code inside an if 0 block.
%     Lines 651-652: unreachable. The block is only entered when an objective coefficient is not
%     zero, so find(model.c) is never empty.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The model annotation cannot be written
%       SEVERITY: error
%       TRIGGER: a model with the field modelAnnotation
%       OBSERVED: a cell array of strings stops in OutputSBML with "model annotation field
%         incorrect type"; a char, which is what readSBML returns, is split into one paragraph per
%         character
%       EXPECTED: the annotation written as a whole
%       LINES: 160-162, 164-165
%     - DEFECT: A model without reactions cannot be written
%       SEVERITY: error
%       TRIGGER: a model whose bounds are empty, the case that the branch at line 449 is there for
%       OBSERVED: OutputSBML stops with "Cannot copy static.fbc_association field"
%       EXPECTED: an SBML file without reactions
%       LINES: 449
%     - DEFECT: The compartments of the model and the given lists are replaced by the defaults
%       SEVERITY: wrong-result
%       TRIGGER: writeSBML(model, fileName) for a model with comps and compNames, or lists given
%         for a model without compNames and without comps
%       OBSERVED: line 55 overwrites both fields with getDefaultCompartments, so a compartment that
%         is not a default gets the warning "Unknown compartment" and a made-up name
%       EXPECTED: the compartments and names of the model or of the lists
%       LINES: 55

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testWriteSBML'));
cd(fileDir);
fprintf('-- Running testWriteSBML ...');


testModelXML = readCbModel('Ec_iJR904.xml');

% write the model as a .sbml file
writeCbModel(testModelXML, 'sbml', 'testModelSBML.sbml');

% read the model from the newly written .sbml file
testModelSBML = readCbModel('testModelSBML.sbml');

%Due to the original model being SBML 2.1, no proteins/geneNames were
%generated.
%These models are not the same, since the References given by the xml (in
%the notes field), are not PubMed IDs, so they are transferred to the
%rxnNotes field,
testModelSBML = rmfield(testModelSBML,'rxnNotes');
testModelXML = rmfield(testModelXML,'rxnNotes');
testModelXML = rmfield(testModelXML,'rxnReferences');

% check whether both models are the same
 [isSame numDiff fieldNames] = isSameCobraModel(testModelXML, testModelSBML, 1);

% assess any potential differences
assert(~any(numDiff))

% obtain SBML structure
testSBMLstruct = writeSBML(testModelSBML,'testModelSBML.sbml');

% asses if lower/upper bounds have proper SBO terms assigned
for i = 1:length(testSBMLstruct.parameter)
    value = testSBMLstruct.parameter(i).value;
    if abs(value) == 1000 || isinf(value) || value == 0
        assert(testSBMLstruct.parameter(i).sboTerm == 626)
    else
        assert(testSBMLstruct.parameter(i).sboTerm == 625)
    end
end

% remove the written file to clean up
delete 'testModelSBML.sbml.xml';

%% The optional parts of the SBML file, one small model perturbed per section
sandboxDir = tempname;
mkdir(sandboxDir);
cd(sandboxDir);

toyModel = struct();
toyModel.mets = {'aa[c]'; 'bb[c]'; 'cc[e]'};
toyModel.metNames = {'A'; 'B'; 'C'};
toyModel.metFormulas = {'C6H12O6'; 'H2O'; 'CO2'};
toyModel.metCharges = [0; -1; 1];
toyModel.rxns = {'R1'; 'R2'};
toyModel.rxnNames = {'Reaction 1'; 'Reaction 2'};
toyModel.S = sparse([-1, 0; 1, -1; 0, 1]);
toyModel.lb = [-5; 0];
toyModel.ub = [1000; 10];
toyModel.c = [1; 0];
toyModel.b = [0; 0; 0];
toyModel.csense = ['E'; 'E'; 'E'];
toyModel.osenseStr = 'max';
toyModel.genes = {'gA'; 'gB'};
toyModel.rules = {'x(1) & x(2)'; ''};

%% Identifiers that are valid SBML ids get no prefix, and the file reads back the same
% the name of the file defaults to output
sbmlStruct = writeSBML(toyModel);
assert(exist('output.xml', 'file') == 2);
assert(strcmp(sbmlStruct.species(1).id, 'aa__91__c__93__'));
assert(strcmp(sbmlStruct.reaction(1).id, 'R1'));
assert(strcmp(sbmlStruct.fbc_geneProduct(1).fbc_id, 'G_gA'));
assert(strcmp(sbmlStruct.fbc_geneProduct(1).fbc_label, 'gA'));
assert(strcmp(sbmlStruct.id, 'COBRAModel'));
toyModelRead = readSBML('output.xml', 1000);
assert(isequal(toyModelRead.mets, toyModel.mets) && isequal(toyModelRead.rxns, toyModel.rxns));
assert(isequal(full(toyModelRead.S), full(toyModel.S)));
assert(isequal(toyModelRead.lb, toyModel.lb) && isequal(toyModelRead.ub, toyModel.ub));
assert(isequal(toyModelRead.c, toyModel.c) && strcmp(toyModelRead.osenseStr, 'max'));
assert(isequal(toyModelRead.genes, toyModel.genes) && contains(toyModelRead.rules{1}, 'x(1) & x(2)'));

%% A gene id that is no valid SBML start is covered by the G_ that every gene product gets
testCase = toyModel;
testCase.genes = {'1g'; '2g'};
sbmlStruct = writeSBML(testCase, 'digitGenes.xml');
assert(isequal({sbmlStruct.fbc_geneProduct.fbc_id}, {'G_1g', 'G_2g'}));

%% The name of the model
testCase = toyModel;
testCase.modelName = 'A toy model';
sbmlStruct = writeSBML(testCase, 'named.xml');
assert(strcmp(sbmlStruct.name, 'A toy model'));

%% The objective: minimisation, several reactions, and coefficients stored in a cell array
testCase = toyModel;
testCase.osenseStr = 'min';
testCase.c = {1; 2};
sbmlStruct = writeSBML(testCase, 'objective.xml');
assert(strcmp(sbmlStruct.fbc_objective.fbc_type, 'minimize'));
assert(isequal({sbmlStruct.fbc_objective.fbc_fluxObjective.fbc_reaction}, {'R1', 'R2'}));
assert(isequal([sbmlStruct.fbc_objective.fbc_fluxObjective.fbc_coefficient], [1, 2]));
assert(isequal(readSBML('objective.xml', 1000).c, [1; 2]));

%% Metabolites without any compartment all go to the compartment c
testCase = toyModel;
testCase.mets = {'aa'; 'bb'; 'cc'};
sbmlStruct = writeSBML(testCase, 'noCompartment.xml');
assert(isequal(unique({sbmlStruct.species.compartment}), {'c'}));
assert(isequal(readSBML('noCompartment.xml', 1000).mets, {'aa[c]'; 'bb[c]'; 'cc[c]'}));

%% A metabolite without a compartment next to others goes to u, and an unknown compartment
% gets a warning and a generated name
testCase = toyModel;
testCase.mets = {'aa'; 'bb[q]'; 'cc[c]'};
sbmlStruct = writeSBML(testCase, 'unknownCompartment.xml');
assert(strcmp(sbmlStruct.species(1).compartment, 'u'));
compartmentNames = {sbmlStruct.compartment.name};
assert(any(strncmp(compartmentNames, 'unknownCompartment', numel('unknownCompartment'))));

%% Compartments of the model without names, and that are no valid SBML ids
testCase = toyModel;
testCase.mets = {'aa[1c]'; 'bb[1c]'; 'cc[1c]'};
testCase.comps = {'1c'};
sbmlStruct = writeSBML(testCase, 'compartmentPrefix.xml');
assert(isequal({sbmlStruct.compartment.id}, {'C_1c'}));
assert(isequal({sbmlStruct.compartment.name}, {'1c'}));
assert(isequal(unique({sbmlStruct.species.compartment}), {'C_1c'}));

%% Without names, formulas and charges the species fields stay empty
testCase = rmfield(toyModel, {'metNames', 'metFormulas', 'metCharges'});
sbmlStruct = writeSBML(testCase, 'noMetaboliteFields.xml');
assert(all(cellfun(@isempty, {sbmlStruct.species.name})));
assert(all(cellfun(@isempty, {sbmlStruct.species.fbc_chemicalFormula})));
assert(~any([sbmlStruct.species.isSetfbc_charge]));

%% Formulas and charges that FBC cannot hold move to the notes, a missing charge stays unset
testCase = toyModel;
testCase.metFormulas{1} = 'C1.5H2';
testCase.metCharges = [0.5; NaN; 1];
sbmlStruct = writeSBML(testCase, 'nonInteger.xml');
assert(isempty(sbmlStruct.species(1).fbc_chemicalFormula));
assert(contains(sbmlStruct.species(1).notes, '<p>FORMULA:C1.5H2</p>'));
assert(contains(sbmlStruct.species(1).notes, '<p>CHARGE:0.5</p>'));
assert(isequal([sbmlStruct.species.isSetfbc_charge], [0, 0, 1]));

%% SBO terms: the given term, or the default where a model with this field has none
testCase = toyModel;
testCase.metSBOTerms = {'SBO:0000299'; ''; 'SBO:0000299'};
testCase.rxnSBOTerms = {'SBO:0000185'; ''};
sbmlStruct = writeSBML(testCase, 'sboTerms.xml');
assert(isequal([sbmlStruct.species.sboTerm], [299, 247, 299]));
assert(isequal([sbmlStruct.reaction.sboTerm], [185, 176]));

%% Notes: a line with a title stays, others get the title NOTES, empty lines are dropped
testCase = toyModel;
testCase.metNotes = {sprintf('titled:text\nplain text'); ''; ''};
testCase.rxnNotes = {sprintf('titled:text\nplain text'); ''};
sbmlStruct = writeSBML(testCase, 'notes.xml');
expectedNotes = {'<p>titled:text</p>', '<p>NOTES: plain text</p>'};
assert(all(cellfun(@(note) contains(sbmlStruct.species(1).notes, note), expectedNotes)));
assert(all(cellfun(@(note) contains(sbmlStruct.reaction(1).notes, note), expectedNotes)));
assert(isempty(sbmlStruct.species(2).notes) && isempty(sbmlStruct.reaction(2).notes));

%% Confidence scores stored as strings
testCase = toyModel;
testCase.rxnConfidenceScores = {'3'; '1'};
sbmlStruct = writeSBML(testCase, 'confidence.xml');
assert(contains(sbmlStruct.reaction(1).notes, 'Confidence Level: 3'));

cd(fileDir);
rmdir(sandboxDir, 's');

%read/writeSBML should be the only methods used for cobra sbml conversion.
% change the directory
cd(currentDir)

% try to shut down any left open parpool
try
    poolobj = getParallelPool();
    delete(poolobj);
catch
    % pass
end

fprintf('testWriteSBML passed!\n');
