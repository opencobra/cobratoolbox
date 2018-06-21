% The COBRAToolbox: testBiomassPrecursorCheck.m
%
% Purpose:
%    - This script aims to test testBiomassPrecursorCheck.m
%
% Authors:
%    - Siu Hung Joshua Chan June 2018

% Save the current path
currentDir = pwd;

% Initialize the test
fileDir = fileparts(which('testBiomassPrecursorCheck'));
cd(fileDir);

model = readCbModel('iJO1366.mat');

% Test where there is no missing metabolite
[missingMets, presentMets] = biomassPrecursorCheck(model);
assert(isempty(missingMets))
presentMetsResult = {'10fthf_c';'2fe2s_c';'2ohph_c';'4fe4s_c';'ala__L_c';...
    'amet_c';'arg__L_c';'asn__L_c';'asp__L_c';'atp_c';'bmocogdp_c';'btn_c';...
    'ca2_c';'cl_c';'coa_c';'cobalt2_c';'ctp_c';'cu2_c';'cys__L_c';'datp_c';...
    'dctp_c';'dgtp_c';'dttp_c';'fad_c';'fe2_c';'fe3_c';'gln__L_c';'glu__L_c';...
    'gly_c';'gtp_c';'h2o_c';'his__L_c';'ile__L_c';'k_c';'kdo2lipid4_e';...
    'leu__L_c';'lys__L_c';'met__L_c';'mg2_c';'mlthf_c';'mn2_c';'mobd_c';...
    'murein5px4p_p';'nad_c';'nadp_c';'nh4_c';'ni2_c';'pe160_c';'pe160_p';...
    'pe161_c';'pe161_p';'phe__L_c';'pheme_c';'pro__L_c';'pydx5p_c';'ribflv_c';...
    'ser__L_c';'sheme_c';'so4_c';'thf_c';'thmpp_c';'thr__L_c';'trp__L_c';...
    'tyr__L_c';'udcpdp_c';'utp_c';'val__L_c';'zn2_c'};
assert(isequal(sort(presentMets), presentMetsResult))

% Test where there is a missing metabolite
model = addReaction(model,'testBiomass','reactionFormula','NotExist + amet_c -> ');
model = changeObjective(model,'testBiomass');
[missingMets, presentMets] = biomassPrecursorCheck(model);
assert(isempty(setxor(missingMets,{'NotExist'}))); % NotExist, and only NotExist is not producible.
assert(isempty(setxor(presentMets,{'amet_c'}))); % amet_c and only amet_c is producible

% Test coupling
model = createToyModelForBiomassPrecursorCheck();
% This model cannot carry flux through the objective, but each precursor can
% be produced if exchangers exist for all precursors.
[missingMets, presentMets] = biomassPrecursorCheck(model);
assert(isempty(setxor(presentMets,{'E','F'})));

% Check for coupled Mets
[missingMets, presentMets, coupledMets] = biomassPrecursorCheck(model,true);

assert(isempty(missingMets))
assert(isempty(setxor(presentMets,{'F'}))); %F can be produced, as surplus E can be removed by the biomass function.
assert(isempty(setxor(coupledMets,{'E'}))); % All E has to go to the biomass as long as there is no sink for F.

% Test error
assert(verifyCobraFunctionError('biomassPrecursorCheck','input',{model},'outputArgCount',3,'testMessage','coupledMets, missingCofs and presentCofs are not being calculated if checkCoupling is not set to true!'));

% Test cofactor pairs
model = readCbModel('ecoli_core_model.mat');
% Add a hypothetical non-producible cofactor pair
model = addReaction(model, 'COF', 'reactionFormula', 'metTest1[c] -> metTest2[c]');
model = addReaction(model, 'BIOMASS2', 'reactionFormula', 'metTest1[c] + atp[c] -> metTest2[c] + adp[c]');
% Test the function's capability to handle >1 objective reactions 
model = changeObjective(model, {'Biomass_Ecoli_core_N(w/GAM)-Nmet2'; 'BIOMASS2'}, 1);
[missingMets0, presentMets0] = biomassPrecursorCheck(model);
if exist([pwd filesep 'testBiomassPrecursorCheck.txt'], 'file')
    delete([pwd filesep 'testBiomassPrecursorCheck.txt'])
end
diary('testBiomassPrecursorCheck.txt');
[missingMets, presentMets,coupledMets, missingCofs, presentCofs] = biomassPrecursorCheck(model,true);
diary off

% Producible cofactors identified as missingMets when checkCoupling not turned on
assert(isempty(setxor(missingMets0, {'accoa[c]';'atp[c]';'nad[c]';'nadph[c]';'metTest1[c]'})))
assert(isempty(setxor(presentMets0, {'3pg[c]';'e4p[c]';'f6p[c]';'g3p[c]';'g6p[c]';...
    'gln-L[c]';'glu-L[c]';'h2o[c]';'oaa[c]';'pep[c]';'pyr[c]';'r5p[c]'})))

% No missingMets when checkCoupling turned on
assert(isempty(missingMets))
% Same set of presentMets
assert(isempty(setxor(presentMets, presentMets0)))

% missingCofs and presentCofs are identified
missingCofsStr = cellfun(@(x) strjoin(x, '|'), missingCofs, 'UniformOutput', false);
assert(isempty(setxor(missingCofsStr, {'metTest1[c]|metTest2[c]'})))
presentCofsStr = cellfun(@(x) strjoin(x, '|'), presentCofs, 'UniformOutput', false);
assert(isempty(setxor(presentCofsStr, {'nadp[c]|nadph[c]'; 'adp[c]|atp[c]'; ...
    'accoa[c]|coa[c]'; 'nad[c]|nadh[c]'})))

% Check the correct printing of the results
f = fopen('testBiomassPrecursorCheck.txt', 'r');
l = fgetl(f);
text = {};
while ~isequal(l, -1)
    text{end + 1} = l;
    l = fgetl(f);
end
fclose(f);

lineCan = find(~cellfun(@isempty, strfind(text, 'Cofactors in the biomass reaction that CAN be produced:')));
assert(isscalar(lineCan))
lineCannot = find(~cellfun(@isempty, strfind(text, 'Cofactors in the biomass reaction that CANNOT be produced:')));
assert(isscalar(lineCannot))
cofactorCan = {'nadph[c]  -> nadp[c]', 'atp[c]  -> adp[c]', 'accoa[c]  -> coa[c]', 'nad[c]  -> nadh[c]'};
cofactorCannot = {'metTest1[c]  -> metTest2[c]'};
% Correct order of printing
for j = 1:numel(cofactorCan)
    lineJ = find(~cellfun(@isempty, strfind(text, cofactorCan{j})));
    assert(~isempty(lineJ) && lineJ > lineCan && lineJ < lineCannot)
end
for j = 1:numel(cofactorCannot)
    lineJ = find(~cellfun(@isempty, strfind(text, cofactorCannot{j})));
    assert(~isempty(lineJ) && lineJ > lineCannot)
end
delete([pwd filesep 'testBiomassPrecursorCheck.txt'])

% Change the directory
cd(currentDir)
