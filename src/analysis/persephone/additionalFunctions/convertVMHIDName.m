function [foundVMHIDs, foundMetNames, similarMets] = convertVMHIDName(metNames,VMHIDs, suggestSimilar)
% FOUR FUNCTIONS:
%
%           1. Retrieve metabolite IDs corresponding to the given metabolite names AND/OR
%           2. Retrieve metabolite names corresponding to a given metabolite ID or some
%               reactions
%           3. Convert metabolite tranport reactions e.g., DM_glc_d[bc] to D-Glucose or
%               EX_glc_D[c] to metabolite name e.g., D-Glucose.
%           4. Suggest similar names for metabolite names provided that are
%               not found in the data base
%
%
% Inputs:
%    metNames -         EITHER: Cell array of metabolite names (strings) or metabolilte transport
%                       reactions (can be mixed)for which IDs are required or flag indicating to skip step (0).
%
%    metIDs -           Cell array of metabolite IDs (strings) for which IDs are
%                       required or flag indicating to skip step (0).
%
%    suggestSimilar -   Flag indicating whether to generate suggestions (1) or not (0).
%
% Outputs:
%
%    foundVMHIDs -      Cell array of metabolite IDs corresponding to the input names.
%    foundMetNames -    Cell array of metabolite Names corresponsing to the input IDs
%    similarMets -      Cell array of possible matches for each unfound metabolite name,
%                       when searching for names.
%
%
% Other requirements: COBRA toolbox installation (and paths set)
%
%
% EXAMPLE OF USE:
%
% VMHIDs = {'DM_gam[bc]'; 'malttr'};
% metNames = {'D-glucose', 'fructose', 'carbon'};
% % metNames = false;
% % VMHIDs = false;
% % suggestSimilar = false;
% suggestSimilar = true;
%
% % [foundVMHIDs, foundMetNames, similarMets] = convertVMHIDName(metNames,VMHIDs, suggestSimilar);
%
% Author: - Anna Sheehy & Tim Hensen - 18/07/2024

% Load the VMH Database
DB = loadVMHDatabase();

%% OPTION ONE: CONVERT ID TO NAME

if exist('VMHIDs', 'var')
    disp('VMH IDs provided, finding corresponding names from VMH')
    
    %add where relevant to this list
    strgToRemove = {'DM_', 'EX_', 'Micro_', 'Muscle_', 'Heart_', 'Brain_', ...
        'Adipocytes_', 'Agland_', 'Bcells_', 'Brain_', 'Breast_', 'CD4Tcells_', ...
        'Cervix_', 'Colon_', 'Gall_', 'Heart_', 'Kidney_', 'Liver_', 'Lung_', ...
        'Monocyte_', 'Muscle_', 'Nkcells_', 'Ovary_', 'Pancreas_', 'Platelet_', ...
        'Prostate_', 'Pthyroidgland_', 'RBC_', 'Retina_', 'Scord_', 'sIEC_', 'Skin_', ...
        'Spleen_', 'Stomach_', 'Testis_', 'Thyroidgland_', 'Urinarybladder_', 'Uterus_'};
    removeAfterBracket = @(str) regexprep(str, '\[.*', '');
    
    for i = 1:length(VMHIDs)
        % Remove anything after the left square bracket
        if contains(VMHIDs{i}, '[')
            VMHIDs{i} = removeAfterBracket(VMHIDs{i});
        end
        
        % Keep checking for and removing strings in strgToRemove until none are found
        keepChecking = true;
        while keepChecking
            keepChecking = false;
            for j = 1:length(strgToRemove)
                if contains(VMHIDs{i}, strgToRemove{j})
                    VMHIDs{i} = strrep(VMHIDs{i}, strgToRemove{j}, '');
                    keepChecking = true; % If a string was removed, check again
                end
            end
        end
    end
  
    
    % Get metabolite names
    disp('Converting VMH IDs to metabolite names')
    [~,~,ib] = intersect(VMHIDs,DB.metabolites(:,1),'stable');
    metaboliteNames = DB.metabolites(ib,2)';
    
    % Repair metabolite names that are wrong or unreadible in the VMH
    % Please extend this list where necessary
    metaboliteNames = string(metaboliteNames);
    metaboliteNames(matches(metaboliteNames,"3alpha,12alpha-Dihydroxy-7-oxo-5beta-cholanate")) = '7-dehydro-CA';
    metaboliteNames(matches(metaboliteNames,"5,10-Methylenetetrahydrofolate")) = 'Tetrahydromethylenefolate';
    metaboliteNames(matches(metaboliteNames,"Isobutyrate, 2-Methylpropanoate")) = 'Isobutyrate';
    metaboliteNames(matches(metaboliteNames,"Isovalerate, 3-Methylbutanoate")) = 'Isovalerate';
    metaboliteNames(matches(metaboliteNames,"Sulfate derivative of norepinephrine")) = 'Norepinephrine sulphate';
    metaboliteNames(matches(metaboliteNames,"Ursodiol")) = 'Ursodeoxycholate';
    metaboliteNames(matches(metaboliteNames,"deoxycholic acid")) = 'Deoxycholate';
    metaboliteNames(matches(metaboliteNames,"formaldehyde")) = 'Formaldehyde';
    metaboliteNames(matches(metaboliteNames,"lithocholate")) = 'Lithocholate';
    metaboliteNames(matches(metaboliteNames,"p-Cresol sulfate")) = 'p-Cresol sulphate';
    metaboliteNames(matches(metaboliteNames,"4-Aminobutanoate")) = 'GABA';
    metaboliteNames(matches(metaboliteNames,"S-Adenosyl-L-methionine")) = 'SAM';
    metaboliteNames(matches(metaboliteNames,"S-Adenosyl-L-homocysteine")) = 'SAH';
    metaboliteNames(matches(metaboliteNames,"agmatinium(2+)")) = 'Agmatine';
    % TEMP
    %metaboliteNames(matches(metaboliteNames,{'L-arginine'})) = 'creatine/L-arginine';
    
    foundMetNames = cellstr(metaboliteNames)';
    
elseif VMHIDS == 0
    disp('No metabolite IDs provided, skipping conversion of IDs to names')
else
    disp('metIDs is neither a list of VMHIDs nor a logical set to false, please provide an input')
end



%% OPTION TWO: CONVERT NAME TO ID

if ~islogical(metNames)
    disp('Metabolite names provided, finding corresponding IDs from VMH')
    
    % Initialize the output cell arrays for metabolite IDs and suggestions
    foundVMHIDs = cell(size(metNames))';
    n = length(metNames);
    
    if suggestSimilar == 1
        % Initialize suggestions cell array if suggest flag is true
        suggestions = cell(700, n);
        suggestions(1, :) = metNames;
    else
        % Initialize an empty suggestions cell array if suggest flag is false
        suggestions = cell(size(metNames));
    end
    
    % Initialize counters for found and unfound metabolites
    foundCount = 0;
    unfoundCount = 0;
    
    % Loop through each input metabolite name
    for i = 1:length(metNames)
        metName = metNames{i};
        % Find the metabolite name in the database
        [~,~,ib] = intersect(metName, DB.metabolites(:,2),'stable');
        
        % If the metabolite is found, retrieve its ID
        if ~isempty(ib)
            foundVMHIDs{i} = DB.metabolites(ib,1);
            foundCount = foundCount + 1;
            
            % Set suggestedMets message if all metabolites are found and suggest is true
            if n == 1 && suggestSimilar == 1
                similarMets = 'All metabolites found';
            end
            
            % Clear column in suggestions if found
            if width(suggestions) == 1
                similarMets = 'All metabolites found';
            else
                suggestions(:, i) = [];
            end
            
        elseif suggestSimilar == 1
            % If not found and suggest flag is true, try to find partial matches
            partialMatches = find(contains(DB.metabolites(:,2), metName));
            unfoundCount = unfoundCount + 1;
            
            % If partial matches are found, list them as suggestions
            if ~isempty(partialMatches)
                % Retrieve metabolite names from the database that partially match the input metabolite name
                ToOrder = DB.metabolites(partialMatches, 2);
                % Sort based on the length of each metabolite name in ascending order
                [~, sortIdx] = sort(cellfun(@length, ToOrder));
                ToOrder = ToOrder(sortIdx);
                % Determine the number of suggestions and update the suggestions array
                k = length(partialMatches) + 1;
                suggestions(2:k, unfoundCount) = ToOrder;
            else
                suggestions{unfoundCount} = [];
            end
            
            % Assign an empty array for the unfound metabolite ID
            foundVMHIDs{i} = [];
        end
    end
    
    % Display the number of found and unfound metabolites
    fprintf('Number of found metabolites: %d\n', foundCount);
    fprintf('Number of unfound metabolites: %d\n', unfoundCount);
    
    % Set suggestedMets to suggestions if it does not exist
    if ~ischar('similarMets')
        similarMets = suggestions;
    end
    
elseif metNames == 0
    disp('No metabolite names provided, skipping conversion of names to IDs')
    foundVMHIDs = "No metabolite names provided";
    if suggestSimilar == 1
        disp('No metabolite names provided- cannot suggest similar names')
    end
    
else
    disp('metNames is neither a list of names nor a logical set to false, please provide an input')
    foundVMHIDs = "No metabolite names provided";
end


end


