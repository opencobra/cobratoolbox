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

[requiredFields,optionalFields] = getDefinedFieldProperties();

modelfields = fieldnames(model);
requiredOrder = requiredFields(ismember(requiredFields(:,1),modelfields));
optionalOrder = sort(intersect(optionalFields(:,1),modelfields));
remainingOrder = sort(setdiff(setdiff(modelfields,requiredOrder),optionalOrder));
overallOrder = [columnVector(requiredOrder);columnVector(optionalOrder);columnVector(remainingOrder)];
orderedModel = orderfields(model,overallOrder);