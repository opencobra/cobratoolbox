% The COBRAToolbox: testAddMicrobeCommunityBiomass.m
%
% Purpose:
%     - addMicrobeCommunityBiomass appends three reactions to a model of joined microbes:
%       communityBiomass, which consumes the biomass metabolite <microbe>_biomass[c] of every
%       microbe weighted by its relative abundance (1/n each when no abundances are given) and
%       makes microbeBiomass[u]; UFEt_microbeBiomass, which moves it from [u] to [fe]; and the
%       reversible exchange EX_microbeBiomass[fe]. The formulas of the three reactions are printed
%       by printRxnFormula; this output is not suppressed.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Input: the documented input is a model with the biomass metabolites <microbe>_biomass[c]
%       of the joined microbes. It is derived from ecoli_core_model by adding the biomass
%       metabolites of two microbes, EcoliA and EcoliB, with addMultipleMetabolites.
%     - Reference values: the reaction and metabolite counts asserted below were recorded from the
%       first run on 2026-11-03 (no solver). They were not derived independently, so they guard
%       consistency, not independent correctness (Tier 5). The stoichiometric coefficients are
%       also derived from the abundances.
%     - The weights tested (1/2, 0.25 and 0.75) have at most six significant digits, so they are
%       not affected by the rounding defect below; weights with more digits are skipped.
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/addMicrobeCommunityBiomass.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; ecoli_core_model loaded through getDistributedModel.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Abundance weights are rounded to six significant digits
%       SEVERITY: wrong-result
%       TRIGGER: weights with more than six significant digits, for example three microbes
%         without abundances (weights 1/3) or abundances [0.123456789; 0.2; 0.676543211]
%       OBSERVED: the reactions are added through their printed formulas (printRxnFormula, then
%         addReaction), so the coefficients become -0.333333 (sum 0.999999) and -0.123457,
%         -0.676543 instead of the given weights
%       EXPECTED: the coefficients of communityBiomass equal the given abundances, or 1/n, exactly
%       LINES: 47-50
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddMicrobeCommunityBiomass'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed
prepareTest();

% load the model once (95 reactions, 72 metabolites) and add the biomass metabolites of two
% microbes (74 metabolites)
model = getDistributedModel('ecoli_core_model.mat');
microbeNames = {'EcoliA'; 'EcoliB'};
model = addMultipleMetabolites(model, strcat(microbeNames, '_biomass[c]'));
[nMets, nRxns] = size(model.S);

% the added reactions and metabolites, in the order in which they are appended
newRxns = {'communityBiomass'; 'UFEt_microbeBiomass'; 'EX_microbeBiomass[fe]'};
newMets = {'microbeBiomass[u]'; 'microbeBiomass[fe]'};

% the reaction- and metabolite-sized fields of ecoli_core_model, for the structural checks
rxnFields = {'rxns', 'lb', 'ub', 'c', 'rules', 'grRules', 'rxnNames', 'subSystems'};
metFields = {'mets', 'b', 'csense', 'metNames', 'metFormulas'};

%% no abundances: every microbe gets the weight 1/n

communityModel = addMicrobeCommunityBiomass(model, microbeNames);

% three reactions and two metabolites are appended (Tier-5 counts, first run 2026-11-03)
assert(isequal(communityModel.rxns, [model.rxns; newRxns]));
assert(isequal(communityModel.mets, [model.mets; newMets]));
assert(numel(communityModel.rxns) == 98 && numel(communityModel.mets) == 76);

% the result is structurally consistent: S matches mets and rxns, every reaction- and
% metabolite-sized field has one row per entry, rxnGeneMat is reactions x genes and the rules
% only use existing gene indices
nNewRxns = numel(communityModel.rxns);
nNewMets = numel(communityModel.mets);
assert(isequal(size(communityModel.S), [nNewMets, nNewRxns]));
assert(all(cellfun(@(f) size(communityModel.(f), 1) == nNewRxns, rxnFields)));
assert(all(cellfun(@(f) size(communityModel.(f), 1) == nNewMets, metFields)));
assert(isequal(size(communityModel.rxnGeneMat), [nNewRxns, numel(communityModel.genes)]));
ruleGeneIdx = str2double(regexp(strjoin(communityModel.rules', ' '), '(?<=x\()\d+(?=\))', 'match'));
assert(all(ruleGeneIdx >= 1 & ruleGeneIdx <= numel(communityModel.genes)));

% the input model is unchanged
assert(isequal(communityModel.S(1:nMets, 1:nRxns), model.S));
assert(isequal(communityModel.lb(1:nRxns), model.lb) && isequal(communityModel.ub(1:nRxns), model.ub));
assert(isequal(communityModel.genes, model.genes));

% the new columns: the community biomass consumes each microbe biomass with weight 1/2 and makes
% microbeBiomass[u], which is moved to [fe] and exchanged (exact: 1/2 is a binary fraction)
expectedS = zeros(nNewMets, 3);
[~, biomassIdx] = ismember(strcat(microbeNames, '_biomass[c]'), communityModel.mets);
expectedS(biomassIdx, 1) = -1 / numel(microbeNames);
expectedS(nMets + 1, 1:2) = [1, -1];
expectedS(nMets + 2, 2:3) = [1, -1];
assert(isequal(full(communityModel.S(:, nRxns + (1:3))), expectedS));

% bounds: the community biomass and the transport are irreversible, the exchange is reversible
assert(isequal(communityModel.lb(nRxns + (1:3)), [0; 0; -1000]));
assert(isequal(communityModel.ub(nRxns + (1:3)), [1000; 1000; 1000]));

% an empty abundance vector also gives equal weights
assert(isequal(addMicrobeCommunityBiomass(model, microbeNames, []), communityModel));

%% given abundances are the weights of the microbe biomass metabolites

abundances = [0.25; 0.75];
communityModel = addMicrobeCommunityBiomass(model, microbeNames, abundances);

% the same reactions and metabolites are appended (Tier-5 counts, first run 2026-11-03)
assert(isequal(communityModel.rxns, [model.rxns; newRxns]));
assert(isequal(communityModel.mets, [model.mets; newMets]));
assert(numel(communityModel.rxns) == 98 && numel(communityModel.mets) == 76);
assert(isequal(size(communityModel.S), [numel(communityModel.mets), numel(communityModel.rxns)]));

% the community biomass consumes each microbe biomass with its abundance (exact: 0.25 and 0.75
% are binary fractions); the transport and exchange columns are as without abundances
[~, biomassIdx] = ismember(strcat(microbeNames, '_biomass[c]'), communityModel.mets);
assert(isequal(full(communityModel.S(biomassIdx, nRxns + 1)), -abundances));
assert(isequal(full(communityModel.S(nMets + (1:2), nRxns + (1:3))), [1, -1, 0; 0, 1, -1]));
assert(nnz(communityModel.S(:, nRxns + 1)) == numel(microbeNames) + 1);
assert(isequal(communityModel.S(1:nMets, 1:nRxns), model.S));

% change the directory
cd(currentDir)
