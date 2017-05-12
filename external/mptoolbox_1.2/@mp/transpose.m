function out=transpose(x)

precision=x(1).precision;
out_rval=cell(fliplr(size(x)));
out_ival=cell(fliplr(size(x)));

xs=size(x);
foo=1;
for jj=1:xs(2)
 for ii=1:xs(1)
  [out_rval{jj,ii},out_ival{jj,ii}]=getVals(x,foo);
  foo=foo+1;
 end
end
out=class(struct('rval',out_rval,...
                 'ival',out_ival,...
                 'precision',precision),'mp');
