function in=tril(in)

precision=in(1).precision;
for ii=1:size(in,1)
 if ii+1<=size(in,2)
  in(ii,ii+1:end)=mp(0,precision);
 end
end