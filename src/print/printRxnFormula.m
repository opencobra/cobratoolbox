function formulas = printRxnFormula(model, rxnAbbrList, printFlag, lineChangeFlag, metNameFlag, fid, directionFlag, gprFlag)
% Prints the reaction formulas for a list of reactions
%
% Reactions that have an upperbound <= 0 and lowerbound < 0 will have
% its directionality reversed unless directionFlag = false.
%
% USAGE:
%
%    formulas = printRxnFormula(model, rxnAbbrList, printFlag, lineChangeFlag, metNameFlag, fid, directionFlag)
%
% INPUTS:
%    model:             COBRA model structure
%
% OPTIONAL INPUTS:
%    rxnAbbrList:       Abbrs of reactions whose formulas are to be printed
%    printFlag:         Print formulas or just return them (Default = true)
%    lineChangeFlag:    Append a line change at the end of each line
%                       (Default = true)
%    metNameFlag:       print full met names instead of abbreviations
%                       (Default = false)
%    fid:               Optional file identifier for printing in files
%    directionFlag:     Checks directionality of reaction. See Note.
%                       (Default = false)
%    gprFlag:           print gene protein reaction association
%                       (Default = false)
%
% OUTPUT:
%    formulas:          Cell array containing formulas of specified reactions
%
%
% .. Authors:
%       - Markus Herrgard 11/17/05
%       - Ronan Fleming 04/30/08 (altered code since findRxnIDs used
%                                abbreviations not names of reactions)
%       - Jeff Ortn 10/11/09 (added metNameFlag option)
%       - Richard Que 03/10/10 (added lb < 0 requirement for reversing
%                              directionality)
%       - Ronan Fleming 21/11/14 (printing gpr optional)
%       - Thomas Pfau 15/12/14 (corrected line end)
%       - Ronan Fleming 16/07/16 (directionality not flipped by default
%                                anymore)

if (nargin < 2)
    rxnAbbrList = model.rxns;
end
if (nargin < 3)
    printFlag = true;
end
if (nargin < 4)
    lineChangeFlag = true;
end
if (nargin < 5)
    metNameFlag = false;
end
if (nargin < 6)
    fid = 1;
end
if (nargin < 7)
    directionFlag = false;
end
if (nargin < 8)
    gprFlag = false;
end

formulas = {};

if (~iscell(rxnAbbrList))
    if (strcmp(rxnAbbrList, 'all'))
        rxnAbbrList = model.rxns;
    else
        rxnAbbrTmp = rxnAbbrList;
        clear rxnAbbrList;
        rxnAbbrList{1} = rxnAbbrTmp;
    end
end

% not all models have rev field
if ~isfield(model, 'rev')
    model.rev = ones(size(model.S, 2), 1);
    for n = 1:size(model.S, 2)
        if model.lb(n) >= 0
            model.rev(n) = 0;
        end
    end
end

for i = 1:length(rxnAbbrList);

    rxnAbbr = rxnAbbrList{i};

    rxnID = findRxnIDs(model, rxnAbbr);

    if (printFlag)
        fprintf(fid, '%s\t', rxnAbbr);
    end

    if (rxnID > 0)

        Srxn = full(model.S(:, rxnID));

        if directionFlag && (isfield(model, 'ub') && model.ub(rxnID) <= 0) && (isfield(model, 'lb') && model.lb(rxnID) < 0)
            Srxn = -Srxn;
        end

        Sprod = (Srxn(Srxn > 0));
        if metNameFlag
            prodMets = model.metNames(Srxn > 0);
        else
            prodMets = model.mets(Srxn > 0);
        end

        Sreact = (Srxn(Srxn < 0));
        if metNameFlag
            reactMets = model.metNames(Srxn < 0);
        else
            reactMets = model.mets(Srxn < 0);
        end

        formulaStr = '';
        for j = 1:length(reactMets)
            if (j > 1)
                if (printFlag)
                    fprintf(fid, '+ ');
                end
                formulaStr = [formulaStr '+ '];
            end
            if (abs(Sreact(j)) ~= 1)
                if (printFlag)
                    fprintf(fid, '%g %s ', abs(Sreact(j)), reactMets{j});
                end
                formulaStr = [formulaStr num2str(abs(Sreact(j))) ' ' reactMets{j} ' '];
            else
                if (printFlag)
                    fprintf(fid, '%s ', reactMets{j});
                end
                formulaStr = [formulaStr reactMets{j} ' '];
            end
        end

        if (model.rev(rxnID))
            if (printFlag)
                fprintf(fid, '\t<=>\t');
            end
            formulaStr = [formulaStr ' <=> '];
        else
            if (printFlag)
                fprintf(fid, '\t->\t');
            end
            formulaStr = [formulaStr ' -> '];
        end

        for j = 1:length(prodMets)
            if (j > 1)
                if (printFlag)
                    fprintf(fid, '+ ');
                end
                formulaStr = [formulaStr '+ '];
            end
            if (Sprod(j) ~= 1)
                if (printFlag)
                    fprintf(fid, '%g %s ', Sprod(j), prodMets{j});
                end
                formulaStr = [formulaStr num2str(Sprod(j)) ' ' prodMets{j} ' '];
            else
                if (printFlag)
                    fprintf(fid, '%s ', prodMets{j});
                end
                formulaStr = [formulaStr prodMets{j} ' '];
            end
        end
    else
        if (printFlag)
            fprintf(fid, 'not in model');
        end
        formulaStr = 'NA';
    end
    if printFlag && gprFlag
        if (rxnID > 0) && (isfield(model, 'grRules'))
            if (isempty(model.grRules{rxnID}))
                fprintf(fid, '\t');
            else
                fprintf(fid, '\t%s', model.grRules{rxnID});
            end
        end

    end
    if (lineChangeFlag) && printFlag
        fprintf(fid, '\n');
    end
    formulas{i} = formulaStr;
end
formulas = formulas';
