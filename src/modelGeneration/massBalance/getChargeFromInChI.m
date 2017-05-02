function [charge,chargeWithoutProtons]=getChargeFromInChI(InChI)
%return the charge from a given InChI string
%
%INPUT
% InChI string
%
% OUTPUT
% charge
%
% Ronan Fleming 23 Sept 09
% Updated May 2017 Thomas Pfau

%InChI Charge is defined in the charge layer and can be modified in the
%proton layer. If nothing is defined, the compound is uncharged

%First: Discard any "Reconnected" parts, as those don't influence the
%charges
InChI = regexprep(InChI,'/r.*','');

%Charge Layer: (either at the end or at the start)
q_layer = regexp(InChI,'/q(.*?)/|/q(.*?)$','tokens');
%proton layer
p_layer = regexp(InChI,'/p(.*?)/|/p(.*?)$','tokens');

chargeWithoutProtons = 0;

if ~isempty(q_layer)
    %Get individual charges from splitted reactions. 
    individualCharges = cellfun(@(x) {strsplit(x{1},';')},q_layer);
    %And calculate the charge by evaluating the individual components.
    chargeWithoutProtons = cellfun(@(x) sum(cellfun(@(y) eval(y) , x)), individualCharges);    
end

proton_charges = 0;
if ~isempty(p_layer)
    individualProtons = cellfun(@(x) {strsplit(x{1},';')},p_layer);
    proton_charges = cellfun(@(x) sum(cellfun(@(y) eval(y) , x)), individualProtons);
end
%The overall Charge is the combination of charge from protons and base
%charge
charge = proton_charges + chargeWithoutProtons;
