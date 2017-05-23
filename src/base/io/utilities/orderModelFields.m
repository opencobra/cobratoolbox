function orderedModel = orderModelFields(model)
%ORDERMODELFIELDS orders the fields in a model according to the field
%definitions. Required first, Optional following, Remaining fields in
%alphabetical order.
%INPUT
% model             a model structure in COBRA format
%
%OUTPUT
%
% orderedModel      a model with fields ordered according to the field
%                   definitions.
%

[fields] = getDefinedFieldProperties();

modelfields = fieldnames(model);
order = fields(ismember(fields(:,1),modelfields));
remainingOrder = sort(setdiff(modelfields,order));
overallOrder = [columnVector(order);columnVector(remainingOrder)];
orderedModel = orderfields(model,overallOrder);