function dGf0 = waterGibbsEnergyOfFormation(T)
% Standard Gibbs energy of formation of liquid water at temperature `T`
%
% Uses the NIST Shomate equations (enthalpy and entropy integrals of the
% heat capacity) of liquid water, hydrogen gas and oxygen gas to compute the
% standard Gibbs energy of formation of liquid water, H2(g) + 1/2 O2(g) -> H2O(l),
% as a function of temperature:
%
% .. math::
%      \Delta_f G(T) = \Delta_f H(T) - T \Delta_f S(T)
%
% with :math:`\Delta_f H(T) = \Delta_f H(298.15) + [H(T) - H(298.15)]_{H_2O}
% - [H(T) - H(298.15)]_{H_2} - 1/2 [H(T) - H(298.15)]_{O_2}` and
% :math:`\Delta_f S(T) = S_{H_2O}(T) - S_{H_2}(T) - 1/2 S_{O_2}(T)`.
%
% USAGE:
%
%    dGf0 = waterGibbsEnergyOfFormation(T)
%
% INPUT:
%    T:       temperature in Kelvin
%
% OUTPUT:
%    dGf0:    standard Gibbs energy of formation of liquid water (kJ/mol),
%             about -237.14 kJ/mol at 298.15 K
%
% NOTE:
%    Shomate coefficients from the NIST Chemistry WebBook:
%    liquid water (valid 298-500 K)
%    http://webbook.nist.gov/cgi/cbook.cgi?ID=C7732185&Units=SI&Mask=2#ref-2
%    hydrogen gas (valid 298-1000 K)
%    http://webbook.nist.gov/cgi/cbook.cgi?ID=C1333740&Units=SI&Mask=1#Thermo-Gas
%    oxygen gas (valid 100-700 K)
%    http://webbook.nist.gov/cgi/cbook.cgi?ID=C7782447&Units=SI&Mask=1#Thermo-Gas
%    The result is therefore valid between 298 and 500 K (liquid water);
%    outside this range the Shomate equations are extrapolated.

% Shomate coefficients [A, B, C, D, E, F, G, H]
water    = [-203.6060, 1523.290, -3196.413, 2474.455, 3.855326, -256.5478, -488.7163, -285.8304];
hydrogen = [33.066178, -11.363417, 11.432816, -2.772874, -0.158558, -9.980797, 172.707974, 0];
oxygen   = [31.32234, -20.23531, 57.86644, -36.50624, -0.007374, -8.903471, 246.7945, 0];

% t = temperature (K) / 1000.
t=T/1000;

% Cp = heat capacity (J/mol*K)
%Cp = A + B*t + C*t2 + D*t3 + E/t2

% H(T) - H(298.15) = A*t + B*t^2/2 + C*t^3/3 + D*t^4/4 - E/t + F - H (kJ/mol)
enthalpyChange = @(c) c(1)*t + c(2)*((t^2)/2) + c(3)*(t^3)/3 + c(4)*(t^4)/4 - c(5)/t + c(6) - c(8);
% S = A*ln(t) + B*t + C*t^2/2 + D*t^3/3 - E/(2*t^2) + G (J/mol*K)
entropy = @(c) c(1)*log(t) + c(2)*t + c(3)*(t^2)/2 + c(4)*(t^3)/3 - c(5)/(2*t^2) + c(7);

% standard enthalpy of formation (kJ/mol)
dHf_liquid =	-285.83; % (kJ/mol) at 298.15 K
dfH = dHf_liquid + enthalpyChange(water) - enthalpyChange(hydrogen) - enthalpyChange(oxygen)/2;

% standard entropy of formation (J/mol*K)
dfS = entropy(water) - entropy(hydrogen) - entropy(oxygen)/2;
% T*dfS (kJ/mol)
TS = (T*dfS)/1000;

dGf0 = dfH - TS;
end
