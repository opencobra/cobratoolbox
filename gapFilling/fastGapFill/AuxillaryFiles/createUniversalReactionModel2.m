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
% blackList             List of excluded reactions from the universal database
%                       (e.g., KEGG) (optional input, default: no
%                       blacklist)
%
% OUTPUT
% KEGG              Contains universal database (U Matrix) in matrix format
%
% 11-10-07 Ines Thiele
% Expanded June 2013, , http://thielelab.eu. 
%

if nargin < 2
    KEGGBlackList= {};
end
if nargin < 1
    KEGGFilename='reaction.lst';
end

KEGGReactionList = importdata(KEGGFilename);
KEGG = createModel;
cnt=1;
cnti=1;
h=waitbar(0,'KEGG reaction list ...');
HTABLE = java.util.Hashtable; % hashes Kegg.mets

for i = 1: length(KEGGReactionList)
    clear Rxn rxnFormulas;
    [Rxn, rxnFormulas] = strtok(KEGGReactionList(i),':');
    %continue if reaction is not in KEGGBlacklist
    
    if isempty(strmatch(Rxn, KEGGBlackList, 'exact')) || isempty(strfind(rxnFormulas,'(n\+m)'))%length(strmatch(Rxn,KEGGBlackList,'exact'))==0
        
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
        rxnFormulas= regexprep(rxnFormulas,'\ n\-1 ','\ 1 ');
        rxnFormulas= regexprep(rxnFormulas,'^\(n\-1) ','1 ');
        rxnFormulas= regexprep(rxnFormulas,' \(n\-1) ',' 1 ');
        rxnFormulas= regexprep(rxnFormulas,'^n\-1 ','1 ');
        rxnFormulas= regexprep(rxnFormulas,'\+ 2n ','\+ 2 ');
        rxnFormulas= regexprep(rxnFormulas,'\+ 4n ','\+ 4 ');
        rxnFormulas= regexprep(rxnFormulas,'\+ (n\+1) ','\+ 3 ');
        rxnFormulas= regexprep(rxnFormulas,' \(n\+1) ',' 3 ');
        rxnFormulas= regexprep(rxnFormulas,'^\(n\+1) ','\3 ');
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
    if (mod(i,40) ==0), waitbar(i/length(KEGGReactionList),h), end
end
close(h);
KEGG.S=spalloc(length(KEGG.mets) + 2*length(KEGG.mets), length(KEGG.mets) + 2*length(KEGG.mets), length(KEGG.mets) + 2*length(KEGG.mets) );

[KEGG] = addReactionGEM(KEGG,KEGG.rxns,KEGG.rxns,KEGG.rxnFormulas,ones(length(KEGG.rxns),1),-10000*ones(length(KEGG.rxns),1),10000*ones(length(KEGG.rxns),1),1);
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
KEGG.S(NullMet==1,:)=[];
KEGG.mets(NullMet==1)=[];
KEGG.b(NullMet==1)=[];

% ditto for rxns
for i = 1: size(KEGG.S,2)
    if isempty(find(KEGG.S(:,i)~=0))
    NullRxns(i)=1;
    end
end

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