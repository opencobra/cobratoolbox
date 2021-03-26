function trainingModel = updateTrainingModel(trainingModel,trainingMolFileDir,forceMolReplacement,printLevel)
% create the training model, or update it with additional data
%
% OPTIONAL INPUTS:
% trainingModel:
% molFileDir:           directory of the mol files
% forceMolReplacement:  force the replacement of the existing mol files
%                       with newly acquired ones
% printLevel:
% 
% OUTPUTS:
%    trainingModel:  trainingModel structure with following additional fields:
%                   * .mets  ;
%                   * .metKEGGID = trainingModel.cids;
%                   * .inchi - Structure containing four `m x 1` cell array's of
%                     IUPAC InChI strings for metabolites, with varying
%                     levels of structural detail.
%
%                   * .inchi.standard: m x 1 cell array of standard inchi
%                   * .inchi.standardWithStereo: m x 1 cell array of standard inchi with stereo
%                   * .inchi.standardWithStereoAndCharge: m x 1 cell array of standard inchi with stereo and charge
%                   * .inchi.nonstandard: m x 1 cell array of non-standard inchi
%
%                   * .inchiBool           m x 1 true if inchi exists
%                   * .molBool             m x 1 true if mol file exists
%                   * .compositeInchiBool  m x 1 true if inchi is composite


fullpath = which('updateTrainingModel.m');
fullpath = regexprep(fullpath,'updateTrainingModel.m','');
if ~exist('molFileDir','var') || isempty(trainingMolFileDir)
    trainingMolFileDir = [fullpath 'mol/'];
end

if ~exist('forceMolReplacement','var')
    forceMolReplacement = 0;
end

if isempty(trainingModel)
    trainingModel = loadTrainingData;
    cid = trainingModel.cids;
    if isnumeric(cid)
        eval(['cid = {' regexprep(sprintf('''C%05d''; ',cid),'(;\s)$','') '};']);
    end
    trainingModel.cids = cid;
%     if ~iscell(trainingModel.cids)
%         for i=1:length(trainingModel.cids)
%             if 1
%                 eval(['trainingModel.cids = {' regexprep(sprintf('''C%05d''; ',trainingModel.cids),'(;\s)$','') '};']);
%             else
%                 switch length(num2str(trainingModel.cids(i)))
%                     case 1
%                         trainingModel.mets{i,1} = ['C0000' num2str(trainingModel.cids(i))];
%                     case 2
%                         trainingModel.mets{i,1} = ['C000' num2str(trainingModel.cids(i))];
%                     case 3
%                         trainingModel.mets{i,1} = ['C00' num2str(trainingModel.cids(i))];
%                     case 4
%                         trainingModel.mets{i,1} = ['C0' num2str(trainingModel.cids(i))];
%                     case 5
%                         trainingModel.mets{i,1} = ['C' num2str(trainingModel.cids(i))];
%                     otherwise
%                         trainingModel.mets{i,1} = ['C' num2str(trainingModel.cids(i))];
%                 end
%             end
%         end
%     end
    trainingModel.mets = trainingModel.cids;
    trainingModel.metKEGGID = trainingModel.cids;
end
%trainingModel = rmfield(trainingModel,'cids');

if forceMolReplacement
    %hack
    additionalFile = 'kegg_inchi_additions.txt';
    if ~isempty(additionalFile)
        fprintf('\n%s\n','Converting additional inchi into mol files')
        KEGG_ADDITIONS_INCHI_FNAME = [fullpath 'data' filesep additionalFile];
        
        if ~exist(KEGG_ADDITIONS_INCHI_FNAME, 'file')
            error(['file not found: ', KEGG_ADDITIONS_INCHI_FNAME]);
        end
        
        if ismac
            babel_cmd = '/usr/local/bin/obabel';
        else
            babel_cmd = 'obabel';
        end
        
        [success, ~] = system(babel_cmd);
        if success ~= 0
            error('Please make sure the command line program "obabel" is installed and in the path');
        end
        
        % load the InChIs for all KEGG compounds in the 'kegg_additions.tsv' file.
        % this contains a few corrections needed in KEGG and added compounds (all starting with C80000)
        fid = fopen(KEGG_ADDITIONS_INCHI_FNAME,'r');
        %fgetl(fid); % fields are: inchi, cid
        filecols = textscan(fid, '%s%s', 'delimiter',' ');
        fclose(fid);
        added_cids = filecols{2};
        added_inchis = filecols{1};
        
        %convert the inchi into mol files
        [success,result] =  system([babel_cmd ' -iinchi ' KEGG_ADDITIONS_INCHI_FNAME ' -omol -O ' fullpath 'mol' filesep 'tmp.sdf -an']);
        %split the sdf into multiple mol files
        [success,result] =  system([babel_cmd ' ' fullpath 'mol' filesep 'tmp.sdf -O ' fullpath 'mol' filesep 'new.mol -m']);
        %rename the files according to the CID
        for i=1:length(added_cids)
            [success,result] =  system(['mv ' fullpath 'mol' filesep 'new' int2str(i) '.mol ' fullpath 'mol' filesep added_cids{i} '.mol']);
        end
        
        [mol,success] = urlread('https://www.genome.jp/dbget-bin/www_bget?-f+m+compound+C00080');
        fid = fopen([fullpath 'mol' filesep 'C00080.mol'],'w+');
        fprintf(fid,'%s',mol);
        fclose(fid);
        
        [mol,success] = urlread('https://www.genome.jp/dbget-bin/www_bget?-f+m+compound+C02780');
        fid = fopen([fullpath 'mol' filesep 'C02780.mol'],'w+');
        fprintf(fid,'%s',mol);
        fclose(fid);
    end
    
    % Retreive molfiles from KEGG if KEGG ID are given.
    fprintf('\nRetreiving molfiles from KEGG.\n');
    takeMajorMS = true; % Convert molfile from KEGG to major tautomer of major microspecies at pH 7
    pH = 7;
    takeMajorTaut = true;
    kegg2mol(trainingModel.metKEGGID,[fullpath trainingMolFileDir],trainingModel.mets,takeMajorMS,pH,takeMajorTaut,forceMolReplacement); % Retreive mol files
end
            
if ~isfield(trainingModel,'inchi')
    trainingModel = addInchiToModel(trainingModel, trainingMolFileDir, 'mol',printLevel);
end
% 672 = number of trainingModel metabolites
% 657 ... with mol files
% 15 ... without mol files
% 629 ... with nonstandard inchi
% 43 ... without nonstandard inchi
% 0 ... compositie inchi removed

if ~isfield(trainingModel,'metFormulas')
    [nMet,nRxn] = size(trainingModel.S);
    for i=1:nMet
        if trainingModel.inchiBool(i)
            inchi = trainingModel.inchi.standard{i};
            [formula, nH, charge] = getFormulaAndChargeFromInChI(inchi);
            trainingModel.metFormulas{i,1}=formula;
            trainingModel.metCharges(i,1)=charge;
        else
            trainingModel.metFormulas{i,1}='';
            trainingModel.metCharges(i,1)=NaN;
        end
    end
end


%% Estimate metabolite pKa values with ChemAxon calculator plugins and determine all relevant pseudoisomers.
if printLevel>0
fprintf('Estimating metabolite pKa values for training trainingModel.\n');
end
if ~isfield(trainingModel,'pseudoisomers')
    npKas = 20;
    takeMajorTaut=1;
    [pseudoisomers,errorMets] = estimate_pKa(trainingModel.mets, trainingModel.inchi.nonstandard, npKas, takeMajorTaut, printLevel);
    fprintf('Training model metabolites with errors while estimating pKa values.\n');
    disp(errorMets)
    trainingModel.pseudoisomers = pseudoisomers;
end

if ~isfield(trainingModel,'rxns')
    for i=1:nRxn
        trainingModel.rxns{i,1}=['rxn' int2str(i)];
    end
end
if ~isfield(trainingModel,'lb')
    trainingModel.lb=ones(size(trainingModel.S,2),1)*-inf;
end
if ~isfield(trainingModel,'ub')
    trainingModel.lb=ones(size(trainingModel.S,2),1)*inf;
end
