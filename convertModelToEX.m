function convertModelToEX(model,filename,rxnzero,EXrxns)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% convert Matlab Model to XPA format
% Inputs:
%     model       Model Structure
%     filename    Filename of Output File (make sure to include '.txt' or
%     '.xpa')
%     rxnzero     Matrix containing all no flux var rxns (to skip, set=0)
%
% Limitations:
%     -Works properly with only integer value reaction coeff. (except for .5
%     or -.5)
%     Other non-integer value coeff. have to be edited manually
%     -Exchange reactions have to be clumped together in model
%     -If using rxnzero, make sure that EX reactions contain no compounds
%     that are not used in the uncommented reactions
%
% Aarash Bordbar, 07/06/07
% Updated Aarash Bordbar 02/22/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid = fopen(filename,'w');
fprintf(fid,'(Internal Fluxes)\n');

if nargin < 4
    EXrxns = [strmatch('EX_',model.rxns);strmatch('DM_',model.rxns)];
    EXrxns = model.rxns(EXrxns);
end
checkEX = ismember(model.rxns,EXrxns);

% Reactions prior to exchange reactions
for i = 1:length(model.rxns)
    if checkEX(i) == 0
        
        for t = 1:size(rxnzero,1)
            if i == rxnzero(t)
                fprintf(fid,'// ');
            end
        end
        fprintf(fid,'%s\t',model.rxns{i});
        if model.rev(i) == 0
            fprintf(fid,'I\t');
        else
            fprintf(fid,'R\t');
        end
        reactionPlace = find(model.S(:,i));
        if abs(model.S(reactionPlace,i)) > 1 - 1e-2
            for j = 1:size(reactionPlace,1)
                fprintf(fid,'%i\t%s\t',model.S(reactionPlace(j),i),model.mets{reactionPlace(j)});
            end
        else
            for j = 1:size(reactionPlace,1)
                newS(j,i) = 2*model.S(reactionPlace(j),i);
                fprintf(fid,'%i\t%s\t',newS(j,i),model.mets{reactionPlace(j)});
            end
        end
        fprintf(fid,'\n');
    end
end

% Exchange Reactions
fprintf(fid,'(Exchange Fluxes)\n');
for i = 1:length(model.rxns)
    if checkEX(i) == 1
        metabolitePlace = find(model.S(:,i));
        fprintf(fid,'%s\t',model.mets{metabolitePlace});
        if model.lb(i) >= 0 && model.ub(i) >= 0
            fprintf(fid,'Output\n');
        else if model.lb(i) <= 0 && model.ub(i) <= 0
                fprintf(fid,'Input\n');
            else
                fprintf(fid,'Free\n');
            end
        end
    end
end

fclose(fid);
