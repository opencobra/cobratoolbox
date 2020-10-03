function Vout = disp_reaction(V,species)

% DISP_REACTION  Displays reactions for a given stoichiometric matrix.
%
% SYNTAX
%
% disp_reaction(V,species)
%
%   Displays the reactions corresponding given by the stoichiometric matrix
%   V. The columns of V correspond to reactions, the rows of V correspond
%   to species. species is a cell array of strings with labels for the
%   chemical species. Note that species is not parsed, so that labels can
%   need not be valid chemical formulas.
%
% Vout = disp_reaction(V,species)
% Vout = disp_reaction(V)
%   
%   When called with an output argument, disp_reaction attempts to produce
%   integer coefficients for the stoichiometric matrix. The goal is to
%   express the coefficients efficiently. No reactions are displayed.
%

% AUTHOR
%
%    Jeff Kantor
%    December 19, 2010


    assert(nargin > 0, 'disp_reaction:input', ['No input. Expects a ', ...
                        'stoichiometric matrix.']);
    assert(nargin < 3, 'atomdisp_reactionic:input', 'Unexpected  inputs.');
    
    % Get size of the stoichiometric matrix. N is number of species, K is
    % number of reactions

    [N,K] = size(V);
    
    % Return if there are no species or no reactions to display.
    
    if ~isnumeric(V) || (N==0) || (K==0)
        disp('No reactions to display.');
        return
    end
    
    % Create generic species labels if no species are provided. Otherwise
    % check the list of species for obvious errors.
    
    if nargin < 2
        species = arrayfun(@(n)sprintf('Species_%d',n),1:N,'Uni',false);
    else
        assert(iscellstr(species), 'disp_reaction:input', ...
            'List of species must be a cell array.');
        assert(length(species(:)) == N, 'disp_reaction:input', ...
            'Number of species must equal rows of stoichiometry matrix.');
    end
    
    species = species(:);

    % The first step is to see if there is a better format for the
    % stoichiometric coefficients. We have 3 options for formatting the
    % stoichiometric coefficients: integer, rational, or floating point. We
    % form all three formats then choose a format for each reaction that
    % minimizes the display length.
    
    % Compute rational number approximation for the stoichiometric
    % coefficients.
    
    [num,den] = rat(V);
    
    % Find least common multiples of the denominators in each reaction. The
    % create output stoichiometric matrix with integer coefficients.

    Vout = zeros(N,K);
    for k = 1:K
        Vout(:,k) = num(:,k)*lcms(den(:,k))./den(:,k);
    end
    
    % Arrays to hold string representations of the stoichiometric
    % coefficients.
    
    Vs = cell(N,K);
    lens = zeros(1,K);
    
    Vf{N,K} = cell(N,K);
    lenf = zeros(1,K);
    
    Vr{N,K} = cell(N,K);
    lenr = zeros(1,K);
   
    % Smallest meaningful stoichiometric coefficient
    
    TOL = 1e-6;
    
    for k = 1:K
        for n = 1:N
            if abs(V(n,k)) >= TOL
               
                % Integer Coefficients
                
                Vs{n,k} = strtrim(sprintf('%d',abs(Vout(n,k))));

                if strcmp(Vs{n,k},'1')
                    Vs{n,k} = '';
                else
                    lens(k) = lens(k) + 1 + length(Vs{n,k});
                end
                
                % Rational Coefficients

                if (den(n,k) == 1) && (num(n,k) == 1);
                    Vr{n,k} = '';
                elseif (den(n,k) == 1)
                    Vr{n,k} = strtrim(sprintf('%d',abs(num(n,k))));
                    lenr(k) = lenr(k) + 1 + length(Vr{n,k});
                else
                    Vr{n,k} = strtrim(sprintf('%d/%d',abs(num(n,k)),den(n,k)));
                    lenr(k) = lenr(k) + 1 + length(Vr{n,k});
                end 
                                
                % Floating Point Coefficients
                
                Vf{n,k} = strtrim(sprintf('%10.5g',abs(V(n,k))));
                if strcmp(Vf{n,k},'1')
                    Vf{n,k} = '';
                else
                    lenf(k) = lenf(k) + 1 + length(Vf{n,k});
                end
                
            end
        end
        
        % Pick the best representation
        
        if (lenf(k) < lenr(k)) && (lenr(k) < lens(k))
            Vs(:,k) = Vf(:,k);
            lens(k) = lenf(k);
            Vout(:,k) = V(:,k);
            
        elseif (lenr(k) < lens(k))
            Vs(:,k) = Vr(:,k);
            lens(k) = lenr(k);
            Vout(:,k) = n(:,k)./den(:,k);
            
        end
             
    end
    
    % If there is no output then display the reactions
    
    if nargout < 1
        fprintf('\n');
        for k = 1:K
            
            pos = 1;
            
            % Print Reaction LHS -- Reactants
            
            n = find(V(:,k) < -TOL);
            pos = fprintrxn(strtrim(strcat(Vs(n,k),{' '},species(n))),pos);
            
            % Print separator
            
            if pos > 40
                fprintf('\n  <=> ');
                pos = 7;
            else
                fprintf(' <=> ');
                pos = pos + 5;
            end
            
            % Print Reaction RHS -- Products
            
            n = find(V(:,k) > TOL);
            fprintrxn(strtrim(strcat(Vs(n,k),{' '},species(n))),pos);

            fprintf('\n');
            
        end
        fprintf('\n'); 
    end 
    
end


function q = lcms(v)

% LCMS  Find the least common multiple of a set of numbers.

    v = v(:);
    q = v(1);
    for k = 2:length(v)
        q = lcm(q,v(k));
    end
end


function pos = fprintrxn(terms,pos)

% FPRINTRXN  Helper function for displaying reactions.
%
% SYNTAX
%
% pos = fprintrxn(terms,pos)
%
%   Prints the reaction terms in the cell array terms separated by ' + '
%   starting at position pos. Breaks into multple lines if necessary.
%   Returns the position of the next character to be printed.

    % Print first term
    
    fprintf('%s',terms{1});
    pos = pos + length(terms{1});
    
    % Print remaining terms
    
    for m = 2:length(terms)
        
        % See where line would end
        
        tlen = 3 + length(terms{m});
        
        if (pos + tlen) <= 70
            
            fprintf(' + %s',terms{m});
            pos = pos + tlen;
            
        else % need a new line
            
            fprintf('\n   + %s',terms{m});
            pos = tlen + 2;
            
        end
    end
end
