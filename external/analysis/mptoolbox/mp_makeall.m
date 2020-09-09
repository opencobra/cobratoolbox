% converts all double variables to mp objects
% put variable names as cell strings into mp_dontmakeall if you don't want them converted
%  e.g. mp_dontmakeall={'C1','C2'};
%  if you don't want C1 and C2 converted to mp objects

tempVarList=whos;

if exist('default_precision')~=1
 default_precision=mp_Defaults(mp(0));
end
for tempLoopVar=1:length(tempVarList)
 if strcmp(tempVarList(tempLoopVar).class,'double')
  tempGoon=1;
  if exist('mp_dontmakeall')
   if any(strcmp(tempVarList(tempLoopVar).name,mp_dontmakeall))
    tempGoon=0;
   end
  end
  if tempGoon
   if ~strcmp(tempVarList(tempLoopVar).name,'default_precision')
    eval([tempVarList(tempLoopVar).name,'=mp(',tempVarList(tempLoopVar).name,...
          ',',num2str(default_precision),');']);
   end
  end
 end
end

clear tempVarList tempLoopVar tempGoon