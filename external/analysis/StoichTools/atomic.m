function [A, atoms, species] = atomic(varargin)

% ATOMIC  Computes the atomic matrix for a given set of chemical species.
%
% SYNTAX
%
% [A,atoms,species] = atomic(species)
%
%   Returns the atomic matrix A for a set of chemical species. The input
%   species is a cell array of chemical formulas. If no output is indicated
%   then the atomic array is displayed.
%
% [A,atoms,species] = atomic(r)
%
%   Returns the atomic matrix A for a set of chemical species. The input r
%   is a structure array of atomic representations. If no output is
%   indicated then the atomic array is displayed.
%
%
% EXAMPLES
%
%   1. Create atomic matrix for methane and its combustion products.
%
%       >> A = atomic({'CH4','O2','CO2','H2O'});
%
%   2. Create a structure array and display the atomic matrix.
%
%       >> r = parse_formula({'CH4','O2','CO2','H2O'});
%       >> A = atomic(r);
% 
%   3. Display the atomic matrix for methane and its combutions products.
%
%       >> atomic({'CH4','O2','CO2','H2O'});
%
%      produces
%
%                  CH4       O2      CO2      H2O 
%          C:        1        0        1        0 
%          H:        4        0        0        2 
%          O:        0        2        2        1 
%
%   4. Display the atomic matrix for charged species
%
%       >> atomic({'H2O','H+','OH-','e-'})
%
%      produces
% 
%                  H2O       H+      OH-       e- 
%          H:        2        1        1        0 
%          O:        1        0        1        0 
%          Q:        0        1       -1       -1 
%
%
% USAGE NOTES
% 
%   1. The atomic matrix A is an M x N matrix where M is the number of
%      atomic species, N is the number of molecular speciesm, and A(i,j) is
%      the number of atoms of element i in species j. 
%
%   2. If charged species are present, then the last row of the atomic
%      matrix corresponds to charge 'Q'.  
%
%   3. The null space of A determines the number of independent reactions.
%

% AUTHOR
%
%   Jeff Kantor
%   December 18, 2010
    
    assert(nargin > 0, 'atomic:input', ['No input. Expects a cell ', ...
                        'array of formulas or structure array of atoms.']);
    assert(nargin < 2, 'atomic:input', 'Unexpected extra inputs.');
    
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
            error('atomic:input',['requires cell array of chemical ',...
              'formulas or a structure array of atomic representations']);
    end
    
    % Use the : operator to put species and r into a known shape. Since the
    % output is a matrix, we don't need to preserve the shape of species or
    % of r.
    
    species = species(:);
    r = r(:);
    
    % At this point r is a structure array of atomic representations, and
    % species is a cell array of chemical formulas

    % Get all of the atom species, and put in a row of a cell array

    atoms = fields(r);
    atoms = atoms(:)';
    
    % Electrons are removed from the atomic balance because they are not
    % are not necessarily conserved when balancing reactions. A separate
    % charge balance is used for balancing reactions
    
    atoms = setdiff(atoms,'e');
    
    % Put atoms in Hill order.  If carbon is present, then carbon and
    % hydrogen go to the front of the line.
    
    if ismember('C',atoms)
        s = {'C','H','D','T'};
        atoms = [intersect(s,atoms), setdiff(atoms,s)];
    end
    
    % Charge Q always goes to the end of the line.
    
    atoms = [setdiff(atoms,{'Q'}), intersect('Q',atoms)];
    
    % Construct atomic matrix
        
    N = length(species);
    M = length(atoms);
    A = zeros(M,N);
    for m = 1:M
        A(m,:) = [r(:).(atoms{m})];
    end
    
    % Display the atomic matrix if there are no output arguments

    if nargout == 0
        fprintf('\n    ');
        cellfun(@(s)fprintf('%8s ',s),species);
        fprintf('\n');
        for m = 1:M
            fprintf('%2s: ',atoms{m});
            arrayfun(@(s)fprintf('%8g ',s),A(m,:));
            fprintf('\n');
        end
    end

end