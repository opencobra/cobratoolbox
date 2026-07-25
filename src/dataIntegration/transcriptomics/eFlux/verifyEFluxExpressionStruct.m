function tf = verifyEFluxExpressionStruct(model, expression)
% Verify the expression struct structure for EFlux
%
% USAGE:
%    tf = verifyEFluxExpressionStruct(model,expression)
%
% INPUTS:
%    model:         The COBRA model struct for the checked expression struct, with field:
%
%                     * .genes - gene identifiers; all genes must be assigned when the targets are genes
%    expression:    The expression struct to verify, with fields:
%
%                     * .value - values for each target
%                     * .target - names of the targets (reactions or genes)
%                     * .preprocessed - whether targets are reactions (true) or genes (false)
%
% OUTPUT:
%    tf:            Whether this struct is valid or not.

tf = true;
if isfield(expression,'preprocessed') && ~expression.preprocessed
    % checkoptional field preprocessed
    % This leads to -1 for unassociated genes
    if ~isempty(setdiff(model.genes,expression.target))
        error('The following genes are lacking assignments:\n%s\nAll genes need to be assigned in order to use eFlux. You can remove genes by using the removeGenesFromModel function',strjoin(setdiff(model.genes,expression.target),'\n')); 
    end                
end
% check sizes of the value/target fields. They must be of equal size.
if size(expression.value,1) ~= numel(expression.target)
    error('The number of values in the expression struct does not fit the number of  targets in the expression struct');
end

end
