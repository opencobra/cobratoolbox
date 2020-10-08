% The COBRAToolbox: testWriteSBML.m
%
% Purpose:
%     - read in a model from a .xml file, write it as a .sbml file,
%       read it back in and assess any differences
%
% Authors:
%     - Partial original file: Joseph Kang 04/07/09
%     - CI integration: Laurent Heirendt

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testWriteSBML'));
cd(fileDir);

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
 [isSame numDiff fieldNames] = isSameCobraModel(testModelXML, testModelSBML);

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

%read/writeSBML should be the only methods used for cobra sbml conversion.
% change the directory
cd(currentDir)

% try to shut down any left open parpool
try
    poolobj = gcp('nocreate');
    delete(poolobj);
catch
    % pass
end
