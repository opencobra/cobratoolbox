function KEGG = createUniversalReactionModel(KEGGFilename, KEGGBlackList)
%createUMatrix creates the U matrix using the universal data from the KEGG
% database
%
% KEGG = createUMatrix(KEGGFilename, KEGGBlackList)
%
% Inputs
%
% KEGGFilename      - downloaded from KEGG database (ie. 'reaction.lst')
% KEGGBlackList     - KEGG reactions not to use
%
% Output
%
% KEGG              - U Matrix
%
% 11-10-07 IT
%

if ~exist('KEGGFilename','var') || isempty(KEGGFilename)
    KEGGFilename='11-20-08-KEGG-reaction.lst';
end
if ~exist('KEGGBlackList','var') || isempty(KEGGBlackList)
    KEGGBlackList = {};
end

KEGGReactionList = importdata(KEGGFilename);
KEGG = createModel;
cnt=1;
cnti=1;

HTABLE = java.util.Hashtable; % hashes Kegg.mets
showprogress(0,'KEGG reaction list ...');
for i = 1: length(KEGGReactionList)
    clear Rxn rxnFormulas;
    [Rxn, rxnFormulas] = strtok(KEGGReactionList(i),':');
     %continue if reaction is not in KEGGBlacklist

    if isempty(strmatch(Rxn, KEGGBlackList, 'exact'))%length(strmatch(Rxn,KEGGBlackList,'exact'))==0

        KEGG.rxns(cnti,1)=Rxn;

        %reformats syntax of reaction
        rxnFormulas= regexprep(rxnFormulas,': ','');
        rxnFormulas= regexprep(rxnFormulas,'\+ C','\+ 1 C');
        rxnFormulas= regexprep(rxnFormulas,' \+','[c] \+');
        rxnFormulas= regexprep(rxnFormulas,'=> C','=> 1 C');
        rxnFormulas= regexprep(rxnFormulas,' <','[c] <');
        rxnFormulas= regexprep(rxnFormulas,'^(C)','1 C');
        rxnFormulas= regexprep(rxnFormulas,' \[c]','[c]');

        rxnFormulas= regexprep(rxnFormulas,'\+ G','\+ 1 G');
        rxnFormulas= regexprep(rxnFormulas,'=> G','=> 1 G');
        rxnFormulas= regexprep(rxnFormulas,'^(G)','1 G');
        rxnFormulas= regexprep(rxnFormulas,'^(n) ','2 ');
        rxnFormulas= regexprep(rxnFormulas,'\+ n ','\+ 2 ');
        rxnFormulas= regexprep(rxnFormulas,'\> n ','\> 2 ');
        rxnFormulas= regexprep(rxnFormulas,'\ n-1 ','\ 1 ');
        rxnFormulas= regexprep(rxnFormulas,'^(n-1) ','1 ');
        rxnFormulas= regexprep(rxnFormulas,'\+ 2n ','\+ 2 ');
        rxnFormulas= regexprep(rxnFormulas,'\+ 4n ','\+ 4 ');
        rxnFormulas= regexprep(rxnFormulas,'\+ (n+1) ','\+ 3 ');
        rxnFormulas= regexprep(rxnFormulas,'\=> (n+1) ','\=> 3 ');
        rxnFormulas= regexprep(rxnFormulas,' 3C',' 3 C');
        rxnFormulas= regexprep(rxnFormulas,' 2C',' 2 C');
        rxnFormulas= regexprep(rxnFormulas,' 4C',' 4 C');

        rxnFormulas = strcat(rxnFormulas,'[c]');
        rxnFormulas= regexprep(rxnFormulas,'<=>','<==>');
        rxnFormulas= regexprep(rxnFormulas,'\=>>','=>');

        KEGG.rxnFormulas(cnti,1)=rxnFormulas;
        cnti=cnti+1;
        %compounds is a list of each of metabolites involved in the
        %reaction that has a KEGGID starting with 'C'. b1 and c1 are just
        %so that the output has the correct number of variable
        [compounds, b1, c1] = regexp(char(rxnFormulas),'C\w+\[c]','match','start','end');
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
        [compounds, b1, c1] = regexp(char(rxnFormulas),'G\w+\[c]','match','start','end');
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
    showprogress(i/length(KEGGReactionList))
end

KEGG.S=spalloc(length(KEGG.mets) + 2*length(KEGG.mets), length(KEGG.mets) + 2*length(KEGG.mets), length(KEGG.mets) + 2*length(KEGG.mets) );

[KEGG] = addReactionGEM(KEGG,KEGG.rxns,KEGG.rxns,KEGG.rxnFormulas,ones(length(KEGG.rxns),1),-10000*ones(length(KEGG.rxns),1),10000*ones(length(KEGG.rxns),1),1);
a=length(KEGG.mets);
KEGG.S(a+1:end,:)=[];
