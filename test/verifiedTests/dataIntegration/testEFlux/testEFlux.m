% The COBRAToolbox: testEFlux.m
% Aerobic and Anaerobic.txt are obtained from GEO (GSM1126445 and GSM1010240, respectively)
% 
% Purpose:
%     - Tests the eFlux function
% Author:
%     - Original file: Thomas Pfau

currentDir = pwd;
% initialize the test
fileDir = fileparts(which('testEFlux.m'));
cd(fileDir);

% requires access to GEO to download data.
% Matlabs tolerances and precision seem incompatible for this function.
solverPkgs = prepareTest('needsLP',true,'toolboxes',{'bioinformatics_toolbox'},'needsWebAddress','https://www.ncbi.nlm.nih.gov/geo/query/','excludeSolvers',{'matlab'});

model = getDistributedModel('ecoli_core_model.mat');
model = removeGenesFromModel(model,'s0001','keepReactions',true);
geoaddress = 'https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?form=text&acc=%s&view=full';
anaerobic = geosoftread(urlread(sprintf(geoaddress,'GSM1010240')));
aerobic = geosoftread(urlread(sprintf(geoaddress,'GSM1126445')));
expressionControl.preprocessed = false;
expressionControl.value = cell2mat(aerobic.Data(:,2));
expressionControl.target = cellfun(@(x) x(1:5),aerobic.Data(:,1),'Uniform',false);
expressionCondition.preprocessed = false;
expressionCondition.value = cell2mat(anaerobic.Data(:,2));
expressionCondition.target = cellfun(@(x) x(1:5),anaerobic.Data(:,1),'Uniform',false);
% There is a potential cycle between reaction 44 and 89 in the model.
% an additional cycle exists for reactions 42,43,68,92, which we will also
% ignore.
% we will ignore those reactions for the assertions.
toAssert = true(numel(model.rxns),1);
toAssert([42,43,68,92,44,89]) = false;

% return to original directory
for k = 1:numel(solverPkgs.LP)
    changeCobraSolver(solverPkgs.LP{k},'LP');
    fprintf('Testing EFlux with %s ...\n',solverPkgs.LP{k})
    [fChangeOrig,~,solContOrig,solCondOrig] = eFlux(model,expressionControl,expressionCondition);
    %anaerobic growth less than aerobic.
    assert(fChangeOrig < 1); 
    oxpos = ismember(model.rxns,'EX_o2(e)');
    % oxygen uptake in aerobic > than anaerobic (i.e. the value is smaller, exchange reaction).
    assert(solContOrig.x(oxpos) < solCondOrig.x(oxpos))
    % also test the soft bounds
    [fChangeSoft,~,solContSoft,solCondSoft] = eFlux(model,expressionControl,expressionCondition,'softBounds',true);
    %since this is punished with a value of 1, this is exactly the same as
    %the original solution. 
    assert(abs(fChangeSoft-fChangeOrig) < 1e-4);
    
    assert(all(abs(solContOrig.x(toAssert)-solContSoft.x(toAssert)) < 1e-4));
    assert(all(abs(solCondOrig.x(toAssert)-solCondSoft.x(toAssert)) < 1e-4));
    % Different use of gpr rules
    [fChange,~,solCont,solCond] = eFlux(model,expressionControl,expressionCondition,'minSum',false);
    % results are still similar.
    assert(fChange < 1); 
    oxpos = ismember(model.rxns,'EX_o2(e)');
    % oxygen uptake in aerobic > than anaerobic (i.e. the value is smaller, exchange reaction).
    assert(solCont.x(oxpos) < solCond.x(oxpos))
    
    %test this with a 1% noise.
    [fChangeNoise,stderr,solContNoise,solCondNoise] = eFlux(model,expressionControl,expressionCondition,'testNoise',true,'noiseStd',expressionControl.value*0.01);
    assert(abs(fChangeNoise-fChangeOrig) < 1e-4);
    assert(stderr > 0) % this should could be wrong at some point, but it is so unlikely....    
end
cd(currentDir)