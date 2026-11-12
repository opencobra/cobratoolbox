% The COBRAToolbox: testEFlux.m
% Aerobic and Anaerobic.txt are obtained from GEO (GSM1126445 and GSM1010240, respectively)
% 
% Purpose:
%     - Tests the eFlux function
% Author:
%     - Original file: Thomas Pfau


% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% determine the test path for references
testPath = pwd;

% initialize the test
fprintf(' -- Running testEFlux ...\n');

% requires access to GEO to download data.
% Matlabs tolerances and precision seem incompatible for this function.
% the GEO sample tables are parsed by readGeoSampleTable (end of this file) instead of
% geosoftread (Bioinformatics Toolbox)
solverPkgs = prepareTest('needsLP',true,'needsWebAddress','https://www.ncbi.nlm.nih.gov/geo/query/','excludeSolvers',{'matlab','pdco'});

model = getDistributedModel('ecoli_core_model.mat');
model = removeGenesFromModel(model,'s0001','keepReactions',true);
geoaddress = 'https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?form=text&acc=%s&view=full';
anaerobic = readGeoSampleTable(urlread(sprintf(geoaddress,'GSM1010240')));
aerobic = readGeoSampleTable(urlread(sprintf(geoaddress,'GSM1126445')));
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

% Print a success message
fprintf('Done.\n');
fprintf('testEFlux passed successfully.\n');

cd(currentDir)

function record = readGeoSampleTable(softText)
% Reads the data table of a GEO sample (GSM) record in SOFT text format: the
% lines between '!sample_table_begin' and '!sample_table_end', whose first line
% is the header (ID_REF, VALUE, ...). Returns record.Data as an N x 2 cell array
% {ID_REF (char), VALUE (double)}, the two columns geosoftread returned and
% this test uses.
global CBT_MISSING_REQUIREMENTS_ERROR_ID
if ~contains(softText, '!sample_table_begin') || ~contains(softText, '!sample_table_end')
    % GEO answered, but not with a SOFT record (for example a browser check page): the
    % web requirement of this test is not met
    error(CBT_MISSING_REQUIREMENTS_ERROR_ID, 'GEO did not return the SOFT sample table (the response is not a GEO SOFT record).');
end
lines = splitlines(string(softText));
first = find(startsWith(lines, '!sample_table_begin'), 1) + 2; % skip the header line
last = find(startsWith(lines, '!sample_table_end'), 1) - 1;
fields = split(lines(first:last), sprintf('\t'));
if isvector(fields)
    fields = reshape(fields, 1, []);
end
record.Data = [cellstr(fields(:, 1)), num2cell(str2double(fields(:, 2)))];
end
