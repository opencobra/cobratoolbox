function coupledRxnReport = printCouplingConstraints(model, printLevel)
% Print all reaction flux coupling constraints
%
% USAGE:
%
%    printConstraints(model)
%
% INPUTS:
%    model:       COBRA model structure
%    printLevel:  Printing the constraints: rxn1 + rxn2 + rxn3 - rxn4 >= d
%                 if printLevel>0, and the formula for the reactions if
%                 printLevel>1 (Default = 0).

if nargin < 2 || isempty(printLevel)
    printLevel = 0;
end

if isfield(model,'C')
    if ~isfield(model,'ctrs')
        model.ctrs = cell(size(model.C, 1),1);
    end
    c = 0;
    % Identify the coupledRxnID and constraint added
    if printLevel > 0
        for i = 1:size(model.C, 1)
            
            % Obtain constraint data
            c = c + 1;
            rxns = model.rxns(find(model.C(i, :)));
            coefficients = full(model.C(i, find(model.C(i, :))));% Make the formula
            constraints = [];
            for j = 1:length(rxns)
                if coefficients(j) < 0 && j == 1
                    constraints = [constraints '- ' rxns{j}];
                elseif coefficients(j) > 0  && j == 1
                    constraints = [constraints rxns{j}];
                else
                    if coefficients(j) < 0
                        constraints = [constraints ' - ' rxns{j}];
                    else
                        constraints = [constraints ' + ' rxns{j}];
                    end
                end
            end
            switch model.dsense(i)
                case 'G'
                    constraints = [constraints ' >= ' num2str(model.d(i))];
                case 'L'
                    constraints = [constraints ' <= ' num2str(model.d(i))];
                case 'E'
                    constraints = [constraints ' = ' num2str(model.d(i))];
            end
            % Add information
            coupledRxnReport.coupledRxnId{c, 1} = model.ctrs{i};
            coupledRxnReport.constraints{c, 1} = constraints;
            
            % Identify the rxnID and formula
            if printLevel > 1
                
                [coupledRxnReport.rxnId{c, 1}, coupledRxnReport.formula{c, 1}] = deal('');
                
                for j = 1:size(rxns, 1)
                    
                    c = c + 1;
                    coupledRxnReport.coupledRxnId{c, 1} = '';
                    coupledRxnReport.constraints{c, 1} = '';
                    coupledRxnReport.rxnId{c, 1} = rxns{j};
                    coupledRxnReport.formula(c, 1) = printRxnFormula(model,'rxnAbbrList', rxns{j}, 'printFlag', false);
                    
                end
            end
        end
        
        % Make a table
        coupledRxnReport = struct2table(coupledRxnReport);
    end
else
    coupledRxnReport =[];
end

if printLevel > 0
    disp(coupledRxnReport)
end