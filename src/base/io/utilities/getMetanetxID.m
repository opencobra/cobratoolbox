function metanetxID = getMetanetxID(name)
% This function converts metabolite names into MetaNetX metabolite IDs 
% using API
%
% USAGE:
%
%    [metanetxID] = metaNetXID(name)
%
% INPUTS:
%    name:     string name of the metabolite (Common names, VMH names, CHEBI ids,
%    swiss lipids id, HMDB ids, and lipidmaps are supported) 
%
% OUTPUT:
%    metanetxID:    MetaNetX metabolite IDs of the metabolite
%
%
% EXAMPLE:
%
%    >>  metanetxID = getMetanetxID('10dacb')
%        metanetxID =
%       'MNXM1702'
%
% NOTE:
%    In the case of more than one matches for the metabolite, this
%    functions returns the first match
%    If input value "name" only contains numbers, the functions recognizes 
%    it as chebi numbers and searchs for "chebi: + name"
%
% .. Author: - Farid Zare, 7/12/2024
%

apiURL = 'https://beta.metanetx.org/cgi-bin/mnxweb/search';

%Check if input is just numbers
name0 = str2double(name);
if ~isnan(name0)
    name = strcat('chebi: ', name);
end

% Set up parameters for the search
params = struct('format', 'json', 'db', 'chem', 'query', name);

% Construct the URL with manually encoded parameters
encodedParams = cellfun(@(k, v) [urlencode(k), '=', urlencode(v)], fieldnames(params), struct2cell(params), 'UniformOutput', false);
queryString = strjoin(encodedParams, '&');
url = [apiURL '?' queryString];

% Make the request using webread
response = webread(url);

if isempty(response)
    % Assign NaN if there was not any match for the metabolite
    metanetxID = nan;

elseif numel(response) > 1
    % If there are more than one matched IDs take the first one
    metanetxID = response{1}.mnx_id;

else
    metanetxID = response.mnx_id;
end
end
