% The COBRAToolbox: testSampleCbModelRHMC.m
%
% Purpose:
%     - tests the sampleCbModel function using RHMC using the E. coli Core Model
%

% initialize the test
fileDir = fileparts(which('testSampleCbModelRHMC'));
models = {};
models{1} = getDistributedModel('ecoli_core_model.mat');
models{2} = getDistributedModel('Acidaminococcus_sp_D21.mat');
% load('Recon1.0model.mat', 'Recon1')
% models{3} = Recon1;
try 
   S = load('iDopaNeuro1.mat');
   names = fieldnames(S);
   models{4} = S.(names{1});
end

fprintf('   Testing sampleCbModel with RHMC ... \n' );

for i = 1:length(models)
   model = models{i};
   n = length(model.lb);
   model.vMean = randn(n,1);
   model.vCov = rand(n,1);
   options.nPointsReturned = 1000;
   
   for j = 1:3
      [modelSampling, samples, volume] = sampleCbModel(model, '', 'RHMC', options);
      modelSampling.samples = samples;
      ESS = min(effective_sample_size(samples));
      pVal = distribution_test(modelSampling);
      okay = (ESS > 100 && pVal > 0.01 && pVal < 0.99);
      if okay, break; end
   end
   assert(okay);
end

fprintf('Done.\n');
