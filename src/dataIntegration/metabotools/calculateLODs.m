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
%  Modified by Loic Marx

% input checking
if length(lod_ngmL) == 1
    lod_ngmL = repmat(lod_ngmL, length(theo_mass)) 
    % throw a warning
warning(The inputs have different size but we fixed it)
end    

if length(lod_ngmL) ~= 1
    error ('both inputs do not have the same size')
end

lod_gL = lod_ngmL* 0.000001;

lod_mM =[];

for i=1:length(lod_gL)

    lod_mM(i,1)= lod_gL(i,1)/theo_mass(i,1)*1000;

end

end
