function [VMHId] = generateVMHMetAbbr(met, metabolite_structure_rBioNet,metab,rxnDB,customMetAbbrList)
% This function generates VMH ID's based on a metabolites based on
% predefined rules, as we would generally do it manually
%
% INPUT
% met                           Metabolite name
% metabolite_structure_rBioNet  To save time provide rBioNet either as
%                               1) string to mat file to load, e.g.,: /path/to/metabolite_structure_rBioNet.mat
%                               2) structure already in memory: metabolite_structure_rBioNet 
%                                
% metab                         To save time provide rBioNet (as
%                               metab.mat file)
% rxnDB                         To save time provide rBioNet (as
%                               rxn.mat file)
% customMetaboliteList          List of metabolite abbr against which
%                               uniqueness should also be checked
%
% OUTPUT
% VMHId                         New VMH ID
%
% Ines Thiele, 09/2021


% load rBioNet
if 0
    mkdir('data/');
    websave('data/MetaboliteDatabase.txt','https://raw.githubusercontent.com/opencobra/COBRA.papers/master/2021_demeter/input/MetaboliteDatabase.txt');
    websave('data/ReactionDatabase.txt','https://raw.githubusercontent.com/opencobra/COBRA.papers/master/2021_demeter/input/ReactionDatabase.txt');
    createRBioNetDBFromVMHDB('rBioNetDBFolder','data/');
end
if ~exist('metab','var')
    load('data/metab.mat');
    load('data/rxn.mat');
else
    rxn = rxnDB;
end
% load extended rBioNet
if exist('metabolite_structure_rBioNet','var')
    if ~isstruct(metabolite_structure_rBioNet)
        load(metabolite_structure_rBioNet);
    end
else
    load met_strc_rBioNet;
end

% convert input into lower case
VMHId = lower(met);

% remove unneeded parts from the input
[VMHId] = removeJunk(VMHId);
% keep the original but curated input name
[met_VMHId] = VMHId;


% replace metabolite name with known abbreviations from rBioNet
for i = 1 : size(metab,1)
    name = lower(metab(i,2));
    abbr = lower(metab(i,1));
    % clean up a bit names
    [name] = removeJunk(name);
    nameList_rBioNet(i,1) = name;
    % check that abbr does not contain HC#
    if isempty(regexp(abbr{1},'m\d\d\d\d\d')) && isempty(regexp(abbr{1},'hc\d\d\d\d\d'))  && isempty(regexp(abbr{1},'ce\d\d\d\d')) ...
            && isempty(regexp(abbr{1},'cn\d\d\d\d'))  && isempty(regexp(abbr{1},'c\d\d\d\d\d'))&& ~strcmp(abbr{1},'m') && contains(VMHId,name)
        
        if strcmp(name,'sulfate')
            abbr = 's'; % don't use so4
        else
            new = ['(' abbr{1} ')'];
            VMHId = regexprep(VMHId,name,new);
        end
    end
end


F = fieldnames(metabolite_structure_rBioNet);
for i= 1: length(F)
    name = metabolite_structure_rBioNet.(F{i}).metNames;
    abbr = metabolite_structure_rBioNet.(F{i}).VMHId;
    [name] = removeJunk(name);
    nameList_rBioNet_strc{i,1} = name;
    if isempty(regexp(abbr,'m\d\d\d\d\d')) && isempty(regexp(abbr,'hc\d\d\d\d\d'))  && isempty(regexp(abbr,'ce\d\d\d\d')) ...
            && isempty(regexp(abbr,'cn\d\d\d\d'))  && isempty(regexp(abbr,'c\d\d\d\d\d'))&& ~strcmp(abbr,'m') && contains(VMHId,name)
        
        if strcmp(name,'sulfate')
            abbr = 's'; % don't use so4
        else

            if ischar(abbr)
                new = ['(' abbr ')'];
            else
                new = ['(' abbr{1} ')'];
            end
            VMHId = regexprep(VMHId,name,new);
        end
    end
end


% these rules are defined as I would have manually implemented them based
% on a metabolite name.
transl = {
    'glucuronide'   '-g-'
    'monophosphate' '-mp-'
    'diphosphate'   '-dp-'
    'triphosphate'   '-tp-'
    'phosphate' '-p-'
    'methyl'    '-m-'
    'uridine'   '-u-'
    'deoxy' '-d-'
    'dehydro'   '-d-'
    'fluoro'    '-f-'
    'uracil'    '-ura-'
    'acetyl'    '-ac-'
    'glutathione'   '-gth-'
    'quinone'   '-q-'
    'thio'  '-t-'
    'pyridil'   'py'
    'amino' '-am-'
    'amine' '-am-'
    'amide' '-ad-'
    'hydroxy'   '-h-'
    'alpha' '-a-'
    'beta'  '-b-'
    'gamma' '-g-'
    'formyl'    '-f-'
    'oxide' '-o-'
    'carboxyl' '-ca-'
    'carboxy' '-ca-'
    'carboxide' '-ca-'
    'oxi'   '-o-'
    'oxy'   '-o-'
    'riboside'  '-rib-'
    'phospho'   '-p-'
    'tauro' '-t-'
    'cheno' '-c-'
    'deaminated'    '-da-'
    'deaminate' '-da-'
    'deamine' '-da-'
    'acid'  '-a-'
    'nicotinic' '-ni-'
    'tadine' 'td'
    'di'    '-d-'
    'carbaldehyde'  '-ca-'
    'carbaldh'  '-ca-'
    'aldehyde'  '-al-'
    'oxo'   '-o-'
    'hydro' '-h-'
    'azole' '-az-'
    'tri'   '-t-'
    'warfarin'  '-warf-'
    'sulphate' '-s-'
    'glucuronate'   '-glc-'
    'benzyl'    '-b-'
    'tetra'    '-t-'
    'enoyl' '-e-'
    'trans' 't'
    'cis' 'c'
    'mono' 'm'
    };
transl = lower(transl);
for i = 1 : size(transl,1)
    VMHId = regexprep(VMHId,transl{i,1},transl{i,2});
end

% no shortening happened
VMHIdO = VMHId;

% choose the first 4 letters
VMHId = regexprep(VMHId,'-([a-z])([a-z])([a-z])([a-z])([a-z]+)-','-$1$2$3$4-');
VMHId = regexprep(VMHId,'-([a-z])([a-z])([a-z])([a-z])([a-z]+)$','-$1$2$3$4-');
VMHId = regexprep(VMHId,'^([a-z])([a-z])([a-z])([a-z])([a-z]+)-','-$1$2$3$4-');
VMHId = regexprep(VMHId,'([a-z])([a-z])([a-z])([a-z])([a-z]+)','-$1$2$3$4-');
% remove numbers between two letters
VMHIdN = VMHId;
% not of the form of DG(15:0/18:2(9Z,12Z)/0:0)
if length(find(strfind(VMHId,'/')))==0
    VMHId = regexprep(VMHId,'([a-z])(\d\d+)([a-z])','$1$3');
else
    VMHId = regexprep(VMHId,'\/','_');
end
VMHId = regexprep(VMHId,'\s','');
VMHId = regexprep(VMHId,'-','');
VMHId = regexprep(VMHId,'\(','');
VMHId = regexprep(VMHId,'\)','');
VMHId = regexprep(VMHId,'\:','');
VMHId = regexprep(VMHId,',','');
VMHId = regexprep(VMHId,'+','_');
VMHId = regexprep(VMHId,'{','');
VMHId = regexprep(VMHId,'}','_');
VMHId = regexprep(VMHId,'__','_');
VMHId = regexprep(VMHId,'^_','');
VMHId = regexprep(VMHId,'!','');
VMHId = regexprep(VMHId,'‐','');

% check that this abbr does not exist yet
[VMH_existance,rBioNet_existance] = checkAbbrExists({VMHId},metab,rxn,metabolite_structure_rBioNet);
% if the abbr already exists, try the version with the internal numbers
if ~isempty(find(contains(VMH_existance(:,3),'1'))) ||  ~isempty(find(contains(rBioNet_existance(:,3),'1')))
    % check whether it is the same metabolite based on name match (not
    % more)
    if isempty(find(ismember(nameList_rBioNet_strc,met_VMHId))) &&  isempty(find(ismember(nameList_rBioNet,met_VMHId)))
        % choose a 5 letter abbr
        VMHId = VMHIdO;
        % add 1 to the end
        VMHId = [VMHId '1'];
        [VMH_existance,rBioNet_existance] = checkAbbrExists({VMHId},metab,rxn,metabolite_structure_rBioNet);
        if ~isempty(find(contains(VMH_existance(:,3),'1'))) ||  ~isempty(find(contains(rBioNet_existance(:,3),'1')))
            VMHId = VMHIdO;
            % add 1 to the end
            VMHId = [VMHId '2'];
            [VMH_existance,rBioNet_existance] = checkAbbrExists({VMHId},metab,rxn,metabolite_structure_rBioNet);
        end
        
        VMHId = regexprep(VMHId,'\s','');
        VMHId = regexprep(VMHId,'-','');
        VMHId = regexprep(VMHId,'\(','');
        VMHId = regexprep(VMHId,'\)','');
        VMHId = regexprep(VMHId,'\:','');
        VMHId = regexprep(VMHId,',','');
        VMHId = regexprep(VMHId,'+','_');
        VMHId = regexprep(VMHId,'{','');
        VMHId = regexprep(VMHId,'}','_');
VMHId = regexprep(VMHId,'‐','');

    end
end

% now check also against the costum metabolite abbr list
if exist('customMetAbbrList','var')
    if ~isempty(customMetAbbrList) &&  length(strmatch(VMHId,customMetAbbrList,'exact'))>0
        % choose a 5 letter abbr
        VMHId = VMHIdO;
        % add 1 to the end
        VMHId = [VMHId '1'];
        num = 2;
        [VMH_existance,rBioNet_existance] = checkAbbrExists({VMHId},metab,rxn,metabolite_structure_rBioNet);
        while ~isempty(find(contains(VMH_existance(:,3),'1'))) ||  ~isempty(find(contains(rBioNet_existance(:,3),'1')))
            VMHId = VMHIdO;
            % add 1 to the end
            VMHId = [VMHId num2str(num)];
            num = num+1;
            [VMH_existance,rBioNet_existance] = checkAbbrExists({VMHId},metab,rxn,metabolite_structure_rBioNet);
        end
        
        VMHId = regexprep(VMHId,'\s','');
        VMHId = regexprep(VMHId,'-','');
        VMHId = regexprep(VMHId,'\(','');
        VMHId = regexprep(VMHId,'\)','');
        VMHId = regexprep(VMHId,'\:','');
        VMHId = regexprep(VMHId,',','');
        VMHId = regexprep(VMHId,'+','_');
        VMHId = regexprep(VMHId,'{','');
        VMHId = regexprep(VMHId,'}','_');
        VMHId = regexprep(VMHId,'/','_');
        VMHId = regexprep(VMHId,'‐','');

        % Check here again if it is in customMetAbbrList (needs first
        % converted with regexprep)
         while ~isempty(find(ismember(customMetAbbrList,VMHId))>0) 
            VMHId = [VMHId '1'];
         end
    end
end


function [name] = removeJunk(name)
% remove parts of the metabolite name (in input as well as in rBioNet) that
% is not informative but makes mapping more challenging

name = regexprep(name,'conjugate','');
name = regexprep(name,'acceptor','');
name = regexprep(name,'donor','');
name = regexprep(name,'intermediate','');
name = regexprep(name,'\(1\-\)','');
name = regexprep(name,'\(1\+\)','');
name = regexprep(name,'\(2\-\)','');
name = regexprep(name,'\(2\+\)','');
name = regexprep(name,'\(3\-\)','');
name = regexprep(name,'\(3\+\)','');
name = regexprep(name,'\(4\-\)','');
name = regexprep(name,'\(4\+\)','');
name = regexprep(name,'\(1\)','');
name = regexprep(name,'\(2\)','');
name = regexprep(name,'^ ','');
name = regexprep(name,' $','');
name = regexprep(name,'*','');
name = regexprep(name,'''','');
name = regexprep(name,'β','b');
name = regexprep(name,'α','a');
name = regexprep(name,'Δ','d');
name = regexprep(name,'δ','d');
name = regexprep(name,'γ','g');
name = regexprep(name,'ω','o');
name = regexprep(name,'\.','_');
% these edits are specific to the metabolon input file
name = regexprep(name,'\[1\]','');
name = regexprep(name,'\[2\]','');
name = regexprep(name,'′','');
name = regexprep(name,'\[cis or trans\]','');
% remove any square brackets but retain text
name = regexprep(name,'\[','');
name = regexprep(name,'\]','');
name = regexprep(name,';','_');
name = regexprep(name,'!','');
name = regexprep(name,'‐','');
name = regexprep(name,'â','a');
