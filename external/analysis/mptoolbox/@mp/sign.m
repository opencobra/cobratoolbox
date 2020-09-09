function out=sign(x)

precision=x(1).precision;
out_rval=cell(size(x));
out_ival=cell(size(x));

for ii=1:numel(x)
 imag=false;
 [xrval,xival]=getVals(x,ii);

 out_rval{ii}=mpfr_absc(precision,xrval,xival);
 
 [out_rval{ii},out_ival{ii}]=mpfr_divc(precision,xrval,xival,out_rval{ii},mpExpForm('0',0));
 
end % for ii=1:max(ex,
out=class(struct('rval',out_rval,...
                  'ival',out_ival,...
                  'precision',precision),'mp');
