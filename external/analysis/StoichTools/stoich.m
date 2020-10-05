function V = stoich(varargin)

% STOICH  Computes a stoichiometric matrix for a set of chemical species.
%
% SYNTAX
%
% V = stoich(species)
% V = stoich(r)
%
%   Returns the stoichiometric matrix V for a collection set of chemical
%   species. The speciies may be specified as a cell array of chemical
%   formulas, or as a structure array of atomic representations. The
%   output V is an N x K matrix where each column corresponds to an
%   independent reaction among N chemical species. The stoichiometric
%   coefficient is negative for a reactant, and postive for a reaction
%   product.
%
% stoich(species)
% stoick(r)
%
%   Computes the stoichiometric matrix and displays the resulting
%   reactions.
%
% 
% EXAMPLES
% 
%   1. Combustion products of methane
%
%       >> V = stoich({'CH4','O2','CO2','H2O'});
%
%      produces
%
%          V =
%             -1
%             -2
%              1
%              2
%
%   2. Calling stoich without an output argument displays the reaction.
%
%       >> stoich({'CH4','O2','CO2','H2O'});
%
%      produces
%
%          CH4 + 2 O2  <=> CO2 + 2 H2O 
%
%   3. Case of multiple independent reactions
%
%       >> stoich({'CH4','O2','CO','CO2','H2O'})
%
%      produces
%
%          CH4 + 3 CO2  <=> 4 CO + 2 H2O 
%          O2 + 2 CO  <=> 2 CO2 
% 
%          ans =
%              -1     0
%               0    -1
%               4    -2
%              -3     2
%               2     0
%
%   4. Case of no possible reactions
%
%       >> stoich({'CH4','O2','CO2'})
%
%      produces
%
%          No reactions to display.
% 
%          ans =
%             Empty matrix: 3-by-0
%
%
% USAGE NOTES
%
%   1. The stoichometric matrix satisfies the relationship A*V = 0
%      where A is the atomic matrix. V is N x K where N is the number of
%      species, and K is the number of independent reactions.
%
%   2. stoich creates a rational approximation to the stoichiometric matrix
%      that does a reasonable job of scaling the stoichiometric
%      coefficients. Any scaling V*diag(D) where D is an K element vector
%      of scaling coefficients is also a valid stoichiometric matrix.
%

% AUTHOR
%
%   Jeff Kantor'
%   December 18, 2010


    assert(nargin > 0, 'stoich:input', ['No input. Expects a cell ', ...
                        'array of formulas or struct array of atoms.']);
    assert(nargin < 2, 'stoich:input', 'Unexpected extra inputs.');
    
    % Process function argument to produce a cell array of chemical
    % formulas and structure array of atomic representations.
    
    switch class(varargin{1})
        case 'char'                      % Single formula
            species = varargin;
            r = parse_formula(species);
        
        case 'cell'                      % Cell array of formulas
            species = varargin{1};
            r = parse_formula(species);
            
        case 'struct'                    % Structure array
            r = varargin{1};
            species = hillformula(r);
            
        otherwise
            error('stoich:input',['requires cell array of chemical ',...
              'formulas or a structure array of atomic representations']);
    end
    
    % Compute the stoichiometric matrix by finding the null space of the
    % atomic matrix.
    
    A = atomic(r);
    V = -rref(null(A)')';
    
    % Create a rational approximation to the stoichiometric matrix. This
    % generally does a good job of scaling the stoichiometric coefficients
    % to meaningful values.
    
    [num,den] = rat(V);
    V = num./den;
    
    % Display the reactions if there is no other output.

    if nargout == 0
        disp_reaction(V,species);
    end

end

