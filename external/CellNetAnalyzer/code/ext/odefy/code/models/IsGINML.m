% ISGINML  Determines whether a file has GINML format
%
%   R=ISGINML(FILE) determines whether file is a GINML XML file
%
%   Reference:
%   GINsim: a software suite for the qualitative modelling, simulation and 
%   analysis of regulatory networks. Gonzalez AG, Naldi A, Sánchez L, 
%   Thieffry D, Chaouiya C. Biosystems. 2006 May;84(2):91-100. 

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function r=IsGINML(file)
r=false;
if IsXML(file)
    % get 2 lines
    h=fopen(file,'r');
    % read
    while ~feof(h)
        l=strtrim(fgetl(h));
        if numel(l)>0
            % XML?
            l1 = l;
            l2 = strtrim(fgetl(h));
            if numel(strfind(l2,'GINsim'))
                r=true;
            end            
            break;
        end
    end
    fclose(h);
end