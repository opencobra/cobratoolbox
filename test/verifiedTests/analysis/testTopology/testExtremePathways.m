% The COBRAToolbox: testExtremePathways.m
%
% Purpose:
%     - testExtremePathways tests the functionality of lsr and extremePathways.
%
% Authors:
%     - Sylvain Arreckx March 2017
%
% Test problem from
%     Extreme Pathway Lengths and Reaction Participation in Genome-Scale Metabolic Networks
%     Jason A. Papin, Nathan D. Price and Bernhard Ø. Palsson

COBRARequisitesFullfilled('needsUnix',true);

[status, result] = system('which lrs');
assert( ~isempty(strfind(result, '/lrs')),'lrs was not properly installed on your system'); %Which returns the path with /!
    
% save the current path
currentDir = pwd;
    
% initialize the test
fileDir = fileparts(which('testExtremePathways'));
cd(fileDir);
model = createExtremePathwayModel();
    
minimalModel = struct();
minimalModel.S = model.S;
    
% calculates the matrix of extreme pathways, P
[P, V] = extremePathways(minimalModel);
    
refP = [2, 2, 2;
    1, 0, 1;
    0, 1, 0;
    0, 1, 1;
    0, 0, 1;
    1, 0, 0;
    2, 2, 2;
    1, 1, 1;
    1, 1, 1];
    
assert(all(all(refP(:, [2, 1, 3]) == P)))
    
positivity = 0;
inequality = 1;
    
[P, V] = extremePathways(model, positivity, inequality)
    
refP = [ 0,  0, 2;
    1,  1, 0;
    -1, -1, 1;
    0, -1, 1;
    1,  0, 0;
    0,  1, 0;
    0,  0, 2;
    0,  0, 1;
    0,  0, 1];
    
assert(all(all(refP == P)))
    
% Change the model to have one non integer entry.
model.S(1, 1) = 0.5;
assert(verifyCobraFunctionError(@() extremePathways(model)));
    
% delete generated files
delete('*.ine');
delete('*.ext');
    
% change the directory
cd(currentDir)
