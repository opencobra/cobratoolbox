function model = createFragmentIncidenceMatrix(inchi, radius, dGPredictorPath, canonicalise)
% Build a fragment incidence matrix by automatically fragmenting each InChI and
% mapping metabolites to the consolidated set of SMILES fragments
%
% USAGE:
%
%    model = createFragmentIncidenceMatrix(inchi, radius, dGPredictorPath, canonicalise)
%
% INPUT:
%    inchi:            `k x 1` cell array of InChI strings (one per metabolite)
%
% OPTIONAL INPUTS:
%    radius:           number of bonds around each central SMILES atom (default 1)
%    dGPredictorPath:    full absolute path (without ~/) to a git clone of dGPredictor
%    canonicalise:       boolean, consolidate duplicate canonical SMILES fragments
%
% OUTPUT:
%    model:            structure with fields:
%
%                        * .inchi - the input `k x 1` cell array of InChI strings
%                        * .frag - `g x 1` cell array of unique SMILES fragments
%                        * .G - `k x g` fragment incidence matrix

if ~exist('radius','var')
    radius=1;
end

%fragment each of the inchi
fragmentedMol = autoFragment(inchi,radius);
[fragmentedMol,decomposableBool] = autoFragment(inchi,radius,dGPredictorPath,canonicalise);

nMols=length(fragmentedMol);

%concatentate the maps into a consolidated map where the fragments are unique
fragmentsMap = containers.Map('KeyType','char','ValueType','double');
for i = 1:nMols
    fragmentsMap = [fragmentsMap;fragmentedMol(i).smilesCounts];
end
nFrag=length(fragmentsMap);

model.inchi = inchi;
model.frag = keys(fragmentsMap)';

%preallocate the fragment incidence matrix
model.G = sparse(nMols,nFrag);

%iterate through each fragmented inchi
%map each of the fragments to the consolidated list of fragments
keySet = keys(fragmentsMap);
for i = 1:nMols
    bool = isKey(fragmentedMol(i).smilesCounts,keySet);
    model.G(i,bool)=cell2mat(values(fragmentedMol(i).smilesCounts));
end

