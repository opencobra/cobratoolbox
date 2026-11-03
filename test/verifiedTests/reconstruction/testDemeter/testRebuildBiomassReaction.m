% The COBRAToolbox: testRebuildBiomassReaction.m
%
% Purpose:
%     - rebuildBiomassReaction (DEMETER) rebuilds the biomass reaction of a reconstruction from
%       the taxonomy of the organism in a table (infoFile: a header row and one row per
%       organism, with the columns Phylum, Genus and Gram Staining). For gram-positive
%       organisms (and gram-negative ones of a few genera or of the phylum Deinococcus-Thermus)
%       it removes lipopolysaccharide (colipa[c]) from the biomass, adds teichoic acids if the
%       biomass has none, adds udpglcur[c] and teich_45_BS[c] if the model has them (removing
%       their demand reactions), and adds the missing reactions of teichoic acid synthesis from
%       the database. For gram-negative organisms it removes teichoic acids, adds colipa[c] if
%       missing, adds dtdprmn[c] and kdo2lipid4L[c] if the model has them (removing their demand
%       reactions) and adds the missing reactions of lipopolysaccharide synthesis. The rebuilt
%       biomass reaction is appended to the model and made the objective. Organisms without a
%       gram status are left unchanged, and an organism missing from the table gives a warning.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Inputs: the AGORA model Acidaminococcus_fermentans_DSM_20731 (biomass400; it has colipa[c]
%       but no teichoic acid in its biomass, and the metabolites udpglcur[c], teich_45_BS[c],
%       dtdprmn[c] and kdo2lipid4L[c]); the taxonomy tables are written in each section, so the
%       same model is also rebuilt as a gram-positive organism. Where a branch needs it, the
%       model is changed first: a demand reaction is added (DM_udpglcur(c), DM_dtdprmn(c)) or
%       colipa[c] is taken out of the biomass. The database is the VMH database shipped with the
%       toolbox (loadVMHDatabase).
%     - Reference values: the expected biomass coefficients are derived independently from the
%       biomass of the input model and the factors the help and comments of the function state;
%       the lists of added reactions were recorded from the first run on 2026-11-03 with this
%       model (no solver). They were not derived independently, so they guard consistency, not
%       independent correctness (Tier 5). The coefficients of this biomass have at most five
%       significant digits, so writing them into a formula with num2str keeps them exactly
%       (see the last defect below).
%     - loadVMHDatabase declares two global variables; the test removes the ones it created.
%
% Function under test:
%     src/reconstruction/demeter/src/refinement/rebuildBiomassReaction.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; Acidaminococcus_fermentans_DSM_20731 (an AGORA
%     model, the nomenclature of the function) loaded through getDistributedModel.
%
% Coverage exemptions:
%     Lines 51-107, the phylum Tenericutes: the rebuilt biomass reaction is not made the
%     objective (defect below), so the input is skipped.
%     Lines 111-182, the archaeal phyla: the call stops with an error (defect below), so the
%     input is skipped.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The model has no objective after rebuilding the biomass of Tenericutes
%       SEVERITY: wrong-result
%       TRIGGER: an organism of the phylum Tenericutes in the taxonomy table
%       OBSERVED: the biomass reaction is removed and appended again with addReaction, whose
%         objective coefficient is 0, and changeObjective is not called (as it is in the other
%         branches), so every entry of model.c is 0
%       EXPECTED: the rebuilt biomass reaction is the objective, as for all other organisms
%       LINES: 97
%     - DEFECT: Rebuilding the biomass of Archaea stops with an error
%       SEVERITY: error
%       TRIGGER: an organism of the phylum Euryarchaeota, Crenarchaeota or Thaumarchaeota
%       OBSERVED: the loop over the archaeal lipids uses size(archaealComp), a vector, as colon
%         operand: MATLAB R2025a stops with "Colon operands must be real scalars." (older
%         releases use the first element, 1, so only dpgpi[c] of the nine lipids is added)
%       EXPECTED: all nine archaeal lipids added to the biomass (a loop over
%         numel(archaealComp))
%       LINES: 140
%     - DEFECT: Biomass coefficients are rounded to about five significant digits
%       SEVERITY: limitation
%       TRIGGER: a biomass coefficient with more significant digits than num2str keeps, for
%         example 0.123456 (written as 0.12346)
%       OBSERVED: the rebuilt reaction is written as a formula with num2str, which keeps five
%         significant digits for values below 10, so the coefficients of the components that are
%         kept change
%       EXPECTED: the coefficients of the kept components unchanged
%       LINES: 81, 83, 90, 92, 166, 168, 175, 177, 265, 267, 274, 276, 327, 329, 336, 338
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRebuildBiomassReaction'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed
prepareTest();

% load the reaction database once; loadVMHDatabase declares the global variables
% additionalSecretionRxns and additionalUptakeRxns, which are removed again if they did not
% exist before
databaseGlobals = {'additionalSecretionRxns', 'additionalUptakeRxns'};
existingGlobals = ismember(databaseGlobals, who('global'));
database = loadVMHDatabase;
for k = find(~existingGlobals)
    clearvars('-global', databaseGlobals{k});
end

% load the model once (1102 reactions, 1013 metabolites, 637 genes; biomass400 is the last
% reaction and the objective)
microbeID = 'Acidaminococcus_fermentans_DSM_20731';
biomassRxn = 'biomass400';
model = getDistributedModel([microbeID '.mat']);
originalBiomass = full(model.S(:, strcmp(model.rxns, biomassRxn)));

% the taxonomy table: a header row and the row of this organism
infoHeader = {'MicrobeID', 'Phylum', 'Genus', 'Gram Staining'};
gramNegInfo = [infoHeader; {microbeID, 'Firmicutes', 'Acidaminococcus', 'Gram-'}];
gramPosInfo = [infoHeader; {microbeID, 'Firmicutes', 'Acidaminococcus', 'Gram+'}];

% the reactions of lipopolysaccharide (gram-negative) and teichoic acid (gram-positive)
% synthesis that this model lacks and the function adds (Tier-5 lists, first run 2026-11-03)
gramNegAddedRxns = {'3OAS121'; '3OAS141'; '3OAS161'; '3OAS181'; 'ARABDt2'; 'DDCAt'; 'EX_arab_D(e)'; ...
    'EX_ddca(e)'; 'KDOS'; 'TDPADGAT'; 'TDPAGTA'};
gramPosAddedRxns = {'ALAPGPL'; 'CDPGLYCGPT'; 'G3PCT'; 'PGPGT'; 'TECA4S'; 'TECAAE'; 'TECAGE'; 'TECAUE'; 'UACMAMO'};

% the reaction- and metabolite-sized fields of this model, for the structural checks
rxnFields = {'rxns', 'lb', 'ub', 'c', 'rules', 'grRules', 'rxnGeneMat', 'rxnConfidenceScores', ...
    'rxnNames', 'rxnECNumbers', 'rxnKEGGID', 'subSystems'};
metFields = {'mets', 'b', 'csense', 'metCharges', 'metFormulas', 'metSmiles', 'metNames', ...
    'metHMDBID', 'metInChIString', 'metKEGGID', 'metChEBIID', 'metPubChemID'};

%% gram-negative organism: demand reaction removed, cell wall components added

% the model with a demand reaction for dtdprmn[c], which the function removes
inputModel = addReaction(model, 'DM_dtdprmn(c)', 'reactionFormula', 'dtdprmn[c] ->');
[newModel, removedBioComp, addedRxns] = rebuildBiomassReaction(inputModel, microbeID, biomassRxn, database, gramNegInfo);

% no teichoic acid was in the biomass, so nothing is removed; the missing reactions of
% lipopolysaccharide synthesis are added
assert(isempty(removedBioComp));
assert(isequal(sort(addedRxns(:)), gramNegAddedRxns));
assert(~any(ismember(addedRxns, inputModel.rxns)));

% the reactions: the input reactions without the biomass and the demand reaction, in their
% order, then the rebuilt biomass reaction, then the added reactions
keptRxns = setdiff(inputModel.rxns, {biomassRxn, 'DM_dtdprmn(c)'}, 'stable');
assert(isequal(newModel.rxns, [keptRxns; {biomassRxn}; addedRxns(:)]));

% the result is structurally consistent: S matches mets and rxns, every reaction- and
% metabolite-sized field has one entry per reaction or metabolite, rxnGeneMat is reactions x
% genes and the rules only use existing gene indices
nRxns = numel(newModel.rxns);
nMets = numel(newModel.mets);
assert(isequal(size(newModel.S), [nMets, nRxns]));
assert(all(cellfun(@(f) size(newModel.(f), 1) == nRxns, rxnFields)));
assert(all(cellfun(@(f) size(newModel.(f), 1) == nMets, metFields)));
assert(isequal(size(newModel.rxnGeneMat), [nRxns, numel(newModel.genes)]));
ruleGeneIdx = str2double(regexp(strjoin(newModel.rules', ' '), '(?<=x\()\d+(?=\))', 'match'));
assert(all(ruleGeneIdx >= 1 & ruleGeneIdx <= numel(newModel.genes)));

% the kept reactions are unchanged
[~, keptIdx] = ismember(keptRxns, inputModel.rxns);
assert(isequal(newModel.S(1:numel(inputModel.mets), 1:numel(keptRxns)), inputModel.S(:, keptIdx)));
assert(isequal(newModel.lb(1:numel(keptRxns)), inputModel.lb(keptIdx)) && isequal(newModel.ub(1:numel(keptRxns)), inputModel.ub(keptIdx)));

% the rebuilt biomass reaction is the objective; it keeps every coefficient of the input
% biomass and gets dtdprmn[c] and kdo2lipid4L[c] with the factor 0.02504 (the model has both;
% colipa[c] is already in the biomass)
assert(isequal(find(newModel.c), nRxns - numel(addedRxns)) && newModel.c(strcmp(newModel.rxns, biomassRxn)) == 1);
expectedBiomass = [originalBiomass; zeros(nMets - numel(model.mets), 1)];
expectedBiomass(findMetIDs(newModel, {'dtdprmn[c]', 'kdo2lipid4L[c]'})) = -0.02504;
assert(isequal(full(newModel.S(:, strcmp(newModel.rxns, biomassRxn))), expectedBiomass));
assert(newModel.lb(strcmp(newModel.rxns, biomassRxn)) == 0 && newModel.ub(strcmp(newModel.rxns, biomassRxn)) == 1000);

% the added reactions have the database formula (the same metabolites) and the gene rule
% demeterGapfill, which is added to the genes
for k = 1:numel(addedRxns)
    formula = database.reactions{strcmp(database.reactions(:, 1), addedRxns{k}), 3};
    rxnMets = sort(newModel.mets(newModel.S(:, strcmp(newModel.rxns, addedRxns{k})) ~= 0));
    assert(isequal(rxnMets, unique(regexp(formula, '[^\s]+\[[a-z]\]', 'match'))'), addedRxns{k});
end
assert(all(strcmp(newModel.grRules(end - numel(addedRxns) + 1:end), 'demeterGapfill')));
assert(isequal(newModel.genes, [model.genes; {'demeterGapfill'}]));

%% gram-negative organism without lipopolysaccharide in the biomass: colipa[c] is added

% the model with colipa[c] taken out of the biomass
inputModel = model;
inputModel.S(findMetIDs(model, 'colipa[c]'), strcmp(model.rxns, biomassRxn)) = 0;
[newModel, removedBioComp, addedRxns] = rebuildBiomassReaction(inputModel, microbeID, biomassRxn, database, gramNegInfo);

% colipa[c] comes back with the factor 0.025039, besides dtdprmn[c] and kdo2lipid4L[c]; the
% same reactions are added as for the distributed model (no demand reaction to remove)
assert(isempty(removedBioComp));
assert(isequal(sort(addedRxns(:)), gramNegAddedRxns));
nMets = numel(newModel.mets);
expectedBiomass = [inputModel.S(:, strcmp(model.rxns, biomassRxn)); zeros(nMets - numel(model.mets), 1)];
expectedBiomass(findMetIDs(newModel, {'dtdprmn[c]', 'kdo2lipid4L[c]', 'colipa[c]'})) = [-0.02504; -0.02504; -0.025039];
assert(isequal(full(newModel.S(:, strcmp(newModel.rxns, biomassRxn))), expectedBiomass));
assert(isequal(size(newModel.S), [nMets, numel(newModel.rxns)]));
assert(isequal(newModel.rxns(1:numel(model.rxns)), model.rxns));

%% gram-positive organism: lipopolysaccharide removed, teichoic acids added

% the model with a demand reaction for udpglcur[c], which the function removes
inputModel = addReaction(model, 'DM_udpglcur(c)', 'reactionFormula', 'udpglcur[c] ->');
[newModel, removedBioComp, addedRxns] = rebuildBiomassReaction(inputModel, microbeID, biomassRxn, database, gramPosInfo);

% colipa[c] is removed from the biomass; the missing reactions of teichoic acid synthesis are
% added
assert(isequal(removedBioComp, {'colipa[c]'}));
assert(isequal(sort(addedRxns(:)), gramPosAddedRxns));
assert(~any(ismember(addedRxns, inputModel.rxns)));
keptRxns = setdiff(inputModel.rxns, {biomassRxn, 'DM_udpglcur(c)'}, 'stable');
assert(isequal(newModel.rxns, [keptRxns; {biomassRxn}; addedRxns(:)]));

% the result is structurally consistent
nRxns = numel(newModel.rxns);
nMets = numel(newModel.mets);
assert(isequal(size(newModel.S), [nMets, nRxns]));
assert(all(cellfun(@(f) size(newModel.(f), 1) == nRxns, rxnFields)));
assert(all(cellfun(@(f) size(newModel.(f), 1) == nMets, metFields)));
assert(isequal(size(newModel.rxnGeneMat), [nRxns, numel(newModel.genes)]));
ruleGeneIdx = str2double(regexp(strjoin(newModel.rules', ' '), '(?<=x\()\d+(?=\))', 'match'));
assert(all(ruleGeneIdx >= 1 & ruleGeneIdx <= numel(newModel.genes)));

% the rebuilt biomass is the objective; it has no colipa[c], the four most common teichoic acid
% components (the biomass had none; tcam[c] 0.001885, the others 0.001806; they are new
% metabolites of the model) and udpglcur[c] and teich_45_BS[c] (0.001806), and keeps all other
% coefficients
assert(isequal(find(newModel.c), nRxns - numel(addedRxns)));
expectedBiomass = [originalBiomass; zeros(nMets - numel(model.mets), 1)];
expectedBiomass(findMetIDs(newModel, 'colipa[c]')) = 0;
expectedBiomass(findMetIDs(newModel, {'tcam[c]', 'glyc45tcaglc[c]', 'glyc45tcaala_D[c]', 'glyc45tca[c]', ...
    'udpglcur[c]', 'teich_45_BS[c]'})) = -[0.001885; 0.001806; 0.001806; 0.001806; 0.001806; 0.001806];
assert(isequal(full(newModel.S(:, strcmp(newModel.rxns, biomassRxn))), expectedBiomass));
assert(all(~ismember({'tcam[c]', 'glyc45tca[c]'}, model.mets)));

% the added reactions have the database formula and the gene rule demeterGapfill
for k = 1:numel(addedRxns)
    formula = database.reactions{strcmp(database.reactions(:, 1), addedRxns{k}), 3};
    rxnMets = sort(newModel.mets(newModel.S(:, strcmp(newModel.rxns, addedRxns{k})) ~= 0));
    assert(isequal(rxnMets, unique(regexp(formula, '[^\s]+\[[a-z]\]', 'match'))'), addedRxns{k});
end
assert(all(strcmp(newModel.grRules(end - numel(addedRxns) + 1:end), 'demeterGapfill')));

%% gram-negative organisms with a gram-positive cell wall are rebuilt as gram-positive

% the result for a gram-positive organism
gramPosResult = rebuildBiomassReaction(model, microbeID, biomassRxn, database, gramPosInfo);

% a gram-negative organism of the genus Flavonifractor (in a table with the column name
% Gram_Staining, also accepted) or of the phylum Deinococcus-Thermus gives the same model
% (isequaln: metCharges holds NaN for unknown charges)
flavonifractorInfo = [{'MicrobeID', 'Phylum', 'Genus', 'Gram_Staining'}; {microbeID, 'Firmicutes', 'Flavonifractor', 'Gram-'}];
assert(isequaln(rebuildBiomassReaction(model, microbeID, biomassRxn, database, flavonifractorInfo), gramPosResult));
deinococcusInfo = [infoHeader; {microbeID, 'Deinococcus-Thermus', 'Deinococcus', 'Gram-'}];
assert(isequaln(rebuildBiomassReaction(model, microbeID, biomassRxn, database, deinococcusInfo), gramPosResult));

%% without a gram status the model is not changed

% an empty gram status and an unknown one
for status = {'', 'Gram variable'}
    info = [infoHeader; {microbeID, 'Firmicutes', 'Acidaminococcus', status{1}}];
    [newModel, removedBioComp, addedRxns] = rebuildBiomassReaction(model, microbeID, biomassRxn, database, info);
    % isequaln: metCharges holds NaN for unknown charges
    assert(isequaln(newModel, model));
    assert(isempty(removedBioComp) && isempty(addedRxns));
end

%% an organism missing from the table gives a warning and the model is not changed

% the warning stays visible; lastwarn is reset only to read its message afterwards
lastwarn('');
[newModel, removedBioComp, addedRxns] = rebuildBiomassReaction(model, 'Unknown_organism', biomassRxn, database, gramNegInfo);
assert(strcmp(lastwarn, 'No organism information provided. The pipeline will not be able to curate the reconstruction based on gram status.'));
assert(isequaln(newModel, model));
assert(isempty(removedBioComp) && isempty(addedRxns));

% change the directory
cd(currentDir)
