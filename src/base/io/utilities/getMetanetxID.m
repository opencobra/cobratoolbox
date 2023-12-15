function [metanetxID] = getMetanetxID(name, varargin)
% This function converts metabolite names into MetaNetX metabolite IDs
% using API
%
% USAGE:
%
%    [metanetxID] = getMetanetxID(name, outputType)
%
% INPUTS:
%    name:     string name of the metabolite (Common names, VMH names, CHEBI ids,
%    swiss lipids id, HMDB ids, and lipidmaps are supported)
%
% OPTIONAL INPUT:
%    outputType:    This function can output name of the
%    metabolite or its MetaNetx ID, for getting name of
%    the metabolite use 'name' string as the second input and for MentaNetX
%    ID use 'metanetx' string as the second input.
%    The default input of the function is 'metanetx'
%
% OUTPUT:
%    metanetxID:    MetaNetX metabolite IDs of the metabolite
%
% EXAMPLE:
%
%    >>  metanetxID = getMetanetxID('10dacb')
%        metanetxID =
%       'MNXM1702'
%    >>  metanetxID = getMetanetxID('10dacb', 'name')
%        metanetxID =
%       '10-deacetylbaccatin III'
%
% NOTE:
%    In the case of more than one matches for the metabolite, this
%    functions returns the first match
%    If input value "name" only contains numbers, the functions recognizes
%    it as chebi numbers and searchs for "chebi: + name"
%
% .. Author: - Farid Zare, 7/12/2024
%

if nargin > 1
    outputStyle = lower(varargin{1});
elseif nargin == 1
    outputStyle = 'metanetx';
end

% Inorder to get the exact ID, "+" is added to the beggining of the name
% metabolite
name = strcat('+', name);

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

if numel(response) > 1
    response = response{1};
end

if isempty(response)
    % Assign NaN if there was not any match for the metabolite
    metanetxID = nan;
else
    if strcmp(outputStyle, 'name')
        metanetxID = response.desc;
    elseif strcmp(outputStyle, 'metanetx')
        metanetxID = response.mnx_id;
    else
        error('Invalid type of requested output')
    end

end
end
