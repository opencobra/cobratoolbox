function model = assignQuantDir(model)
% Quantitatively assigns reaction directionality based on estimated bounds
% on transformed reaction Gibbs energies
%
% USAGE:
%
%    model = assignQuantDir(model)
%
% INPUT:
%    model:    structure with fields:
%
%                * .SIntRxnBool - `n x 1` boolean of internal reactions
%                * .DrGtMin - `n x 1` array of estimated lower bounds on
%                  transformed reaction Gibbs energies.
%                * .DrGtMax - `n x 1` array of estimated upper bounds on
%                  transformed reaction Gibbs energies.
%
% OUTPUT:
%    model:    structure with fields:
%
%                * .quantDir - `n x 1` array indicating quantitatively assigned
%                  reaction directionality. 1 for reactions that are
%                  irreversible in the forward direction, -1 for
%                  reactions that are irreversible in the reverse
%                  direction, and 0 for reversible reactions.
%
% .. Author: - Hulda SH, Nov. 2012

model.NaNdfG0MetBool=isnan(model.DfGt0);
model.NaNd0GRxnBool = isnan(model.DrGt0);

DrGtMin=model.DrGtMin;
DrGtMax=model.DrGtMax;

[nMet,nRxn]=size(model.S);

% model.quantDir = zeros(size(DrGtMin));
% model.quantDir(DrGtMax < 0) = 1;
% model.quantDir(DrGtMin > 0) = -1;

nEqualDrGt=nnz(DrGtMin==DrGtMax & DrGtMin~=0);
if any(nEqualDrGt)
    fprintf('%s\n',[num2str(nEqualDrGt) '/' num2str(length(DrGtMin)) ' reactions with DrGtMin=DrGtMax~=0' ]);
end

nZeroDrGt=nnz(DrGtMin==0 & DrGtMax==0);
if any(nZeroDrGt)
    fprintf('%s\n',[num2str(nZeroDrGt) '/' num2str(length(DrGtMin)) ' reactions with DrGtMin=DrGtMax=0' ]);
end


if any(model.NaNd0GRxnBool)
    warning('Some DfGt0 are NaN');
end

if any(DrGtMin>DrGtMax)
    error('DrGtMin greater than DrGtMax');
end

%reaction directionality
%keep exchange bounds the same as for the recostruction
model.lb_reconThermo=model.lb;
model.ub_reconThermo=model.ub;

%now set internal reaction directions
for n=1:nRxn
    if model.SIntRxnBool(n)
        if model.NaNd0GRxnBool(n)
            %for the reactions that involve a NaN metabolite standard Gibbs energy of
            %formation, use the directions given by the reconstruction
            if model.lb(n)<0 && model.ub(n)>0
                model.lb_reconThermo(n)=-Inf;
                model.ub_reconThermo(n)=Inf;
            end
            %forward
            if model.lb(n)>=0 && model.ub(n)>0
                model.lb_reconThermo(n)=0;
                model.ub_reconThermo(n)=Inf;
            end
            %reverse
            if model.lb(n)<0 && model.ub(n)<=0
                model.lb_reconThermo(n)=-Inf;
                model.ub_reconThermo(n)=0;
            end
            if model.lb(n)==0 && model.ub(n)==0
                error(['Reaction ' model.rxns{n} ' bounds set to zero'])
            end
            %note that there is no thermodynamic directionality assignment
            %for this reaction
            model.directionalityThermo{n}=NaN;
        else
            if DrGtMax(n)<0
                model.directionalityThermo{n}='forward';
                model.lb_reconThermo(n)=0;
                model.ub_reconThermo(n)=Inf;
            end
            if DrGtMin(n)>0
                model.directionalityThermo{n}='reverse';
                model.lb_reconThermo(n)=-Inf;
                model.ub_reconThermo(n)=0;
            end
            if DrGtMin(n)<0 && DrGtMax(n)>0
                model.directionalityThermo{n}='reversible';
                model.lb_reconThermo(n)=-Inf;
                model.ub_reconThermo(n)=Inf;
            end
            if DrGtMin(n)==DrGtMax(n)
                model.directionalityThermo{n}='equilibrium';
            end
            if model.lb(n)==0 && model.ub(n)==0
                error(['Reaction ' model.rxns{n} ' bounds set to zero'])
            end
        end
    end
end
