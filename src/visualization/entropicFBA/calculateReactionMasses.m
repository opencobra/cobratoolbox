function [substratesMass, productsMass] = calculateReactionMasses(model)
% This function calculates mass related to each reaction, products mass and
% substrates mass,using the left null space of stochiometric matrix,
% useful to unbiased flux through reactions with massive
% metabolites in entropicFBA

% Author: Samira Ranjbar 2024
%% % Check if metFormula field is provied in the model, if not add it using model0(Recon3DModel_301_xomics_input)

if ~isfield(model,'metFormulas')
    model0 = readCbModel('Recon3DModel_301_xomics_input.mat');
    % Loop through each entry in the first list
    for i = 1:numel(model.mets)      
        % Find the corresponding entry in the second list
        index = find(ismember(model0.mets, regexprep(model.mets{i}, ',(rec[12]|comm[12])\]$', ']')));
    
        % If a matching entry is found, update the formula
        if ~isempty(index)
            model.metFormulas{i,1} = model0.metFormulas{index};
        end
    end
    
    % Verify the validity of the updated model
    if verifyModel(model, 'simpleCheck', true)
        % Save the updated model
        % writeCbModel(model, 'updated_model.mat');
        disp('Model successfully updated and saved.');
    else
        disp('The updated model is not valid.');
    end
end
%% There is a wrong formula for this a metabolite in the generic model
model.metFormulas(findMetIDs(model,model.mets(contains(model.mets,'paps[')))) = {'C10H11N5O13P2S'};
% model.metFormulas(findMetIDs(model,'paps[c,rec2]')) = {'C10H11N5O13P2S'};
% model.metFormulas(findMetIDs(model,'paps[g,rec1]')) = {'C10H11N5O13P2S'};
% model.metFormulas(findMetIDs(model,'paps[g,rec2]')) = {'C10H11N5O13P2S'};
% model.metFormulas(findMetIDs(model,'paps[c]')) = {'C10H11N5O13P2S'};
% model.metFormulas(findMetIDs(model,'paps[g]')) = {'C10H11N5O13P2S'};
 
%% Calculate molecular weights using the computeMW function
metList = model.mets;
[molecularWeights, ~] = computeMW(model, metList);
% model = readCbModel('scRecon3D_2-1.mat')
% Get the number of consistent reactions in the model
numReactions = numel(model.rxns(model.SConsistentRxnBool));
sConsistent = model.S(model.SConsistentMetBool,model.SConsistentRxnBool);
rxnConsistent = model.rxns(model.SConsistentRxnBool);
% Initialize variables to store results
cf = cell(numReactions, 1); % Cell array for substrate mass results
cr = cell(numReactions, 1); % Cell array for product mass results


% Iterate through all reactions
for i = 1:numReactions
    % Get row indices and stoichiometric coefficients for the current reaction
    [rowIndices, ~, stoichiometry] = find(sConsistent(:, i));

    % Identify substrates and products
    substrates = model.mets(rowIndices(stoichiometry < 0));
    products = model.mets(rowIndices(stoichiometry > 0));

    % Calculate mass of substrates and products using molecular weights
    substrateCoefficients = stoichiometry(stoichiometry < 0);
    substrateMass = abs(substrateCoefficients) .* molecularWeights(ismember(metList, substrates));

    productMass = stoichiometry(stoichiometry > 0) .* molecularWeights(ismember(metList, products));

    % Store results in cf and cr
    cf{i} = struct('reaction', rxnConsistent{i}, 'substrates', substrates, 'mass', substrateMass);
    cr{i} = struct('reaction', rxnConsistent{i}, 'products', products, 'mass', productMass);
end
for i= 1:length(cf)
    Cf(i) = sum(cf{i}(1).mass);
    Cr(i) = sum(cr{i}(1).mass); 
end
CF = Cf';
CR = Cr';
%% Check if any mass imbalance happen
j=1;
indexmassimbalance =[];
for i = 1:length(CF)
    if( round(CF(i), 2)~= round(CR(i), 2) & ~isnan(CF(i)))
        indexmassimbalance(j) = i;
        j = j + 1;
    end
end
% if isempty(indexmassimbalance)
%     disp('All reactions that do not include an R-group are mass-balanced.');
% else
%     fprintf('%s is not mass-balance\n', cell2mat(model.rxns(indexmassimbalance)));
% end
if ~isempty(indexmassimbalance)
    
    dataTable = [];
    
    for a = indexmassimbalance%[95, 182, 384, 465, 3090, 3180, 3386, 3487, 4008]
        if isfield(model,'rxnFormulas')
            Formula = model.rxnFormulas(findRxnIDs(model, cf{a, 1}(1).reaction));
        else
            Formula = printRxnFormula(model, cf{a, 1}(1).reaction);
        end
        ForwardMass = sum(cf{a, 1}(1).mass);
        ReverseMass = sum(cr{a, 1}(1).mass);
    
        % Accumulate data
        dataRow = [a, Formula, ReverseMass, ForwardMass];
        dataTable = [dataTable; dataRow];
    end
    
    % Create a table after the loop
    variableNames = {'rxn number', 'Formula', 'Reverse Mass', 'Forward Mass'};
    resultTable = array2table(dataTable, 'VariableNames', variableNames);
    disp(resultTable);
else
    disp('All reactions that do not include an R-group are mass-balanced.')
end
%% linear programming using lsqnonneg method

N = model.S(model.SConsistentMetBool,model.SConsistentRxnBool);
A = N';
% Objective function: L2 regularization
objective = @(x) sum(x.^2);

% Nonlinear equality constraint: A*x = 0
nonlinearConstraint = @(x) A*x;

% Initial guess for x (make sure it satisfies A*x = 0 and x > 0)
x0 = ones(size(A, 2), 1);

% Non-negative least squares
x = lsqnonneg(A, zeros(size(A, 1), 1));

% Display the result
if(x >= 0)
    LeftNullSpace_nonzero = nnz(x)
    % figure('Renderer', 'painters', 'Position', [10 10 1600 800])
    % bar(x,'FaceColor', [1, 0, 0], 'FaceAlpha',0.5)
    % xlabel('met Index', FontSize=14, FontWeight='bold');
    % ylabel('Left null space value', FontSize=14, FontWeight='bold');
else
    disp('There is no strictly positive left- null space')
end
%% set undifined molecularweight to zero
for i = 1: length(molecularWeights)
    if isnan(molecularWeights(i))
        molecularWeights(i) = 0;
    end
end
T = table((1:length(x))', model.mets, model.metFormulas, molecularWeights, x, 'VariableNames',...
{'ID','met',	'met formula',	'molecular weigth',	'left null space'});
[~, idx] = sortrows(T, {'molecular weigth', 'left null space'}, {'ascend', 'ascend'});
sortedTable = T(idx, :);
var4Values = sortedTable.("molecular weigth");
var5Values = sortedTable.("left null space");

nonzeroIndices = find(var4Values ~= 0);
%% Removing metabolites that contain R-group
y = var4Values(nonzeroIndices(1):end);
x = var5Values(nonzeroIndices(1):end);

%% Detect and remove outliers using IQR method
x_std = std(x);
y_std = std(y);

x_median = median(x);
y_median = median(y);

% Define a threshold for outliers (e.g., 7 times the standard deviation)
threshold = 7;

% Find indices of outliers
outliers_x = find(abs(x - x_median) > threshold * x_std);
outliers_y = find(abs(y - y_median) > threshold * y_std);

% Combine outlier indices
outliers_indices = unique([outliers_x; outliers_y]);

% Remove outliers from the data
x_no_outliers = x;
y_no_outliers = y;
x_no_outliers(outliers_indices) = [];
y_no_outliers(outliers_indices) = [];

% Perform polynomial regression on data without outliers
degree = 1; % Adjust the degree of the polynomial as needed
coefficients_poly = polyfit(x_no_outliers, y_no_outliers, degree);

% Evaluate the polynomial at various x values for plotting
x_fit_poly = linspace(min(x_no_outliers), max(x_no_outliers), 100);
y_fit_poly = polyval(coefficients_poly, x_fit_poly);

%% Plot the original data and the fitted polynomial
figure('Renderer', 'painters', 'Position', [10 10 1600 800])
plot(x, y, 'o', 'DisplayName', 'Original Data');
hold on;

% Plot the data without outliers
plot(x_no_outliers, y_no_outliers, 'x', 'DisplayName', 'Data without Outliers');

% Plot the fitted polynomial
plot(x_fit_poly, y_fit_poly, '-', 'DisplayName', 'Fitted Line');
hold off
legend('Location', 'Best');
xlabel('left null-space');
ylabel('molecularWeights');
title('Polynomial Regression');

%% Display the coefficients
% Construct the polynomial equation as a string
degree = length(coefficients_poly) - 1;
equation_str = 'y = ';
for i = degree:-1:1
    equation_str = [equation_str num2str(coefficients_poly(degree - i + 1)) ' * x^' num2str(i) ' + '];
end
equation_str = [equation_str num2str(coefficients_poly(end))];

% Display the polynomial equation
disp('Fitted Polynomial Equation:');
disp(equation_str);

for i = 1:nonzeroIndices(1)-1
     var4Values(i) =  coefficients_poly(1) * var5Values(i) + coefficients_poly(2);
end
sortedTable.("molecular weigth") = var4Values;
ST=sortrows(sortedTable, {'ID'}, {'ascend'});
%% calculate mass again for metabolite contain R-group using left null space
molecularWeights = ST.("molecular weigth");
for i = 1:numReactions
    % Get row indices and stoichiometric coefficients for the current reaction
    [rowIndices, ~, stoichiometry] = find(sConsistent(:, i));

    % Identify substrates and products
    substrates = model.mets(rowIndices(stoichiometry < 0));
    products = model.mets(rowIndices(stoichiometry > 0));

    % Calculate mass of substrates and products using molecular weights
    substrateCoefficients = stoichiometry(stoichiometry < 0);
    substrateMass = abs(substrateCoefficients) .* molecularWeights(ismember(metList, substrates));

    productMass = stoichiometry(stoichiometry > 0) .* molecularWeights(ismember(metList, products));

    % Store results in cf and cr
    cf{i} = struct('reaction', rxnConsistent{i}, 'substrates', substrates, 'mass', substrateMass);
    cr{i} = struct('reaction', rxnConsistent{i}, 'products', products, 'mass', productMass);
end
for i= 1:length(cf)
    Cf(i) = sum(cf{i}(1).mass);
    Cr(i) = sum(cr{i}(1).mass); 
end
CF = Cf';
CR = Cr';
substratesMass = CF;
productsMass = CR;