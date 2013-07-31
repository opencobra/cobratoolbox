% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted.
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2012

function [abb, comp] = metCompartment(met)
% [abb, comp] = metComp(met)
%
% INPUT: 
%   met     - metabolite with a specified compartment, "atp[d]"
% 
% OUTPUT:
%   abb     - abbreviation without compartment "atp"
%   comp    - compartment "d"

if isa(met,'cell')
    met = met{1};
end

bracket = regexpi(met,'\[');
comp = met(bracket+1);
abb = met(1:bracket-1);