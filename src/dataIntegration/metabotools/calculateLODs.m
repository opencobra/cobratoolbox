function [lod_mM] = calculateLODs(theo_mass,lod_ngmL)
% This function converts detection limits of the unit ng/mL to mM using the
% theoretical mass (g/mol) for the metabolites
%
% USAGE:
%
%    [lod_mM] = calculateLODs(theo_mass, lod_ngmL)
%
% INPUTS:
%   theo_mass:         Vector that specifies the theoretical mass (g/mol) of each metabolite
%   lod_ngmL:          Instrumental limit of detection (ng/mL)
%
% OUTPUT:
%   lod_mM:            Detection limits in mM
%
% .. Author: - Maike K. Aurich 27/05/15
%  Modified by Loic Marx, November 2018

% input checking
if length(lod_ngmL) == 1
    
    lod_ngmL = repmat(lod_ngmL, 1, length(theo_mass)); 
    
    % throw a warning
    warning('The inputs have different size but we managed to fix this problem');
    
end    

if length(lod_ngmL) ~= length(theo_mass)
    
    error('The length of the inputs are not the same');
end

lod_gL = lod_ngmL * 0.000001;

lod_mM = zeros(length(lod_gL), 1);

for i=1 : length(lod_gL)

    lod_mM(i) = lod_gL(i)/theo_mass(i)*1000;

end

end
