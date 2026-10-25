% The COBRAToolbox: testAddRefinementComments.m
%
% Purpose:
%     - addRefinementComments replaces the gap-filling labels stored in the gene rules of a model by
%     explanatory reaction comments and confidence scores, and clears the annotation of exchange,
%     demand and sink reactions.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/demeter/src/refinement/addRefinementComments.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddRefinementComments'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% one reaction for every label the function knows; the scores start at 0
labels = {'gap_filled', 'CarbonSourceGapfill', 'FermentationGapfill', 'condFermentationGapfill', ...
          'uptakeMetaboliteGapfill', 'secretionProductGapfill', 'PutrefactionGapfill', 'AnaerobicGapfill', ...
          'GrowthRequirementsGapfill', 'essentialGapfill', 'Unknown', 'g1 and g2'};
nRxns = numel(labels);
model.rxns = arrayfun(@(i) sprintf('r%d', i), 1:nRxns, 'UniformOutput', false)';
model.grRules = labels';
model.comments = repmat({''}, nRxns, 1);
model.rxnConfidenceScores = zeros(nRxns, 1);
summary = struct('conditionSpecificGapfill', {{}}, 'targetedGapfill', {{}}, 'relaxFBAGapfill', {{}}, 'addedReactionsBiomass', {{}});

%% comments and scores for each label

out = addRefinementComments(model, summary);
% the labels are removed from the gene rules; ordinary rules stay
assert(isequal(out.grRules(1:11), repmat({''}, 11, 1)));
assert(strcmp(out.grRules{12}, 'g1 and g2'));
assert(strcmp(out.comments{1}, 'Reaction added based in gap-filling during comparative genomic analyses.'));
assert(strcmp(out.comments{2}, 'Reaction added by DEMETER based on experimental data on carbon sources.'));
assert(strcmp(out.comments{3}, 'Reaction added by DEMETER based on experimental data on fermentation products.'));
assert(strcmp(out.comments{4}, 'Reaction added by DEMETER as annotated fermentation reactions were already present.'));
assert(strcmp(out.comments{5}, 'Reaction added by DEMETER based on experimental data on consumed metabolites.'));
assert(strcmp(out.comments{6}, 'Reaction added by DEMETER based on experimental data on secretion products.'));
assert(strcmp(out.comments{7}, 'Reaction added by DEMETER based on experimental data on putrefaction pathways.'));
assert(strcmp(out.comments{8}, 'Reaction added by DEMETER to enable anaerobic growth.'));
assert(strcmp(out.comments{9}, 'Reaction added by DEMETER based on experimental data on growth requirements.'));
assert(strcmp(out.comments{10}, 'Added by DEMETER, reactions that should always be present.'));
assert(strcmp(out.comments{11}, 'Added by Model SEED/KBase gap-filling pipeline.'));
assert(isempty(out.comments{12}));
% confidence scores: gap_filled 2, carbon +2, fermentation +2, conditional +2, uptake +0, secretion +2,
% putrefaction 2, anaerobic 1, growth +2, essential 2, unknown 1
assert(isequal(out.rxnConfidenceScores', [2 2 2 2 0 2 2 1 2 2 1 0]));

%% gap-filling by DEMETER takes its comment from the summary

model2 = model;
model2.rxns = {'ra'; 'rb'; 'rc'; 'rd'; 're'};
model2.grRules = repmat({'demeterGapfill'}, 5, 1);
model2.comments = repmat({''}, 5, 1);
model2.rxnConfidenceScores = zeros(5, 1);
summary2 = struct('conditionSpecificGapfill', {{'ra'}}, 'targetedGapfill', {{'rb'}}, ...
                  'relaxFBAGapfill', {{'rc'}}, 'addedReactionsBiomass', {{'rd'}});
out = addRefinementComments(model2, summary2);
assert(strcmp(out.comments{1}, 'Added by DEMETER to enable flux with VMH-consistent constraints.'));
assert(strcmp(out.comments{2}, 'Added by DEMETER during targeted gapfilling to enable production of required metabolites.'));
assert(strcmp(out.comments{3}, 'Added by DEMETER based on relaxFBA. Low confidence level.'));
assert(strcmp(out.comments{4}, 'Added by DEMETER to enable synthesis of biomass components according to gram status of the organism.'));
% the fifth reaction is in none of the lists: no comment
assert(isempty(out.comments{5}));
assert(isequal(out.rxnConfidenceScores', [1 1 0 2 0]));
assert(all(cellfun(@isempty, out.grRules)));

%% exchange, demand and sink reactions are cleared

model3.rxns = {'EX_glc'; 'DM_x'; 'sink_y'; 'normal'};
model3.grRules = {'g1'; 'g2'; 'g3'; 'g4'};
model3.comments = {'c1'; 'c2'; 'c3'; 'c4'};
model3.rxnConfidenceScores = [3; 3; 3; 3];
out = addRefinementComments(model3, summary);
assert(isequal(out.rxnConfidenceScores, [1; 1; 1; 3]));
assert(isequal(out.grRules, {''; ''; ''; 'g4'}) && isequal(out.comments, {''; ''; ''; 'c4'}));

%% exchange reaction text in gene rules is removed

model4.rxns = {'normal'};
model4.grRules = {'exchange_reaction'};
model4.comments = {''};
model4.rxnConfidenceScores = 0;
out = addRefinementComments(model4, summary);
assert(isempty(out.grRules{1}));

% change the directory
cd(currentDir)
