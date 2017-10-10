function Tmodel = cleanTmodel(Tmodel, varargin)
% Reorganizes and checks `Tmodel` for completeness. To be used
% immediately after `addToTmodel`. Called by `addToTmodel`, `mergeModelsBorg`, `mergeTrxns`, calls `TmodelFields`, `buildRxnEquations`, `removeDuplicateNames`, `makeNamesUnique`, `charpos`, `removeProblematicCharacters`.
%
% USAGE:
%
%    Tmodel = cleanTmodel(Tmodel)
%
% INPUTS:
%    Tmodel:       Template model.
%
% OPTIONAL INPUTS:
%    'Verbose':    Ask when performing certain operations.
%
% OUTPUTS:
%    Tmodel:       Cleaned template model
%
% Please cite:
% `Sauls, J. T., & Buescher, J. M. (2014). Assimilating genome-scale
% metabolic reconstructions with modelBorgifier. Bioinformatics
% (Oxford, England), 30(7), 1036?8`. http://doi.org/10.1093/bioinformatics/btt747
%
% ..
%    Edit the above text to modify the response to help addMetInfo
%    Last Modified by GUIDE v2.5 06-Dec-2013 14:19:28
%    This file is published under Creative Commons BY-NC-SA.
%
%    Correspondance:
%    johntsauls@gmail.com
%
%    Developed at:
%    BRAIN Aktiengesellschaft
%    Microbial Production Technologies Unit
%    Quantitative Biology and Sequencing Platform
%    Darmstaeter Str. 34-36
%    64673 Zwingenberg, Germany
%    www.brain-biotech.de

verbose = false ; % Declare variables.
if ~isempty(varargin)
    if sum(strcmp('Verbose', varargin))
        verbose = true ;
    end
end

% Grab fields names.
fields = TmodelFields ;

% Reaction related cell field names.
rxnFields = fields{1} ;
% Reaction related double Fields (which are kept model specific).
rNumFields = fields{2} ;
% Metabolite related cell field names.
metFields = fields{3} ;
% Metabolite related double field names.
mNumFields = fields{4} ;

% Model names.
moNames = fieldnames(Tmodel.Models) ;

% Number of reactions and number of metabolites.
nRxns = length(Tmodel.rxns) ;
nMets = length(Tmodel.mets) ;

% Set flags for if Verbose mode is on
if isempty(varargin)
    mergeRxns = 'y' ;
    askeverytime = 0 ;
    beautifynames = 'y' ;
    askeverytimeb = 0 ;
else
    if verbose
        mergeRxns = input(['Should I try merging identical reactions? ' char(10) ...
                               'y...yes in all cases' char(10) ...
                               'a...ask me every time' char(10) ...
                               'n...no thanks (default)' char(10)], 's') ;
        askeverytime = strcmpi(mergeRxns, 'a') ;

        beautifynames = input(['Should I try to replace cryptic names by nicer ones? ' char(10) ...
                           'y...yes in all cases' char(10) ...
                           'a...ask me every time' char(10) ...
                           'n...no thanks (default)' char(10)], 's') ;
        askeverytimeb = strcmpi(beautifynames,'a') ;
    else
        mergeRxns = 'y' ;
        askeverytime = 0 ;
        beautifynames = 'y' ;
        askeverytimeb = 0 ;
    end
end

%% Lengthen rev, lb, ub, and c arrays for old models.
for iField = 1:length(rNumFields)
    for iMo = 1:length(moNames)
        nowArray = Tmodel.(rNumFields{iField}).(moNames{iMo}) ;
        if length(nowArray) ~= nRxns
            nowArray(end:nRxns) = 0 ;
            Tmodel.(rNumFields{iField}).(moNames{iMo}) = nowArray;
        end
    end
end

%% Lengthen reaction and metabolite identity arrays, convert to logicals.
for iMo = 1:length(moNames)
    % Reactions.
    rxnsArray = Tmodel.Models.(moNames{iMo}).rxns ;
    if length(rxnsArray) ~= nRxns
        rxnsArray(end+1:nRxns) = 0 ;
    end
    Tmodel.Models.(moNames{iMo}).rxns = logical(rxnsArray) ;

    % Metabolites.
    metsArray = Tmodel.Models.(moNames{iMo}).mets ;
    if length(metsArray) ~= nMets
        metsArray(end+1:nMets) = 0 ;
    end
    Tmodel.Models.(moNames{iMo}).mets = logical(metsArray) ;
end

%% Check for accidently duplicated reactions and metabolites
Sfind = zeros(size(Tmodel.S)) ;
Sfind(Tmodel.S ~= 0) = 1 ;
metpos = cell(1, nRxns) ;
metposstr = cell(1, nRxns) ;
for i = 1:nRxns
    metpos{i} = find(Sfind(:, i)) ;
    metposstr{i} = num2str(metpos{i}') ;
end
[~, a, b] = unique(metposstr) ;
mergerxns = {} ; mergerxnratio = [] ;
modelnames = fieldnames(Tmodel.Models)' ;
for im = 1:length(modelnames)
    rxnNowPresent(:, im) = Tmodel.Models.(modelnames{im}).rxns ;
end

if ismember(mergeRxns, {'y', 'a', 'Y', 'A'})
    for i = 1:nRxns
        if ~ismember(i, a) % rxns that use the same metabolites
            eqset = find(b == b(i)) ;
            stoicheck = 1 ;
            for ie = 2:length(eqset)
                rxnratio = unique(Tmodel.S(metpos{i}, eqset(1)) ./ Tmodel.S(metpos{i}, eqset(ie))) ;
                if length(rxnratio) == 1 && ~isnan(rxnratio)  && ...
                        sum(rxnNowPresent(eqset(1), :) .* rxnNowPresent(eqset(ie), :)) == 0
                    if askeverytime
                    % if reactions have the same stoichiometry, maybe with a factor
                    disp([Tmodel.rxns{eqset(1)} '(' strjoin(modelnames(rxnNowPresent(eqset(1), :)), '|') ')' ' and ' ...
                          Tmodel.rxns{eqset(ie)}  '(' strjoin(modelnames(rxnNowPresent(eqset(ie), :)), '|') ')'  ...
                          ' seem to have the same stoichiometry' char(10) ...
                         Tmodel.rxnEquations{eqset(1)} '  VS  ' Tmodel.rxnEquations{eqset(ie)} char(10) ])
                    shouldmerge = input('Do you want to merge them? [Y/n] ' ,'s') ;
                    elseif strcmpi(mergeRxns, 'y')
                        shouldmerge = 'y' ;
                    end
                    if ~strcmp(shouldmerge, 'n')
                        mergerxns{end + 1} = eqset ;
                        mergerxnratio(end + 1) = rxnratio ;
                        disp(['merging ' Tmodel.rxns{eqset(1)} '(' strjoin( modelnames(rxnNowPresent(eqset(1), :)), '|') ')' ' and ' ...
                             Tmodel.rxns{eqset(ie)}  '(' strjoin( modelnames(rxnNowPresent(eqset(ie), :)), '|') ')' ])
                    end
                end
            end
        end
    end
    if length(mergerxns) ~= 0
        Tmodel = mergeTrxns(Tmodel, mergerxns, mergerxnratio) ;
        disp(char(10))
    end
end

% Re-count number of reactions and number of metabolites.
nRxns = length(Tmodel.rxns) ;
nMets = length(Tmodel.mets) ;

%% Prefer biologist-friendly names for reactions and metabolites
if ismember(beautifynames,{'y', 'a', 'Y', 'A'})
    for im = 1:nMets
        nowIDsep = {Tmodel.mets{im}(1:end-3)} ;
        nowcomp = Tmodel.mets{im}(end-2:end) ;
        % parse alternative metIDs
        nowIDs = Tmodel.metID{im};
        nowdelim1 = strfind(nowIDs,':') ;
        nowdelim2 = [strfind(nowIDs,'|') strfind(nowIDs,':') length(nowIDs) + 1] ;
        for ii = 1:length(nowdelim1)
            nowIDsep{ii + 1} = nowIDs(nowdelim1(ii) + 1:min(nowdelim2(nowdelim2 > nowdelim1(ii))) - 1) ;
            nowIDsep{ii + 1} = lower(nowIDsep{ii + 1}(1:min([strfind(nowIDsep{ii + 1},'[') - 1, length(nowIDsep{ii + 1})]))) ;
            nowIDsep{ii + 1} = removeProblematicCharacters(nowIDsep{ii + 1}) ;
        end
        [nowIDalt, ~, freq] = unique(nowIDsep) ;
        nowIDalt = nowIDalt(~cellfun(@isempty, nowIDalt)) ;
        tailnum = [] ; idfreq = [] ;
        if length(nowIDalt) == 1
            % no alternative name found, keep the current one
        else
            for ii = 1:length(nowIDalt)
                tailnum(ii) = length(nowIDalt{ii}(max(find(charpos(nowIDalt{ii}))):end)) - 1 ;
                idfreq(ii) = sum(freq == ii) ;
            end
            [~, goodids] = min((tailnum + 2)./(2*idfreq)) ;
            % if leading character is a number in original name but "a" in new
            % name, then do nothing
            nowcharpos = charpos(Tmodel.mets{im}) ;
            if ~strcmp(nowIDalt{goodids}, Tmodel.mets{im}(1:end - 3)) && ...
                    ~(~nowcharpos(1) && strcmp(nowIDalt{goodids}(1), 'a')) && ...
                   length(Tmodel.mets{im}(max(find(charpos(Tmodel.mets{im}(1:end - 3)) ) ):end - 3)) > 4
                if askeverytimeb
                    replacethistime = input(['Should I rename ' Tmodel.mets{im} ' to '...
                                             nowIDalt{goodids} nowcomp ' (y/n)?'], 's') ;
                end
                if ~askeverytimeb || strcmpi(replacethistime, 'y')
                    disp(['renaming ' Tmodel.mets{im} ' to ' nowIDalt{goodids} nowcomp])
                    Tmodel.mets{im} = [nowIDalt{goodids} nowcomp] ;
                end
            end
        end
    end
    for ir = 1:nRxns
        % transport to extracellular reaction
        if numel(find(Tmodel.S(:, ir))) == 1
            if strcmp(Tmodel.mets{(Tmodel.S(:, ir))~=0}(end - 2:end), '[e]')
                newrxnname = ['ex_' lower(Tmodel.mets{(Tmodel.S(:, ir))~=0}(1:end - 3)) '_e'] ;
                if ~strcmp(newrxnname, Tmodel.rxns{ir})
                    if askeverytimeb
                        replacethistime = input(['Should I rename '  Tmodel.rxns{ir}  ' to '...
                                             newrxnname ' (y/n)?'], 's') ;
                    end
                    if ~askeverytimeb || strcmpi(replacethistime, 'y')
                        disp(['correcting ' Tmodel.rxns{ir} ' to ' newrxnname])
                        Tmodel.rxns{ir} = newrxnname ;
                    end
                end
            end
        else % normal reactions
            nowIDsep = Tmodel.rxns(ir) ;
            if strcmp(nowIDsep{1}(end - 1),'_')
                % this reaction has probably been already renamed to ensure
                % unique reaction names. Therefore do nothing.
                continue
            end
            % parse alternative rxnIDs
            nowIDs = Tmodel.rxnID{ir} ;
            nowdelim1 = strfind(nowIDs, ':') ;
            nowdelim2 = [strfind(nowIDs, '|') strfind(nowIDs, ':') length(nowIDs) + 1] ;
            for ii = 1:length(nowdelim1)
                nowIDsep{ii+1} = nowIDs(nowdelim1(ii) + 1:min(nowdelim2(nowdelim2 > nowdelim1(ii))) - 1) ;
                nowIDsep{ii+1} = lower(nowIDsep{ii + 1}(1:min([strfind(nowIDsep{ii + 1},'[') - 1, length(nowIDsep{ii + 1})]))) ;
                nowIDsep{ii+1} = removeProblematicCharacters(nowIDsep{ii + 1}) ;
            end
            [nowIDalt, ~, freq] = unique(nowIDsep) ;
            tailnum = [] ; idfreq = [] ;
            if length(nowIDalt) == 1
                % no alternative name found, keep the current one
            else
                for ii = 1:length(nowIDalt)
                    tailnum(ii) = length(nowIDalt{ii}(max(find(charpos(nowIDalt{ii}))):end)) - 1 ;
                    idfreq(ii) = sum(freq == ii) ;
                end
                [~, goodids] = min((tailnum + 2) ./ (2 * idfreq)) ;
                % check that the name is not already taken
                if sum(strcmp(Tmodel.rxns, nowIDalt{goodids})) == 0 && ...
                   length(Tmodel.rxns{ir}(max(find(charpos(Tmodel.rxns{ir}))):end)) > 4
                    if askeverytimeb
                        replacethistime = input(['Should I rename '  Tmodel.rxns{ir}  ' to '...
                                             nowIDalt{goodids} ' (y/n)?'], 's') ;
                    end
                    if ~askeverytimeb || strcmpi(replacethistime, 'y')
                        disp(['replacing ' Tmodel.rxns{ir} ' by ' nowIDalt{goodids}])
                        Tmodel.rxns{ir} = nowIDalt{goodids} ;
                    end
                end
            end
        end
    end
end

%% Make sure all names are unique before reorganizing.
% Rebuild reaction equations so there is a hint for renaming rxns.
Tmodel = buildRxnEquations(Tmodel) ;
if verbose ; fprintf('Checking if reaction IDs (.rxns) are unique.\n') ; end
Tmodel.rxns = makeNamesUnique(Tmodel.rxns, Tmodel.rxnEquations) ;
if verbose ; fprintf('Checking if metabolite IDs (.mets) are unique.\n') ; end
Tmodel.mets = makeNamesUnique(Tmodel.mets, Tmodel.metNames) ;

% Remove duplicate met IDs.
Tmodel.metID = removeDuplicateNames(Tmodel.metID) ;

% Rebuild reaction equations.
Tmodel = buildRxnEquations(Tmodel) ;

%% Reorder reactions and metabolites alphabetically.
% Reorder reaction related lists.
[~, rxnI] = sort(Tmodel.rxns) ;
for iField = 1:length(rxnFields)
    Tmodel.(rxnFields{iField}) = Tmodel.(rxnFields{iField})(rxnI) ;
end
for iField = 1:length(rNumFields)
    for iMo = 1:length(moNames)
        Tmodel.(rNumFields{iField}).(moNames{iMo}) = ...
            Tmodel.(rNumFields{iField}).(moNames{iMo})(rxnI) ;
    end
end

% Reorder metabolite related lists.
[~, metI] = sort(Tmodel.mets) ;
for iField = 1:length(metFields)
    Tmodel.(metFields{iField}) = Tmodel.(metFields{iField})(metI) ;
end
for iField = 1:length(mNumFields)
    Tmodel.(mNumFields{iField}) = ...
        Tmodel.(mNumFields{iField})(metI) ;
end

% Reorder identity arrays.
for iMo = 1:length(moNames)
    Tmodel.Models.(moNames{iMo}).rxns = ...
        Tmodel.Models.(moNames{iMo}).rxns(rxnI) ;
    Tmodel.Models.(moNames{iMo}).mets = ...
        Tmodel.Models.(moNames{iMo}).mets(metI) ;
end

% Reorder S matrix.
Tmodel.S = Tmodel.S(:, rxnI) ;
Tmodel.S = Tmodel.S(metI, :) ;

%% Share information between the same metabolite in different compartments.
% Metabolite fields to share information between
share = {'metNames' 'metFormulas' 'metKEGGID' 'metSEEDID' 'metChEBIID' ...
         'metPubChemID' 'metInChIString'} ;

metsNoComp = cell(nMets,1) ;
for iMet = 1:nMets
    metsNoComp{iMet} = Tmodel.mets{iMet}(1:end - 3) ;
end
uniqMets = unique(metsNoComp,'first') ;

% Create combined formation fields for each metabolite and redistribute.
for iMet = 1:length(uniqMets)
  % Find sister metabolites
  sMets = find(strcmp(uniqMets{iMet}, metsNoComp)) ;
  if length(sMets) > 1
    % Create combined information for each field.
    for iF = 1:length(share)
      info = {''} ;
      for iSis = 1:length(sMets)
        % If the field is not empty, break information into parts
        % (as seperated by pipes), and add that information in if
        % it is not already present.
        if ~isempty(Tmodel.(share{iF}){sMets(iSis)})
          pipePos = [0 ...
                     strfind(Tmodel.(share{iF}){sMets(iSis)}, '|') ...
                     length(Tmodel.(share{iF}){sMets(iSis)}) + 1] ;
          for j = 1:length(pipePos) - 1
            nowInfo = Tmodel.(share{iF}){sMets(iSis)} ...
                      (pipePos(j) + 1:pipePos(j + 1) - 1) ;
            % If the info does not already exist.
            if isempty(strfind(info{1}, nowInfo))
              % If it is the first piece of information or additional.
              if isempty(info{1})
                info{1} = nowInfo ;
              else
                info{1} = strcat(info{1}, '|', nowInfo) ;
              end
            end
          end
        end
      end
      for iSis = 1:length(sMets)
          Tmodel.(share{iF}){sMets(iSis)} = info{1} ;
      end
      clear info
    end
  end
end

% Now remove duplicate information which may have snuck in.
for iField = 1:length(share)
    Tmodel.(share{iField}) = removeDuplicateNames(Tmodel.(share{iField})) ;
end

%% Remove duplicate reaction longnames and IDs
Tmodel.rxnNames = removeDuplicateNames(Tmodel.rxnNames) ;
Tmodel.rxnID = removeDuplicateNames(Tmodel.rxnID) ;

%% Clear leftover fields from the matching process
deleteFields = {'rxnNamesFix' 'rxnComp' 'metNums' 'rxnMetNames'} ;
existFields = isfield(Tmodel, deleteFields) ;
for iF = 1:length(existFields)
    if existFields(iF)
        Tmodel = rmfield(Tmodel,deleteFields{iF}) ;
    end
end
