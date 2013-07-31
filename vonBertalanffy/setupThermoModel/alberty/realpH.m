function [pHr,pHAdjustment]=realpH(pHa,temp,is)
% Apparent glass electrode pH is not the same as real pH for thermodynamic calculations.
%
% Given the experimental glass electrode measurement of pH, this function returns
% the pH to be used for thermodynamic calculations, pHc = -log10[H+], 
% by subtracting the effect of the ion atmosphere around H+ which 
% reduces its activity coefficient below unity.
% See p49 Alberty 2003
%
%INPUT
% pHa       apparent pH, measured by glass electrode experimentally
% temp      experimentally measured temperature
% is        estimate of ionic strength
%
%OUTPUT
% pHr           real pH to be used for thermodynamic calculations
% pHAdjustment  adjustment to pH
%
% Ronan M.T. Fleming

%p48 Alberty
gibbscoeff = 1.10708 - (1.54508*temp)/10^3 + (5.95584*temp^2)/10^6;

%Adjust pH using Extended Debye-Huckle equation
pHAdjustment = ( (gibbscoeff*(is^(0.5))) / (log(10)*(1+1.6*(is^(0.5)))) );

% fprintf('%s\t%f\n','pH adjustment',phAdjustment);
pHr = pHa - pHAdjustment;
