function Outmodel = NormaliseGPRs(model,geneRegExp)
% Bring all GPRS into a DNF form and reduce them to the minimal DNF Form
% First we will walk over all GPRs and bring them into DNF
%
% USAGE:
%
%    Outmodel = NormaliseGPRs(model,geneRegExp)
%
% INPUTS:
%
%    model:       The Model to convert the GPRs
%    geneRegExp:  A Regular expression matching the genes in the model.
% 

gprs = model.rules;
FP = FormulaParser();
newgprs = cell(numel(gprs),1);
newrules = cell(numel(gprs),1);
for i = 1:numel(gprs)
    if strcmp(gprs{i},'')        
        newgprs{i} = '';
        newrules{i} = '';
        continue
    end
    fprintf('Currently calculating GPR #%i: \n %s\n',i,gprs{i});
    Head = FP.parseFormula(gprs{i});
    NewHead = Head.convertToDNF();
    FP.reduceFormula(NewHead);
    if isa(NewHead,'OrNode')
        NewHead.removeDNFduplicates();
    end
    newgprs{i} = NewHead.toString();
    newrule = NewHead.toString(1);
    geneIDs = unique(regexp(newrule,['\(' geneRegExp '\)'],'match'));
    geneIDs = regexprep(geneIDs,'^\(|\)$','');
    genepos = find(ismember(model.genes,geneIDs));
    %this line ensures, that we do have the same order!!
    geneIDs = model.genes(genepos);
    for j = 1:numel(geneIDs)
        newrule = strrep(newrule,['(' geneIDs{j} ')'],['x(' num2str(genepos(j)) ')']);
    end
    newrules{i} = newrule;
end
Outmodel = model;
Outmodel.grRules = newgprs;
Outmodel.rules = newrules;

end