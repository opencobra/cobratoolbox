function model = createFragmentIncidenceMatrix(inchi,radius,dGPredictorPath,canonicalise)
% model.G:    k x g  fragment incidence matrix

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

