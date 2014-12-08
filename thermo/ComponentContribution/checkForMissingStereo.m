function missingStereo = checkForMissingStereo(model, nist)

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
