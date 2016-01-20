function cnap= CNAwriteSFNValues(cnap,reacval,reaccol,specval,speccol)
% CellNetAnalyzer API function 'CNAwriteSFNValues'
%
% Usage: cnap= CNAwriteSFNValues(cnap,reacval,reaccol,specval,speccol)
%
% Given a signal-flow project that has been loaded with GUI (all
% signal-flow N- and P-fields must exist in cnap), this function writes
% numerical values into the reaction and species text boxes. The q x 1 vector 
% reacval contains the values to be written into the reaction text boxes,
% i.e. reacval(i) appears in the text box of the i-th reaction.
% Analogously, the n x 1 vector specval contains the values to be written
% into the species text boxes, i.e. specval(i) appears in the text box of
% the i-th species. An unknown/undefined value can be indicated by value
% NaN which will then be represented in the resepctive reaction/species box
% as ‘###’. The text box colors are specified by the q x 1 vector reaccol
% (reaction text boxes) and by the m x 1 vector speccol (species text boxes).
% Each element in reaccol and speccol is an integer value from the set
% {1,2,3,4} defining the color index of the associated reaction/species
% text box. The indices have the following meaning: 1=”standard”,
% 2=”calculated”, 3=”defined”, 4=”special“. Note that “standard” is
% different for species and reactions; the other three color indices refer
% to the same color (see also chapter 2).
% The function returns the network project with a few updated L-fields. For
% example, the values displayed in the text boxes before using this
% function are saved so that they can be recalled by the ‘Reset last
% scenario’ function.

cnap=get_rates_inter(cnap);
cnap.local.rb_last=cnap.local.rb;
cnap.local.met_last=cnap.local.metvals;

if ~isempty(reacval) || ~isempty(reaccol)
	if(length(reacval)~=cnap.numr)
		disp('Wrong dimension of reaction values vector');
		return;
	end
	if(length(reaccol)~=cnap.numr)
		disp('Wrong dimension of reaction colors vector');
		return;
	end
	cnap.local.r_fertig=reacval;
	cnap.local.reactype=reaccol;
else
	cnap.local.r_fertig=NaN*ones(cnap.numr,1);
	cnap.local.reactype= ones(cnap.numr,1);
end

if ~isempty(specval) || ~isempty(speccol)
	if(length(specval)~=cnap.nums)
		disp('Wrong dimension of species values vector');
		return;
	end
	if(length(speccol)~=cnap.nums)
		disp('Wrong dimension of species colors vector');
		return;
	end
	cnap.local.met_fertig=specval;
	cnap.local.mettype=speccol;
else
	cnap.local.met_fertig=NaN*ones(cnap.nums,1);
	cnap.local.mettype= ones(cnap.nums,1);
end

cnap= show_flux_inter(cnap);

