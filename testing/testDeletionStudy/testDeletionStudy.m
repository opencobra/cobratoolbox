function x = testDeletionStudy()
%testDeletionStudy tests the basic functionality of
%singleGeneDeletion/doubleGeneDeletion/singleRxnDeletion
%   Makes sure that these resultant values are correct:
%       singleGeneDeletion - hasEffect, delRxns, grRateKO, grRateWT
%       doubleGeneDeletion - grRatioDble, grRateKO, grRateWT
%       singleRXDeletion - hasEffect, delRxn, grRateKO, grRateWT
%   returns 1 if all are correct, else 0
%
%   Joseph Kang 11/16/09

oriFolder = pwd;

test_folder = what('testDeletionStudy');
cd(test_folder.path);

tol = 0.00001;

%load model
load('ecoli_core_model.mat');

fprintf('\n*** Test basic single gene deletion: ***\n\n');
fprintf('\n*** Deleting gene for ENO: ***\n\n');
%deleting gene for 'ENO')
[grRatio,grRateKO,grRateWT,hasEffect,delRxns,fluxSolution] = singleGeneDeletion(model,'FBA',{'b2779'});

pts = 0;
if(hasEffect==1)
    display('Correct hasEffect value');
    pts = pts +1;
else
    display('Incorrect hasEffect value');
end
if(strcmp(delRxns{1}, 'ENO'))
    display('Correct deleted reactions');
    pts = pts +1;
else
    display('Incorrect deleted reactions');
end
if(abs(grRateKO) < tol)
    display('Correct grRateKO value');
    pts = pts +1;
else
    display('Incorrect grRateKO value');
end
if(abs(grRateWT) > tol)
    display('Correct grRateWT value');
    pts = pts +1;
else
    display('Incorrect grRateWT value');
end


[grRatioDble,grRateKO,grRateWT] = doubleGeneDeletion(model,'FBA',{'b2779'},{'b2287'});
if(abs(grRatioDble) < tol)
    display('Correct grRateDble value');
    pts = pts +1;
else
    display('Incorrect grRateDble value');
end
if(abs(grRateKO) < tol)
    display('Correct grRateKO value');
    pts = pts +1;
else
    display('Incorrect grRateKO value');
end
if(abs(grRateWT) > tol)
    display('Correct grRateWT value');
    pts = pts +1;
else
    display('Incorrect grRateWT value');
end

%% singleRxnDeletion Test
fprintf('\n\nStarting singleRxnDeletion test:\n');

[test_grRatio,test_grRateKO,test_grRateWT,test_hasEffect,test_delRxn]= singleRxnDeletion(model, 'FBA');
load('rxnDeletionData.mat');

% if(~isequal(isnan(grRatio), isnan(test_grRatio)))
grRatio(isnan(grRatio))=-1;
test_grRatio(isnan(test_grRatio))=-1;
if(abs(grRatio-test_grRatio)<tol)
    display('Correct grRatio values');
    pts = pts+1;
else
    disp('Incorrect grRatio values');
end

grRateKO(isnan(grRateKO))=-1;
test_grRateKO(isnan(test_grRateKO))=-1;
if(abs(grRateKO-test_grRateKO)<tol)
    display('Correct grRateKO values');
    pts = pts +1;
else
    disp('Incorrect grRateKO values');
end

if(abs(grRateWT-test_grRateWT)<tol)
    display('Correct grRateWT values');
    pts = pts +1;
else
    disp('Incorrect grRateWT values');
end

if(isequal(delRxn, test_delRxn))
    display('Correct delRxn values');
    pts = pts +1;
else
    disp('Incorrect delRxn values');
end

if(pts == 11)
    x = 1;
else
    x = 0;
end


cd(oriFolder);

end

