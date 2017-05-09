function out=imag(x)

precision=x(1).precision;
out_rval=cell(size(x));
out_ival=cell(size(x));

for ii=1:numel(x)
 [temp,out_rval{ii}]=getVals(x,ii);
 out_ival{ii}='0';
end % for ii=1:max(ex,
out=class(struct('rval',out_rval,...
                 'ival',out_ival,...
                 'precision',precision),'mp');
