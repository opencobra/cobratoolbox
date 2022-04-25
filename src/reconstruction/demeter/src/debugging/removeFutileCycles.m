function [model, deletedRxns, addedRxns, gfRxns] = removeFutileCycles(model, biomassReaction, database,unionRxns,constrainedModel)
% Part of the DEMETER pipeline. Resolves reactions that are running in
% infeasible directions and causing futile cycles that result in
% unrealistically high ATP production. All solutions were identified
% through manual inspection. Any new solutions identified for reaction
% combinations not yet encountered by DEMETER may be added.
%
% USAGE:
%
%   [model, deletedRxns, addedRxns, gfRxns] = removeFutileCycles(model, biomassReaction, database,unionRxns,constrainedModel)
%
% INPUTS
% model:               COBRA model structure
% biomassReaction:     Reaction ID of the biomass objective function
% database:            rBioNet reaction database containing min. 3 columns:
%                      Column 1: reaction abbreviation, Column 2: reaction
%                      name, Column 3: reaction formula.
% unionRxns:           Union of reactions from  multiple reconstructions
%                      (only for debugging multi-species models)
% constrainedModels:   COBRA model constrained with defined medium (for
%                      certain steps of DEMETER)
%
% OUTPUT
% model:               COBRA model structure
% deletedRxns:         Deleted reactions that were causing futile cycles
% addedRxns:           Added irreversible versions of the deleted reactions
% gfRxns:              Additional gap-filled reactions needed to enable
%                      growth. Low confidence score.
%
% .. Author:
%       - Almut Heinken, 2016-2019

deletedRxns = {};
addedRxns = {};
gfRxns = {};

tol = 1e-8;

model_old = model;
model = changeObjective(model, biomassReaction);

% load complex medium
constraints = readtable('ComplexMedium.txt', 'Delimiter', 'tab');
constraints=table2cell(constraints);
constraints=cellstr(string(constraints));

% apply complex medium
model = useDiet(model,constraints);

if nargin > 4 && ~isempty(constrainedModel)
    model=constrainedModel;
end

delCnt = 1;
addCnt = 1;

% Create table with information on reactions to replace to remove futile
% cycles. This information was determined manually.
reactionsToReplace = {'if present','if not present','removed','added'
    'LYSt2r AND LYSt3r',[],'LYSt3r','LYSt3'
    'FDHr',[],'FDHr','FDH'
    'EAR40xr',[],'EAR40xr','EAR40x'
    'PROt2r AND PROt4r',[],'PROt4r','PROt4'
    'FOROXAtex AND FORt',[],'FORt',[]
    'NO2t2r AND NTRIR5',[],'NO2t2r','NO2t2'
    'NOr1mq AND NHFRBOr',[],'NHFRBOr','NHFRBO'
    'N2OO AND NHFRBOr',[],'NHFRBOr','NHFRBO'
    'NIR AND L_LACDr',[],'L_LACDr','L_LACD'
    'NARK AND NTRIR5 AND L_LACDr',[],'L_LACDr','L_LACD'
    'PIt6b AND PIt7',[],'PIt7','PIt7ir'
    'ABUTt2r AND GLUABUTt7',[],'ABUTt2r','ABUTt2'
    'ABUTt2r AND ABTAr',[],'ABTAr','ABTA'
    'Kt1r AND Kt3r AND EX_chsterol(e) AND ARGDA',[],'Kt3r','Kt3 AND ASPTA AND PC AND H2CO3D AND ASPNH4L AND r1667 AND EX_orn(e)'
    'Kt1r AND Kt3r','EX_for(e)','Kt3r','Kt3 AND EX_for(e) AND FORt2r'
    'Kt1r AND Kt3r',[],'Kt3r','Kt3'
    'Kt1r AND Kt2r',[],'Kt2r','Kt2'
    'Kt1r AND Kt3r AND ACtr',[],'Kt3r AND ACtr','Kt3 AND ACt2r'
    'CYTDt4 AND CYTDt2r',[],'CYTDt2r','CYTDt2'
    'ASPt2_2 AND ASPt2r',[],'ASPt2_2','ASPt2_2i'
    'ASPt2_3 AND ASPt2r',[],'ASPt2r','ASPt2'
    'FUMt2_2 AND FUMt2r','FUMt','FUMt2r','FUMt'
    'SUCCt2_2 AND SUCCt2r','SUCCt','SUCCt2r','SUCCt'
    'SUCCt2_3r AND SUCCt2r',[],'SUCCt2r',[]
    'MALFADO AND MDH',[],'MALFADO','MALFADOi'
    'MALFADO AND GLXS',[],'MALFADO','MALFADOi'
    'r0392 AND GLXCL',[],'r0392','ALDD8x'
    'HACD1 AND PHPB2',[],'PHPB2','PHPB2i'
    'PPCKr AND PPCr',[],'PPCKr','PPCK'
    'PPCKr AND GLFRDO AND FXXRDO',[],'PPCKr','PPCK'
    'BTCOADH AND FDNADOX_H AND ACOAD1',[],'ACOAD1','ACOAD1i'
    'ACEDIPIT AND APAT AND DAPDA AND 26DAPLLAT',[],'26DAPLLAT','26DAPLLATi'
    'ACKr AND ACEDIPIT AND APAT AND DAPDA',[],'DAPDA','DAPDAi'
    'ACKr AND ACEDIPIT AND APAT AND DAPDA',[],'DAPDA','DAPDAi AND EX_asp_L(e) AND ASPt2r'
    'MALNAt AND NAt3_1 AND MALt2r',[],'NAt3_1','NAt3'
    'MALNAt AND NAt3_1 AND MALt2r',[],'MALt2r','MALt2'
    'MALNAt AND MAL_Lte AND MALt2r',[],'MALt2r','MALt2'
    'MAL_Lte AND MDH3 AND MALt2r',[],'MALt2r','MALt2'
    'MALNAt AND NAt3_1 AND MALt2r AND URIt2r AND URIt4',[],'URIt2r','URIt2'
    'DADNt2r AND HYXNt',[],'HYXNt','HYXNti'
    'URIt2r AND URAt2r',[],'URAt2r','URAt2'
    'XANt2r AND URAt2r',[],'URAt2r','URAt2'
    'XANt2r AND CSNt6',[],'CSNt6','CSNt2'
    'XANt2r AND DADNt2r',[],'XANt2r','XANt2'
    'XANt2r AND XPPTr',[],'XPPTr','XPPT'
    'XANt2r AND PUNP7',[],'XANt2r','XANt2'
    'r1667 AND ARGt2r',[],'ARGt2r','ARGt2'
    'PIt7 AND NAt3_1 AND GLUt4r',[],'GLUt4r','r1144'
    'GLUt2r AND NAt3_1 AND GLUt4r',[],'GLUt4r','r1144'
    'GLYt2r AND NAt3_1 AND GLYt4r',[],'GLYt2r','GLYt2'
    'GLUt2r AND NAt3 AND GLUt4r',[],'GLUt4r','r1144'
    'L_LACNa1t AND L_LACt2r',[],'L_LACt2r','L_LACt'
    'ACOAD1 AND ACOAD1f AND SUCD4',[],'ACOAD1f','ACOAD1fi'
    'PGK AND D_GLY3PR',[],'D_GLY3PR','D_GLY3PRi'
    'ACCOACL AND BTNCL',[],'BTNCL','BTNCLi'
    'r0220 AND r0318',[],'r0318','r0318i'
    'MTHFRfdx AND FDNADOX_H',[],'FDNADOX_H',[]
    'FDNADOX_H AND FDX_NAD_NADP_OX',[],'FDX_NAD_NADP_OX','FDX_NAD_NADP_OXi'
    'PROPAT4te AND PROt2r',[],'PROt2r','PROt2'
    'G3PD8 AND GLYC3Pt',[],'GLYC3Pt','GLYC3Pti'
    'OAACL AND PPCr AND NDPK9',[],'OAACL','OAACLi'
    'OAACL AND PPCr AND NDPK3',[],'OAACL','OAACLi'
    'OAACL AND ASPTA AND NDPK9',[],'OAACL','OAACLi'
    'OAACL AND ASPTA AND PPDK',[],'OAACL','OAACLi'
    'CBMKr AND OCBT AND CITRH','ARGDA','CBMKr','CBMK'
    'SPTc AND r0392 AND GHMT2r',[],'GHMT2r','GHMT2'
    'OAACL AND OAASr AND NDPK9',[],'OAASr','OAAS'
    'G16BPS AND G1PP AND G1PPT',[],'G16BPS','G16BPSi'
    'ASPK AND ASAD AND HSDx',[],'ASPK','ASPKi'
    'BTCOADH AND ACOAD1f AND FDNADOX_H',[],'ACOAD1f','ACOAD1fi'
    'TARCGLYL AND TARTD AND PYK',[],'TARCGLYL','TARCGLYLi'
    'HPROxr AND PROD3',[],'PROD3','PROD3i'
    'RBPC AND PRKIN',[],'PRKIN','PRKINi'
    'MGt5 AND CITt10 AND CITCAt',[],'CITt10','CITt10i'
    'MGt5 AND CITt10 AND CITCAt',[],'CITCAt','CITCAti'
    'CAt4i AND CITCAt AND r1088',[],'r1088','CITt2'
    'CAt4i AND CITCAt AND r1088',[],'CITCAt','CITCAti'
    'SUCCt AND CITt7 AND r1088',[],'r1088','CITt2'
    'MMSAD5 AND MALCOAPYRCT AND MMSAD4',[],'MMSAD4','MMSAD4i'
    'NTRIR5 AND FDOXR AND FDNADOX_H',[],'NTRIR5','NTRIR5i'
    'GLFRDO AND FRDOr AND FDNADOX_H',[],'FRDOr','FRDO'
    'GCALDL AND r0392 AND GCALDDr',[],'GCALDDr','GCALDD'
    'ACACT1r AND SUCOAS AND OCOAT1r',[],'OCOAT1r','OCOAT1'
    'FDNADOX_H AND BTCOADH AND MAOX2 AND GLFRDO',[],'GLFRDO','GLFRDOi'
    'PYRCT AND SUCOAS AND PPCr',[],'PPCr','PPC'
    '3CARLPDH AND r0163c AND r0556c',[],'r0556c','r0556ci'
    'NACUP AND NACt2r',[],'NACUP',[]
    'NACt AND NACt2r',[],'NACt',[]
    'NCAMUP AND NCAMt2r',[],'NCAMUP',[]
    'ORNt AND ORNt2r',[],'ORNt',[]
    'FORt AND FORt2r',[],'FORt',[]
    'ARABt AND ARABDt2',[],'ARABt',[]
    'ASPte AND ASPt2_2',[],'ASPte',[]
    'ASPte AND ASPt2_3',[],'ASPte',[]
    'ASPt2 AND ASPt2_2',[],'ASPt2',[]
    'ASPt2 AND ASPt2_3',[],'ASPt2',[]
    'THYMDt AND THMDt2r',[],'THYMDt',[]
    'CBMK AND CBMKr',[],'CBMKr',[]
    'SPTc AND TRPS2r AND TRPAS2',[],'TRPS2r','TRPS2'
    'PROD3 AND PROD3i',[],'PROD3',[]
    'PROPAT4te AND PROt2r AND PROt2',[],'PROt2r',[]
    'CITt10i AND CITCAt AND CITCAti',[],'CITCAt',[]
    'GUAt2r AND GUAt',[],'GUAt2r','GUAt2'
    'PROPAT4te AND PROt4r AND PROt4',[],'PROt4r',[]
    'INSt2 AND INSt',[],'INSt2','INSt2i'
    'GNOXuq AND GNOXuqi',[],'GNOXuq',[]
    'GNOXmq AND GNOXmqi',[],'GNOXmq',[]
    'MMSAD5 AND MSAS AND MALCOAPYRCT AND PPCr AND ACALD',[],'ACALD','ACALDi'
    'PGK AND G1PP AND G16BPS AND G1PPT',[],'G16BPS','G16BPSi'
    'LACLi AND PPCr AND RPE AND PKL AND FTHFL AND MTHFC',[],'MTHFC','MTHFCi'
    'RMNt2 AND RMNt2_1',[],'RMNt2_1',[]
    'MNLpts AND MANAD_D AND MNLt6',[],'MNLt6','MNLt6i'
    'FDNADOX_H AND SULRi AND FXXRDO',[],'FXXRDO','FXXRDOi'
    'FDNADOX_H AND SO3R AND FXXRDO',[],'FXXRDO','FXXRDOi'
    'FDNADOX_H AND AKGS AND BTCOADH AND OOR2r',[],'OOR2r','OOR2'
    'FDNADOX_H AND AKGS AND BTCOADH AND OOR2 AND POR4',[],'POR4','POR4i'
    'FDNADOX_H AND AKGS AND OAASr AND ICDHx AND POR4i',[],'ICDHx','ICDHxi'
    'GLXS AND GCALDL AND GCALDDr',[],'GCALDDr','GCALDD'
    'GLYCLTDxr AND GLYCLTDx',[],'GLYCLTDxr',[]
    'GCALDD AND GCALDDr',[],'GCALDDr',[]
    'BGLA AND BGLAr',[],'BGLAr',[]
    'AKGMAL AND MALNAt AND AKGt2r',[],'AKGt2r','AKGt2'
    'AKGte AND MAL_Lte AND AKGt2r',[],'AKGt2r','AKGt2'
    'TRPS1 AND TRPS2r AND TRPS3r',[],'TRPS2r','TRPS2'
    'OAACL AND OAACLi',[],'OAACL',[]
    'DHDPRy AND DHDPRyr',[],'DHDPRyr',[]
    'EDA_R AND EDA',[],'EDA_R',[]
    'GLYC3Pt AND GLYC3Pti',[],'GLYC3Pt',[]
    'TDCOATA AND FA140ACPH AND ACS AND FACOAL140',[],'FACOAL140','FACOAL140i'
    'FA180ACPHrev AND STCOATA AND FACOAL180',[],'FACOAL180','FACOAL180i'
    'FA180ACPHrev AND STCOATA AND FACOAL180',[],'FACOAL180','FACOAL180i AND ADK1'
    'CITt2 AND CAt4i AND CITCAt',[],'CITCAt','CITCAti'
    'AHCYSNS_r AND AHCYSNS',[],'AHCYSNS_r',[]
    'FDOXR AND GLFRDO AND OOR2r AND FRDOr',[],'FRDOr','FRDO'
    'GNOX AND GNOXy AND GNOXuq AND GNOXmq',[],'GNOXmq','GNOXmqi'
    'GNOX AND GNOXy AND GNOXuq AND GNOXmqi',[],'GNOXuq','GNOXuqi'
    'SHSL1r AND SHSL2 AND SHSL4r',[],'SHSL4r','SHSL4'
    'AHSERL3 AND CYSS3r AND METSOXR1r AND SHSL4r',[],'TRDRr','TRDR'
    'ACACT1r AND ACACt2 AND ACACCTr AND OCOAT1r',[],'OCOAT1r','OCOAT1'
    'ACONT AND ACONTa AND ACONTb',[],'ACONT',[]
    'ALAt2r AND ALAt4r',[],'ALAt2r','ALAt2'
    'CYTK2 AND DCMPDA AND URIDK3',[],'DCMPDA','DCMPDAi'
    'MALNAt AND NAt3_1 AND PIt7ir',[],'NAt3_1','NAt3'
    'PIt6b AND PIt7ir',[],'PIt6b','PIt6bi'
    'LEUTA AND LLEUDr',[],'LLEUDr','LLEUD'
    'ILETA AND L_ILE3MR',[],'L_ILE3MR','L_ILE3MRi'
    'TRSARry AND TRSARr',[],'TRSARr','TRSAR'
    'THRD AND THRAr AND PYRDC',[],'THRAr','THRAi'
    'THRD AND GLYAT AND PYRDC',[],'GLYAT','GLYATi'
    'SUCD1 AND SUCD4 AND SUCDimq AND NADH6',[],'SUCD1','SUCD1i'
    'POR4 AND SUCDimq AND NADH6 AND PDHa AND FRD7 AND FDOXR AND NTRIR4',[],'POR4','POR4i'
    'SUCDimq AND NADH6 AND HYD1 AND HYD4 AND FRD7 AND FDOXR AND NTRIR4',[],'FDOXR','FDOXRi'
    'PPCr AND SUCOAS AND OAASr AND ICDHx AND POR4i AND ACONTa AND ACONTb AND ACACT1r AND 3BTCOAI AND OOR2r',[],'ICDHx','ICDHxi'
    'ICDHx AND AKGS AND SUCOAS AND PYK AND POR4 AND FDNADOX_H AND PPCr AND ICL AND GLXS AND MDH',[],'ICDHx','ICDHxi'
    'PYNP1r AND CSNt6',[],'PYNP1r','PYNP1'
    'ASPK AND ASAD AND HSDy',[],'ASPK','ASPKi'
    'GLUt2r AND GLUABUTt7 AND ABTAr',[],'GLUt2r','GLUt2'
    'DURAD AND DHPM1 AND UPPN',[],'DURAD','DURADi'
    'XU5PG3PL AND PKL',[],'PKL',[]
    'G16BPS AND G1PPT AND PGK',[],'G16BPS','G16BPSi'
    'G1PPT AND PGK AND GAPD_NADP AND GAPD',[],'G1PPT','G1PPTi'
    'PPIt2e AND GUAPRT AND AACPS6 AND GALT',[],'PPIt2e','PPIte'
    'PPIt2e AND GLGC AND NADS2 AND SADT',[],'PPIt2e','PPIte'
    'MCOATA AND MALCOAPYRCT AND C180SNrev',[],'MCOATA','MACPMT'
    'PPCr AND MALCOAPYRCT AND MMSAD5 AND MSAS',[],'PPCr','PPC'
    'ACt2r AND ACtr',[],'ACtr',[]
    'LEUt2r AND LEUtec',[],'LEUtec',[]
    'PTRCt2r AND PTRCtex2',[],'PTRCtex2',[]
    'TYRt2r AND TYRt',[],'TYRt',[]
    'TSULt2 AND SO3t AND H2St AND TRDRr',[],'TRDRr','TRDR'
    'AMPSO3OX AND SADT AND EX_h2s(e) AND CHOLSH',[],'AMPSO3OX','AMPSO3OXi'
    'NTRIR4 AND FDNADOX_H AND FDOXR',[],'FDOXR','FDOXRi'
    'ASPNH4L AND ASPt2r',[],'ASPNH4L','ASPNH4Li'
    'DDGLKr AND DDGLCNt2r',[],'DDGLKr','DDGLK'
    'ARGSSr',[],'ARGSSr','ARGSS'
    'ARGDr',[],'ARGDr','ARGDA'
    'SERD_Lr',[],'SERD_Lr','SERD_L'
    'G1PP AND GLGC AND GLCP',[],'G1PP','G1PPi'
    'CBMKr AND OCBT AND r1667','ARGDA','CBMKr','CBMK'
    'TRPS3r AND TRPS1 AND TRPS2r',[],'TRPS3r','TRPS3'
    'D_LACD AND L_LACD2 AND L_LACDr',[],'L_LACDr','L_LACD'
    'PYK AND MMSAD5 AND PPCr AND MSAS AND MALCOAPYRCT',[],'PPCr','PPC'
    'MALFADO AND PPCKr AND ME2',[],'MALFADO','MALFADOi'
    'PIabc AND PIt7',[],'PIt7','PIt7ir'
    'G3PFDXOR AND FDNADOX_H',[],'FDNADOX_H','FDNADOX_Hi'
    'POR4 AND FRDOr',[],'FRDOr','FRDO'
    'TRPAS2',[],'TRPAS2','TRPAS2i'
    'TRPS2r',[],'TRPS2r','TRPS2'
    % 'DPCOAt',[],'DPCOAt','DPCOAti'
    'AMPt2r',[],'AMPt2r','AMPt2'
    'dTMPt2r',[],'dTMPt2r','dTMPt2'
    'NADPt',[],'NADPt','NADPti'
    'BTCOADH AND FDOXR AND BUTCTr AND BUTKr AND ACOAD1i AND FDNADOX_H',[],'BTCOADH','BTCOADHi'
    'TRDRr AND THSr1mq AND H2St AND SO3t AND TSULt2',[],'TRDRr','TRDR'
    'TRDRr AND AMPSO3OX2 AND AMPSO3OX AND TSULt2',[],'TRDRr','TRDR'
    'OIVD1r AND KLEURFd',[],'OIVD1r','OIVD1'
    'GALt1r AND GALt2_2',[],'GALt2_2','GALt2_2i'
    'GALt4 AND GALt2_2',[],'GALt2_2','GALt2_2i'
    'GALt1r AND GALt4',[],'GALt4','GALt4i'
    'ACGAt AND ACGAMtr2',[],'ACGAMtr2','ACGAMt2'
    'NTRIR2y AND FDNADOX_H AND FDOXR',[],'FDOXR','FDOXRi'
    'G3PFDXOR AND PGK',[],'G3PFDXOR','G3PFDXORi'
    'GNOXuq AND GNOXmq AND DGOR AND GLUOR AND NADH6',[],'GNOXuq','GNOXuqi'
    'GNOXuq AND GNOXmq AND DGOR AND GLUOR AND NADH6',[],'GNOXmq','GNOXmqi'
    'GNOXmq AND DGOR AND GLUOR AND NADH6',[],'GNOXmq','GNOXmqi'
    'DGOR AND GLUOR AND NADH6',[],'GLUOR','GLUORi'
    'GNOXuq AND GNOXmq AND DGOR AND SBTD_D2 AND NADH6',[],'GNOXuq','GNOXuqi'
    'GNOXuq AND GNOXmq AND DGOR AND SBTD_D2 AND NADH6',[],'GNOXmq','GNOXmqi'
    'GNOXuqi AND GNOXmq AND DGOR AND SBTD_D2 AND NADH6',[],'GNOXmq','GNOXmqi'
    'FACOAL160',[],'FACOAL160','FACOAL160i'
    'FACOAL180',[],'FACOAL180','FACOAL180i'
    'SUCD1 AND SUCCt AND SUCCt2r',[],'SUCCt',[]
    'SUCD4 AND SUCCt AND SUCCt2r',[],'SUCCt',[]
    'CBMKr AND CBMK',[],'CBMK',[]
    'ETOHt2r AND ETOHt',[],'ETOHt',[]
    'ETOHt2r AND ETOHt3',[],'ETOHt2r',[]
    'ETOHt2r AND ETOHt3',[],'ETOHt3',[]
    'DTTPti',[],'DTTPti',[]
    'UCO2L AND BUAMDH AND BURTADH',[],'UCO2L','UCO2Li'
    'SNG3POR',[],'SNG3POR','G3PD5'
    'SNG3POR','SUCCt2r','SNG3POR','G3PD5 AND EX_succ(e) AND SUCCt'
    'SNG3POR',[],'SNG3POR','G3PD5 AND EX_q8(e) AND Q8abc AND EX_2dmmq8(e) AND 2DMMQ8abc'
    'SNG3POR','SUCCt2r','SNG3POR','G3PD5 AND GLYK'
    'NADH6 AND FTMAOR AND NTMAOR',[],'FTMAOR','FTMAORi'
    'NADH6 AND FTMAOR AND NTMAOR',[],'NTMAOR','NTMAORi'
    'NADH6 AND TMAOR1 AND NTMAOR',[],'NTMAOR','NTMAORi'
    'NADH6 AND TMAOR2e AND NTMAOR',[],'TMAOR2e','TMAORdmq'
    'ACOAD2f AND SUCD1 AND PPCOAOc',[],'ACOAD2f','ACOAD2fi'
    'ACOAD2f AND SUCD1 AND PPCOAOc',[],'PPCOAOc','PPCOAOci'
    'ACOAD2fi AND SUCD1i AND PPCOAOc AND ACOAR',[],'PPCOAOc','PPCOAOci'
    'ACOAD2f AND ACOAD2 AND NADH6',[],'ACOAD2f','ACOAD2fi'
    'ACOAD7f AND C180SNrev AND NADH6',[],'ACOAD7f','ACOAD7fi'
    'THRAr AND THRD_L AND OBTFL',[],'THRAr','THRAi'
    'ALAPAT4te AND ALAt2r',[],'ALAt2r','ALAt2'
    'ALAPAT4te AND ALAt4r',[],'ALAt4r','ALAt4'
    'r2526 AND SERt2r',[],'SERt2r','r2471'
    'HISCAT1 AND HISt2r',[],'HISt2r','HISt2'
    'HISCAT1 AND HISt2r','ACCOAC','HISt2r','HISt2 AND DM_q8h2[c] AND EX_lac_L(e) AND L_LACt2r'
    'r1106 AND RIBFLVt2r',[],'RIBFLVt2r','RIBFLVt2'
    'ILEtec AND ILEt2r',[],'ILEt2r','ILEt2'
    'VALtec AND VALt2r',[],'VALt2r','VALt2'
    'NACUP AND NACt2r',[],'NACUP','NACt'
    'NACUP AND NACt2r',[],'NACt2r','NACHORCTL3le'
    'ORNt AND ORNt2r',[],'ORNt2r','ORNt2'
    'SUCCt AND SUCCt2r',[],'SUCCt',[]
    'NZP_NR AND NZP_NRe',[],'NZP_NRe','NZP_NRei'
    'FUCt2_1 AND FUCtp',[],'FUCt2_1','FUCt2_1i'
    'METATr',[],'METATr','METAT'
    'METATr',[],'METATr','METAT AND EX_met_L(e) AND METt2r'
    'PYDXKr',[],'PYDXKr','PYDXK'
    'PYDXKr',[],'PYDXKr','PYDXK AND EX_pydx(e) AND PYDXabc'
    'TMKr',[],'TMKr','TMK'
    'TMKr',[],'TMKr','TMK AND EX_thm(e) AND THMabc'
    'TMPKr',[],'TMPKr','TMPK'
    'TMPKr',[],'TMPKr','TMPK AND EX_thm(e) AND THMabc'
    'NMNATr',[],'NMNATr','NMNAT'
    'NMNATr',[],'NMNATr','NMNAT AND EX_nmn(e) AND NMNP'
    'DDGLKr',[],'DDGLKr','DDGLK'
    'XYLKr',[],'XYLKr','XYLK'
    'RBK_Dr','ARABI','RBK_Dr','RBK_D'
    %  'METSr',[],'METSr','METS'
    %  'METSr',[],'METSr','METS AND EX_met_L(e) AND METt2r'
    'SUCCt2i',[],'SUCCt2i','SUCCt2'
    'THMt3 AND THMte',[],'THMte',[]
    'PPAt2r AND PPAtr',[],'PPAtr',[]
    'PPAt2r AND PPAt2',[],'PPAt2',[]
    'CBMKr AND OCBT AND CITRH',[],'CITRH','CITRHi'
    'DHLPHEOR AND DHPHEOGAT',[],'DHLPHEOR','DHLPHEORi'
    'MCCCr AND ACOAD8 AND ACACT1r AND HMGCOAS AND MGCOAH',[],'MCCCr','MCCC'
    'r0392 AND ALCD19 AND GLYD',[],'r0392','ALDD8x'
    'FDNADOX_H AND BTCOADH AND GLFRDO',[],'GLFRDO','GLFRDOi'
    'RIBFLVt4 AND r1106',[],'RIBFLVt4','RIBFLVt4i'
    'ASP4DC AND PPCr AND ALATA_L',[],'ASP4DC','ASP4DCi'
    'ASP4DC AND PPCr AND PYK',[],'ASP4DC','ASP4DCi'
    'METFR AND FDNADOX_H AND 5MTHFOX',[],'METFR','METFRi'
    'ACOAR AND SUCD1 AND PPCOAOc',[],'PPCOAOc','PPCOAOci'
    'HYD1 AND FRDOr AND HYD4',[],'FRDOr','FRDO'
    'TSULt2 AND THSr1mq AND H2O2D AND SO3t AND THIORDXi',[],'TSULt2','TSULt2i'
    'FDNADOX_H AND HACD1 AND GLFRDO',[],'GLFRDO','GLFRDOi'
    'FDNADOX_H AND HACD1 AND OOR2r',[],'OOR2r','OOR2'
    'FUMt2r AND FUMt',[],'FUMt',[]
    '5ASAt2r AND 5ASAp',[],'5ASAp',[]
    'HMR_0197 AND FACOAL140',[],'FACOAL140','FACOAL140i'
    'SULR AND SO3rDmq AND THSr1mq AND AMPSO3OX',[],'SULR','SULRi'
    'H2St AND TSULt2 AND TSULST AND GTHRD AND THSr1mq',[],'TSULt2','TSULt2i'
    '15DAPt AND CADVt AND LYSt3r',[],'LYSt3r','LYSt3'
    'MAL_Lte AND r1144 AND MALNAt AND GLUt2r',[],'GLUt2r','GLUt2'
    'ACGApts AND ACGAMPM AND ACGAMPT AND ACGAMtr2',[],'ACGAMtr2','ACGAMt2'
    'CHLt2r AND sink_chols AND CHOLSH AND EX_so4(e)',[],'CHLt2r','CHLt2'
    'H2O2D AND CYTBD AND EX_h2o2(e) AND L_LACD2',[],'H2O2D','NPR'
    'AKGt2r AND AKGte',[],'AKGte',[]
    'PHEt2r AND PHEtec',[],'PHEt2r','PHEt2'
    'r0389',[],'r0389','r0389i'
    'SULR AND SULRi',[],'SULR',[]
    'FUCt2_1 AND FUCt',[],'FUCt2_1',[]
    'G6PDH2r AND G6PBDH AND G6PDA AND G6PI',[],'G6PDH2r','G6PDH2'
    % 'CD2t6r AND CD2abc1',[],'CD2t6r','CD2t6'
    'OOR2r AND POR4 AND FRD2 AND FUM AND ACONTb AND ACONTa AND SUCCt AND SUCCt2r',[],'SUCCt','FDNADOX_H'
    'ACKr AND NNAM AND NAPRT AND NACt AND NACt2r',[],'NACt','EX_asp_L(e) AND ASPt2r'
    'HYD4 AND POR4 AND FRD2 AND ACONTb AND ACONTa AND FORt AND FORt2r',[],'FORt2r',[]
    'OOR2r AND ACKr AND FRD2 AND ACONTb AND ACONTa AND FORt AND FORt2r AND ALCD2x AND ACALD AND SUCCt','ETOHt','FORt2r AND SUCCt','EX_etoh(e) AND ETOHt2r AND SUCCt2r'
    'POR4 AND FRD2 AND ACONTb AND ACONTa AND FORt AND FORt2r AND ALCD2x AND ACALD AND SUCCt','ETOHt','FORt2r AND SUCCt','FDNADOX_H AND EX_etoh(e) AND ETOHt2r AND SUCCt2r'
    'OOR2r AND FRD2 AND ACONTb AND ACONTa AND FORt AND FORt2r AND SUCCt AND NTRIR2x','PTAr','FORt2r AND SUCCt','PTAr AND SUCCt2r AND EX_no2(e) AND NO2t2'
    'OOR2r AND FRD2 AND ACONTb AND ACONTa AND FORt AND FORt2r AND SUCCt AND NTRIR2x','ACtr','FORt2r AND SUCCt','EX_ac(e) AND ACtr AND SUCCt2r AND EX_no2(e) AND NO2t2'
    'PIt7 AND EX_na1(e) AND ACKr AND OAASr AND FORt AND FORt2r','PIabc','FORt2r','DM_NA1'
    'ICDHyr AND SUCOAS AND PYK AND FDNADOX_H AND POR4',[],'ICDHyr','ICDHy'
    'ASPt2_2 AND ASPt2r',[],'ASPt2r','ASPte'
    'SUCCt AND SUCCt2r',[],'SUCCt',[]
    'SUCCt AND SUCCt2_2 AND SUCCt2_3',[],'SUCCt',[]
    'ACKr AND ACEDIPIT AND APAT AND DAPDA AND 26DAPLLAT',[],'26DAPLLAT','26DAPLLATi'
    'MALNAt AND L_LACNa1t AND L_LACt2r',[],'L_LACt2r','L_LACt2'
    'r0010 AND H2O2D',[],'H2O2D','NPR'
    'r1088',[],'r1088','CITt2'
    'FDNADOX_H AND AKGS AND OAASr AND ICDHx AND POR4',[],'ICDHx','ICDHxi'
    'CITt2ipp AND CAt4i AND CITCAt',[],'CITCAt','CITCAti'
    'G16BPS AND G1PPT AND PGK AND GAPD_NADP AND GAPD',[],'G16BPS','G16BPSi'
    'PPCr AND PYK AND ACTLDCCL AND HEDCHL AND OAAKEISO',[],'PPCr','PPC'
    'PPCr AND OAACL',[],'OAACL','OAACLi'
    'PPCr AND PYK AND ACPACT AND TDCOATA AND MCOATA AND HACD6',[],'PPCr','PPC'
    'OCBT AND CITRH AND CBMKr',[],'CBMKr','CBMK'
    'LDH_L AND L_LACDr',[],'L_LACDr','L_LACD'
    'UCO2L AND BUAMDH AND BURTADH AND H2CO3D',[],'UCO2L','UCO2Li'
    'FDOXR AND NADH7 AND NTRIR4',[],'FDOXR','FDOXRi'
    'PPCOAOc AND NADH6 AND ACOAR',[],'PPCOAOc','PPCOAOci'
    'PGK AND G1PP AND G16BPS AND G1PPTi',[],'G16BPS','G16BPSi'
    'FACOAL140 AND FA140ACPH',[],'FACOAL140','FACOAL140i'
    'R5PAT AND PRPPS AND NADN AND NAPRT',[],'R5PAT','R5PATi'
    'R5PAT AND ADPRDPTS AND PPM',[],'R5PAT','R5PATi'
    'MCCCr AND HMGCOAS AND MGCOAH AND ACOAD8 AND ACACT1r',[],'MCCCr','MCCC'
    'FRUpts AND FRUt2r',[],'FRUt2r','FRUt1r'
    'PGMT AND G16BPS AND G1PPTi',[],'G16BPS','G16BPSi'
    'ILEt2r AND ILEtec',[],'ILEt2r','ILEt2'
    'VALt2r AND VALtec',[],'VALt2r','VALt2'
    'NTMAOR AND SUCDimq AND FRD7 AND NADH6',[],'NTMAOR','NTMAORi'
    'PIt6bi AND PIt7',[],'PIt7','PIt7ir'
    'PIt6b AND PIt7',[],'PIt7','PIt7ir'
    'THMt3 AND THMte',[],'THMt3','THMt3i'
    'PROPAT4te AND PROt4r',[],'PROt4r','PROt4'
    'GLUOR AND GALM1r AND NADH6',[],'GLUOR','GLUORi'
    'PGK AND G1PP AND G16BPS AND G1PPT',[],'G1PP','G1PPi'
    'FDOXR AND FDNADOX_H',[],'FDOXR','FDOXRi'
    'FRDOr AND HYD1 AND HYD4',[],'FRDOr','FRDO'
    'ASP4DC AND PYK AND PPCr',[],'ASP4DC','ASP4DCi'
    'NZP_NRe AND NZP_NR',[],'NZP_NRe','NZP_NRei'
    'NFORGLUAH AND 5MTHFGLUNFT AND FOMETR',[],'NFORGLUAH','NFORGLUAHi'
    'FDOXR AND POR4 AND FDH2',[],'FDOXR','FDOXRi'
    'ACGApts AND ACGAMtr2',[],'ACGAMtr2','ACGAMt2'
    'FDNADOX_H AND KLEURFd AND OIVD1r',[],'OIVD1r','OIVD1'
    'CITCAt AND CAt4i AND CITt13',[],'CITCAt','CITCAti'
    '4ABZt2r AND 4ABZt',[],'4ABZt2r','4ABZt2'
    'FUMt2r AND FUMt',[],'FUMt2r','FUMt2'
    'TARCGLYL AND TARTD AND PYRCT',[],'TARCGLYL','TARCGLYLi'
    'SULR AND SO3rDmq AND SUCDimq',[],'SULR','SULRi'
    'CITt15 AND ZN2t4 AND Kt1r AND CITt2',[],'CITt15','CITt15i'
    'FRDO AND FDNADOX_H AND GLFRDO',[],'GLFRDO','GLFRDOi'
    'THMDt2r AND THYMDtr2',[],'THMDt2r','THMDt2'
    'HXANt2r AND HYXNt',[],'HXANt2r','HXANt2'
    'GSNt2r AND GSNt',[],'GSNt2r','GSNt2'
    'GALt4 AND GALt1r',[],'GALt4','GALt4i'
    'THSr1mq AND TSULt2 AND H2St AND SO3t AND TSULST AND GTHRD AND SUCDimq',[],'TSULt2','TSULt2i'
    'PPCKr AND MALFADO AND ACKr AND PPDK AND PPIACPT',[],'MALFADO','MALFADOi'
    'AKGte AND AKGt2r',[],'AKGt2r','AKGt2'
    '5ASAp AND 5ASAt2r',[],'5ASAt2r','5ASAt2'
    'MAL_Lte AND MALt2r',[],'MALt2r','MALt2'
    'MAL_Lte AND GLUt2r AND MALNAt AND GLUt4r',[],'MALNAt','MALt4'
    'AKGMAL AND MALNAt AND AKGte',[],'MALNAt','MALt4'
    'r0792 AND 5MTHFOX AND FDNADOX_H AND MTHFD2 AND MTHFD',[],'r0792','MTHFR2rev'
    'H2O2D AND CYTBD AND r0010',[],'H2O2D','NPR'
    'PROD3 AND NADH6 AND HPROxr',[],'PROD3','PROD3i'
    'GLFRDO AND GLFRDOi',[],'GLFRDO',[]
    'DGOR AND SBTD_D2 AND GALM1r AND GNOXmq',[],'DGOR','DGORi'
    'DGORi AND SBTD_D2 AND GALM1r AND GNOXmq',[],'GNOXmq','GNOXmqi'
    'DGORi AND SBTD_D2 AND GALM1r AND GNOXuq',[],'GNOXuq','GNOXuqi'
    'LPCDH AND LPCOX AND NADH6pp AND ATPS4pp',[],'LPCDH','LPCDHi'
    'CITt2pp AND CITCAtpp AND CAt4ipp',[],'CITCAtpp','CITCAtipp'
    'GLFRDO AND FDNADOX_H',[],'FDOXR','GLFRDOi'
    'OOR2r AND FDNADOX_H AND AKGS',[],'OOR2r','OOR2'
    'OAASr AND ICDHx AND ACONTa AND ACONTb AND ALCD2x AND FDH AND PTAr AND ACKr',[],'ICDHx','ICDHxi'
    'METt2r AND METt3r',[],'METt2r','METt2'
    'NTP9 AND NDPK4',[],'NTP9','NTP9i'
    'MAN1PT2r',[],'MAN1PT2r','MAN1PT2'
    'HMR_7271 AND MAN1PT2 AND MAN6PI AND PMANM',[],'PMANM','PMANMi'
    'HMR_7271 AND MAN1PT2 AND MANISO AND PMANM',[],'PMANM','PMANMi'
    'PGMT AND GALU AND GLBRAN AND GLDBRAN AND GLGNS1 AND GLPASE1 AND NDPK2 AND PPA AND r1393',[],'NDPK2','NDPK2i'
    'D_GLUMANt AND MANt2r AND GLU_Dt2r',[],'GLU_Dt2r','GLU_Dt2'
    'NACUP AND NACSMCTte AND NAt3_1',[],'NAt3_1','NAt3'
    'GALU AND DCLMPDOH AND GDPGALP AND GDPMANNE AND GALT',[],'GALT','GALTi'
    'HYD2 AND HYD4 AND NTRIR4 AND FDOXR',[],'FDOXR','FDOXRi'
    'FACOAL181',[],'FACOAL181','FACOAL181i'
    'MAN6PI AND DCLMPDOH AND GDPGALP AND GDPMANNE AND HMR_7271',[],'GDPGALP','GDPGALPi'
    'FE2DH AND FE3Ri AND NADH6 AND SUCD1 AND FRD7',[],'FE2DH','FE2DHi'
    'GLBRAN AND GLDBRAN AND GLGNS1 AND GLPASE1 AND GPDDA1',[],'GLDBRAN',[]
    'CDPDPH AND CYTK1',[],'CDPDPH','CDPDPHi'
    'UMPK AND NDP7',[],'NDP7','NDP7i'
    'CLt4r AND r2137',[],'r2137','CLti'
    'LDH_L2 AND LDH_L',[],'LDH_L',[]
    'HXANtex AND HYXNtipp AND HXANt2r',[],'HXANt2r','HYXNt'
    'SUCCt2rpp AND SUCCtex AND SUCCt',[],'SUCCt',[]
    'POR4 AND FDHfdx AND MTHFRfdx AND GLFRDOi',[],'POR4','POR4i'
    'SUCCt2_3r AND CITt7',[],'SUCCt2_3r','SUCCt2_3'
    '3HPCOAHL AND 3HPCOAS AND ACOAR',[],'3HPCOAHL','3HPCOAHLi'
    'AKGMAL AND MALt2r AND AKGte',[],'MALt2r','MALt2'
    'AKGDa AND 3CARLPDH AND r0163c',[],'AKGDa','AKGDai'
    'L_LACNa1t AND AKGMAL AND L_LACt',[],'L_LACt',[]
    'r0559 AND AEPPT AND ETHAP AND PACTH',[],'r0559','r0559i'
    'HXANt2r AND HYXNti',[],'HYXNti',[]
    'FA141ACPH AND AGPAT141 AND DASYN141 AND G3PAT141',[],'FA141ACPH','FA141ACPHi'
    'DALAt2r AND ALA_Dt',[],'DALAt2r','DALAt2'
    'DALAt2r AND ALA_Dtex',[],'DALAt2r','DALAt2'
    'LCADi AND MTHGXLDH AND LALDO3',[],'LALDO3','LALDO3i'
    'ORNt AND PTRCORNt7 AND PTRCAT AND ABUTR',[],'PTRCAT','PTRCATi'
    'GUAD AND PUNP3 AND PUNP7 AND r1384 AND GUAt2r',[],'GUAt2r','GUAt2'
    'r0480 AND r0788 AND r0789',[],'r0480','r0480'
    'G3PD8 AND G3PPHL AND ALCD19',[],'G3PD8','G3PD8i'
    'G3PD8 AND G3PD1 AND SUCD4',[],'G3PD8','G3PD8i'
    'L_LACt AND L_LACt2r',[],'L_LACt2r','L_LACt2'
    'CODH_ACS AND FTHFL AND METR AND MTHFC AND MTHFD AND PKL',[],'PKL','XU5PG3PL'
    'FTHFL AND TKT1 AND TKT2 AND RPI AND RPE AND MTHFC AND MTHFD AND PKL',[],'PKL','XU5PG3PL'
    'FDH2 AND HYD1 AND HYDFDN2rfdx AND GALM1r AND SUCD4 AND GLUOR',[],'GLUOR','GLUORi'
    'NTMAOR AND SUCD4 AND HYD1',[],'NTMAOR','NTMAORi'
    'ALAt2r AND ALAt4 AND CITt2',[],'ALAt2r','ALAt2'
    'GLUTACCOACL AND GLUTACCOADC AND ACOAD1 AND ACOAD1fi AND r1144',[],'GLUTACCOACL','GLUTACCOACLi'
    'GLUTACCOACL AND GLUTACCOADC AND ACOAD1 AND ACOAD1fi AND MALNAt',[],'GLUTACCOACL','GLUTACCOACLi'
    'GLUTACCOACL AND GLUTACCOADC AND NAt3_1 AND ACOAD1',[],'NAt3_1','NAt3'
    'FXXRDO AND G3PFDXOR AND GAPD AND H2Ot AND H2St AND NADH8 AND PGK AND SO3rDdmq AND SO3t',[],'SO3t','SO3ti'
    'FRD7 AND FRD6 AND NADH6pp','EX_succ(e)','FRD7','SUCDi'
    'FRD3 AND FRD6 AND NADH8','EX_succ(e)','FRD3','SUCDi'
    'FRD7 AND FRD6 AND NADH8','EX_succ(e)','FRD7','SUCDi'
    'FXXRDO AND H2St AND SO3t AND H2Ot AND NADH8 AND SO3rDdmq',[],'FXXRDO','FXXRDOi'
    'CLt4r AND SO4CLtex2 AND SO4t2',[],'SO4t2','SO4t2i'
    'FXXRDO AND PIt6b AND AND NADH8 AND SO3rDdmq',[],'PIt6b','PIt6bi'
    'NACSMCTte AND NACUP AND PIt6b AND r2136',[],'PIt6b','PIt6bi'
    'URIt2r AND URIt',[],'URIt',[]
    'H202D',[],'H202D','NPR'
    'NACSMCTte AND NACUP AND r2136',[],'NACUP',[]
    'NACSMCTte AND NACUP AND URIt2r',[],'NACUP',[]
    % IT 03/2022
    %     'AC5ASAc AND AC5ASAe',[],'AC5ASAe',[]
    'METFR AND r0792',[],'r0792',[]
    %     'FDNADOX_Hipp AND METFR AND MTHFRfdx',[],'METFR',[]
    %     'FDNADOX_Hi AND METFR AND MTHFRfdx',[],'METFR',[]
    'L_LACDr AND D_LACD',[],'L_LACD',[]
    %     'ALCD19 AND FDNADOX_Hi AND FXXRDO AND GLUOX AND GLUSx AND SULRi AND r0245',[],'FDNADOX_Hi',[]
    %     'LACOAAOR AND MDH AND LDH_L2',[],'LACOAAOR',[]
    %     'G3PFDXORi AND GAPD AND HYDFDN2rfdx AND PGK',[],'GAPD',[]
    'FDNADOX_H AND HYDFDN2rfdx',[],'FDNADOX_Hi',[] % or irreversible version
    %'FMNRx AND LDH_L2 AND L_LACD4',[],'L_LACD4i',[] % L_LACD4i needs to be added to rBioNet
    'CITt10i AND CITt4_4 AND LEUt2r AND LEUt4 AND MGt5',[],'CITt10i',[] % not an ideal solution but I cannot see another one
    %     'BTCOADH',[],'BTCOADH','BTCOADHi'
    %     'FTMAOR',[],'FTMAOR','FTMAORi'
    %     'NTMAOR',[],'NTMAOR','NTMAORi'
    'LDH_L2 AND L_LACDr AND METFR AND MTHFRfdx',[],'L_LACDr','L_LACD'
    'LDH_D AND LDH_L2 AND LacR',[],'LDH_D','LDH_Di' % not ideal but I don't see another possibilty
    % 'FMNRx AND LDH_L2 AND L_LACD4',[],'L_LACD4','L_LACD4i' % somehow this L_LACD4i become reversible in the pipeline
    %     'FMNRx AND LDH_L2 AND L_LACD4',[],'LDH_L2',[] % not ideal but should fix this issue % somehow this L_LACD4i become reversible in the pipeline
    'LACLi',[],'LACLi','LACL'
    'ILEt3 AND ILEt2r',[],'ILEt2r','ILEt2'
    % IT 04/2022
    'SUCCt2_2 AND SUCCt2_3r',[],'SUCCt2_2',[]
    'GNOX AND GNOXmq AND GNOXy AND SUCDimq',[],'GNOXmq','GNOXmqi'
    };


% growth-restoring gapfills: needed if the futile cycle was the model's
% only way to produce ATP and growth rate without it is zero. Enables ATP
% production through a more realistic pathway.
growthGapfills={
    'EX_succ(e) AND SUCCt'
    'EX_fum(e) AND FUMt2'
    'EX_succ(e) AND SUCCt2r'
    'EX_fum(e) AND FUMt2 AND EX_succ(e) AND SUCCt2r'
    'EX_for(e) AND FORt2r'
    'EX_ac(e) AND ACt2r'
    'EX_etoh(e) AND ETOHt2r'
    'EX_pyr(e) AND PYRt2r'
    'EX_hco3(e) AND HCO3abc AND H2CO3D'
    % consider adding glycolysis
    'HEX1 AND PFK AND FBA AND TPI AND GAPD AND PGK AND PGM AND ENO AND PYK'
    'HEX1 AND PFK AND FBA AND TPI AND GAPD AND PGK AND PGM AND ENO AND PYK AND EX_etoh(e) AND ETOHt2r'
    'EX_q8(e) AND Q8abc'
    'EX_2dmmq8(e) AND 2DMMQ8abc'
    'DM_q8h2[c]'
    'DM_NA1'
    'G3PFDXORi' % tentative-some models would not produce feasible amounts of ATP without it
    'ASP4DCi' % tentative-some models would not produce feasible amounts of ATP without it
    'EX_lac_L(e) AND L_LACt2r'
    'EX_acald(e) AND ACALDt'
    'EX_asp_L(e) AND ASPt2r'
    'EX_arg_L(e) AND ARGt2r'
    'EX_ser_L(e) AND SERt2r'
    'PPA'
    'EX_glyald[e] AND GLYALDt'
    'ATPS4'
    'ADK1'
    'EX_ac(e) AND ACtr'
    };

for i = 2:size(reactionsToReplace, 1)
    % take other models in a multi-species model into account if applies
    if nargin>3 && ~isempty(unionRxns)
        go = 1;
        present=strsplit(reactionsToReplace{i,1},' AND ');
        if ~(length(intersect(unionRxns,present))==length(present))
            go= 0;
        end
        notpresent=reactionsToReplace{i,2};
        if ~isempty(intersect(unionRxns,notpresent))
            go= 0;
        end
    else
        go = 1;
        present=strsplit(reactionsToReplace{i,1},' AND ');
        if ~(length(intersect(model.rxns,present))==length(present))
            if any(contains(model.mets,'[p]'))
                % if a periplasmatic reaction exists, use that
                for j=1:length(present)
                    if ~isempty(intersect(database.reactions(:,1),[present{j} 'pp']))
                        present{j}=[present{j} 'pp'];
                    end
                end
            end
            if ~(length(intersect(model.rxns,present))==length(present))
                go= 0;
            end
        end
        if ~isempty(reactionsToReplace{i,2})
            notpresent=strsplit(reactionsToReplace{i,2},' AND ');
            if any(contains(model.mets,'[p]'))
                % if a periplasmatic reaction exists, use that
                for j=1:length(notpresent)
                    if ~isempty(intersect(database.reactions(:,1),[notpresent{j} 'pp']))
                    notpresent{j}=[notpresent{j} 'pp'];
                    end
                end
            end
            if length(intersect(model.rxns,notpresent))==length(notpresent)
                go= 0;
            end
        end
    end
    if go == 1
        clear newForm;
        % Only make the change if biomass can still be produced
        toRemove=strsplit(reactionsToReplace{i,3},' AND ');
        for k=1:length(toRemove)
            if isempty(intersect(model.rxns,toRemove{k}))
                RxForm = database.reactions{find(ismember(database.reactions(:, 1), toRemove{k})), 3};
                if contains(RxForm,'[e]')
                    newName=[toRemove{k} 'pp'];
                    % make sure we get the correct reaction
                    newForm=strrep(RxForm,'[e]','[p]');
                    rxnInd=find(ismember(database.reactions(:, 1), {newName}));
                    if ~isempty(rxnInd)
                        dbForm=database.reactions{rxnInd, 3};
                        if checkFormulae(newForm, dbForm) && any(contains(model.mets,'[p]'))
                            toRemove{k}=newName;
                        end
                    end
                end
            end
        end
        modelTest = removeRxns(model, toRemove);
        if ~isempty(reactionsToReplace{i, 4})
            rxns=strsplit(reactionsToReplace{i, 4},' AND ');
            for j=1:length(rxns)
                if isempty(intersect(model.rxns,rxns{j}))
                    % create a new formula

                    RxForm = database.reactions{find(ismember(database.reactions(:, 1), rxns{j})), 3};
                    
                    if contains(RxForm,'[e]') && any(contains(model.mets,'[p]'))
                        newName=[rxns{j} 'pp'];
                        % make sure we get the correct reaction
                        newForm=strrep(RxForm,'[e]','[p]');
                        rxnInd=find(ismember(database.reactions(:, 1), {newName}));
                        if ~isempty(rxnInd)
                            dbForm=database.reactions{rxnInd, 3};
                            if checkFormulae(newForm, dbForm) && any(contains(model.mets,'[p]'))
                                RxForm=dbForm;
                            end
                        end
                        modelTest = addReaction(modelTest, newName, RxForm);
                    else
                        modelTest = addReaction(modelTest, rxns{j}, RxForm);
                    end
                end
            end
        end
        % sometimes oxygen uptake needs to be enabled
        modelTest=changeRxnBounds(modelTest,'EX_o2(e)',-10,'l');
        FBA = optimizeCbModel(modelTest, 'max');
        if FBA.f > tol
            model = modelTest;
            if ~isempty(reactionsToReplace{i, 3})
                for j=1:length(toRemove)
                    deletedRxns{delCnt, 1} = toRemove{j};
                    delCnt = delCnt + 1;
                end
            end
            if ~isempty(reactionsToReplace{i, 4})
                if ~isempty(reactionsToReplace{i, 3}) && length(toRemove)==1
                    addedRxns{addCnt, 1} = toRemove{1};
                end
                if exist('newForm','var')
                    addedRxns{addCnt, j+1} = [rxns{j} 'pp'];
                else
                    addedRxns{addCnt, j+1} = rxns{j};
                end
                addCnt = addCnt + 1;
            end
        else
            % try growth-restoring gapfills
            gf=1;
            modelPrevious=modelTest;
            for k=1:size(growthGapfills,1)
                ggrxns=strsplit(growthGapfills{k, 1},' AND ');
                % to not add reactions that were just flagged for removal
                ggrxns=setdiff(ggrxns,toRemove);
                for j=1:length(ggrxns)
                    % create a new formula
                    RxForm = database.reactions{find(ismember(database.reactions(:, 1), ggrxns{j})), 3};
                    if contains(RxForm,'[e]') && any(contains(model.mets,'[p]'))
                        newName=[ggrxns{j} 'pp'];
                        % make sure we get the correct reaction
                        newForm=strrep(RxForm,'[e]','[p]');
                        rxnInd=find(ismember(database.reactions(:, 1), {newName}));
                        if ~isempty(rxnInd)
                            dbForm=database.reactions{rxnInd, 3};
                            if checkFormulae(newForm, dbForm) && any(contains(model.mets,'[p]'))
                                RxForm=dbForm;
                            end
                        end
                        if isempty(find(contains(model.rxns,newName)))
                            modelTest = addReaction(modelTest, newName, RxForm);
                        end
                    else
                        if isempty(find(strcmp(model.rxns,ggrxns{j})))
                            modelTest = addReaction(modelTest, ggrxns{j}, RxForm);
                        end
                    end
                end
                FBA = optimizeCbModel(modelTest, 'max');
                if FBA.f > tol
                    % ensure this does not add new futile cycles
                    modelATPBefore=changeObjective(model,'DM_atp_c_');
                    fbaATPBefore=optimizeCbModel(modelATPBefore,'max');
                    modelATPAfter=changeObjective(modelTest,'DM_atp_c_');
                    fbaATPAfter=optimizeCbModel(modelATPAfter,'max');
                    if fbaATPAfter.f-fbaATPBefore.f < 100
                        model = modelTest;
                        % add replaced reactions
                        if ~isempty(reactionsToReplace{i, 3})
                            for j=1:length(toRemove)
                                deletedRxns{delCnt, 1} = toRemove{j};
                                delCnt = delCnt + 1;
                            end
                        end
                        if ~isempty(reactionsToReplace{i, 4})
                            if ~isempty(reactionsToReplace{i, 3}) && length(toRemove)==1
                                addedRxns{addCnt, 1} = toRemove{1};
                            end
                            if contains(RxForm,'[e]')  && exist('newForm','var')
                                addedRxns{addCnt, j+1} = [rxns{j} 'pp'];
                            else
                                addedRxns{addCnt, j+1} = rxns{j};
                            end
                            addCnt = addCnt + 1;
                        end
                        % add growth-restoring gapfilled reactions
                        for j=1:length(ggrxns)
                            gfRxns{length(gfRxns)+1, 1} = ggrxns{j};
                        end
                        gf=0;
                        break
                    end
                end
                modelTest=modelPrevious;
            end
        end
    end
end

%% Make the proposed changes
model = model_old;

% remove reactions to delete
model = removeRxns(model, deletedRxns);

% make sure gene rule and notes are kept while replacing
if ~isempty(addedRxns)
    for j = 1:size(addedRxns,1)
        if ~isempty(addedRxns{j,1})
            model = addReaction(model, addedRxns{j, 2}, database.reactions{find(ismember(database.reactions(:, 1), addedRxns{j, 2})), 3});
            % if a reaction from the old version is replaced, keep the GPR
            if ~isempty(addedRxns{j, 1}) && ~isempty(find(ismember(model_old.rxns,addedRxns{j, 1})))
                rxnIDNew=find(ismember(model.rxns,addedRxns{j, 2}));
                rxnIDOld=find(ismember(model_old.rxns,addedRxns{j, 1}));
                model.grRules{rxnIDNew,1}=model_old.grRules{rxnIDOld,1};
                if isfield(model_old,'rxnConfidenceScores')
                    model.rxnConfidenceScores(rxnIDNew,1)=model_old.rxnConfidenceScores(rxnIDOld,1);
                end
            end
            model.comments{end,1}='Added to eliminate futile cycles during DEMETER pipeline.';
            model.rxnConfidenceScores(end,1)=1;
        end
        % if more than one reaction is added
        if size(addedRxns,2)>2
            if ~isempty(addedRxns{j,3})
                for k=3:size(addedRxns(j,:),2)
                    if ~isempty(addedRxns{j,k})
                        model = addReaction(model, addedRxns{j, k}, database.reactions{find(ismember(database.reactions(:, 1), addedRxns{j, k})), 3});
                         model.comments{end,1}='Added to eliminate futile cycles during DEMETER pipeline.';
                         model.rxnConfidenceScores(end,1)=1;
                    end
                end
            end
        end
    end
end

% add any gap-filled reactions
if ~isempty(gfRxns)
    for i=1:length(gfRxns)
        model = addReaction(model, gfRxns{i,1}, database.reactions{find(ismember(database.reactions(:, 1), gfRxns{i,1})), 3});
        model.comments{end,1}='Added to enable growth after eliminating futile cycles during DEMETER pipeline.';
        model.rxnConfidenceScores(end,1)=1;
    end
end

if size(addedRxns,2) >1
    addedRxns=addedRxns(:,2);
end

% relax constraints-cause infeasibility problems
relaxConstraints=model.rxns(find(model.lb>0));
model=changeRxnBounds(model,relaxConstraints,0,'l');

% change back to unlimited medium
% list exchange reactions
exchanges = model.rxns(strncmp('EX_', model.rxns, 3));
% open all exchanges
model = changeRxnBounds(model, exchanges, -1000, 'l');
model = changeRxnBounds(model, exchanges, 1000, 'u');

end
