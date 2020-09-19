function r = parse_formula(varargin)

% PARSE_FORMULA Parses a chemical formula to form an atomic representation.
%
% SYNTAX
%
% r = parse_formula(str)
% r = parse_formula({str1,str2,str3, ...})
%
%   Parses chemical formulas and returns a structure array holding the an
%   atomic representation of the chemical forulas. The input is a string or
%   a cell array of strings.
%
%
% EXAMPLES
% 
%   1. Chemical formulas of varying complexity
% 
%       parse_formula('H2O');            % Water
%       parse_formula('NaHCO3');         % Sodium Bicarbonate
%       parse_formula('(CH4)8(H2O)46');  % Methane Clathrate
%       parse_formula('CH3COOCH2CH3');   % Ethyl Acetate
%       parse_formula('MnO4-');          % Negative Charge Ion
%
%       parse_formula('dCH4');           % Returns error message
%
%   2. Create an structure array of atomic representations for a set of
%      compounds
%
%       r = parse_formula({'CH4','O2','CO2','H2O'});
%
%
% USAGE NOTES
%
%   1. Formulas are made of up of sequences of elements followed by
%      integers  indicating the number of included atoms. Omitted integers
%      are assumed to be one.
%
%   2. Elements are the conventional one or two character abbreviations.
%      The character is captialized. If present, the second character is
%      lower case. In addition to the standard elements, the parser allows
%      for
%
%       Symbol  Entity                 Interpretation
%          e    electron               like an element with MW = 0
%          D    deuterium              an element
%          T    tritium                an element
%          M    any metal              like an element, mw = NaN
%          X    any halogen            like an element, mw = NaN
%          Me   methyl group (CH3)     CH3 substituted for Me
%          Et   ethyl group (C2H5)     C2H5 substituted for Et
%          Bu   butyl group (C4H9)     C4H9 substituted for Bu
%          Ph   phenol group (C6H5)    C6H5 substituted for Ph
%
%   3. Subgroups may be included between parenthesis or brackets followed
%      by an integer indicating number of repetitions. Two levels of
%      subgrouping are allowed.
%
%   4. A terminal lower case suffix denoting phases will be correctly
%      parsed. The phase must be one of (aq), (l), (g), or (s).
%
%   5. The charge on an ionic species is appended as a + or - followed by
%      an optional integer.  Examples are H+, OH-, or Ca+2.
%
%   6. The bare electron e- is used in balancing chemical half reactions.
%
%   7. Error messages are generated for invalid fomulas
%
%   8. str can be a cell array of chemical formula. The results is a
%      structure array. The elements of the output structure array are in
%      one-to-one correspondence with elements of the cell array. For
%      example
%
%          r = parse_formula({'CH4','CH3OH','CHOOH'})
%
%      r(1) holds the atomic formula for CH4, r(2) for CH3OH, and r(3) for
%      CHOOH.

% AUTHOR
%
%   Jeff Kantor
%   December 18, 2010


    assert(nargin > 0, 'parse_formula:input', ['No input. Expects a  ', ...
                        'string or cell array of chemical formulas.']);
    assert(nargin < 2, 'stoich:input', 'Unexpected extra inputs.');
    
    switch class(varargin{1})
        case 'char'                      % Single formula
            str = varargin;
        
        case 'cell'                      % Cell array of formulas
            str = varargin{1};
            
        otherwise
            error('parse_formula:input',['requires cell array of  ',...
              'chemical formulas.']);
    end
    
    assert(iscellstr(str), 'parse_formula:input', ...
        'Formulas must be strings.');
    
    % Trim any whitespace at front or back
    
    str = strtrim(str);
    
    % Remove phase information. This information is currently neglected. In
    % a later version we may wish to incorporate phase into a more complete
    % data structure for representing chemical formula.
    
    prex = '|\((aq|g|l|s)\)$';
    str = regexprep(str,prex,'');
    
    % Substitute for some common chemical abbreviations
    
    str = regexprep(str,'Bu','C4H9');    % Butyl
    str = regexprep(str,'Et','C2H5');    % Ethyl
    str = regexprep(str,'Me','CH3');     % Methyl
    str = regexprep(str,'Ph','C6H5');    % Phenol

    % Apply the main parser to every element of str

    q = cellfun(@(s)parse_formula_(s,3),str,'Uniform',false);

    % Union of all atomic species

    atoms = {};
    for i = 1:length(q(:))
        atoms = union(atoms, fields(q{i}));
    end
    
    % Add all atomic species to all structures.

    for i = 1:length(q(:))
        for j = 1:length(atoms)
            if ~ismember(atoms{j},fields(q{i}))
                q{i}.(atoms{j}) = 0;
            end
        end
    end

    % Form the structure array to have the same shape as str
    
    r = reshape([q{:}],size(str));
   
end % parse_formula


function r = parse_formula_(str,kdepth)

    assert(kdepth > 0, 'parse_formula_:Recursion', ...
        'Reached maximum recursion depth');

    r = struct([]);
    
    % Regular expression returning tokens for element and number
    % sexpr matches single elements followed by a digit, or a +/-
    % followed by a digit to denote charge
    
    persistent srex;  % Regexp pattern to match elements and charges
    persistent grex;  % Regexp pattern to match groups
    
    if isempty(srex) || isempty(grex)
        srex = ['(A[lrsgutcm]|B[eraik]?|C[laroudsemf]?|D[y]?|E[urs]|', ...
                'F[erm]?|G[aed]|H[eofgas]?|I[nr]?|Kr?|L[iaur]|', ...
                'M[gnodt]?|N[eaibdpos]?|Os?|P[drmtboau]?|R[buhenaf]|', ...
                'S[icernbmg]?|T[icebmalh]?|U|V|W|X[e]?|Yb?|Z[nr])', ...
                '(\d*\.\d+|\d*)', ...
                '|(e|+|-)(\d*)'];
        grex = '|\(([^\)]*)\)(\d*\.\d+|\d*)|\[([^\]]*)\](\d*\.\d+|\d*)';
    end

    % Parse formula for chemical groups. This picks out anything that looks
    % an element followed by a number, or a subgroup within parentheses.
    % The tokens are returned in the cell array u. Each u{k} has two
    % elements, the first is a string denoting the group, and the second is
    % number string of repetitions.

    [u,s,e] = regexp(str,[srex,grex],'tokens','start','end');

    % Report any parsing errors. A parse error occurs if there are any
    % characters not matched as tokens. We scan the start and end positions
    % of the tokens to determine if there are any gaps.

    g(1:length(str)) = '^';
    for i = 1:length(s);
        g(s(i):e(i)) = ' ';
    end
    
    assert(all(g ~= '^'), 'parse_formula:ParseError', ...
        'Could not parse formula:\n    %s\n    %s\n', str, char(g));
    
    % Extract atom tokens from the first part of each token
    
    tok = cellfun(@(v)v{1},u,'Uni',false);

    % Extract counts from the second part of each token, convert to
    % doubles, empty counts set to 1
    
    cnt = cellfun(@(v)v{2},u,'Uni',false);
    cnt = str2double(cnt);
    cnt(isnan(cnt)) = 1;
    
    % Loop over tokens

    for j = 1:length(u)

        % See if token matches an element

        if strcmp(tok{j},regexp(tok{j},srex,'match'))

            % The token exactly matches an element.
            % Change + or - tokens to 'Q'.
            
            tok{j} = regexprep(tok{j},'+','Q');

            if strcmp(tok{j}, '-')
                tok{j} = 'Q';
                cnt(j) = -cnt(j);
            end

            % Update atomic representation, adding a field if needed.

            if isfield(r,tok{j})
                r.(tok{j}) = r.(tok{j}) + cnt(j);
            else
                r(1).(tok{j}) = cnt(j);
            end

        else 

            % The token must be a group, so do a recursion to find
            % an atomic represenation of the group.

            q = parse_formula_(tok{j},kdepth-1);

            % Updatethe  atomic representation to include the group.
            % Add fields if needed. Multiply by number of groups in the
            % formula we're parsing.

            f = fields(q);

            for k = 1:length(f)

                if isfield(r,f{k})
                    r.(f{k}) = r.(f{k}) + cnt(j)*q.(f{k});
                else
                    r(1).(f{k}) = cnt(j)*q.(f{k});
                end

            end
        end
    end
        
end % parse_formula_





