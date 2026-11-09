% The COBRAToolbox: testReadSBML.m
%
% Purpose:
%     - reads all the sbml files in this folder and
%       checks if all the parameters are correctly written
%     - loads certain xml files, runs and FBA, and compares the
%       solution to pre-calculated values from FBAs run with .mat files
%
% Authors:
%     - Partial original file: Joseph Kang 04/07/09
%     - CI integration: Laurent Heirendt
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%
% Function under test:
%     src/base/io/utilities/readSBML.m
%
% Coverage exemptions:
%     Lines 141, 145, 292, 296: unreachable. The fallback for releases without pad; pad exists in
%     every supported MATLAB release and cannot fail on an SBO term, which has seven digits.
%     Lines 218, 225: unreachable. parseSBMLNotesField always returns a subsystem as a cell, so
%     the subsystems are never all numeric and never all char.
%     Line 269: unreachable. The field genes was set a few lines above, in both branches.
%     Lines 333-335: unreachable. TranslateSBML always returns a kineticLaw field.
%     Line 535: unreachable. The only caller asks for a field that TranslateSBML always returns
%     for an fbc model.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented default of defaultBound does not exist
%       SEVERITY: error
%       TRIGGER: readSBML(fileName), without the optional input defaultBound
%       OBSERVED: the call stops with "Not enough input arguments" where the bound is first used
%       EXPECTED: the default of 1000 given in the help text
%       LINES: 310
%
% Note:
%     - The solver libraries must be included separately

global CBTDIR

%Check the requirements (a LP solver is necessary)
solvers = prepareTest('needsLP',true,'requireOneSolverOf',{'gurobi','ibm_cplex','glpk','mosek','quadMinos'});

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReadSBML'));
cd(fileDir);

%Check if the model contains the same information

% initialize the test
cd([CBTDIR, filesep, 'test', filesep, 'models']);


% load the models
modelArr = { 'Abiotrophia_defectiva_ATCC_49176.xml', 'STM_v1.0.xml', 'iIT341.xml'};

%loop through the models
for i = 1:length(modelArr)
    %reading the models takes quite a bit of time, so only do it once for
    %all solvers.
    % output a line before launching the test for model i
    fprintf('   Testing %s ...\n', modelArr{i});
    
    % load the model (actually supply the full filename of the path
    % where the model is found)
    model = getDistributedModel(modelArr{i});
    for k = 1:length(solvers.LP)
        fprintf(' -- Running testReadSBML using the solver interface: %s ... ', solvers.LP{k});
        solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
        
        fprintf('   Testing loaded model ... \n');
        
        % set the tolerance
        tol = 1e-6;
        
        
        % define the maximum objective values calculated from pre-converted .mat files
        modelFBAf_max = [0.149475406282249; 0.477833660760744; 0.692812693473487];
        
        % define the minimum objective values
        modelFBAf_min = [0.0; 0.0; 0.0];
        
        % solve the maximisation problem
        FBA = optimizeCbModel(model, 'max');
        
        % test the maximisation solution
        assert(FBA.stat == 1);
        assert(abs(FBA.f - modelFBAf_max(i)) < tol);
        assert(norm(model.S * FBA.x) < tol);
        
        % solve the minimisation problem
        FBA = optimizeCbModel(model, 'min');
        
        % test the minimisation solution
        assert(FBA.stat == 1);
        assert(abs(FBA.f - modelFBAf_min(i)) < tol);
        assert(norm(model.S * FBA.x) < tol);
        
        % print a line for success of loop i
        fprintf(' Done.\n');
        
        
        % test that gene rules are generated correctly
        % needs testing on model with large number of genes, i.e.,
        % 'Abiotrophia_defectiva_ATCC_49176.xml'
        if strcmp(modelArr{i}, 'Abiotrophia_defectiva_ATCC_49176.xml')
            % test that rules are correctly generated, i.e. no gene partially matched
            % no indication of x(1)23 instead of x(123).
            assert(~any(~cellfun(@isempty, regexp(model.rules, '\(\d+\)\d+')))) %incorrect
        end
    end
end

% test reading COBRA models with symbols in objective reactions and multiple objective reactions
for jTest = 1:2
    if jTest == 1
        % test objective reactions with symbols
        fprintf('   Testing readSBML for models with symbols in objective reactions ...\n');
        model = createModel({'EX_a(e)'; 'EX_b(e)'}, {'Test A'; 'Test B'}, {'a[e] <=>'; 'b[e] <=>'});
        model.c = [1; 0];

    elseif jTest == 2
        % test more than one objective reactions with >1 objective reactions
        fprintf('   Testing readSBML for models with >1 objective reactions ...\n');
        model = createModel({'EX_a'; 'EX_b'}, {'Test A'; 'Test B'}, {'a[e] <=>'; 'b[e] <=>'});
        model.c = [1; -2];
    end

    model.lb = model.lb(:);
    model.ub = model.ub(:);
    model.comps = {'e'};
    model.compNames = {'ExtraCellular'};
    % add the fields outputted by readSBML
    [model.modelVersion.SBML_level, model.modelVersion.SBML_version, model.modelVersion.fbc_version] = deal(3, 1, 2);
    model.metCharges = zeros(numel(model.mets), 1);
    model.metFormulas = {'C'; 'C'};
    model.osense = -1;
    model.description = 'test_sbml_obj.xml';
    model.genes = {'gene1'; 'gene2'};
    model.rules = {''; ''};
    model.rxnGeneMat = zeros(2, 2);
    model.subSystems = {'s1'; 's2'}

    model = convertOldStyleModel(model);

    % write the model
    writeCbModel(model, 'sbml', 'test_sbml_obj');


    % read in the model
    model2 = readCbModel('test_sbml_obj.xml');    
    %We are creating a few default fields in readCbModel. 
    DefaultFields = {'S','b','csense','lb','ub','c','osense','rxns','mets','genes','rules','subSystems'};

    model2 = convertOldStyleModel(model2);
    
    modelFields = fieldnames(model);    
    modelFields = setdiff(modelFields,'rxnGeneMat'); %rxnGeneMat did not contain any information and is not created by readCbModel.
    for i = 1:numel(modelFields)
        if iscell(model.(modelFields{i}))
            if ~all(cellfun(@isempty, model.(modelFields{i})))  || any(ismember(modelFields{i},DefaultFields))
                assert(isequal(model.(modelFields{i}),model2.(modelFields{i})));
            else
                assert(~isfield(model2, modelFields{i}));
            end
        else
            if isnumeric(model.(modelFields{i}))
                if ~all(isnan(model.(modelFields{i})(:))) || any(ismember(modelFields{i},DefaultFields))                                        
                    assert(isequal(model.(modelFields{i})(~isnan(model.(modelFields{i}))),model2.(modelFields{i})(~isnan(model.(modelFields{i})))));
                    assert(isequal(~isnan(model.(modelFields{i})),~isnan(model2.(modelFields{i}))));
                else
                    assert(~isfield(model2, modelFields{i}));
                end
            else
                %Not numeric, i.e. another field.
                assert(isequal(model.(modelFields{i}),model2.(modelFields{i})));
            end
        end
    end
    fprintf(' Done.\n\n');
end
delete('test_sbml_obj.xml')

%% A hand-written SBML level 2 file: annotations on all elements, no fbc package, no kinetic law
sandboxDir = tempname;
mkdir(sandboxDir);
rdfAnnotation = @(about, qualifier, uri) ['<annotation><rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" ', ...
    'xmlns:bqbiol="http://biomodels.net/biology-qualifiers/" xmlns:bqmodel="http://biomodels.net/model-qualifiers/">', ...
    '<rdf:Description rdf:about="#', about, '"><', qualifier, '><rdf:Bag><rdf:li rdf:resource="', uri, '"/></rdf:Bag></', qualifier, '>', ...
    '</rdf:Description></rdf:RDF></annotation>'];
sbmlText = ['<?xml version="1.0" encoding="UTF-8"?>', newline, ...
    '<sbml xmlns="http://www.sbml.org/sbml/level2/version4" level="2" version="4"><model id="fixture">', ...
    '<listOfCompartments><compartment metaid="cyt" id="cyt" size="1">', ...
    rdfAnnotation('cyt', 'bqbiol:is', 'http://identifiers.org/go/GO:0005737'), '</compartment></listOfCompartments>', ...
    '<listOfSpecies>', ...
    '<species metaid="s1" id="M_aa_cyt" compartment="cyt">', ...
    rdfAnnotation('s1', 'bqbiol:hasProperty', 'http://identifiers.org/sbo/SBO:0000247'), '</species>', ...
    '<species metaid="s2" id="M_bb_cyt" compartment="cyt" sboTerm="SBO:0000299"/>', ...
    '</listOfSpecies><listOfReactions>', ...
    '<reaction metaid="r1" id="R_r1" reversible="false">', ...
    '<notes><html xmlns="http://www.w3.org/1999/xhtml"><p>SUBSYSTEM: first;second</p></html></notes>', ...
    rdfAnnotation('r1', 'bqbiol:hasProperty', 'http://identifiers.org/sbo/SBO:0000176'), ...
    '<listOfReactants><speciesReference species="M_aa_cyt"/></listOfReactants>', ...
    '<listOfProducts><speciesReference species="M_bb_cyt"/></listOfProducts></reaction>', ...
    '<reaction metaid="r2" id="R_r2" reversible="true" sboTerm="SBO:0000185">', ...
    rdfAnnotation('r2', 'bqbiol:isDescribedBy', 'http://identifiers.org/pubmed/12345'), ...
    '<listOfReactants><speciesReference species="M_bb_cyt"/></listOfReactants></reaction>', ...
    '</listOfReactions></model></sbml>'];
annotatedFile = [sandboxDir filesep 'annotated.xml'];
fid = fopen(annotatedFile, 'w');
fprintf(fid, '%s', sbmlText);
fclose(fid);

% a metabolite id that ends in its compartment id, of any length, gets the usual bracket
annotatedModel = readSBML(annotatedFile, 500);
assert(isequal(annotatedModel.mets, {'aa[cyt]'; 'bb[cyt]'}));
assert(isequal(annotatedModel.rxns, {'r1'; 'r2'}));
assert(isequal(annotatedModel.S, [-1, 0; 1, -1]));
% the annotations reach their fields, and a term in the annotation wins over the sboTerm attribute
assert(isequal(annotatedModel.compisgoID, {'GO:0005737'}));
assert(isequal(annotatedModel.metSBOTerms, {'SBO:0000247'; 'SBO:0000299'}));
assert(isequal(annotatedModel.rxnSBOTerms, {'SBO:0000176'; 'SBO:0000185'}));
assert(isequal(annotatedModel.rxnReferences, {''; '12345'}));
% without kinetic laws the bounds follow from the reversibility and the default bound
assert(isequal(annotatedModel.lb, [0; -500]));
assert(isequal(annotatedModel.ub, [500; 500]));
assert(isequal(annotatedModel.c, [0; 0]));
% a reaction with two subsystems makes all entries cells
assert(isequal(annotatedModel.subSystems{1}, {'first', 'second'}));
assert(iscell(annotatedModel.subSystems{2}));

%% A metabolite id without any compartment information gets the compartment of its species
noSuffixFile = [sandboxDir filesep 'noSuffix.xml'];
fid = fopen(noSuffixFile, 'w');
fprintf(fid, '%s', strrep(sbmlText, '_cyt"', '"'));
fclose(fid);
noSuffixModel = readSBML(noSuffixFile, 500);
assert(isequal(noSuffixModel.mets, {'aa[cyt]'; 'bb[cyt]'}));

%% Compartments that only got the prefix C_ for the SBML file lose it again
compModel = createModel({'R1'}, {'Reaction 1'}, {'aa[1c] -> bb[1c]'});
compModel.comps = {'1c'};
compFile = [sandboxDir filesep 'prefixed.xml'];
writeCbModel(compModel, 'format', 'sbml', 'fileName', compFile);
assert(contains(fileread(compFile), 'id="C_1c"'));
compModelRead = readSBML(compFile, 1000);
assert(isequal(compModelRead.comps, {'1c'}));
assert(isequal(compModelRead.mets, {'aa[1c]'; 'bb[1c]'}));

rmdir(sandboxDir, 's');

% change the directory
cd(currentDir)
