function N=numAtomsOfElementInFormula(formula,element)
% returns the number of atoms of a single element in a formula
%
% INPUT
% formula       formula in format Element then NumberOfAtoms with no spaces
% element       Abbreviation of element e.g. C or Mg
%
% OUTPUT
% N             number of atoms of this element in the formula provided
%
% Ronan Fleming 9 March 09
% Ronan Fleming 21 July 09 handles formulae with same first letter for
%                          element e.g.C & Co in 'C55H80CoN15O11'
% Ronan Fleming 18 Sept 09 handles composite formulae like C62H90N13O14P.C10H11N5O3.Co
% Hulda SH 7 July 2011 Simplified and generalized code. Now handles most or
%                      all exceptional formulas.

if any(~isletter(element))
    disp(element)
    error('Element must not contain numbers')
end

if length(element)==1
    if ~strcmp(upper(element),element)
        disp(element)
        error('Single letter element must not be lower case')
    end
end

if ~isletter(formula(1))
    disp(formula)
    error('Formula format expected is element then number of elements, not the other way around')
end

zero='0';
indZero=strfind(formula,zero);
if ~isempty(indZero)
    if isletter(formula(indZero-1))
        % formula = strrep(formula, zero, 'O');
        error('Formula contains a zero with a letter preceeding it, represent oxygen with a the character O not zero')
    end
end

%Count FULLR and FULLR2 groups as R groups (Human reconstruction)
formula = strrep(formula, 'FULLR2', 'R');
formula = strrep(formula, 'FULLR', 'R');

if ischar(element) && ischar(formula)
    elementStart = regexp(formula, '[A-Z]', 'start'); % Get indices of all capital letters in the string formula. Treated as starting indices of elements.
    elementArray = cell(length(elementStart),2); % Initialize cell array for element symbols (Column 1) and numerical subscripts (Column 2)
    
    for n = 1:length(elementStart) % Loop for each element in formula
        if n < length(elementStart)
            splitFormula = formula(elementStart(n):(elementStart(n+1)-1)); % Extract section of formula from starting index of element n to starting index of element n+1
            
        else
            splitFormula = formula(elementStart(n):end);
            
        end
        
        if ~isempty(regexp(splitFormula, '[^a-z_A-Z]', 'once')) % If current section of formula contains non-alphabetic characters
            elementArray{n,1} = splitFormula(1:(regexp(splitFormula, '[^a-z_A-Z]', 'once')-1)); % Element symbol assumed to extend from beginning of current section to the first non-alphabetic character
            rest = splitFormula(regexp(splitFormula, '[^a-z_A-Z]', 'once'):end); % Rest of section after element symbol.
            
            if ~isempty(regexp(rest, '\W', 'once')) % Rest of section may contain word characters such as numbers and dots.
                if ~isempty(regexp(rest(1), '\d', 'once')) % If first character following element symbol is numeric it is assumed to represent the number of atoms of that element.
                    elementArray{n,2} = rest(1:(regexp(rest, '\W', 'once')-1)); % Extract element's numeric subscript.
                    
                else
                    elementArray{n,2} = '1'; % If no number follows element symbol the numeric subscript is assumed to be 1.
                    
                end
                
            else
                elementArray{n,2} = rest;
            
            end
            
        else
            elementArray{n,1} = splitFormula;
            elementArray{n,2} = '1';
            
        end
    end
    
    elementRows = strmatch(element, elementArray(:,1), 'exact'); % Element may appear in two different locations within formula.
    
    if ~isempty(elementRows)
        elementCount = zeros(length(elementRows),1);
        
        for m = 1:length(elementRows)
            elementCount(m,1) = str2double(elementArray{elementRows(m),2}); % Get numeric subscript by each instance of element in formula and convert from char to double
            
        end
        
        N = sum(elementCount);
        
    else
        N = 0;
        
    end
    
else
    if ~ischar(element)
        disp(element)
        error('Element must be given by a variable of class char')
    else
        disp(element)
        error('Formula must be given by a variable of class char')
    end
end