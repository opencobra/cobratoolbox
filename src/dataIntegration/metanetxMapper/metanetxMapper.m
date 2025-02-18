function [metData] = metanetxMapper(metInfo, varargin)
% This function maps metabolite IDs to each other using Beta MetaNetX database 
%
% USAGE:
%
%    [metData] = metanetxMapper(metInfo, infoType)
%
% INPUTS:
%    metInfo:     string information of the metabolite (Common name, VMH name, CHEBI id,
%    Swiss Lipid id, HMDB id, Lipidmap, or InChIkey are supported)
%
%
% OPTIONAL INPUT:
%    infoType: In the cases of searching with common name, VMH, or ChEBI, use 'name', 'vmh',
%    or 'chebi' respectively as the identifier type for more accurate respond
%
% OUTPUT:
%    metData: A structure variable including fields of metabolite Identifiers: 
%           -metName:            Common Name
%           -metMetaNetXID:      MetaNetX ID
%           -metVMHID:           VMH Symbol
%           -metCheBIID:         ChEBI ID
%           -metHMDBID:          HMDB ID
%           -metKEGGID:          KEGG ID
%           -metBiGGID:          BIGG ID
%           -metSwissLipidsID:   Swiss Lipids ID(only for lipids)
%           -metInChIString:     InChI String
%           -metInChIkey:        InChI key
%           -metSmiles:          SMILES ID
%
% EXAMPLE:
%     >>  metData = metanetxMapper('SLM:000390086')
%         metData = 
% 
%         struct with fields:
%              
%                    metName: "O-3-methylbutanoyl-(R)-carnitine"
%                    metMetaNetXID: "MNXM1101229"
%                    metVMHID: "ivcrn"
%                    metCheBIID: "70819"
%                    metHMDBID: "HMDB0000688"
%                    metKEGGID: "C20826"
%                    metBiGGID: "ivcrn"
%                    metSwissLipidsID: "SLM:000390086"
%                    metInChIString: "InChI=1S/C12H23NO4/c1-9(2)6-12(16)17-10(7-11(14)15)8-13(3,4)5/h9-10H,6-8H2,1-5H3/t10-/m1/s1"
%                    metInChIkey: "IGQBPDJNUXPEMT-SNVBAGLBSA-N"
%                    metSmiles: "[CH3:1][CH:9]([CH3:2])[CH2:6][C:12](=[O:16])[O:17][C@H:10]([CH2:7][C:11](=[O:14])[O-:15])[CH2:8][N+:13]([CH3:3])([CH3:4])[CH3:5]"
%
%    >>  metData = metanetxMapper('glu_L', 'VMH')
%        metData =
%
%        struct with fields:
%
%                    metName: "L-glutamate"
%                    metMetaNetXID: "MNXM741173"
%                    metVMHID: "glu_L"
%                    metCheBIID: "16015"
%                    metHMDBID: "HMDB0000148"
%                    metKEGGID: "C00025"
%                    metBiGGID: "glu__L"
%                    metSwissLipidsID: ""
%                    metInChIString: "InChI=1S/C5H9NO4/c6-3(5(9)10)1-2-4(7)8/h3H,1-2,6H2,(H,7,8)(H,9,10)/p-1/t3-/m0/s1"
%                    metInChIkey: "WHUUTDBJXJRKMK-VKHMYHEASA-M"
%                    metSmiles: "[CH2:1]([CH2:2][C:4](=[O:7])[OH:8])[C@@H:3]([C:5](=[O:9])[OH:10])[NH2:6]"
%
% NOTE:
%    In the case of more than one matches for the metabolite, this
%    functions returns the first match
%    This function adds "+" sign at the begining of the metabolites name to
%    find the exact match in MetaNetX website
%
% .. Author:
%           - Farid Zare, 7/12/2024
%
global response
% Change the format to char if it is a cell or string
if ~ischar(metInfo)
    metInfo = char(metInfo);
end

% Input is an ID by default
nameFlag = 0;
if nargin > 1 && ~isempty(metInfo)
    % Assuming varargin{1} is the second input argument
    switch lower(varargin{1})
        case 'name'
            nameFlag = 1;
        case 'vmh'
            metInfo = ['vmhM:', metInfo];
        case 'chebi'
            metInfo = ['CHEBI:', metInfo];
        otherwise
            error('Unrecognized input type of data. Input data type should be either "name" or "id"');
    end
end

% Inorder to get the exact ID, "+" is added to the beggining of the name
% metabolite
if ~isempty(metInfo)
    if metInfo(1) ~= '+'
        metInfo = strcat('+', metInfo);
    end
end

% For names its better to use MetaNetX search and for IDs we use id-mapper
% feature of MetaNetX website
if nameFlag
    % For names its better to use MetaNetX search
    url = 'https://beta.metanetx.org/cgi-bin/mnxweb/search';
    params = {'format', 'json', 'db', 'chem', 'query', metInfo};
else
    % For IDs we use id-mapper feature of MetaNetX
    url = 'https://beta.metanetx.org/cgi-bin/mnxweb/id-mapper';
    params = {'query_index', 'chem', 'output_format', 'JSON', 'query_list', metInfo};
end

% Define output as a struct
metData = struct('metName', "", 'metMetaNetXID', "", 'metVMHID', "", 'metCheBIID',...
    "", 'metHMDBID', "", 'metKEGGID', "", 'metBiGGID', "", 'metSwissLipidsID', "",...
    'metInChIString', "", 'metInChIkey', "", 'metSmiles', "");

% Make the request using webread and respond an empty response to empty
% names
if ~isempty(metInfo)
    response = webread(url, params{:});
else
    response = '';
end

if nameFlag
    if ~isempty(response) 

        % For cases using MetaNetX name search in the cases of more than 1 result
        % the first result is counted
        if numel(response) > 1
            response = response{1};
        end
        % Get the second respond using the retrieved metanetx id and search
        % that on ID-mapper
        metInfo = response.mnx_id;
        % For IDs we use id-mapper feature of MetaNetX
        url = 'https://beta.metanetx.org/cgi-bin/mnxweb/id-mapper';
        params = {'query_index', 'chem', 'output_format', 'JSON', 'query_list', metInfo};
        % Make the request using webread
        response = webread(url, params{:});

    end
end

if ~isempty(response) 

    % Getting the subfield in the struct field
    fields = fieldnames(response);
    response = response.(fields{1});

    if ~isempty(fieldnames(response))

        % Assign metanetx and name
        metData.metMetaNetXID = string(response.mnx_id);
        metData.metName = string(response.name);

        % Assign InChIkey 
        if isfield(response, 'InChIkey')
            InChIkey = response.InChIkey;
            InChIkey = string(InChIkey);
            metData.metInChIkey = InChIkey;
        end

        % Assign InChI String
        if isfield(response, 'InChI')
            InChI = response.InChI;
            InChI = string(InChI);
            metData.metInChIString = InChI;
        end

        % Assign Smiles
        if isfield(response, 'SMILES')
            SMILES = response.SMILES;
            SMILES = string(SMILES);
            metData.metSmiles = SMILES;
        end

        xref = response.xrefs;

        % Assign Chebi ID
        chebiID = find(contains(lower(xref), 'chebi'));
        if ~isempty(chebiID)
            % First ID is the real ID others might be similar mets
            chebi = xref(chebiID(1));
            chebi = string(chebi);
            chebi = strsplit(chebi, ':');
            metData.metCheBIID = string(chebi{2});
        end

        % Assign hmdb ID
        hmdbID = find(contains(lower(xref), 'hmdb'));
        if ~isempty(hmdbID)
            % First ID is the real ID others might be similar mets
            hmdb = xref(hmdbID(1));
            hmdb = string(hmdb);
            hmdb = strsplit(hmdb, ':');
            metData.metHMDBID = string(hmdb{2});
        end

        % Assign vmh ID
        vmhID = find(contains(lower(xref), 'vmhm'));
        if ~isempty(vmhID)
            % First ID is the real ID others might be similar mets
            vmh = xref(vmhID(1));
            vmh = string(vmh);
            vmh = strsplit(vmh, ':');
            metData.metVMHID = string(vmh{2});
        end

        % Assign swisslipids ID
        slmID = find(contains(lower(xref), 'slm'));
        if ~isempty(slmID)
            % First ID is the real ID others might be similar mets
            slm = xref(slmID(1));
            slm = string(slm);
            metData.metSwissLipidsID = slm;
        end

        % Assign KEGG ID
        keggID = find(contains(lower(xref), 'kegg.compound'));
        if ~isempty(keggID)
            % First ID is the real ID others might be similar mets
            kegg = xref(keggID(1));
            kegg = string(kegg);
            kegg = strsplit(kegg, ':');
            metData.metKEGGID = string(kegg{2});
        end

        % Assign BIGG ID
        biggID = find(contains(lower(xref), 'bigg.metabolite'));
        if ~isempty(biggID)
            % First ID is the real ID others might be similar mets
            bigg = xref(biggID(1));
            bigg = string(bigg);
            bigg = strsplit(bigg, ':');
            metData.metBiGGID = string(bigg{2});
        end


        % Replace the reference identifier

        ref = response.reference;
        % Assign Chebi ID
        chebiID = find(contains(lower(ref), 'chebi'));
        if ~isempty(chebiID)
            chebi = ref;
            chebi = string(chebi);
            chebi = strsplit(chebi, ':');
            metData.metCheBIID = string(chebi{2});
        end

        % Assign hmdb ID
        hmdbID = find(contains(lower(ref), 'hmdb'));
        if ~isempty(hmdbID)
            hmdb = ref;
            hmdb = string(hmdb);
            hmdb = strsplit(hmdb, ':');
            metData.metHMDBID = string(hmdb{2});
        end

        % Assign vmh ID
        vmhID = find(contains(lower(ref), 'vmhm'));
        if ~isempty(vmhID)
            vmh = ref;
            vmh = string(vmh);
            vmh = strsplit(vmh, ':');
            metData.metVMHID = string(vmh{2});
        end

        % Assign swisslipids ID
        slmID = find(contains(lower(ref), 'slm'));
        if ~isempty(slmID)
            slm = ref;
            slm = string(slm);
            metData.metSwissLipidsID = slm;
        end

        % Assign KEGG ID
        keggID = find(contains(lower(ref), 'kegg.compound'));
        if ~isempty(keggID)
            kegg = ref;
            kegg = string(kegg);
            kegg = strsplit(kegg, ':');
            metData.metKEGGID = string(kegg{2});
        end

        % Assign BIGG ID
        biggID = find(contains(lower(ref), 'bigg.metabolite'));
        if ~isempty(biggID)
            bigg = ref;
            bigg = string(bigg);
            bigg = strsplit(bigg, ':');
            metData.metBiGGID = string(bigg{2});
        end
    end
end
end
