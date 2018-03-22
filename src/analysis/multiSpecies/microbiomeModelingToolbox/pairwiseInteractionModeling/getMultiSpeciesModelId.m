function [names, ids] = getMultiSpeciesModelId(modelJoint, nameTagsModels, nameTagHost, metTagRe, rxnTagRe, compCom, compHost)
% Get names and IDs for metabolites and exchange reactions in the [u] and [b] space
%
% USAGE:
%
%    [names, ids] = getMultiSpeciesModelId(modelJoint, nameTagsModels, nameTagHost, metTagRe, rxnTagRe, compCom, compHost)
%
% INPUTS:
%    modelJoint:       COBRA multi-organism model
%    nameTagsModels:   cell array of tags for species to identify the respective
%                      reactions and metabolites from `modelJoint.rxns` and `.mets`
%
% OPTIONAL INPUTS:
%    nameTagHost:      string of tag for the host model if exist. Input [] if no host is present
%    metTagRe:         a regular expression to identify the tag in nameTagsModels from `modelJoint.mets`.
%                      Use '%s' for the tag in `nameTagsModels` for each species.
%                      Default '^%s', the beginning of the string. In this case, if the tag for species 1 is
%                      'SP1', then mets with id 'SP1glc-D[e]' will be identified as belonging to species 1.
%                      E.g., 'met[compartment_SP1]' where 'SP1' is the tag for species 1, input '\[[^_]+_%s\]$'.
%    rxnTagRe:         a regular expression to idenify the tag in `nameTagsModels` from `modelJoint.rxns`.
%                      Default '^%s', the beginning of the string
%    compCom:          compartment Id for the community exchange compartment. Default 'u'
%    compHost:         compartment Id for the exchange compartment specific to the host. Default 'b'
%
% OUTPUTS:
%    names:            structure of reaction/metabolite name (.rxns/.mets) with the following fields:
%
%                        * spAbbr - species abbreviation (= `nameTags`). Host put at the end
%                        * EXcom - #met[u]-by-1 cell. Exchange reactions for community metabolites `met[u]`
%                        * EXhost - #met[b]-by-1 cell. Exchange reactions for host-specific exchange metabolites `met[b]`
%                        * EXsp - #met[u]-by-#species cell. `EXsp(i,j)` is the species-community exchange reactions
%                          for the i-th met[u] and the j-th species
%                        * Mcom - #met[u]-by-1 cell. All community metabolites `met[u]`
%                        * Mhost - #met[u]-by-1 cell. Host-specific exchange metabolites `met[b]`
%                        * Msp - #met[u]-by-#species cell. `Msp(i,j)` is the metabolite in `met[e]` of the `j`-th species
%                          participating in reaction `EXsp(i,j)`
%                        * rxnSps - #rxns-by-1 cell. `rxnSps(i)` would be `spAbbr(j)` if the `i`-th reaction belongs to the `j`-th species
%                        * metSps - #mets-by-1 cell. `metSps(i)` would be `spAbbr(j)` if the i-th metabolite belongs to the `j`-th species
%
%    ids:              structure of reaction/metabolite index with the same fields as names except without `spAbbr`

if nargin < 7 || isempty(compHost)
    compHost = 'b';
end
if nargin < 6 || isempty(compCom)
    compCom = 'u';
end
compHost = regexprep(compHost, '^\[(.*)\]$', '$1');
compCom = regexprep(compCom, '^\[(.*)\]$', '$1');
% regular expression for identifying species
if nargin < 5 || isempty(rxnTagRe)
    rxnTagRe = '^%s';
end
if nargin < 4 || isempty(metTagRe)
    metTagRe = '^%s';
end
metCompartment = getCompartment(modelJoint.mets);
% mets in the common exchange space ([u]) or the biomass (use biomass[c] to be consistent with createMultipleSpeciesModel)
metCom = strcmp(metCompartment, compCom) | strcmp(modelJoint.mets, 'biomass[c]');
% mets in exchange space accessible only by the host ([b])
metHost = strcmp(metCompartment, compHost);
hostExist = any(metHost) && nargin >= 3 && ~isempty(nameTagHost);   % use && to avoid error if nameTagHost not given
if hostExist && iscell(nameTagHost)
    nameTagHost = nameTagHost{1};
end
if ischar(nameTagsModels)
    nameTagsModels = {nameTagsModels};
end
% get the regular expression of identifiers for species-specific mets and rxns
nSp = numel(nameTagsModels);
[metTagReSp, rxnTagReSp] = deal(repmat({''}, nSp + hostExist, 1));
for jSp = 1:nSp
    metTagReSp{jSp} = strrep(metTagRe, '%s', nameTagsModels{jSp});
    rxnTagReSp{jSp} = strrep(rxnTagRe, '%s', nameTagsModels{jSp});
end
metHost = find(metHost);
if hostExist
    % add regular expression for host
    metTagReSp{nSp + 1} = strrep(metTagRe, '%s', nameTagHost);
    rxnTagReSp{nSp + 1} = strrep(rxnTagRe, '%s', nameTagHost);
    % try to sort metHost to have the same order as metCom by comparing met names
    metHostName = regexprep(modelJoint.mets(metHost), metTagReSp{nSp + 1}, '');
    metHostName = strrep(metHostName, ['[' compHost ']'], '');
    metComName = strrep(modelJoint.mets(metCom), ['[' compCom ']'], '');
    [yn, id] = ismember(metComName, metHostName);
    if all(yn) && numel(union(metComName, metHostName)) == numel(metComName)
        % one-to-one mapping exists. Reorder
        metHost = metHost(id);
    end
end

% get system exchange rxns
rxnEX = find(sum(modelJoint.S ~= 0, 1) == 1);
% exchange rxns for mets in [u], in the same order as metCom
[EXcom, ~] = find(modelJoint.S(metCom, rxnEX)');
EXcom = rxnEX(EXcom);
% exchange rxns for mets in [b], in the same order as metHost
[EXhost, ~] = find(modelJoint.S(metHost, rxnEX)');
EXhost = rxnEX(EXhost);

% Get the species number for each met and rxn. 0 for those in [u]
[nMets, nRxns] = size(modelJoint.S);
metSps = zeros(nMets, 1);
rxnSps = zeros(nRxns, 1);
for jSp = 1:nSp
    metSps(~cellfun(@isempty, regexp(modelJoint.mets, metTagReSp{jSp}, 'once')) & ~metCom) = jSp;
    rxnSps(~cellfun(@isempty, regexp(modelJoint.rxns, rxnTagReSp{jSp}, 'once'))) = jSp;
    %     metSps(strncmp(modelJoint.mets, nameTagsModels{j}, numel(nameTagsModels{j})) & ~metCom) = j;
    %     rxnSps(strncmp(modelJoint.rxns, nameTagsModels{j}, numel(nameTagsModels{j}))) = j;
    rxnSps(EXcom) = 0;  % in case some mets or exchange rxns in [u] have prefix equal to the name tags
    % check if the model is properly compartmentalized.
    if nnz(modelJoint.S(metSps == jSp, rxnSps ~= jSp)) > 0 ...
            || nnz(modelJoint.S(metSps ~= jSp & metSps > 0, rxnSps == jSp)) > 0
        error('The model for species %s is not correctly compartmentalized. Check the name tags.');
    end
end
if hostExist
    metSps(~cellfun(@isempty, regexp(modelJoint.mets, metTagReSp{nSp + 1}, 'once')) & ~metCom) = nSp + 1;
    rxnSps(~cellfun(@isempty, regexp(modelJoint.rxns, rxnTagReSp{nSp + 1}, 'once'))) = nSp + 1;
    %     metSps(strncmp(modelJoint.mets, nameTagHost, numel(nameTagHost))) = nSp + 1;
    %     rxnSps(strncmp(modelJoint.rxns, nameTagHost, numel(nameTagHost))) = nSp + 1;
end

% species-community exchange rxns (between members' [e] and [u])
EXeu = any(modelJoint.S(metCom, :), 1);
EXeu(EXcom) = false;  % exclude system input/output exchange rxns
EXeu = find(EXeu);
% EXsp is a #met[u] x #species matrix with (i,j)-entry being the index for exchange reactionn
% for the i-th met in [u] between [u] and [e] of the j-th organism.
% Msp similar but the index for the exchanged metabolite in [e] of the organism
[EXsp, Msp] = deal(zeros(sum(metCom), nSp + hostExist));
for j = 1:numel(EXeu)
    mJcom = find(modelJoint.S(:, EXeu(j)) ~= 0 & metCom);  % met in [u]
    mJsp = find(modelJoint.S(:, EXeu(j)) ~= 0 & ~metCom);  % met in [e]
    EXsp(sum(metCom(1:mJcom)), rxnSps(EXeu(j))) = EXeu(j);
    Msp(sum(metCom(1:mJcom)), rxnSps(EXeu(j))) = mJsp;
end
% store all rxns/mets and their ids
names.spAbbr = nameTagsModels(:);  % species abbreviation
if hostExist
    names.spAbbr = [names.spAbbr; {nameTagHost}];
end
names.spName = names.spAbbr;
names.EXcom = modelJoint.rxns(EXcom);
ids.EXcom = EXcom(:);
names.EXhost = modelJoint.rxns(EXhost);
ids.EXhost = EXhost(:);
names.EXsp = repmat({''}, size(EXsp, 1), size(EXsp, 2));
names.EXsp(EXsp ~= 0) = modelJoint.rxns(EXsp(EXsp ~= 0));
ids.EXsp = EXsp;
names.Mcom = modelJoint.mets(metCom);
ids.Mcom = find(metCom);
names.Mhost = modelJoint.mets(metHost);
ids.Mhost = metHost;
names.Msp = repmat({''}, size(EXsp, 1), size(EXsp, 2));
names.Msp(Msp ~= 0) = modelJoint.mets(Msp(Msp ~= 0));
ids.Msp = Msp;
names.rxnSps = cell(nRxns, 1);
names.rxnSps(rxnSps > 0) = names.spAbbr(rxnSps(rxnSps > 0));
names.rxnSps(rxnSps == 0) = {'com'};
ids.rxnSps = rxnSps;
names.metSps = cell(nMets, 1);
names.metSps(metSps > 0) = names.spAbbr(metSps(metSps > 0));
names.metSps(metSps == 0) = {'com'};
ids.metSps = metSps;
