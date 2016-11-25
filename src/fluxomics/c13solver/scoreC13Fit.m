function [output] = scoreC13Fit(flux,expdata,model, namesset, method)

std = expdata.std2;

%this function (1) computes the theoretical mdv distribution vector for
%a given flux vector, v, (2) and then computes an error score by taking a
%running sum of the squared difference between the theortical and
%experimental mdv vectors. 

%v - flux vector array
%expdata - experimental data structure 
%     e.g.
%       ala57
%          - met = xalaL
%          - fragment = [1,1,1]'
%          - data = [0.238,0.098,0.017]'
% glc_cdv is a sugar distribution in cuomer format (see idv2cdv).

% output contains fields:
%        - error - the calculated error sum value
%        - theory - theoretical mdv vector 
%        - experimental - experimental mdv vector 


max_attempt = 2; % keep this at two to try both methods

isV = length(flux) == length(model.lb);
if nargin < 6
    method = 2; % method 1 = cumomer.  method 2 = CMU
end

%check if flux is alpha factor or v
%if flux is v then make appropriate assignments
if(isV)
    v = flux; 
else
    v = (model.N)*flux;
end

if nargin < 5 || isempty(namesset)
    namesset = false;
end
          


attempt = 1;
names = fields(expdata.fragments);
expdata2 = expdata.fragments;  

while attempt <= max_attempt
    tmdv = zeros(0,1);
    emdv = zeros(0,1);
    if method == 1 %cumomer
        glc_input = expdata.input;
        o = slvrCumomer_fast(v, glc_input);
        for l = 1:length(names)
            name = names{l};
            tname = expdata2.(name).met;
            tfragment = expdata2.(name).fragment;
            tresult = idv2mdv(length(tfragment), tfragment)*o.(tname);
            eresult = expdata2.(name).data;
            tmdv = [tmdv; tresult];
            emdv = [emdv; eresult];
        end
    elseif method == 2 %newer/faster
        glc_input = expdata.inputfrag;
        o = slvrEMU_fast(v, glc_input);
        for l = 1:length(names)
            name = names{l};
            tname = expdata2.(name).metfrag;
            tresult = o.(tname);
            eresult = expdata2.(name).data;
            tmdv = [tmdv; tresult];
            emdv = [emdv; eresult];
        end
    end
    
    if any(isnan(tmdv)) && attempt < max_attempt
        attempt = attempt + 1;
        if method == 1
            method = 2;
        else
            method = 1;
        end
    else
%         if attempt == 2 % aka it worked the second time
%             fprintf('s');
%             pause;
%         end
        break;
    end
end
if any(isnan(tmdv))
    save errorFile flux
end
%iterate through both the theoretical and experimental vectors and compute
%a running error value 

variation = (tmdv - emdv).^2; 

output = struct;
output.error = sum(variation)/(std^2); 
output.theory = tmdv;
output.experimental = emdv;
if(namesset)
    k = 1;
    for l = 1:length(names)
        name = names{l};
        if method == 1
            tname = expdata2.(name).met; 
        else
            tname = expdata2.(name).metfrag;
        end
        %tresult = o.(tname);
        for i = 1:length(expdata2.(name).fragment)
            newname = strcat(name, num2str(i-1));
            mdvnames{k,1} = newname;
            k = k+1;
        end
    end
    output.mdvnames = mdvnames;
end
return