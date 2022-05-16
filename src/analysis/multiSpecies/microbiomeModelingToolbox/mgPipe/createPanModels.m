function createPanModels(agoraPath, panPath, taxonLevel, numWorkers, taxTable)
% This function creates pan-models for all unique taxa (e.g., species)
% included in the AGORA resource. If reconstructions of multiple strains
% in a given taxon are present, the reactions in these reconstructions will
% be combined into a pan-reconstruction. The pan-biomass reactions will be
% built from the average of all biomasses. Futile cycles that result from
% the newly combined reaction content are removed by setting certain
% reactions irreversible. These reactions have been determined manually.
% NOTE: Futile cycle removal has only been tested at the species and genus
% level. Pan-models at higher taxonomical levels (e.g., family) may
% contain futile cycles and produce unrealistically high ATP flux.
% The pan-models can be used an input for mgPipe if taxon abundance data is
% available at a higher level than strain, e.g., species, genus.
%
% USAGE:
%
%   createPanModels(agoraPath,panPath,taxonLevel)
%
% INPUTS:
%    agoraPath     String containing the path to the AGORA reconstructions.
%                  Must end with a file separator.
%    panPath       String containing the path to an empty folder that the
%                  created pan-models will be stored in. Must end with a file separator.
%    taxonLevel    String with desired taxonomical level of the pan-models.
%                  Allowed inputs are 'Species','Genus','Family','Order', 'Class','Phylum'.
%
% OPTIONAL INPUTS
%    numWorkers    Number of workers for parallel pool (default: no pool)
%    taxTable      File with information on taxonomy of reconstruction
%                  resource (default: 'AGORA_infoFile.xlsx')
%
% .. Authors
%       - Stefania Magnusdottir, 2016
%       - Almut Heinken, 06/2018: adapted to function.
%       - Almut Heinken, 03/2021: enabled parallelization

tol = 1e-5;

if nargin <4
    numWorkers = 0;
end

mkdir(panPath)

% initialize parallel pool
if numWorkers > 0
    % with parallelization
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool(numWorkers)
    end
end

global CBT_LP_SOLVER
if isempty(CBT_LP_SOLVER)
    initCobraToolbox
end
solver = CBT_LP_SOLVER;
environment = getEnvironment();

if ~exist('taxTable','var')
    infoFile = readInputTableForPipeline('AGORA_infoFile.xlsx');
else
    infoFile = readInputTableForPipeline(taxTable);
end

% get the reaction and metabolite database
database=loadVMHDatabase;

% List all species in the AGORA resource
findTaxCol = find(strcmp(infoFile(1, :), taxonLevel));
allTaxa = unique(infoFile(2:end, findTaxCol));

% Remove unclassified and unnamed organisms
allTaxa(strncmp(allTaxa, 'unclassified',  12)) = [];
allTaxa(strcmp(allTaxa, '')) = [];

% Remove models that have already been assembled from the list of models to create
dInfo = dir(panPath);
dInfo = dInfo(~[dInfo.isdir]);
built={dInfo.name};
built=built';
built = strrep(built, '.mat', '');
built=regexprep(built,'pan','','once');
translTaxa=strrep(allTaxa,'[','');
translTaxa=strrep(translTaxa,' ','_');
translTaxa=strrep(translTaxa,']','');
translTaxa=strrep(translTaxa,'(','_');
translTaxa=strrep(translTaxa,')','');
translTaxa=strrep(translTaxa,'/','_');
translTaxa=strrep(translTaxa,'-','_');
translTaxa=strrep(translTaxa,'.','');
[C,IA] = setdiff(translTaxa, built);
toCreate=allTaxa(IA);

% Build pan-models
% define the intervals in which the testing and regular saving will be
% performed
if size(toCreate,1)>200
    steps=100;
else
    steps=25;
end

for i = 1:steps:size(toCreate,1)
    if size(toCreate,1)-i >= steps-1
        endPnt=steps-1;
    else
        endPnt=size(toCreate,1)-i;
    end
    
    modelsTmp={};
    parfor j=i:i+endPnt
        restoreEnvironment(environment);
        changeCobraSolver(solver, 'LP', 0, -1);
        if strcmp(solver,'ibm_cplex')
            % prevent creation of log files
            changeCobraSolverParams('LP', 'logFile', 0);
        end
        models = find(ismember(infoFile(:, findTaxCol), toCreate{j,1}));
        
        panModel=buildPanModel(agoraPath, models, toCreate{j,1}, infoFile, database);
        modelsTmp{j}=panModel;
    end
    for j=i:i+endPnt
        model=modelsTmp{j};
        modelname=strrep(toCreate{j, 1}, ' ', '_');
        modelname=strrep(modelname,'[','');
        modelname=strrep(modelname,']','');
        modelname=strrep(modelname,'(','_');
        modelname=strrep(modelname,')','');
        modelname=strrep(modelname,'/','_');
        modelname=strrep(modelname,'-','_');
        modelname=strrep(modelname,'.','');
        savePath = [panPath filesep 'pan' modelname '.mat'];
        save(savePath, 'model');
    end
end

%% Remove futile cycles
% Create table with information on reactions to replace to remove futile
% cycles. This information was determined manually by Stefania
% Magnusdottir and Almut Heinken.

reactionsToReplace = {
    'if','removed','added'
    'LYSt2r AND LYSt3r','LYSt3r','LYSt3'
    'FDHr','FDHr','FDH'
    'GLYO1','GLYO1','GLYO1i'
    'EAR40xr','EAR40xr','EAR40x'
    'PROt2r AND PROt4r','PROt4r','PROt4'
    'FOROXAtex AND FORt','FORt',[]
    'NO2t2r AND NTRIR5','NO2t2r','NO2t2'
    'NOr1mq AND NHFRBOr','NHFRBOr','NHFRBO'
    'NIR AND L_LACDr','L_LACDr','L_LACD'
    'PIt6b AND PIt7','PIt7','PIt7ir'
    'ABUTt2r AND GLUABUTt7','ABUTt2r','ABUTt2'
    'ABUTt2r AND ABTAr','ABTAr','ABTA'
    'Kt1r AND Kt3r','Kt3r','Kt3'
    'CYTDt4 AND CYTDt2r','CYTDt2r','CYTDt2'
    'ASPt2_2 AND ASPt2r','ASPt2r','ASPte'
    'ASPt2_3 AND ASPt2r','ASPt2r','ASPt2'
    'FUMt2_2 AND FUMt2r','FUMt2r','FUMt'
    'SUCCt2_2 AND SUCCt2r','SUCCt2r','SUCCt'
    'SUCCt2_3r AND SUCCt2r','SUCCt2r',[]
    'MALFADO AND MDH','MALFADO','MALFADOi'
    'MALFADO AND GLXS','MALFADO','MALFADOi'
    'r0392 AND GLXCL','r0392','ALDD8x'
    'HACD1 AND PHPB2','PHPB2','PHPB2i'
    'PPCKr AND PPCr','PPCKr','PPCK'
    'PPCKr AND GLFRDO AND FXXRDO','PPCKr','PPCK'
    'BTCOADH AND FDNADOX_H AND ACOAD1','ACOAD1','ACOAD1i'
    'ACKr AND ACEDIPIT AND APAT AND DAPDA AND 26DAPLLAT','26DAPLLAT','26DAPLLATi'
    'ACKr AND ACEDIPIT AND APAT AND DAPDA','DAPDA','DAPDAi'
    'MALNAt AND NAt3_1 AND MALt2r','NAt3_1','NAt3'
    'MALNAt AND NAt3_1 AND MALt2r','MALt2r','MALt2'
    'MALNAt AND NAt3_1 AND MALt2r AND URIt2r AND URIt4','URIt2r','URIt2'
    'DADNt2r AND HYXNt','HYXNt','HYXNti'
    'URIt2r AND URAt2r','URAt2r','URAt2'
    'XANt2r AND URAt2r','URAt2r','URAt2'
    'XANt2r AND CSNt6','CSNt6','CSNt2'
    'XANt2r AND DADNt2r','XANt2r','XANt2'
    'XANt2r AND XPPTr','XPPTr','XPPT'
    'XANt2r AND PUNP7','XANt2r','XANt2'
    'r1667 AND ARGt2r','ARGt2r','ARGt2'
    'GLUt2r AND NAt3_1 AND GLUt4r','GLUt4r','r1144'
    'GLYt2r AND NAt3_1 AND GLYt4r','GLYt2r','GLYt2'
    'MALNAt AND L_LACNa1t AND L_LACt2r','L_LACt2r','L_LACt2'
    'G3PD8 AND SUCD4 AND G3PD1','G3PD8','G3PD8i'
    'ACOAD1 AND ACOAD1f AND SUCD4','ACOAD1f','ACOAD1fi'
    'PGK AND D_GLY3PR','D_GLY3PR','D_GLY3PRi'
    'r0010 AND H2O2D','H2O2D','NPR'
    'ACCOACL AND BTNCL','BTNCL','BTNCLi'
    'r0220 AND r0318','r0318','r0318i'
    'MTHFRfdx AND FDNADOX_H','FDNADOX_H',[]
    'FDNADOX_H AND FDX_NAD_NADP_OX','FDX_NAD_NADP_OX','FDX_NAD_NADP_OXi'
    'r1088','r1088','CITt2'
    'NACUP AND NACt2r','NACUP',[]
    'NCAMUP AND NCAMt2r','NCAMUP',[]
    'ORNt AND ORNt2r','ORNt',[]
    'FORt AND FORt2r','FORt',[]
    'ARABt AND ARABDt2','ARABt',[]
    'ASPte AND ASPt2_2','ASPte',[]
    'ASPte AND ASPt2_3','ASPte',[]
    'ASPt2 AND ASPt2_2','ASPt2',[]
    'ASPt2 AND ASPt2_3','ASPt2',[]
    'THYMDt AND THMDt2r','THYMDt',[]
    'CBMK AND CBMKr','CBMKr',[]
    'SPTc AND TRPS2r AND TRPAS2','TRPS2r','TRPS2'
    'PROD3 AND PROD3i','PROD3',[]
    'PROPAT4te AND PROt2r AND PROt2','PROt2r',[]
    'CITt10i AND CITCAt AND CITCAti','CITCAt',[]
    'GUAt2r AND GUAt','GUAt2r','GUAt2'
    'PROPAT4te AND PROt4r AND PROt4','PROt4r',[]
    'INSt2 AND INSt','INSt2','INSt2i'
    'GNOXuq AND GNOXuqi','GNOXuq',[]
    'GNOXmq AND GNOXmqi','GNOXmq',[]
    'RBPC AND PRKIN','PRKIN','PRKINi'
    % 'MMSAD5 AND MSAS AND MALCOAPYRCT AND PPCr AND ACALD','ACALD','ACALDi'
    'PGK AND G1PP AND G16BPS AND G1PPT','G16BPS','G16BPSi'
    'FRD7 AND SUCD1 AND G3PD8','G3PD8','G3PD8i'
    'PROPAT4te AND PROt2r','PROt2r','PROt2'
    'LACLi AND PPCr AND RPE AND PKL AND FTHFL AND MTHFC','MTHFC','MTHFCi'
    'RMNt2 AND RMNt2_1','RMNt2_1',[]
    'MNLpts AND MANAD_D AND MNLt6','MNLt6','MNLt6i'
    'FDNADOX_H AND SULRi AND FXXRDO','FXXRDO','FXXRDOi'
    'FDNADOX_H AND AKGS AND BTCOADH AND OOR2r','OOR2r','OOR2'
    'FDNADOX_H AND AKGS AND BTCOADH AND OOR2 AND POR4','POR4','POR4i'
    'FDNADOX_H AND AKGS AND OAASr AND ICDHx AND POR4i','ICDHx','ICDHxi'
    'FDNADOX_H AND AKGS AND OAASr AND ICDHx AND POR4','ICDHx','ICDHxi'
    'GLXS AND GCALDL AND GCALDDr','GCALDDr','GCALDD'
    'GLYCLTDxr AND GLYCLTDx','GLYCLTDxr',[]
    'GCALDD AND GCALDDr','GCALDDr',[]
    'BGLA AND BGLAr','BGLAr',[]
    'AKGMAL AND MALNAt AND AKGt2r','AKGt2r','AKGt2'
    'TRPS1 AND TRPS2r AND TRPS3r','TRPS2r','TRPS2'
    'OAACL AND OAACLi','OAACL',[]
    'DHDPRy AND DHDPRyr','DHDPRyr',[]
    'EDA_R AND EDA','EDA_R',[]
    'GLYC3Pt AND GLYC3Pti','GLYC3Pt',[]
    'FA180ACPHrev AND STCOATA AND FACOAL180','FACOAL180','FACOAL180i'
    'CITt2 AND CAt4i AND CITCAt','CITCAt','CITCAti'
    'CITt2pp AND CAt4i AND CITCAt','CITCAt','CITCAti'
    'AHCYSNS_r AND AHCYSNS','AHCYSNS_r',[]
    'FDOXR AND GLFRDO AND OOR2r AND FRDOr','FRDOr','FRDO'
    'GNOX AND GNOXy AND GNOXuq AND GNOXmq','GNOXmq','GNOXmqi'
    'GNOX AND GNOXy AND GNOXuq AND GNOXmqi','GNOXuq','GNOXuqi'
    'SHSL1r AND SHSL2 AND SHSL4r','SHSL4r','SHSL4'
    'AHSERL3 AND CYSS3r AND METSOXR1r AND SHSL4r AND TRDRr','TRDRr','TRDR'
    'ACACT1r AND ACACt2 AND ACACCTr AND OCOAT1r','OCOAT1r','OCOAT1'
    'ACONT AND ACONTa AND ACONTb','ACONT',[]
    'ALAt2r AND ALAt4r','ALAt2r','ALAt2'
    'CYTK2 AND DCMPDA AND URIDK3','DCMPDA','DCMPDAi'
    'MALNAt AND NAt3_1 AND PIt7ir','NAt3_1','NAt3'
    'PIt6b AND PIt7ir','PIt6b','PIt6bi'
    'LEUTA AND LLEUDr','LLEUDr','LLEUD'
    'ILETA AND L_ILE3MR','L_ILE3MR','L_ILE3MRi'
    'TRSARry AND TRSARr','TRSARr','TRSAR'
    'THRD AND THRAr AND PYRDC','THRAr','THRAi'
    'THRD AND GLYAT AND PYRDC','GLYAT','GLYATi'
    'SUCD1 AND SUCD4 AND SUCDimq AND NADH6','SUCD1','SUCD1i'
    'POR4 AND SUCDimq AND NADH6 AND PDHa AND FRD7 AND FDOXR AND NTRIR4','POR4','POR4i'
    'SUCDimq AND NADH6 AND HYD1 AND HYD4 AND FRD7 AND FDOXR AND NTRIR4','FDOXR','FDOXRi'
    'PPCr AND SUCOAS AND OAASr AND ICDHx AND POR4i AND ACONTa AND ACONTb AND ACACT1r AND 3BTCOAI AND OOR2r','ICDHx','ICDHxi'
    'PYNP1r AND CSNt6','PYNP1r','PYNP1'
    'ASPK AND ASAD AND HSDy','ASPK','ASPKi'
    'GLUt2r AND GLUABUTt7 AND ABTAr','GLUt2r','GLUt2'
    'DURAD AND DHPM1 AND UPPN','DURAD','DURADi'
    'XU5PG3PL AND PKL','PKL',[]
    'G16BPS AND G1PPT AND PGK AND GAPD_NADP AND GAPD','G16BPS','G16BPSi'
    'G1PPT AND PGK AND GAPD_NADP AND GAPD','G1PPT','G1PPTi'
    'PPIt2e AND GUAPRT AND AACPS6 AND GALT','PPIt2e','PPIte'
    'PPIt2e AND GLGC AND NADS2 AND SADT','PPIt2e','PPIte'
    'MCOATA AND MALCOAPYRCT AND C180SNrev','MCOATA','MACPMT'
    'PPCr AND MALCOAPYRCT AND MMSAD5 AND MSAS','PPCr','PPC'
    'PPCr AND PYK AND ACTLDCCL AND HEDCHL AND OAAKEISO','PPCr','PPC'
    'PPCr AND NDPK9 AND OAACL','PPCr','PPC'
    'PPCr AND PYK AND ACPACT AND TDCOATA AND MCOATA AND HACD6','PPCr','PPC'
    'ACt2r AND ACtr','ACtr',[]
    'LEUt2r AND LEUtec','LEUtec',[]
    'PTRCt2r AND PTRCtex2','PTRCtex2',[]
    'TYRt2r AND TYRt','TYRt',[]
    'OCBT AND CITRH AND CBMKr','CBMKr','CBMK'
    'TSULt2 AND SO3t AND H2St AND TRDRr','TRDRr','TRDR'
    'AMPSO3OX AND SADT AND EX_h2s(e) AND CHOLSH','AMPSO3OX','AMPSO3OXi'
    'GALt2_2 AND GALt1r','GALt2_2','GALt2_2i'
    'HISCAT1 AND HISt2r','HISt2r','HISt2'
    'LDH_L AND L_LACDr','L_LACDr','L_LACD'
    'ALAPAT4te AND ALAt4r','ALAt4r','ALAt4'
    'UCO2L AND BUAMDH AND BURTADH AND H2CO3D','UCO2L','UCO2Li'
    'r1106 AND RIBFLVt2r','RIBFLVt2r','RIBFLVt2'
    'FDOXR AND NADH7 AND NTRIR4','FDOXR','FDOXRi'
    'NADH6 AND SNG3POR AND G3PD2','SNG3POR','G3PD5'
    'PPCOAOc AND NADH6 AND ACOAR','PPCOAOc','PPCOAOci'
    'PGK AND G1PP AND G16BPS AND G1PPTi','G16BPS','G16BPSi'
    'FACOAL140 AND FA140ACPH','FACOAL140','FACOAL140i'
    'R5PAT AND PRPPS AND NADN AND NAPRT','R5PAT','R5PATi'
    'R5PAT AND ADPRDPTS AND PPM','R5PAT','R5PATi'
    'MCCCr AND HMGCOAS AND MGCOAH AND ACOAD8 AND ACACT1r','MCCCr','MCCC'
    'FRUpts AND FRUt2r','FRUt2r','FRUt1r'
    'ALAPAT4te AND ALAt2r','ALAt2r','ALAt2'
    'ALAPAT4te AND ALAt2r','ALAt2r','ALAt2'
    'r2526 AND SERt2r','SERt2r','r2471'
    'PGMT AND G16BPS AND G1PPTi','G16BPS','G16BPSi'
    'ILEt2r AND ILEtec','ILEt2r','ILEt2'
    'VALt2r AND VALtec','VALt2r','VALt2'
    'SUCCt AND SUCCt2r','SUCCt',[]
    'DHLPHEOR AND DHPHEOGAT','DHLPHEOR','DHLPHEORi'
    'SNG3POR AND OOR2r AND FUM AND POR4 AND HPYRI','SNG3POR','G3PD5'
    'NTMAOR AND SUCDimq AND FRD7 AND NADH6','NTMAOR','NTMAORi'
    'PIt6bi AND PIt7','PIt7','PIt7ir'
    'THMt3 AND THMte','THMt3','THMt3i'
    'PROPAT4te AND PROt4r','PROt4r','PROt4'
    'GLUOR AND GALM1r AND NADH6','GLUOR','GLUORi'
    'PGK AND G1PP AND G16BPS AND G1PPT','G1PP','G1PPi'
    'FDOXR AND FDNADOX_H','FDOXR','FDOXRi'
    'FRDOr AND HYD1 AND HYD4','FRDOr','FRDO'
    'ASP4DC AND PYK AND PPCr','ASP4DC','ASP4DCi'
    'NZP_NRe AND NZP_NR','NZP_NRe','NZP_NRei'
    'NFORGLUAH AND 5MTHFGLUNFT AND FOMETR','NFORGLUAH','NFORGLUAHi'
    'FDOXR AND POR4 AND FDH2','FDOXR','FDOXRi'
    'ACGApts AND ACGAMtr2','ACGAMtr2','ACGAMt2'
    'FDNADOX_H AND KLEURFd AND OIVD1r','OIVD1r','OIVD1'
    'CITCAt AND CAt4i AND CITt13','CITCAt','CITCAti'
    '4ABZt2r AND 4ABZt','4ABZt2r','4ABZt2'
    'FUMt2r AND FUMt','FUMt2r','FUMt2'
    'TARCGLYL AND TARTD AND PYRCT','TARCGLYL','TARCGLYLi'
    'SULR AND SO3rDmq AND SUCDimq','SULR','SULRi'
    'CITt15 AND ZN2t4 AND Kt1r AND CITt2','CITt15','CITt15i'
    'FRDO AND FDNADOX_H AND GLFRDO','GLFRDO','GLFRDOi'
    'THMDt2r AND THYMDtr2','THMDt2r','THMDt2'
    'HXANt2r AND HYXNt','HXANt2r','HXANt2'
    'ETOHt2r AND ETOHt','ETOHt2r','ETOHt2'
    'GSNt2r AND GSNt','GSNt2r','GSNt2'
    'FUCt2_1 AND FUCtp','FUCt2_1','FUCt2_1i'
    'GALt4 AND GALt1r','GALt4','GALt4i'
    'PHEt2r AND PHEtec','PHEt2r','PHEt2'
    'ACOAD2f AND ACOAD2 AND NADH6','ACOAD2f','ACOAD2fi'
    'THSr1mq AND TSULt2 AND H2St AND SO3t AND TSULST AND GTHRD AND SUCDimq','TSULt2','TSULt2i'
    'PPCKr AND MALFADO AND ACKr AND PPDK AND PPIACPT','MALFADO','MALFADOi'
    'AKGte AND AKGt2r','AKGt2r','AKGt2'
    '5ASAp AND 5ASAt2r','5ASAt2r','5ASAt2'
    'MAL_Lte AND MALt2r','MALt2r','MALt2'
    'MAL_Lte AND GLUt2r AND MALNAt AND GLUt4r','MALNAt','MALt4'
    'AKGMAL AND MALNAt AND AKGte','MALNAt','MALt4'
    'r0792 AND 5MTHFOX AND FDNADOX_H AND MTHFD2 AND MTHFD','r0792','MTHFR2rev'
    'H2O2D AND CYTBD AND r0010','H2O2D','NPR'
    'PROD3 AND NADH6 AND HPROxr','PROD3','PROD3i'
    'GLFRDO AND GLFRDOi','GLFRDO',[]
    'DGOR AND SBTD_D2 AND GALM1r AND GNOXmq','DGOR','DGORi'
    'DGORi AND SBTD_D2 AND GALM1r AND GNOXmq','GNOXmq','GNOXmqi'
    'DGORi AND SBTD_D2 AND GALM1r AND GNOXuq','GNOXuq','GNOXuqi'
    'LPCDH AND LPCOX AND NADH6pp AND ATPS4pp','LPCDH','LPCDHi'
    'CITt2pp AND CITCAtpp AND CAt4ipp','CITCAt','CITCAti'
    'G1PGTi AND PGMT2 AND G1PPT AND G16BPS','G16BPS','G16BPSi'
    'HISSNAT5tc AND HISt2r','HISt2r','HISt2'
    'TDCOATA AND ACPACT AND FAS140ACPrev','FAS140ACPrev','FAS140ACP'
    'SHCHCS AND 2S6HCC AND ACONTa AND ACONTb AND CITL AND ICDHx','ICDHx','ICDHxi'
    'PPCr AND MALCOAPYRCT AND MMSAD5 AND MMSAD4','PPCr','PPC'
    'SERD_Lr','SERD_Lr','SERD_L'
    'LDH_L AND LDH_L2','LDH_L',[]
    '25DOPOX AND GLCRAL AND D4DGCD','D4DGCD','D4DGCDi'
    'CITt7 AND SUCCt AND CAt4i AND CITCAt','CITCAt','CITCAti'
    'HEDCHL AND OAAKEISO AND ACTLDCCL','ACTLDCCL','ACTLDCCLi'
    'ADNt AND ADNCNT3tc','ADNCNT3tc','ADNt2'
    'PGMT AND G1PP AND GK_adp_','G1PP','G1PPi'
    'LPCDH AND LPCOX AND NADH6','LPCDH','LPCDHi'
    'THMtrbc AND THMt3','THMtrbc','THMti'
    'MAN6PI AND HEX4 AND DCLMPDOH AND HMR_7271 AND PMANM','PMANM','PMANMi'
    'DRPAr AND r0570 AND ACALD AND DURIPP AND PYNP2r AND DURI2OR','DURI2OR','DURI2ORi'
    'PYDAMtr AND PYDAMt','PYDAMtr',[]
    'ENO AND GLXS AND PGM AND PGK AND TPI AND OAACL','OAACL','OAACLi'
    'NAt3_1 AND SUCCt2r AND SUCCt4_3','SUCCt4_3','SUCCt4_3i'
    'PNTOt2 AND PNTOte','PNTOt2','PNTOt2i'
    'r0974 AND PNTOte','r0974','PNTOt4'
    'ARGSL AND ARGSSr AND ARGDr AND ACS AND ACKr AND PTAr','ARGSSr','ARGSS'
    'METt2r AND METt3r','METt2r','METt2'
    'GLUOOR AND GLUR AND H2O2D','H2O2D','NPR'
    'TMAt2r AND TMAOR2e AND TMAOt2r','TMAOR2e','TMAOR2ei'
    'ORNt2r AND PROPAT4te AND r2018 AND r1667','ORNt2r','ORNt2'
    'G1PP AND PGMT AND XYLI2 AND MAN6PI AND PNPHPT','G1PP','G1PPi'
    'DCLMPDOH AND HMR_7271 AND MAN1PT2 AND PMANM','PMANM','PMANMi'
    'ADEt2r AND ADEt','ADEt2r','ADEt2'
    'PPCr AND PPC','PPCr',[]
    'DGLU6Pt2 AND G6Pt6_2 AND PIt7 AND NAt3_1','PIt7','PIt7ir'
    'LEUt2r AND r1642 AND PROPAT4te','PROPAT4te','PROte'
    'AGPAT120 AND PLIPA2A120 AND FA120ACPH','FA120ACPH','FA120ACPHi'
    'AGPAT160 AND PLIPA2A160 AND FA160ACPH','FA160ACPH','FA160ACPHi'
    'GLUt2r AND GLUDy AND GLUt4r','GLUt2r','GLUt2'
    'ACOATA AND KAS14 AND C180SNrev AND 3HAD100','C180SNrev','C180SN'
    'ECOAH5 AND HACD2 AND HACD5 AND ACACT1r','ACACT1r','ACACT1'
    'FOLt2 AND FOLt','FOLt','FOLTle'
    'BTNt2 AND BTNT5r','BTNt2','BTNt2i'
    'AGOR AND SBTPD AND SBTpts AND SBTt6','SBTt6','SBTt6i'
    'PGM AND PGMT AND G16BPS AND G1PPT','G16BPS','G16BPSi'
    'EX_HC00319(e) AND MALNt AND C180SNrev AND ACACPT','C180SNrev','C180SN'
    'TRPt2r AND TRPt','TRPt2r','TRPt2'
    '2S6HCC AND SHCHCS AND SSALxr AND OOR2r AND SUCOAS','SSALxr','SSALx'
    'ADK8 AND NDPK7 AND NTP13','NTP13','NTP13i'
    'ADK10 AND NDPK4 AND NTP9','NTP9','NTP9i'
    'ADK1 AND NDPK4 AND NTP9','NTP9','NTP9i'
    'RE0583C AND SUCD1 AND ACOAD8f','ACOAD8f','ACOAD8fi'
    'TYRAL AND 4HBZOR AND 4HBZCL AND TYRL','4HBZCL','4HBZCLi'
    'NADH8 AND H2Ot AND SO3rDdmq AND SO3t AND H2St','SO3t','SO3ti'
    'PHE_Ltex AND PHEt2rpp AND PHEtec','PHEtec',[]
    'TYR_Ltex AND TYRt2rpp AND TYRt','TYRt',[]
    'LYSt3rpp AND LYS_Ltex AND LYSt2r','LYSt2r',[]
    'CITt2 AND CITt4_4','CITt4_4','CITt'
    'SUCD1 AND 5MTHFOR','5MTHFOR','5MTHFORi'
    'MLTHFTRU AND AMETRNAMT AND 5MTHCYST AND 5MTHGLUS','AMETRNAMT','AMETRNAMTi'
    'FDNADOX_Hpp AND OXONADPOR AND OOR2r','OOR2r','OOR2'
    'NDP7 AND UMPK','NDP7','NDP7i'
    'RPI AND PNP AND NMNPH AND DRIBI AND NTRK AND RBK_Dr','RBK_Dr','RBK_D'
    'SERAT AND CYSS3r AND TSULST AND GTHRD AND TRDRr','TRDRr','TRDR'
    '3CARLPDH AND r0163c AND r0556c','r0556c','r0556ci'
    'PPCr AND NDPK1 AND PEPCK_re','PEPCK_re','PEPCK'
    'COBALTt AND COBALTt5','COBALTt',[]
    'CLt4r AND r2137','r2137',[]
    'NACSMCTte AND NAt3_1 AND NACUP','NAt3_1','NAt3'
    'DCLMPDOH AND GDPGALP AND GDPMANNE AND HMR_7271','GDPGALP','GDPGALPi'
    };

% List complex medium constraints to test if the pan-model produces
% reasonable ATP flux on this diet.
dietConstraints = table2cell(readtable('ComplexMedium.txt'));
dietConstraints(:, 2) = cellstr(num2str(cell2mat(dietConstraints(:, 2))));

dInfo = dir(panPath);
panModels = {dInfo.name};
panModels = panModels';
panModels(~contains(panModels(:, 1), '.mat'), :) = [];

% Test ATP production and remove futile cycles if applicable.
for i = 1:length(panModels)
    % workaround for models that give an error in readCbModel
    try
        model=readCbModel([panPath filesep panModels{i}]);
    catch
        warning('Model could not be read through readCbModel. Consider running verifyModel.')
        modelStr=load([panPath filesep panModels{i}]);
        modelF=fieldnames(modelStr);
        model=modelStr.(modelF{1});
    end
    
    model = useDiet(model, dietConstraints);
    model = changeObjective(model, 'DM_atp_c_');
    FBA = optimizeCbModel(model, 'max');
    % Ensure that pan-models can still produce biomass
    model = changeObjective(model, 'biomassPan');
    if FBA.f > 100
        for j = 2:size(reactionsToReplace, 1)
            rxns = strsplit(reactionsToReplace{j, 1}, ' AND ');
            go = true;
            for k = 1:size(rxns, 2)
                if isempty(intersect(model.rxns,rxns{k}))
                    RxForm = database.reactions{find(ismember(database.reactions(:, 1), rxns{k})), 3};
                    if contains(RxForm,'[e]') && any(contains(model.mets,'[p]'))
                        newName=[rxns{k} 'pp'];
                        % make sure we get the correct reaction
                        newForm=strrep(RxForm,'[e]','[p]');
                        rxnInd=find(ismember(database.reactions(:, 1), {newName}));
                        if ~isempty(rxnInd)
                            dbForm=database.reactions{rxnInd, 3};
                            if checkFormulae(newForm, dbForm) && any(contains(model.mets,'[p]'))
                                rxns{k}=newName;
                            end
                        end
                    end
                end
                if isempty(find(ismember(model.rxns, rxns{k})))
                    go = false;
                end
            end
            if go
                % account for periplasmatic versions
                replacePP=0;
                RxForm = database.reactions{find(ismember(database.reactions(:, 1), reactionsToReplace{j, 2})), 3};
                if contains(RxForm,'[e]') && any(contains(model.mets,'[p]'))
                    newName=[reactionsToReplace{j, 2} 'pp'];
                    % make sure we get the correct reaction
                    newForm=strrep(RxForm,'[e]','[p]');
                    dbForm=database.reactions{find(ismember(database.reactions(:, 1), {newName})), 3};
                    replacePP=1;
                end
                % Only make the change if biomass can still be produced
                if replacePP && isempty(intersect(model.rxns,reactionsToReplace{j, 2}))
                    modelTest = removeRxns(model, newName);
                else
                    modelTest = removeRxns(model, reactionsToReplace{j, 2});
                end
                if ~isempty(reactionsToReplace{j, 3})
                    RxForm = database.reactions{find(ismember(database.reactions(:, 1), reactionsToReplace{j, 3})), 3};
                    if replacePP
                        % create a new formula
                        RxForm = database.reactions{find(ismember(database.reactions(:, 1), reactionsToReplace{j, 3})), 3};
                        if contains(RxForm,'[e]') && any(contains(model.mets,'[p]'))
                            newName=[reactionsToReplace{j, 3} 'pp'];
                            % make sure we get the correct reaction
                            newForm=strrep(RxForm,'[e]','[p]');
                            rxnInd=find(ismember(database.reactions(:, 1), {newName}));
                            if ~isempty(rxnInd)
                                dbForm=database.reactions{rxnInd, 3};
                                if checkFormulae(newForm, dbForm) && any(contains(model.mets,'[p]'))
                                    RxForm=dbForm;
                                end
                            else
                                % if not present already, add to database
                                RxForm=newForm;
                                database.reactions(size(database.reactions,1)+1,:)={newName,newName,RxForm,'0','','','','','','','',''};
                            end
                        end
                        modelTest = addReaction(modelTest, newName, RxForm);
                    else
                        modelTest = addReaction(modelTest, reactionsToReplace{j, 3}, RxForm);
                    end
                end
                FBA = optimizeCbModel(modelTest, 'max');
                if FBA.f > tol
                    model = modelTest;
                end
            end
        end
        % set back to unlimited medium
        model = changeRxnBounds(model, model.rxns(strmatch('EX_', model.rxns)), -1000, 'l');
        % Rebuild model consistently
        %         model = rebuildModel(model,database);
        save([panPath filesep panModels{i}], 'model');
    end
end

end

function model=buildPanModel(agoraPath, models, taxonToCreate, infoFile, database)
% Builds a pan-model from all models corresponding to strains that belong
% to the respective taxon.

tol = 1e-5;

% List complex medium constraints
dietConstraints = table2cell(readtable('ComplexMedium.txt'));
dietConstraints(:, 2) = cellstr(num2str(cell2mat(dietConstraints(:, 2))));

% temporary fix-for adaptation of AGORA to recent database changes
tempFixes={'EX_indprp(e)','EX_ind3ppa(e)';'INDPRPt2r','IND3PPAt2r';'GDOCAH','';'1H2NPTHi','1H2NPTH';'HSNOOXi','HSNOOX';'SALCACDi','SALCACD';'34DCCBRi','34DCCBR';'URAOXi','URAOX';'SQLEi','SQLE';'34HPPORdci','34HPPORdc';'L_TRPCOOi','L_TRPCOO';'PPHPTi','PPHPT';'CHOLOXi','CHOLOX'};

if size(models, 1) == 1
    model = readCbModel([agoraPath filesep infoFile{models, 1} '.mat']);
    % make adaptations to recent database changes
    for i=1:size(tempFixes,1)
        if find(strcmp(model.rxns,tempFixes{i,1}))
            model=removeRxns(model,tempFixes{i,1});
            if ~isempty(tempFixes{i,2})
                RxnForm = database.reactions(find(ismember(database.reactions(:, 1), tempFixes{i,2})), 3);
                model = addReaction(model, tempFixes{i,2}, 'reactionFormula', RxnForm{1, 1});
            end
        end
    end
    
    % rename biomass reaction to agree with other pan-models
    bio = find(strncmp(model.rxns, 'bio', 3));
    model.rxns{bio, 1} = 'biomassPan';
elseif size(models, 1) > 1
    for k = 1:size(models, 1)
        model = readCbModel([agoraPath filesep infoFile{models(k), 1} '.mat']);
        % make adaptations to recent database changes
        for i=1:size(tempFixes,1)
            if find(strcmp(model.rxns,tempFixes{i,1}))
                model=removeRxns(model,tempFixes{i,1});
                if ~isempty(tempFixes{i,2})
                    RxnForm = database.reactions(find(ismember(database.reactions(:, 1), tempFixes{i,2})), 3);
                    model = addReaction(model, tempFixes{i,2}, 'reactionFormula', RxnForm{1, 1});
                end
            end
        end
        bio = find(strncmp(model.rxns, 'bio', 3));
        if k == 1
            panModel.rxns = model.rxns;
            panModel.grRules = model.grRules;
            panModel.rxnNames = model.rxnNames;
            panModel.subSystems = model.subSystems;
            panModel.lb = model.lb;
            panModel.ub = model.ub;
            forms = printRxnFormula(model, model.rxns, false, false, false, [], false);
            panModel.formulas = forms;
            % biomass products and substrates with coefficients
            bioPro = model.mets(find(model.S(:, bio) > 0), 1);
            bioProSC = full(model.S(find(model.S(:, bio) > 0), bio));
            bioSub = model.mets(find(model.S(:, bio) < 0), 1);
            bioSubSC = full(model.S(find(model.S(:, bio) < 0), bio));
        else
            panModel.rxns = [panModel.rxns; model.rxns];
            panModel.grRules = [panModel.grRules; model.grRules];
            panModel.rxnNames = [panModel.rxnNames; model.rxnNames];
            panModel.subSystems = [panModel.subSystems; model.subSystems];
            panModel.lb = [panModel.lb; model.lb];
            panModel.ub = [panModel.ub; model.ub];
            forms = printRxnFormula(model, model.rxns, false, false, false, [], false);
            panModel.formulas = [panModel.formulas; forms];
            % biomass products and substrates with coefficients
            bioPro = [bioPro; model.mets(find(model.S(:, bio) > 0), 1)];
            bioProSC = [bioProSC; full(model.S(find(model.S(:, bio) > 0), bio))];
            bioSub = [bioSub; model.mets(find(model.S(:, bio) < 0), 1)];
            bioSubSC = [bioSubSC; full(model.S(find(model.S(:, bio) < 0), bio))];
        end
    end
    % take out biomass reactions
    bio = find(strncmp(panModel.rxns, 'bio', 3));
    panModel.rxns(bio) = [];
    panModel.grRules(bio) = [];
    panModel.rxnNames(bio) = [];
    panModel.subSystems(bio) = [];
    panModel.lb(bio) = [];
    panModel.ub(bio) = [];
    panModel.formulas(bio) = [];
    % set up data matrix for rBioNet
    [uniqueRxns, oldInd] = unique(panModel.rxns);
    rbio.data = cell(size(uniqueRxns, 1), 14);
    rbio.data(:, 1) = num2cell(ones(size(rbio.data, 1), 1));
    rbio.data(:, 2) = uniqueRxns;
    rbio.data(:, 3) = panModel.rxnNames(oldInd);
    rbio.data(:, 4) = panModel.formulas(oldInd);
    rbio.data(:, 6) = panModel.grRules(oldInd);
    rbio.data(:, 7) = num2cell(panModel.lb(oldInd));
    rbio.data(:, 8) = num2cell(panModel.ub(oldInd));
    rbio.data(:, 10) = panModel.subSystems(oldInd);
    rbio.description = cell(7, 1);
    % build model with rBioNet
    model = data2model(rbio.data, rbio.description, database);
    % build biomass reaction from average of all biomasses
    subs = unique(bioSub);
    prods = unique(bioPro);
    bioForm = '';
    for s = 1:size(subs, 1)
        indS = find(ismember(bioSub, subs{s, 1}));
        newCoeff = sum(bioSubSC(indS)) / k;
        bioForm = [bioForm, num2str(-newCoeff), ' ', subs{s, 1}, ' + '];
    end
    bioForm = bioForm(1:end - 3);
    bioForm = [bioForm, ' -> '];
    for p = 1:size(prods, 1)
        indP = find(ismember(bioPro, prods{p, 1}));
        newCoeff = sum(bioProSC(indP)) / k;
        bioForm = [bioForm, num2str(newCoeff), ' ', prods{p, 1}, ' + '];
    end
    bioForm = bioForm(1:end - 3);
    % add biomass reaction to pan model
    model = addReaction(model, 'biomassPan', bioForm);
    model.comments{end + 1, 1} = '';
    model.citations{end + 1, 1} = '';
    model.rxnConfidenceScores{end + 1, 1} = '';
    model.rxnECNumbers{end + 1, 1} = '';
    model.rxnKEGGID{end + 1, 1} = '';
end
% update some fields to new standards
model.osenseStr = 'max';
if isfield(model, 'rxnConfidenceScores')
    model = rmfield(model, 'rxnConfidenceScores');
end
model.rxnConfidenceScores = zeros(length(model.rxns), 1);
for k = 1:length(model.rxns)
    model.subSystems{k, 1} = cellstr(model.subSystems{k, 1});
    model.rxnKEGGID{k, 1} = '';
    model.rxnECNumbers{k, 1} = '';
end
for k = 1:length(model.mets)
    if strcmp(model.metPubChemID{k, 1}, '[]') || isempty(model.metPubChemID{k, 1})
        model.metPubChemID{k, 1} = string;
    end
    if strcmp(model.metChEBIID{k, 1}, '[]') || isempty(model.metChEBIID{k, 1})
        model.metChEBIID{k, 1} = string;
    end
    if strcmp(model.metKEGGID{k, 1}, '[]') || isempty(model.metKEGGID{k, 1})
        model.metKEGGID{k, 1} = string;
    end
    if strcmp(model.metInChIString{k, 1}, '[]') || isempty(model.metInChIString{k, 1})
        model.metInChIString{k, 1} = string;
    end
    if strcmp(model.metHMDBID{k, 1}, '[]') || isempty(model.metHMDBID{k, 1})
        model.metHMDBID{k, 1} = string;
    end
end
model.metPubChemID = cellstr(model.metPubChemID);
model.metChEBIID = cellstr(model.metChEBIID);
model.metKEGGID = cellstr(model.metKEGGID);
model.metInChIString = cellstr(model.metInChIString);
model.metHMDBID = cellstr(model.metHMDBID);
% fill in descriptions
model = rmfield(model, 'description');
model.description.organism = taxonToCreate;
model.description.name = taxonToCreate;
model.description.author = 'https://vmh.life';
model.description.date = date;

% Rebuild model consistently
model = rebuildModel(model,database);
model=changeObjective(model,'biomassPan');

% constrain sink reactions
model.lb(find(strncmp(model.rxns,'sink_',5)))=-1;

% remove duplicate reactions
% Will remove reversible reactions of which an irreversible version is also
% there but keep the irreversible version.
model = useDiet(model,dietConstraints);
[modelRD, removedRxnInd, keptRxnInd] = checkDuplicateRxn(model);
% test if the model can still grow
FBA=optimizeCbModel(modelRD,'max');
if FBA.f > tol
    model=modelRD;
else
    modelTest=model;
    toRM={};
    for j=1:length(removedRxnInd)
        modelRD=removeRxns(modelTest,model.rxns(removedRxnInd(j)));
        modelRD = useDiet(modelRD,dietConstraints);
        FBA=optimizeCbModel(modelRD,'max');
        if FBA.f > tol
            modelTest=removeRxns(modelTest, model.rxns{removedRxnInd(j)});
            toRM{j}=model.rxns{removedRxnInd(j)};
        else
            modelTest=removeRxns(modelTest, model.rxns{keptRxnInd(j)});
            toRM{j}=model.rxns{keptRxnInd(j)};
        end
    end
    model=removeRxns(model,toRM);
end
% remove diet constraints
exch=find(strncmp(model.rxns,'EX_',3));
model=changeRxnBounds(model,model.rxns(exch),-1000,'l');

end
