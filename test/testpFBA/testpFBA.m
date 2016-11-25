function x = testpFBA()
%testpFBA tests the basic functionality of pFBA
%   Tests the basic solution for both minimizing the flux of gene-
%   associated reactions and all rxns, while growing on gluose or lactose
%   minimal media. Does not test the functionality of the map function.
%
%   returns 1 if all tests were completed succesfully, 0 if not
%
%   Nathan Lewis 08/30/10

oriFolder = pwd;

test_folder = what('testpFBA');
cd(test_folder.path);

%tolerance
tol = 0.00000001;

% load models and expected results
load('testpFBAData.mat','model_glc','model_lac')
og_ = load('testpFBAData.mat','GeneClasses_glc1','GeneClasses_glc0','GeneClasses_lac1','GeneClasses_lac0');
or_ = load('testpFBAData.mat','RxnClasses_glc1','RxnClasses_glc0','RxnClasses_lac1','RxnClasses_lac0');
om_ = load('testpFBAData.mat','modelIrrev_glc1','modelIrrev_glc0','modelIrrev_lac1','modelIrrev_lac0');

% run pFBA
fprintf('\n*** Test basic pFBA calculations ***\n\n');
fprintf('\n** Optimal solution - minimize gene-associated flux: glucose\n');
[t_og.GeneClasses_glc1 t_or.RxnClasses_glc1 t_om.modelIrrev_glc1] = pFBA(model_glc, 'geneoption',1);
fprintf('\n** Optimal solution - minimize gene-associated flux: lactate\n');
[t_og.GeneClasses_lac1 t_or.RxnClasses_lac1 t_om.modelIrrev_lac1] = pFBA(model_lac, 'geneoption',1);

fprintf('\n** Optimal solution - minimize all flux: glucose **\n');
[t_og.GeneClasses_glc0 t_or.RxnClasses_glc0 t_om.modelIrrev_glc0] = pFBA(model_glc, 'geneoption',0);
fprintf('\n** Optimal solution - minimize all flux: lactate **\n');
[t_og.GeneClasses_lac0 t_or.RxnClasses_lac0 t_om.modelIrrev_lac0] = pFBA(model_lac, 'geneoption',0);


t_og_f = fieldnames(t_og);
t_or_f = fieldnames(t_or);
t_om_f = fieldnames(t_om);

% testing if gene lists are consistent with expected lists
t_fg=zeros(40,1);cnt=0;
for i = 1:length(t_og_f)
    tmp_lists = fieldnames(t_og.(t_og_f{i}));
    for j = 1:length(tmp_lists)
        t1 = find(~ismember(t_og.(t_og_f{i}).(tmp_lists{j}),og_.(t_og_f{i}).(tmp_lists{j})));
        t2 = find(~ismember(og_.(t_og_f{i}).(tmp_lists{j}),t_og.(t_og_f{i}).(tmp_lists{j})));
        cnt = cnt +1;
        if isempty(t1)
            t_fg(cnt) = 1;
        end
        cnt = cnt +1;
        if isempty(t2)
            t_fg(cnt) = 1;
        end
    end
end

if(min(t_fg)==0)
    disp('Test failed for classifying genes');
else
    disp('Test succeeded for classifying genes');
end

% testing if rxn lists are consistent with expected lists
t_fr=zeros(40,1);cnt=0;
for i = 1:length(t_or_f)
    tmp_lists = fieldnames(t_or.(t_or_f{i}));
    for j = 1:length(tmp_lists)
        t1 = find(~ismember(t_or.(t_or_f{i}).(tmp_lists{j}),or_.(t_or_f{i}).(tmp_lists{j})));
        t2 = find(~ismember(or_.(t_or_f{i}).(tmp_lists{j}),t_or.(t_or_f{i}).(tmp_lists{j})));
        cnt = cnt +1;
        if isempty(t1)
            t_fr(cnt) = 1;
        end
        cnt = cnt +1;
        if isempty(t2)
            t_fr(cnt) = 1;
        end
    end
end

if(min(t_fr)==0)
    disp('Test failed for classifying reactions');
else
    disp('Test succeeded for classifying reactions');
end

% testing if flux minima are consistent with expected values
t_fm=zeros(8,1);cnt=0;
for i = 1:length(t_om_f)
    t1 = t_om.(t_om_f{i}).lb(findRxnIDs(t_om.(t_om_f{i}),'netFlux'))-om_.(t_om_f{i}).lb(findRxnIDs(om_.(t_om_f{i}),'netFlux'));
    t2 = t_om.(t_om_f{i}).ub(findRxnIDs(t_om.(t_om_f{i}),'netFlux'))-om_.(t_om_f{i}).ub(findRxnIDs(om_.(t_om_f{i}),'netFlux'));
    cnt = cnt +1;
    if t1<tol,
        t_fm(cnt) = 1;
    end
    cnt = cnt +1;
    if t2<tol
        t_fm(cnt) = 1;
    end
end

if(min(t_fm)==0)
    disp('Test failed for finding the minimum flux');
else
    disp('Test succeeded for finding the minimum flux');
end


x = min([t_fm;t_fg;t_fr]);

cd(oriFolder);

end

