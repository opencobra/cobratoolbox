function out=real(x)

precision=x(1).precision;
out_rval=cell(size(x));
out_ival=cell(size(x));

for ii=1:numel(x)
 imag=false;
 [out_rval{ii},xival]=getVals(x,ii);
end % for ii=1:max(ex,
out=class(struct('rval',out_rval,...
                 'ival',out_ival,...
                 'precision',precision),'mp');
