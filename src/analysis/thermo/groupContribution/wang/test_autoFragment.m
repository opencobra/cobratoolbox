%test autofragmentation using dGPredictor
inchi='InChI=1/C9H19NO2S2/c10-7-14-6-5-8(13)3-1-2-4-9(11)12/h8,13H,1-7,10H2,(H,11,12)/f/h11H';
radius=1;
dGPredictorPath='/home/rfleming/work/sbgCloud/code/dGPredictor';%must be absolute path to the dGPredictor github repo, i.e. no ~/
canonicalise=0;
cacheName=[];
debug=0;

fragmentedMol.inchi='InChI=1/C9H19NO2S2/c10-7-14-6-5-8(13)3-1-2-4-9(11)12/h8,13H,1-7,10H2,(H,11,12)/f/h11H';
fragmentedMol.smilesCounts=containers.Map({'C=O','CC(=O)O','CC(C)S','CCC','CCS','CN','CO','CS','CSC','NCS'},{[1],[1],[1],[5],[1],[1],[1],[1],[1],[1]});

[fragmentedMol2,decomposableBool,inchiExistBool] = autoFragment(inchi,radius,dGPredictorPath,canonicalise,cacheName,debug);

assert(isequal(fragmentedMol.smilesCounts.keys,fragmentedMol2.smilesCounts.keys))
assert(isequal(fragmentedMol.smilesCounts.values,fragmentedMol2.smilesCounts.values))

%%
[fragmentedMol2,decomposableBool,inchiExistBool] = autoFragment({[]},radius,dGPredictorPath,canonicalise,cacheName,debug);


%%
inchi='InChI=1S/H2O2/c1-2';
radius=1;
[fragmentedMol3,decomposableBool,inchiExistBool] = autoFragment(inchi,radius);
%disp([keys(fragmentedMol3.smilesCounts),values(fragmentedMol3.smilesCounts)])
assert(isequal(keys(fragmentedMol3.smilesCounts),{'O=O'}))
assert(isequal(values(fragmentedMol3.smilesCounts),{[2]}))

%%
radius=2;
[fragmentedMol4,decomposableBool,inchiExistBool] = autoFragment(inchi,radius);
%disp([keys(fragmentedMol4.smilesCounts),values(fragmentedMol4.smilesCounts)])
assert(isempty(keys(fragmentedMol4.smilesCounts)))
assert(isempty(values(fragmentedMol4.smilesCounts)))

%%
inchi='InChI=1S/H2O/h1H2';
radius=1;
[fragmentedMol5,decomposableBool,inchiExistBool] = autoFragment(inchi,radius);
%disp([keys(fragmentedMol5.smilesCounts),values(fragmentedMol5.smilesCounts)])
assert(isequal(keys(fragmentedMol5.smilesCounts),{'O'}))
assert(isequal(values(fragmentedMol5.smilesCounts),{[1]}))

%%
radius=2;
[fragmentedMol6,decomposableBool,inchiExistBool] = autoFragment(inchi,radius);
%disp([keys(fragmentedMol6.smilesCounts),values(fragmentedMol6.smilesCounts)])
assert(isempty(keys(fragmentedMol6.smilesCounts)))
assert(isempty(values(fragmentedMol6.smilesCounts)))