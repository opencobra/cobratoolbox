% The COBRAToolbox: testReadCbModel.m
%
% Purpose:
%     - test the readCbModel function
%
% Authors:
%     - Stefania Magnusdottir

% save the current path
currentDir = pwd;

initCobraToolbox;
global CBTDIR

% initialize the test
fileDir = fileparts(which('testReadCbModel'));
cd(fileDir);

% define tolerance
tol = 1e-6;

% read xml model version
modelXML = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep ...
    'Abiotrophia_defectiva_ATCC_49176.xml']);

% re-insert parentheses and square brackets to reactions
modelXML.rxns = strrep(modelXML.rxns, '_LPAREN_', '(');
modelXML.rxns = strrep(modelXML.rxns, '_RPAREN_', ')');
modelXML.rxns = strrep(modelXML.rxns, '_LSQBKT_', '[');
modelXML.rxns = strrep(modelXML.rxns, '_RSQBKT_', ']');

% load mat model version
load([CBTDIR filesep 'test' filesep 'models' filesep ...
    'Abiotrophia_defectiva_ATCC_49176.mat']);
modelMAT = model;

% convert to old style model
modelMAT = convertOldStyleModel(modelMAT);

% test model fields
assert(isequal(modelMAT.lb, modelXML.lb))
assert(isequal(modelMAT.b, modelXML.b))
assert(isequal(modelMAT.ub, modelXML.ub))
assert(isequal(modelMAT.mets, modelXML.mets))
assert(isequal(modelMAT.csense, modelXML.csense))
assert(isequal(modelMAT.osense, modelXML.osense))
assert(isequal(modelMAT.rxns, modelXML.rxns))
assert(isequal(modelMAT.genes, modelXML.geneNames)) %genes = geneNames in model from xml
assert(isequal(modelMAT.c, modelXML.c))
assert(isequal(modelMAT.S, modelXML.S))

% test that rules are correctly generated, i.e. no gene partially matched
% no indication of x(1)23 instead of x(123).
assert(~any(~cellfun(@isempty, regexp(modelXML.rules, '\(\d+\)\d+')))) %incorrect

% test FBA solution
solverOK = changeCobraSolver('glpk');

if solverOK
    % run an LP and compare the solutions
    solModelMAT = optimizeCbModel(modelMAT);
    solModelXML = optimizeCbModel(modelXML);
    
    assert(abs(solModelMAT.f - solModelXML.f) < tol)
    assert(solModelMAT.stat == solModelXML.stat)
end

% change to old directory
cd(currentDir);
