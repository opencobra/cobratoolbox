function status = testSampler()
%tests the newSamppler function using the E. coli Core Model


%Load required variables
load([regexprep(mfilename('fullpath'),mfilename,'') 'Ecoli_core_model.mat']);

%Call sampler
[sampleStructOut, mixedFrac] = gpSampler(model, 200, [], 60);

%check
[errorsA, errorsLUB, stuckPoints] = verifyPoints(sampleStructOut);
if any(errorsA)|any(errorsLUB)|any(stuckPoints)
    status=0;
else
    status = 1;
end