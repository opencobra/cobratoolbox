function [metabolite_structure, reaction_structure] = replaceVMHIds(metabolite_structure,reaction_structure)
% add, remove, or replace errors present in the metabolite annotation
% all mentions in this file are manually done and will result in the
% removal or replacement of the entries.
%
% INPUT
% metabolite_structure  metabolite structure
% reaction_structure    reaction structure (not done yet)
%
% OUTPUT
% metabolite_structure  updated metabolite structure
% reaction_structure    updated reaction structure (not done yet)
%
%
% Ines Thiele 2020/2021

if ~exist('reaction_structure','var')
    reaction_structure = '';
end

if ~exist('metabolite_structure','var')
    metabolite_structure = '';
end


annotationSource = 'curator (IT)';
annotationType = 'manual';
annotationVerification = 'verified';

replaceMet ={
    % vmhID % entry to be replaced  % replacement
    '3oh_dlor'  'pubChemId' '10359050'
    '3oh_dlor'  'inchiString' 'NaN'
    '10dmthmcn'	'cheBIId'	'29706'
    '10dmthnld'	'cheBIId'	'29461'
    '10fdhf'	'cheBIId'	'57452'
    '10hdhsngnrn'	'cheBIId'	'15878'
    '10hocdca'	'cheBIId'	'33197'
    '12acndl'	'cheBIId'	'80376'
    '12d4mch35d1c'	'keggId'	'C06729'
    '12d4mch35d1c'	'pubChemId'	'25202441'
    '12d4mch35d1c'	'seed'	'cpd04116'
    '12d4mch35d1c'	'biggId'	'dh4mchc'
    '12d4mch35d1c'	'biocyc'	'CIS-12-DIHYDROXY-ETCETERA-CARBOXYLATE'
    '12d4mch35d1c'	'cheBIId' '58768'
    '12d4mch35d1c'	'metanetx' 'MNXM3734'
    '12dhrtclnm'	'cheBIId'	'18363'
    '12dhtc'	'cheBIId'	'15808'
    '12dhnp12d'	'hmdb'	'HMDB0060335'
    '12daihdglyc'	'metanetx'	'MNXM7956'
    'glc_D'	'pdmapName'	'glucose'
    'cgz'	'drugbank'	'DBMET01328'
    'cgz'	'inchiKey'	'DSNDPTBTZSQWJS-TXEJJXNPSA-N'
    'phtd'	'wikipedia'	'Phenetidine'
    'phtn'	'wikipedia'	'Phenacetin'
    '11docrtsl' 'pubChemId' '46780609'
    '11docrtsl' 'wikipedia' '11-Deoxycortisol'
    '12dvmln'  'pubChemId' '11953964'
    '12dvmln'  'cheBIId' '17372'
    '12dvmln' 'inchiString' 'InChI=1S/C21H24N2O3/c1-3-11-12-8-15-18-21(13-6-4-5-7-14(13)22-18)9-16(23(15)20(11)25)17(12)19(21)26-10(2)24/h3-7,12,15-20,22,25H,8-9H2,1-2H3/b11-3+/t12-,15-,16-,17?,18-,19+,20+,21+/m0/s1'
    '12dvmln'   'keggID'    'C11808'
    '13dmxnthn' 'wikipedia' 'Theophylline'
    '13dmxnthn' 'epa_id' 'DTXSID5021336'
    '13dmxnthn' 'pubChemId' '2153'
    '13dmxnthn' 'inchiString' 'InChI=1S/C7H8N4O2/c1-10-5-4(8-3-9-5)6(12)11(2)7(10)13/h3H,1-2H3,(H,8,9)'
    '13shpoddnt'    'pubChemId' '5280720'
    '13shpoddnt' 'inchiString' 'InChI=1S/C18H32O4/c1-2-3-11-14-17(22-21)15-12-9-7-5-4-6-8-10-13-16-18(19)20/h7,9,12,15,17,21H,2-6,8,10-11,13-14,16H2,1H3,(H,19,20)/b9-7-,15-12+/t17-/m0/s1'
    '13shpoddnt' 'keggId'  'C04717'
    '13shpoddnt' 'cheBIId'  '15655'
    '14bdc' 'chemspider'    '7208'
    '14bdc' 'wikipedia' 'Terephthalic_acid'
    '14dgndnbtn' 'cheBIId'  '16652'
    '14dgndnbtn' 'chemspider'    '2141'
    '14dgndnbtn' 'pubChemId'   '20627403'
    '14dgndnbtn' 'inchiString' 'InChI=1S/C6H16N6/c7-5(8)11-3-1-2-4-12-6(9)10/h1-4H2,(H4,7,8,11)(H4,9,10,12)/p+2'
    '14hphe2maoh'   'seed'  'cpd02769'
    '14hphe2maoh'   'keggId'  'C04548'
    '14hphe2maoh'   'cheBIId'  '29081'
    '15ahgtl'   'wikipedia' '1,5-Anhydroglucitol'
    '15ahgtl'  'epa_id' 'DTXSID10893389'
    '15anhfruc' 'pubChemId'    '126517'
    '15anhfruc' 'chemspider'    '112421'
    '15anhfruc' 'biocyc'    '15-ANHYDRO-D-FRUCTOSE'
    '15anhfruc' 'metanetx'    'MNXM1060'
    '15anhfruc' 'seed'    'cpd03896'
    '16evsmn' 'pubChemId'   '11335328'
    '16evsmn' 'cheBIId'  '16425'
    '16evsmn' 'biocyc'  '16-EPIVELLOSIMINE'
    '16evsmn'  'metanetx'   'MNXM732387'
    'protein'   'fullName'  'protein'
    '13dmxnthn' 'inchiKey'  'ZFXYFBGIUFBOJW-UHFFFAOYSA-N'
    '13dmxnthn'    'keggId'    'C07130'
    '13dmxnthn'   'cheBIId'  '28177'
    '14bdc'  'biocyc'    'TEREPHTHALATE'
    '14bdc' 'keggId' 'C06337'
    '14bdc' 'inchiKey'   'KKEYFWRCBNTPAC-UHFFFAOYSA-L'
    '14lctn' 'keggId' 'C01770'
    '14lctn'  'inchiKey'    'YEJRWHAVMIAJKC-UHFFFAOYSA-N'
    '15ahgtl' 'inchiKey'    'MPCAJMNYNOGXPB-SLPGGIOYSA-N'
    '15ahgtl' 'keggId' 'C07326'
    '15ahgtl' 'biocyc' '15-ANHYDRO-D-GLUCITOL'
    '15phytn' 'inchiKey'  'YVLPJIGOMTXXLP-BHLJUDRVSA-N'
    '17oajmln'  'inchiKey'  'SRISWFJLVRCABV-QQTHMAAHSA-O'
    '17oajmln'  'keggId'    'C15985'
    '17oajmln'  'biocyc'    'CPD-8898'
    '17oanrjmln'  'inchiKey'  'VAOXSMUPPRUEKF-ZXDSMUBISA-O'
    '17oanrjmln'  'keggId'  'C11809'
    '17oanrjmln'  'cheBIId'  '17384'
    '25d5o2a'   'pubchemId' '542'
    '25d5o2a'   'cheBIId'   '58372'
    '25d5o2a'   'biocyc'    'CPD-15124'
    '25d5o2a'   'metanetx'   'MNXM726703'
    '25d5o2a'   'seed'  'cpd19162'
    '2dg'   'wikipedia' '2-Deoxy-D-glucose'
    '2dg'   'inchiKey'  'PMMURAAUARKVCB-CERMHHMHSA-N'
    'CE2120'    'chargedFormula'    'C13H16N2O6S'
    'CE2120'    'drugbank'  'DBMET00763'
    'CE2120'    'hmdb'  'HMDB0041815'
    'CE2120'    'chemspider'    '58606'
    'protein'   'chargedFormula'    'X'
    '2mmal' 'pubchemId' '5460281'
    '2mmal' 'keggId' 'C02612'
    '2mmal' 'seed' 'cpd01700'
    '2mmal' 'inchiKey'  'XFTRTWQBIOMVPK-RXMQYKEDSA-L'
    '2oh_mtz' 'chemspider' '108713'
    %'2oh_mtz' 'charge' '-2' %wrong charge in AGORA2/rBioNet!!!!!!
    '2pentcoa'   'biocyc' 'CPD-20685'
    '2pentcoa'   'pubchemId' '86290090'
    '2pentcoa'   'inchiKey'  'GJSFKOVNQYGUGN-JQVZGLFNSA-J'
    '2pentcoa'   'cheBIId' '83324'
    '3oh_dlor_glc' 'drugbank' 'DBMET02792'
    '3oh_dlor_glc' 'chemspider' '23976479'
    'indprp' 'hmdb' 'HMDB0002302'
    'indprp' 'wikipedia'    '3-Indolepropionic_acid'
    'indprpcoa' 'pubchemId'  '3081870'
    'indprpcoa' 'ctd'   'C077841'
    'indprpcoa' 'mesh'  'C077841'
    'indprpcoa' 'chemidplus'    '144319-97-1'
    'malcoam' 'pubchemId' '56928103'
    'malcoam'  'biocyc'    'CPD-12454'
    'malcoam'   'cheBIId'   '71244'
    'malcoam'   'seed'  'cpd20921'
    'malcoam'  'inchiKey' 'CHQAJZULNPRMEN-ITIYDSSPSA-J'
    'ph2s'   'pubchemId'  '108196'
    'ph2s'   'fullName'  'Hydrogen Disulfide'
    'ph2s'   'wikipedia'  'Hydrogen_disulfide'
    'h2s'  'fullName'   'Hydrogen Sulfide'
    'placcoa'   'keggId'    'C16257'
    'placcoa'   'seed'  'cpd14973'
    'placcoa'   'inchiKey' 'FKMUDVUPQINOSF-NHZRKUKBSA-J'
    'placcoa'   'biocycy'   'CPD-5922'
    'placcoa'   'metanetx'  'MNXM3766'
    'placcoa' 'pubchemId' '45266533'
    'placcoa'   'cheBIId'   '57254'
    'pnp'   'wikipedia' '4-Nitrophenol'
    %  'pnp'   'chargedFormula'  'C6H4NO3' % one proton missing based on my
    %  count
    'pppncoa'   'pubchemId' '3081660'
    'pppncoa'  'cheBIId'   '85676'
    'HC00001'   'wikipedia' 'Albumin'
    'HC00002' 'wikipedia' 'Alpha_1-antichymotrypsin'
    'HC00003' 'wikipedia'   'Alpha-1_antitrypsin'
    'HC01939' 'wikipedia'   'Haptoglobin'
    'HC01942'   'wikipedia' 'Plasmin'
    'HC01943'   'wikipedia' 'Thrombin'
    'vldl_hs'   'wikipedia' 'Very_low-density_lipoprotein'
    'idl_hs'   'wikipedia' 'Intermediate-density_lipoprotein'
    'ldl_hs'   'wikipedia' 'Low-density_lipoprotein'
    'hdl_hs'   'wikipedia' 'High-density_lipoprotein'
    'myelin_hs'   'wikipedia' 'Myelin'
    'M01570'   'wikipedia' 'Chylomicron'
    'M03147'   'wikipedia' 'Very_low-density_lipoprotein'
    'M03146'   'wikipedia' 'Very_low-density_lipoprotein'
    'M02048'   'wikipedia' 'High-density_lipoprotein'
    'M02047'   'wikipedia' 'High-density_lipoprotein'
    'M02353'   'wikipedia' 'Low-density_lipoprotein'
    'M02352'   'wikipedia' 'Low-density_lipoprotein'
    'PPARA (EnsG00000186951)'   'wikipedia' 'Peroxisome_proliferator-activated_receptor_alpha'
    % M00463 charge is wrong! should be -2
    'CE7231'    'cheBIId'   '136523'
    'CE7231'    'chargedFormula'   'C20H31O3'
    'CE7231'    'charge'   '-1'
    'CE7231'    'fullName'  '7-Hydroxyarachidonate (7-HETE)'
    'CE7231'   'hmdb'  'HMDB0062431'
    'CE7228' 'chemspider'    '35032542'
    'CE7228'    'chargedFormula'    'C20H31O3'
    'CE7228'    'charge'    '-1'
    'CE7228' 'cheBIId'   '137345'
    'CE7228' 'fullName'   '13-Hydroxy-5Z,8Z,11Z,14Z-Eicosatetraenoate (13-HETE)'
    % HMR_1079 reaction is potentially wrong if CE4922 is indeed
    % CHEBI:75913 - needs to be checked
    'M01094'    'hmdb'  'HMDB0060138'
    'M01352'    'wikipedia' 'Apolipoprotein_B'
    'CE5799'    'wikipedia' 'Glycinamide'
    'CE5799'   'hmdb'  'HMDB0062472'
    % HMR_9502 is potentially wrong if CE5800 is indeed pubchem 53481590
    'akval' 'pubchemId' '5460364'
    'akval' 'cheBIId'   '28644'
    'CE5528'    'hmdb'  'HMDB0062289'
    'gda1_hs'   'seed'  'cpd02999'
    'gda1_hs'   'chargedFormula'  'C66H111N4O38FULLRCO'
    'gda1_hs'   'charge'  '-2'
    'gda1_hs' 'biggId'    'gda1_hs'
    'gda1_hs'  'metanatx' 'MNXM8637'
    '2a5faprap' 'wikipedia' '2-Amino-5-formylamino-6-(5-phospho-D-ribosylamino)pyrimidin-4(3H)-one'
    '2a5faprap' 'cheBIId'   '11515'
    '2aasng3p'  'keggId'    'C01264'
    '2ac1asngpc' 'cheBIId'   '36707'
    '2hc'   'keggId' 'C02929'
    '2hc'  'cheBIId'   '52618'
    '2oc'   'keggId' 'C00161'
    '2oc'  'cheBIId'   '35910'
    '2ppp'  'keggId'    'C05807'
    '2ppp'  'fullName'  '2-Polyprenylphenol (n = 2)' % could draw structure for n=2
    '2ppp'  'cheBIId'   '1269'
    '35cntd'    'keggId'    'C04212'
    'tzeatn'    'keggId'    'C00371'
    'trpne' 'keggId'    'C02089'
    'trna3acpu' 'keggId' 'C04510'
    'tact'  'keggId'    'C01757'
    'tact'  'biocyc'   'CPD-22400'
    'sdplgal'    'keggId'    'C02280'
    'sdplgal'    'biocyc'    'GDP-L-GALACTOSE'
    'sdplgal'    'metanetx'    'MNXM728364'
    'rssr'    'keggId' 'C15496'
    'rsgth'    'keggId'  'C02320'
    'rsgth'    'biocyc' 'CPD-20939'
    'rooh'    'keggId' 'C15498'
    'rnsdtp'    'keggId'  'C03802'
    'rch2nh2'    'keggId'  'C00375'
    'rbpcnmlys'    'keggId' 'C06404'
    'rbpclys'    'keggId'     'C06403'
    'razur'    'keggId'  'C05358'
    'pyrzl' 'wikipedia' 'Pyrazole'
    'pyrzl' 'keggId' 'C00481'
    'pyrzl' 'biocyc' 'PYRAZOLE'
    'pyrzl' 'metanetx' 'MNXM732773'
    'CE1926'    'hmdb'  'HMDB0001931'
    '3ohsebac' 'hmdb'   'HMDB0000350'
    'inds'  'wikipedia' 'Indoxyl_sulfate'
    'inds'  'chemspider'    '9840'
    'inds'   'epa'  'DTXSID30928203'
    'ind3ppa'   'wikipedia' '3-Indolepropionic_acid'
    'ind3ppa'   'cheBIId'   '43580'
    'ind3ppa'   'epa'   'DTXSID7061192'
    '23camp'    'chemspider'    '91988'
    '23camp'    'keggId'    'C02353'
    '23camp'    'cheBIId'    '27844'
    '23camp'    'metanetx'    'MNXM2598'
    'eryt'  'keggId'    'C21593'
    'mthmcn'    'pubChemId' '5282034'
    };

%% metabolite structure update
for i = 1 : size(replaceMet,1)
    ID = regexprep(replaceMet{i,1},'-','_minus_');
    ID = regexprep(ID,'(','_parentO_');
    ID = regexprep(ID,')','_parentC_');
    ID = strcat('VMH_',ID);
    if isfield(metabolite_structure,ID)
        if strcmp(replaceMet{i,3},'NaN')
            metabolite_structure.(ID).(replaceMet{i,2}) = NaN;
            metabolite_structure.(ID).([replaceMet{i,2},'_source']) = NaN;
        else
            metabolite_structure.(ID).(replaceMet{i,2}) =replaceMet{i,3};
            metabolite_structure.(ID).([replaceMet{i,2},'_source']) = [annotationSource,':',annotationType,':',annotationVerification,':',datestr(now)];
        end
    end
end

% make sure that new replacements are in correct format and cell/double
%[metabolite_structure] = cleanUpMetabolite_structure(metabolite_structure);

%% reaction structure update -- TO be done
replaceRxn = {     % vmhID % entry to be replaced  % replacement
    'PYLALDOX'  'wikipedia'     'Perillyl-alcohol_dehydrogenase'
    'PYLALDOX'  'keggID'   'R03945'
    'SFGTH'   'wikipedia' 'S-formylglutathione_hydrolase' 
    };


for i = 1 : size(replaceRxn,1)
    ID = regexprep(replaceRxn{i,1},'-','_minus_');
    ID = regexprep(ID,'(','_parentO_');
    ID = regexprep(ID,')','_parentC_');
    
    ID = regexprep(ID,'[','_parentO_');
    ID = regexprep(ID,']','_parentC_');
    ID = regexprep(ID,':','_colon_');
    ID = regexprep(ID,' ','');
    
    ID = strcat('VMH_',ID);
    if isfield(reaction_structure,ID)
        if strcmp(replaceRxn{i,3},'NaN')
            reaction_structure.(ID).(replaceRxn{i,2}) = NaN;
            reaction_structure.(ID).([replaceRxn{i,2},'_source']) = NaN;
        else
            reaction_structure.(ID).(replaceRxn{i,2}) =replaceRxn{i,3};
            reaction_structure.(ID).([replaceRxn{i,2},'_source']) = [annotationSource,':',annotationType,':',annotationVerification,':',datestr(now)];
        end
    end
end

