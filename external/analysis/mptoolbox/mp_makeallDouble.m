% converts all mp objects to double variables
% put variable names as cell strings into mp_dontmakeallDouble if you 
% don't want them converted
%  e.g. mp_dontmakeallDouble={'C1','C2'};
%  if you don't want C1 and C2 converted to doubles

tempVarList=whos;

if exist('default_precision')~=1
 default_precision=mp_Defaults(mp(0));
end
for tempLoopVar=1:length(tempVarList)
 if strcmp(tempVarList(tempLoopVar).class,'mp')
  tempGoon=1;
  if exist('mp_dontmakeallDouble')
   if any(strcmp(tempVarList(tempLoopVar).name,mp_dontmakeallDouble))
    tempGoon=0;
   end
  end
  if tempGoon
   if ~strcmp(tempVarList(tempLoopVar).name,'default_precision')
    eval([tempVarList(tempLoopVar).name,'=double(',tempVarList(tempLoopVar).name,');']);
   end
  end
 end
end

clear tempVarList tempLoopVar tempGoon