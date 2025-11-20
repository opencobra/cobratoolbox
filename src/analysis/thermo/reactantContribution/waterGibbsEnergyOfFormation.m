function dGf0=waterGibbsEnergyOfFormation(T)
%http://webbook.nist.gov/cgi/cbook.cgi?ID=C7732185&Units=SI&Mask=2#ref-2
A	=-203.6060;
B	=1523.290;
C	=-3196.413;
D	=2474.455;
E	=3.855326;
F	=-256.5478;
G	=-488.7163;
H	=-285.8304;

% t = temperature (K) / 1000.
t=T/1000;

% Cp = heat capacity (J/mol*K)
%Cp = A + B*t + C*t2 + D*t3 + E/t2

% H° = standard enthalpy (kJ/mol)
dHf_liquid =	-285.83; % (kJ/mol)
H = dHf_liquid + A*t + B*((t^2)/2) + C*(t^3)/3 + D*(t^4)/4 - E/t + F - H;

% S° = standard entropy (J/mol*K)
S = A*log(t) + B*t + C*(t^2)/2 + D*(t^3)/3 - E/(2*t^2) + G;
% TS° = standard entropy (kJ/mol)
TS = T*1000*S;

dGf0 = H - TS;
   