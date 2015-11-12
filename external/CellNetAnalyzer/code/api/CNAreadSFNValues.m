function [reacval,specval]=CNAreadSFNValues(cnap)
% CellNetAnalyzer API function 'CNAreadSFNValues'
%
% Usage: [reacval,specval]=CNAreadSFNValues(cnap)
%
% Given a signal-flow project that has been loaded with GUI (i.e. all
% signal-flow N- and P-fields must exist in cnap), this function returns
% the numerical values currently set in the text boxes of reactions (q x 1
% vector reacval) and species (n x 1 vector specval), respectively. If the
% text box of the i-th reaction does not contain a numerical value, then
% reacval(i)=NaN; the same is done for species. Nothing is changed in the
% project variable cnap; it is therefore not returned.

cnap=get_rates_inter(cnap);

reacval=NaN*ones(cnap.numr,1);
if(length(cnap.local.rb))
	reacval(cnap.local.rb(:,1))=cnap.local.rb(:,2);
end
specval=NaN*ones(cnap.nums,1);
if(length(cnap.local.metvals))
	specval(cnap.local.metvals(:,1))=cnap.local.metvals(:,2);
end




