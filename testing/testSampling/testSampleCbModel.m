function status = testSampleCbModel
%tests the newSamppler function using the E. coli Core Model


%Load required variables
load([regexprep(mfilename('fullpath'),mfilename,'') 'Ecoli_core_model.mat']);

options.nFiles = 4;
options.nPointsReturned = 200;
[modelSampling,samples] = sampleCbModel(model,'EcoliModelSamples','ACHR',options);

%check
status = 0;
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
                    status = 1;
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