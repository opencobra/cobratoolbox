function model = createToyModelWDE()
    % creates toy model with contraints:
    % (1) -1e6*v2 + v3 < 0,   with 2 flux variables and bad scaled
    %                         coefficient.
    % (2) v1 -v2 -v3 < 0,     with more than 2 flux variables.
    % (3) v2 -v3 < 0,         with 2 flux variables and no bad scaled
    %                         coefficient.
    % (4) -1e6*v1 + u1 = 0,   with 2 variables (1 flux variable + 1 extra
    %                         variable), and a badscaled coefficient.
    % (5) u1 + u2 -upool < 0, with more that 2 variables (all extra
    %                         variables), and no bad scaled coefficient.
    % (6) -v3 + u2 = 0,       with 2 variables (1 flux variable + 1 extra
    %                         variable), and no bad coeficient.
    % (7) -v1 -1e6*v2 + u2 < 0, with more than 2 variables
    %                           (flux and extra variables).
    model.S = [1, -1, -1]; % v1 = V2 + v3
    model.rxns = {'v1'; 'v2'; 'v3'};
    model.mets = {'met1'};
    model.csense = 'E';
    model.b = 0;
    model.c = [0; 0; 0]; % fluxes of reactions using enzymes in GECKO-style models is positive (no irreversible rxns)
    model.lb = zeros(3, 1);
    model.ub = 10*ones(numel(model.rxns), 1);
    model.osense = 1; % minimize
    % constraint with 2 flux variables and bad scaled coefficient
    % selected by liftRows for lifting and lifted:
    % -1e6v2 + v3 < 0
    C1 = [0 -1e6 1]; 
    D1 = [0 0 0];
    % constraint with more than 2 flux variables 
    % not selected for lifting by liftRows (only constraints with 2 flux
    % variables are processed by liftRows):
    % v1 -v2 -v3 < 0
    C2 = [1 -1 -1]; 
    D2 = [0 0 0];
    % constraint with 2 flux variables and no bad scaled coefficient
    % selected for lifting by liftRows but not lifted (only constraints
    % with bad scalled coefficients are lifted):
    % v2 - v3 < 0
    C3 = [0 1 -1];
    D3 = [0 0 0];
    % constraint with 2 variables (1 flux variable + 1 extra variable), and a
    % badscaled coefficient.
    % selected for lifting by liftRows and lifted:
    % -1e6v1 + u1 = 0
    C4 = [-1e6 0 0]; 
    D4 = [1 0 0];
    % constraint with more that 2 variables (all extra variables), and no
    % bad scaled coefficient.
    % not selected for lifting by liftRows.
    % this constraint is equivalent to sum of all enzyme usage variables in GECKO:
    % u1 + u2 - u3 = 0
    C5 = [0 0 0];
    D5 = [1 1 -1];
    % constraint with 2 variables (1 flux variable +1 extra variable), and
    % no bad coeficient.
    % selected by liftRows but not lifted:
    % -v3 + u2 = 0 
    C6 = [0 0 -1];
    D6 = [0 1 0];
    % constraint with more than 2 variables (2 flux variables + 1 extra
    % variable), and a bad scaled coefficient.
    % split into constraints of two variables each, selected by liftRows and lifted. 
    % this constraint is equivalent to the same enzyme being used by more than one reaction in GECKO:
    % -v1 -1e6v2 + u2 < 0
    C7 = [-1 -1e6 0];
    D7 = [0 1 0];
    
    model.C = [C1; C2; C3; C4; C5; C6; C7];
    model.D = [D1; D2; D3; D4; D5; D6; D7];
    model.ctrs = {'flxVarOnly_2beLifted'; 'flxVarOnly_Not2beSelected'; 'flxVarOnly_2beSelected'; 'FlxExtrVar_2beLifted'; 'ExtrVarOnly_sumflux'; 'FlxExtrVar_2beSelected'; 'FlxExtrVar_2beSplitAndLifted'};
    model.ctrNames = model.ctrs;
    model.d = zeros(numel(model.ctrs), 1);
    model.dsense = [repmat('L', 3, 1); 'E'; repmat('L', 3, 1)];
    model.evars = {'u1'; 'u2'; 'upool'};
    model.evarNames = model.evars;
    model.evarc = [0; 0; 1]; % minimize the enzyme pool
    model.evarlb = zeros(numel(model.evars), 1); % enzyme concentration cannot be negative
    model.evarub = [1e9; 1e3; 1e3];
    model.E = zeros(size(model.S, 1), numel(model.evars));
end
