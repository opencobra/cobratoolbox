function [sameReactions,similarReactions] = mapKBaseToVMHReactions(translatedRxns)
% Part of the DEMETER pipeline. This functions aids in translating
% reactions from KBase to VMH nomenclature. Requires running the function 
% propagateKBaseMetTranslationToRxns beforehand to translate metabolite
% IDs, which will then allow matching translated reactions to reactions
% thjat already exist in the VMH (Virtual Metabolic Human) database.
%
% USAGE:
%
%           [sameReactions,similarReactions] = mapKBaseToVMHReactions(translatedRxns)
%
% INPUTS
% translatedRxns:       Table with untranslated KBase reactions but
%                       translated metabolite IDs
%
% OUTPUT
% sameReactions:        Table with translated KBase reactions that already
%                       exist in the VMH database with corresponding IDs
% similarReactions:     Table with translated KBase reactions for which a 
%                       reaction with the same formula but irreversible in 
%                       VMH and reversible in KBase (or vice versa) exists
%
% .. Authors:
%       - Almut Heinken, 01/2021



sameReactions={'KBase_reaction','VMH_reaction','KBase_Formula','VMH_Formula'};
similarReactions={'KBase_reaction','VMH_reaction','KBase_Formula','VMH_Formula'};

% get VMH reaction database
reactionDatabase = readtable('ReactionDatabase.txt', 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011'], 'ReadVariableNames', false);
reactionDatabase=table2cell(reactionDatabase);

parsedVMHFormulas={};
cnt=1;

% parse the VMH reaction database
for i=1:size(reactionDatabase,1)
    % break down the formula
    [metaboliteList, stoichCoeffList, revFlag] = parseRxnFormula(reactionDatabase{i,3});
    % now put the formula back together, ensuring it is written the same
    % way as translated KBase formulas
    if revFlag==1
        revChar=' <=> ';
    elseif revFlag==0
        revChar=' -> ';
    end
    rxnForm='';
    % parse substrates
    substrates=find(stoichCoeffList<0);
    if ~isempty(substrates)
        for j=1:length(substrates)
            if j<length(substrates)
                rxnForm=[rxnForm num2str(abs(stoichCoeffList(substrates(j)))) ' ' metaboliteList{substrates(j)} ' + ' ];
            else
                rxnForm=[rxnForm num2str(abs(stoichCoeffList(substrates(j)))) ' ' metaboliteList{substrates(j)} revChar ];
            end
        end
    else
      % catch cases of exchange reactions
      rxnForm=[rxnForm revChar];
    end
    
    % parse products
    products=find(stoichCoeffList>0);
    if ~isempty(products)
        for j=1:length(products)
            if j<length(products)
                rxnForm=[rxnForm num2str(abs(stoichCoeffList(products(j)))) ' ' metaboliteList{products(j)} ' + ' ];
            else
                rxnForm=[rxnForm num2str(abs(stoichCoeffList(products(j)))) ' ' metaboliteList{products(j)}];
            end
        end
    end
    
    parsedVMHFormulas{cnt,1}=reactionDatabase{i,1};
    parsedVMHFormulas{cnt,2}=rxnForm;
    parsedVMHFormulas{cnt,3}=revFlag;
    cnt=cnt+1;
    if revFlag==1
        % also catch the reaction being written the other way around
        rxnForm=strsplit(rxnForm,' <=> ');
        parsedVMHFormulas{cnt,1}=reactionDatabase{i,1};
        parsedVMHFormulas{cnt,2}=[rxnForm{2} ' <=> ' rxnForm{1}];
        parsedVMHFormulas{cnt,3}=revFlag;
        cnt=cnt+1;
    end
end

% parse KBase reactions to translate in the same manner
parsedKBaseFormulas={};
cnt=1;

for i=1:size(translatedRxns,1)
    % break down the formula
    [metaboliteList, stoichCoeffList, revFlag] = parseRxnFormula(translatedRxns{i,3});
    % now put the formula back together, ensuring it is written the same
    % way as translated VMH formulas
    if revFlag==1
        revChar=' <=> ';
    elseif revFlag==0
        revChar=' -> ';
    end
    rxnForm='';
    % parse substrates
    substrates=find(stoichCoeffList<0);
    if ~isempty(substrates)
        for j=1:length(substrates)
            if j<length(substrates)
                rxnForm=[rxnForm num2str(abs(stoichCoeffList(substrates(j)))) ' ' metaboliteList{substrates(j)} ' + ' ];
            else
                rxnForm=[rxnForm num2str(abs(stoichCoeffList(substrates(j)))) ' ' metaboliteList{substrates(j)} revChar ];
            end
        end
    else
      % catch cases of exchange reactions
      rxnForm=[rxnForm revChar];
    end
    
    % parse products
    products=find(stoichCoeffList>0);
    if ~isempty(products)
        for j=1:length(products)
            if j<length(products)
                rxnForm=[rxnForm num2str(abs(stoichCoeffList(products(j)))) ' ' metaboliteList{products(j)} ' + ' ];
            else
                rxnForm=[rxnForm num2str(abs(stoichCoeffList(products(j)))) ' ' metaboliteList{products(j)}];
            end
        end
    end
    
    parsedKBaseFormulas{cnt,1}=translatedRxns{i,1};
    parsedKBaseFormulas{cnt,2}=rxnForm;
    parsedKBaseFormulas{cnt,3}=revFlag;
    cnt=cnt+1;
    % also catch if irreversible versions of this reaction exist in the VMH
    % database -> may consider translation
    if revFlag==1
        % also catch the reaction being written the other way around
        rxnForm=strsplit(rxnForm,' <=> ');
        parsedKBaseFormulas{cnt,1}=translatedRxns{i,1};
        parsedKBaseFormulas{cnt,2}=[rxnForm{1} ' -> ' rxnForm{2}];
        parsedKBaseFormulas{cnt,3}=revFlag;
        cnt=cnt+1;
        parsedKBaseFormulas{cnt,1}=translatedRxns{i,1};
        parsedKBaseFormulas{cnt,2}=[rxnForm{2} ' -> ' rxnForm{1}];
        parsedKBaseFormulas{cnt,3}=revFlag;
        cnt=cnt+1;
    end
end

% now find the overlap between the VMH database formulas and translated
% KBase reactions
[C,IA,IB]=intersect(parsedVMHFormulas(:,2),parsedKBaseFormulas(:,2));

% now get the overlap. If the reversibility flags agree, they are the same
% reaction, otherwise, they are similar (but translation should be
% considered).

for i=1:length(C)
    VMHform=reactionDatabase{find(strcmp(reactionDatabase(:,1),parsedVMHFormulas{IA(i),1})),3};
    KBaseform=translatedRxns{find(strcmp(translatedRxns(:,1),parsedKBaseFormulas{IB(i),1})),3};
    
    toAdd={parsedKBaseFormulas{IB(i),1},parsedVMHFormulas{IA(i),1},KBaseform,VMHform};
    % if they are the same reaction
    if parsedVMHFormulas{IA(i),3} == parsedKBaseFormulas{IB(i),3}
        sameReactions(size(sameReactions,1)+1,:)=toAdd;
    else
        similarReactions(size(similarReactions,1)+1,:)=toAdd;
    end
end

% remove similar reactions that are already in same reactions
[C,IA]=intersect(similarReactions(:,1),sameReactions(:,1),'stable');
similarReactions(IA(2:end),:)=[];

end
