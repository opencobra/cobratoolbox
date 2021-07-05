function [dGf0, dHf0, mf, aveHbound, aveZi, lambda, gpfnsp] = calcdGHT(dGzero, dHzero, zi, nH, pHr, is, temp, chi, Legendre, LegendreCHI, printLevel)
% Calculates the standard transformed Gibbs energy of a reactant
%
% Reproduces the function of T (in Kelvin), pHa (electrode pH), and ionic strength (is) that
% gives the standard transformed Gibbs energy of formation of a reactant
% (sum of species) and the standard transformed enthalpy of a reactant.
%
% Assuming p pseudoisomer species corresponding to one reactant
%
% Optional output dependent on multiple precision toolbox
%
% USAGE:
%
%    [dGf0, dHf0, mf, aveHbound, aveZi, lambda, gpfnsp] = calcdGHT(dGzero, dHzero, zi, nH, pHr, is, temp, chi, Legendre, LegendreCHI, printLevel)
%
% INPUTS:
%    dGzero:         `p x 1` standard Gibbs energy of formation at 298.15 K
%    zi:             `p x 1` electric charge
%    nH:             `p x 1` number of hydrogen atoms in each species
%    pHr:            real pH of 5 to 9 (see realpH.m)
%    is:             ionic strength 0 to 0.35 M
%    temp:           temperature 273.15 K to 313.15 K
%
% OPTIONAL INPUT:
%    dHzero:         `p x 1` standard enthalpy of formation at 298.15 K
%    chi:            electrical potential
%    Legendre:       {(1), 0} Legendre Transformation for specifc pHr?
%    LegendreCHI:    {(1), 0} Legendre Transformation for specifc electrical potential?
%
% OUTPUT:
%    dGf0:           reactant standard transformed Gibbs energy of formation
%    dHf0:           reactant standard transformed enthalpy of formation
%    mf:             mole fraction of each species within a pseudoisomer group
%    aveHbound:      average number of protons bound to a reactant
%    aveZi:          average charge of a reactant
%    lambda:         activity coefficient for each metabolite species
%    gpfnsp:         metabolite species standard transformed Gibbs energy of formation
%
% OPTIONAL OUTPUT:
%
%    dHf0:           standard transformed enthalpy of formation
%
% The values of the standard transformed Gibbs energy of formation
% and the standard transformed enthalpy of formation can be calculated
% temperature in the range 273.15 K to 313.15 K, using the van't Hoff equation.
% `pHr` in the range 5 to 9 (these correspond to the pH range of the species in Alberty's tables)
% ionic strength in the range 0 to 0.35 M.
% See Mathematica program `calcdGHT p289 Alberty 2003`
%
% The changes in the values of standard transformed Gibbs energy of formation
% and the standard transformed enthalpy of formation might be improved if
% knowlegde of standard molar heat capacity was available for each species
% See `p41 Alberty 2003`
%
% Multiple Precision Toolbox for MATLAB by Ben Barrowes (mptoolbox_1.1)
% http://www.mathworks.com/matlabcentral/fileexchange/6446
%
% .. Author: -Ronan M.T. Fleming

if ~exist('printLevel','var')
    printLevel=0;
end

electricalTerm = 0; % initialize electricalTerm

if pHr<5 || pHr>9
    if 0
        error('pHr out of applicable range, 5 - 9.');
    else
        warning('pHr out of applicable range, 5 - 9.');
    end
end
if temp<273.15 || temp>313.15
    error('temperature out of applicable range, 273.15 - 313.15');
end
if is<0 || is>0.35
    error('ionic strength out of applicable range, 0 - 0.35');
end

if ~exist('Legendre','var')
    Legendre=1;
end
if ~exist('LegendreCHI','var')
    LegendreCHI=1;
end

%check if multiple precision toolbox is properly installed
if strcmp(which('mp'),'') || 1 %TODO install
    if printLevel>0
        fprintf('%s\n','No multiple precision toolbox: NaN returned if exp(x) gets too large');
    end
    R=8.31451;
    %Energies are expressed in kJ mol^-1.*)
    R=R/1000;
    %standard temperature with a capital T
    T=298.15;

    %Faraday Constant (kJ/mol)
    F=96.48; %kJ/mol

    p=9.20483;
    q=10^3;
    r=1.284668;
    s=10^5;
    u=4.95199;
    v=10^8;
    % Eq. 3.7-3 p48 Alberty 2003
    % Around 298.15K
    % alpha = 1.10708 - 1.54508*temp/(10^3) +5.95584*temp^2/(10^6)
    % Eq. 3.7-4 p49 Alberty 2003
    % R*T*alpha, where alpha is the temperature dependent coeffficient, sometimes A,
    % in the extended Debye-Huckel equation
    gibbscoeff = (9.20483*temp)/10^3 - (1.284668*temp^2)/10^5 + (4.95199*temp^3)/10^8;


    %If standard enthalpy of formation is known, and independent of
    %temperature an adjustment for temperature can be made.
    %(calcdGHT p289 Alberty 2003)
    if isempty(dHzero)
        %dGzeroT = (dGzero*temp)/T + dHzero*(1 - temp/T);
        dGzeroT = dGzero;%(dGzero*temp)/T + dHzero*(1 - temp/T);
    else
        % van't Hoff equation
        dGzeroT = (dGzero*temp)/T + dHzero*(1 - temp/T);
    end

    %pHr
    if Legendre
        %Eq. 4.4-9/10 p67 Alberty 2003
        %note the use of culture temperature
        pHterm = nH*R*temp*log(10^-pHr);
        %Eq 4.4-10 Alberty 2003 with temp dependent gibbscoeff
        istermG = (gibbscoeff*(zi.^2 - nH)*is^0.5)/(1 + 1.6*is^0.5);
    else
        %no Legendre transformation for pHr
        pHterm = 0;
        %Eq 3.6-3 Alberty 2003 with temp dependent gibbscoeff
        istermG = (gibbscoeff*(zi.^2)*is^0.5)/(1 + 1.6*is^0.5); %omit the -nH if  no Legendre
    end

    if LegendreCHI
        if 0
            %By convention, we assume the chemical potential of a metabolite
            %includes an electrical potential term
            % u = u0 + RT*log(activity) + F*zi*chi;
            %The Legendre transformation for electrical potential is
            % u' = u -  F*zi*chi = u0 + RT*log(activity);
            %So the following line will negate the effect of an electrical
            %potential ONLY if it has previously been added.
            electricalTerm=-(F*(chi/1000))*zi;
            %eq 8.5-1 p148 Alberty 2003
        else
            %Imaginary Legendre Transformation for Electrical Potential, to
            %take account of the fact that we have not previously added an
            %electrical potential term to the standard Gibbs energy.
            electricalTerm=0;
            %The charge and change in chemical potential for multiphase
            %reactions is taken into account in
            %deltaG0concFluxConstraintBounds.m
        end
    end

    %standard transformed Gibbs energy of each species
    gpfnsp = dGzeroT - pHterm - istermG - electricalTerm;

    %isomer group thermodynamic standard transformed Gibbs energy of
    %formation for a reactant with more than one metabolite species
    if length(dGzero)==1
        dGf0=gpfnsp;
    else
        %need to approximate log(sum(exp(-gpfnsp/(R*temp))));
        dGf0 = -R*temp*maxstar(-gpfnsp/(R*temp));
    end

    %Mole fraction
    %see 3.5-12 p45 Alberty 2003
    mf=exp((dGf0-gpfnsp)/(R*temp));
%     fprintf('%s\n','Cannot calculate mole fractions without multiple
%     precision toolbox');

    %activity coefficient
    lambda=double(exp(-(gibbscoeff*(zi.^2)*is^0.5)/(1 + 1.6*is^0.5)/(R*temp)));

    %average number of H+ ions bound by a reactant
    aveHbound=mf'*nH;

    %average charge of a reactant
    aveZi=mf'*zi;
%     fprintf('%s\n',int2str(length(dGzero)));

    %isomer group thermodynamic standard transformed Enthalpy of
    %formation for a reactant
    %%%%%%% makes script faster to leave this out for now.
    dHzero=[];
    if ~isempty(dHzero)
        %make temperature a smaller variable
        t=temp;
        switch length(dGzero)
            case 1
                %corresponds to Simplify[-(t^2*D[dGf0/t, t])] in Albertys code for
                %one species reactant
                %see Mathematica file dHfn.nb
                A=dGzero(1);
                B=dHzero(1);
                C=zi(1);
                D=nH(1);
                dHf0 =(B*(1+1.6*is^0.5)*s*v + (C^2)*(is^0.5)*(t^2)*(2*s*t*u-r*v)+D*(is^0.5)*(t^2)*(-2*s*t*u+r*v)) / ((1+1.6*is^0.5)*s*v);

                if isnan(dHf0)
                    error('No multiple precision toolbox: NaN returned if exp(x) gets too large')
                end
            case 2
                %see Mathematica file dHfn.nb
                A=dGzero(1);
                B=dHzero(1);
                C=zi(1);
                D=nH(1);
                a=dGzero(2);
                b=dHzero(2);
                c=zi(2);
                d=nH(2);
                %translated to matlab from mathematica by hand
                dHf0 =((10^-pHr)^d*exp(-(b*((1/t)-(1/T))+a/T-(((c^2-d)*is^0.5*(p*s*v+q*t*(s*t*u-r*v)))/((1+1.6*is^0.5)*q*s*v)))/R)*(b*(1+1.6*is^0.5)*s*v+...
                    c^2*is^0.5*t^2*(2*s*t*u-r*v)+d*is^0.5*t^2*(-2*s*t*u+r*v))+...
                    (10^-pHr)^D*exp(-(B*((1/t)-(1/T))+A/T-(((C^2-D)*is^0.5*(p*s*v+q*t*(s*t*u-r*v)))/((1+1.6*is^0.5)*q*s*v)))/R)*(B*(1+1.6*is^0.5)*s*v+...
                    C^2*is^0.5*t^2*(2*s*t*u-r*v)+D*is^0.5*t^2*(-2*s*t*u+r*v)))/...
                    (((10^-pHr)^d*exp((b*((-1/t)+(1/T))-a/T+(((c^2-d)*is^0.5*(p*s*v+q*t*(s*t*u-r*v)))/((1+1.6*is^0.5)*q*s*v)))/R)+...
                    (10^-pHr)^D*exp((B*((-1/t)+(1/T))-A/T+(((C^2-D)*is^0.5*(p*s*v+q*t*(s*t*u-r*v)))/((1+1.6*is^0.5)*q*s*v)))/R))*(1+1.6*is^0.5)*s*v);
                %         Mathematica Expression to Matlab m-file Converter by Harri Ojanen, Rutgers University
                %         dHfn2=((10.^((-1).*pHr)).^d.*exp(R.^(-1).*(b.*((-1).*t.^(-1)+T.^(-1))+(-1).*a.* ...
                %             T.^(-1)+0.1E1.*(c.^2+(-0.1E1).*d).*(0.1E1+0.16E1.*is.^0.5E0).^(-1).* ...
                %             is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.*v+q.*t.*(s.*t.*u+(-0.1E1).* ...
                %             r.*v))))+(10.^((-1).*pHr)).^D.*exp(R.^(-1).*(B.*((-1).*t.^(-1)+T.^(-1))+( ...
                %             -1).*A.*T.^(-1)+0.1E1.*(C.^2+(-0.1E1).*D).*(0.1E1+0.16E1.*is.^0.5E0).^( ...
                %             -1).*is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.*v+q.*t.*(s.*t.*u+( ...
                %             -0.1E1).*r.*v))))).^(-1).*(0.1E1+0.16E1.*is.^0.5E0).^(-1).*s.^(-1).*v.^( ...
                %             -1).*((10.^((-1).*pHr)).^d.*exp((-1).*R.^(-1).*(b.*(t.^(-1)+(-1).*T.^(-1) ...
                %             )+a.*T.^(-1)+(-0.1E1).*(c.^2+(-0.1E1).*d).*(0.1E1+0.16E1.*is.^0.5E0).^( ...
                %             -1).*is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.*v+q.*t.*(s.*t.*u+( ...
                %             -0.1E1).*r.*v)))).*(b.*(1+0.16E1.*is.^0.5E0).*s.*v+c.^2.*is.^0.5E0.* ...
                %             t.^2.*(0.2E1.*s.*t.*u+(-0.1E1).*r.*v)+d.*is.^0.5E0.*t.^2.*((-0.2E1).*s.* ...
                %             t.*u+r.*v))+(10.^((-1).*pHr)).^D.*exp((-1).*R.^(-1).*(B.*(t.^(-1)+(-1).* ...
                %             T.^(-1))+A.*T.^(-1)+(-0.1E1).*(C.^2+(-0.1E1).*D).*(0.1E1+0.16E1.* ...
                %             is.^0.5E0).^(-1).*is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.*v+q.*t.*( ...
                %             s.*t.*u+(-0.1E1).*r.*v)))).*(B.*(1+0.16E1.*is.^0.5E0).*s.*v+C.^2.* ...
                %             is.^0.5E0.*t.^2.*(0.2E1.*s.*t.*u+(-0.1E1).*r.*v)+D.*is.^0.5E0.*t.^2.*(( ...
                %             -0.2E1).*s.*t.*u+r.*v)));

                if isnan(dHf0)
                    %see Mathematica file dHfn.nb
                    error('No multiple precision toolbox: NaN returned if exp(x) gets too large')
                end
            case 3

                A=dGzero(1);
                B=dHzero(1);
                C=zi(1);
                D=nH(1);
                a=dGzero(2);
                b=dHzero(2);
                c=zi(2);
                d=nH(2);
                e=dGzero(3);
                f=dHzero(3);
                g=zi(3);
                h=nH(3);
                %see Mathematica file dHfn.nb
                %Mathematica Expression to Matlab m-file Converter by Harri Ojanen, Rutgers University
                dHf0 = ((10.^((-1).*pHr)).^d.*exp(R.^(-1).*(b.*((-1).*t.^(-1)+T.^(-1))+(-1).*a.* ...
                    T.^(-1)+0.1E1.*(c.^2+(-0.1E1).*d).*(0.1E1+0.16E1.*is.^0.5E0).^(-1).* ...
                    is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.*v+q.*t.*(s.*t.*u+(-0.1E1).* ...
                    r.*v))))+(10.^((-1).*pHr)).^D.*exp(R.^(-1).*(B.*((-1).*t.^(-1)+T.^(-1))+( ...
                    -1).*A.*T.^(-1)+0.1E1.*(C.^2+(-0.1E1).*D).*(0.1E1+0.16E1.*is.^0.5E0).^( ...
                    -1).*is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.*v+q.*t.*(s.*t.*u+( ...
                    -0.1E1).*r.*v))))+(10.^((-1).*pHr)).^h.*exp(R.^(-1).*(f.*((-1).*t.^(-1)+ ...
                    T.^(-1))+(-1).*e.*T.^(-1)+0.1E1.*(g.^2+(-0.1E1).*h).*(0.1E1+0.16E1.* ...
                    is.^0.5E0).^(-1).*is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.*v+q.*t.*( ...
                    s.*t.*u+(-0.1E1).*r.*v))))).^(-1).*(0.1E1+0.16E1.*is.^0.5E0).^(-1).*s.^( ...
                    -1).*v.^(-1).*((10.^((-1).*pHr)).^d.*exp((-1).*R.^(-1).*(b.*(t.^(-1)+(-1) ...
                    .*T.^(-1))+a.*T.^(-1)+(-0.1E1).*(c.^2+(-0.1E1).*d).*(0.1E1+0.16E1.* ...
                    is.^0.5E0).^(-1).*is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.*v+q.*t.*( ...
                    s.*t.*u+(-0.1E1).*r.*v)))).*(b.*(1+0.16E1.*is.^0.5E0).*s.*v+c.^2.* ...
                    is.^0.5E0.*t.^2.*(0.2E1.*s.*t.*u+(-0.1E1).*r.*v)+d.*is.^0.5E0.*t.^2.*(( ...
                    -0.2E1).*s.*t.*u+r.*v))+(10.^((-1).*pHr)).^D.*exp((-1).*R.^(-1).*(B.*( ...
                    t.^(-1)+(-1).*T.^(-1))+A.*T.^(-1)+(-0.1E1).*(C.^2+(-0.1E1).*D).*(0.1E1+ ...
                    0.16E1.*is.^0.5E0).^(-1).*is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.* ...
                    v+q.*t.*(s.*t.*u+(-0.1E1).*r.*v)))).*(B.*(1+0.16E1.*is.^0.5E0).*s.*v+ ...
                    C.^2.*is.^0.5E0.*t.^2.*(0.2E1.*s.*t.*u+(-0.1E1).*r.*v)+D.*is.^0.5E0.* ...
                    t.^2.*((-0.2E1).*s.*t.*u+r.*v))+(10.^((-1).*pHr)).^h.*exp((-1).*R.^(-1).* ...
                    (f.*(t.^(-1)+(-1).*T.^(-1))+e.*T.^(-1)+(-0.1E1).*(g.^2+(-0.1E1).*h).*( ...
                    0.1E1+0.16E1.*is.^0.5E0).^(-1).*is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*( ...
                    p.*s.*v+q.*t.*(s.*t.*u+(-0.1E1).*r.*v)))).*(f.*(1+0.16E1.*is.^0.5E0).* ...
                    s.*v+g.^2.*is.^0.5E0.*t.^2.*(0.2E1.*s.*t.*u+(-0.1E1).*r.*v)+h.* ...
                    is.^0.5E0.*t.^2.*((-0.2E1).*s.*t.*u+r.*v)));

                %       dHf0 = ((10.^((-1).*pHr)).^d.*...
                %             exp(R.^(-1).*(b.*((-1).*t.^(-1)+T.^(-1))+(-1).*a.* ...
                %             T.^(-1)+0.1E1.*(c.^2+(-0.1E1).*d).*(1+1.6*is.^0.5).^(-1).* ...
                %             is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.*v+q.*t.*(s.*t.*u+(-0.1E1).* ...
                %             r.*v))))...
                %             +(10.^((-1).*pHr)).^D.*...
                %             exp(R.^(-1).*(B.*((-1).*t.^(-1)+T.^(-1))+( ...
                %             -1).*A.*T.^(-1)+0.1E1.*(C.^2+(-0.1E1).*D).*(1+1.6*is.^0.5).^( ...
                %             -1).*is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.*v+q.*t.*(s.*t.*u+( ...
                %             -0.1E1).*r.*v))))...
                %             +(10.^((-1).*pHr)).^h.*...
                %             exp(R.^(-1).*(f.*((-1).*t.^(-1)+ ...
                %             T.^(-1))+(-1).*e.*T.^(-1)+0.1E1.*(g.^2+(-0.1E1).*h).*(0.1E1+0.16E1.* ...
                %             is.^0.5E0).^(-1).*is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.*v+q.*t.*( ...
                %             s.*t.*u+(-0.1E1).*r.*v))))...
                %             ).^(-1).*(1+1.6*is.^0.5).^(-1).*s.^(-1).*v.^(-1).*...%%% end of denominator
                %             ((10.^((-1).*pHr)).^d.*...
                %             exp((-1).*R.^(-1).*(b.*(t.^(-1)+(-1) ...
                %             .*T.^(-1))+a.*T.^(-1)+(-0.1E1).*(c.^2+(-0.1E1).*d).*(0.1E1+0.16E1.* ...
                %             is.^0.5E0).^(-1).*is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.*v+q.*t.*( ...
                %             s.*t.*u+(-0.1E1).*r.*v))))...
                %             .*(b*(1+1.6*is^0.5)*s*v...
                %             +c^2*is.^0.5*t^2*(2.*s.*t.*u-r*v)+d.*is.^0.5*t^2*(-2*s*t*u+r*v))...
                %             +(10.^((-1).*pHr)).^D.*...
                %             exp((-1).*R.^(-1).*(B.*( ...
                %             t.^(-1)+(-1).*T.^(-1))+A.*T.^(-1)+(-0.1E1).*(C.^2+(-0.1E1).*D).*(0.1E1+ ...
                %             0.16E1.*is.^0.5E0).^(-1).*is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.* ...
                %             v+q.*t.*(s.*t.*u+(-0.1E1).*r.*v))))...
                %             .*(B.*(1+1.6*is.^0.5).*s.*v+ ...
                %             C.^2*is^0.5*t^2*(2*s*t*u-r*v)+D*is.^0.5*t^2*(-2*s*t*u+r*v))...
                %             +(10.^(-pHr)).^h.*...
                %             exp((-1).*R.^(-1).* ...
                %             (f.*(t.^(-1)+(-1).*T.^(-1))+e.*T.^(-1)+(-0.1E1).*(g.^2+(-0.1E1).*h).*( ...
                %             1+1.6*is.^0.5).^(-1).*is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*( ...
                %             p.*s.*v+q.*t.*(s.*t.*u+(-0.1E1).*r.*v))))...
                %             *(f*(1+1.6*is.^0.5)*s*v+g^2*is^0.5*t.^2*(2*s*t*u-r*v)+h*is^0.5*t^2*(-2*s*t*u+r*v)));
                %
                %             denominatorInv = ((10.^((-1).*pHr)).^d.*...
                %             exp(R.^(-1).*(b.*((-1).*t.^(-1)+T.^(-1))+(-1).*a.* ...
                %             T.^(-1)+0.1E1.*(c.^2+(-0.1E1).*d).*(1+1.6*is.^0.5).^(-1).* ...
                %             is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.*v+q.*t.*(s.*t.*u+(-0.1E1).* ...
                %             r.*v))))...
                %             +(10.^((-1).*pHr)).^D.*...
                %             exp(R.^(-1).*(B.*((-1).*t.^(-1)+T.^(-1))+( ...
                %             -1).*A.*T.^(-1)+0.1E1.*(C.^2+(-0.1E1).*D).*(1+1.6*is.^0.5).^( ...
                %             -1).*is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.*v+q.*t.*(s.*t.*u+( ...
                %             -0.1E1).*r.*v))))...
                %             +(10.^((-1).*pHr)).^h.*...
                %             exp(R.^(-1).*(f.*((-1).*t.^(-1)+ ...
                %             T.^(-1))+(-1).*e.*T.^(-1)+0.1E1.*(g.^2+(-0.1E1).*h).*(0.1E1+0.16E1.* ...
                %             is.^0.5E0).^(-1).*is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.*v+q.*t.*( ...
                %             s.*t.*u+(-0.1E1).*r.*v))))...
                %             ).^(-1).*(1+1.6*is.^0.5).^(-1).*s.^(-1).*v.^(-1);%%% end of denominator
                %
                %             dInv1=(10.^((-1).*pHr)).^d.*...
                %             exp(R.^(-1).*(b.*((-1).*t.^(-1)+T.^(-1))+(-1).*a.* ...
                %             T.^(-1)+0.1E1.*(c.^2+(-0.1E1).*d).*(1+1.6*is.^0.5).^(-1).* ...
                %             is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.*v+q.*t.*(s.*t.*u+(-0.1E1).* ...
                %             r.*v))));
                %
                %         dInv2=(10.^((-1).*pHr)).^D.*...
                %             exp(R.^(-1).*(B.*((-1).*t.^(-1)+T.^(-1))+( ...
                %             -1).*A.*T.^(-1)+0.1E1.*(C.^2+(-0.1E1).*D).*(1+1.6*is.^0.5).^( ...
                %             -1).*is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.*v+q.*t.*(s.*t.*u+( ...
                %             -0.1E1).*r.*v))));
                %
                %         dInv3=(10.^((-1).*pHr)).^h.*...
                %             exp(R.^(-1).*(f.*((-1).*t.^(-1)+ ...
                %             T.^(-1))+(-1).*e.*T.^(-1)+0.1E1.*(g.^2+(-0.1E1).*h).*(0.1E1+0.16E1.* ...
                %             is.^0.5E0).^(-1).*is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.*v+q.*t.*( ...
                %             s.*t.*u+(-0.1E1).*r.*v))));
                %
                %         dinvEnd=(1+1.6*is.^0.5).^(-1).*s.^(-1).*v.^(-1);
                %
                %         denominatorInv=(dInv1+dInv2+dInv3)^-1*dinvEnd;
                %
                %
                %
                %
                %             numerator=((10.^((-1).*pHr)).^d.*...
                %             exp((-1).*R.^(-1).*(b.*(t.^(-1)+(-1) ...
                %             .*T.^(-1))+a.*T.^(-1)+(-0.1E1).*(c.^2+(-0.1E1).*d).*(0.1E1+0.16E1.* ...
                %             is.^0.5E0).^(-1).*is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.*v+q.*t.*( ...
                %             s.*t.*u+(-0.1E1).*r.*v))))...
                %             .*(b*(1+1.6*is^0.5)*s*v...
                %             +c^2*is.^0.5*t^2*(2.*s.*t.*u-r*v)+d.*is.^0.5*t^2*(-2*s*t*u+r*v))...
                %             +(10.^((-1).*pHr)).^D.*...
                %             exp((-1).*R.^(-1).*(B.*( ...
                %             t.^(-1)+(-1).*T.^(-1))+A.*T.^(-1)+(-0.1E1).*(C.^2+(-0.1E1).*D).*(0.1E1+ ...
                %             0.16E1.*is.^0.5E0).^(-1).*is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.* ...
                %             v+q.*t.*(s.*t.*u+(-0.1E1).*r.*v))))...
                %             .*(B.*(1+1.6*is.^0.5).*s.*v+ ...
                %             C.^2*is^0.5*t^2*(2*s*t*u-r*v)+D*is.^0.5*t^2*(-2*s*t*u+r*v))...
                %             +(10.^(-pHr)).^h.*...
                %             exp((-1).*R.^(-1).* ...
                %             (f.*(t.^(-1)+(-1).*T.^(-1))+e.*T.^(-1)+(-0.1E1).*(g.^2+(-0.1E1).*h).*( ...
                %             1+1.6*is.^0.5).^(-1).*is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*( ...
                %             p.*s.*v+q.*t.*(s.*t.*u+(-0.1E1).*r.*v))))...
                %             *(f*(1+1.6*is.^0.5)*s*v+g^2*is^0.5*t.^2*(2*s*t*u-r*v)+h*is^0.5*t^2*(-2*s*t*u+r*v)));
                %             dHf0=denominatorInv*numerator;

                if isnan(dHf0)
                    %see Mathematica file dHfn.nb
                    error('No multiple precision toolbox: NaN returned if exp(x) gets too large')
                end
            otherwise
                dHf0 = NaN;
        end
        if isnan(dHf0)
            %see Mathematica file dHfn.nb
            error('Too many species in reactant so standard transformed enthalpy is NaN')
        end
    else
        %changed to NaN 20 July 2009
        dHf0=NaN;
    end
else
    fprintf('%s\n','Using multiple precision toolbox');
    dGzero=mp(dGzero);
    dHzero=mp(dHzero);
    zi=mp(zi);
    nH=mp(nH);
    pHr=mp(pHr);
    is=mp(is);
    chi=mp(chi);
    %culture temp
    temp=mp(temp);

    R=mp(8.31451);
    %Energies are expressed in kJ mol^-1.*)
    R=R/1000;
    %standard temperature with a capital T
    T=mp(298.15);
    %Faraday Constant (kJ/mol)
    F=96.48; %kJ/mol
    F=mp(F);

    p=mp(9.20483);
    q=mp(10^3);
    r=mp(1.284668);
    s=mp(10^5);
    u=mp(4.95199);
    v=mp(10^8);

    %RTalpha p 49 Alberty 2003
    %where alpha is the Debye-Huckel Constant
    gibbscoeff = (9.20483*temp)/10^3 - (1.284668*temp^2)/10^5 + (4.95199*temp^3)/10^8;

    %If standard enthalpy of formation is known, and independent of
    %temperature an adjustment for temperature can be made.
    %(calcdGHT p289 Alberty 2003)
    if isempty(dHzero) || double(temp)==T;
        %dGzeroT = (dGzero*temp)/T + dHzero*(1 - temp/T);
        dGzeroT = dGzero;%(dGzero*temp)/T + dHzero*(1 - temp/T);
    else
        dGzeroT = (dGzero*temp)/T + dHzero*(1 - temp/T);
    end

    %pHr
    if Legendre
        %Eq. 4.4-9/10 p67 Alberty 2003
        %note the use of culture temperature
        pHterm = nH*R*temp*log(10^-pHr);
        %Eq 4.4-10 Alberty 2003 with temp dependent gibbscoeff
        istermG = (gibbscoeff*(zi.^2 - nH)*is^0.5)/(1 + 1.6*is^0.5);
    else
        %no Legendre transformation for pHr
        pHterm = 0;
        %Eq 3.6-3 Alberty 2003 with temp dependent gibbscoeff
        istermG = (gibbscoeff*(zi.^2)*is^0.5)/(1 + 1.6*is^0.5); %omit the -nH if  no Legendre
    end

    if LegendreCHI
        if 0
            %By convention, we assume the chemical potential of a metabolite
            %includes an electrical potential term
            % u = u0 + RT*log(activity) + F*zi*chi;
            %The Legendre transformation for electrical potential is
            % u' = u -  F*zi*chi = u0 + RT*log(activity);
            %So the following line will negate the effect of an electrical
            %potential ONLY if it has previously been added.
            electricalTerm=-(F*(chi/1000))*zi;
            %eq 8.5-1 p148 Alberty 2003
        else
            %Imaginary Legendre Transformation for Electrical Potential, to
            %take account of the fact that we have not previously added an
            %electrical potential term to the standard Gibbs energy.
            electricalTerm=0;
            %The charge and change in chemical potential for multiphase
            %reactions is taken into account in
            %deltaG0concFluxConstraintBounds.m
        end
    end

    %standard transformed Gibbs energy of each species
    gpfnsp = dGzeroT - pHterm - istermG - electricalTerm;

    %partition function
    pf=sum(exp(-gpfnsp/(R*temp)));

    %mole fraction
    if length(dGzero)==1
        mf=1;
    else
        %mole fraction of each species if there is more than one
        lin_gpfnsp=exp(-gpfnsp/(R*temp));
        %cast back into a double
        mf=double(lin_gpfnsp/pf);
    end

    %activity coefficient
    lambda=double(exp(-(gibbscoeff*(zi.^2)*is^0.5)/(1 + 1.6*is^0.5)/(R*temp)));

    %average number of H+ ions bound by a reactant
    aveHbound=mf'*double(nH);

    %average number of H+ ions bound by a reactant
    aveZi=mf'*double(zi);

    %isomer group thermodynamic standard transformed Gibbs energy of
    %formation for a reactant with more than one metabolite species
    if length(dGzero)==1
        dGf0=gpfnsp;
    else
        dGf0 = -R*temp*log(pf);
    %     dGf0 = -R*temp*maxstar(-gpfnsp/(R*temp));
    end

    %isomer group thermodynamic standard transformed Enthalpy of
    %formation for a reactant
    %%%%%%% makes script faster to leave this out for now.
    dHzero=[];
    %%%%%%%
    if ~isempty(dHzero)
        %make temperature a smaller variable
        t=temp;
        switch length(dGzero)
            case 1
                %corresponds to Simplify[-(t^2*D[dGf0/t, t])] in Albertys code for
                %one species reactant
                %see Mathematica file dHfn.nb
                A=dGzero(1);
                B=dHzero(1);
                C=zi(1);
                D=nH(1);
                dHf0 =(B*(1+1.6*is^0.5)*s*v + (C^2)*(is^0.5)*(t^2)*(2*s*t*u-r*v)+D*(is^0.5)*(t^2)*(-2*s*t*u+r*v)) / ((1+1.6*is^0.5)*s*v);
            case 2
                %see Mathematica file dHfn.nb
                A=dGzero(1);
                B=dHzero(1);
                C=zi(1);
                D=nH(1);
                a=dGzero(2);
                b=dHzero(2);
                c=zi(2);
                d=nH(2);
                %translated to matlab from mathematica by hand
                dHf0 =((10^-pHr)^d*exp(-(b*((1/t)-(1/T))+a/T-(((c^2-d)*is^0.5*(p*s*v+q*t*(s*t*u-r*v)))/((1+1.6*is^0.5)*q*s*v)))/R)*(b*(1+1.6*is^0.5)*s*v+...
                    c^2*is^0.5*t^2*(2*s*t*u-r*v)+d*is^0.5*t^2*(-2*s*t*u+r*v))+...
                    (10^-pHr)^D*exp(-(B*((1/t)-(1/T))+A/T-(((C^2-D)*is^0.5*(p*s*v+q*t*(s*t*u-r*v)))/((1+1.6*is^0.5)*q*s*v)))/R)*(B*(1+1.6*is^0.5)*s*v+...
                    C^2*is^0.5*t^2*(2*s*t*u-r*v)+D*is^0.5*t^2*(-2*s*t*u+r*v)))/...
                    (((10^-pHr)^d*exp((b*((-1/t)+(1/T))-a/T+(((c^2-d)*is^0.5*(p*s*v+q*t*(s*t*u-r*v)))/((1+1.6*is^0.5)*q*s*v)))/R)+...
                    (10^-pHr)^D*exp((B*((-1/t)+(1/T))-A/T+(((C^2-D)*is^0.5*(p*s*v+q*t*(s*t*u-r*v)))/((1+1.6*is^0.5)*q*s*v)))/R))*(1+1.6*is^0.5)*s*v);
                %         Mathematica Expression to Matlab m-file Converter by Harri Ojanen, Rutgers University
                %         dHfn2=((10.^((-1).*pHr)).^d.*exp(R.^(-1).*(b.*((-1).*t.^(-1)+T.^(-1))+(-1).*a.* ...
                %             T.^(-1)+0.1E1.*(c.^2+(-0.1E1).*d).*(0.1E1+0.16E1.*is.^0.5E0).^(-1).* ...
                %             is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.*v+q.*t.*(s.*t.*u+(-0.1E1).* ...
                %             r.*v))))+(10.^((-1).*pHr)).^D.*exp(R.^(-1).*(B.*((-1).*t.^(-1)+T.^(-1))+( ...
                %             -1).*A.*T.^(-1)+0.1E1.*(C.^2+(-0.1E1).*D).*(0.1E1+0.16E1.*is.^0.5E0).^( ...
                %             -1).*is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.*v+q.*t.*(s.*t.*u+( ...
                %             -0.1E1).*r.*v))))).^(-1).*(0.1E1+0.16E1.*is.^0.5E0).^(-1).*s.^(-1).*v.^( ...
                %             -1).*((10.^((-1).*pHr)).^d.*exp((-1).*R.^(-1).*(b.*(t.^(-1)+(-1).*T.^(-1) ...
                %             )+a.*T.^(-1)+(-0.1E1).*(c.^2+(-0.1E1).*d).*(0.1E1+0.16E1.*is.^0.5E0).^( ...
                %             -1).*is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.*v+q.*t.*(s.*t.*u+( ...
                %             -0.1E1).*r.*v)))).*(b.*(1+0.16E1.*is.^0.5E0).*s.*v+c.^2.*is.^0.5E0.* ...
                %             t.^2.*(0.2E1.*s.*t.*u+(-0.1E1).*r.*v)+d.*is.^0.5E0.*t.^2.*((-0.2E1).*s.* ...
                %             t.*u+r.*v))+(10.^((-1).*pHr)).^D.*exp((-1).*R.^(-1).*(B.*(t.^(-1)+(-1).* ...
                %             T.^(-1))+A.*T.^(-1)+(-0.1E1).*(C.^2+(-0.1E1).*D).*(0.1E1+0.16E1.* ...
                %             is.^0.5E0).^(-1).*is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.*v+q.*t.*( ...
                %             s.*t.*u+(-0.1E1).*r.*v)))).*(B.*(1+0.16E1.*is.^0.5E0).*s.*v+C.^2.* ...
                %             is.^0.5E0.*t.^2.*(0.2E1.*s.*t.*u+(-0.1E1).*r.*v)+D.*is.^0.5E0.*t.^2.*(( ...
                %             -0.2E1).*s.*t.*u+r.*v)));
            case 3
                A=dGzero(1);
                B=dHzero(1);
                C=zi(1);
                D=nH(1);
                a=dGzero(2);
                b=dHzero(2);
                c=zi(2);
                d=nH(2);
                e=dGzero(3);
                f=dHzero(3);
                g=zi(3);
                h=nH(3);
                %see Mathematica file dHfn.nb
                %Mathematica Expression to Matlab m-file Converter by Harri Ojanen, Rutgers University
                dHf0 = ((10.^((-1).*pHr)).^d.*exp(R.^(-1).*(b.*((-1).*t.^(-1)+T.^(-1))+(-1).*a.* ...
                    T.^(-1)+0.1E1.*(c.^2+(-0.1E1).*d).*(0.1E1+0.16E1.*is.^0.5E0).^(-1).* ...
                    is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.*v+q.*t.*(s.*t.*u+(-0.1E1).* ...
                    r.*v))))+(10.^((-1).*pHr)).^D.*exp(R.^(-1).*(B.*((-1).*t.^(-1)+T.^(-1))+( ...
                    -1).*A.*T.^(-1)+0.1E1.*(C.^2+(-0.1E1).*D).*(0.1E1+0.16E1.*is.^0.5E0).^( ...
                    -1).*is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.*v+q.*t.*(s.*t.*u+( ...
                    -0.1E1).*r.*v))))+(10.^((-1).*pHr)).^h.*exp(R.^(-1).*(f.*((-1).*t.^(-1)+ ...
                    T.^(-1))+(-1).*e.*T.^(-1)+0.1E1.*(g.^2+(-0.1E1).*h).*(0.1E1+0.16E1.* ...
                    is.^0.5E0).^(-1).*is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.*v+q.*t.*( ...
                    s.*t.*u+(-0.1E1).*r.*v))))).^(-1).*(0.1E1+0.16E1.*is.^0.5E0).^(-1).*s.^( ...
                    -1).*v.^(-1).*((10.^((-1).*pHr)).^d.*exp((-1).*R.^(-1).*(b.*(t.^(-1)+(-1) ...
                    .*T.^(-1))+a.*T.^(-1)+(-0.1E1).*(c.^2+(-0.1E1).*d).*(0.1E1+0.16E1.* ...
                    is.^0.5E0).^(-1).*is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.*v+q.*t.*( ...
                    s.*t.*u+(-0.1E1).*r.*v)))).*(b.*(1+0.16E1.*is.^0.5E0).*s.*v+c.^2.* ...
                    is.^0.5E0.*t.^2.*(0.2E1.*s.*t.*u+(-0.1E1).*r.*v)+d.*is.^0.5E0.*t.^2.*(( ...
                    -0.2E1).*s.*t.*u+r.*v))+(10.^((-1).*pHr)).^D.*exp((-1).*R.^(-1).*(B.*( ...
                    t.^(-1)+(-1).*T.^(-1))+A.*T.^(-1)+(-0.1E1).*(C.^2+(-0.1E1).*D).*(0.1E1+ ...
                    0.16E1.*is.^0.5E0).^(-1).*is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*(p.*s.* ...
                    v+q.*t.*(s.*t.*u+(-0.1E1).*r.*v)))).*(B.*(1+0.16E1.*is.^0.5E0).*s.*v+ ...
                    C.^2.*is.^0.5E0.*t.^2.*(0.2E1.*s.*t.*u+(-0.1E1).*r.*v)+D.*is.^0.5E0.* ...
                    t.^2.*((-0.2E1).*s.*t.*u+r.*v))+(10.^((-1).*pHr)).^h.*exp((-1).*R.^(-1).* ...
                    (f.*(t.^(-1)+(-1).*T.^(-1))+e.*T.^(-1)+(-0.1E1).*(g.^2+(-0.1E1).*h).*( ...
                    0.1E1+0.16E1.*is.^0.5E0).^(-1).*is.^0.5E0.*q.^(-1).*s.^(-1).*v.^(-1).*( ...
                    p.*s.*v+q.*t.*(s.*t.*u+(-0.1E1).*r.*v)))).*(f.*(1+0.16E1.*is.^0.5E0).* ...
                    s.*v+g.^2.*is.^0.5E0.*t.^2.*(0.2E1.*s.*t.*u+(-0.1E1).*r.*v)+h.* ...
                    is.^0.5E0.*t.^2.*((-0.2E1).*s.*t.*u+r.*v)));
            otherwise
                dHf0 = NaN;
        end
        if isnan(dHf0)
            %see Mathematica file dHfn.nb
%             error('Too many species in reactant so standard transformed enthalpy is NaN')
            fprintf('%s\n','Too many species in reactant so standard transformed enthalpy is NaN')
        end
        %cast back into normal matlab double
        dHf0=double(dHf0);
    else
        %changed to NaN 20 July 2009
        dHf0=NaN;
    end
    %cast back into normal matlab double
    dGf0=double(dGf0);
    gpfnsp=double(gpfnsp);
end

%
%This is a helper function to compute the log(sum(exp(v))) of a vector v
function y = maxstar(x, w, dim)
% maxstar   Log of a sum of exponentials.
%   For vectors, maxstar(x) is equivalent to log(sum(exp(x))).
%   For matrices, maxstar(x) is a row vector and maxstar operates on
%   each column of x. For N-D arrays, maxstar(x) operates along the
%   first non-singleton dimension.
%
%   maxstar(x,w) is the log of a weighted sum of exponentials,
%   equivalent to log(sum(w.*exp(x))). Vectors w and x must be
%   the same length. For matrix x, the weights w can be input as
%   a matrix the same size as x, or as a vector of the same length
%   as columns of x. Weights may be zero or negative, but the result
%   sum(w.*exp(x)) must be greater than zero.
%
%   maxstar(x, [], dim) operates along the dimension dim, and has
%   the same dimensions as the MATLAB function max(x, [], dim).
%
%   Note:
%   The max* function is described in Lin & Costello, Error Control
%   Coding, 2nd Edition, equation 12.127, in the two-argument form
%     max*(x1,x2) = max(x1,x2) + log(1 + exp(-abs(x1-x2))).
%   The function max* can be applied iteratively:
%     max*(x1,x2,x3) = max*(max*(x1,x2),x3).
%   Functions max(x) ~ max*(x), and min(x) ~ -max*(-x).
%
%   Algorithm:
%   The double precision MATLAB expresson log(sum(exp(x))) fails
%   if all(x < -745), or if any(x > 706). This is avoided using
%   m = max(x) in  max*(x) = m + log(sum(exp(x - m))).
%
%   Example: If x = [2 8 4
%                    7 3 9]
%
%   then maxstar(x,[],1) is [7.0067 8.0067 9.0067],
%
%   and  maxstar(x,[],2) is [8.0206
%                            9.1291].

% 2006-02-10   R. Dickson
% 2006-03-25   Implemented N-D array features following a suggestion
%              from John D'Errico.
%
%   Uses: max, log, exp, sum, shiftdim, repmat, size, zeros, ones,
%         length, isempty, error, nargin, find, reshape

if nargin < 1 || nargin > 3
    error('Wrong number of input arguments.');
end

[x, n] = shiftdim(x);
szx = size(x);

switch nargin
    case 1
        w = [];
        dim = 1;
    case 2
        dim = 1;
    case 3
        dim = dim - n;
end

if isempty(w)
    % replicate m = max(x) to get mm, with size(mm) == size(x)
    m = max(x,[],dim);
    szm = ones(size(szx));
    szm(dim) = szx(dim);
    mm = repmat(m,szm);
    y = m + log(sum(exp(x - mm), dim));
else
    w = shiftdim(w);
    szw = size(w);
    % protect the second condition with a short-circuit or
    if ~(length(szw) == length(szx)) || ~all(szw == szx)
        if size(w,1) == size(x,dim)
            % replicate w with repmat so size(w) == size(x)
            szw = ones(size(szx));
            szw(dim) = size(w,1);
            w = reshape(w, szw);
            szr = szx;
            szr(dim) = 1;
            w = repmat(w, szr);
        else
            error('Length of w must match size(x,dim).');
        end
    end

    % Move the weight into the exponent xw and find
    % m = max(xw) over terms with positive weights
    ipos = find(w>0);
    xw = -Inf*zeros(szx);
    xw(ipos) = x(ipos) + log(w(ipos));
    m = max(xw,[],dim);
    % replicate m with repmat so size(mm) == size(x)
    szm = ones(size(szx));
    szm(dim) = szx(dim);
    mm = repmat(m,szm);
    exwp = zeros(szx);
    exwp(ipos) = exp(xw(ipos)-mm(ipos));
    % check for terms with negative weights
    ineg = find(w<0);
    if ~isempty(ineg)
        exwn = zeros(szx);
        exwn(ineg) = exp(x(ineg) + log(-w(ineg)) - mm(ineg));
        y = m + log(sum(exwp, dim) - sum(exwn, dim));
    else
        y = m + log(sum(exwp, dim));
    end
end
%
