modelToUse = 'loopToy';
%modelToUse  = 'iCoreED';
%modelToUse = 'iAF1260';

switch modelToUse
    case 'loopToy'
        makeLoopToyModel      
    case 'iCoreED'
        if ~exist('iCoreED','var')
            load iCoreED_modelT.mat
        end
        useModelT = 0;
        if useModelT
            model = modelT;
            [nMet,nRxn] = size(model.S);
            %use original FBA bounds
            model.lb = iCoreED.lb;
            model.ub = iCoreED.ub;
            % standard chemical potential
            model.u0 = (modelT.dGft0Min+modelT.dGft0Max)/(2*modelT.temp*modelT.gasConstant);
            u0       = model.u0;
        else
            model    = iCoreED;
            [nMet,nRxn] = size(model.S);
            % standard chemical potential
            u0       = sparse(nMet,1);
        end
        if ~isfield(model,'biomassRxnAbbr')
            model.biomassRxnAbbr='Biomass_Ecoli_core_w_GAM';
        end
        % remove biomass reaction
        if 1
            model.S(:,strcmp(model.biomassRxnAbbr,model.rxns)) = 0;
        end
        if 1
            %make coefficients integers
            model.S(:,strcmp('CYTBD',model.rxns)) = model.S(:,strcmp('CYTBD',model.rxns))*2;
        end 
        % new objective
        model.c(:)=0;
        % formate
        model.c(strcmp('EX_for(e)',model.rxns))=1;
end
    
%assume only trivial inequalities for now
A = model.S;
%assume steady state
a = zeros(nMet,1);
%
D = [speye(nRxn);-speye(nRxn)];
d = [model.lb;-model.ub];

%linear objective
f = - model.c;

%options
positivity = 0;
inequality = 0;
sh=0;

%call lrs
filename=[modelToUse 'LP'];
lrsInputHalfspace(A,D,filename,positivity,inequality,a,d,f,sh);

if isunix
    %call lrs and wait until extreme pathways have been calculated 
    systemCallText=['/usr/local/bin/lrslib-042c/lrs ' pwd '/' filename '_neg_eq.ine > ' pwd '/' filename '_neg_eq.ext'];
    [status, result] = unix(systemCallText);
end
% % reads in P0 which is an nDim by nRay matrix of extreme rays
P1=lrsOutputReadRay([pwd '/' filename '_neg_eq.ext']);
% [nDim,nRay]=size(P1);