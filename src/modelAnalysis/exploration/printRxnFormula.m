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
% OPTIONAL INPUTS
%    rxnAbbrList:       Abbrs of reactions whose formulas are to be printed
%    printFlag:         Print formulas or just return them (Default = true)
%    lineChangeFlag:    Append a line change at the end of each line
%                       (Default = true)
%    metNameFlag:       print full met names instead of abbreviations
%                       (Default = false)
%    fid:               Optional file identifier for printing in files
%                       (default 1, i.e. stdout)
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
%       - Thomas Pfau May 2017 - Changed to Parameter value pair input


optionalParameters = {'rxnAbbrList','printFlag', 'lineChangeFlag', 'metNameFlag', 'fid', 'directionFlag', 'gprFlag'};
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
parser.addParameter('rxnAbbrList',model.rxns,@(x) iscell(x) || ischar(x))
parser.addParameter('printFlag',true,@(x) isnumeric(x) || islogical(x))
parser.addParameter('lineChangeFlag',true,@(x) isnumeric(x) || islogical(x));
parser.addParameter('metNameFlag',false,@(x) isnumeric(x) || islogical(x));
parser.addParameter('fid',1, @isnumeric);
parser.addParameter('directionFlag',false,@(x) isnumeric(x) || islogical(x));
parser.addParameter('gprFlag',false,@(x) isnumeric(x) || islogical(x));

parser.parse(model,varargin{:})

model = parser.Results.model;
rxnAbbrList = parser.Results.rxnAbbrList;
printFlag = parser.Results.printFlag;
lineChangeFlag = parser.Results.lineChangeFlag;
metNameFlag = parser.Results.metNameFlag;
fid = parser.Results.fid;
directionFlag = parser.Results.directionFlag;
gprFlag = parser.Results.gprFlag;

if gprFlag && ~isfield(model,'grRules')
    %if we want to print the grRules but we don't have the field, create
    %it.
    model = generateGrRules(model);
end

if metNameFlag && ~isfield(model,'metNames')
    %if we want to print the metNames, but they don't exist, just use the mets instead. 
    warning('metNames requested, but no metNames Field exists in the model, using mets instead');
    model.metNames = model.mets;
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


for i = 1:length(rxnAbbrList)

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

        if (model.lb(rxnID) < 0)
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

% %pass out a character string if only one reaction in the abbreviation list
% if length(rxnAbbrList)==1
%     formulas=formulas{1};
% end