% The COBRAToolbox: testSampleCbModel.m
%
% Purpose:
%     - tests the sampleCbModel function using the E. coli Core Model
%

% Load required variables
load('ecoli_core_model.mat', 'model');

% create a parallel pool
poolobj = gcp('nocreate');  % if no pool, do not create new one.
if isempty(poolobj)
    parpool(2);  % launch 2 workers
end

samplers = {'ACHR', 'CHRR', 'MFE'};

for i = 1:length(samplers)

    samplerName = samplers{i};

    switch samplerName
        case 'ACHR'
            fprintf('\nTesting the artificial centering hit-and-run (ACHR) sampler\n.');

            options.nFiles = 4;
            options.nStepsPerPoint = 5;
            options.nPointsReturned = 20;
            options.nPointsPerFile = 5;
            options.nFilesSkipped = 0;

            [modelSampling, samples, volume] = sampleCbModel(model, 'EcoliModelSamples', 'ACHR', options);

            % check if sample files created
            if exist('EcoliModelSamples_1.mat', 'file') == 2 && exist('EcoliModelSamples_2.mat', 'file') == 2 && exist('EcoliModelSamples_3.mat', 'file') == 2 && exist('EcoliModelSamples_4.mat', 'file') == 2
                display('Sample files generated');
                % check if model reduced and rxns removed
                removedRxns = find(~ismember(model.rxns, modelSampling.rxns));
                assert(all(removedRxns == [26; 27; 29; 34; 45; 47; 52; 63]))
            else
                display('Sample files not found');
            end

        case 'CHRR'
            fprintf('\nTesting the coordinate hit-and-run with rounding (CHRR) sampler\n.');

            options.nStepsPerPoint = 1;
            options.nPointsReturned = 10;

            [modelSampling, samples, volume] = sampleCbModel(model, 'EcoliModelSamples', 'CHRR', options);

            assert(norm(samples) > 0)

        %{
        case 'MFE'
            options.eps = 0.15;
            [modelSampling, samples, volume] = sampleCbModel(model, 'EcoliModelSamples', 'MFE', options);

            assert(volume > 0);
        %}
    end
end
