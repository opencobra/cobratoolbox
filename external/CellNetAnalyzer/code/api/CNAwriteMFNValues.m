function cnap= CNAwriteMFNValues(cnap,reacval,reaccol,macroval)
% CellNetAnalyzer API function 'CNAwriteMFNValues'
%
% Usage: cnap= CNAwriteMFNValues(cnap,reacval,reaccol,macroval)
%
% Given a mass-flow project that has been loaded with GUI (all N- and
% P-fields must exist in cnap), this function writes numerical values into
% the text boxes. The q x 1 vector reacval contains the values to be written
% into the reaction text boxes, i.e. reacval(i) appears in the text box of
% the i-th reaction. An unknown/undefined value is indicated by value NaN
% which will then be represented in the box as ‘###’. The q x 1 vector
% reaccol specifies the color of each reaction text box. Each element in
% reaccol is an integer value from the set {1,2,3,4} defining the color
% index of the associated reaction text box. The indices have the following
% meaning (for colors in CNA see chapter 2): 1=”standard”, 2=”calculated”,
% 3=”defined”, 4=”special“.
% The m x 1 vector macroval contains the numerical values to be written in
% the text boxes of the macromolecules. They usually define the biomass
% composition, i.e. the percentages of the biomass constituents given by g
% macromolecule/gDW (see chapter 3). If you don't have macromolecules in
% your model simply use an empty matrix []. The color of macromolecule
% text boxes is fixed and can thus not be changed. The function returns the
% network project with a few updated L-fields. For example, the values
% displayed in the text boxes before using this function are saved so that
% they can be recalled by the ‘Reset last scenario’ function.

cnap=get_rates(cnap);
cnap.local.rb_last=cnap.local.rb;
cnap.local.c_makro_last=cnap.local.c_makro;

if ~isempty(reacval) || ~isempty(reaccol)
	if(length(reacval)~=cnap.numr)
		disp('Number of elements in reaction values vector not consistent with number of reactions');
		return;
	end
	if(length(reaccol)~=cnap.numr)
		disp('Number of elements in reaction colors vector not consistent with number of reactions');
		return;
	end
	cnap.local.r_fertig=reacval;
	cnap.local.reactype=reaccol;
else
	cnap.local.r_fertig=NaN*ones(cnap.numr,1);
  cnap.local.reactype= ones(cnap.numr,1);
end

if(length(macroval))
	if(length(macroval)~=cnap.nummac)
		disp('Number of elements in macromolecule vector not consistent with number of macromolecules');
		return;
	end
	if(length(macroval)>size(macroval,1))
		cnap.local.c_makro=macroval';
	else
		cnap.local.c_makro=macroval;
	end
end
cnap.local.setassflux=1;

cnap=show_flux(cnap);
