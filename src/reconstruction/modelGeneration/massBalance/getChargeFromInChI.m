function [charge, chargeWithoutProtons] = getChargeFromInChI(InChI)
% Returns the charge from a given InChI string
%
% USAGE:
%
%    [charge, chargeWithoutProtons] = getChargeFromInChI(InChI)
%
% INPUT:
%    InChI:                   The Inchi Identifier - string
%
% OUTPUTS:
%    charge:                  The charge encoded in the `InChi` string (including protonation)
%    chargeWithoutProtons:    The charge encoded in the `InChi` ignoring the protonation state
%
% NOTE:
%
%    InChI Charge is defined in the charge layer and can be modified in the
%    proton layer. If nothing is defined, the compound is uncharged.
%    First: Discard any "Reconnected" parts, as those don't influence the
%    charge
%
% .. Author:
%       - Ronan Fleming, 23 Sept 09
%       - Thomas Pfau, May 2017, Updated
    
    InChI = regexprep(InChI,'/r.*','');
    
    %Charge Layer: (either at the end or at the start)
    q_layer = regexp(InChI,'/q(.*?)/|/q(.*?)$','tokens');
    %We need to store a potential change of charge in the fixed-H
    %layer, as we need to ignore that change later on.        
    q_fixed_H_layer = regexp(InChI,'/f.*?/q(.*?)/|/f.*?/q(.*?)$','tokens');        
        
    %proton layer
    p_layer = regexp(InChI,'/p(.*?)/|/p(.*?)$','tokens');    
    
    chargeWithoutProtons = 0;
    
    if ~isempty(q_layer)
        %Get individual charges from splitted reactions.
        individualCharges = cellfun(@(x) {strsplit(x{1},';')},q_layer);
        %And calculate the charge by evaluating the individual components.
        chargeWithoutProtons = sum(cellfun(@(x) sum(cellfun(@(y) eval(y) , x)), individualCharges));
        if ~isempty(q_fixed_H_layer)
            individualCharges_fixed_H = cellfun(@(x) {strsplit(x{1},';')},q_fixed_H_layer);        
            chargeWithoutProtons = chargeWithoutProtons - sum(cellfun(@(x) sum(cellfun(@(y) eval(y) , x)), individualCharges_fixed_H));
        end
    end
    
    proton_charges = 0;
    if ~isempty(p_layer)
        individualProtons = cellfun(@(x) {strsplit(x{1},';')},p_layer);
        proton_charges = cellfun(@(x) sum(cellfun(@(y) eval(y) , x)), individualProtons);
    end
    %The overall Charge is the combination of charge from protons and base
    %charge
    charge = proton_charges + chargeWithoutProtons;
