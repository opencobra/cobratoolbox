function [metabolite_structure] = searchUnknownMetOnline(met,VMHId,metabolite_structure_rBioNet,metab_rBioNet_online,rxn_rBioNet_online)
% This function searches HMDB by names and returns a metabolite structure
% and the HMDB ID if the name appear in the common name, IUPAC, synonyms,
% or traditional name.
%
% INPUT
% met                   metabolite name (try to spell it correctly)
%
% OUTPUT
% metabolite_structure  metabolite structure
%
%
% Ines Thiele, 09/2021

if ~exist('metabolite_structure_rBioNet','var')
    load met_strc_rBioNet;
end
if ~exist('metab_rBioNet_online','var') ||  ~exist('rxn_rBioNet_online','var')
    load('data/rxn.mat');
    load('data/metab.mat');
    metab_rBioNet_online = metab;
    rxn_rBioNet_online = rxn;
end

% generate abbr
if ~exist('VMHId','var')
    % previously I encoded to generate random VMH numbers
    % [VMHnum] = generateRandomVMHnum;
    %abbr = [VMHnum];
    % we will now generate de novo VMH Id's based on defined
    % rules
    [VMHId] = generateVMHMetAbbr(met,metabolite_structure_rBioNet,metab_rBioNet_online,rxn_rBioNet_online);
end

populate = 'true';
molFileDirectory = 'molFiles';
% search metabolite online

hmdb = retrievePotHitsHMDB(met);
if ~isempty(hmdb)
    % get further inchiString, mol file, charged formula for new
    % metabolite
    % I still need an abbr
    metInput={
        'VMH ID' 'metabolite_name' 'HMDB' };
    metInput = [metInput; {VMHId met hmdb}];
    source = 'metabolite searched in HMDB by name';
    populate = 'true';
    molFileDirectory = 'molFiles';
    [metabolite_structure_tmp] = createNewMetEntryFromArray(metInput,source,populate,molFileDirectory,metab_rBioNet_online,rxn_rBioNet_online,metabolite_structure_rBioNet);
    if exist('metabolite_structure','var') && ~isempty(metabolite_structure)
        metabolite_structure = catstruct(metabolite_structure,metabolite_structure_tmp);
    else
        metabolite_structure = metabolite_structure_tmp;
    end
end

% no hit found - try alternative spellings
altSpell = {
    ' ',''
    ' ','-'
    ' (\d+)','-$1'
    'oxy'   'oxi'
    'oxi'   'oxy'
    };
metOri = met;
for i = 1 : size(altSpell)
    if ~exist('metabolite_structure','var')|| isempty(metabolite_structure)
        % no hit
        % try an alternate spelling
        met = metOri;
        met = regexprep(met,altSpell{i,1},altSpell{i,2}); % replace spaces
        
        % retrieve hit if present
        hmdb =retrievePotHitsHMDB(met);
        if ~isempty(hmdb)
            % get further inchiString, mol file, charged formula for new
            % metabolite
            % I still need an abbr
            metInput={
                'VMH ID' 'metabolite_name' 'HMDB' };
            metInput = [metInput; {VMHId met hmdb}];
            source = 'metabolite searched in HMDB by name';
            [metabolite_structure_tmp] = createNewMetEntryFromArray(metInput,source,populate,molFileDirectory,metab_rBioNet_online,rxn_rBioNet_online,metabolite_structure_rBioNet);
            if exist('metabolite_structure','var') && ~isempty(metabolite_structure)
                metabolite_structure = catstruct(metabolite_structure,metabolite_structure_tmp);
            else
                metabolite_structure = metabolite_structure_tmp;
            end
        end
    end
end

% if no hit could be found on HMDB, create nevertheless a structure with
% the compound
if ~exist('metabolite_structure','var')
    metInput={
        'VMH ID' 'metabolite_name' 'HMDB' };
    metInput = [metInput; {VMHId met NaN}];
    source = 'Manual entry';
    [metabolite_structure] = createNewMetEntryFromArray(metInput,source,populate,molFileDirectory,metab_rBioNet_online,rxn_rBioNet_online,metabolite_structure_rBioNet);
    
end

