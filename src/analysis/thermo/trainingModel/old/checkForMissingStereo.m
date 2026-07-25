function missingStereo = checkForMissingStereo(model, nist)
% Identify model metabolites whose stereochemistry is missing relative to the NIST data
%
% Compares standard InChI without stereochemistry against standard InChI with
% stereochemistry for the NIST training data, then returns the model metabolite
% abbreviations that match a NIST compound but lack stereochemical detail.
%
% USAGE:
%
%    missingStereo = checkForMissingStereo(model, nist)
%
% INPUTS:
%    model:            COBRA model structure. Fields used:
%
%                        * .mets - metabolite abbreviations
%                        * .inchi.standard - standard InChI without stereochemistry
%                        * .inchi.standardWithStereo - standard InChI with stereochemistry
%
%    nist:             NIST training-data structure. Fields used:
%
%                        * .std_inchi - standard InChI without stereochemistry
%                        * .std_inchi_stereo - standard InChI with stereochemistry
%
% OUTPUTS:
%    missingStereo:    cell array of model metabolite abbreviations present in
%                      the NIST data but lacking stereochemistry

nistStdBool = false(length(nist.std_inchi));
for n = 1:length(nist.std_inchi)
   if ~isempty(nist.std_inchi{n})
       if ~any(nistStdBool(:,n))
           nistStdBool(n,n) = true;
           nistStdBool(n,strcmp(nist.std_inchi{n},nist.std_inchi)) = true;
       end
   end
end

nistStdStereoBool = false(length(nist.std_inchi_stereo));
for n = 1:length(nist.std_inchi_stereo)
   if ~isempty(nist.std_inchi_stereo{n})
       if ~any(nistStdStereoBool(:,n))
           nistStdStereoBool(n,n) = true;
           nistStdStereoBool(n,strcmp(nist.std_inchi_stereo{n},nist.std_inchi_stereo)) = true;
       end
   end
end

nistStdStereoBool(diag(true(size(nistStdStereoBool,1),1))) = false;
nistBool = nistStdBool & ~nistStdStereoBool;
nistBool = nistBool(sum(nistBool,2)>1,:);

nistStdInchi = nist.std_inchi(any(nistBool));
modelStdInchi = model.inchi.standard;
modelStdInchi(cellfun(@isempty,modelStdInchi)) = {'N/A'};

modelStdInchiStereo = model.inchi.standardWithStereo(ismember(modelStdInchi,nistStdInchi));
modelMets = model.mets(ismember(modelStdInchi,nistStdInchi));
modelMets = regexprep(modelMets,'\[\w\]','');
[modelMets,crossi] = unique(modelMets);
modelStdInchiStereo = modelStdInchiStereo(crossi);
missingStereo = modelMets(cellfun('isempty',regexp(modelStdInchiStereo,'[tms]')));

end
