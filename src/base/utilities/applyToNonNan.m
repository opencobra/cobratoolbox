function result = applyToNonNan(data,func)
% Apply the given function columnwise to all non NaN values in the given
% data.
%
% USAGE:
%
%    result = applyToNonNan(data,func)
%
% INPUTS:
%    data:          Matrix of data (individuals x variables)
%    func:          function handle that takes an vector of data and
%                   computes single value result.
%
% OUTPUTS:
%
%    result:        A Vector of with dimensions (size(data,2) x 1) where
%                   the supplied function was applied to all columns
%                   ignoring NaN values.

result = zeros(1,size(data,2));

for i = 1:size(data,2)
    result(i) = func(data(~isnan(data(:,i)),i));
end