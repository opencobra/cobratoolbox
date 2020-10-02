function in=triu(in)

precision=in(1).precision;
for ii=1:size(in,2)
 if ii+1<=size(in,1)
  in(ii+1:end,ii)=mp(0,precision);
 end
end