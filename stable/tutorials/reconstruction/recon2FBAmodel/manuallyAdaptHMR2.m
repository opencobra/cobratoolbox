function [modelOut,removeMetBool,removeRxnBool] = manuallyAdaptHMR2(model,printLevel)
% manually adapts the reactions in HMR2
%
%INPUT
% model             a recon3 draft
% printLevel
%
%OUTPUT
% modelOut          manually adapted Recon3
% removeMetBool     removed metabolites
% removeRxnBool     removed reactions

if ~exist('printLevel','var')
    printLevel=1;
end

modelOut=model;

removeMetBool=[];
removeRxnBool=[];

[nMet,nRxn]=size(modelOut.S);

%#	METID	METNAME	UNCONSTRAINED	MIRIAM	COMPOSITION	InChI	COMPARTMENT	REPLACEMENT ID	LM_ID	SYSTEMATIC_NAME	SYNONYMS	BIGG ID	EHMN ID	CHEBI_ID	CHEBI_ID	KEGG_ID	HMDB_ID	HepatoNET ID
%%oxalate[x]	oxalate	1	obo.chebi:CHEBI:16995	C2H2O4		x	m02661x		Oxalate		oxa		CHEBI:16995		C00209		HC00195
%9 is the metabolite compartment for external
removeMetBool=modelOut.metComps==modelOut.metComps(strcmp(modelOut.mets,'m02661x'));
nnz(removeMetBool)

removeRxnBool = getCorrespondingCols(modelOut.S,removeMetBool,true(nRxn,1),'inclusive');
nnz(removeRxnBool)

%zero out the stoichiometric coefficients for the [x] metabolites
modelOut.S(removeMetBool,:)=0;

for n=1:nRxn
    if removeRxnBool(n)
        rxnAbbr=modelOut.rxns{n};
        modelOut.rxns{n}=['EX_' rxnAbbr];
    end
end

% 'biomass_components',...
% 'cofactors_vitamins',...
% 'vitaminA',...
% 'vitaminD',...
% 'vitaminE',...
% 'xenobiotics',...
% 'arachidonates',...
% 'steroids',...
% 'others',... %HMR "Artificial reactions" 

