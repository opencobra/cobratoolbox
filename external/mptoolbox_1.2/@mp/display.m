function display(x)
% mp/display Command window display of multiple precision objects

s=size(x);
ans=cell(s);
for ii=1:numel(x)
 [rval,ival]=getVals(x,ii);
 if isempty(rval)
  rval='0';
 end
%%% if isempty(rexp)
%%%  rexp='0';
%%% end
 if ~(strncmp(rval,'-',1) | strncmp(rval,'+',1))
  rval=['+',rval];
 end
 if ~isempty(ival)
  if ~(strncmp(ival,'-',1) | strncmp(ival,'+',1))
   ival=['+',ival];
  end
 end
 if isempty(ival)
  ans{ii}=rval;
 else
  ans{ii}=[rval,ival,'i'];
%%%  if strncmp(ival,'-',1) | strncmp(ival,'+',1)
%%%   ans{ii}=[temp,ival,'i'];
%%%  else
%%%   ans{ii}=[temp,'+',ival,'i'];
%%%  end
 end % if isreal(x(i,
end

if ~strcmp('ans',inputname(1))
%%% display([inputname(1),'=']);
 disp([inputname(1),'=']);
end

if any(cellfun('length',ans)>78)
 celldisp(ans,inputname(1))
else
 display(ans)
end
