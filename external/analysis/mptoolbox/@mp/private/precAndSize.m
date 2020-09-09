if isa(x,'mp')
 precision=x(1).precision;
 if ~isa(y,'mp')
  y=mp(y,precision);
 end
else
 precision=y(1).precision;
 if ~isa(x,'mp')
  x=mp(x,precision);
 end 
end

sx=size(x);  sy=size(y);
ex=prod(sx); ey=prod(sy);
if ~all(sx==sy)
 if ~(length(x)==1|length(y)==1)
  disp(['size of matrix 1 => ',num2str(sx(1)),'x',num2str(sx(2))]);
  disp(['size of matrix 2 => ',num2str(sy(1)),'x',num2str(sy(2))]);
  error(['Size mismatch for mp objects']);
 end
end

if ex>=ey
 out_rval=cell(sx);
 out_ival=out_rval;
 outn=zeros(sx);
else
 out_rval=cell(sy);
 out_ival=out_rval;
 outn=zeros(sy);
end

