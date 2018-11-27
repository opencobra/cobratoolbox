function s=exp2fit(t,f,caseval,lsq_val,options)

%  exp2fit solves the non-linear least squares problem exact
%  and using it as a start guess in a least square method 
%  in cases with noise, of the specific exponential functions:
%  --- caseval = 1 ----
%  f=s1+s2*exp(-t/s3)
%  
%  --- caseval = 2 (general case, two exponentials) ----
%  f=s1+s2*exp(-t/s3)+s4*exp(-t/s5)
%  
%  --- caseval = 3 ----
%  f=s1*(1-exp(-t/s2)) %i.e., constraints between s1 and s2
%  
%  Syntax: s=exp2fit(t,f,caseval) gives the parameters in the fitting
%  function specified by the choice of caseval (1,2,3).
%  t and f are (normally) vectors of the same size, containing
%  the data to be fitted.
%  s=exp2fit(t,f,caseval,lsq_val,options), using lsq_val='no' gives
%  the analytic solution, without least square approach (faster), where 
%  options (optional or []) are produced by optimset, as used in lsqcurvefit.
%
%  This algorithm is using analytic formulas using multiple integrals.
%  Integral estimations are used as start guess in lsqcurvefit.
%  Note: For infinite lengths of t, and f, without noise
%  the result is exact.
%
% %--- Example 1:
% t=linspace(1,4,100)*1e-9;
% noise=0.02;
% f=0.1+2*exp(-t/3e-9)+noise*randn(size(t));
% 
% %--- solve without startguess
% s=exp2fit(t,f,1)
%
% %--- plot and compare
% fun = @(s,t) s(1)+s(2)*exp(-t/s(3));
% tt=linspace(0,4*s(3),200);
% ff=fun(s,tt);
% figure(1), clf;plot(t,f,'.',tt,ff);
%
% %--- Example 2, Damped Harmonic oscillator:
% %--- Note: sin(x)=(exp(ix)-exp(-ix))/2i
% t=linspace(1,12,100)*1e-9;
% w=1e9;
% f=1+3*exp(-t/5e-9).*sin(w*(t-2e-9));
% 
% %--- solve without startguess
% s=exp2fit(t,f,2,'no')
%
% %--- plot and compare
% fun = @(s,t) s(1)+s(2)*exp(-t/s(3))+s(4)*exp(-t/s(5));
% tt=linspace(0,20,200)*1e-9;
% ff=fun(s,tt);
% figure(1), clf;plot(t,f,'.',tt,real(ff));
% %--- evaluate parameters:
% sprintf(['f=1+3*exp(-t/5e-9).*sin(w*(t-2e-9))\n',...
% 'Frequency: w_fitted=',num2str(-imag(1/s(3)),3),' w_data=',num2str(w,3),'\n',...
% 'Damping: tau=',num2str(1/real(1/s(3)),3),'\n',...
% 'Offset: s1=',num2str(real(s(1)),3)])
%
%%% By Per Sundqvist january 2009.

[t,ix]=sort(t(:));%convert to column vector and sort
f=f(:);f=f(ix);

if nargin<4
    lsq_val='yes';%default, use lsq-fitting
end
if nargin<5
    options=optimset('TolX',1e-6,'TolFun',1e-8);%default
end
if nargin>=5
    if isempty(options)
        options=optimset('TolX',1e-6,'TolFun',1e-8);
    end
end
if length(t)<3
    error(['WARNING!', ...
    'To few data to give correct estimation of parameters!']);
end

%calculate help-variables
T=max(t)-min(t);t2=max(t);
tt=linspace(min(t),max(t),200);
ff=pchip(t,f,tt);
n=1;I1=trapz(tt,ff.*(t2-tt).^(n-1))/factorial(n-1);
n=2;I2=trapz(tt,ff.*(t2-tt).^(n-1))/factorial(n-1);
n=3;I3=trapz(tt,ff.*(t2-tt).^(n-1))/factorial(n-1);
n=4;I4=trapz(tt,ff.*(t2-tt).^(n-1))/factorial(n-1);

if caseval==1
    %--- estimate tau, s1,s2
    %--- Case: f=s1+s2*exp(-t/tau)
    tau=(12*I4-6*I3*T+I2*T^2)/(-12*I3+6*I2*T-I1*T^2);
    Q1=exp(-min(t)/tau);
    Q=exp(-T/tau);
    s1=2.*T.^(-1).*((1+Q).*T+2.*((-1)+Q).*tau).^(-1).*(I2.*((-1)+Q)+I1.* ...
       (T+((-1)+Q).*tau));
    s2=(2.*I2+(-1).*I1.*T).*tau.^(-1).*((1+Q).*T+2.*((-1)+Q).*tau).^(-1);
    s2=s2/Q1;
    sf0=[s1 s2 tau];
    fun = @(s,t) (s(1)*sf0(1))+(s(2)*sf0(2))*exp(-t/(s(3)*sf0(3)));
    s0=[1 1 1];
elseif caseval==3
    %--- estimate tau, s1
    %--- Case: f=s1*(1-exp(-t/tau))
    tau=(12*I4-6*I3*T+I2*T^2)/(-12*I3+6*I2*T-I1*T^2);
    s1=6.*T.^(-3).*((-2).*I3+I2.*(T+(-2).*tau)+I1.*T.*tau);
    sf0=[s1 tau];
    fun = @(s,t) (s(1)*sf0(1))*(1-exp(-t/(s(2)*sf0(2))));
    s0=[1 1];
elseif caseval==2
    %
    T=max(t)-min(t);t2=max(t);
    tt=linspace(min(t),max(t),200);
    ff=pchip(t,f,tt);
    n=1;J(n)=trapz(tt,ff.*(t2-tt).^(n-1))/factorial(n-1)/T^n;
    n=2;J(n)=trapz(tt,ff.*(t2-tt).^(n-1))/factorial(n-1)/T^n;
    n=3;J(n)=trapz(tt,ff.*(t2-tt).^(n-1))/factorial(n-1)/T^n;
    n=4;J(n)=trapz(tt,ff.*(t2-tt).^(n-1))/factorial(n-1)/T^n;
    n=5;J(n)=trapz(tt,ff.*(t2-tt).^(n-1))/factorial(n-1)/T^n;
    n=6;J(n)=trapz(tt,ff.*(t2-tt).^(n-1))/factorial(n-1)/T^n;
    n=7;J(n)=trapz(tt,ff.*(t2-tt).^(n-1))/factorial(n-1)/T^n;

    %
    p(1)=(1/2).*(J(2).^2+(-1).*J(1).*(J(3)+(-15).*(J(4)+(-6).*J(5)+14.*J(6) ...
  ))+(-15).*J(2).*(J(3)+2.*(J(4)+(-25).*J(5)+84.*J(6)))+120.*(J(3) ...
  .^2+J(3).*((-8).*J(4)+(-9).*J(5)+105.*J(6))+15.*(2.*J(4).^2+14.*J( ...
  5).^2+(-7).*J(4).*(J(5)+2.*J(6))))).^(-1).*(J(1).*(J(4)+(-15).*(J( ...
  5)+(-6).*J(6)+14.*J(7)))+(-1).*J(2).*(J(3)+(-120).*(J(5)+(-8).*J( ...
  6)+21.*J(7)))+15.*(J(3).^2+(-2).*J(3).*(7.*J(4)+(-7).*J(5)+(-120) ...
  .*J(6)+420.*J(7))+8.*(8.*J(4).^2+105.*J(5).*(J(5)+(-2).*J(6))+J(4) ...
  .*((-51).*J(5)+210.*J(7))))+sqrt(4.*(J(2).^2+(-1).*J(1).*(J(3)+( ...
  -15).*(J(4)+(-6).*J(5)+14.*J(6)))+(-15).*J(2).*(J(3)+2.*(J(4)+( ...
  -25).*J(5)+84.*J(6)))+120.*(J(3).^2+J(3).*((-8).*J(4)+(-9).*J(5)+ ...
  105.*J(6))+15.*(2.*J(4).^2+14.*J(5).^2+(-7).*J(4).*(J(5)+2.*J(6))) ...
  )).*((-1).*J(3).^2+J(2).*(J(4)+(-15).*(J(5)+(-6).*J(6)+14.*J(7)))+ ...
  15.*J(3).*(J(4)+2.*(J(5)+(-25).*J(6)+84.*J(7)))+(-120).*(J(4).^2+ ...
  J(4).*((-8).*J(5)+(-9).*J(6)+105.*J(7))+15.*(2.*J(5).^2+14.*J(6) ...
  .^2+(-7).*J(5).*(J(6)+2.*J(7)))))+(J(1).*(J(4)+(-15).*(J(5)+(-6).* ...
  J(6)+14.*J(7)))+(-1).*J(2).*(J(3)+(-120).*(J(5)+(-8).*J(6)+21.*J( ...
  7)))+15.*(J(3).^2+(-2).*J(3).*(7.*J(4)+(-7).*J(5)+(-120).*J(6)+ ...
  420.*J(7))+8.*(8.*J(4).^2+105.*J(5).*(J(5)+(-2).*J(6))+J(4).*(( ...
  -51).*J(5)+210.*J(7))))).^2));
%
    p(2)=(-1/2).*(J(2).^2+(-1).*J(1).*(J(3)+(-15).*(J(4)+(-6).*J(5)+14.*J( ...
  6)))+(-15).*J(2).*(J(3)+2.*(J(4)+(-25).*J(5)+84.*J(6)))+120.*(J(3) ...
  .^2+J(3).*((-8).*J(4)+(-9).*J(5)+105.*J(6))+15.*(2.*J(4).^2+14.*J( ...
  5).^2+(-7).*J(4).*(J(5)+2.*J(6))))).^(-1).*((-1).*J(1).*(J(4)+( ...
  -15).*(J(5)+(-6).*J(6)+14.*J(7)))+J(2).*(J(3)+(-120).*(J(5)+(-8).* ...
  J(6)+21.*J(7)))+(-15).*(J(3).^2+(-2).*J(3).*(7.*J(4)+(-7).*J(5)+( ...
  -120).*J(6)+420.*J(7))+8.*(8.*J(4).^2+105.*J(5).*(J(5)+(-2).*J(6)) ...
  +J(4).*((-51).*J(5)+210.*J(7))))+sqrt(4.*(J(2).^2+(-1).*J(1).*(J( ...
  3)+(-15).*(J(4)+(-6).*J(5)+14.*J(6)))+(-15).*J(2).*(J(3)+2.*(J(4)+ ...
  (-25).*J(5)+84.*J(6)))+120.*(J(3).^2+J(3).*((-8).*J(4)+(-9).*J(5)+ ...
  105.*J(6))+15.*(2.*J(4).^2+14.*J(5).^2+(-7).*J(4).*(J(5)+2.*J(6))) ...
  )).*((-1).*J(3).^2+J(2).*(J(4)+(-15).*(J(5)+(-6).*J(6)+14.*J(7)))+ ...
  15.*J(3).*(J(4)+2.*(J(5)+(-25).*J(6)+84.*J(7)))+(-120).*(J(4).^2+ ...
  J(4).*((-8).*J(5)+(-9).*J(6)+105.*J(7))+15.*(2.*J(5).^2+14.*J(6) ...
  .^2+(-7).*J(5).*(J(6)+2.*J(7)))))+(J(1).*(J(4)+(-15).*(J(5)+(-6).* ...
  J(6)+14.*J(7)))+(-1).*J(2).*(J(3)+(-120).*(J(5)+(-8).*J(6)+21.*J( ...
  7)))+15.*(J(3).^2+(-2).*J(3).*(7.*J(4)+(-7).*J(5)+(-120).*J(6)+ ...
  420.*J(7))+8.*(8.*J(4).^2+105.*J(5).*(J(5)+(-2).*J(6))+J(4).*(( ...
  -51).*J(5)+210.*J(7))))).^2));
%
    s2=3.*p(1).^(-1).*(p(1)+(-1).*p(2)).^(-1).*((-1).*J(2).*p(1)+(-4).*( ...
  J(2).*p(1).^2.*(2+5.*p(1))+5.*J(5).*(1+6.*p(1).*(1+2.*p(1))))+(( ...
  -1).*J(1).*p(1).*(1+4.*p(1).*(2+5.*p(1)))+J(2).*((-1)+12.*p(1) ...
  .^2.*(3+10.*p(1)))).*p(2)+J(3).*((-1)+8.*p(2)+12.*p(1).*(p(1).*(3+ ...
  p(1).*(10+(-20).*p(2)))+3.*p(2)))+(-4).*J(4).*((-2)+5.*p(2)+3.*p( ...
  1).*((-3)+10.*p(2)+20.*p(1).*(p(1)+p(2)))));
%
    s3=3.*(p(1)+(-1).*p(2)).^(-1).*p(2).^(-1).*(J(3)+(-8).*J(4)+20.*J(5)+ ...
  J(2).*p(1)+(-8).*J(3).*p(1)+20.*J(4).*p(1)+(J(2)+(-36).*J(4)+120.* ...
  J(5)+(J(1)+(-36).*J(3)+120.*J(4)).*p(1)).*p(2)+(-4).*(9.*J(3)+( ...
  -60).*J(5)+(-2).*(J(1)+30.*J(4)).*p(1)+J(2).*((-2)+9.*p(1))).*p(2) ...
  .^2+20.*(J(2)+(-6).*J(3)+12.*J(4)+J(1).*p(1)+(-6).*(J(2)+(-2).*J( ...
  3)).*p(1)).*p(2).^3);
%
    s1=6.*((-1)+(-3).*p(2)+(-1).*p(1).*(3+6.*p(2))).^(-1).*((-1).*J(3)+( ...
  1/2).*((s3+2.*s3.*p(1)+(-2).*J(1).*p(1)).*p(2)+(-2).*J(2).*(p(1)+ ...
  p(2))+s2.*p(1).*(1+2.*p(2))));
%
    tau1=p(1)*T;
    tau2=p(2)*T;
    Q1=exp(-min(t)/tau1);
    Q2=exp(-min(t)/tau2);
    s2=s2/Q1;
    s3=s3/Q2;
    %
    sf0=[s1 s2 tau1 s3 tau2];
    fun = @(s,t) (s(1)*sf0(1))+...
                 (s(2)*sf0(2))*exp(-t/(s(3)*sf0(3)))+...
                 (s(4)*sf0(4))*exp(-t/(s(5)*sf0(5)));
    s0=[1 1 1 1 1];
end

%--- use lsqcurvefit if not lsq_val='no'
if isequal(lsq_val,'no')
    s=sf0;
else
    cond=1;
    while cond
        [s,RESNORM,RESIDUAL,EXIT]=lsqcurvefit(fun,s0,t,f,[],[],options);
        cond=not(not(EXIT==0));
        s0=s;
    end
    s=s0.*sf0;
end
