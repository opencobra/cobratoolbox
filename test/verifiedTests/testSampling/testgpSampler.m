% The COBRAToolbox: testgpSampler.m
%
% Purpose:
%     - tests the newSampler function using the E. coli Core Model
%

% save the current path
currentDir = pwd;

% initialize the test
cd(fileparts(which(mfilename)));

changeCobraSolver('glpk');

load('ecoli_core_model.mat', 'model');

samplePoints = [5, 190];

for i = 1:length(samplePoints)
    % call sampler
    [sampleStructOut, mixedFrac] = gpSampler(model, samplePoints(i), [], 2);

    % check
    [errorsA, errorsLUB, stuckPoints] = verifyPoints(sampleStructOut);

    tmpErrorsA = ~any(errorsA);

    assert(tmpErrorsA(1) && tmpErrorsA(2))
    assert(~any(errorsLUB))
    assert(~any(stuckPoints))
end

% change the directory
cd(currentDir)
