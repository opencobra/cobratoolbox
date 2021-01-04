function [outputFile, outputSummary, onlyInNewModel, onlyInPreviousModel] = compareVersions(previousFolder, newFolder, reportFolder, microbeID, ncbiID)
% Compares the test functions in a previous and a new version of AGORA and writes a report of the differences in a .tex file. Writes a PDF
% using pdf2latex.
%
% INPUT
% modelPrevious       COBRA model structure of older model to compare
% modelNew            COBRA model structure of newer model to compare
% microbeID           Microbe ID in carbon source data file
% reportFolder        Path to folder where report documents should be written
%                     (e.g., 'C:\Reports')
%
% OPTIONAL INPUT
% ncbiID              Organism NCBI ID
%
% OUTPUT
% outputFile          Name of the output file with report
% outputSummary       Summary of results in matfile format
% onlyInNewModel      Reactions/metabolites/genes only in new model
% onlyInPreviousModel Reactions/metabolites/genes only in previous model
%
%
% Almut Heinken, Dec 2017, adapted from script reportPDF

% switch directory to create the LaTex file
currentDir = pwd;
cd(reportFolder)

% start the summary table
outputSummary = string({
    'Feature', 'Reaction_content', 'Metabolite_content', 'Gene_content', 'Constraints', 'Mass_balance', 'Charge_balance', 'Metabolites_without_formulas', 'Leak_test', 'ATP_production', 'Biomass', 'Carbon_sources', 'Fermentation_products', 'Essential_nutrients', 'Nonessential_nutrients', 'Vitamin_biosynthesis', 'Vitamin_secretion', 'Bile_acid_biosynthesis'
    'Same_in_both', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''
    });
onlyInNewModel = {};
onlyInPreviousModel = {};


% Open file to write report (using LaTeX)
fileNameTex = [reportFolder filesep 'Comparison_', microbeID, '.tex'];
fid = fopen(fileNameTex, 'w');
cd(currentDir);

% Print preamble to file
fprintf(fid, '\\documentclass[11pt,a4paper]{article}\n');
fprintf(fid, '\\title{%s}\n', strrep(microbeID, '_', '\_'));
fprintf(fid, '\\date{\\today}\n');
fprintf(fid, '\\begin{document}\n');
fprintf(fid, '\\maketitle\n');
fprintf(fid, '\n');

% Versions compared
previousVersion = strrep(previousFolder, ':', '.');
newVersion = strrep(newFolder, ':', '.');
previousVersion = strrep(previousVersion, '\', '.');
newVersion = strrep(newVersion, '\', '.');
previousVersion = strrep(previousVersion, '..', '.');
newVersion = strrep(newVersion, '..', '.');
previousVersion = strrep(previousVersion, '_', '.');
newVersion = strrep(newVersion, '_', '.');

fprintf(fid, '\\section{Versions compared}\n');
fprintf(fid, '\\subsection{New version}\n');
fprintf(fid, strcat(newVersion, '\n'));
fprintf(fid, '\\subsection{Previous version}\n');
fprintf(fid, strcat(previousVersion, '\n'));
fprintf(fid, '\n');

% Taxonomic lineage
fprintf(fid, '\\section{Taxonomic lineage}\n');
if ~isempty(ncbiID)
    taxonomy = parseNCBItaxonomy(ncbiID);
    taxFields = fieldnames(taxonomy);
    if ~isempty(taxFields)
        fprintf(fid, '\\begin{tabular}{rl}\n');
        for i = 1:length(taxFields)
            fprintf(fid, '%s: & %s \\\\\n', taxFields{i}, strrep(taxonomy.(taxFields{i}), '_', '\_'));
        end
        fprintf(fid, '\\end{tabular}\n');
    end
    fprintf(fid, '\n');
end

% load the two versions of the reconstruction
load([previousFolder, microbeID, '.mat'])
% field names may differ
if isfield(model, 'metCharge')
    model.metCharges = model.metCharge;
    rmfield(model, 'metCharge');
end
modelPrevious = model;
% some reconstruction names changed-need to consider
if strcmp(microbeID, 'Bacillus_timonensis_JC401')
    load([newFolder, 'Bacillus_sp_10403023', '.mat'])
elseif strcmp(microbeID, 'Proteus_mirabilis_ATCC_35198')
    load([newFolder, 'Proteus_penneri_ATCC_35198', '.mat'])
elseif strcmp(microbeID, 'Bifidobacterium_stercoris_ATCC_43183')
    load([newFolder, 'Bifidobacterium_stercoris_DSM_24849', '.mat'])
else
    load([newFolder, microbeID, '.mat'])
end
% field names may differ
if isfield(model, 'metCharge')
    model.metCharges = model.metCharge;
    rmfield(model, 'metCharge');
end
modelNew = model;
biomassReactionNew = modelNew.rxns(find(strncmp(modelNew.rxns, 'biomass', 7)));
biomassReactionPrevious = modelPrevious.rxns(find(strncmp(modelPrevious.rxns, 'biomass', 7)));

% Reconstruction properties
fprintf(fid, '\\section{Reconstruction properties}\n');
fprintf(fid, '\\subsection{New model}\n');
fprintf(fid, '\\begin{tabular}{rl}\n');
fprintf(fid, 'Reactions: & %d \\\\\n', length(modelNew.rxns));
fprintf(fid, 'Metabolites: & %d \\\\\n', length(modelNew.mets));
fprintf(fid, 'Genes: & %d \\\\\n', length(modelNew.genes));
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\n');
fprintf(fid, '\\subsection{Previous model}\n');
fprintf(fid, '\\begin{tabular}{rl}\n');
fprintf(fid, 'Reactions: & %d \\\\\n', length(modelPrevious.rxns));
fprintf(fid, 'Metabolites: & %d \\\\\n', length(modelPrevious.mets));
fprintf(fid, 'Genes: & %d \\\\\n', length(modelPrevious.genes));
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\n');

% Reaction, metabolite, and gene content
% reactions
fprintf(fid, '\\section{Reaction content}\n');
if isequal(modelNew.rxns, modelPrevious.rxns)
    fprintf(fid, 'Reactions are identical in both models.\n');
    outputSummary(2, 2) = 'Unchanged';
else
    outputSummary(2, 2) = 'Changed';
    RxnsOnlyInNew = setdiff(modelNew.rxns, modelPrevious.rxns);
    if size(RxnsOnlyInNew, 1) > 0
        fprintf(fid, '\\subsection{Reactions only in new model}\n');
        fprintf(fid, '\\begin{tabular}{lc}\n');
        for i = 1:size(RxnsOnlyInNew, 1)
            fprintf(fid, strcat(strrep(RxnsOnlyInNew{i, 1}, '_', '.'), '\\\\\n'));
            onlyInNewModel{1, i} = RxnsOnlyInNew{i, 1};
        end
        fprintf(fid, '\\end{tabular}\n');
        fprintf(fid, '\n');
    end
    RxnsOnlyInPrevious = setdiff(modelPrevious.rxns, modelNew.rxns);
    if size(RxnsOnlyInPrevious, 1) > 0
        fprintf(fid, '\\subsection{Reactions only in previous model}\n');
        fprintf(fid, '\\begin{tabular}{lc}\n');
        for i = 1:size(RxnsOnlyInPrevious, 1)
            fprintf(fid, strcat(strrep(RxnsOnlyInPrevious{i, 1}, '_', '.'), '\\\\\n'));
            onlyInPreviousModel{1, i} = RxnsOnlyInPrevious{i, 1};
        end
        fprintf(fid, '\\end{tabular}\n');
        fprintf(fid, '\n');
    end
end
% metabolites
fprintf(fid, '\\section{Metabolite content}\n');
if isequal(modelNew.rxns, modelPrevious.rxns)
    fprintf(fid, 'Metabolites are identical in both models.\n');
    outputSummary(2, 3) = 'Unchanged';
else
    outputSummary(2, 3) = 'Changed';
    MetsOnlyInNew = setdiff(modelNew.mets, modelPrevious.mets);
    if size(MetsOnlyInNew, 1) > 0
        fprintf(fid, '\\subsection{Metabolites only in new model}\n');
        fprintf(fid, '\\begin{tabular}{lc}\n');
        for i = 1:size(MetsOnlyInNew, 1)
            fprintf(fid, strcat(strrep(MetsOnlyInNew{i, 1}, '_', '.'), '\\\\\n'));
            onlyInNewModel{2, i} = MetsOnlyInNew{i, 1};
        end
        fprintf(fid, '\\end{tabular}\n');
        fprintf(fid, '\n');
    end
    MetsOnlyInPrevious = setdiff(modelPrevious.mets, modelNew.mets);
    if size(MetsOnlyInPrevious, 1) > 0
        fprintf(fid, '\\subsection{Metabolites only in previous model}\n');
        fprintf(fid, '\\begin{tabular}{lc}\n');
        for i = 1:size(MetsOnlyInPrevious, 1)
            fprintf(fid, strcat(strrep(MetsOnlyInPrevious{i, 1}, '_', '.'), '\\\\\n'));
            onlyInPreviousModel{2, i} = MetsOnlyInPrevious{i, 1};
        end
        fprintf(fid, '\\end{tabular}\n');
        fprintf(fid, '\n');
    end
end
% genes
fprintf(fid, '\\section{Gene content}\n');
if isequal(modelNew.genes, modelPrevious.genes)
    fprintf(fid, 'Genes are identical in both models.\n');
    outputSummary(2, 4) = 'Unchanged';
else
    outputSummary(2, 4) = 'Changed';
    GenesOnlyInNew = setdiff(modelNew.genes, modelPrevious.genes);
    if size(GenesOnlyInNew, 1) > 0
        fprintf(fid, '\\subsection{Genes only in new model}\n');
        fprintf(fid, '\\begin{tabular}{lc}\n');
        for i = 1:size(GenesOnlyInNew, 1)
            fprintf(fid, strcat(strrep(GenesOnlyInNew{i, 1}, '_', '.'), '\\\\\n'));
            onlyInNewModel{3, i} = GenesOnlyInNew{i, 1};
        end
        fprintf(fid, '\\end{tabular}\n');
        fprintf(fid, '\n');
    end
    GenesOnlyInPrevious = setdiff(modelPrevious.genes, modelNew.genes);
    if size(GenesOnlyInPrevious, 1) > 0
        fprintf(fid, '\\subsection{Genes only in previous model}\n');
        fprintf(fid, '\\begin{tabular}{lc}\n');
        for i = 1:size(GenesOnlyInPrevious, 1)
            fprintf(fid, strcat(strrep(GenesOnlyInPrevious{i, 1}, '_', '.'), '\\\\\n'));
            onlyInPreviousModel{3, i} = GenesOnlyInPrevious{i, 1};
        end
        fprintf(fid, '\\end{tabular}\n');
        fprintf(fid, '\n');
    end
end

% Constraints
fprintf(fid, '\\section{Constraints}\n');
changedConstraints = {};
cnt = 1;
for i = 1:length(modelNew.rxns)
    rxnInOld = find(strcmp(modelNew.rxns{i}, modelPrevious.rxns));
    if ~isempty(rxnInOld)
        if modelNew.lb(i) ~= modelPrevious.lb(rxnInOld) || modelNew.ub(i) ~= modelPrevious.ub(rxnInOld)
            changedConstraints{cnt, 1} = modelNew.rxns{i};
            cnt = cnt + 1;
        end
    end
end
if isempty(changedConstraints)
    fprintf(fid, 'No reactions with changed constraints in new model.\n');
    outputSummary(2, 5) = 'Unchanged';
else
    outputSummary(2, 5) = 'Changed';
            fprintf(fid, '\\subsection{Reactions with changed constraints}\n');
        fprintf(fid, '\\begin{tabular}{lc}\n');
        for i = 1:size(changedConstraints, 1)
            fprintf(fid, '%s & %s \\\\\n', strrep(changedConstraints{i,1}, '_', '\_'));
        end
        fprintf(fid, '\\end{tabular}\n');
        fprintf(fid, '\n');
%         fprintf(fid, '\\subsection{Constraints in new model}\n');
%         fprintf(fid, '\\begin{tabular}{lc}\n');
%         for i = 1:size(changedConstraints, 1)
%             LB=modelNew.lb(find(strcmp(changedConstraints{i,1},modelNew.rxns)));
%             UB=modelNew.ub(find(strcmp(changedConstraints{i,1},modelNew.rxns)));
%             fprintf(fid, '%s & %s \\\\\n', strrep(changedConstraints{i,1}, '_', '\_'));
%             fprintf(fid, 'Lower bound: & %\\\\\n', LB);
%             fprintf(fid, 'Upper bound: & %\\\\\n', UB);
%         end
%         fprintf(fid, '\\end{tabular}\n');
%         fprintf(fid, '\n');
%         
%         fprintf(fid, '\\subsection{Constraints in previous model}\n');
%         fprintf(fid, '\\begin{tabular}{lc}\n');
%         for i = 1:size(changedConstraints, 1)
%             LB=modelPrevious.lb(find(strcmp(changedConstraints{i,1},modelPrevious.rxns)));
%             UB=modelPrevious.ub(find(strcmp(changedConstraints{i,1},modelPrevious.rxns)));
%             fprintf(fid, '%s & %s \\\\\n', strrep(changedConstraints{i,1}, '_', '\_'));
%             fprintf(fid, 'Lower bound: & %4.4f\\\\\n', LB);
%             fprintf(fid, 'Upper bound: & %4.4f\\\\\n', UB);
%         end
%         fprintf(fid, '\\end{tabular}\n');
%         fprintf(fid, '\n');
end

% Mass and charge balance
fprintf(fid, '\\section{Mass and charge balance}\n');
[massImbalancedRxnsNew, chargeImbalancedRxnsNew, ~, metsMissingFormulasNew] = ...
    Test_MassChargeBalance(modelNew, true, biomassReactionNew);
[massImbalancedRxnsPrevious, chargeImbalancedRxnsPrevious, ~, metsMissingFormulasPrevious] = ...
    Test_MassChargeBalance(modelPrevious, true, biomassReactionPrevious);
if isequal(massImbalancedRxnsNew(:,1),massImbalancedRxnsPrevious(:,1))
    fprintf(fid, 'No changes in mass balance.\n');
    outputSummary(2,6)='Unchanged';
else
    outputSummary(2,6)='Changed';
end
if isequal(chargeImbalancedRxnsNew(:,1),chargeImbalancedRxnsPrevious(:,1))
    fprintf(fid, 'No changes in charge balance.\n');
    outputSummary(2,7)='Unchanged';
else
    outputSummary(2,7)='Changed';
end
if isequal(metsMissingFormulasNew(:,1),metsMissingFormulasPrevious(:,1))
    fprintf(fid, 'No changes in metabolites with missing formulas.\n');
    outputSummary(2,8)='Unchanged';
else
    outputSummary(2,8)='Changed';
end

% first new model
fprintf(fid, '\\subsection{New model}\n');
fprintf(fid, '\\begin{tabular}{lc}\n');
% mass imbalances
fprintf(fid, 'Reaction & Element imbalances\\\\\n');
fprintf(fid, '\\hline\\\\\n');
if size(massImbalancedRxnsNew, 1) > 1
    for i = 2:size(massImbalancedRxnsNew, 1)
        
        fprintf(fid, '%s & %s \\\\\n', strrep(massImbalancedRxnsNew{i, 1}, '_', '\_'), ...
            massImbalancedRxnsNew{i, 3});
    end
end
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\n');
fprintf(fid, '\\begin{tabular}{lc}\n');
% charge imbalances
fprintf(fid, 'Reaction & Charge imbalance\\\\\n');
fprintf(fid, '\\hline\\\\\n');
if size(chargeImbalancedRxnsNew, 1) > 1
    for i = 2:size(chargeImbalancedRxnsNew, 1)
        fprintf(fid, '%s & %s \\\\\n', strrep(chargeImbalancedRxnsNew{i, 1}, '_', '\_'), ...
            chargeImbalancedRxnsNew{i, 3});
    end
end
fprintf(fid, '\\end{tabular}\n');

fprintf(fid, '\n');
fprintf(fid, '\\begin{tabular}{ll}\n');
% missing formulas
fprintf(fid, 'Metabolite & Name \\\\\n');
fprintf(fid, '\\hline\\\\\n');
if ~isempty(metsMissingFormulasNew)
    for i = 1:size(metsMissingFormulasNew, 1)
        fprintf(fid, '%s & %s\\\\\n', strrep(metsMissingFormulasNew{i, 1}, '_', '\_'), ...
            strrep(metsMissingFormulasNew{i, 2}, '_', '\_'));
    end
end
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\n');
% then previous model
fprintf(fid, '\\subsection{Previous model}\n');
fprintf(fid, '\\begin{tabular}{lc}\n');
% mass imbalances
fprintf(fid, 'Reaction & Element imbalances\\\\\n');
fprintf(fid, '\\hline\\\\\n');
if size(massImbalancedRxnsPrevious, 1) > 1
    for i = 2:size(massImbalancedRxnsPrevious, 1)
        
        fprintf(fid, '%s & %s \\\\\n', strrep(massImbalancedRxnsPrevious{i, 1}, '_', '\_'), ...
            massImbalancedRxnsPrevious{i, 3});
    end
end
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\n');
fprintf(fid, '\\begin{tabular}{lc}\n');
% charge imbalances
fprintf(fid, 'Reaction & Charge imbalance\\\\\n');
fprintf(fid, '\\hline\\\\\n');
if size(chargeImbalancedRxnsPrevious, 1) > 1
    for i = 2:size(chargeImbalancedRxnsPrevious, 1)
        fprintf(fid, '%s & %s \\\\\n', strrep(chargeImbalancedRxnsPrevious{i, 1}, '_', '\_'), ...
            chargeImbalancedRxnsPrevious{i, 3});
    end
end
fprintf(fid, '\\end{tabular}\n');

fprintf(fid, '\n');
fprintf(fid, '\\begin{tabular}{ll}\n');
% missing formulas
fprintf(fid, 'Metabolite & Name \\\\\n');
fprintf(fid, '\\hline\\\\\n');
if ~isempty(metsMissingFormulasPrevious)
    for i = 1:size(metsMissingFormulasPrevious, 1)
        fprintf(fid, '%s & %s\\\\\n', strrep(metsMissingFormulasPrevious{i, 1}, '_', '\_'), ...
            strrep(metsMissingFormulasPrevious{i, 2}, '_', '\_'));
    end
end
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\n');

% Leak test
fprintf(fid, '\\section{Leak test}\n');
leakingMetsNew = Test_LeakingMetabolites(modelNew);
leakingMetsPrevious = Test_LeakingMetabolites(modelPrevious);
if isempty(leakingMetsPrevious) && isempty(leakingMetsNew)
    fprintf(fid, 'No leaking metabolites in either version.\n');
    outputSummary(2,9)='Unchanged';
else
    if isequal(leakingMetsNew,leakingMetsPrevious)
        fprintf(fid, 'No changes.\n');
        outputSummary(2,9)='Unchanged';
    else
        outputSummary(2,9)='Changed';
    end
    fprintf(fid, '\\begin{tabular}{l}\n');
    fprintf(fid, '\\subsection{New model}\n');
    fprintf(fid, '\\begin{tabular}{lc}\n');
    for i = 1:length(leakingMetsNew)
        fprintf(fid, '%s\\\\\n', strrep(leakingMetsNew{i, 1}, '_', '\_'));
    end
    fprintf(fid, '\\subsection{Previous model}\n');
    fprintf(fid, '\\begin{tabular}{lc}\n');
    for i = 1:length(leakingMetsPrevious)
        fprintf(fid, '%s\\\\\n', strrep(leakingMetsPrevious{i, 1}, '_', '\_'));
    end
    fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\n');
end
%
% ATP production
fprintf(fid, '\\section{ATP production}\n');
[atpFluxAerobicNew, atpFluxAnaerobicNew] = Test_ATP(modelNew);
[atpFluxAerobicPrevious, atpFluxAnaerobicPrevious] = Test_ATP(modelPrevious);
% do not count very small differences
if abs(atpFluxAerobicNew-atpFluxAerobicPrevious)<0.000001 && abs(atpFluxAnaerobicNew-atpFluxAnaerobicPrevious)<0.000001
    fprintf(fid, 'No changes.\n');
    outputSummary(2,10)='Unchanged';
else
    outputSummary(2,10)='Changed';
end
fprintf(fid, '\\subsection{New model}\n');
fprintf(fid, '\\begin{tabular}{ll}\n');
fprintf(fid, 'ATP demand (aerobic): & %4.4f mmol/gDW/h\\\\\n', atpFluxAerobicNew);
fprintf(fid, 'ATP demand (anaerobic): & %4.4f mmol/gDW/h\\\\\n', atpFluxAnaerobicNew);
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\n');
fprintf(fid, '\\subsection{Previous model}\n');
fprintf(fid, '\\begin{tabular}{ll}\n');
fprintf(fid, 'ATP demand (aerobic): & %4.4f mmol/gDW/h\\\\\n', atpFluxAerobicPrevious);
fprintf(fid, 'ATP demand (anaerobic): & %4.4f mmol/gDW/h\\\\\n', atpFluxAnaerobicPrevious);
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\n');

% Growth
fprintf(fid, '\\section{Growth}\n');
[AerobicGrowthNew, AnaerobicGrowthNew] = Test_Growth(modelNew, biomassReactionNew);
[AerobicGrowthPrevious, AnaerobicGrowthPrevious] = Test_Growth(modelPrevious, biomassReactionPrevious);
if abs(AerobicGrowthNew(1, 1)-AerobicGrowthPrevious(1, 1))<0.000001 && abs(AnaerobicGrowthNew(1, 1)-AnaerobicGrowthPrevious(1, 1))<0.000001 && abs(AerobicGrowthNew(1, 2)-AerobicGrowthPrevious(1, 2))<0.000001 && abs(AnaerobicGrowthNew(1, 2)-AnaerobicGrowthPrevious(1, 2))<0.000001
    fprintf(fid, 'No changes.\n');
    outputSummary(2,11)='Unchanged';
else
    outputSummary(2,11)='Changed';
end
fprintf(fid, '\\subsection{New model}\n');
fprintf(fid, '\\begin{tabular}{ll}\n');
fprintf(fid, 'Unlimited growth (aerobic): & %4.4f mmol/gDW/h\\\\\n', AerobicGrowthNew(1, 1));
fprintf(fid, 'Unlimited growth (anaerobic): & %4.4f mmol/gDW/h\\\\\n', AnaerobicGrowthNew(1, 1));
fprintf(fid, 'Western diet growth (aerobic): & %4.4f mmol/gDW/h\\\\\n', AerobicGrowthNew(1, 2));
fprintf(fid, 'Western diet growth (anaerobic): & %4.4f mmol/gDW/h\\\\\n', AnaerobicGrowthNew(1, 2));
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\n');
fprintf(fid, '\\subsection{Previous model}\n');
fprintf(fid, '\\begin{tabular}{ll}\n');
fprintf(fid, 'Unlimited growth (aerobic): & %4.4f mmol/gDW/h\\\\\n', AerobicGrowthPrevious(1, 1));
fprintf(fid, 'Unlimited growth (anaerobic): & %4.4f mmol/gDW/h\\\\\n', AnaerobicGrowthPrevious(1, 1));
fprintf(fid, 'Western diet growth (aerobic): & %4.4f mmol/gDW/h\\\\\n', AerobicGrowthPrevious(1, 2));
fprintf(fid, 'Western diet growth (anaerobic): & %4.4f mmol/gDW/h\\\\\n', AnaerobicGrowthPrevious(1, 2));
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\n');

% Carbon sources
fprintf(fid, '\\section{Carbon sources}\n');
[TruePositivesNew, FalseNegativesNew] = Test_CarbonSources(modelNew, microbeID, biomassReactionNew);
[TruePositivesPrevious, FalseNegativesPrevious] = Test_CarbonSources(modelPrevious, microbeID, biomassReactionPrevious);
% sort the entries to compare them
TruePositivesNew=sort(TruePositivesNew);
FalseNegativesNew=sort(FalseNegativesNew);
TruePositivesPrevious=sort(TruePositivesPrevious);
FalseNegativesPrevious=sort(FalseNegativesPrevious);

if ~isempty(FalseNegativesNew) || ~isempty(TruePositivesNew) || ~isempty(FalseNegativesPrevious) || ~isempty(TruePositivesPrevious)
    if isequal(TruePositivesNew,TruePositivesPrevious) && isequal(FalseNegativesNew,FalseNegativesPrevious)
        fprintf(fid, 'No changes.\n');
        outputSummary(2,12)='Unchanged';
    else
        outputSummary(2,12)='Changed';
    end
    fprintf(fid, '\\subsection{New model}\n');
    fprintf(fid, '\\begin{tabular}{ll}\n');
    fprintf(fid, '\\textit{In vitro} carbon source & Taken up by model\\\\\n');
    fprintf(fid, '\\hline\\\\\n');
    if ~isempty(FalseNegativesNew)
        FalseNegatives = strrep(FalseNegativesNew, '_', '\_');
        for i = 1:length(FalseNegatives)
            fprintf(fid, '%s & %s\\\\\n', FalseNegatives{i}, 'FALSE');
        end
    end
    if ~isempty(TruePositivesNew)
        TruePositives = strrep(TruePositivesNew, '_', '\_');
        for i = 1:length(TruePositives)
            fprintf(fid, '%s & %s\\\\\n', TruePositives{i}, 'TRUE');
        end
    end
    fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\n');
    fprintf(fid, '\\subsection{Previous model}\n');
    fprintf(fid, '\\begin{tabular}{ll}\n');
    fprintf(fid, '\\textit{In vitro} carbon source & Taken up by model\\\\\n');
    fprintf(fid, '\\hline\\\\\n');
    if ~isempty(FalseNegativesPrevious)
        FalseNegatives = strrep(FalseNegativesPrevious, '_', '\_');
        for i = 1:length(FalseNegatives)
            fprintf(fid, '%s & %s\\\\\n', FalseNegatives{i}, 'FALSE');
        end
    end
    if ~isempty(TruePositivesPrevious)
        TruePositives = strrep(TruePositivesPrevious, '_', '\_');
        for i = 1:length(TruePositives)
            fprintf(fid, '%s & %s\\\\\n', TruePositives{i}, 'TRUE');
        end
    end
    fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\n');
else
    fprintf(fid, 'No carbon sources reported for organism.\n');
    outputSummary(2,12)='Unchanged';
end

% Fermentation products
fprintf(fid, '\\section{Fermentation products}\n');
[TruePositivesNew, FalseNegativesNew] = Test_FermentationProducts(modelNew, microbeID, biomassReactionNew);
[TruePositivesPrevious, FalseNegativesPrevious] = Test_FermentationProducts(modelPrevious, microbeID, biomassReactionPrevious);
% sort the entries to compare them
TruePositivesNew=sort(TruePositivesNew);
FalseNegativesNew=sort(FalseNegativesNew);
TruePositivesPrevious=sort(TruePositivesPrevious);
FalseNegativesPrevious=sort(FalseNegativesPrevious);

if ~isempty(FalseNegativesNew) || ~isempty(TruePositivesNew) || ~isempty(FalseNegativesPrevious) || ~isempty(TruePositivesPrevious)
    if isequal(TruePositivesNew,TruePositivesPrevious) && isequal(FalseNegativesNew,FalseNegativesPrevious)
        fprintf(fid, 'No changes.\n');
        outputSummary(2,13)='Unchanged';
    else
        outputSummary(2,13)='Changed';
    end
    fprintf(fid, '\\subsection{New model}\n');
    fprintf(fid, '\\begin{tabular}{ll}\n');
    fprintf(fid, '\\textit{In vitro} fermentation product & Secreted by model\\\\\n');
    fprintf(fid, '\\hline\\\\\n');
    if ~isempty(FalseNegativesNew)
        FalseNegatives = strrep(FalseNegativesNew, '_', '\_');
        for i = 1:length(FalseNegatives)
            fprintf(fid, '%s & %s\\\\\n', FalseNegatives{i}, 'FALSE');
        end
    end
    if ~isempty(TruePositivesNew)
        TruePositives = strrep(TruePositivesNew, '_', '\_');
        for i = 1:length(TruePositives)
            fprintf(fid, '%s & %s\\\\\n', TruePositives{i}, 'TRUE');
        end
    end
    fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\n');
    fprintf(fid, '\\subsection{Previous model}\n');
    fprintf(fid, '\\begin{tabular}{ll}\n');
    fprintf(fid, '\\textit{In vitro} fermentation product & Secreted by model\\\\\n');
    fprintf(fid, '\\hline\\\\\n');
    if ~isempty(FalseNegativesPrevious)
        FalseNegatives = strrep(FalseNegativesPrevious, '_', '\_');
        for i = 1:length(FalseNegatives)
            fprintf(fid, '%s & %s\\\\\n', FalseNegatives{i}, 'FALSE');
        end
    end
    if ~isempty(TruePositivesPrevious)
        TruePositives = strrep(TruePositivesPrevious, '_', '\_');
        for i = 1:length(TruePositives)
            fprintf(fid, '%s & %s\\\\\n', TruePositives{i}, 'TRUE');
        end
    end
    fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\n');
else
    fprintf(fid, 'No fermentation products reported for organism.\n');
    outputSummary(2,13)='Unchanged';
end

% Nutrient requirements
fprintf(fid, '\\section{Nutrient requirements}\n');
[TruePositivesEssentialNew, TruePositivesNonessentialNew, FalseNegativesEssentialNew, FalseNegativesNonessentialNew] = ...
    Test_NutrientRequirements(modelNew, microbeID, biomassReactionNew);
[TruePositivesEssentialPrevious, TruePositivesNonessentialPrevious, FalseNegativesEssentialPrevious, FalseNegativesNonessentialPrevious] = ...
    Test_NutrientRequirements(modelPrevious, microbeID, biomassReactionPrevious);

% essential nutrients
% sort the entries to compare them
TruePositivesEssentialNew=sort(TruePositivesEssentialNew);
TruePositivesEssentialPrevious=sort(TruePositivesEssentialPrevious);
FalseNegativesEssentialNew=sort(FalseNegativesEssentialNew);
FalseNegativesEssentialPrevious=sort(FalseNegativesEssentialPrevious);

if ~isempty(FalseNegativesEssentialNew) || ~isempty(TruePositivesEssentialNew) || ~isempty(FalseNegativesEssentialPrevious) || ~isempty(TruePositivesEssentialPrevious)
    if isequal(TruePositivesEssentialNew,TruePositivesEssentialPrevious) && isequal(FalseNegativesEssentialNew,FalseNegativesEssentialPrevious)
        fprintf(fid, 'No changes.\n');
        outputSummary(2,14)='Unchanged';
    else
        outputSummary(2,14)='Changed';
    end
    if ~isempty(FalseNegativesEssentialNew) || ~isempty(TruePositivesEssentialNew)
        fprintf(fid, '\\subsection{Essential nutrients in new model}\n');
        fprintf(fid, '\\begin{tabular}{ll}\n');
        fprintf(fid, 'Essential \\textit{in vitro} & Essential in model\\\\\n');
        fprintf(fid, '\\hline\\\\\n');
        if ~isempty(FalseNegativesEssentialNew)
            FalseNegativesEssential = strrep(FalseNegativesEssentialNew, '_', '\_');
            for i = 1:length(FalseNegativesEssential)
                fprintf(fid, '%s & %s\\\\\n', FalseNegativesEssential{i}, 'FALSE');
            end
        end
        if ~isempty(TruePositivesEssentialNew)
            TruePositivesEssential = strrep(TruePositivesEssentialNew, '_', '\_');
            for i = 1:length(TruePositivesEssential)
                fprintf(fid, '%s & %s\\\\\n', TruePositivesEssential{i}, 'TRUE');
            end
        end
        fprintf(fid, '\\end{tabular}\n');
        fprintf(fid, '\n');
    end
    if ~isempty(FalseNegativesEssentialPrevious) || ~isempty(TruePositivesEssentialPrevious)
        fprintf(fid, '\\subsection{Essential nutrients in previous model}\n');
        fprintf(fid, '\\begin{tabular}{ll}\n');
        fprintf(fid, 'Essential \\textit{in vitro} & Essential in model\\\\\n');
        fprintf(fid, '\\hline\\\\\n');
        if ~isempty(FalseNegativesEssentialPrevious)
            FalseNegativesEssential = strrep(FalseNegativesEssentialPrevious, '_', '\_');
            for i = 1:length(FalseNegativesEssential)
                fprintf(fid, '%s & %s\\\\\n', FalseNegativesEssential{i}, 'FALSE');
            end
        end
        if ~isempty(TruePositivesEssentialPrevious)
            TruePositivesEssential = strrep(TruePositivesEssentialPrevious, '_', '\_');
            for i = 1:length(TruePositivesEssential)
                fprintf(fid, '%s & %s\\\\\n', TruePositivesEssential{i}, 'TRUE');
            end
        end
        fprintf(fid, '\\end{tabular}\n');
        fprintf(fid, '\n');
    end
else
    fprintf(fid, 'No essential nutrients reported for organism.\n');
    outputSummary(2,14)='Unchanged';
end
% non-essential nutrients
% sort the entries to compare them
TruePositivesNonessentialNew=sort(TruePositivesNonessentialNew);
TruePositivesNonessentialPrevious=sort(TruePositivesNonessentialPrevious);
FalseNegativesNonessentialNew=sort(FalseNegativesNonessentialNew);
FalseNegativesNonessentialPrevious=sort(FalseNegativesNonessentialPrevious);

if ~isempty(FalseNegativesNonessentialNew) || ~isempty(TruePositivesNonessentialNew) || ~isempty(FalseNegativesNonessentialPrevious) || ~isempty(TruePositivesNonessentialPrevious)
    if isequal(TruePositivesNonessentialNew,TruePositivesNonessentialPrevious) && isequal(FalseNegativesNonessentialNew,FalseNegativesNonessentialPrevious)
        fprintf(fid, 'No changes.\n');
        outputSummary(2,15)='Unchanged';
    else
        outputSummary(2,15)='Changed';
    end
    fprintf(fid, '\\subsection{Non-essential nutrients in new model}\n');
    fprintf(fid, '\\begin{tabular}{ll}\n');
    fprintf(fid, 'Non-essential \\textit{in vitro} & Non-essential in model\\\\\n');
    fprintf(fid, '\\hline\\\\\n');
    if ~isempty(FalseNegativesNonessentialNew)
        FalseNegativesNonessential = strrep(FalseNegativesNonessentialNew, '_', '\_');
        for i = 1:length(FalseNegativesNonessential)
            fprintf(fid, '%s & %s\\\\\n', FalseNegativesNonessential{i}, 'FALSE');
        end
    end
    if ~isempty(TruePositivesNonessentialNew)
        TruePositivesNonessential = strrep(TruePositivesNonessentialNew, '_', '\_');
        for i = 1:length(TruePositivesNonessential)
            fprintf(fid, '%s & %s\\\\\n', TruePositivesNonessential{i}, 'TRUE');
        end
    end
    fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\n');
    fprintf(fid, '\\subsection{Non-essential nutrients in previous model}\n');
    fprintf(fid, '\\begin{tabular}{ll}\n');
    fprintf(fid, 'Non-essential \\textit{in vitro} & Non-essential in model\\\\\n');
    fprintf(fid, '\\hline\\\\\n');
    if ~isempty(FalseNegativesNonessentialPrevious)
        FalseNegativesNonessential = strrep(FalseNegativesNonessentialPrevious, '_', '\_');
        for i = 1:length(FalseNegativesNonessential)
            fprintf(fid, '%s & %s\\\\\n', FalseNegativesNonessential{i}, 'FALSE');
        end
    end
    if ~isempty(TruePositivesNonessentialPrevious)
        TruePositivesNonessential = strrep(TruePositivesNonessentialPrevious, '_', '\_');
        for i = 1:length(TruePositivesNonessential)
            fprintf(fid, '%s & %s\\\\\n', TruePositivesNonessential{i}, 'TRUE');
        end
    end
    fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\n');
else
    fprintf(fid, 'No non-essential nutrients reported for organism.\n');
    outputSummary(2,15)='Unchanged';
end

% B-vitamin biosynthesis
fprintf(fid, '\\section{B-vitamin biosynthesis}\n');
[TruePositivesNew, FalseNegativesNew] = Test_BvitaminBiosynthesis(modelNew, microbeID);
[TruePositivesPrevious, FalseNegativesPrevious] = Test_BvitaminBiosynthesis(modelPrevious, microbeID);
% sort the entries to compare them
TruePositivesNew=sort(TruePositivesNew);
FalseNegativesNew=sort(FalseNegativesNew);
TruePositivesPrevious=sort(TruePositivesPrevious);
FalseNegativesPrevious=sort(FalseNegativesPrevious);

if ~isempty(FalseNegativesNew) || ~isempty(TruePositivesNew) || ~isempty(FalseNegativesPrevious) || ~isempty(TruePositivesPrevious)
    if isequal(TruePositivesNew,TruePositivesPrevious) && isequal(FalseNegativesNew,FalseNegativesPrevious)
        fprintf(fid, 'No changes.\n');
        outputSummary(2,16)='Unchanged';
    else
        outputSummary(2,16)='Changed';
    end
    fprintf(fid, '\\subsection{B-vitamin biosynthesis in new model}\n');
    fprintf(fid, '\\begin{tabular}{ll}\n');
    fprintf(fid, 'Vitamin & \\textit{De novo} synthesis in model\\\\\n');
    fprintf(fid, '\\hline\\\\\n');
    if ~isempty(FalseNegativesNew)
        FalseNegatives = strrep(FalseNegativesNew, '_', '\_');
        for i = 1:length(FalseNegatives)
            fprintf(fid, '%s & %s\\\\\n', FalseNegatives{i}, 'FALSE');
        end
    end
    if ~isempty(TruePositivesNew)
        TruePositives = strrep(TruePositivesNew, '_', '\_');
        for i = 1:length(TruePositives)
            fprintf(fid, '%s & %s\\\\\n', TruePositives{i}, 'TRUE');
        end
    end
    fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\n');
    
    fprintf(fid, '\\subsection{B-vitamin biosynthesis in previous model}\n');
    fprintf(fid, '\\begin{tabular}{ll}\n');
    fprintf(fid, 'Vitamin & \\textit{De novo} synthesis in model\\\\\n');
    fprintf(fid, '\\hline\\\\\n');
    if ~isempty(FalseNegativesPrevious)
        FalseNegatives = strrep(FalseNegativesPrevious, '_', '\_');
        for i = 1:length(FalseNegatives)
            fprintf(fid, '%s & %s\\\\\n', FalseNegatives{i}, 'FALSE');
        end
    end
    if ~isempty(TruePositivesPrevious)
        TruePositives = strrep(TruePositivesPrevious, '_', '\_');
        for i = 1:length(TruePositives)
            fprintf(fid, '%s & %s\\\\\n', TruePositives{i}, 'TRUE');
        end
    end
    fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\n');
else
    fprintf(fid, 'No \textit{de novo} vitamin biosynthesis reported for organism.\n');
    outputSummary(2,16)='Unchanged';
end

% Vitamin and GABA secretion
% NOT same test as previous-tests for vitamins that were explicitly stated
% to be secreted by particular microbes
fprintf(fid, '\\section{Vitamin and GABA secretion}\n');
[TruePositivesNew, FalseNegativesNew] = Test_VitaminSecretion(modelNew, microbeID, biomassReactionNew);
[TruePositivesPrevious, FalseNegativesPrevious] = Test_VitaminSecretion(modelPrevious, microbeID, biomassReactionPrevious);
% sort the entries to compare them
TruePositivesNew=sort(TruePositivesNew);
FalseNegativesNew=sort(FalseNegativesNew);
TruePositivesPrevious=sort(TruePositivesPrevious);
FalseNegativesPrevious=sort(FalseNegativesPrevious);

if ~isempty(FalseNegativesNew) || ~isempty(TruePositivesNew) || ~isempty(FalseNegativesPrevious) || ~isempty(TruePositivesPrevious)
    if isequal(TruePositivesNew,TruePositivesPrevious) && isequal(FalseNegativesNew,FalseNegativesPrevious)
        fprintf(fid, 'No changes.\n');
        outputSummary(2,17)='Unchanged';
    else
        outputSummary(2,17)='Changed';
    end
    fprintf(fid, '\\subsection{Vitamin and GABA secretion in new model}\n');
    fprintf(fid, '\\begin{tabular}{ll}\n');
    fprintf(fid, 'Vitamin and GABA secretion in model\\\\\n');
    fprintf(fid, '\\hline\\\\\n');
    if ~isempty(FalseNegativesNew)
        FalseNegatives = strrep(FalseNegativesNew, '_', '\_');
        for i = 1:length(FalseNegatives)
            fprintf(fid, '%s & %s\\\\\n', FalseNegatives{i}, 'FALSE');
        end
    end
    if ~isempty(TruePositivesNew)
        TruePositives = strrep(TruePositivesNew, '_', '\_');
        for i = 1:length(TruePositives)
            fprintf(fid, '%s & %s\\\\\n', TruePositives{i}, 'TRUE');
        end
    end
    fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\n');
    
    fprintf(fid, '\\subsection{Vitamin and GABA secretion in previous model}\n');
    fprintf(fid, '\\begin{tabular}{ll}\n');
    fprintf(fid, 'Vitamin and GABA secretion in model\\\\\n');
    fprintf(fid, '\\hline\\\\\n');
    if ~isempty(FalseNegativesPrevious)
        FalseNegatives = strrep(FalseNegativesPrevious, '_', '\_');
        for i = 1:length(FalseNegatives)
            fprintf(fid, '%s & %s\\\\\n', FalseNegatives{i}, 'FALSE');
        end
    end
    if ~isempty(TruePositivesPrevious)
        TruePositives = strrep(TruePositivesPrevious, '_', '\_');
        for i = 1:length(TruePositives)
            fprintf(fid, '%s & %s\\\\\n', TruePositives{i}, 'TRUE');
        end
    end
    fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\n');
else
    fprintf(fid, 'No vitamin and/or GABA secretion reported for organism.\n');
    outputSummary(2,17)='Unchanged';
end

% bile acid biosynthesis
fprintf(fid, '\\section{Bile acid biosynthesis}\n');
[TruePositivesNew, FalseNegativesNew] = Test_BileAcidBiosynthesis(modelNew, microbeID, biomassReactionNew);
[TruePositivesPrevious, FalseNegativesPrevious] = Test_BileAcidBiosynthesis(modelPrevious, microbeID, biomassReactionPrevious);
% sort the entries to compare them
TruePositivesNew=sort(TruePositivesNew);
FalseNegativesNew=sort(FalseNegativesNew);
TruePositivesPrevious=sort(TruePositivesPrevious);
FalseNegativesPrevious=sort(FalseNegativesPrevious);

if ~isempty(FalseNegativesNew) || ~isempty(TruePositivesNew) || ~isempty(FalseNegativesPrevious) || ~isempty(TruePositivesPrevious)
    if isequal(TruePositivesNew,TruePositivesPrevious) && isequal(FalseNegativesNew,FalseNegativesPrevious)
        fprintf(fid, 'No changes.\n');
        outputSummary(2,18)='Unchanged';
    else
        outputSummary(2,18)='Changed';
    end
    fprintf(fid, '\\subsection{Bile acid biosynthesis in new model}\n');
    fprintf(fid, '\\begin{tabular}{ll}\n');
    fprintf(fid, 'Bile acid & \\textit{De novo} synthesis in model\\\\\n');
    fprintf(fid, '\\hline\\\\\n');
    if ~isempty(FalseNegativesNew)
        FalseNegatives = strrep(FalseNegativesNew, '_', '\_');
        for i = 1:length(FalseNegatives)
            fprintf(fid, '%s & %s\\\\\n', FalseNegatives{i}, 'FALSE');
        end
    end
    if ~isempty(TruePositivesNew)
        TruePositives = strrep(TruePositivesNew, '_', '\_');
        for i = 1:length(TruePositives)
            fprintf(fid, '%s & %s\\\\\n', TruePositives{i}, 'TRUE');
        end
    end
    fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\n');
    
    fprintf(fid, '\\subsection{Bile acid biosynthesis in previous model}\n');
    fprintf(fid, '\\begin{tabular}{ll}\n');
    fprintf(fid, 'Bile acid & \\textit{De novo} synthesis in model\\\\\n');
    fprintf(fid, '\\hline\\\\\n');
    if ~isempty(FalseNegativesPrevious)
        FalseNegatives = strrep(FalseNegativesPrevious, '_', '\_');
        for i = 1:length(FalseNegatives)
            fprintf(fid, '%s & %s\\\\\n', FalseNegatives{i}, 'FALSE');
        end
    end
    if ~isempty(TruePositivesPrevious)
        TruePositives = strrep(TruePositivesPrevious, '_', '\_');
        for i = 1:length(TruePositives)
            fprintf(fid, '%s & %s\\\\\n', TruePositives{i}, 'TRUE');
        end
    end
    fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\n');
else
    fprintf(fid, 'No bile acid biosynthesis reported for organism.\n');
    outputSummary(2,18)='Unchanged';
end

% Close document
fprintf(fid, '\\end{document}\n');
fclose(fid);

% write PDF
cd(reportFolder)
system(['pdflatex ', fileNameTex]);
cd(currentDir);

outputFile=strcat('Comparison_',microbeID,'.pdf');
end
