function out=mrdivide(x,y)

precisionx=0;   precisiony=0;
if isa(x,'mp')
 precisionx=x(1).precision;
end
if isa(y,'mp')
 precisiony=y(1).precision;
end
precision=max(precisionx,precisiony);
ex=numel(x);
ey=numel(y);

if ey==1
 out=x./y;
else
 error('full mrdivide hasn''t been written for mp objects yet')
end