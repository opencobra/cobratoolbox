function inchiLayersDetail = getInchiData(inchi)
% Classify the inchi according to its various layers of information
% 
% USAGE:
%
% detailLevelInchi = inchiDetail(inchi)
%
% INPUTS:
%    inchi:             String with the InChI to classify
%
% OUTPUTS:
%    detailLevelInchi:  Struct file with the following fields:
%
%                       * .layers - Number of layers in the InChI.
%                       * .standart - Logical, indicates whether the inchi 
%                                     is standard or not.
%                       * .metFormulas - The molecula formula.
%                       * .positiveCharges - Number of positive charges.
%                       * .negativeCharges - Number of negative charges.
%                       * .netCharge - Summ of the charges.
%                       * .stereochemicalLayer - Logical, indicates whether 
%                                                the inchi  represent 
%                                                stereochemical information
%                                                or not.
%                       * .isotopicLayer - Logical, indicates whether the 
%                                          inchi represent isotopic 
%                                          information or not.

inchiSplited = split(inchi, '/');

% Check inchi layers
inchiLayersDetail.layers = numel(inchiSplited);

% Check if it is a standard inchi 
assert(contains(inchiSplited{1}, 'InChI='), [inchi ' is not an InChI'])
if contains(inchiSplited{1}, '1S')
    inchiLayersDetail.standart = true;
else
    inchiLayersDetail.standart = false;
end
    
% Chemical formula 
inchiLayersDetail.metFormulas = inchiSplited{2};

% Charge layer
pLayer = contains(inchiSplited, 'p');
if any(pLayer)
    inchiLayersDetail.positiveCharges = str2double(regexprep(inchiSplited{pLayer}, 'p-|;', ''));
else
    inchiLayersDetail.positiveCharges = 0;
end
qLayer = contains(inchiSplited, 'q');
if any(qLayer)
    inchiLayersDetail.negativeCharges = str2double(regexprep(inchiSplited{qLayer}, 'q\+|;', ''));
else
    inchiLayersDetail.negativeCharges = 0;
end
inchiLayersDetail.netCharge = inchiLayersDetail.positiveCharges - inchiLayersDetail.negativeCharges;

% Stereochemical layer
if any(~cellfun(@isempty, regexp(inchiSplited, 'b|t|m|s')))
    inchiLayersDetail.stereochemicalLayer = true;
end

% Isotopic layer
if any(~cellfun(@isempty, regexp(inchiSplited, 'i|h')))
    inchiLayersDetail.isotopicLayer = true;
end

end