function status = testSampleCbModel
%tests the sampleCbModel function using the E. coli Core Model

%Load required variables
load([regexprep(mfilename('fullpath'),mfilename,'') 'Ecoli_core_model.mat']);

samplers = {'ACHR' 'CHRR'}; % 'MFE'};

for i = 1:length(samplers)
    
    samplerName = samplers{i};
    
    switch samplerName
        case 'ACHR'
            fprintf('\nTesting the artificial centering hit-and-run (ACHR) sampler\n.');
            
            options.nFiles = 4;
            options.nStepsPerPoint = 1;
            options.nPointsReturned = 20;
            options.nPointsPerFile = 5;
            options.nFilesSkipped = 0;
            [modelSampling,samples,volume] = sampleCbModel(model,'EcoliModelSamples','ACHR',options);
            
            %check
            achrStatus = 0;
            %check if sample files created
            if exist('EcoliModelSamples_1.mat','file')
                if exist('EcoliModelSamples_2.mat','file')
                    if exist('EcoliModelSamples_3.mat','file')
                        if exist('EcoliModelSamples_4.mat','file')
                            display('Sample files generated');
                            %check if model reduced and rxns removed
                            removedRxns = find(~ismember(model.rxns,modelSampling.rxns));
                            if all(removedRxns == [26; 27; 29; 34; 45; 47; 52; 63])
                                display('Model reduced')
                                achrStatus = 1;
                            else
                                display('Model not reduced or loop reactions not removed properly')
                            end
                        else
                            display('Sample files not found');
                        end
                    else
                        display('Sample files not found');
                    end
                else
                    display('Sample files not found');
                end
            else
                display('Sample files not found');
            end
            
        case 'CHRR'
            fprintf('\nTesting the coordinate hit-and-run with rounding (CHRR) sampler\n.');
            
            options.nStepsPerPoint = 1;
            options.nPointsReturned = 10;
            
            chrrStatus = 0;
            
            try
                [modelSampling,samples,volume] = sampleCbModel(model,'EcoliModelSamples','CHRR',options);
                
                if norm(samples) > 0
                    chrrStatus = 1;
                end
                
            catch
                fprintf('CHRR sampler failed.\n')
            end
            
        case 'MFE'
            options.eps=0.15;
            [modelSampling,samples,volume] = sampleCbModel(model,'EcoliModelSamples','MFE',options);
            
            mfeStatus = volume > 0;
    end
    
end

status = double(achrStatus & chrrStatus); % & mfeStatus