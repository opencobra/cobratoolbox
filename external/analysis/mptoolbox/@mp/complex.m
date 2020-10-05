function out=complex(x,y);

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

out=x+y*complex(0,1);