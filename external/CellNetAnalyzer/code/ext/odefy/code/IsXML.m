% ISXML
%
%   R=ISXML(FILE) determines whether FILE contains an XML header.

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function x=isXML(file)
x=0;

try
    h=fopen(file,'r');
    % read
    while ~feof(h)
        l=strtrim(fgetl(h));
        if numel(l)>0
            % XML?
            if numel(l)>=5 && strcmpi(l(1:5),'<?xml')
                x=1;
            end
            break;
        end
    end
    fclose(h);
catch
end
