% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted. 
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011

%Input is reaction formula, reaction list (data) and if there is a waitbar.
%output are numbers of rxn lines that share similarity. 
%Stefan G. Thorleifsson 2010

function reactions = similarity(formula,data,bar)
% reactions = similarity(formula,data,bar)
% INPUT 
%   formula - Reaction formula being checked
%   data    - Compare reactions formulas
% INPUT OPTIONAL 
%   bar -  (status bar) 0 to skip
%
% OUTPUT
%   reactions - List of similar reactions (numbers that reference input data).
%
%
if nargin < 3
    bar = 1;
end

comp = cell(1);
compd = cell(1);
reactions = [];

%Generate metabolite, compartment, coefficient and rev array
[met,coe,rev] = parseRxnFormula(formula);
S = length(met);
for n = 1:S
    k = regexpi(met{n},'\[');
    metab = met{n};
    comp{n} = metab(k+1);
    met{n} = metab(1:k-1);
end




Sdata = length(data);

if bar == 1
    h = waitbar(0/Sdata,'This may take a while. Checking reaction');
end

for i = 1:Sdata
    if bar == 1
        waitbar(i/Sdata);
    end
    
    [metd,coed,revd] = parseRxnFormula(data{i});
    %Sd = length(metd);
    
    if length(metd) == S % If reaction has equal number of metabolites.
        for n = 1:S %Create comparison array

            compd{n} = regexprep(regexpi(metd{n},'\[.*?\]','match'),'\[*\]*','');
            metd{n} = metd{n}(1:regexp(metd{n},'\[','end')-1);

        end
        
        match = 0;
        for m = 1:S % Check every metabolite in met
            metab_match = 0;
            for l = 1:S 
                if strcmp(met{m},metd{l})
                    metab_match = 1; 
                end
            end
            if  metab_match == 0 % If metabolite dous not match
                break
            else
                match = match+1;
            end
        end
        
        if match == S
            reactions = [reactions i];
        end
        
        
    end
   
end
if bar == 1
    close(h)
end



