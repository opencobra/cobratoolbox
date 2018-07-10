function formulas = printRxnFormula(model, varargin)
% Prints the reaction formulas for a list of reactions
%
% Reactions that have an upperbound <= 0 and lowerbound < 0 will have
% its directionality reversed unless directionFlag = false.
%
% USAGE:
%
%    formulas = printRxnFormula(model, varargin)
%
% INPUTS:
%    model:             COBRA model structure
%
% OPTIONAL INPUTS:
%    
%    varargin:           Optional Inputs provided as 'ParameterName', Value
%                        pairs. the following parameternames are available:
%
%                       * rxnAbbrList:       Cell array of rxnIDs to be printed (Default = print all reactions)
%                       * printFlag:         Print formulas or just return them (Default = true)
%                       * lineChangeFlag:    Append a line change at the end of each line
%                                            (Default = true)
%                       * metNameFlag:       Print full met names instead of abbreviations
%                                            (Default = false)
%                       * fid:               Optional file identifier for printing in files
%                                            (default 1, i.e. stdout)
%                       * directionFlag:     Checks directionality of reaction. See Note.
%                                            (Default = false)
%                       * gprFlag:           Print gene protein reaction association
%                                            (Default = false)
%                       * proteinFlag:       Print the protein names associated with the genes in the 
%                                            GPRs associated with the reactions. (Default = false)
%                       * printBounds:       Print the upper and lower Bounds of the reaction (Default = false)
%                       
%
% OUTPUT:
%    formulas:          Cell array containing formulas of specified reactions
%
% EXAMPLES:
%    1) print only ATPM and TKT1:
%       printRxnFormula(model,'rxnAbbrList',{'ATPM','TKT1'});
%    2) print the reactions of the model with the metabolite Names instead of ids.
%       printRxnFormula(model, 'metNameFlag',true);
%    3) print all reactions with the metabolite names to a given fileID
%       printRxnFormula(model, 'metNameFlag',true, 'fid', fileID);
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
%       - Thomas Pfau May 2017 - Changed to Parameter value pair input


optionalParameters = {'rxnAbbrList','printFlag', 'lineChangeFlag', 'metNameFlag', 'fid', 'directionFlag', 'gprFlag', 'proteinFlag','printBounds'};
if (numel(varargin) > 0 && (~ischar(varargin{1}) || ~any(ismember(varargin{1},optionalParameters))))
    %We have an old style thing....
    %Now, we need to check, whether this is a formula, or a complex setup
        tempargin = cell(1,2*(numel(varargin)));

        for i = 1:numel(varargin)

                tempargin{2*(i-1)+1} = optionalParameters{i};
                tempargin{2*(i-1)+2} = varargin{i};
        end
        varargin = tempargin;

end

parser = inputParser();
parser.addRequired('model',@isstruct) % we only check, whether its a struct, no details for speed
parser.addParamValue('rxnAbbrList',model.rxns,@(x) iscell(x) || ischar(x))
parser.addParamValue('printFlag',true,@(x) isnumeric(x) || islogical(x))
parser.addParamValue('lineChangeFlag',true,@(x) isnumeric(x) || islogical(x));
parser.addParamValue('metNameFlag',false,@(x) isnumeric(x) || islogical(x));
parser.addParamValue('fid',1, @isnumeric);
parser.addParamValue('directionFlag',false,@(x) isnumeric(x) || islogical(x));
parser.addParamValue('gprFlag',false,@(x) isnumeric(x) || islogical(x));
parser.addParamValue('proteinFlag',false,@(x) isnumeric(x) || islogical(x));
parser.addParamValue('printBounds',false,@(x) isnumeric(x) || islogical(x));

parser.parse(model,varargin{:})

model = parser.Results.model;
rxnAbbrList = parser.Results.rxnAbbrList;
printFlag = parser.Results.printFlag;
lineChangeFlag = parser.Results.lineChangeFlag;
metNameFlag = parser.Results.metNameFlag;
fid = parser.Results.fid;
directionFlag = parser.Results.directionFlag;
gprFlag = parser.Results.gprFlag;
proteinFlag = parser.Results.proteinFlag;
printBounds = parser.Results.printBounds;

if proteinFlag && ~isfield(model,'proteins')
    %If no proteins field is present, we will use the genes field.    
    fprintf('Proteins requested, but no proteins Field exists in the model, using genes instead!\n');    
    model.proteins = model.genes;
end

if metNameFlag && ~isfield(model,'metNames')
    %if we want to print the metNames, but they don't exist, just use the mets instead.
    fprintf('metNames requested, but no metNames Field exists in the model, using mets instead!\n');
    model.metNames = model.mets;
end

if (~iscell(rxnAbbrList))
    if (strcmp(rxnAbbrList, 'all'))
        rxnAbbrList = model.rxns;
    else
        rxnAbbrTmp = rxnAbbrList;
        clear rxnAbbrList;
        rxnAbbrList{1} = rxnAbbrTmp;
    end
end

formulas = cell(size(rxnAbbrList));

for i = 1:length(rxnAbbrList)

    rxnAbbr = rxnAbbrList{i};

    rxnID = findRxnIDs(model, rxnAbbr);

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
                formulaStr = sprintf('%s+ ', formulaStr);
            end
            if (abs(Sreact(j)) ~= 1)
                formulaStr = sprintf('%s%g %s ', formulaStr, abs(Sreact(j)), reactMets{j});
            else
                formulaStr = sprintf('%s%s ', formulaStr, reactMets{j});
            end
        end

        if (model.lb(rxnID) < 0)
            formulaStr = sprintf('%s <=> ', formulaStr);
        else
            formulaStr = sprintf('%s -> ', formulaStr);
        end
        
        for j = 1:length(prodMets)
            if (j > 1)
                formulaStr = sprintf('%s+ ', formulaStr);
            end
            if (Sprod(j) ~= 1)
                formulaStr = sprintf('%s%g %s ', formulaStr, abs(Sprod(j)), prodMets{j});
            else
                formulaStr = sprintf('%s%s ', formulaStr, prodMets{j});
            end
        end
        formulas{i} = formulaStr;
        if (printFlag)
            formulaStr = regexprep(formulaStr, ' <=> ', '\t<=>\t');
            formulaStr = regexprep(formulaStr, ' -> ', '\t->\t');
            fprintf(fid, '%s\t%s', rxnAbbr, formulaStr);
            if gprFlag
                if (isfield(model, 'grRules'))
                    fprintf(fid, '\t%s', model.grRules{rxnID});
                elseif (isfield(model,'rules'))
                    rule = regexprep(model.rules{rxnID},'|','or');
                    rule = regexprep(rule,'&','and');
                    rule = regexprep(rule,'x\((?<id>[0-9]+)\)','${model.genes{num2str($1)}}');
                    fprintf(fid, '\t%s', rule);
                end
            end
            if proteinFlag
                if (isfield(model, 'rules'))
                    rule = regexprep(model.rules{rxnID},'|','or');
                    rule = regexprep(rule,'&','and');
                    rule = regexprep(rule,'x\((?<id>[0-9]+)\)','${model.proteins{num2str($1)}}');
                    fprintf(fid, '\t%s', rule);
                end
            end
            if printBounds
                fprintf('\tlb:%f\tub:%f',model.lb(rxnID),model.ub(rxnID));
            end
        end
    else
        if (printFlag)
            fprintf(fid, 'not in model');
        end
        formulaStr = 'NA';
        formulas{i} = formulaStr;
    end
    if (lineChangeFlag && printFlag)
        fprintf(fid, '\n');
    end
end

% %pass out a character string if only one reaction in the abbreviation list
% if length(rxnAbbrList)==1
%     formulas=formulas{1};
% end
