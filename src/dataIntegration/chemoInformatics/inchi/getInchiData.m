function inchiLayersDetail = getInchiData(inchi)
% Classify the inchi according to its various layers of information. All layers 
% and sub-layers (except for the chemical formula sub-layer of the Main layer) 
% start with /? where ? is a lower-case letter to indicate the type of information 
% held in that layer. 
% 
% USAGE:
%
%   inchiLayersDetail = getInchiData(inchi)
%
% INPUTS:
%    inchi:             String with the InChI to classify
%
% OUTPUTS:
%    detailLevelInchi:  Struct file with the following fields:
%
%       * .layers              - Number of layers in the InChI.
%       * .mainLayer           - Number of layers in the InChI.
%       * .standart            - Logical, indicates whether the inchi is 
%                                standard or not.
%       * .metFormula          - The molecula formula.
%       * .netCharge           - Summ of the charges.
%       * .stereochemicalLayer - Logical, indicates whether the inchi   
%                                represent stereochemical information or not.
%       * .isotopicLayer       - Logical, indicates whether the inchi represent 
%                                isotopic information or not.

inchiSplited = split(inchi, '/');

% Count inchi layers
inchiLayersDetail.layers = numel(inchiSplited);

% Check if it is a standard InChI 
assert(contains(inchiSplited{1}, 'InChI='), [inchi ' is not an InChI'])
if contains(inchiSplited{1}, '1S')
    inchiLayersDetail.standard = true;
else
    inchiLayersDetail.standard = false;
end
    
% Chemical formula 
if isempty(regexp(inchiSplited{2}(1), '[a-z]')) % ignore protons; they don't have formula
    inchiLayersDetail.metFormula = inchiSplited{2};
elseif isequal(inchiSplited{2}, 'p+1')
    inchiLayersDetail.metFormula = 'H';
else
    inchiLayersDetail.metFormula = [];
end

% Main layer
mainLayer = [inchiSplited{1} '/' inchiLayersDetail.metFormula];
if length(inchiSplited) > 3 && ismember(inchiSplited{3}(1), {'c', 'h'}) 
    mainLayer = [mainLayer  '/' inchiSplited{3}];
end
if length(inchiSplited) >= 4 && ismember(inchiSplited{4}(1), 'h') 
    mainLayer = [mainLayer '/' inchiSplited{4}];
end
inchiLayersDetail.mainLayer = mainLayer;
    
% Charge layer
pLayer = contains(inchiSplited, 'p');
if any(pLayer)
    protons = str2double(regexprep(inchiSplited{pLayer}, 'p|;', ''));
else
    protons = 0;
end
qLayer = contains(inchiSplited, 'q');
if any(qLayer)
    charge = str2double(regexprep(inchiSplited{qLayer}, 'q\+|;', ''));
else
    charge = 0;
end
inchiLayersDetail.netCharge = charge + protons;

% Stereochemical layer
stereochemicalLayerBool = ~cellfun(@isempty, regexp(inchiSplited, 'b|t|m|s'));
if any(stereochemicalLayerBool)
    inchiLayersDetail.stereochemicalSubLayers = sum(stereochemicalLayerBool);
else
    inchiLayersDetail.stereochemicalSubLayers = 0;
end

% Isotopic layer
isotopicLayerBool = ~cellfun(@isempty, regexp(inchiSplited, 'i'));
if any(isotopicLayerBool)
    inchiLayersDetail.isotopicLayer = true;
else
    inchiLayersDetail.isotopicLayer = 0;
end

end