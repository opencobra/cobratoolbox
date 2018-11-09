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
%            - Modified by Loic Marx, November 2018

% input checking
if size(lod_ngmL) == 1
    lod_ngmL = repmat(lod_ngmL, 1, length(theo_mass)); 
    end    

if size(lod_ngmL) ~= size(theo_mass)
    error('The number of elements in the input vectors do not match. They have to be either the same size, or lod_ngmL has to be a single value which is used for all elements');
end

lod_gL = lod_ngmL * 1e-6; 
lod_mM = zeros(length(lod_gL), 1);

for i = 1 : length(lod_gL)
    lod_mM(i) = lod_gL(i)/theo_mass(i)*1000;
end

end
