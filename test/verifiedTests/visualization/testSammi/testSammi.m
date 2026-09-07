% The COBRAToolbox: sammi
%
% Purpose:
%     - tests the sammi function
%
% SAMMI Visualize the given model, set of reactions, and/or data.
% Documentation at: https://sammim.readthedocs.io/en/latest/index.html
%
% Citation: Schultz, A., & Akbani, R. (2019). SAMMI: A Semi-Automated
%     Tool for the Visualization of Metabolic Networks. Bioinformatics.
%

% Get COBRA directory
global CBTDIR;

% save the current path
currentDir = pwd;

solverPkgs = prepareTest('requiredToolboxes', {'statistics_toolbox'});

% Get SAMMIM folder
sammipath = strrep(which('sammi'),'/sammi.m','');

% initialize the test
fileDir = fileparts(which('testSammi'));
cd(fileDir);

fprintf('   Testing SAMMI function ...\n')

%Set seed for consistency
rng(734)

testFile = fullfile(fileDir, 'sammi_test_output.html');
options = struct;
options.htmlName = testFile;
options.load = false;  % Suppress browser opening
options.jscode = '';

% case 0
%Load model
load([CBTDIR '/test/models/mat/ecoli_core_model.mat'])
%Plot
sammi(model, [], [], [], options);
assert(isfile(testFile));
% Remove function result
delete(testFile);
% case 1
%Load model
load([CBTDIR '/test/models/mat/Recon2.v04.mat'])
%Plot a subgraph for each subsystem
sammi(modelR204,'subSystems', [], [], options)
assert(isfile(testFile));
% Remove function result
delete(testFile);
% case 2
%Load model
load([CBTDIR '/test/models/mat/iJO1366.mat'])
%Make compartment field
x = regexp(iJO1366.mets,'_(.)$','tokens');
x = [x{:}]; x = [x{:}];
iJO1366.compartment = x';
%Plot a subgraph for each compartment
sammi(iJO1366,'compartment', [], [], options)
assert(isfile(testFile));
% Remove function result
delete(testFile);
% case 3
%Load model
load([CBTDIR '/test/models/mat/ecoli_core_model.mat'])
%Plot whole model in default file
sammi(model,[],[],[],options)
assert(isfile(testFile));
% Remove function result
delete(testFile);
%Plot model parsed by subsystem
sammi(model,'subSystems',[],[],options);
assert(isfile(testFile));
% Remove function result
delete(testFile);
% case 4
%Load model
load([CBTDIR '/test/models/mat/ecoli_core_model.mat'])
%Get reactions to plot
tca = {'ACONTa','ACONTb','AKGDH','CS','FUM','ICDHyr','MDH','SUCOAS'};
gly = {'ENO','FBA','FBP','GAPD','PDH','PFK','PGI','PGK','PGM','PPS','PYK','TPI'};
ppp = {'G6PDH2r','GND','PGL','RPE','RPI','TALA','TKT1','TKT2'};
dat = cat(2,tca,gly,ppp);
%Plot only desired reactions
sammi(model,dat, [], [], options);
assert(isfile(testFile));
% Remove function result
delete(testFile);

% case 5
%Load model
load([CBTDIR '/test/models/mat/ecoli_core_model.mat'])
%Get reactions to plot
tca = {'ACONTa','ACONTb','AKGDH','CS','FUM','ICDHyr','MDH','SUCOAS'};
gly = {'ENO','FBA','FBP','GAPD','PDH','PFK','PGI','PGK','PGM','PPS','PYK','TPI'};
ppp = {'G6PDH2r','GND','PGL','RPE','RPI','TALA','TKT1','TKT2'};
dat = cat(2,tca,gly,ppp);
%Define secondaries
secondaries = {'^h\[.\]$','^h2o\[.\]$','^o2\[.\]$','^co2\[.\]$',...
    '^atp\[.\]$','^adp\[.\]$','^pi\[.\]$',...
    '^nadh\[.\]$','^nadph\[.\]$','^nad\[.\]$','^nadp\[.\]$'};
%Plot only desired reactions
sammi(model,dat,[],secondaries, options);
assert(isfile(testFile));
% Remove function result
delete(testFile);
% case 6
%Load model
load([CBTDIR '/test/models/mat/ecoli_core_model.mat'])
%Get reactions to plot
dat = struct;
dat(1).name = 'TCA Cycle';
dat(1).rxns = {'ACONTa';'ACONTb';'AKGDH';'CS';'FUM';'ICDHyr';'MDH';'SUCOAS'};
dat(2).name = 'Glycolysis';
dat(2).rxns = {'ENO';'FBA';'FBP';'GAPD';'PDH';'PFK';'PGI';'PGK';'PGM';'PPS';'PYK';'TPI'};
dat(3).name = 'Pentose Phosphate Pathway';
dat(3).rxns = {'G6PDH2r';'GND';'PGL';'RPE';'RPI';'TALA';'TKT1';'TKT2'};
%Plot only desired reactions
sammi(model,dat, [], [], options);
assert(isfile(testFile));
% Remove function result
delete(testFile);
% case 7
%Load model
load([CBTDIR '/test/models/mat/ecoli_core_model.mat'])
%Get reactions to plot
dat(1).name = 'TCA Cycle';
dat(1).rxns = {'ACONTa';'ACONTb';'AKGDH';'CS';'FUM';'ICDHyr';'MDH';'SUCOAS'};
dat(2).name = 'Glycolysis';
dat(2).rxns = {'ENO';'FBA';'FBP';'GAPD';'PDH';'PFK';'PGI';'PGK';'PGM';'PPS';'PYK';'TPI'};
dat(3).name = 'Pentose Phosphate Pathway';
dat(3).rxns = {'G6PDH2r';'GND';'PGL';'RPE';'RPI';'TALA';'TKT1';'TKT2'};
%Add random flux
for i = 1:3; dat(i).flux = randn(length(dat(i).rxns),1); end
%Plot only desired reactions
sammi(model,dat, [], [], options);
assert(isfile(testFile));
% Remove function result
delete(testFile);
% case 8
%Load model
load([CBTDIR '/test/models/mat/ecoli_core_model.mat'])
%Define number of conditions
n = 5;
%Make reaction table with random data
rxntbl = randn(length(model.rxns),n);
rxntbl(randsample(length(model.rxns)*n,floor(n*length(model.rxns)/10))) = NaN;
rxntbl = array2table(rxntbl,'VariableNames',sprintfc('condition_%d',1:n),...
    'RowNames',model.rxns);
%Make metabolites table with random data
mettbl = randn(length(model.mets),n);
mettbl(randsample(length(model.mets)*n,floor(0.5*length(model.mets)))) = NaN;
mettbl = array2table(mettbl,'VariableNames',sprintfc('condition_%d',1:n),...
    'RowNames',model.mets);
%Make struct
dat(1).type = {'rxns' 'color'};
dat(1).data = rxntbl;
dat(2).type = {'rxns' 'size'};
dat(2).data = rxntbl;
dat(3).type = {'mets' 'color'};
dat(3).data = mettbl;
dat(4).type = {'mets' 'size'};
dat(4).data = mettbl;
dat(5).type = {'links' 'size'};
dat(5).data = rxntbl;
%Define secondaries
secondaries = {'^h\[.\]$','^h20\[.\]$','^o2\[.\]$','^co2\[.\]$',...
    '^atp\[.\]$','^adp\[.\]$','^pi\[.\]$',...
    '^nadh\[.\]$','^nadph\[.\]$','^nad\[.\]$','^nadp\[.\]$'};
%Plot dividing up by subsystems
sammi(model,'subSystems',dat,secondaries, options)
assert(isfile(testFile));
% Remove function result
delete(testFile);
% case 9
%Load model
load([CBTDIR '/test/models/mat/ecoli_core_model.mat'])
%Define number of conditions
n = 5;
%Make reaction table with random data
rxntbl = randn(length(model.rxns),n);
rxntbl(randsample(length(model.rxns)*n,floor(n*length(model.rxns)/10))) = NaN;
rxntbl = array2table(rxntbl,'VariableNames',sprintfc('condition_%d',1:n),...
    'RowNames',model.rxns);
%Make struct
dat(1).type = {'rxns' 'color'};
dat(1).data = rxntbl;
%Define secondaries
secondaries = {'^h\[.\]$','^h20\[.\]$','^o2\[.\]$','^co2\[.\]$',...
    '^atp\[.\]$','^adp\[.\]$','^pi\[.\]$',...
    '^nadh\[.\]$','^nadph\[.\]$','^nad\[.\]$','^nadp\[.\]$'};
%Define Javascript code
jscode = ['x = document.getElementById("onloadf1");' ...
    'x.value = "Citric Acid Cycle";' ...
    'onLoadSwitch(x);' ...
    'document.getElementById("fluxmin").valueAsNumber = -0.1;' ...
    'document.getElementById("fluxmax").valueAsNumber = 0.1;' ...
    'fluxmin = -0.1; fluxmax = 0.1;' ...
    'document.getElementById("edgemin").value = "#ff0000";' ...
    'document.getElementById("edgemax").value = "#0000ff";' ...
    'document.getElementById("addrxnbreak").click();' ...
    'document.getElementsByClassName("rxnbreakval")[0].value = 0;' ...
    'document.getElementsByClassName("rxnbreakcol")[0].value = "#c0c0c0";' ...
    'defineFluxColorVectors();'];
%Define options
options.jscode = jscode;
%Plot dividing up by subsystems
sammi(model,'subSystems',dat,secondaries,options)
assert(isfile(testFile));
% Remove function result
delete(testFile);
% case 10
%Load model
load([CBTDIR '/test/models/mat/ecoli_core_model.mat'])
%Define zooming option
options.jscode = 'zoom.transform(gMain, d3.zoomIdentity.translate(-1149,-863).scale(2.64));';
%Load existing model
sammi(model,fullfile(fileDir,'demo.json'),[],[],options)
assert(isfile(testFile));
% Remove function result
delete(testFile);
% case 11
%     %Load and tailor model
%     load([CBTDIR '/test/models/mat/iJO1366.mat'])
%     model = iJO1366;
%     model = changeRxnBounds(model,model.rxns(findExcRxns(model)),0,'b');
%     model = changeRxnBounds(model,'ATPM',0,'l');
%     model.csense = repmat('E',length(model.mets),1);
%     model.c = model.c*0;
%
%     %Do FVA
%     [fluxmin,fluxmax] = fastFVA(model,0);
%     %Clear numerical error
%     fluxmax(fluxmax < 1e-7) = 0;
%     fluxmin(fluxmin < -1e-7) = 0;
%
%     %Parse
%     count = 0;
%     %For each positive flux
%     for id = find(fluxmax)'
%         %Set as objective
%         model = changeObjective(model,model.rxns{id},1);
%         %Calculate fluxes
%         flux = optimizeCbModel(model,'max','one');
%         %Clear numerical error
%         flux.x(abs(flux.x) < 1e-7) = 0;
%         %Save results for plot
%         count = count+1;
%         ind = find(flux.x);
%         dat(count).name = num2str(count);
%         dat(count).rxns = model.rxns(ind);
%         dat(count).flux = flux.x(ind);
%     end
%     %For each negative flux
%     for id = find(fluxmin)'
%         %Set as objective
%         model = changeObjective(model,model.rxns{id},1);
%         %Calculate fluxes
%         flux = optimizeCbModel(model,'min','one');
%         %Clear numerical error
%         flux.x(abs(flux.x) < 1e-7) = 0;
%         %Save results for plot
%         count = count+1;
%         ind = find(flux.x);
%         dat(count).name = num2str(count);
%         dat(count).rxns = model.rxns(ind);
%         dat(count).flux = flux.x(ind);
%     end
%     %Plot
%     sammi(model,dat, [], [], options);
%     assert(isfile(testFile));
%     % Remove function result
%     delete(testFile);

% case 12
% Verify the 'subSystems' grouping mode gives identical results to the
% pre-fix unique/ismember approach for the existing flat-shape case
% (FR-004 Acceptance Scenario 2), and correctly groups a reaction
% assigned to more than one subsystem (nested-cell shape) into every
% subgraph it belongs to (FR-004 Acceptance Scenario 1, SC-003), without
% mutating model.subSystems (FR-011, SC-007).
load([CBTDIR '/test/models/mat/ecoli_core_model.mat'])

% (a) Equivalence oracle: reproduce the pre-fix unique/ismember grouping
% independently and compare it against the new matrix-based grouping,
% for the model's existing flat-char subSystems (unchanged shape).
% Excludes the empty-string name unique() included (an existing sammi.m
% quirk unrelated to this fix) since it must not appear as a subsystem
% name per spec Edge Cases, matching getModelSubSystems/buildRxn2subSystem's
% existing exclusion.
ssOld = unique(model.subSystems);
ssOld = ssOld(~cellfun('isempty', ssOld));
oldNames = ssOld;
oldRxnSets = cell(size(ssOld));
for i = 1:length(ssOld)
    oldRxnSets{i} = sort(model.rxns(ismember(model.subSystems,ssOld{i})));
end
[~, rxn2subSystemMat, subSystemNames] = buildRxn2subSystem(model, false);
newNames = subSystemNames;
newRxnSets = cell(size(subSystemNames));
for i = 1:length(subSystemNames)
    newRxnSets{i} = sort(model.rxns(logical(rxn2subSystemMat(:,i))));
end
assert(isequal(sort(oldNames), sort(newNames)), ...
    'New matrix-based subsystem name set differs from the pre-fix unique() result.');
[~, order] = ismember(oldNames, newNames);
assert(all(order > 0) && isequal(oldRxnSets, newRxnSets(order)), ...
    'New matrix-based per-subsystem reaction grouping differs from the pre-fix ismember() result.');

% (b) New capability: a reaction assigned to more than one subsystem
% (uniformly nested-cell shape, which throws today at sammi.m:156's
% unique() before this fix) must be grouped into every subgraph it
% belongs to, and sammi(...) must not throw.
modelMulti = model;
modelMulti.subSystems = cellfun(@(x) {x}, model.subSystems, 'UniformOutput', false);
multiRxn = modelMulti.rxns{1};
modelMulti.subSystems{1} = {'Glycolysis','MultiSubsystemTestMarker'};
subSystemsBefore = modelMulti.subSystems;
sammi(modelMulti,'subSystems', [], [], options);
assert(isfile(testFile));
htmlTxt = fileread(testFile);

% MultiSubsystemTestMarker is a synthetic label unique to this fixture,
% so it forms its own single-reaction subgraph
assert(~isempty(regexp(htmlTxt, ...
    ['\["MultiSubsystemTestMarker",\["' multiRxn '"\]\]'], 'once')), ...
    'Reaction was not grouped into its synthetic second subsystem.');
% Glycolysis is shared with several other reactions; bound the search
% window to just after its own label so the check cannot spill into an
% unrelated subgraph
glyStart = strfind(htmlTxt, '["Glycolysis",');
assert(~isempty(glyStart), 'Glycolysis subgraph not found in sammi output.');
glyWindow = htmlTxt(glyStart(1):min(glyStart(1)+500, numel(htmlTxt)));
assert(contains(glyWindow, ['["' multiRxn '"]']), ...
    'Reaction was not grouped into its pre-existing Glycolysis subsystem.');
assert(isequal(modelMulti.subSystems, subSystemsBefore), ...
    'sammi mutated model.subSystems.');
% Remove function result
delete(testFile);

% output a success message
fprintf('Done.\n');

% change the directory
cd(currentDir)





