% The COBRAToolbox: testBiomassPrecursorCheck.m
%
% Purpose:
%    - This script aims to test testBiomassPrecursorCheck.m
%
% Authors:
%    - Siu Hung Joshua Chan June 2018

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testBiomassPrecursorCheck'));
cd(fileDir);

model = readCbModel('iJO1366.mat');

% test where there is no missing metabolite
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

% test where there is a missing metabolite
model = addReaction(model,'testBiomass','reactionFormula','NotExist + amet_c -> ');
model = changeObjective(model,'testBiomass');
[missingMets, presentMets] = biomassPrecursorCheck(model);
assert(isempty(setxor(missingMets,{'NotExist'}))); % NotExist, and only NotExist is not producible.
assert(isempty(setxor(presentMets,{'amet_c'}))); % amet_c and only amet_c is producible

% change the directory
cd(currentDir)
