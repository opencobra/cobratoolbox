function [rxnBool,nSpecies]=singleMetaboliteSpeciesReaction(model)
%Identify reactions involving reactants with only one metabolite species.
%
%identify the reactions involving one substrate metabolite species reactant,
%one product metabolite species reactant and where each reactant is composed 
%of only one metabolite species.
%
%INPUT
%model.S
%model.met(m).mf    mole fraction of each species
%
% Ronan M.T. Fleming

[nMet,nRxn]=size(model.S);

%logical indexing
Shat=logical(sign(abs(model.S)));

nSpecies=zeros(nMet,1);
for m=1:nMet
    nSpecies(m)=length(model.met(m).mf);
end

rxnBool=false(nRxn,1);
p=1;
for n=1:nRxn
    if isempty(find(model.SExRxnInd==n))
        %     if n==77
        %         pause(0.1)
        %     end
        %reactions involving reactants with only one species
        if length(find(nSpecies(Shat(:,n))==1))==nnz(Shat(:,n))
            rxnBool(n)=1;
%             fprintf('%s\t%s\t%s\t%s\n',['#' int2str(p)],int2str(n),model.rxns{n},model.rxn(n).equation);
%             fprintf('%s\n',model.rxns{n});
%             fprintf('%s\n',model.rxnNames{n});
            fprintf('%s\t\t\t%s\n',model.rxns{n},model.rxn(n).equation);
            p=p+1;
        end
        
        %     %reactions also involving only one reactant on either side
        %     if nnz(Shat(:,n))==2 %&& sum(nonzeros(model.S(:,n)))==0
        %         fprintf('%s\t%s\t%s\n',int2str(n),model.rxns{n},model.rxn(n).equation);
        %     else
        %         rxnBool(n)=0;
        %     end
    end
end
    

