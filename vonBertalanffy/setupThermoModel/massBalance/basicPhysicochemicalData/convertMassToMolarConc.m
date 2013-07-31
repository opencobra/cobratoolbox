function c = convertMassToMolarConc(rho,formula)
%for compound with given formula, convert mg\L mass concentration rho, 
%to concentration (mmol/L)
%
%INPUT
% rho       mass concentration (mg/L)
% formula
%
%OUTPUT
% c         conc (mmol/l)

%convert rho (mg/L) to rho (kg/m3)
rho=rho/1000;

%M molecular mass(es) in (g/Mol)
M=getMolecularMass(formula);

%convert M (g/Mol) to M (kg/Mol)
M=M/1000;

%conc (mol/m3)
c=rho/M;

%convert conc (mol/m3) to conc (mmol/L)
c=c;