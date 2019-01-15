function epsilon = calculateEPSILON(samples, rxnFBS, varargin)
% Calculate the minimum required flux change (epsilon) for reactions to be
% considered as significantly changed with p-value of 0.05
% The code below is based on the method presented in:
%    Yizhak, K., Gabay, O., Cohen, H., & Ruppin, E. (2013). Model-based
%    identification of drug targets that revert disrupted metabolism and
%    its application to ageing. Nature communications, 4, 2632.
%
% USAGE:
%
%    epsilon = calculateEPSILON(samples, rxnFBS, 'unique_epsilon', false, 'minimum', 1e-3)
%
% INPUT:
%    samples:           Matrix of sampled fluxes.
%    rxnFBS:            Array that contains the desired change: Forward,
%                       Backward and Unchanged (+1;0;-1). This is calculated
%                       from the rules and differential expression analysis.
%
% OPTIONAL INPUTS:
%    varargin:  `ParameterName` value pairs with the following options:
%
%                - `unique_epsilon`: True = unique epsilon, False = each reaction has different epsilon (default=false)
%                - `minimum`: Minimun value for epsilon requiered (default=1e-3)
%
% OUTPUT:
%    epsilon:           Numeric value or array with the epsilon for the different reactions
%
% .. Authors:
%       - Luis V. Valcarcel, 06/07/2015, University of Navarra, CIMA & TECNUN School of Engineering.
%       - Luis V. Valcarcel, 26/10/2018, University of Navarra, CIMA & TECNUN School of Engineering.
%       - Francisco J. Planes, 26/10/2018, University of Navarra, TECNUN School of Engineering.

p = inputParser; % check the input parameters
addRequired(p, 'samples', @isnumeric);
addRequired(p, 'rxnFBS', @isnumeric);
p.CaseSensitive = false;
addParameter(p, 'unique_epsilon', false);
addParameter(p, 'minimum', 1e-3, @(x)isnumeric(x)&&isscalar(x));
parse(p, samples, rxnFBS, varargin{:});

% initialize array with epsilons for each reaction
n = size(samples,2);
epsilon = tinv(0.95,n-1) * std(samples,0,2) / sqrt(n);
epsilon(rxnFBS==0) = 0;

% if unique, we calculate the unique epsilon
if p.Results.unique_epsilon
    %Threshold, we take epsilon so 70% of the reactions are differentially expressed
    th = 0.7;
    epsilon = sort(epsilon(rxnFBS~=0));
    epsilon = epsilon(int64(length(epsilon)*th));
    % transform to one vector
    epsilon = ones(size(rxnFBS))*epsilon;
    epsilon(rxnFBS==0) = 0;
else
    epsilon(epsilon < p.Results.minimum) = p.Results.minimum;
    epsilon(rxnFBS==0) = 0;
end

end

