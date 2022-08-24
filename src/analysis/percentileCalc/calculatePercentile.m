function value = calculatePercentile(expressionValues, k)
% Calculates and returns the numeric value of a given percentile based on
% the expression value array
%
% USAGE:
%
%   value = calculatePercentile(expressionValues, k)
%
% INPUTS:
%   expressionValues:       double cell array
%   k:                      double
%
% OUTPUTS:
%	value:                  double
%
% .. Authors:
%       - Kristina Grausa 05/16/2022
%       - Kristina Grausa 08/22/2022 - standard header and formatting

    if ~isnan(k)
        C = unique(expressionValues,'sorted');
        n = length(C);
        Lp =  (n+1) * (k/100); % Position Locator
        if round(Lp) == Lp
            value = C(Lp);
        else
            value = round(C(floor(Lp)) + (Lp-floor(Lp)) * (C(ceil(Lp))-C(floor(Lp))));
        end
    else 
        value = k;
    end
end
