function out=acosh(x)


out=log(x+sqrt(x+1).*sqrt(x-1));

%%%precision=x(1).precision;
%%%out=mp(zeros(size(x)));
%%%
%%%mpPi=mppi(precision);
%%%for ii=1:numel(x)
%%% out(ii)=log(x(ii)+sqrt(x(ii)+1)*sqrt(x(ii)-1));
%%%end % for ii=1:max(ex,

