function status = testXls2Model()
%tests the functionality of the xls2model function,

status = 1;
disp('** Testing xls2model **')
fprintf('\n')

% check whether the toy model xlsx file can be loaded without error
% if not: fail test

% the addReaction function will produce output in one of its last lines.
% can not be helped since this is a useful functionality outside of testing

try
	model = xls2model('cobra_import_toy_model.xlsx');
catch
	status = 0;
end

% maybe some more fancy testing here, later
if length(model.rxns) > 1 && length(model.mets) > 1,
	status = 1;
else
	status = 0;
end

if status,
	fprintf('\n')
	disp('** testXls2Model worked **')
	fprintf('\n')
else
    fprintf('\n')
	disp('** testXls2Model failed **')
	fprintf('\n')
end

end
