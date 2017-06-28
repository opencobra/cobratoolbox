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
orderedModel = orderfields(model,overallOrder);
