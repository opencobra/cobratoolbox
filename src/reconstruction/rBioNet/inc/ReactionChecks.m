% rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% reconstructing high-quality biochemical networks, Bioinformatics, Accepted.
%
% rbionet@systemsbiology.is
% Stefan G. Thorleifsson
% 2011
%This is an start to simplefying the balancing and similarity
%checking of reactions process.
%Stefan G. Thorleifsson

%Move reactions checks to one file
%What needs to be passed on to new file
%   handles.rxn
%   handles.metab
%   handles.meta_compartment
%   newrxns
%
%
%What will be in the output?
%If everything is okay
%   newrxns (reactions can be removed) set table
%   handles.data - all similarity info including dispdata.
%   handles.check
%If we return,
%   Empty is a good choise .

function data_output = ReactionChecks(rxn,metab,meta_compartment,newrxns,data)
data_output = [];
%rxn reaction database
% newrxns = get(handles.uitable1,'data');
S_nrxns = size(newrxns);
% rev and CS must be numbers
% for i =1:S_nrxns(1)
%     if ~isa(newrxns{i,4},'numeric') && ~isempty(newrxns{i,4});
%         newrxns{i,4} = str2num(newrxns{i,4});
%     end
%     if ~isa(newrxns{i,5},'numeric') && ~isempty(newrxns{i,5});
%         newrxns{i,5} = str2num(newrxns{i,5});
%     end
% end

names = {}; %Abbreviations that's already in database
names_numb = []; %there numbners
%----------- Check abbreviations names --------------------

for i = 1:S_nrxns(1)
    Own_match = strmatch(newrxns{i,1},newrxns(:,1),'exact');
    S_O = size(Own_match);

    if isempty(newrxns{i,1}) || ~isempty(strmatch(newrxns{i,1},'','exact')) %Empty
        msgbox('No rxn name specified. Make sure all reaction have specified abbreviations.',...
            'Specify name.','help');
        return;
    elseif ~isempty(strmatch(newrxns{i,1},rxn(:,1),'exact'))%Already in database
        names = [names newrxns{i,1}];
        names_numb = [names_numb i];
    elseif S_O(1) > 1
        msgbox(['New reactions cannot have the same name (' newrxns{i,1}...
            ').'],'Change names','error');
        return
    end
end

if ~isempty(names)

    if length(names) > 30
        str = [ 'exist in datbase (30 of ' num2str(length(names)) ' shown).'];

        abbreviations = questdlg([names(1:30) str ['Either your reactions already exist'...
            ' in database or abbreviation is taken. Do you want to continue'...
            ' without them?']],'Abbrevitions already in database','Yes','No',...
            'No');
    else

        abbreviations = questdlg([names ' exist in datbase. Either your reactions already exist'...
            ' in database or abbreviation is taken. Do you want to continue'...
            ' without them?'],'Abbrevitions already in database','Yes','No',...
            'No');
    end

    switch abbreviations
        case 'Yes'

            S_names = size(names_numb);
            if S_names(1) == S_nrxns(1)
                msgbox('All reaction abbreviations are in database.',...
                    'No new reactions','error');
                return
            else

                cnt_k = 0;
                for k = 1:S_names(2)

                    newrxns(names_numb(k)-cnt_k,:) = '';
                    cnt_k = cnt_k + 1;
                end
            end
            S_nrxns = size(newrxns);%newrxns has fever reactions.
            if S_nrxns(1) == 0
                msgbox(['All reactions are already in database and thus'...
                    ,' non will be added.'], 'Abbrevitions in database'...
                    ,'error');
                return
            end
        case 'No'
            return
        otherwise
            return
    end
end

for i = 1:S_nrxns(1)
    if isempty(newrxns(i,3)) %Missing formula
        msgbox([newrxns(i,1) [' is missing the formula and cannot'...
            'be added to database with out it. Please make sure all'...
            'your reactions have formula.']],...
            'Missing formula.','error');
        return;
    end
end

%Check for similarities in reaction formula
%sims structure is: lines is reaction, column is simular reaction.

%---------------------Check for unbalancing -----------------------

%newrxns - the data
%S_nrxns - size newrxns

reactions = {}; %balane abbreviation listbox
balance_charge = {};
reaction_line = []; %lines unblance originate from
showprogress(1/S_nrxns(1),'Balance checking reaction ');
fails = cell(0,1);
thei = [];
fullRCO = [];
for i = 1:S_nrxns(1)
    showprogress(i/S_nrxns(1))
    meta_meta = LoadReaction(newrxns(i,:),metab,meta_compartment,i);
    if isempty(meta_meta{1})
        thei = [thei i]; %corresponding line to fails.
        fails{end+1} = ['Reaction: ' meta_meta{2} ' Line: ' int2str(i) ' Metabolite: ' meta_meta{3}];
        continue;
    else
        output = BalancePrep(meta_meta);
        charge_l = output{3};
        charge_r = output{4};
    end

    match = regexpi(meta_meta(:,6),'FULLRCO');%this might be okay today, needs to bee loked into
    if ~isempty(match{1})
        fullRCO = [fullRCO i];
    end

    balance = balancecheck(meta_meta,1); %Verify that reaction is balanced.
    if any(~(cell2mat(balance(2,:)) == cell2mat(balance(3,:)))) || ~(charge_l == charge_r) %reaction is unbalance
        if isempty(balance)
            balance = cell(3,12); %quick fix, needs to be fixed someday.
        end
        charge = cell(3,1);
        charge(1:3,1)= {'Charge', charge_l, charge_r};
        balance_charge = [balance_charge; charge, balance];% All data is here
        reactions = [reactions newrxns{i,1}]; % balance abbreviation for listbox
        reaction_line = [reaction_line i];
        %the referenced reactions
    end
end

if ~isempty(fullRCO) %FULLRCO can not be balanced check for the moment.
    answear = questdlg({['Reactions with FULLRCO can not be balanced'...
        ' checked. Do you still want to continue?'],['Reactions in the '...
        'following lines contain FULLRCO:'], num2str(fullRCO)},'FULLRCO','Yes',...
        'No','Yes');
    switch answear
        case 'Yes'
        otherwise
            return;
    end
end


if ~isempty(fails)
    if size(fails,2) < 30
    msg = ['These metabolites are not in database. Do you want to remove'...
        ' the following reactions to continue?',fails];
    else
         msg = ['These metabolites are not in database. Do you want to'...
             ' remove the following reactions to continue? Note: 30 of '...
             num2str(size(fails,2)) ' shown.' fails(1:30)];
    end

    answer = questdlg(msg,'Metabolites not in database','Yes','No','Yes');

    switch answer
        case 'Yes'
            cnt = 0;
            cnt2 = 0;
            for i = 1:length(thei)
                %Need to cleen balance_charge, reactions, newrxns
                newrxns(i-cnt,:) = '';
                if any(thei(i) == reaction_line) %if any of those were unbalanced
                    reactions(reaction_line(i)-cnt2) = '';
                    balance_charge(3*(reaction_line(i)-cnt2)-2:3*(reaction_line(i)-cnt2),:) = '';
                    cnt2 = cnt2 + 1;
                end
                cnt = cnt + 1;
            end

        case 'No'
            for i = 1:length(fails)
                disp(fails{i});
            end
            return;
    end
end
S_nrxns = size(newrxns);
% Initiate unbalanced window
if ~isempty(reactions)
    con = unbalanced(balance_charge,reactions);
    if con == 0
        return;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------- Check reactions for similarities within the text file-----------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cnt = 1;
% sims = sparse(1,1);
%     num2str(S_nrxns(1)) '. This may take a while.']);
% for i = 1:S_nrxns(1)-1
%     similar = similarity(newrxns{i,3},newrxns(i+1:end,3),0); %similarity test
%
%     if ~isempty(similar)
%         sim_l = length(similar);
%         %First column has line of reaction in newrxns
%         %Other columns have lines in rxn that er similar to the new
%         %reaction.
%
%         sims(cnt,1:sim_l+1) = [i similar+i];
%
%         cnt = cnt + 1;
%     end
%
% end
% S = size(sims);
% %handles.data....similarity display
% equality = cell(0,3);
% for i = 1:S(1)
%     for k = 1:S(2)-1
%         if sims(i,k+1) == 0
%             break
%         end
%         eq = ReactionEq(newrxns{sims(i,1),3},newrxns(sims(i,k+1),:));
%
%         if ~isempty(eq)
%             equality(end+1,:) = {newrxns{sims(i,1),1}, eq, sims(i,1)};
%
%         else
% %             data{i,1} = newrxns{sims(i,1),1}; %line one is listbox
% %             data{i,k+1} = rxn(sims(i,k+1),:);
%         end
%
%     end
% end
%
% if ~isempty(equality)
%     cnt = 0;
%     for i = 1:size(equality,1)
%         newrxns(equality{i,3}-cnt,:) = '';
%         cnt = cnt + 1;
%     msgbox(['Reaction: ' equality{i,1} ' and ' equality{i,2} ' have the same'...
%         ' reaction formula. The same reaction can not exist under different abbreviation.']...
%         ,'Reaction','error');
%     end
%     return;
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------------ Check reactions for similarities ----------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cnt = 1;
sims = sparse(1,1);
showprogress(0,['Similarity checking. Number of reaction databases: ', num2str(S_nrxns(1))]);
for i = 1:S_nrxns(1)
    showprogress(i/S_nrxns(1)); %['Similarity checking reaction to database ' num2str(i) ' of ' num2str(S_nrxns(1)) '.']

    similar = similarity(newrxns{i,3},rxn(:,3),0); %similarity test

    if ~isempty(similar)
        sim_l = length(similar);
        %First column has line of reaction in newrxns
        %Other columns have lines in rxn that er similar to the new
        %reaction.

        sims(cnt,1:sim_l+1) = [i similar];

        cnt = cnt + 1;
    end

end

S = size(sims);
%handles.data....similarity display
equality = cell(0,3);
for i = 1:S(1)
    for k = 1:S(2)-1
        if sims(i,k+1) == 0
            break
        end
        eq = ReactionEq(newrxns{sims(i,1),3},rxn(sims(i,k+1),:));
        if ~isempty(eq)
            equality(end+1,:) = {newrxns{sims(i,1),1}, eq, sims(i,1)};

        else
            data{i,1} = newrxns{sims(i,1),1}; %line one is listbox
            data{i,k+1} = rxn(sims(i,k+1),:);

        end

    end
end

if ~isempty(equality)
    cnt = 0;
    for i = 1:size(equality,1)
        newrxns(equality{i,3}-cnt,:) = '';
        cnt = cnt + 1;
    msgbox(['Reaction: ' equality{i,1} ' exists under ' equality{i,2} ' and will not be added.'],'Reaction removed','warn');
    end
end
check = 1;

data_output = {newrxns,data,check};

% handles.
% if isempty(handles.data)
%     set(handles.listbox1,'string','No similarities');
% else
%     set(handles.listbox1,'string',handles.data(:,1));
% end

% dispdata = []; % display data
% S = size(handles.data);
% for i = 1:S(2)-1
%     if isempty(handles.data{1,i}), break, end
%     dispdata = [dispdata; handles.data{1,i+1}];
% end
% set(handles.uitable1,'data',newrxns);
% set(handles.uitable2,'data',dispdata);%similar reactions to handles.data
