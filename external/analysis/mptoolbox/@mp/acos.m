function out=acos(x)

precision=x(1).precision;
mpPi=mppi(precision);
out=mpPi/2+i.*log(i*x+sqrt(1-x.^2));

%%%precision=x(1).precision;
%%%out=mp(zeros(size(x)));
%%%
%%%mpPi=mppi(precision);
%%%for ii=1:numel(x)
%%% out(ii)=mpPi/2+i*log(i*x(ii)+sqrt(1-x(ii)^2));
%%%end % for ii=1:max(ex,

