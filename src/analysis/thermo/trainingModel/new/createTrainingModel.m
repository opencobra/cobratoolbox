function trainingModel = createTrainingModel(trainingModel,trainingMolFileDir,forceMolReplacement,printLevel)
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
%                   * .mets   m x 1 metabolite abbreviations
%                   * .rxns   n x 1 reaction abbreviations
%                   * .metKEGGID m x 1 trainingModel.cids;
%                   * .metChEBIID  m x 1 ChEBI identifier of the metabolite.       
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


fullpath = which('Transform.m');
fullpath = regexprep(fullpath,'Transform.m','');
if ~exist('molFileDir','var') || isempty(trainingMolFileDir)
    trainingMolFileDir = [fullpath 'data' filesep 'mol' filesep];
end

if ~exist('forceMolReplacement','var')
    forceMolReplacement = 0;
end

if isempty(trainingModel)
    trainingModel = loadTrainingData;
    cid = trainingModel.cids;
    %convert numeric compound ids to proper KEGG compound ids
    if isnumeric(cid)
        eval(['cid = {' regexprep(sprintf('''C%05d''; ',cid),'(;\s)$','') '};']);
    end
    trainingModel.cids = cid;
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
            babel_cmd = '/usr/local/bin/babel';
        else
            babel_cmd = 'babel';
        end
        
        [success, ~] = system(babel_cmd);
        if success ~= 0
            error('Please make sure the command line program "babel" is installed and in the path');
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
        [success,result] =  system([babel_cmd ' -iinchi ' KEGG_ADDITIONS_INCHI_FNAME ' -omol -O ' fullpath 'data' filesep 'mol' filesep 'tmp.sdf -an']);
        %split the sdf into multiple mol files
        [success,result] =  system([babel_cmd ' ' fullpath 'data' filesep 'mol' filesep 'tmp.sdf -O ' fullpath 'data' filesep 'mol' filesep 'new.mol -m']);
        %rename the files according to the CID
        for i=1:length(added_cids)
            [success,result] =  system(['mv ' fullpath 'data' filesep 'mol' filesep 'new' int2str(i) '.mol ' fullpath 'data' filesep 'mol' filesep added_cids{i} '.mol']);
        end
        
        if ~exist([fullpath 'data' filesep 'mol' filesep 'C00080.mol'],'file')
            [mol,success] = urlread('https://www.genome.jp/dbget-bin/www_bget?-f+m+compound+C00080');
            fid = fopen([fullpath 'data' filesep 'mol' filesep 'C00080.mol'],'w+');
            fprintf(fid,'%s',mol);
            fclose(fid);
        end
        
        if ~exist([fullpath 'data' filesep 'mol' filesep 'C02780.mol'],'file')
            [mol,success] = urlread('https://www.genome.jp/dbget-bin/www_bget?-f+m+compound+C02780');
            fid = fopen([fullpath 'data' filesep 'mol' filesep 'C02780.mol'],'w+');
            fprintf(fid,'%s',mol);
            fclose(fid);
        end
    end
    
    % Retreive molfiles from KEGG if KEGG ID are given.
    fprintf('\nRetreiving molfiles from KEGG.\n');
    takeMajorMS = true; % Convert molfile from KEGG to major tautomer of major microspecies at pH 7
    pH = 7;
    takeMajorTaut = true;
    kegg2mol(trainingModel.metKEGGID,trainingMolFileDir,trainingModel.mets,takeMajorMS,pH,takeMajorTaut,forceMolReplacement); % Retreive mol files
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
fprintf('\nEstimating metabolite pKa values for training trainingModel...\n');
end
if ~isfield(trainingModel,'pseudoisomers')
    npKas = 20;
    takeMajorTaut=1;
    [pseudoisomers,errorMets] = estimate_pKa(trainingModel.mets, trainingModel.inchi.nonstandard, npKas, takeMajorTaut, printLevel-1);
    if ~isempty(errorMets)
        fprintf('Training model metabolites with errors while estimating pKa values:\n');
        disp(errorMets)
    end
    trainingModel.pseudoisomers = pseudoisomers;
end
fprintf('\n ...done. \n')

if ~isfield(trainingModel,'rxns')
    for i=1:nRxn
        trainingModel.rxns{i,1}=['rxn' int2str(i)];
    end
end
if ~isfield(trainingModel,'lb')
    trainingModel.lb=ones(size(trainingModel.S,2),1)*-inf;
end
if ~isfield(trainingModel,'ub')
    trainingModel.ub=ones(size(trainingModel.S,2),1)*inf;
end
