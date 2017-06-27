function bool=checkFormulae(formulaA,formulaB,exceptions)
%compare two formulae for the number of elements for all optionally except the
%elements listed in exceptions
%
%INPUT
% formulaA
% formulaB
%
%OPTIONAL INPUT
% exceptions     String array of metabolite abbreviation exceptions e.g. {'H'}
%
%OUTPUT
% bool           Boolean where 1 means the formulae match and 0 otherwise
%
%Ronan M. T. Fleming 20 July 2009

if ~exist('exceptions','var')
    exceptions={};
end

if ischar(exceptions)
    ex=exceptions;
    clear exceptions
    exceptions{1}=ex;
end

elements = {'C','H','O','P','S','K','Na','N'};

bool=1;
for n=1:length(elements)
    if ~any(strcmp(elements{n},exceptions))
        numA=numAtomsOfElementInFormula(formulaA,elements{n});
        numB=numAtomsOfElementInFormula(formulaB,elements{n});
        %check to see if number of elements is not the same for each
        %metabolite
        if numA~=numB
            bool=0;
            break;
        end
    end
end
