function charge=getChargeFromInChI(InChI)
%return the charge from a given InChI string
%
%INPUT
% InChI string
%
% OUTPUT
% charge
%
% Ronan Fleming 23 Sept 09

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