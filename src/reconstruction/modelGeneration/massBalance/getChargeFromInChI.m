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


if 1
    k = strfind(InChI, '/q');
    if isempty(k)
        charge=0;
    else
        %disp(InChI)
        %check if it has a composite formula
        indDots=findstr('.',getFormulaFromInChI(InChI));
        if isempty(indDots)
            if strcmp(InChI(k+2),'+')
                %positive charge
                sgn=1;
            else
                sgn=-1;
            end
            if length(InChI)<k+4
                charge=sgn*str2num(InChI(k+3:k+3));
            else
                if strcmp(InChI(k+4),'/')
                    charge=sgn*str2num(InChI(k+3:k+3));
                else
                    if length(InChI)<k+5
                        charge=sgn*str2num(InChI(k+3:k+4));
                    else
                        if strcmp(InChI(k+5),'/')
                            charge=sgn*str2num(InChI(k+3:k+4));
                        else
                            disp(InChI)
                            error('Charge too high')
                        end
                    end
                end
            end
        else
            %todo - cleanup, this code is a bit messy but seems to work
            totalCharge=0;
            for d=1:length(indDots)+1
                while  strcmp(InChI(k+2),';')
                    k=k+1;
                end
                if strcmp(InChI(k+2),'+') || strcmp(InChI(k+2),'-')
                    if strcmp(InChI(k+2),'+')
                        %positive charge
                        sgn=1;
                    else
                        sgn=-1;
                    end
                else
                    if strcmp(InChI(k+2),'/')
                        break;
                    else
                        disp(InChI)
                        sgn=0;
                        warning(['Not valid charge: ' InChI(k+2)])
                        break;
                        %error(InChI(k+2))
                    end
                end
                if length(InChI)<k+4
                    charge=sgn*str2num(InChI(k+3:k+3));
                    k=k+2;
                else
                    if strcmp(InChI(k+4),'/') || strcmp(InChI(k+4),';')
                        charge=sgn*str2num(InChI(k+3:k+3));
                        k=k+2;
                    else
                        if length(InChI)<k+5
                            charge=sgn*str2num(InChI(k+3:k+4));
                            k=k+3;
                        else
                            if strcmp(InChI(k+5),'/')  || strcmp(InChI(k+5),';')
                                charge=sgn*str2num(InChI(k+3:k+4));
                                k=k+3;
                            else
                                disp(InChI)
                                error('Charge too high')
                            end
                        end
                    end
                end
                d=d+1;
                totalCharge=totalCharge+charge;
            end
            charge=totalCharge;
        end
    end
    %TODO
    chargeWithoutProtons=[];
else
    %Chokes with this inchi - Thomas to fix
    %InChI=1/C60H101N22O15S/c1-33(2)27-40(77-50(88)37(12-6-21-69-59(64)65)74-55(93)44-15-9-24-81(44)56(94)38(13-7-22-70-60(66)67)75-48(86)35(62)17-18-46(63)84)51(89)79-42(31-83)53(91)78-41(28-34-29-68-32-72-34)52(90)73-36(11-4-5-20-61)49(87)71-30-47(85)80-23-8-14-43(80)54(92)76-39(19-26-98-3)57(95)82-25-10-16-45(82)58(96)97/h29,32-33,35-45H,4-28,30-31,61-62H2,1-3H3,(H2,63,84)(H,68,72)(H,71,87)(H,73,90)(H,74,93)(H,75,86)(H,76,92)(H,77,88)(H,78,91)(H,79,89)(H,96,97)(H4,64,65,69)(H4,66,67,70)/q-1/p+4/t35-,36-,37-,38+,39-,40+,41+,42-,43+,44+,45-/m1/s1/fC60H105N22O15S/h61-62,68-79H,63-67H2/q+3
    
    %       - Thomas Pfau, May 2017, Updated
    
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
end