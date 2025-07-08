function [modelOut,g]=integerizeS(model,printLevel,internalRxnsOnly)
%convert an S matrix with some non integer coefficients into an S matrix 
%with all integer coefficients
%assumes that there are a maximum of six significant digits in the biomass
%reaction
%
%INPUT
% S         stoichiometric matrix
%
%OPTIONAL INPUT
% internalRxnsOnly (1),0. 1 = integerise internal reactions only
%
%OUTPUT
% S         stoichiometric matrix with internal reactions integers, unless internalRxnsOnly =0, whence all reactions will be integerised
% g         scaling vector such that modelIn.S*diag(g)=modelOut.S;

if ~exist('printLevel','var')
    printLevel=1;
end

if ~exist('internalRxnsOnly','var')
    internalRxnsOnly=1;
end

[nMet,nRxn]=size(model.S);

if internalRxnsOnly
    if isfield(model,'SConsistentRxnBool')
        rxnToIntegerize=model.SConsistentRxnBool;
    else
        %heuristically identify exchange reactions and metabolites exclusively
        %involved in exchange reactions
        if isfield(model,'mets')
            %attempts to finds the reactions in the model which export/import from the model
            %boundary i.e. mass unbalanced reactionsisfield
            %e.g. Exchange reactions
            %     Demand reactions
            %     Sink reactions
            model = findSExRxnInd(model,[],printLevel-1);
        else
            model.SIntMetBool=true(size(model.S,1),1);
            model.SIntRxnBool=true(size(model.S,2),1);
        end
        rxnToIntegerize=model.SIntRxnBool;
    end
else
    rxnToIntegerize=true(nRxn,1);
end

Sabs=abs(model.S);
Srem=Sabs-floor(Sabs);

g=ones(nRxn,1);
for n=1:nRxn
    if rxnToIntegerize(n)
        if max(Srem(:,n))~=0
            if 0
                %old approach
                fprintf('%s\t','Reaction ');
                fprintf('%s\t',model.rxns{n});
                if length(find(Srem(:,n)~=0))>6
                    fprintf('%s\n',' a biomass reaction multiplied by 1e6');
                    g(n)=1e6;
                else
                    sigDigit=1;
                    while sigDigit>0
                        Srem2=Srem(:,n)*10*sigDigit;
                        Srem2=Srem2-floor(Srem2);
                        if max(Srem2)~=0
                            sigDigit=sigDigit+1;
                        else
                            g(n)=10*sigDigit;
                            fprintf('%s\n',['multiplied by ' int2str(10*sigDigit)]);
                            break;
                        end
                    end
                end
            else
                %new approach
                coefficients=Sabs(Sabs(:,n)~=0,n);
                % Initialize a variable to store denominators
                denominators = zeros(size(coefficients));

                % Loop through each number and get its denominator
                for i = 1:length(coefficients)
                    [~, d] = rat(coefficients(i));
                    denominators(i) = d;
                end

                % Calculate the least common multiple of all denominators
                k = lcm(denominators(1), denominators(2));
                for i = 3:length(denominators)
                    k = lcm(k, denominators(i));
                end
                g(n)=k;
            end
        end
    end
end

if printLevel>1 && any(g~=1)
    fprintf('%s\n','Before reactions integerised: ');
    printRxnFormula(model,model.rxns(g~=1));
    fprintf('\n')
end

% fix(X) rounds the elements of X to the nearest integers
modelOut=model;
modelOut.S=fix(model.S*diag(g));

if printLevel && any(g~=1)
    fprintf('%s\n','Reactions integerised: ');
    printRxnFormula(modelOut,modelOut.rxns(g~=1));
end


            
        