function [ResultsAllCellLines] = performPPP(ResultsAllCellLines,mets,step_size,samples,step_num,direct)
% This function performs the a phase plane analysis. The analysis starts from zero and proceed `step_num*step_size` in the specified direction and for two exchanges.
% the results of the analysis will be saved into `ResultsAllCellLines`.
%
% USAGE:
%
%    [ResultsAllCellLines] = performPPP(ResultsAllCellLines, mets, step_size, samples, step_num, direct)
%
% INPUTS:
%    ResultsAllCellLines:
%    samples:                 Conditions
%    mets:                    Set of two metabolites to test e.g.  mets ={`EX_glc(e)`, `EX_gln(e)`; `EX_o2(e)`, `EX_o2(e)`}
%    step_size:               Step size for metabolites specified in mets e.g., `step_size` = 100
%    direct:                  Direction for metabolites specified in mets: uptake (-1) or secretion (1), e.g., direct = [-1,-1,-1,-1];
%    step_num:                Number of steps (1000/20 = 50), step_num = [5,5;5,5]
%
% OUTPUT:
%    ResultsAllCellLines:     The matrix of growth rates are added to the `ResultsAllCellLines` structure alond with the values or the bounds using the same of the manipulated exchanges
%
% .. Author: - Maike K. Aurich 08/07/15 (performed as in Jeff Orth et al. 2010, Supplemental tutorial.)


bound_size = max(max(step_num));
for k=1:length(samples)
    k
    model1 = eval(['ResultsAllCellLines.' samples{k} '.modelPruned']);

    for p=1:size(mets,1)
        bounds = zeros(bound_size,2); % allocate space to fill in bounds
        growthRates=zeros(step_num(p,1),step_num(p,2));
        model=model1;

        for i=1:step_num(p,1)
            if direct(p,1)==1
                bounds(i,1) = direct(p,1)*i*step_size(p,1)- step_size(p,1);
                model=changeRxnBounds(model,mets{p,1},bounds(i,1),'b');
            else
                bounds(i,1) = direct(p,1)*i*step_size(p,1)+ step_size(p,1);
                model=changeRxnBounds(model,mets{p,1},bounds(i,1),'b');
            end


            for j=1:step_num(p,2)
               if direct(p,2)==1
                bounds(j,2) = direct(p,2)*j*step_size(p,2)- step_size(p,2);
                model=changeRxnBounds(model,mets{p,2},bounds(j,2),'b');
               else
                   bounds(j,2) = direct(p,2)*j*step_size(p,2)+ step_size(p,2);
                model=changeRxnBounds(model,mets{p,2},bounds(j,2),'b');
               end
                FBAsolution=optimizeCbModel(model,'max');
                growthRates(i,j)=FBAsolution.f;
                clear FBAsolution
            end
        end

        name  = ['phasePlane_' strtok(mets{p,1}, '(') '_' strtok(mets{p,2}, '(')];


        ResultsAllCellLines.(samples{k}).(name).growthRates= growthRates;
        ResultsAllCellLines.(samples{k}).(name).bounds =  bounds;
        clear bounds model growthRates
    end

    clear model1
    save('PPP120', '-v7.3');
end
end
