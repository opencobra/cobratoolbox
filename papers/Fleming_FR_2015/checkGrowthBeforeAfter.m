function checkGrowthBeforeAfter(FRresults)
% compares the growth of models before and after eliminating rows and
% columns from the models that do not satisfy the conditions:
% 1. All rows of S := R − F correspond to molecular species in stoichiometrically consistent
% reactions, with the exception of exchange reactions.
% 2. No two rows in [F, R] are identical up to scalar multiplication.
% 3. All rows of S correspond to molecular species in net flux consistent reactions, assuming
% all reactions are reversible, including exchange reactions.
% 4. No row of [F, R] is all zeros.
%
%INPUT
% FRresults     output from checkRankFRdriver.m

for k=1:length(FRresults)  
    model=FRresults(k).model;
    
    %test if models support nonzero growth
    FBAsolutionBefore = optimizeCbModel(model);
    
    modelFR=model;
    modelFR.lb(~model.FRVcols)=0;
    modelFR.ub(~model.FRVcols)=0;
    modelFR.S(~model.FRrows,:)=0;
    modelFR.b(~model.FRrows,:)=0;
    
    %test if the after model supports nonzero growth
    FBAsolutionAfter = optimizeCbModel(modelFR);

    if k==1
        fprintf('%25s\t%s\t%s\t%s\n','ModelID','Before      ','After     ','Fractional Change')
    end
    fprintf('%25s\t%f\t%f\t%f\n',FRresults(k).modelID,FBAsolutionBefore.f,FBAsolutionAfter.f,(FBAsolutionAfter.f-FBAsolutionBefore.f)/abs(FBAsolutionBefore.f));
end

