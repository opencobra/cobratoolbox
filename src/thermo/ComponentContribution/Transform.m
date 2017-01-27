function dG0_prime = Transform(pseudoisomers, pH, I, T)
% Calculate pseudoisomer group standard transformed Gibbs energy of
% formation at specified pH, ionic strength and temperature.
% 
% DfGt0 = transform(pseudoisomers, pH, I, T)
% 
% INPUTS
% pseudoisomers     p x 3 matrix with a row for each of the p pseudoisomers
%                   in the group, and the following columns:
%                   1. Standard Gibbs energy of formation,
%                   2. Number of hydrogen atoms,
%                   3. Charge.
% pH                pH.
% I                 Ionic strength in mol/L.
% T                 Temperature in Kelvin.
% 
% OUTPUTS
% dG0_prime         Pseudoisomer group standard transformed Gibbs energy of
%                   formation in kJ/mol.
% 
% Elad Noor, Nov. 2012
% Hulda SH, Nov. 2012   Added temperature dependent alpha.

R = 8.3144621e-3; % Gas constant in kJ/(K*mol)
alpha = (9.20483*T)/10^3 - (1.284668*T^2)/10^5 + (4.95199*T^3)/10^8; % Approximation of the temperature dependency of ionic strength effects
DH = (alpha * sqrt(I)) / (1 + 1.6 * sqrt(I)); % Debye Huckel

% dG0' = dG0 + nH * (RTlog(10) * pH + DH) + charge^2 * DH;
dG0_prime_vector = pseudoisomers(:, 1) + ...
                   pseudoisomers(:, 2) * (R*T*log(10)*pH + DH) - ...
                   pseudoisomers(:, 3).^2 * DH;

dG0_prime = -R * T * maxstar(dG0_prime_vector / (-R * T));
