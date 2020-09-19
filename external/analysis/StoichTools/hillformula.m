function species = hillformula(varargin)
%
% HILLFORMULA  Produce a cell array of chemical formulas in Hill Notation.
%
%   species = hillformula(r)
%   species = hillformula(species)
%
%   Construct a cell array of chemical formula strings in Hill notation.
%   The input is either a cell array of chemical formulas or a structure
%   array of atomic representations.
%
%
% EXAMPLES
%   
%   1. Construct formula for methane
%
%       r.C = 1;
%       r.H = 4;
%       hillformula(r);       
%
%   2. Roundtrip construction for methanol
%
%       r = parse_formula('CH3OH');
%       hillformula(r)
%
%   3. Convert formula to Hill notation
%
%      sp = hillformula('H2SO4');
%
%
% USAGE NOTES
%
%   1. Starting with a chemical formula s1,
%
%          s2 = hillformula(s1)
%
%      projects the chemical onto a simpler representation s2. This is not
%      unique, there may be multiple formulas (isomers) that result in the
%      same string s2.
%
%   2. Starting with an atomic representation r1, the combination
%
%          s  = hillformula(r1)
%          r2 = parse_formula(s)
%
%      will return the same atomic representation.

% Author
%
%   Jeff Kantor
%   December 18, 2010

    assert(nargin > 0, 'hillfomula:input', ['No input. Expects a ', ...
    	'cell array of formulas or struct array of atoms.']);
    assert(nargin < 2, 'hillfomula:input', 'Unexpected extra inputs.');
     
    % Process function argument to produce a cell array of chemical
    % formulas and structure array of atomic representations.
    
    switch class(varargin{1})
        case 'char'                      % Single formula
            r = parse_formula(varargin);
        
        case 'cell'                      % Cell array of formulas
            r = parse_formula(varargin{1});
            
        case 'struct'                    % Structure array
            r = varargin{1};
            
        otherwise
            error('hillfomula:input',['requires cell array of chemical ',...
              'formulas or a structure array of atomic representations']);
    end
    
    % Use hillformula_ to perform calculations for each element of array r
    
    species = arrayfun(@hillformula_,r,'UniformOutput',false);

end


function str = hillformula_(r)

    % Put fields in alphabetical order

    atoms = sort(fields(r));
    
    % The fields of r is union set of atoms present in the various chemical
    % species. We obtain these fields and put them in Hill order.
    
    if ismember('C',atoms) && (r.C > 0)
        a = intersect({'C','H','D','T'},atoms);
        b = setdiff(atoms,{'C','H','D','T'});
        atoms = [a(:); b(:)];
    end
    
    % If Q is present, then Q always goes to the end of the line

    if ismember('Q',atoms) && (r.Q ~= 0)
        a = setdiff(atoms,{'Q'});
        atoms = [a(:); 'Q'];
    end
        
    str = '';
    
    for k = 1:length(atoms);
        switch atoms{k}
            case 'Q'
                if r.(atoms{k}) <= -2
                    str = strcat(str,num2str(r.(atoms{k})));
                elseif r.(atoms{k}) == -1
                    str = strcat(str,'-');
                elseif r.(atoms{k}) == 1
                    str = strcat(str,'+');
                elseif r.(atoms{k}) >= 2
                    str = strcat(str,'+',num2str(r.(atoms{k})));
                end
            otherwise
                if (r.(atoms{k}) > 0) && (r.(atoms{k}) ~= 1)  
                    str = strcat(str,atoms{k},num2str(r.(atoms{k})));
                elseif r.(atoms{k}) == 1
                    str = strcat(str,atoms{k});
                end
        end
    end
end