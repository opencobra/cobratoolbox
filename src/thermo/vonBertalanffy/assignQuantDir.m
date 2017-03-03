function quantDir = assignQuantDir(DrGtMin,DrGtMax)
% Quantitatively assigns reaction directionality based on estimated bounds
% on transformed reaction Gibbs energies
% 
% quantDir = assignQuantDir(DrGtMin,DrGtMax)
% 
% INPUTS
% DrGtMin   Lower bounds on transformed reaction Gibbs energies in kJ/mol.
% DrGtMax   Upper bounds on transformed reaction Gibbs energies in kJ/mol.
% 
% OUTPUTS
% quantDir  Quantitative directionality assignments.
%           quantDir = 1 for reactions that are irreversible in the forward
%           direction.
%           quantDir = -1 for reactions that are irreversible in the
%           reverse direction.
%           quantDir = 0 for reversible reactions.
% 
% Hulda SH, Nov. 2012

quantDir = zeros(size(DrGtMin));
quantDir(DrGtMax < 0) = 1;
quantDir(DrGtMin > 0) = -1;

nEqualDrGt=nnz(DrGtMin==DrGtMax & DrGtMin~=0);
if any(nEqualDrGt)
    fprintf('%s\n',[num2str(nEqualDrGt) '/' num2str(length(DrGtMin)) ' reactions with DrGtMin=DrGtMax~=0' ]);
end

nZeroDrGt=nnz(DrGtMin==0 & DrGtMax==0);
if any(nZeroDrGt)
    fprintf('%s\n',[num2str(nZeroDrGt) '/' num2str(length(DrGtMin)) ' reactions with DrGtMin=DrGtMax=0' ]);
end