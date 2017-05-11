function constrOptIrrev = setConstraintsIrrevModel(constrOpt,model,modelIrrev,rev2irrev)
% Sets constraints for a subset of `rxns` while
% converting reversible to irreversible reaction names and handling the
% constraint directions correctly
%
% USAGE:
%
%    constrOptIrrev = setConstraintsIrrevModel(rxnNameList, constrValue, constrSense, model, modelIrrev)
%
% INPUTS:
%    constrOpt:       Constraint options
%
%                       * rxnList - Reaction selection cell array (for reversible
%                         representation)
%                       * values - Constraint values
%                       * sense - Constraint senses ordered as `rxnNameList`
%
%    model:            Model in reversible format
%    modelIrrev:       Model in irreversible format
%    rev2irrev:        Reversible to irreversible reaction index conversion
%                      obtained from `convertToIrreversible`
%
% OUTPUTS:
%    constrOpt:       Constraint options in irrev model
%
%                       * rxnList - Reaction selection cell array
%                       * rxnInd - Selection index for constraints in irreversible model (e.g. [2 4 5 9 10])
%                       * values - Correctly ordered constraint values
%                       * sense - Correctly ordered constraint senses
%
% .. Author: - Markus Herrgard 10/14/03, 6/9/05 Changed this so that it allows multiple occurences of the same rxn, 1/22/07 Completely rewritten

constrIndIrrev = [];
constrValIrrev = [];
constrSenseIrrev = '';

% Bit vector describing the processing status of this constraint
constrProcessed = false*ones(length(constrOpt.rxnList),1);

for i = 1:length(constrOpt.rxnList)

    % Has this rxn already been processed?
    if (~constrProcessed(i))

        % Get reaction name
        rxnName = constrOpt.rxnList{i};
        % Find reaction index in reversible reaction set
        rxnID = find(ismember(model.rxns,rxnName));

        % Find out if there are more than one constraint for this rxn
        thisConstrInd = find(strcmp(constrOpt.rxnList,rxnName));
        % How many matching rxns
        nThisConstr = length(thisConstrInd);
        % Mark as processed
        constrProcessed(thisConstrInd) = true;

        % Get constraint values
        thisConstrValue = constrOpt.values(thisConstrInd);
        % Get constraint directions
        thisConstrSense = constrOpt.sense(thisConstrInd);

        if (~isempty(rxnID))
            % Find reaction index in irreversible reaction set
            irrevRxnID = rev2irrev{rxnID};

            % Add reaction indices and constraint values into the list
            if (length(irrevRxnID) == 1) % Irreversible
                irrevRxnName = modelIrrev.rxns{irrevRxnID};
                if length(rxnName)>2 && ~strcmp(irrevRxnName(end-1:end),'_r')
                    % Value of map is directly the index of the reaction
                    for j = 1:nThisConstr
                        constrIndIrrev(end+1) = irrevRxnID;
                        constrValIrrev(end+1) = thisConstrValue(j);
                        constrSenseIrrev(end+1) = thisConstrSense(j);
                    end
                else %Reaction is reversed in model. Flip sign of value
                    for j = 1:nThisConstr
                        constrIndIrrev(end+1) = irrevRxnID;
                        constrValIrrev(end+1) = -thisConstrValue(j);
                        constrSenseIrrev(end+1) = thisConstrSense(j);
                    end
                end
            else % Reversible
                % Only one constraint or an equality constraint represented
                % through two inequality constraints
                if (nThisConstr == 1 | (thisConstrValue(1) == thisConstrValue(2)))
                    % This would be an equality constraint
                    if (nThisConstr == 2)
                        thisConstrSense = 'E';
                    end
                    % Map contains both forward and reverse reaction indices
                    constrIndIrrev(end+1) = irrevRxnID(1);
                    constrIndIrrev(end+1) = irrevRxnID(2);
                    if (thisConstrValue(1) >= 0)
                        constrValIrrev(end+1) = thisConstrValue(1);
                        constrValIrrev(end+1) = 0;
                        % Deal with different directions of constraints
                        switch thisConstrSense
                            case 'E'
                                constrSenseIrrev(end+1) = 'E';
                                constrSenseIrrev(end+1) = 'E';
                            case 'G'
                                constrSenseIrrev(end+1) = 'G';
                                constrSenseIrrev(end+1) = 'E';
                            case 'L'
                                constrSenseIrrev(end+1) = 'L';
                                constrSenseIrrev(end+1) = 'G';
                        end
                    else
                        constrValIrrev(end+1) = 0;
                        constrValIrrev(end+1) = -thisConstrValue(1);
                        switch thisConstrSense
                            case 'E'
                                constrSenseIrrev(end+1) = 'E';
                                constrSenseIrrev(end+1) = 'E';
                            case 'G'
                                constrSenseIrrev(end+1) = 'G';
                                constrSenseIrrev(end+1) = 'L';
                            case 'L'
                                constrSenseIrrev(end+1) = 'E';
                                constrSenseIrrev(end+1) = 'G';
                        end
                    end
                else % More than one constraint (the only case that makes sense is a <= v <= b)
                    lowestConstrVal = min(thisConstrValue);
                    highestConstrVal = max(thisConstrValue);

                    if ((lowestConstrVal > 0) & (highestConstrVal > 0))  % Both positive
                        constrIndIrrev(end+1:end+3) = irrevRxnID([1 1 2]);
                        constrValIrrev(end+1:end+3) = [lowestConstrVal highestConstrVal 0];
                        constrSenseIrrev(end+1:end+3) = 'GLE';
                    elseif ((lowestConstrVal < 0) & (highestConstrVal < 0)) % Both negative
                        constrIndIrrev(end+1:end+3) = irrevRxnID([1 2 2]);
                        constrValIrrev(end+1:end+3) = [0 -highestConstrVal -lowestConstrVal];
                        constrSenseIrrev(end+1:end+3) = 'EGL';
                    else % Low positive, hi negative
                        constrIndIrrev(end+1:end+2) = irrevRxnID([1 2]);
                        constrValIrrev(end+1:end+2) = [highestConstrVal -lowestConstrVal];
                        constrSenseIrrev(end+1:end+2) = 'LL';
                    end
                end
            end
        end
    end
end

constrOptIrrev.rxnList = columnVector(modelIrrev.rxns(constrIndIrrev));
constrOptIrrev.rxnInd = columnVector(constrIndIrrev);
constrOptIrrev.values = columnVector(constrValIrrev);
constrOptIrrev.sense = columnVector(constrSenseIrrev);
