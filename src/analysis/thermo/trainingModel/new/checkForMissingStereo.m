function missingStereo = checkForMissingStereo(model, trainingModel)
% USAGE:
%
%    missingStereo = checkForMissingStereo(model, trainingModel)
%
% INPUTS:
%    model:    structure with fields:
%
%                * .mets
%                * .inchi.standard
%                * .inchi.standardWithStereo
%
%    trainingModel:     structure with fields:
%
%                *.inchi.standard
%                *.inchi.standardWithStereo
%
% OUTPUTS:
%    missingStereo:

nistStdBool = false(length(trainingModel.inchi.standard));
for n = 1:length(trainingModel.inchi.standard)
   if ~isempty(trainingModel.inchi.standard{n})
       if ~any(nistStdBool(:,n))
           nistStdBool(n,n) = true;
           nistStdBool(n,strcmp(trainingModel.inchi.standard{n},trainingModel.inchi.standard)) = true;
       end
   end
end

nistStdStereoBool = false(length(trainingModel.inchi.standardWithStereo));
for n = 1:length(trainingModel.inchi.standardWithStereo)
   if ~isempty(trainingModel.inchi.standardWithStereo{n})
       if ~any(nistStdStereoBool(:,n))
           nistStdStereoBool(n,n) = true;
           nistStdStereoBool(n,strcmp(trainingModel.inchi.standardWithStereo{n},trainingModel.inchi.standardWithStereo)) = true;
       end
   end
end

nistStdStereoBool(diag(true(size(nistStdStereoBool,1),1))) = false;
nistBool = nistStdBool & ~nistStdStereoBool;
nistBool = nistBool(sum(nistBool,2)>1,:);

nistStdInchi = trainingModel.inchi.standard(any(nistBool));
modelStdInchi = model.inchi.standard;
modelStdInchi(cellfun(@isempty,modelStdInchi)) = {'N/A'};

modelStdInchiStereo = model.inchi.standardWithStereo(ismember(modelStdInchi,nistStdInchi));
modelMets = model.mets(ismember(modelStdInchi,nistStdInchi));
modelMets = regexprep(modelMets,'\[\w\]','');
[modelMets,crossi] = unique(modelMets);
modelStdInchiStereo = modelStdInchiStereo(crossi);
missingStereo = modelMets(cellfun('isempty',regexp(modelStdInchiStereo,'[tms]')));

end
