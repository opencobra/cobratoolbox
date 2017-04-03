function KEGG = createUniversalReactionModel2(KEGGFilename, KEGGBlackList)
%% function KEGG = createUniversalReactionModel2(KEGGFilename, KEGGBlackList)
%
% createUMatrix creates the U matrix using the universal data from the KEGG
% database
% % Requires the openCOBRA toolbox
% http://opencobra.sourceforge.net/openCOBRA/Welcome.html
%
% Getting the Latest Code From the Subversion Repository:
% Linux:
% svn co https://opencobra.svn.sourceforge.net/svnroot/opencobra/cobra-devel
%
% INPUT
% KEGGFilename          File name containing universal database (e.g., KEGG; optional input, default: reaction.lst)
% KEGGblackList         List of excluded reactions from the universal database
%                       (e.g., KEGG) (optional input, default: no
%                       blacklist)
% OUTPUT
% KEGG              Contains universal database (U Matrix) in matrix format
%
%
% N.B. This file is KEGG-specific: if non-KEGG-type metabolite IDs are used
% it will not parse the reactions correctly and will throw an error.
%
% 11-10-07 Ines Thiele
% Expanded June 2013, , http://thielelab.eu.
%

if ~exist('KEGGFilename','var') || isempty(KEGGFilename)
    KEGGFilename='reaction.lst';
end
if ~exist('KEGGBlackList','var') || isempty(KEGGBlackList)
    KEGGBlackList = {};
end

KEGGReactionList = importdata(KEGGFilename);
KEGG = createModel;
cnt=1;
cnti=1;
showprogress(0,'KEGG reaction list ...');

HTABLE = java.util.Hashtable; % hashes Kegg.mets

%Create reversibility vector, default=1 (reversible)
KEGG.rev = [];

for i = 1:length(KEGGReactionList)
    clear rxnID rxnFormula;
    [rxnID, rxnFormula] = strtok(KEGGReactionList(i),':');
    %continue if reaction is not in KEGGBlacklist

    if isempty(strmatch(rxnID, KEGGBlackList, 'exact')) || isempty(strfind(rxnFormula,'(n\+m)'))%length(strmatch(rxnID,KEGGBlackList,'exact'))==0

        KEGG.rxns(cnti,1)=rxnID;

        %reformats syntax of reaction
        rxnFormula= regexprep(rxnFormula,': ','');
        rxnFormula= regexprep(rxnFormula,'\+ C','\+ 1 C');
        rxnFormula= regexprep(rxnFormula,' \+','[c] \+');
        rxnFormula= regexprep(rxnFormula,'=> C','=> 1 C');
        rxnFormula= regexprep(rxnFormula,'= C','= 1 C');
        rxnFormula= regexprep(rxnFormula,' <','[c] <');
        rxnFormula= regexprep(rxnFormula,'^(C)','1 C');
        rxnFormula= regexprep(rxnFormula,' \[c]','[c]');
        rxnFormula= regexprep(rxnFormula,'\+ G','\+ 1 G');
        rxnFormula= regexprep(rxnFormula,'=> G','=> 1 G');
        rxnFormula= regexprep(rxnFormula,'= G','= 1 G');
        rxnFormula= regexprep(rxnFormula,'^(G)','1 G');
        rxnFormula= regexprep(rxnFormula,'^(n) ','2 ');
        rxnFormula= regexprep(rxnFormula,'\+ n ','\+ 2 ');
        rxnFormula= regexprep(rxnFormula,'\> n ','\> 2 ');
        rxnFormula= regexprep(rxnFormula,'\ n\-1 ','\ 1 ');
        rxnFormula= regexprep(rxnFormula,'^\(n\-1) ','1 ');
        rxnFormula= regexprep(rxnFormula,' \(n\-1) ',' 1 ');
        rxnFormula= regexprep(rxnFormula,'^n\-1 ','1 ');
        rxnFormula= regexprep(rxnFormula,'\+ 2n ','\+ 2 ');
        rxnFormula= regexprep(rxnFormula,'\+ 4n ','\+ 4 ');
        rxnFormula= regexprep(rxnFormula,'\+ (n\+1) ','\+ 3 ');
        rxnFormula= regexprep(rxnFormula,' \(n\+1) ',' 3 ');
        rxnFormula= regexprep(rxnFormula,'^\(n\+1) ','\3 ');
        rxnFormula= regexprep(rxnFormula,' 3C',' 3 C');
        rxnFormula= regexprep(rxnFormula,' 2C',' 2 C');
        rxnFormula= regexprep(rxnFormula,' 4C',' 4 C');

        %Add compartment specification to ID for each metabolite in formula
        rxnFormula=regexprep(rxnFormula,'([CG]\d{5})($|\s)','$1[c]$2');
        %rxnFormula = strcat(rxnFormula,'[c]');
        rxnFormula= regexprep(rxnFormula,'<=>','<==>');
        rxnFormula= regexprep(rxnFormula,'\=>>','=>');
        rxnFormula= regexprep(rxnFormula,'\s<=+>\s',' <==> ');
        rxnFormula= regexprep(rxnFormula,'\s=+>\s',' => ');


        %If reaction is irreversible backwards, flip around formula
        irrevBackwards = regexp(rxnFormula,'\s<=+[^>]*\s','ONCE');
        if ~isempty(irrevBackwards{1})
            [~,rxnSides] = regexp(rxnFormula,'(.+)<=+(.+)','match','tokens');
            rxnFormula = strcat(strtrim(rxnSides{1}{1}{2}),{' => '},strtrim(rxnSides{1}{1}{1}));
        end

        %Assign reversibility
        revResult = regexp(rxnFormula,'<=+>','ONCE');
        if isempty(revResult{1})
            KEGG.rev(cnti,1) = 0;
        else
            KEGG.rev(cnti,1) = 1;
        end

        KEGG.rxnFormulas(cnti,1)=rxnFormula;
        cnti=cnti+1;
        %compounds is a list of each of metabolites involved in the
        %reaction that has a KEGGID starting with 'C'.
        [compounds, ~, ~] = regexp(char(rxnFormula),'C\w+\[c]','match','start','end');
        for j=1:length(compounds)
            if (~isempty(compounds(j)))
                %condition1 = length(strmatch(compounds(j),KEGG.mets))==0
                condition2 = isempty(HTABLE.get(compounds{j}));
                %if condition1 ~= condition2, pause; end
                if (condition2)
                    HTABLE.put(compounds{j}, cnt);
                    KEGG.mets(cnt,1)=compounds(j);
                    cnt=cnt+1;
                end
            end
        end
        clear  compounds

        %compounds is a list of each of metabolites involved in the
        %reaction that has a KEGGID starting with 'G'
        [compounds, ~, ~] = regexp(char(rxnFormula),'G\w+\[c]','match','start','end');
        for j=1:length(compounds)
            if (~isempty(compounds(j)))
                %condition1 = length(strmatch(compounds(j),KEGG.mets))==0
                condition2 = isempty(HTABLE.get(compounds{j}));
                %if condition1 ~= condition2, pause; end
                if (condition2)
                    HTABLE.put(compounds{j}, cnt);
                    KEGG.mets(cnt,1)=compounds(j);
                    cnt=cnt+1;
                end
            end
        end

    end
    showprogress(i/length(KEGGReactionList));
end

KEGG.S=spalloc(length(KEGG.mets) + 2*length(KEGG.mets), length(KEGG.mets) + 2*length(KEGG.mets), length(KEGG.mets) + 2*length(KEGG.mets) );

[KEGG] = addReactionGEM(KEGG,KEGG.rxns,KEGG.rxns,KEGG.rxnFormulas,KEGG.rev,-10000*ones(length(KEGG.rxns),1),10000*ones(length(KEGG.rxns),1),1);
a=length(KEGG.mets);
KEGG.S(a+1:end,:)=[];
a=length(KEGG.rxns);
KEGG.S(:,a+1:end)=[];

% the kegg database contains metabolites such as metalloions which appear
% on both sides of the equation. Thus KEGG.S may actually contain empty
% rows
for i = 1 : length(KEGG.mets)
    if isempty(find(KEGG.S(i,:)~=0))
    NullMet(i)=1;
    end
end
if exist('NullMet','var')
    KEGG.S(NullMet==1,:)=[];
    KEGG.mets(NullMet==1)=[];
    KEGG.b(NullMet==1)=[];
end

% ditto for rxns
for i = 1: size(KEGG.S,2)
    if isempty(find(KEGG.S(:,i)~=0))
        NullRxns(i)=1;
    end
end
if exist('NullRxns','var')
    KEGG.S(:,NullRxns==1)=[];
    KEGG.rxns(NullRxns==1)=[];
    KEGG.rxnNames(NullRxns==1)=[];
    KEGG.rxnFormulas(NullRxns==1)=[];
    KEGG.subSystems(NullRxns==1)=[];
    KEGG.lb(NullRxns==1)=[];
    KEGG.ub(NullRxns==1)=[];
    KEGG.rev(NullRxns==1)=[];
    KEGG.rules(NullRxns==1)=[];
    KEGG.grRules(NullRxns==1)=[];
    KEGG.c(NullRxns==1)=[];
end
