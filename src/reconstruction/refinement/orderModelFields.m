function orderedModel = orderModelFields(model)
% Orders the fields in a model according to the field
% definitions. Defined first, Remaining fields in
% alphabetical order.
%
% USAGE:
%
%    orderedModel = orderModelFields(model)
%
% INPUT:
%    model:           a model structure in COBRA format
%
% OUTPUT:
%    orderedModel:    a model with fields ordered according to the field definitions.
%
% .. Author: - Thomas Pfau May 2017


[fields] = getDefinedFieldProperties();

modelfields = fieldnames(model);
order = fields(ismember(fields(:,1),modelfields));
remainingOrder = sort(setdiff(modelfields,order));
overallOrder = [columnVector(order);columnVector(remainingOrder)];

% SNEW = ORDERFIELDS(S1, C) orders the fields in S1 so the new structure
% array SNEW has field names in the same order as that in the array of
% field names in C. S1 and C must have the same field names.
orderedModel = orderfields(model,overallOrder);
