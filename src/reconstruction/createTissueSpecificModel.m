function [tissueModel,Rxns] = createTissueSpecificModel(model, ...
                                                  expressionData,proceedExp,orphan,exRxnRemove,solver,options,funcModel)
% Creates draft tissue specific model from mRNA expression data
%
% USAGE:
%
%    [tissueModel, Rxns] = createTissueSpecificModel(model, expressionData, proceedExp, orphan, exRxnRemove, solver, options, funcModel)
%
% INPUTS:
%    model:               global recon1 model
%    expressionData:      mRNA expression data structure:
%
%                           * Locus - Vector containing `GeneIDs`
%                           * Data - Presence/Absence Calls
%
%                              * Use: (1 - Present, 0 - Absent) when proceedExp = 1
%                              * Use: (2 - Present, 1 - Marginal, 0 - Absent) when proceedExp = 0
%                           * Transcript - RefSeq Accession (only required if proceedExp = 0)
%
% OPTIONAL INPUTS:
%    proceedExp:          1 - data are processed ; 0 - data need to be
%                         processed (Default = 1)
%    orphan:              1 - leave orphan reactions in model for Shlomi Method
%                         0 - remove orphan reactions
%                         (Default = 1)
%    exRxnRemove:         Names of exchange reactions to remove
%                         (Default = [])
%    solver:              Use either 'GIMME', 'iMAT', or 'Shlomi' to create tissue
%                         specific model. 'Shlomi' is the same as 'iMAT' the names
%                         are just maintained for historical purposes.
%                         (Default = 'GIMME')
%    options:             If using GIMME, enter `objectiveCol` here
%                         Default: objective function with 90% flux cutoff,
%                         written as: `[find(model.c) 0.9]`
%    funcModel:           1 - Build a functional model having only reactions
%                         that can carry a flux (using `FVA`), 0 - skip this
%                         step (Default = 0)
%
% OUTPUTS:
%    tissueModel:         Model produced by GIMME or iMAT, containing only
%                         reactions carrying flux
%    Rxns:                Statistics of test:
%
%                              * ExpressedRxns - predicted by mRNA data
%                              * UnExpressedRxns - predicted by mRNA data
%                              * unknown - unable to be predicted by mRNA data
%                              * Upregulated - added back into model
%                              * Downregulated - removed from model
%                              * UnknownIncluded - orphans added
%
% If there are multiple transcripts to one probe that have different
% expression patterns the script will ask what the locus is of the
% expressed and unexpressed transcripts
%
% GIMME script matches objective functions flux, Shlomi algorithm is
% based on maintaining pathway length comparable to expression data, not flux
%
% .. Authors:
%       - Aarash Bordbar 05/15/2009
%       - IT 10/30/09 Added proceedExp
%       - IT 05/27/10 Adjusted manual input for alt. splice form
%       - AB 08/05/10 Final Corba 2.0 Version

if iscell(expressionData.Locus(1))
  match_strings = true;
else
  match_strings = false;
end
% Define defaults
% Deal with hardcoded belief that all the genes will have human entrez
% ids and the user wants to collapse alternative constructs
if ~exist('proceedExp','var') || isempty(proceedExp)
    proceedExp = 1;
end

if ~exist('solver','var') || isempty(solver)
    solver = 'GIMME';
end

if ~exist('exRxnRemove','var') || isempty(exRxnRemove)
    exRxnRemove = [];
end

if ~exist('orphan','var') || isempty(orphan)
    orphan = 1;
end

if ~exist('funcModel','var') || isempty(funcModel)
    funcModel = 0;
end


% Extracting GPR data from model
[parsedGPR,corrRxn] = extractGPRs(model);

if proceedExp == 0
    % Making presence/absence calls on mRNA expression data
    [Results,Transcripts] = charExpData(expressionData);

    x = ismember(Transcripts.Locus,[Transcripts.Expressed;Transcripts.UnExpressed]);
    unkLocus = find(x==0);

    AltSplice.Locus = Transcripts.Locus(unkLocus);
    AltSplice.Transcripts = Transcripts.Data(unkLocus);
    AltSplice.Expression = Transcripts.Expression(unkLocus);

    fprintf('There are some probes that match up with different transcripts and expression patterns\n');
    fprintf('Please elucidate these discrepancies below\n');
    fprintf('To do so, look up the transcript in RefSeq and enter the proper locii below\n');

    cnt1 = 1;
    cnt2 = 1;
    locusNE =[];
    locusE = [];
    for i = 1:length(AltSplice.Locus)
        if length(AltSplice.Transcripts{i}) < 1
        elseif AltSplice.Expression(i) == 0
            fprintf('Probe: %i, Transcript: %s, Expression: %i\n',AltSplice.Locus(i),AltSplice.Transcripts{i},AltSplice.Expression(i));
         %   locusNE(cnt1,1) = input('What is the proper locii? ');
                     locusNE(cnt1,1) = AltSplice.Locus(i);%input('What is the proper locii? ');
            cnt1=cnt1+1;
        elseif AltSplice.Expression(i) == 1
            fprintf('Probe: %i, Transcript: %s, Expression: %i\n',AltSplice.Locus(i),AltSplice.Transcripts{i},AltSplice.Expression(i));
           % locusE(cnt2,1) = input('What is the proper locii? ');
            locusE(cnt2,1) = AltSplice.Locus(i);% Hack by Maike %input('What is the proper locii? ');
            cnt2=cnt2+1;
        end
    end

    locusP = [Results.Expressed;Transcripts.Expressed;locusE];
    locusNP = [Results.UnExpressed;Transcripts.UnExpressed;locusNE];

    genePresenceP = ones(length(locusP),1);
    genePresenceNP = zeros(length(locusNP),1);

    locus = [locusP;locusNP];
    genePresence = [genePresenceP;genePresenceNP];
else
    locus = expressionData.Locus;
    genePresence = zeros(length(locus),1);
    genePresence(find(expressionData.Data(:,1))) = 1;
end

% Mapping probes to reactions in model
[ExpressedRxns,UnExpressedRxns,unknown] = mapProbes(parsedGPR,corrRxn,locus,genePresence,match_strings);

% Removing exchange reactions that are not in this specific tissue
% metabolome
if ~isempty(exRxnRemove)
    model = removeRxns(model,exRxnRemove);
end

nRxns = length(model.lb);

% Determine reaction indices of expressed and unexpressed reactions
RHindex = findRxnIDs(model,ExpressedRxns);
RLindex = findRxnIDs(model,UnExpressedRxns);
if (strcmp(solver, 'iMAT'))
  solver = 'Shlomi';
end
switch solver
    case 'Shlomi'

        S = model.S;
        lb = model.lb;
        ub = model.ub;
        eps = 1;

        % Creating A matrix
        A = sparse(size(S,1)+2*length(RHindex)+2*length(RLindex),size(S,2)+2*length(RHindex)+length(RLindex));
        [nConstr,nVar] = size(S);
        [m,n,s] = find(S);
        for i = 1:length(m)
            A(m(i),n(i)) = s(i);
        end

        for i = 1:length(RHindex)
            A(i+size(S,1),RHindex(i)) = 1;
            A(i+size(S,1),i+size(S,2)) = lb(RHindex(i)) - eps;
            A(i+size(S,1)+length(RHindex),RHindex(i)) = 1;
            A(i+size(S,1)+length(RHindex),i+size(S,2)+length(RHindex)+length(RLindex)) = ub(RHindex(i)) + eps;
        end

        for i = 1:length(RLindex)
            A(i+size(S,1)+2*length(RHindex),RLindex(i)) = 1;
            A(i+size(S,1)+2*length(RHindex),i+size(S,2)+length(RHindex)) = lb(RLindex(i));
            A(i+size(S,1)+2*length(RHindex)+length(RLindex),RLindex(i)) = 1;
            A(i+size(S,1)+2*length(RHindex)+length(RLindex),i+size(S,2)+length(RHindex)) = ub(RLindex(i));
        end

        % Creating csense
        csense1(1:size(S,1)) = 'E';
        csense2(1:length(RHindex)) = 'G';
        csense3(1:length(RHindex)) = 'L';
        csense4(1:length(RLindex)) = 'G';
        csense5(1:length(RLindex)) = 'L';
        csense = [csense1 csense2 csense3 csense4 csense5];

        % Creating lb and ub
        lb_y = zeros(2*length(RHindex)+length(RLindex),1);
        ub_y = ones(2*length(RHindex)+length(RLindex),1);
        lb = [lb;lb_y];
        ub = [ub;ub_y];

        % Creating c
        c_v = zeros(size(S,2),1);
        c_y = ones(2*length(RHindex)+length(RLindex),1);
        c = [c_v;c_y];

        % Creating b
        b_s = zeros(size(S,1),1);
        lb_rh = lb(RHindex);
        ub_rh = ub(RHindex);
        lb_rl = lb(RLindex);
        ub_rl = ub(RLindex);
        b = [b_s;lb_rh;ub_rh;lb_rl;ub_rl];

        % Creating vartype
        vartype1(1:size(S,2),1) = 'C';
        vartype2(1:2*length(RHindex)+length(RLindex),1) = 'B';
        vartype = [vartype1;vartype2];
        n_int = length(vartype2);

        MILPproblem.A = A;
        MILPproblem.b = b;
        MILPproblem.c = c;
        MILPproblem.lb = lb;
        MILPproblem.ub = ub;
        MILPproblem.csense = csense;
        MILPproblem.vartype = vartype;
        MILPproblem.osense = -1;
        MILPproblem.x0 = [];

        verboseFlag = true;

        solution = solveCobraMILP(MILPproblem);

        Rxns.solution = solution;

        x = solution.cont;
        for i = 1:length(x)
            if abs(x(i)) < 1e-6
                x(i,1) = 0;
            end
        end

        removed = find(x==0);
        % option to leave orphan reactions
        if orphan == 1
            orphans = findOrphanRxns(model);
            removed(find(ismember(model.rxns(removed),orphans)))=[];
        end
        rxnRemList = model.rxns(removed);
        tissueModel = removeRxns(model,rxnRemList);

        Rxns.Expressed = ExpressedRxns;
        Rxns.UnExpressed = UnExpressedRxns;
        Rxns.unknown = unknown;

        x = ismember(UnExpressedRxns,tissueModel.rxns);
        loc = find(x);
        Rxns.UpRegulated = UnExpressedRxns(loc);

        x = ismember(ExpressedRxns,tissueModel.rxns);
        loc = find(x==0);
        Rxns.DownRegulated = ExpressedRxns(loc);

        x = ismember(model.rxns,[ExpressedRxns;UnExpressedRxns]);
        loc = find(x==0);
        x = ismember(tissueModel.rxns,model.rxns(loc));
        loc = find(x);
        Rxns.UnknownIncluded = tissueModel.rxns(loc);

    case 'GIMME'
        x = ismember(model.rxns,[ExpressedRxns;UnExpressedRxns]);
        unk = find(x==0);

        expressionCol = zeros(length(model.rxns),1);
        for i = 1:length(unk)
            expressionCol(unk(i)) = -1;
        end

        for i = 1:length(RHindex)
            expressionCol(RHindex(i)) = 2;
        end
        if ~exist('options','var') || isempty(options)
            loc = find(model.c);

            sol = optimizeCbModel(model);

            options = [loc 0.9];
        end
        cutoff = 1;
        [reactionActivity,reactionActivityIrrev,model2gimme,gimmeSolution] = solveGimme(model,options,expressionCol,cutoff);

        remove = model.rxns(find(reactionActivity == 0));
        tissueModel = removeRxns(model,remove);

        if funcModel ==1
            c = tissueModel.c;

            remove = [];
            tissueModel.c = zeros(length(tissueModel.c),1);
            for i = 1:length(tissueModel.rxns)
                tissueModel.c(i) = 1;
                sol1 = optimizeCbModel(tissueModel,'max');
                sol2 = optimizeCbModel(tissueModel,'min');
                if sol1.f == 0 & sol2.f == 0
                    remove = [remove tissueModel.rxns(i)];
                end
                tissueModel.c(i) = 0;
            end

            tissueModel.c = c;
            tissueModel = removeRxns(tissueModel,remove);
        end

        Rxns.Expressed = ExpressedRxns;
        Rxns.UnExpressed = UnExpressedRxns;
        Rxns.unknown = unknown;

        x = ismember(UnExpressedRxns,tissueModel.rxns);
        loc = find(x);
        Rxns.UpRegulated = UnExpressedRxns(loc);

        x = ismember(ExpressedRxns,tissueModel.rxns);
        loc = find(x==0);
        Rxns.DownRegulated = ExpressedRxns(loc);

        x = ismember(model.rxns,[ExpressedRxns;UnExpressedRxns]);
        loc = find(x==0);
        x = ismember(tissueModel.rxns,model.rxns(loc));
        loc = find(x);
        Rxns.UnknownIncluded = tissueModel.rxns(loc);

end

%% Internal Functions
function [reactionActivity,reactionActivityIrrev,model2gimme,gimmeSolution] = solveGimme(model,objectiveCol,expressionCol,cutoff)

nRxns = size(model.S,2);

%first make model irreversible
[modelIrrev,matchRev,rev2irrev,irrev2rev] = convertToIrreversible(model);

nExpressionCol = size(expressionCol,1);
if (nExpressionCol < nRxns)
    display('Warning: Fewer expression data inputs than reactions');
    expressionCol(nExpressionCol+1:nRxns,:) = zeros(nRxns-nExpressionCol, size(expressionCol,2));
end

nIrrevRxns = size(irrev2rev,1);
expressionColIrrev = zeros(nIrrevRxns,1);
for i=1:nIrrevRxns
%     objectiveColIrrev(i,:) = objectiveCol(irrev2rev(i,1),:);
    expressionColIrrev(i,1) = expressionCol(irrev2rev(i,1),1);
end

nObjectives = size(objectiveCol,1);
for i=1:nObjectives
    objectiveColIrrev(i,:) = [rev2irrev{objectiveCol(i,1),1}(1,1) objectiveCol(i,2)];
end

%Solve initially to get max for each objective
for i=1:size(objectiveCol)
    %define parameters for initial solution
    modelIrrev.c=zeros(nIrrevRxns,1);
    modelIrrev.c(objectiveColIrrev(i,1),1)=1;

    %find max objective
    FBAsolution = optimizeCbModel(modelIrrev);
    if (FBAsolution.stat ~= 1)
        not_solved=1;
        display('Failed to solve initial FBA problem');
        return
    end
    maxObjective(i)=FBAsolution.f;
end

model2gimme = modelIrrev;
model2gimme.c = zeros(nIrrevRxns,1);


for i=1:nIrrevRxns
    if (expressionColIrrev(i,1) > -1)   %if not absent reaction
        if (expressionColIrrev(i,1) < cutoff)
            model2gimme.c(i,1) = cutoff-expressionColIrrev(i,1);
        end
    end
end

for i=1:size(objectiveColIrrev,1)
    model2gimme.lb(objectiveColIrrev(i,1),1) = objectiveColIrrev(i,2) * maxObjective(i);
end

gimmeSolution = optimizeCbModel(model2gimme,'min');

if (gimmeSolution.stat ~= 1)
%%        gimme_not_solved=1;
%        display('Failed to solve GIMME problem');
%        return
gimmeSolution.x = zeros(nIrrevRxns,1);
end

reactionActivityIrrev = zeros(nIrrevRxns,1);
for i=1:nIrrevRxns
    if ((expressionColIrrev(i,1) > cutoff) | (expressionColIrrev(i,1) == -1))
        reactionActivityIrrev(i,1)=1;
    elseif (gimmeSolution.x(i,1) > 0)
        reactionActivityIrrev(i,1)=2;
    end
end

%Translate reactionActivity to reversible model
reactionActivity = zeros(nRxns,1);
for i=1:nRxns
    for j=1:size(rev2irrev{i,1},2)
        if (reactionActivityIrrev(rev2irrev{i,1}(1,j)) > reactionActivity(i,1))
            reactionActivity(i,1) = reactionActivityIrrev(rev2irrev{i,1}(1,j));
        end
    end
end

function [rxnExpressed,unExpressed,unknown] = mapProbes(parsedGPR,corrRxn,locus,genePresence,match_strings)
if ~exist('match_strings', 'var') || isempty(match_strings)
  match_strings = false;
end

rxnExpressed = [];
unExpressed = [];
unknown = [];
for i = 1:size(parsedGPR,1)
    cnt = 0;
    for j = 1:size(parsedGPR,2)
        if length(parsedGPR{i,j}) == 0
            break
        end
        cnt = cnt+1;
    end

    test = 0;
    for j = 1:cnt
      if match_strings
        loc = parsedGPR{i,j};
        x = strmatch(loc, locus, 'exact');
      else
        loc = str2num(parsedGPR{i,j});
        loc = floor(loc);
        x = find(locus == loc);
      end

        if length(x) > 0 & genePresence(x) == 0
            unExpressed = [unExpressed;corrRxn(i)];
            test = 1;
            break
        elseif length(x) == 0
          test = 2;
        end
    end

    if test == 0
        rxnExpressed = [rxnExpressed;corrRxn(i)];
    elseif test == 2
      unknown = [unknown;corrRxn(i)];
    end
end

rxnExpressed = unique(rxnExpressed);
unExpressed = unique(unExpressed);
unknown = unique(unknown);

unknown = setdiff(unknown,rxnExpressed);
unknown = setdiff(unknown,unExpressed);
unExpressed = setdiff(unExpressed,rxnExpressed);

function [parsedGPR,corrRxn] = extractGPRs(model)

warning off all

parsedGPR = [];
corrRxn = [];
cnt = 1;

for i = 1:length(model.rxns)
    if length(model.grRules{i}) > 1
        % Parsing each reactions gpr
		%Replace and/or which are surrounded by whitespace (e.g. not within a gene id) with the symbols &/| to make strtok parsing of geneids containing the letters "adnor" possible.
		grRuleIn=regexprep(regexprep(model.grRules{i},'\s+or\s+','|'),'\s+and\s+','&');
        [parsing{1,1},parsing{2,1}] = strtok(grRuleIn,'|');
        for j = 2:1000
            [parsing{j,1},parsing{j+1,1}] = strtok(parsing{j,1},'|');
            if isempty(parsing{j+1,1})==1
                break
            end
        end

        for j = 1:length(parsing)
            for k = 1:1000
                [parsing{j,k},parsing{j,k+1}] = strtok(parsing{j,k},'&');
                if isempty(parsing{j,k+1})==1
                    break
                end
            end
        end

        for j = 1:size(parsing,1)
            for k = 1:size(parsing,2)
                parsing{j,k} = strrep(parsing{j,k},'(','');
                parsing{j,k} = strrep(parsing{j,k},')','');
                parsing{j,k} = strrep(parsing{j,k},' ','');
            end
        end

        for j = 1:size(parsing,1)-1
            newparsing(j,:) = parsing(j,1:length(parsing(j,:))-1);
        end

        parsing = newparsing;


        for j = 1:size(parsing,1)
            for k = 1:size(parsing,2)
                if length(parsing{j,k}) == 0
                    parsing{j,k} = '';
                end
            end
        end


        num = size(parsing,1);
        for j = 1:num
            sizeP = length(parsing(j,:));
            if sizeP > size(parsedGPR,2)
                for k = 1:size(parsedGPR,1)
                    parsedGPR{k,sizeP} = {''};
                end
            end

            for l = 1:sizeP
            parsedGPR{cnt,l} = parsing(j,l);
            end
            cnt = cnt+1;
        end

        for j = 1:num
            corrRxn = [corrRxn;model.rxns(i)];
        end

        clear parsing newparsing

    end

end

for i = 1:size(parsedGPR,1)
    for j = 1:size(parsedGPR,2)
        if isempty(parsedGPR{i,j}) == 1
            parsedGPR{i,j} = {''};
        end
    end
end

i =1 ;
sizeP = size(parsedGPR,1);
while i <= sizeP
    if strcmp(parsedGPR{i,1},{''}) == 1
        parsedGPR = [parsedGPR(1:i-1,:);parsedGPR(i+1:end,:)];
        corrRxn = [corrRxn(1:i-1,:);corrRxn(i+1:end,:)];
        sizeP = sizeP-1;
        i=i-1;
    end
    i = i+1;
end

for i = 1:size(parsedGPR,1)
    for j= 1:size(parsedGPR,2)
        parsedGPR2(i,j) = cellstr(parsedGPR{i,j});
    end
end

parsedGPR = parsedGPR2;

function [Results,Transcripts] = charExpData(ExpressionData)

n = length(ExpressionData.Locus);
Locus = ExpressionData.Locus;

ExpThreshold = floor(0.75*size(ExpressionData.Data,2))/size(ExpressionData.Data,2);
UnExpThreshold = ceil(0.25*size(ExpressionData.Data,2))/size(ExpressionData.Data,2);
Results.Expressed = [];
Results.UnExpressed = [];
Results.AltSplice = [];
Results.Total = 0;
for i = 1:n
    if ExpressionData.Locus(i) > 0

        locus = ExpressionData.Locus(i);
        loc = find(ExpressionData.Locus == locus);
        cap = length(loc)*size(ExpressionData.Data,2)*2;

        for j = 1:length(loc)
            total(j) = sum(ExpressionData.Data(loc(j),:));
            ExpressionData.Locus(loc(j)) = 0;
        end

        transcripts = {};
        for j = 1:length(loc)
            if length(ExpressionData.Transcript{loc(j)}) > 0
                transcripts = [transcripts;ExpressionData.Transcript{loc(j)}];
            end
        end

        if length(unique(transcripts)) <= 1

            % Overall expression patterns (> 75% in binary data, Expressed)
            if sum(total)/cap >= ExpThreshold
                Results.Expressed = [Results.Expressed;locus];
            % If < 25% in binary data, UnExpressed
            elseif sum(total)/cap <= UnExpThreshold
                Results.UnExpressed = [Results.UnExpressed;locus];

            % Accounting for different probes and their binding positions
            else
                cntP = 0;
                for j = 1:length(total)

                    % Threshold once again, 75%
                    if total(j) >= floor(0.75*size(ExpressionData.Data,2))*2;
                        cntP = cntP+1;
                    end
                end

                % If 50% or more of the probes have met the threshold,
                % expressed
                if cntP/length(total) >= 0.5
                    Results.Expressed = [Results.Expressed;locus];
                else
                    Results.UnExpressed = [Results.UnExpressed;locus];
                end
            end
        else

            % If different RefSeq Accession codes, different transcripts,
            % must be manually curated
            Results.AltSplice = [Results.AltSplice;locus];
        end
        Results.Total = Results.Total+1;
        clear total
    end
end

% Setting up different transcripts for manual curation
Transcripts.Locus = [];
Transcripts.Data = {};
for i = 1:length(Results.AltSplice)
    num = find(Locus==Results.AltSplice(i));
    transcripts = unique(ExpressionData.Transcript(num));
    for j = 1:length(transcripts)
        Transcripts.Locus = [Transcripts.Locus;Results.AltSplice(i)];
    end
    Transcripts.Data = [Transcripts.Data;transcripts];
end

% Determining each transcripts expression using a similar threshold as
% before
for i = 1:length(Transcripts.Data)
    loc = strmatch(Transcripts.Data{i},ExpressionData.Transcript,'exact');
    for j = 1:length(loc)
        total(j) = sum(ExpressionData.Data(loc(j),:));
        ExpressionData.Locus(loc(j)) = 0;
    end
    cap = length(loc)*11*2;
    if sum(total)/cap >= ExpThreshold
        Transcripts.Expression(i,1) = 1;
    else
        Transcripts.Expression(i,1) = 0;
    end
end

% If expression of transcripts of one locus are the same, added as if no
% alternative splicing occurs for simplicity
Transcripts.Expressed = [];
Transcripts.UnExpressed = [];
mem_tran = Transcripts.Locus;
for i = 1:length(Transcripts.Locus)
    if Transcripts.Locus(i) > 0
        locus = Transcripts.Locus(i);
        loc = find(Transcripts.Locus==locus);
        sumExp = 0;
        for j = 1:length(loc)
            sumExp = sumExp+Transcripts.Expression(loc(j));
            Transcripts.Locus(loc(j)) = 0;
        end
        if sumExp == 0
            Transcripts.UnExpressed = [Transcripts.UnExpressed;locus];
        elseif sumExp == length(loc)
            Transcripts.Expressed = [Transcripts.Expressed;locus];
        end
    end
end
Transcripts.Locus = mem_tran;
