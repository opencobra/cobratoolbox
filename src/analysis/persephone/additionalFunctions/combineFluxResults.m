function combineFluxResults(directory1,directory2,resultdirectory,set_regexp)
% This function merges & prunes the FBA solutions between two runs of the 
% optimiseRxnMultipleWBMs.m function. Reaction fluxes, FBA statistics, & 
% shadow prices get therefore concatenated. Note that in case the sample 
% filenames differ from the standard, the regular expression needs to be adapted.
%
% USAGE:
%       [dietInfo, dietGrowthStats] = ensureHMfeasibility(hmDirectory, Diet)
%
% INPUTS
% directory1            [char array] Directory to flux solutions from the first run
% directory2            [char array] Directory to flux solutions from the second run
% resultdirectory       [char array] Directory to empty folder where the combined fluxes
%                       will be saved. 
%
% OPTIONAL INPUT
% set_regexp            [char array] Specifying alternative regular expression in case
%                       the sample filenames are different from their style 
%                       than the standard optimiseRxnMultipleWBMs.m output.
%
% Authors:  
%   - Tim Hensen, 2024
%   - modified by Jonas Widder, 10/2024 & 11/2024 (function can now also merge dirs
%     with unequal number of samples + added set_regexp option)

if ~exist(resultdirectory,'dir')
    mkdir(resultdirectory)
end

% Define standard regexp to filter filenames if user doesn´t provide one
% The standard regexp extracts the chars between "FBA_sol_" & ".mat" from original
% filename
if nargin < 4
    set_regexp = '(?<=FBA_sol_).*?(?=\.mat)';
    % % Initial regExp used by TH for earlier file naming convention
    % set_regexp = '(?<=microbiota_model_diet_).*?(?=_)'
end

% Obtain paths to FBA solutions in both runs
pathsRun1 = string(append(what(directory1).path, filesep, what(directory1).mat));
pathsRun2 = string(append(what(directory2).path, filesep, what(directory2).mat));

% Find names of FBA solutions for each sample
namesRun1 = regexp(pathsRun1,set_regexp,'match');
namesRun2 = regexp(pathsRun2,set_regexp,'match');

% Exchange the two germfree models (labeled by 'GM') with Harvey & Harvetta
% using local function "replaceGF"
namesRun1 = cellfun(@(x) replaceGF(x), namesRun1, 'UniformOutput', false);
namesRun2 = cellfun(@(x) replaceGF(x), namesRun2, 'UniformOutput', false);

% Get paths for common samples between both dirs
[commonSamples, ia, ib] = intersect(string(namesRun1), string(namesRun2), 'stable');
pathsRun1_commonSamples = pathsRun1(ia);
pathsRun2_commonSamples = pathsRun2(ib);

% Get solution path for common samples between both dirs
pathsResults = string(append(resultdirectory, filesep, commonSamples, '.mat'));

tic
% Merge & prune common samples
for i = 1:length(pathsResults)
    % Load results (if GM model, then do not load microbiome results, as NaN anyway)
    if ~contains(pathsRun1_commonSamples(i),{'GF'})
        % Load main results
        main = load(pathsRun1_commonSamples(i),'rxns','ID','sex','speciesBIO','shadowPriceBIO','f','stat', 'relAbundances', 'OrigStat');
        % Load additional results
        new = load(pathsRun2_commonSamples(i),'rxns','shadowPriceBIO','f','stat', 'OrigStat');
    else
        % Load main results
        main = load(pathsRun1_commonSamples(i),'rxns','ID','sex','f','stat', 'OrigStat');
        % Load additional results
        new = load(pathsRun2_commonSamples(i),'rxns','f','stat', 'OrigStat');
    end

    if size(new.rxns,2)==1
        new.rxns = new.rxns';
    end
    if size(main.rxns,2)==1
        main.rxns = main.rxns';
    end

    % Check for duplicate reactions
    [~,dup] = intersect(new.rxns,main.rxns);
    cols=find(structfun(@(x) size(x,2)>1,new));

    % Remove duplicate entries
    field = string(fieldnames(new));
    for j = cols'
        new.(field(j))(:,dup)=[];
    end

    if ~contains(pathsRun1(i),{'GF'})
        % Add shadow prices for non-GF samples
        main.shadowPriceBIO = [main.shadowPriceBIO new.shadowPriceBIO];
    end

    % Add data to main
    main.rxns = [main.rxns new.rxns];
    main.f = [main.f new.f];
    main.stat = [main.stat new.stat];
    main.OrigStat = [main.OrigStat new.OrigStat];
    
    % Save updated main 
    save(pathsResults(i),'-struct', 'main')
end
toc
end


function newStr = replaceGF(str)
    % Helper function to exchange a string containing "GF" by "Harvey" or
    % "Harvetta" filenames dependent if male/female.
    % FileNaming will probably change in future, therefore this function is
    % only for temporary bug fix!
    % INPUT: str:       String to replace if contains "GF".
    % OUTPUT: newStr:   New string with Harvey/Harvetta naming.
    %
    % AUTHOR:
    %   Jonas Widder, 11/2024
    if contains(str, 'female') && contains(str, 'GF')
        newStr = 'Harvetta_1_04c_female';
    elseif contains(str, 'male') && contains(str, 'GF')
        newStr = 'Harvey_1_04c_male';
    else
        newStr = str;
    end
end