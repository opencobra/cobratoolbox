function [reacval,macroval]=CNAreadMFNValues(cnap)
% CellNetAnalyzer API function 'CNAreadMFNValues'
%
% Usage: [reacval,macroval]=CNAreadMFNValues(cnap)
%
% Given a mass-flow project that has been loaded with GUI (i.e. all N- and
% P-fields must exist in cnap), this function returns the numerical values
% currently set in the text boxes of reactions (q x 1 vector reacval) and
% macromolecules (m x 1 vector macroval), respectively. If the text box of
% the i-th reaction does not contain a numerical value, then
% reacval(i)=NaN. Nothing is changed in the project variable cnap; it is
% therefore not returned.

cnap= get_rates(cnap);
reacval=NaN*ones(cnap.numr,1);
if(length(cnap.local.rb))
	reacval(cnap.local.rb(:,1))=cnap.local.rb(:,2);
end
macroval=cnap.local.c_makro;
