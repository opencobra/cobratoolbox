function out=ctranspose(x)


out=conj(transpose(x));

%%%x=conj(x);
%%%precision=x(1).precision;
%%%out_rval=cell(fliplr(size(x)));
%%%out_ival=cell(fliplr(size(x)));
%%%
%%%xs=size(x)
%%%foo=1;
%%%for jj=1:xs(2)
%%% for ii=1:xs(1)
%%%  [xrval,xrexp,xival,xiexp]=getVals(x,foo);
%%%  out_rval{jj,ii}=xrval;
%%%  out_rexp{jj,ii}=xrexp;
%%%  out_ival{jj,ii}=xival;
%%%  out_iexp{jj,ii}=xiexp;
%%%  foo=foo+1;
%%% end
%%%end
%%%out=class(struct('rval',out_rval,...
%%%                 'rexp',out_rexp,...
%%%                 'ival',out_ival,...
%%%                 'iexp',out_iexp,...
%%%                 'precision',precision),'mp');
