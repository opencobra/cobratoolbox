function [outputFile] = reportPDF(model, microbeID, biomassReaction, reportFolder, ncbiID)
% Runs all test functions and writes a report in a .tex file. Writes a PDF
% using pdf2latex.
% Requires a LaTex installation, e.g. MiKTex (https://miktex.org/download)
% and pdftex (https://ctan.org/pkg/pdftex).
%
% INPUT
% model             COBRA model structure
% microbeID         Microbe ID in carbon source data file
% biomassReaction   Model biomass reaction
% reportFolder      Path to folder where report documents should be written
%                   (e.g., 'C:\Reports')
%
% OPTIONAL INPUT
% ncbiID            Organism NCBI ID
%
% OUTPUT
% outputFile        Name of the output file with report
%
% Stefania Magnusdottir, Nov 2017
% Almut Heinken, Sep 2018-adapted nomenclature

currentDir=pwd;
fileDir = fileparts(which('ReactionTranslationTable.txt'));
cd(fileDir);
metaboliteDatabase = readtable('MetaboliteDatabase.txt', 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011'], 'ReadVariableNames', false);
metaboliteDatabase=table2cell(metaboliteDatabase);
cd(currentDir)

% switch directory to create the LaTex file
currentDir = pwd;
cd(reportFolder)

% Open file to write report (using LaTeX)
% fileNameTex = [reportFolder filesep datestr(datetime('now'), 'yyyymmdd'), '_', microbeID, '.tex'];
fileNameTex = [reportFolder filesep  microbeID, '.tex'];
fid = fopen(fileNameTex, 'w');
cd(currentDir);

% Print preamble to file
fprintf(fid, '\\documentclass[11pt,a4paper]{article}\n');
fprintf(fid, '\\title{%s}\n', strrep(microbeID, '_', '\_'));
fprintf(fid, '\\date{\\today}\n');
fprintf(fid, '\\begin{document}\n');
fprintf(fid, '\\maketitle\n');
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

% Reconstruction properties
fprintf(fid, '\\section{Reconstruction properties}\n');
fprintf(fid, '\\begin{tabular}{rl}\n');
fprintf(fid, 'Reactions: & %d \\\\\n', length(model.rxns));
fprintf(fid, 'Metabolites: & %d \\\\\n', length(model.mets));
fprintf(fid, 'Genes: & %d \\\\\n', length(model.genes));
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\n');

% Mass and charge balance
fprintf(fid, '\\section{Mass and charge balance}\n');
[massImbalancedRxns, chargeImbalancedRxns, ~, metsMissingFormulas] = ...
    testModelMassChargeBalance(model, true, biomassReaction);
if size(massImbalancedRxns, 1) > 1
    fprintf(fid, '\\subsection{Mass imbalanced reactions}\n');
    fprintf(fid, '\\begin{tabular}{lc}\n');
    fprintf(fid, 'Reaction & Element imbalances\\\\\n');
    fprintf(fid, '\\hline\\\\\n');
    for i = 2:size(massImbalancedRxns, 1)
        fprintf(fid, '%s & %s \\\\\n', strrep(massImbalancedRxns{i, 1}, '_', '\_'), ...
                massImbalancedRxns{i, 3});
    end
    fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\n');
end
if size(chargeImbalancedRxns, 1) > 1
    fprintf(fid, '\\subsection{Charge imbalanced reactions}\n');
    fprintf(fid, '\\begin{tabular}{lc}\n');
    fprintf(fid, 'Reaction & Charge imbalance\\\\\n');
    fprintf(fid, '\\hline\\\\\n');
    for i = 2:size(chargeImbalancedRxns, 1)
        fprintf(fid, '%s & %s \\\\\n', strrep(chargeImbalancedRxns{i, 1}, '_', '\_'), ...
                chargeImbalancedRxns{i, 3});
    end
    fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\n');
end
if ~isempty(metsMissingFormulas)
    fprintf(fid, '\\subsection{Metabolites missing formulas}\n');
    fprintf(fid, '\\begin{tabular}{ll}\n');
    fprintf(fid, 'Metabolite & Name \\\\\n');
    fprintf(fid, '\\hline\\\\\n');
    for i = 1:size(metsMissingFormulas, 1)
        fprintf(fid, '%s & %s\\\\\n', strrep(metsMissingFormulas{i, 1}, '_', '\_'), ...
                strrep(metsMissingFormulas{i, 2}, '_', '\_'));
    end
    fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\n');
end

% Leak test
fprintf(fid, '\\section{Leak test}\n');
leakingMets = testLeakingMetabolites(model);
if ~isempty(leakingMets)
    fprintf(fid, '\\begin{tabular}{l}\n');
    for i = 1:length(leakingMets)
        fprintf(fid, '%s\\\\\n', strrep(leakingMets{i, 1}, '_', '\_'));
    end
    fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\n');
else
    fprintf(fid, 'No leaking metabolites.\n');
end

% ATP production
fprintf(fid, '\\section{ATP production}\n');
[atpFluxAerobic, atpFluxAnaerobic] = testATP(model);
fprintf(fid, '\\begin{tabular}{ll}\n');
fprintf(fid, 'ATP demand (aerobic): & %4.4f mmol/gDW/h\\\\\n', atpFluxAerobic);
fprintf(fid, 'ATP demand (anaerobic): & %4.4f mmol/gDW/h\\\\\n', atpFluxAnaerobic);
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\n');

% Growth
fprintf(fid, '\\section{Growth}\n');
[AerobicGrowth, AnaerobicGrowth] = testGrowth(model, biomassReaction);
fprintf(fid, '\\begin{tabular}{ll}\n');
fprintf(fid, 'Unlimited growth (aerobic): & %4.4f mmol/gDW/h\\\\\n', AerobicGrowth(1, 1));
fprintf(fid, 'Unlimited growth (anaerobic): & %4.4f mmol/gDW/h\\\\\n', AnaerobicGrowth(1, 1));
fprintf(fid, 'Western diet growth (aerobic): & %4.4f mmol/gDW/h\\\\\n', AerobicGrowth(1, 2));
fprintf(fid, 'Western diet growth (anaerobic): & %4.4f mmol/gDW/h\\\\\n', AnaerobicGrowth(1, 2));
fprintf(fid, '\\end{tabular}\n');
fprintf(fid, '\n');

% Carbon sources
fprintf(fid, '\\section{Carbon sources}\n');
[TruePositives, FalseNegatives] = testCarbonSources(model, microbeID, biomassReaction);
if ~isempty(FalseNegatives) || ~isempty(TruePositives)
    fprintf(fid, '\\begin{tabular}{ll}\n');
    fprintf(fid, '\\textit{In vitro} carbon source & Taken up by model\\\\\n');
    fprintf(fid, '\\hline\\\\\n');
    if ~isempty(FalseNegatives)
        for i = 1:length(FalseNegatives)
            fprintf(fid, '%s & %s\\\\\n', FalseNegatives{i}, 'FALSE');
        end
    end
    if ~isempty(TruePositives)
        for i = 1:length(TruePositives)
            fprintf(fid, '%s & %s\\\\\n', TruePositives{i}, 'TRUE');
        end
    end
    fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\n');
else
    fprintf(fid, 'No carbon sources reported for organism.\n');
end

% Fermentation products
fprintf(fid, '\\section{Fermentation products}\n');
[TruePositives, FalseNegatives] = testFermentationProducts(model, microbeID, biomassReaction);
if ~isempty(FalseNegatives) || ~isempty(TruePositives)
    fprintf(fid, '\\begin{tabular}{ll}\n');
    fprintf(fid, '\\textit{In vitro} fermentation product & Secreted by model\\\\\n');
    fprintf(fid, '\\hline\\\\\n');
    if ~isempty(FalseNegatives)
        for i = 1:length(FalseNegatives)
            fprintf(fid, '%s & %s\\\\\n', FalseNegatives{i}, 'FALSE');
        end
    end
    if ~isempty(TruePositives)
        for i = 1:length(TruePositives)
            fprintf(fid, '%s & %s\\\\\n', TruePositives{i}, 'TRUE');
        end
    end
    fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\n');
else
    fprintf(fid, 'No fermentation products reported for organism.\n');
end

% Growth on defined media
[growsOnDefinedMedium,~,growthOnKnownCarbonSources] = ...
    testGrowthOnDefinedMedia(model, microbeID, biomassReaction);
fprintf(fid, '\\section{Growth on defined medium}\n');
if ~strcmp(growsOnDefinedMedium,'NA')
    fprintf(fid, '\\begin{tabular}{ll}\n');
    if growsOnDefinedMedium==1
        fprintf(fid, 'The model grows on defined medium with at least one carbon source.\n');
    elseif growsOnDefinedMedium==0
        fprintf(fid, 'The model cannot on defined medium reported for the organism.\n');
    end
        fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\n');
%     fprintf(fid, '\\subsection{Growth rates on defined medium}\n');
%     fprintf(fid, '\\begin{tabular}{ll}\n');
%     fprintf(fid, 'Carbon source & Aerobic & Anaerobic\\\\\n');
%     fprintf(fid, '\\hline\\\\\n');
%     for i=1:size(growthOnKnownCarbonSources,1)
%         fprintf(fid, '%s & %s\\\\\n', growthOnKnownCarbonSources{i,1}, str2double(growthOnKnownCarbonSources{i,2}), str2double(growthOnKnownCarbonSources{i,3}));
%     end
%     fprintf(fid, '\\end{tabular}\n');
%     fprintf(fid, '\n');
else
    fprintf(fid, 'No growth media reported for organism.\n');
end

% Biomass precursor biosynthesis
fprintf(fid, '\\section{B-vitamin biosynthesis}\n');
[TruePositives, FalseNegatives] = testBiomassPrecursorBiosynthesis(model, microbeID);
if ~isempty(FalseNegatives) || ~isempty(TruePositives)
    fprintf(fid, '\\begin{tabular}{ll}\n');
    fprintf(fid, 'Vitamin & \\textit{De novo} synthesis in model\\\\\n');
    fprintf(fid, '\\hline\\\\\n');
    if ~isempty(FalseNegatives)
        for i = 1:length(FalseNegatives)
            fprintf(fid, '%s & %s\\\\\n', FalseNegatives{i}, 'FALSE');
        end
    end
    if ~isempty(TruePositives)
        for i = 1:length(TruePositives)
            fprintf(fid, '%s & %s\\\\\n', TruePositives{i}, 'TRUE');
        end
    end
    fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\n');
else
    fprintf(fid, 'No \\textit{de novo} vitamin biosynthesis reported for organism.\n');
end

% Uptake of known consumed metabolites
fprintf(fid, '\\section{Known consumed metabolites}\n');
[TruePositives, FalseNegatives] = testMetaboliteUptake(model, microbeID, biomassReaction);
if ~isempty(FalseNegatives) || ~isempty(TruePositives)
    fprintf(fid, '\\begin{tabular}{ll}\n');
    fprintf(fid, 'Consumed metabolites in model\\\\\n');
    fprintf(fid, '\\hline\\\\\n');
    if ~isempty(FalseNegatives)
        for i = 1:length(FalseNegatives)
            fprintf(fid, '%s & %s\\\\\n', FalseNegatives{i}, 'FALSE');
        end
    end
    if ~isempty(TruePositives)
        for i = 1:length(TruePositives)
            fprintf(fid, '%s & %s\\\\\n', TruePositives{i}, 'TRUE');
        end
    end
    fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\n');
else
    fprintf(fid, 'No known consumed metabolites reported for organism.\n');
end

% Production of known secretion products
fprintf(fid, '\\section{Known secretion products}\n');
[TruePositives, FalseNegatives] = testSecretionProducts(model, microbeID, biomassReaction);
if ~isempty(FalseNegatives) || ~isempty(TruePositives)
    fprintf(fid, '\\begin{tabular}{ll}\n');
    fprintf(fid, 'Secretion products in model\\\\\n');
    fprintf(fid, '\\hline\\\\\n');
    if ~isempty(FalseNegatives)
        for i = 1:length(FalseNegatives)
            fprintf(fid, '%s & %s\\\\\n', FalseNegatives{i}, 'FALSE');
        end
    end
    if ~isempty(TruePositives)
        for i = 1:length(TruePositives)
            fprintf(fid, '%s & %s\\\\\n', TruePositives{i}, 'TRUE');
        end
    end
    fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\n');
else
    fprintf(fid, 'No known secretion products reported for organism.\n');
end

% Bile acid biosynthesis
fprintf(fid, '\\section{Bile acid biosynthesis}\n');
[TruePositives, FalseNegatives] = testBileAcidBiosynthesis(model, microbeID, biomassReaction);
if ~isempty(FalseNegatives) || ~isempty(TruePositives)
    fprintf(fid, '\\begin{tabular}{ll}\n');
    fprintf(fid, 'Bile acid biosynthesis in model\\\\\n');
    fprintf(fid, '\\hline\\\\\n');
    if ~isempty(FalseNegatives)
        for i = 1:length(FalseNegatives)
            fprintf(fid, '%s & %s\\\\\n', FalseNegatives{i}, 'FALSE');
        end
    end
    if ~isempty(TruePositives)
        for i = 1:length(TruePositives)
            fprintf(fid, '%s & %s\\\\\n', TruePositives{i}, 'TRUE');
        end
    end
    fprintf(fid, '\\end{tabular}\n');
    fprintf(fid, '\n');
else
    fprintf(fid, 'No bile acid biosynthesis reported for organism.\n');
end

% Close document
fprintf(fid, '\\end{document}\n');
fclose(fid);

% write PDF
cd(reportFolder)
system(['pdflatex ' fileNameTex]);
cd(currentDir);

outputFile = strcat(microbeID, '.pdf');
end
