function [stats, statsR] = summarizeSamplingResults(modelA,modelB,path,nFiles,pointsPerFile,starting_model,dataGenes,show_rxns,fonts,hist_per_page,bin,fileNameA,fileNameB)
% The function summarizes the sampling results of the two models `modelA` and
% `modelB`. Subsequently, it returnes medians from the two models' sampling,
% FVA results for the respective reaction, simple test results (`stats`).
% Finally, histograms are produced, one for each reactions containing the
% distributions of the two models. The set of analyzed reactions can be
% limited (`show_rxns`). Reactions associated with genes of special interest,
% e.g. differentially expressed genes, can be marked to facilitate the
% analysis, and simplify the identification of interesting histograms.
%
% USAGE:
%
%    [stats, statsR] = summarizeSamplingResults(modelA, modelB, path, nFiles, pointsPerFile, starting_model, dataGenes, show_rxns, fonts, hist_per_page, bin, fileNameA, fileNameB)
%
% INPUTS:
%    modelA:                     Sampled modelA (condition 1)
%    modelB:                     Sampled modelB (condition 2)
%    path:                       Path to sampling output files
%    nFiles:                     Number of files saved, e.g., 20;
%    pointsPerFilePoints:        Points saved per file, e.g., 5000;
%    starting_model:             Original metabolic model (Recon)
%    dataGenes:                  Gene set, whose associated reactions should be emphasized by color, e.g., alternatively spliced or differentially expressed genes
%
% OPTIONAL INPUTS:
%    show_rxns:                  Vector of reactions that should be displayed, e.g., certain pathways or non-loop reactions
%    fonts:                      Font size (default = 9)
%    hist_per_page:              Defines the number of histogramms that are printed per page, e.g., 4, 9, or 25 (default = 9)
%    bin:                        Binning for histogramm (default = 30)
%    fileNameA:                  Name of files the sampling points are stored in
%    fileNameB:                  Name of files the sampling points are stored in
%
% OUTPUTS:
%    stats:                      Statistics from the sampling (Columns: Median modelA, Median modelB, minFlux_A, maxFlux_A, minFlux_B, maxFlux_B )
%    statsR:                     Reaction vector for stats output
%
% Depends on COBRA functions: `loadsamples`, `findRxnsFromGenes`, flux
% variability analysis / `fastFVA`
%
% .. Author: - Maike K. Aurich 22/08/15

if ~exist('hist_per_page','var') %% default settings
    hist_per_page=9;
end

if ~exist('fonts','var')
    fonts=9;
end

if ~exist('bin','var')
    bin = 30;
end

if ~exist('fileNameA','var')
    fileNameA = modelA;
end

if ~exist('fileNameB','var')
    fileNameB = modelB;
end

%% Summarize sampling results


samples_A = loadSamples([path filesep fileNameA], nFiles, pointsPerFile);
samples_B = loadSamples([path filesep fileNameB], nFiles, pointsPerFile);


%% Find the reactions associated, e.g., with the alternatively spliced or differentially expressed genes


Transcript = starting_model.genes;

cnt = 1;
for i = 1 : length(Transcript); % 1905
    a=regexp(Transcript{i,1},'\.','split');
    if ~isempty(char(a));
        if ~isempty(find(dataGenes== str2num(char(a(1)))));
            j = find(dataGenes == str2num(char(a(1))));
            Genes2Transcripts(j,cnt) = 1;
            ExpressionData.Transcript{cnt,1} = Transcript{i,1};
            ExpressionData.Locus(cnt,1) = dataGenes(j(1));
            cnt = cnt +1;

        end

    end
end

if ~exist('ExpressionData')
     Rxns_List_reg={};

else
    [results ListResults] = findRxnsFromGenes(starting_model, ExpressionData.Transcript,1,1);
    Rxns_List_reg = unique(ListResults(:,1));
end

%% find reactions that overlap

%Reactions = find(ismember(modelA.rxns, modelB.rxns)); %find indices
ReactionsName = modelA.rxns(find(ismember(modelA.rxns, modelB.rxns))); % find reaction names for figure titles

%%%
Reg_modelA_rxns= (find(ismember(modelA.rxns,Rxns_List_reg)));
Reg_modelA_rxnsNames= modelA.rxns(find(ismember(modelA.rxns, Rxns_List_reg)));
%%%
Reg_modelB_rxns= (find(ismember(modelB.rxns,Rxns_List_reg)));
Reg_modelB_rxnsNames= modelB.rxns(find(ismember(modelB.rxns, Rxns_List_reg)));

%% run FVAs on reduced models
[minFlux_modelB,maxFlux_modelB] = fluxVariability(modelB,0);
[minFlux_modelA,maxFlux_modelA] = fluxVariability(modelA,0);
FVA_results.minFlux_modelA = minFlux_modelA;
FVA_results.maxFlux_modelA = maxFlux_modelA;
FVA_results.minFlux_modelB = minFlux_modelB;
FVA_results.maxFlux_modelB = maxFlux_modelB;



%% For all common reations of the subset of NL
title_modelA = regexprep(modelA.rxns,'_','- ');

if ~exist('show_rxns'); % if a subset of reactions is not defined, use all reactions found in both models
    show_rxns = ReactionsName;
end

%reactions to illustration
Reactions_show_rxns= ReactionsName(find(ismember(ReactionsName,show_rxns)));
clear Reactions

%find indices in model A and B with reaction names
Reactions= find(ismember(modelA.rxns,Reactions_show_rxns));
Reactions_modelA_Names= modelA.rxns(find(ismember(modelA.rxns,Reactions_show_rxns)));
Reactions_modelB = (find(ismember(modelB.rxns,Reactions_show_rxns )));
%Reactions_modelB_Names = modelB.rxns(find(ismember(modelB.rxns,Reactions_show_rxns )));



%% make figure (automatically saved to pdf)
pages = length(show_rxns)/hist_per_page;
v=0;
for g=1:pages % see if pages works
    figure;
    for i = 1:hist_per_page

        % save the last page even if page is not full
        if i+v>length(Reactions_modelA_Names);
            fprintf('Saving results to %s.png.\n', [path filesep 'sampling_page' num2str(g)]);
            saveas(gcf, [path filesep 'sampling_page' num2str(g)], 'pdf');
            break
        end

        %define size of subplot
        if hist_per_page==4

            subplot (2,2,i)

        elseif hist_per_page==9

            subplot (3,3,i)

        elseif hist_per_page==5

            subplot (5,5,i);
        end

        % position of rxns in modelA
        %j=find(ismember(modelA.rxns,(Reactions_modelA_Names(i+v))));
        j=Reactions(i+v);
        MC = median(samples_A(j,:));
        %k= find(ismember(modelB.rxns,(Reactions_modelB_Names(i+v))));
        k= Reactions_modelB(i+v);
        MM = median(samples_B(k,:));
        [N,X] = hist(samples_A(j,:),bin);
        plot(X,N, 'b');set(gca,'FontSize',fonts)

        hold on

        [N,X] = hist(samples_B(k,:),bin);
        plot(X,N, 'r');set(gca,'FontSize',fonts)

        minFlux_A = FVA_results.minFlux_modelA(j,1);
        maxFlux_A = FVA_results.maxFlux_modelA(j,1);

        minFlux_B = FVA_results.minFlux_modelB(k,1);
        maxFlux_B = FVA_results.maxFlux_modelB(k,1);

        % collect statistics for output and illustrations
        stats(i+v,1)= MC;
        stats(i+v,2)= MM;
        stats(i+v,3)= minFlux_A;
        stats(i+v,4)= maxFlux_A;
        stats(i+v,5)= minFlux_B;
        stats(i+v,6)= maxFlux_B;
        statsR(i+v,1) = modelA.rxns(j);


        %% color if is Data-gene associated reaction
        if ismember(modelA.rxns{j},Reg_modelA_rxnsNames)

            titleString = [title_modelA{j}];

            titleString2 =['FVA(modelA): ' num2str(minFlux_A) ',' num2str(maxFlux_A)];
            titleString3 =['FVA(modelB): ' num2str(minFlux_B) ',' num2str(maxFlux_B)];
            titleString4 = ['Median(modelA): ' num2str(MC)];
            titleString5 = ['Median(modelB): ' num2str(MM) ];
            title(titleString, 'Color','r');
            h=  title(strvcat(titleString , titleString2 ,titleString3, titleString4 ,titleString5),'Color','r' );
            set(h,'fontsize',fonts)

        else
            titleString = [title_modelA{j}];
            titleString2 =['FVA(modelA): ' num2str(minFlux_A) ',' num2str(maxFlux_A)];
            titleString3 =['FVA(modelB): ' num2str(minFlux_B) ',' num2str(maxFlux_B)];
            titleString4 =['Median(modelA): ' num2str(MC)];
            titleString5 =['Median(modelB): ' num2str(MM)];

            h= title(strvcat(titleString , titleString2,titleString3, titleString4 ,titleString5));
            set(h,'fontsize',fonts);
        end

    end
    fprintf('Saving results to %s.png.\n', [path filesep 'sampling_page' num2str(g)]);
    saveas(gcf, [path filesep 'sampling_page' num2str(g)], 'pdf');
    close
    v=v+hist_per_page;
end
end
