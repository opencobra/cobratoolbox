%test autofragmentation using dGPredictor
inchi='InChI=1/C9H19NO2S2/c10-7-14-6-5-8(13)3-1-2-4-9(11)12/h8,13H,1-7,10H2,(H,11,12)/f/h11H'
inchi='InChI=1/C9H19NO2S2/c10-7-14-6-5-8(13)3-1-2-4-9(11)12/h8,13H,1-7,10H2,(H,11,12)/f/h11H'
inchi='InChI=1/C9H19NO2S2/c10-7-14-6-5-8(13)3-1-2-4-9(11)12/h8,13H,1-7,10H2,(H,11,12)/f/h11H';
inchi='InChI=1/C9H19NO2S2/c10-7-14-6-5-8(13)3-1-2-4-9(11)12/h8,13H,1-7,10H2,(H,11,12)/f/h11H';
radius=1;
dGPredictorPath='/home/rfleming/work/sbgCloud/code/dGPredictor';%must be absolute path to the dGPredictor github repo, i.e. no ~/
canonicalise=0;
cacheName=[];
debug=0;

[fragmentedMol2,decomposableBool,inchiExistBool] = autoFragment(inchi,radius,dGPredictorPath,canonicalise,cacheName,debug);


fragmentedMol.inchi='InChI=1/C9H19NO2S2/c10-7-14-6-5-8(13)3-1-2-4-9(11)12/h8,13H,1-7,10H2,(H,11,12)/f/h11H';
fragmentedMol.smilesCounts=containers.Map({'C=O','CC(=O)O','CC(C)S','CCC','CCS','CN','CO','CS','CSC','NCS'},{[1],[1],[1],[5],[1],[1],[1],[1],[1],[1]});


assert(isequal(fragmentedMol.smilesCounts.keys,fragmentedMol2.smilesCounts.keys))
assert(isequal(fragmentedMol.smilesCounts.values,fragmentedMol2.smilesCounts.values))


[fragmentedMol2,decomposableBool,inchiExistBool] = autoFragment({[]},radius,dGPredictorPath,canonicalise,cacheName,debug);