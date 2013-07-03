function [output] = slvrEMU(v_in, xglcDe)
% input:  v has size unknown
% input:  xglcDe has size 64

% dividing symmetric fluxes

 v = v_in;
v(113) = v_in(113)/4; % GLYCDx is a symmetric reaction
v(255) = v_in(255)/2; % IMPSYN1 is a symmetric reaction
v(214) = v_in(214)/4; % SDPDS is a symmetric reaction
v(224) = v_in(224)/4; % SUCCt23 is a symmetric reaction
v(91) = v_in(91)/4; % FUMt23 is a symmetric reaction
v(220) = v_in(220)/2; % SSALx is a symmetric reaction
v(67) = v_in(67)/4; % DAPE is a symmetric reaction
v(298) = v_in(298)/4; % GLYCt_r is a symmetric reaction
v(20) = v_in(20)/2; % EX_succ is a symmetric reaction
v(38) = v_in(38)/2; % COMBO10 is a symmetric reaction
v(122) = v_in(122)/2; % GLYK is a symmetric reaction
v(8) = v_in(8)/2; % EX_glyc is a symmetric reaction
v(135) = v_in(135)/2; % ICL is a symmetric reaction
v(315) = v_in(315)/4; % PHETA1_r is a symmetric reaction
v(259) = v_in(259)/3; % FADSYN is a symmetric reaction
v(90) = v_in(90)/4; % FUMt22 is a symmetric reaction
v(226) = v_in(226)/4; % SUCD1i is a symmetric reaction
v(121) = v_in(121)/4; % GLYCt is a symmetric reaction
v(256) = v_in(256)/2; % IMPSYN2 is a symmetric reaction
v(61) = v_in(61)/2; % COMBO22 is a symmetric reaction
v(86) = v_in(86)/4; % FRD2 is a symmetric reaction
v(280) = v_in(280)/2; % ARGSL_r is a symmetric reaction
v(70) = v_in(70)/2; % DHAPT is a symmetric reaction
v(193) = v_in(193)/4; % PHETA1 is a symmetric reaction
v(325) = v_in(325)/16; % SUCFUMt_r is a symmetric reaction
v(290) = v_in(290)/2; % F6PA_r is a symmetric reaction
v(270) = v_in(270)/2; % G3PP is a symmetric reaction
v(266) = v_in(266)/2; % PEPTIDOSYN is a symmetric reaction
v(247) = v_in(247)/4; % TYRTA is a symmetric reaction
v(333) = v_in(333)/4; % TYRTA_r is a symmetric reaction
v(181) = v_in(181)/2; % ORNDC is a symmetric reaction
v(229) = v_in(229)/2; % SUCOAS is a symmetric reaction
v(228) = v_in(228)/16; % SUCFUMt is a symmetric reaction
v(44) = v_in(44)/2; % ARGSL is a symmetric reaction
v(6) = v_in(6)/2; % EX_fum is a symmetric reaction
v(200) = v_in(200)/2; % PPND is a symmetric reaction
v(293) = v_in(293)/2; % rFUM_r is a symmetric reaction
v(66) = v_in(66)/2; % DAPDC is a symmetric reaction
v(22) = v_in(22)/2; % COMBO2 is a symmetric reaction
v(264) = v_in(264)/2; % CLPNSYN is a symmetric reaction
v(225) = v_in(225)/4; % SUCCt2b is a symmetric reaction
v(36) = v_in(36)/2; % COMBOSPMD is a symmetric reaction
v(222) = v_in(222)/4; % SUCCabc is a symmetric reaction
v(110) = v_in(110)/2; % GLUSy is a symmetric reaction
v(79) = v_in(79)/2; % F6PA is a symmetric reaction
v(201) = v_in(201)/2; % PPNDH is a symmetric reaction
v(221) = v_in(221)/2; % SSALy is a symmetric reaction
v(87) = v_in(87)/4; % FRD3 is a symmetric reaction
v(286) = v_in(286)/4; % DAPE_r is a symmetric reaction
v(326) = v_in(326)/2; % SUCOAS_r is a symmetric reaction
v(89) = v_in(89)/2; % rFUM is a symmetric reaction
v(258) = v_in(258)/2; % COASYN is a symmetric reaction
v(223) = v_in(223)/4; % SUCCt22 is a symmetric reaction

% level: 1 of size 243
A1 = sparse(243, 243);
B1 = zeros(243, 2);
%>>> x13dpg#001#
A1(1, 1) = v(296) + v(312); % drain :GAPD_r_01:PGK_r_01 
A1(1, 23) = A1(1, 23) - v(189); % source1:PGK_01:x3pg#001(4)
A1(1, 123) = A1(1, 123) - v(100); % source1:GAPD_01:xg3p#001(4)
%>>> x13dpg#010#
A1(2, 2) = v(296) + v(312); % drain :GAPD_r_01:PGK_r_01 
A1(2, 24) = A1(2, 24) - v(189); % source1:PGK_01:x3pg#010(2)
A1(2, 124) = A1(2, 124) - v(100); % source1:GAPD_01:xg3p#010(2)
%>>> x13dpg#100#
A1(3, 3) = v(296) + v(312); % drain :GAPD_r_01:PGK_r_01 
A1(3, 25) = A1(3, 25) - v(189); % source1:PGK_01:x3pg#100(1)
A1(3, 125) = A1(3, 125) - v(100); % source1:GAPD_01:xg3p#100(1)
%>>> x1pyr5c#00001#
A1(4, 4) = v(182) + v(183); % drain :P5CD_01:P5CR_01 
A1(4, 132) = A1(4, 132) - v(97); % source1:G5SADs_01:xglu5sa#00001(16)
A1(4, 4) = A1(4, 4) - v(203); % source1:PROD2_01:x1pyr5c#00001(16)
%>>> x1pyr5c#00010#
A1(5, 5) = v(182) + v(183); % drain :P5CD_01:P5CR_01 
A1(5, 133) = A1(5, 133) - v(97); % source1:G5SADs_01:xglu5sa#00010(8)
A1(5, 5) = A1(5, 5) - v(203); % source1:PROD2_01:x1pyr5c#00010(8)
%>>> x1pyr5c#00100#
A1(6, 6) = v(182) + v(183); % drain :P5CD_01:P5CR_01 
A1(6, 134) = A1(6, 134) - v(97); % source1:G5SADs_01:xglu5sa#00100(4)
A1(6, 6) = A1(6, 6) - v(203); % source1:PROD2_01:x1pyr5c#00100(4)
%>>> x1pyr5c#01000#
A1(7, 7) = v(182) + v(183); % drain :P5CD_01:P5CR_01 
A1(7, 135) = A1(7, 135) - v(97); % source1:G5SADs_01:xglu5sa#01000(2)
A1(7, 7) = A1(7, 7) - v(203); % source1:PROD2_01:x1pyr5c#01000(2)
%>>> x1pyr5c#10000#
A1(8, 8) = v(182) + v(183); % drain :P5CD_01:P5CR_01 
A1(8, 136) = A1(8, 136) - v(97); % source1:G5SADs_01:xglu5sa#10000(1)
A1(8, 8) = A1(8, 8) - v(203); % source1:PROD2_01:x1pyr5c#10000(1)
%>>> x26dapLL#0000001#
A1(9, 9) = v(67) + v(67) + v(67) + v(67); % drain :DAPE_03:DAPE_02:DAPE_04:DAPE_01 
A1(9, 12) = A1(9, 12) - v(286); % source1:DAPE_r_04:x26dapM#1000000(1)
A1(9, 11) = A1(9, 11) - v(286); % source1:DAPE_r_02:x26dapM#0000001(64)
A1(9, 218) = A1(9, 218) - v(214); % source1:SDPDS_03:xsl2a6o#00000010000(64)
A1(9, 219) = A1(9, 219) - v(214); % source1:SDPDS_01:xsl2a6o#10000000000(1)
A1(9, 12) = A1(9, 12) - v(286); % source1:DAPE_r_01:x26dapM#1000000(1)
A1(9, 219) = A1(9, 219) - v(214); % source1:SDPDS_02:xsl2a6o#10000000000(1)
A1(9, 11) = A1(9, 11) - v(286); % source1:DAPE_r_03:x26dapM#0000001(64)
A1(9, 218) = A1(9, 218) - v(214); % source1:SDPDS_04:xsl2a6o#00000010000(64)
%>>> x26dapLL#1000000#
A1(10, 10) = v(67) + v(67) + v(67) + v(67); % drain :DAPE_03:DAPE_02:DAPE_04:DAPE_01 
A1(10, 11) = A1(10, 11) - v(286); % source1:DAPE_r_04:x26dapM#0000001(64)
A1(10, 12) = A1(10, 12) - v(286); % source1:DAPE_r_02:x26dapM#1000000(1)
A1(10, 219) = A1(10, 219) - v(214); % source1:SDPDS_03:xsl2a6o#10000000000(1)
A1(10, 218) = A1(10, 218) - v(214); % source1:SDPDS_01:xsl2a6o#00000010000(64)
A1(10, 11) = A1(10, 11) - v(286); % source1:DAPE_r_01:x26dapM#0000001(64)
A1(10, 218) = A1(10, 218) - v(214); % source1:SDPDS_02:xsl2a6o#00000010000(64)
A1(10, 12) = A1(10, 12) - v(286); % source1:DAPE_r_03:x26dapM#1000000(1)
A1(10, 219) = A1(10, 219) - v(214); % source1:SDPDS_04:xsl2a6o#10000000000(1)
%>>> x26dapM#0000001#
A1(11, 11) = v(66) + v(286) + v(286) + v(66) + v(286) + v(266) + v(266) + v(286); % drain :DAPDC_01:DAPE_r_02:DAPE_r_01:DAPDC_02:DAPE_r_04:PEPTIDOSYN_01:PEPTIDOSYN_02:DAPE_r_03 
A1(11, 9) = A1(11, 9) - v(67); % source1:DAPE_03:x26dapLL#0000001(64)
A1(11, 9) = A1(11, 9) - v(67); % source1:DAPE_02:x26dapLL#0000001(64)
A1(11, 10) = A1(11, 10) - v(67); % source1:DAPE_04:x26dapLL#1000000(1)
A1(11, 10) = A1(11, 10) - v(67); % source1:DAPE_01:x26dapLL#1000000(1)
%>>> x26dapM#1000000#
A1(12, 12) = v(66) + v(286) + v(286) + v(66) + v(286) + v(266) + v(266) + v(286); % drain :DAPDC_01:DAPE_r_02:DAPE_r_01:DAPDC_02:DAPE_r_04:PEPTIDOSYN_01:PEPTIDOSYN_02:DAPE_r_03 
A1(12, 10) = A1(12, 10) - v(67); % source1:DAPE_03:x26dapLL#1000000(1)
A1(12, 10) = A1(12, 10) - v(67); % source1:DAPE_02:x26dapLL#1000000(1)
A1(12, 9) = A1(12, 9) - v(67); % source1:DAPE_04:x26dapLL#0000001(64)
A1(12, 9) = A1(12, 9) - v(67); % source1:DAPE_01:x26dapLL#0000001(64)
%>>> x2ippm#0000010#
A1(13, 13) = v(140) + v(303); % drain :IPPMIb_01:IPPMIa_r_01 
A1(13, 13) = A1(13, 13) - v(139); % source1:IPPMIa_01:x2ippm#0000010(32)
A1(13, 19) = A1(13, 19) - v(304); % source1:IPPMIb_r_01:x3c3hmp#0000010(32)
%>>> x2kmb#00001#
A1(14, 14) = v(249); % drain :UNK3_01 
A1(14, 87) = A1(14, 87) - v(74); % source1:DKMPPD2_01:xdkmpp#000001(32)
A1(14, 87) = A1(14, 87) - v(73); % source1:DKMPPD_01:xdkmpp#000001(32)
%>>> x2kmb#10000#
A1(15, 15) = v(249); % drain :UNK3_01 
A1(15, 88) = A1(15, 88) - v(74); % source1:DKMPPD2_01:xdkmpp#010000(2)
A1(15, 88) = A1(15, 88) - v(73); % source1:DKMPPD_01:xdkmpp#010000(2)
%>>> x2pg#001#
A1(16, 16) = v(77) + v(191); % drain :ENO_01:PGM_01 
A1(16, 183) = A1(16, 183) - v(288); % source1:ENO_r_01:xpep#001(4)
A1(16, 23) = A1(16, 23) - v(313); % source1:PGM_r_01:x3pg#001(4)
%>>> x2pg#010#
A1(17, 17) = v(77) + v(191); % drain :ENO_01:PGM_01 
A1(17, 184) = A1(17, 184) - v(288); % source1:ENO_r_01:xpep#010(2)
A1(17, 24) = A1(17, 24) - v(313); % source1:PGM_r_01:x3pg#010(2)
%>>> x2pg#100#
A1(18, 18) = v(77) + v(191); % drain :ENO_01:PGM_01 
A1(18, 185) = A1(18, 185) - v(288); % source1:ENO_r_01:xpep#100(1)
A1(18, 25) = A1(18, 25) - v(313); % source1:PGM_r_01:x3pg#100(1)
%>>> x3c3hmp#0000010#
A1(19, 19) = v(304); % drain :IPPMIb_r_01 
A1(19, 22) = A1(19, 22) - v(141); % source1:IPPS_01:x3mob#10000(1)
A1(19, 13) = A1(19, 13) - v(140); % source1:IPPMIb_01:x2ippm#0000010(32)
%>>> x3dhq#1000000#
A1(20, 20) = v(72); % drain :DHQD_01 
A1(20, 185) = A1(20, 185) - v(68); % source1:COMBO25_01:xpep#100(1)
A1(20, 21) = A1(20, 21) - v(287); % source1:DHQD_r_01:x3dhsk#1000000(1)
%>>> x3dhsk#1000000#
A1(21, 21) = v(218) + v(287); % drain :SHK3Dr_01:DHQD_r_01 
A1(21, 20) = A1(21, 20) - v(72); % source1:DHQD_01:x3dhq#1000000(1)
A1(21, 21) = A1(21, 21) - v(324); % source1:SHK3Dr_r_01:x3dhsk#1000000(1)
%>>> x3mob#10000#
A1(22, 22) = v(141) + v(334) + v(258) + v(258); % drain :IPPS_01:VALTA_r_01:COASYN_02:COASYN_01 
A1(22, 22) = A1(22, 22) - v(250); % source1:VALTA_01:x3mob#10000(1)
A1(22, 192) = A1(22, 192) - v(69); % source1:DHAD1_01:xpyr#100(1)
%>>> x3pg#001#
A1(23, 23) = v(189) + v(313) + v(187); % drain :PGK_01:PGM_r_01:COMBO47_01 
A1(23, 142) = A1(23, 142) - v(114); % source1:GLYCK_01:xglx#01(2)
A1(23, 1) = A1(23, 1) - v(312); % source1:PGK_r_01:x13dpg#001(4)
A1(23, 16) = A1(23, 16) - v(191); % source1:PGM_01:x2pg#001(4)
%>>> x3pg#010#
A1(24, 24) = v(189) + v(313) + v(187); % drain :PGK_01:PGM_r_01:COMBO47_01 
A1(24, 142) = A1(24, 142) - v(114); % source1:GLYCK_01:xglx#01(2)
A1(24, 2) = A1(24, 2) - v(312); % source1:PGK_r_01:x13dpg#010(2)
A1(24, 17) = A1(24, 17) - v(191); % source1:PGM_01:x2pg#010(2)
%>>> x3pg#100#
A1(25, 25) = v(189) + v(313) + v(187); % drain :PGK_01:PGM_r_01:COMBO47_01 
A1(25, 143) = A1(25, 143) - v(114); % source1:GLYCK_01:xglx#10(1)
A1(25, 3) = A1(25, 3) - v(312); % source1:PGK_r_01:x13dpg#100(1)
A1(25, 18) = A1(25, 18) - v(191); % source1:PGM_01:x2pg#100(1)
%>>> x4abut#0001#
A1(26, 26) = v(21); % drain :ABTA_01 
A1(26, 189) = A1(26, 189) - v(22); % source1:COMBO2_01:xptrc#1000(1)
A1(26, 140) = A1(26, 140) - v(107); % source1:GLUDC_01:xgluL#01000(2)
A1(26, 186) = A1(26, 186) - v(22); % source1:COMBO2_02:xptrc#0001(8)
%>>> x4abut#0010#
A1(27, 27) = v(21); % drain :ABTA_01 
A1(27, 188) = A1(27, 188) - v(22); % source1:COMBO2_01:xptrc#0100(2)
A1(27, 139) = A1(27, 139) - v(107); % source1:GLUDC_01:xgluL#00100(4)
A1(27, 187) = A1(27, 187) - v(22); % source1:COMBO2_02:xptrc#0010(4)
%>>> x4abut#0100#
A1(28, 28) = v(21); % drain :ABTA_01 
A1(28, 187) = A1(28, 187) - v(22); % source1:COMBO2_01:xptrc#0010(4)
A1(28, 138) = A1(28, 138) - v(107); % source1:GLUDC_01:xgluL#00010(8)
A1(28, 188) = A1(28, 188) - v(22); % source1:COMBO2_02:xptrc#0100(2)
%>>> x4abut#1000#
A1(29, 29) = v(21); % drain :ABTA_01 
A1(29, 186) = A1(29, 186) - v(22); % source1:COMBO2_01:xptrc#0001(8)
A1(29, 137) = A1(29, 137) - v(107); % source1:GLUDC_01:xgluL#00001(16)
A1(29, 189) = A1(29, 189) - v(22); % source1:COMBO2_02:xptrc#1000(1)
%>>> x4pasp#0001#
A1(30, 30) = v(281) + v(282); % drain :ASAD_r_01:ASPK_r_01 
A1(30, 70) = A1(30, 70) - v(46); % source1:ASAD_01:xaspsa#0001(8)
A1(30, 66) = A1(30, 66) - v(50); % source1:ASPK_01:xaspL#0001(8)
%>>> x4pasp#0010#
A1(31, 31) = v(281) + v(282); % drain :ASAD_r_01:ASPK_r_01 
A1(31, 71) = A1(31, 71) - v(46); % source1:ASAD_01:xaspsa#0010(4)
A1(31, 67) = A1(31, 67) - v(50); % source1:ASPK_01:xaspL#0010(4)
%>>> x4pasp#0100#
A1(32, 32) = v(281) + v(282); % drain :ASAD_r_01:ASPK_r_01 
A1(32, 72) = A1(32, 72) - v(46); % source1:ASAD_01:xaspsa#0100(2)
A1(32, 68) = A1(32, 68) - v(50); % source1:ASPK_01:xaspL#0100(2)
%>>> x4pasp#1000#
A1(33, 33) = v(281) + v(282); % drain :ASAD_r_01:ASPK_r_01 
A1(33, 73) = A1(33, 73) - v(46); % source1:ASAD_01:xaspsa#1000(1)
A1(33, 69) = A1(33, 69) - v(50); % source1:ASPK_01:xaspL#1000(1)
%>>> xac#01#
A1(34, 34) = v(275) + v(26) + v(31); % drain :ACt2r_r_01:ACKr_01:ACS_01 
A1(34, 36) = A1(34, 36) - v(60); % source1:CYSS_01:xaccoa#01(2)
A1(34, 190) = A1(34, 190) - v(196); % source1:POX_01:xpyr#001(4)
A1(34, 45) = A1(34, 45) - v(157); % source1:NACODA_01:xacg5sa#0000001(64)
A1(34, 232) = A1(34, 232) - v(42); % source1:ALDD2x_01:xthrL#0001(8)
A1(34, 45) = A1(34, 45) - v(28); % source1:ACODA_01:xacg5sa#0000001(64)
A1(34, 36) = A1(34, 36) - 2*v(265); % source1:LPSSYN_01:xaccoa#01(2)
A1(34, 34) = A1(34, 34) - v(32); % source1:ACt2r_01:xac#01(2)
A1(34, 52) = A1(34, 52) - v(272); % source1:ACKr_r_01:xactp#01(2)
%>>> xac#10#
A1(35, 35) = v(275) + v(26) + v(31); % drain :ACt2r_r_01:ACKr_01:ACS_01 
A1(35, 37) = A1(35, 37) - v(60); % source1:CYSS_01:xaccoa#10(1)
A1(35, 191) = A1(35, 191) - v(196); % source1:POX_01:xpyr#010(2)
A1(35, 46) = A1(35, 46) - v(157); % source1:NACODA_01:xacg5sa#0000010(32)
A1(35, 233) = A1(35, 233) - v(42); % source1:ALDD2x_01:xthrL#0010(4)
A1(35, 46) = A1(35, 46) - v(28); % source1:ACODA_01:xacg5sa#0000010(32)
A1(35, 37) = A1(35, 37) - 2*v(265); % source1:LPSSYN_01:xaccoa#10(1)
A1(35, 35) = A1(35, 35) - v(32); % source1:ACt2r_01:xac#10(1)
A1(35, 53) = A1(35, 53) - v(272); % source1:ACKr_r_01:xactp#10(1)
%>>> xaccoa#01#
A1(36, 36) = v(148) + v(141) + v(216) + 5e-05*v(1) + 16.86*v(260) + v(24) + v(206) + v(33) + 2*v(266) + 2*v(266) + v(58) + 43*v(265); % drain :MALS_01:IPPS_01:SERAT_01:BiomassEcoliGALUi_01:CDPDAGSYN_01:COMBO3_01:PTAr_01:ADHEr_01:PEPTIDOSYN_01:PEPTIDOSYN_02:CS_01:LPSSYN_01 
A1(36, 232) = A1(36, 232) - v(23); % source1:ACALDi_01:xthrL#0001(8)
A1(36, 190) = A1(36, 190) - v(184); % source1:PDH_01:xpyr#001(4)
A1(36, 36) = A1(36, 36) - v(323); % source1:SERAT_r_01:xaccoa#01(2)
A1(36, 94) = A1(36, 94) - v(276); % source1:ADHEr_r_01:xetoh#01(2)
A1(36, 34) = A1(36, 34) - v(31); % source1:ACS_01:xac#01(2)
A1(36, 232) = A1(36, 232) - v(112); % source1:COMBO37_01:xthrL#0001(8)
A1(36, 190) = A1(36, 190) - v(186); % source1:PFL_01:xpyr#001(4)
A1(36, 52) = A1(36, 52) - v(318); % source1:PTAr_r_01:xactp#01(2)
%>>> xaccoa#10#
A1(37, 37) = v(148) + v(141) + v(216) + 5e-05*v(1) + 16.86*v(260) + v(24) + v(206) + v(33) + 2*v(266) + 2*v(266) + v(58) + 43*v(265); % drain :MALS_01:IPPS_01:SERAT_01:BiomassEcoliGALUi_01:CDPDAGSYN_01:COMBO3_01:PTAr_01:ADHEr_01:PEPTIDOSYN_01:PEPTIDOSYN_02:CS_01:LPSSYN_01 
A1(37, 233) = A1(37, 233) - v(23); % source1:ACALDi_01:xthrL#0010(4)
A1(37, 191) = A1(37, 191) - v(184); % source1:PDH_01:xpyr#010(2)
A1(37, 37) = A1(37, 37) - v(323); % source1:SERAT_r_01:xaccoa#10(1)
A1(37, 95) = A1(37, 95) - v(276); % source1:ADHEr_r_01:xetoh#10(1)
A1(37, 35) = A1(37, 35) - v(31); % source1:ACS_01:xac#10(1)
A1(37, 233) = A1(37, 233) - v(112); % source1:COMBO37_01:xthrL#0010(4)
A1(37, 191) = A1(37, 191) - v(186); % source1:PFL_01:xpyr#010(2)
A1(37, 53) = A1(37, 53) - v(318); % source1:PTAr_r_01:xactp#10(1)
%>>> xacg5p#0000001#
A1(38, 38) = v(277); % drain :AGPR_r_01 
A1(38, 45) = A1(38, 45) - v(39); % source1:AGPR_01:xacg5sa#0000001(64)
A1(38, 36) = A1(38, 36) - v(24); % source1:COMBO3_01:xaccoa#01(2)
%>>> xacg5p#0000010#
A1(39, 39) = v(277); % drain :AGPR_r_01 
A1(39, 46) = A1(39, 46) - v(39); % source1:AGPR_01:xacg5sa#0000010(32)
A1(39, 37) = A1(39, 37) - v(24); % source1:COMBO3_01:xaccoa#10(1)
%>>> xacg5p#0000100#
A1(40, 40) = v(277); % drain :AGPR_r_01 
A1(40, 47) = A1(40, 47) - v(39); % source1:AGPR_01:xacg5sa#0000100(16)
A1(40, 137) = A1(40, 137) - v(24); % source1:COMBO3_01:xgluL#00001(16)
%>>> xacg5p#0001000#
A1(41, 41) = v(277); % drain :AGPR_r_01 
A1(41, 48) = A1(41, 48) - v(39); % source1:AGPR_01:xacg5sa#0001000(8)
A1(41, 138) = A1(41, 138) - v(24); % source1:COMBO3_01:xgluL#00010(8)
%>>> xacg5p#0010000#
A1(42, 42) = v(277); % drain :AGPR_r_01 
A1(42, 49) = A1(42, 49) - v(39); % source1:AGPR_01:xacg5sa#0010000(4)
A1(42, 139) = A1(42, 139) - v(24); % source1:COMBO3_01:xgluL#00100(4)
%>>> xacg5p#0100000#
A1(43, 43) = v(277); % drain :AGPR_r_01 
A1(43, 50) = A1(43, 50) - v(39); % source1:AGPR_01:xacg5sa#0100000(2)
A1(43, 140) = A1(43, 140) - v(24); % source1:COMBO3_01:xgluL#01000(2)
%>>> xacg5p#1000000#
A1(44, 44) = v(277); % drain :AGPR_r_01 
A1(44, 51) = A1(44, 51) - v(39); % source1:AGPR_01:xacg5sa#1000000(1)
A1(44, 141) = A1(44, 141) - v(24); % source1:COMBO3_01:xgluL#10000(1)
%>>> xacg5sa#0000001#
A1(45, 45) = v(157) + v(274) + v(39); % drain :NACODA_01:ACOTA_r_01:AGPR_01 
A1(45, 38) = A1(45, 38) - v(277); % source1:AGPR_r_01:xacg5p#0000001(64)
A1(45, 45) = A1(45, 45) - v(30); % source1:ACOTA_01:xacg5sa#0000001(64)
%>>> xacg5sa#0000010#
A1(46, 46) = v(157) + v(274) + v(39); % drain :NACODA_01:ACOTA_r_01:AGPR_01 
A1(46, 39) = A1(46, 39) - v(277); % source1:AGPR_r_01:xacg5p#0000010(32)
A1(46, 46) = A1(46, 46) - v(30); % source1:ACOTA_01:xacg5sa#0000010(32)
%>>> xacg5sa#0000100#
A1(47, 47) = v(157) + v(274) + v(39); % drain :NACODA_01:ACOTA_r_01:AGPR_01 
A1(47, 40) = A1(47, 40) - v(277); % source1:AGPR_r_01:xacg5p#0000100(16)
A1(47, 47) = A1(47, 47) - v(30); % source1:ACOTA_01:xacg5sa#0000100(16)
%>>> xacg5sa#0001000#
A1(48, 48) = v(157) + v(274) + v(39); % drain :NACODA_01:ACOTA_r_01:AGPR_01 
A1(48, 41) = A1(48, 41) - v(277); % source1:AGPR_r_01:xacg5p#0001000(8)
A1(48, 48) = A1(48, 48) - v(30); % source1:ACOTA_01:xacg5sa#0001000(8)
%>>> xacg5sa#0010000#
A1(49, 49) = v(157) + v(274) + v(39); % drain :NACODA_01:ACOTA_r_01:AGPR_01 
A1(49, 42) = A1(49, 42) - v(277); % source1:AGPR_r_01:xacg5p#0010000(4)
A1(49, 49) = A1(49, 49) - v(30); % source1:ACOTA_01:xacg5sa#0010000(4)
%>>> xacg5sa#0100000#
A1(50, 50) = v(157) + v(274) + v(39); % drain :NACODA_01:ACOTA_r_01:AGPR_01 
A1(50, 43) = A1(50, 43) - v(277); % source1:AGPR_r_01:xacg5p#0100000(2)
A1(50, 50) = A1(50, 50) - v(30); % source1:ACOTA_01:xacg5sa#0100000(2)
%>>> xacg5sa#1000000#
A1(51, 51) = v(157) + v(274) + v(39); % drain :NACODA_01:ACOTA_r_01:AGPR_01 
A1(51, 44) = A1(51, 44) - v(277); % source1:AGPR_r_01:xacg5p#1000000(1)
A1(51, 51) = A1(51, 51) - v(30); % source1:ACOTA_01:xacg5sa#1000000(1)
%>>> xactp#01#
A1(52, 52) = v(318) + v(272); % drain :PTAr_r_01:ACKr_r_01 
A1(52, 34) = A1(52, 34) - v(26); % source1:ACKr_01:xac#01(2)
A1(52, 36) = A1(52, 36) - v(206); % source1:PTAr_01:xaccoa#01(2)
%>>> xactp#10#
A1(53, 53) = v(318) + v(272); % drain :PTAr_r_01:ACKr_r_01 
A1(53, 35) = A1(53, 35) - v(26); % source1:ACKr_01:xac#10(1)
A1(53, 37) = A1(53, 37) - v(206); % source1:PTAr_01:xaccoa#10(1)
%>>> xakg#00001#
A1(54, 54) = v(215) + v(110) + v(297) + v(247) + v(247) + v(250) + v(247) + v(41) + v(110) + v(22) + v(301) + v(193) + v(233) + v(247) + v(193) + v(30) + v(22) + v(51) + v(21) + v(193) + v(193) + v(136); % drain :SDPTA_01:GLUSy_02:GLUDy_r_01:TYRTA_04:TYRTA_02:VALTA_01:TYRTA_01:ALATAL_01:GLUSy_01:COMBO2_02:ICDHyr_r_01:PHETA1_04:TESTAKGDH_01:TYRTA_03:PHETA1_01:ACOTA_01:COMBO2_01:ASPTA_01:ABTA_01:PHETA1_02:PHETA1_03:ILETA_01 
A1(54, 137) = A1(54, 137) - v(333); % source1:TYRTA_r_04:xgluL#00001(16)
A1(54, 137) = A1(54, 137) - v(315); % source1:PHETA1_r_03:xgluL#00001(16)
A1(54, 137) = A1(54, 137) - v(274); % source1:ACOTA_r_01:xgluL#00001(16)
A1(54, 137) = A1(54, 137) - v(322); % source1:SDPTA_r_01:xgluL#00001(16)
A1(54, 137) = A1(54, 137) - v(147); % source1:LEUTAi_01:xgluL#00001(16)
A1(54, 137) = A1(54, 137) - v(334); % source1:VALTA_r_01:xgluL#00001(16)
A1(54, 137) = A1(54, 137) - v(333); % source1:TYRTA_r_02:xgluL#00001(16)
A1(54, 137) = A1(54, 137) - v(302); % source1:ILETA_r_01:xgluL#00001(16)
A1(54, 137) = A1(54, 137) - v(187); % source1:COMBO47_01:xgluL#00001(16)
A1(54, 137) = A1(54, 137) - v(315); % source1:PHETA1_r_02:xgluL#00001(16)
A1(54, 137) = A1(54, 137) - v(315); % source1:PHETA1_r_04:xgluL#00001(16)
A1(54, 137) = A1(54, 137) - v(249); % source1:UNK3_01:xgluL#00001(16)
A1(54, 137) = A1(54, 137) - v(333); % source1:TYRTA_r_01:xgluL#00001(16)
A1(54, 137) = A1(54, 137) - v(279); % source1:ALATAL_r_01:xgluL#00001(16)
A1(54, 137) = A1(54, 137) - v(251); % source1:HISSYN_01:xgluL#00001(16)
A1(54, 137) = A1(54, 137) - v(283); % source1:ASPTA_r_01:xgluL#00001(16)
A1(54, 158) = A1(54, 158) - v(134); % source1:ICDHyr_01:xicit#000010(16)
A1(54, 137) = A1(54, 137) - v(108); % source1:GLUDy_01:xgluL#00001(16)
A1(54, 137) = A1(54, 137) - v(333); % source1:TYRTA_r_03:xgluL#00001(16)
A1(54, 137) = A1(54, 137) - v(315); % source1:PHETA1_r_01:xgluL#00001(16)
%>>> xakg#00010#
A1(55, 55) = v(215) + v(110) + v(297) + v(247) + v(247) + v(250) + v(247) + v(41) + v(110) + v(22) + v(301) + v(193) + v(233) + v(247) + v(193) + v(30) + v(22) + v(51) + v(21) + v(193) + v(193) + v(136); % drain :SDPTA_01:GLUSy_02:GLUDy_r_01:TYRTA_04:TYRTA_02:VALTA_01:TYRTA_01:ALATAL_01:GLUSy_01:COMBO2_02:ICDHyr_r_01:PHETA1_04:TESTAKGDH_01:TYRTA_03:PHETA1_01:ACOTA_01:COMBO2_01:ASPTA_01:ABTA_01:PHETA1_02:PHETA1_03:ILETA_01 
A1(55, 138) = A1(55, 138) - v(333); % source1:TYRTA_r_04:xgluL#00010(8)
A1(55, 138) = A1(55, 138) - v(315); % source1:PHETA1_r_03:xgluL#00010(8)
A1(55, 138) = A1(55, 138) - v(274); % source1:ACOTA_r_01:xgluL#00010(8)
A1(55, 138) = A1(55, 138) - v(322); % source1:SDPTA_r_01:xgluL#00010(8)
A1(55, 138) = A1(55, 138) - v(147); % source1:LEUTAi_01:xgluL#00010(8)
A1(55, 138) = A1(55, 138) - v(334); % source1:VALTA_r_01:xgluL#00010(8)
A1(55, 138) = A1(55, 138) - v(333); % source1:TYRTA_r_02:xgluL#00010(8)
A1(55, 138) = A1(55, 138) - v(302); % source1:ILETA_r_01:xgluL#00010(8)
A1(55, 138) = A1(55, 138) - v(187); % source1:COMBO47_01:xgluL#00010(8)
A1(55, 138) = A1(55, 138) - v(315); % source1:PHETA1_r_02:xgluL#00010(8)
A1(55, 138) = A1(55, 138) - v(315); % source1:PHETA1_r_04:xgluL#00010(8)
A1(55, 138) = A1(55, 138) - v(249); % source1:UNK3_01:xgluL#00010(8)
A1(55, 138) = A1(55, 138) - v(333); % source1:TYRTA_r_01:xgluL#00010(8)
A1(55, 138) = A1(55, 138) - v(279); % source1:ALATAL_r_01:xgluL#00010(8)
A1(55, 138) = A1(55, 138) - v(251); % source1:HISSYN_01:xgluL#00010(8)
A1(55, 138) = A1(55, 138) - v(283); % source1:ASPTA_r_01:xgluL#00010(8)
A1(55, 159) = A1(55, 159) - v(134); % source1:ICDHyr_01:xicit#000100(8)
A1(55, 138) = A1(55, 138) - v(108); % source1:GLUDy_01:xgluL#00010(8)
A1(55, 138) = A1(55, 138) - v(333); % source1:TYRTA_r_03:xgluL#00010(8)
A1(55, 138) = A1(55, 138) - v(315); % source1:PHETA1_r_01:xgluL#00010(8)
%>>> xakg#00100#
A1(56, 56) = v(215) + v(110) + v(297) + v(247) + v(247) + v(250) + v(247) + v(41) + v(110) + v(22) + v(301) + v(193) + v(233) + v(247) + v(193) + v(30) + v(22) + v(51) + v(21) + v(193) + v(193) + v(136); % drain :SDPTA_01:GLUSy_02:GLUDy_r_01:TYRTA_04:TYRTA_02:VALTA_01:TYRTA_01:ALATAL_01:GLUSy_01:COMBO2_02:ICDHyr_r_01:PHETA1_04:TESTAKGDH_01:TYRTA_03:PHETA1_01:ACOTA_01:COMBO2_01:ASPTA_01:ABTA_01:PHETA1_02:PHETA1_03:ILETA_01 
A1(56, 139) = A1(56, 139) - v(333); % source1:TYRTA_r_04:xgluL#00100(4)
A1(56, 139) = A1(56, 139) - v(315); % source1:PHETA1_r_03:xgluL#00100(4)
A1(56, 139) = A1(56, 139) - v(274); % source1:ACOTA_r_01:xgluL#00100(4)
A1(56, 139) = A1(56, 139) - v(322); % source1:SDPTA_r_01:xgluL#00100(4)
A1(56, 139) = A1(56, 139) - v(147); % source1:LEUTAi_01:xgluL#00100(4)
A1(56, 139) = A1(56, 139) - v(334); % source1:VALTA_r_01:xgluL#00100(4)
A1(56, 139) = A1(56, 139) - v(333); % source1:TYRTA_r_02:xgluL#00100(4)
A1(56, 139) = A1(56, 139) - v(302); % source1:ILETA_r_01:xgluL#00100(4)
A1(56, 139) = A1(56, 139) - v(187); % source1:COMBO47_01:xgluL#00100(4)
A1(56, 139) = A1(56, 139) - v(315); % source1:PHETA1_r_02:xgluL#00100(4)
A1(56, 139) = A1(56, 139) - v(315); % source1:PHETA1_r_04:xgluL#00100(4)
A1(56, 139) = A1(56, 139) - v(249); % source1:UNK3_01:xgluL#00100(4)
A1(56, 139) = A1(56, 139) - v(333); % source1:TYRTA_r_01:xgluL#00100(4)
A1(56, 139) = A1(56, 139) - v(279); % source1:ALATAL_r_01:xgluL#00100(4)
A1(56, 139) = A1(56, 139) - v(251); % source1:HISSYN_01:xgluL#00100(4)
A1(56, 139) = A1(56, 139) - v(283); % source1:ASPTA_r_01:xgluL#00100(4)
A1(56, 160) = A1(56, 160) - v(134); % source1:ICDHyr_01:xicit#001000(4)
A1(56, 139) = A1(56, 139) - v(108); % source1:GLUDy_01:xgluL#00100(4)
A1(56, 139) = A1(56, 139) - v(333); % source1:TYRTA_r_03:xgluL#00100(4)
A1(56, 139) = A1(56, 139) - v(315); % source1:PHETA1_r_01:xgluL#00100(4)
%>>> xakg#01000#
A1(57, 57) = v(215) + v(110) + v(297) + v(247) + v(247) + v(250) + v(247) + v(41) + v(110) + v(22) + v(301) + v(193) + v(233) + v(247) + v(193) + v(30) + v(22) + v(51) + v(21) + v(193) + v(193) + v(136); % drain :SDPTA_01:GLUSy_02:GLUDy_r_01:TYRTA_04:TYRTA_02:VALTA_01:TYRTA_01:ALATAL_01:GLUSy_01:COMBO2_02:ICDHyr_r_01:PHETA1_04:TESTAKGDH_01:TYRTA_03:PHETA1_01:ACOTA_01:COMBO2_01:ASPTA_01:ABTA_01:PHETA1_02:PHETA1_03:ILETA_01 
A1(57, 140) = A1(57, 140) - v(333); % source1:TYRTA_r_04:xgluL#01000(2)
A1(57, 140) = A1(57, 140) - v(315); % source1:PHETA1_r_03:xgluL#01000(2)
A1(57, 140) = A1(57, 140) - v(274); % source1:ACOTA_r_01:xgluL#01000(2)
A1(57, 140) = A1(57, 140) - v(322); % source1:SDPTA_r_01:xgluL#01000(2)
A1(57, 140) = A1(57, 140) - v(147); % source1:LEUTAi_01:xgluL#01000(2)
A1(57, 140) = A1(57, 140) - v(334); % source1:VALTA_r_01:xgluL#01000(2)
A1(57, 140) = A1(57, 140) - v(333); % source1:TYRTA_r_02:xgluL#01000(2)
A1(57, 140) = A1(57, 140) - v(302); % source1:ILETA_r_01:xgluL#01000(2)
A1(57, 140) = A1(57, 140) - v(187); % source1:COMBO47_01:xgluL#01000(2)
A1(57, 140) = A1(57, 140) - v(315); % source1:PHETA1_r_02:xgluL#01000(2)
A1(57, 140) = A1(57, 140) - v(315); % source1:PHETA1_r_04:xgluL#01000(2)
A1(57, 140) = A1(57, 140) - v(249); % source1:UNK3_01:xgluL#01000(2)
A1(57, 140) = A1(57, 140) - v(333); % source1:TYRTA_r_01:xgluL#01000(2)
A1(57, 140) = A1(57, 140) - v(279); % source1:ALATAL_r_01:xgluL#01000(2)
A1(57, 140) = A1(57, 140) - v(251); % source1:HISSYN_01:xgluL#01000(2)
A1(57, 140) = A1(57, 140) - v(283); % source1:ASPTA_r_01:xgluL#01000(2)
A1(57, 161) = A1(57, 161) - v(134); % source1:ICDHyr_01:xicit#010000(2)
A1(57, 140) = A1(57, 140) - v(108); % source1:GLUDy_01:xgluL#01000(2)
A1(57, 140) = A1(57, 140) - v(333); % source1:TYRTA_r_03:xgluL#01000(2)
A1(57, 140) = A1(57, 140) - v(315); % source1:PHETA1_r_01:xgluL#01000(2)
%>>> xakg#10000#
A1(58, 58) = v(215) + v(110) + v(297) + v(247) + v(247) + v(250) + v(247) + v(41) + v(110) + v(22) + v(301) + v(193) + v(233) + v(247) + v(193) + v(30) + v(22) + v(51) + v(21) + v(193) + v(193) + v(136); % drain :SDPTA_01:GLUSy_02:GLUDy_r_01:TYRTA_04:TYRTA_02:VALTA_01:TYRTA_01:ALATAL_01:GLUSy_01:COMBO2_02:ICDHyr_r_01:PHETA1_04:TESTAKGDH_01:TYRTA_03:PHETA1_01:ACOTA_01:COMBO2_01:ASPTA_01:ABTA_01:PHETA1_02:PHETA1_03:ILETA_01 
A1(58, 141) = A1(58, 141) - v(333); % source1:TYRTA_r_04:xgluL#10000(1)
A1(58, 141) = A1(58, 141) - v(315); % source1:PHETA1_r_03:xgluL#10000(1)
A1(58, 141) = A1(58, 141) - v(274); % source1:ACOTA_r_01:xgluL#10000(1)
A1(58, 141) = A1(58, 141) - v(322); % source1:SDPTA_r_01:xgluL#10000(1)
A1(58, 141) = A1(58, 141) - v(147); % source1:LEUTAi_01:xgluL#10000(1)
A1(58, 141) = A1(58, 141) - v(334); % source1:VALTA_r_01:xgluL#10000(1)
A1(58, 141) = A1(58, 141) - v(333); % source1:TYRTA_r_02:xgluL#10000(1)
A1(58, 141) = A1(58, 141) - v(302); % source1:ILETA_r_01:xgluL#10000(1)
A1(58, 141) = A1(58, 141) - v(187); % source1:COMBO47_01:xgluL#10000(1)
A1(58, 141) = A1(58, 141) - v(315); % source1:PHETA1_r_02:xgluL#10000(1)
A1(58, 141) = A1(58, 141) - v(315); % source1:PHETA1_r_04:xgluL#10000(1)
A1(58, 141) = A1(58, 141) - v(249); % source1:UNK3_01:xgluL#10000(1)
A1(58, 141) = A1(58, 141) - v(333); % source1:TYRTA_r_01:xgluL#10000(1)
A1(58, 141) = A1(58, 141) - v(279); % source1:ALATAL_r_01:xgluL#10000(1)
A1(58, 141) = A1(58, 141) - v(251); % source1:HISSYN_01:xgluL#10000(1)
A1(58, 141) = A1(58, 141) - v(283); % source1:ASPTA_r_01:xgluL#10000(1)
A1(58, 162) = A1(58, 162) - v(134); % source1:ICDHyr_01:xicit#100000(1)
A1(58, 141) = A1(58, 141) - v(108); % source1:GLUDy_01:xgluL#10000(1)
A1(58, 141) = A1(58, 141) - v(333); % source1:TYRTA_r_03:xgluL#10000(1)
A1(58, 141) = A1(58, 141) - v(315); % source1:PHETA1_r_01:xgluL#10000(1)
%>>> xalaL#001#
A1(59, 59) = v(266) + v(41) + 0.488*v(1) + v(266) + v(40); % drain :PEPTIDOSYN_01:ALATAL_01:BiomassEcoliGALUi_01:PEPTIDOSYN_02:ALAR_01 
A1(59, 190) = A1(59, 190) - v(279); % source1:ALATAL_r_01:xpyr#001(4)
A1(59, 59) = A1(59, 59) - v(278); % source1:ALAR_r_01:xalaL#001(4)
%>>> xalaL#010#
A1(60, 60) = v(266) + v(41) + 0.488*v(1) + v(266) + v(40); % drain :PEPTIDOSYN_01:ALATAL_01:BiomassEcoliGALUi_01:PEPTIDOSYN_02:ALAR_01 
A1(60, 191) = A1(60, 191) - v(279); % source1:ALATAL_r_01:xpyr#010(2)
A1(60, 60) = A1(60, 60) - v(278); % source1:ALAR_r_01:xalaL#010(2)
%>>> xalaL#100#
A1(61, 61) = v(266) + v(41) + 0.488*v(1) + v(266) + v(40); % drain :PEPTIDOSYN_01:ALATAL_01:BiomassEcoliGALUi_01:PEPTIDOSYN_02:ALAR_01 
A1(61, 192) = A1(61, 192) - v(279); % source1:ALATAL_r_01:xpyr#100(1)
A1(61, 61) = A1(61, 61) - v(278); % source1:ALAR_r_01:xalaL#100(1)
%>>> xargsuc#0000000001#
A1(62, 62) = v(44) + v(44); % drain :ARGSL_01:ARGSL_02 
A1(62, 109) = A1(62, 109) - v(280); % source1:ARGSL_r_01:xfum#0001(8)
A1(62, 69) = A1(62, 69) - v(45); % source1:ARGSS_01:xaspL#1000(1)
A1(62, 112) = A1(62, 112) - v(280); % source1:ARGSL_r_02:xfum#1000(1)
%>>> xargsuc#0000000010#
A1(63, 63) = v(44) + v(44); % drain :ARGSL_01:ARGSL_02 
A1(63, 112) = A1(63, 112) - v(280); % source1:ARGSL_r_01:xfum#1000(1)
A1(63, 66) = A1(63, 66) - v(45); % source1:ARGSS_01:xaspL#0001(8)
A1(63, 109) = A1(63, 109) - v(280); % source1:ARGSL_r_02:xfum#0001(8)
%>>> xargsuc#0000000100#
A1(64, 64) = v(44) + v(44); % drain :ARGSL_01:ARGSL_02 
A1(64, 111) = A1(64, 111) - v(280); % source1:ARGSL_r_01:xfum#0100(2)
A1(64, 67) = A1(64, 67) - v(45); % source1:ARGSS_01:xaspL#0010(4)
A1(64, 110) = A1(64, 110) - v(280); % source1:ARGSL_r_02:xfum#0010(4)
%>>> xargsuc#0000001000#
A1(65, 65) = v(44) + v(44); % drain :ARGSL_01:ARGSL_02 
A1(65, 110) = A1(65, 110) - v(280); % source1:ARGSL_r_01:xfum#0010(4)
A1(65, 68) = A1(65, 68) - v(45); % source1:ARGSS_01:xaspL#0100(2)
A1(65, 111) = A1(65, 111) - v(280); % source1:ARGSL_r_02:xfum#0100(2)
%>>> xaspL#0001#
A1(66, 66) = v(45) + v(256) + v(38) + v(255) + v(38) + 0.229*v(1) + v(48) + v(256) + v(252) + v(50) + v(267) + v(51) + v(268) + v(253) + v(255) + v(258) + v(258); % drain :ARGSS_01:IMPSYN2_02:COMBO10_02:IMPSYN1_01:COMBO10_01:BiomassEcoliGALUi_01:ASNS1_01:IMPSYN2_01:UMPSYN1_01:ASPK_01:NADSYN1_01:ASPTA_01:NADSYN2_01:UMPSYN2_01:IMPSYN1_02:COASYN_02:COASYN_01 
A1(66, 66) = A1(66, 66) - v(47); % source1:ASNN_01:xaspL#0001(8)
A1(66, 174) = A1(66, 174) - v(283); % source1:ASPTA_r_01:xoaa#0001(8)
A1(66, 30) = A1(66, 30) - v(282); % source1:ASPK_r_01:x4pasp#0001(8)
%>>> xaspL#0010#
A1(67, 67) = v(45) + v(256) + v(38) + v(255) + v(38) + 0.229*v(1) + v(48) + v(256) + v(252) + v(50) + v(267) + v(51) + v(268) + v(253) + v(255) + v(258) + v(258); % drain :ARGSS_01:IMPSYN2_02:COMBO10_02:IMPSYN1_01:COMBO10_01:BiomassEcoliGALUi_01:ASNS1_01:IMPSYN2_01:UMPSYN1_01:ASPK_01:NADSYN1_01:ASPTA_01:NADSYN2_01:UMPSYN2_01:IMPSYN1_02:COASYN_02:COASYN_01 
A1(67, 67) = A1(67, 67) - v(47); % source1:ASNN_01:xaspL#0010(4)
A1(67, 175) = A1(67, 175) - v(283); % source1:ASPTA_r_01:xoaa#0010(4)
A1(67, 31) = A1(67, 31) - v(282); % source1:ASPK_r_01:x4pasp#0010(4)
%>>> xaspL#0100#
A1(68, 68) = v(45) + v(256) + v(38) + v(255) + v(38) + 0.229*v(1) + v(48) + v(256) + v(252) + v(50) + v(267) + v(51) + v(268) + v(253) + v(255) + v(258) + v(258); % drain :ARGSS_01:IMPSYN2_02:COMBO10_02:IMPSYN1_01:COMBO10_01:BiomassEcoliGALUi_01:ASNS1_01:IMPSYN2_01:UMPSYN1_01:ASPK_01:NADSYN1_01:ASPTA_01:NADSYN2_01:UMPSYN2_01:IMPSYN1_02:COASYN_02:COASYN_01 
A1(68, 68) = A1(68, 68) - v(47); % source1:ASNN_01:xaspL#0100(2)
A1(68, 176) = A1(68, 176) - v(283); % source1:ASPTA_r_01:xoaa#0100(2)
A1(68, 32) = A1(68, 32) - v(282); % source1:ASPK_r_01:x4pasp#0100(2)
%>>> xaspL#1000#
A1(69, 69) = v(45) + v(256) + v(38) + v(255) + v(38) + 0.229*v(1) + v(48) + v(256) + v(252) + v(50) + v(267) + v(51) + v(268) + v(253) + v(255) + v(258) + v(258); % drain :ARGSS_01:IMPSYN2_02:COMBO10_02:IMPSYN1_01:COMBO10_01:BiomassEcoliGALUi_01:ASNS1_01:IMPSYN2_01:UMPSYN1_01:ASPK_01:NADSYN1_01:ASPTA_01:NADSYN2_01:UMPSYN2_01:IMPSYN1_02:COASYN_02:COASYN_01 
A1(69, 69) = A1(69, 69) - v(47); % source1:ASNN_01:xaspL#1000(1)
A1(69, 177) = A1(69, 177) - v(283); % source1:ASPTA_r_01:xoaa#1000(1)
A1(69, 33) = A1(69, 33) - v(282); % source1:ASPK_r_01:x4pasp#1000(1)
%>>> xaspsa#0001#
A1(70, 70) = v(71) + v(46) + v(300); % drain :COMBO26_01:ASAD_01:HSDy_r_01 
A1(70, 70) = A1(70, 70) - v(129); % source1:HSDy_01:xaspsa#0001(8)
A1(70, 30) = A1(70, 30) - v(281); % source1:ASAD_r_01:x4pasp#0001(8)
%>>> xaspsa#0010#
A1(71, 71) = v(71) + v(46) + v(300); % drain :COMBO26_01:ASAD_01:HSDy_r_01 
A1(71, 71) = A1(71, 71) - v(129); % source1:HSDy_01:xaspsa#0010(4)
A1(71, 31) = A1(71, 31) - v(281); % source1:ASAD_r_01:x4pasp#0010(4)
%>>> xaspsa#0100#
A1(72, 72) = v(71) + v(46) + v(300); % drain :COMBO26_01:ASAD_01:HSDy_r_01 
A1(72, 72) = A1(72, 72) - v(129); % source1:HSDy_01:xaspsa#0100(2)
A1(72, 32) = A1(72, 32) - v(281); % source1:ASAD_r_01:x4pasp#0100(2)
%>>> xaspsa#1000#
A1(73, 73) = v(71) + v(46) + v(300); % drain :COMBO26_01:ASAD_01:HSDy_r_01 
A1(73, 73) = A1(73, 73) - v(129); % source1:HSDy_01:xaspsa#1000(1)
A1(73, 33) = A1(73, 33) - v(281); % source1:ASAD_r_01:x4pasp#1000(1)
%>>> xcit#000001#
A1(74, 74) = v(29); % drain :rACONT_01 
A1(74, 157) = A1(74, 157) - v(273); % source1:rACONT_r_01:xicit#000001(32)
A1(74, 177) = A1(74, 177) - v(58); % source1:CS_01:xoaa#1000(1)
%>>> xcit#000010#
A1(75, 75) = v(29); % drain :rACONT_01 
A1(75, 158) = A1(75, 158) - v(273); % source1:rACONT_r_01:xicit#000010(16)
A1(75, 37) = A1(75, 37) - v(58); % source1:CS_01:xaccoa#10(1)
%>>> xcit#000100#
A1(76, 76) = v(29); % drain :rACONT_01 
A1(76, 159) = A1(76, 159) - v(273); % source1:rACONT_r_01:xicit#000100(8)
A1(76, 36) = A1(76, 36) - v(58); % source1:CS_01:xaccoa#01(2)
%>>> xcit#001000#
A1(77, 77) = v(29); % drain :rACONT_01 
A1(77, 160) = A1(77, 160) - v(273); % source1:rACONT_r_01:xicit#001000(4)
A1(77, 176) = A1(77, 176) - v(58); % source1:CS_01:xoaa#0100(2)
%>>> xcit#010000#
A1(78, 78) = v(29); % drain :rACONT_01 
A1(78, 161) = A1(78, 161) - v(273); % source1:rACONT_r_01:xicit#010000(2)
A1(78, 175) = A1(78, 175) - v(58); % source1:CS_01:xoaa#0010(4)
%>>> xcit#100000#
A1(79, 79) = v(29); % drain :rACONT_01 
A1(79, 162) = A1(79, 162) - v(273); % source1:rACONT_r_01:xicit#100000(1)
A1(79, 174) = A1(79, 174) - v(58); % source1:CS_01:xoaa#0001(8)
%>>> xco2#1#
A1(80, 80) = v(301) + v(198) + v(127) + v(284); % drain :ICDHyr_r_01:PPC_01:HCO3E_01:CO2t_r_01 
A1(80, 213) = A1(80, 213) - v(201); % source1:PPNDH_02:xskm5p#1000000(1)
A1(80, 143) = A1(80, 143) - v(111); % source1:GLXCL_01:xglx#10(1)
A1(80, 182) = A1(80, 182) - v(181); % source1:ORNDC_01:xorn#10000(1)
A1(80, 11) = A1(80, 11) - v(66); % source1:DAPDC_02:x26dapM#0000001(64)
A1(80, 212) = A1(80, 212) - v(262); % source1:PESYN_01:xserL#100(1)
A1(80, 192) = A1(80, 192) - v(27); % source1:COMBO5_01:xpyr#100(1)
A1(80, 171) = A1(80, 171) - v(36); % source1:COMBOSPMD_02:xmetL#10000(1)
A1(80, 145) = A1(80, 145) - v(115); % source1:GLYCL_01:xgly#10(1)
A1(80, 80) = A1(80, 80) - 35*v(265); % source1:LPSSYN_01:xco2#1(1)
A1(80, 80) = A1(80, 80) - v(299); % source1:HCO3E_r_01:xco2#1(1)
A1(80, 58) = A1(80, 58) - v(233); % source1:TESTAKGDH_01:xakg#10000(1)
A1(80, 192) = A1(80, 192) - v(25); % source1:COMBO4_01:xpyr#100(1)
A1(80, 69) = A1(80, 69) - v(252); % source1:UMPSYN1_01:xaspL#1000(1)
A1(80, 141) = A1(80, 141) - v(107); % source1:GLUDC_01:xgluL#10000(1)
A1(80, 166) = A1(80, 166) - v(153); % source1:ME2_01:xmalL#0001(8)
A1(80, 171) = A1(80, 171) - v(36); % source1:COMBOSPMD_01:xmetL#10000(1)
A1(80, 192) = A1(80, 192) - v(196); % source1:POX_01:xpyr#100(1)
A1(80, 213) = A1(80, 213) - v(200); % source1:PPND_01:xskm5p#1000000(1)
A1(80, 157) = A1(80, 157) - v(134); % source1:ICDHyr_01:xicit#000001(32)
A1(80, 108) = A1(80, 108) - v(82); % source1:FDH2_01:xformate#1(1)
A1(80, 69) = A1(80, 69) - 2*v(258); % source1:COASYN_02:xaspL#1000(1)
A1(80, 213) = A1(80, 213) - v(200); % source1:PPND_02:xskm5p#1000000(1)
A1(80, 174) = A1(80, 174) - v(199); % source1:PPCK_01:xoaa#0001(8)
A1(80, 213) = A1(80, 213) - v(201); % source1:PPNDH_01:xskm5p#1000000(1)
A1(80, 108) = A1(80, 108) - v(83); % source1:FDH3_01:xformate#1(1)
A1(80, 69) = A1(80, 69) - v(253); % source1:UMPSYN2_01:xaspL#1000(1)
A1(80, 12) = A1(80, 12) - v(66); % source1:DAPDC_01:x26dapM#1000000(1)
A1(80, 80) = A1(80, 80) - v(57); % source1:CO2t_01:xco2#1(1)
A1(80, 13) = A1(80, 13) - v(180); % source1:OMCDC_01:x2ippm#0000010(32)
A1(80, 80) = A1(80, 80) - 14.86*v(260); % source1:CDPDAGSYN_01:xco2#1(1)
A1(80, 192) = A1(80, 192) - v(184); % source1:PDH_01:xpyr#100(1)
A1(80, 213) = A1(80, 213) - v(43); % source1:COMBO15_01:xskm5p#1000000(1)
A1(80, 69) = A1(80, 69) - v(267); % source1:NADSYN1_01:xaspL#1000(1)
A1(80, 69) = A1(80, 69) - v(268); % source1:NADSYN2_01:xaspL#1000(1)
A1(80, 166) = A1(80, 166) - v(152); % source1:ME1_01:xmalL#0001(8)
A1(80, 131) = A1(80, 131) - v(125); % source1:GND_01:xg6p#100000(1)
A1(80, 108) = A1(80, 108) - v(84); % source1:FHL_01:xformate#1(1)
A1(80, 182) = A1(80, 182) - v(181); % source1:ORNDC_02:xorn#10000(1)
A1(80, 212) = A1(80, 212) - 2*v(258); % source1:COASYN_01:xserL#100(1)
%>>> xdha#001#
A1(81, 81) = v(70) + v(290) + v(290) + v(70); % drain :DHAPT_02:F6PA_r_02:F6PA_r_01:DHAPT_01 
A1(81, 148) = A1(81, 148) - v(113); % source1:GLYCDx_04:xglyc#100(1)
A1(81, 146) = A1(81, 146) - v(113); % source1:GLYCDx_03:xglyc#001(4)
A1(81, 146) = A1(81, 146) - v(113); % source1:GLYCDx_02:xglyc#001(4)
A1(81, 99) = A1(81, 99) - v(79); % source1:F6PA_02:xf6p#001000(4)
A1(81, 148) = A1(81, 148) - v(113); % source1:GLYCDx_01:xglyc#100(1)
A1(81, 101) = A1(81, 101) - v(79); % source1:F6PA_01:xf6p#100000(1)
%>>> xdha#010#
A1(82, 82) = v(70) + v(290) + v(290) + v(70); % drain :DHAPT_02:F6PA_r_02:F6PA_r_01:DHAPT_01 
A1(82, 147) = A1(82, 147) - v(113); % source1:GLYCDx_04:xglyc#010(2)
A1(82, 147) = A1(82, 147) - v(113); % source1:GLYCDx_03:xglyc#010(2)
A1(82, 147) = A1(82, 147) - v(113); % source1:GLYCDx_02:xglyc#010(2)
A1(82, 100) = A1(82, 100) - v(79); % source1:F6PA_02:xf6p#010000(2)
A1(82, 147) = A1(82, 147) - v(113); % source1:GLYCDx_01:xglyc#010(2)
A1(82, 100) = A1(82, 100) - v(79); % source1:F6PA_01:xf6p#010000(2)
%>>> xdha#100#
A1(83, 83) = v(70) + v(290) + v(290) + v(70); % drain :DHAPT_02:F6PA_r_02:F6PA_r_01:DHAPT_01 
A1(83, 146) = A1(83, 146) - v(113); % source1:GLYCDx_04:xglyc#001(4)
A1(83, 148) = A1(83, 148) - v(113); % source1:GLYCDx_03:xglyc#100(1)
A1(83, 148) = A1(83, 148) - v(113); % source1:GLYCDx_02:xglyc#100(1)
A1(83, 101) = A1(83, 101) - v(79); % source1:F6PA_02:xf6p#100000(1)
A1(83, 146) = A1(83, 146) - v(113); % source1:GLYCDx_01:xglyc#001(4)
A1(83, 99) = A1(83, 99) - v(79); % source1:F6PA_01:xf6p#001000(4)
%>>> xdhap#001#
A1(84, 84) = v(123) + v(240) + v(294) + v(268) + v(291) + v(267); % drain :COMBO38_01:TPI_01:G3PD2_r_01:NADSYN2_01:FBA_r_01:NADSYN1_01 
A1(84, 125) = A1(84, 125) - v(331); % source1:TPI_r_01:xg3p#100(1)
A1(84, 149) = A1(84, 149) - v(96); % source1:G3PD7_01:xglyc3p#001(4)
A1(84, 149) = A1(84, 149) - v(94); % source1:G3PD5_01:xglyc3p#001(4)
A1(84, 105) = A1(84, 105) - v(80); % source1:FBA_01:xfdp#001000(4)
A1(84, 81) = A1(84, 81) - v(70); % source1:DHAPT_02:xdha#001(4)
A1(84, 149) = A1(84, 149) - v(93); % source1:G3PD2_01:xglyc3p#001(4)
A1(84, 149) = A1(84, 149) - v(95); % source1:G3PD6_01:xglyc3p#001(4)
A1(84, 83) = A1(84, 83) - v(70); % source1:DHAPT_01:xdha#100(1)
%>>> xdhap#010#
A1(85, 85) = v(123) + v(240) + v(294) + v(268) + v(291) + v(267); % drain :COMBO38_01:TPI_01:G3PD2_r_01:NADSYN2_01:FBA_r_01:NADSYN1_01 
A1(85, 124) = A1(85, 124) - v(331); % source1:TPI_r_01:xg3p#010(2)
A1(85, 150) = A1(85, 150) - v(96); % source1:G3PD7_01:xglyc3p#010(2)
A1(85, 150) = A1(85, 150) - v(94); % source1:G3PD5_01:xglyc3p#010(2)
A1(85, 106) = A1(85, 106) - v(80); % source1:FBA_01:xfdp#010000(2)
A1(85, 82) = A1(85, 82) - v(70); % source1:DHAPT_02:xdha#010(2)
A1(85, 150) = A1(85, 150) - v(93); % source1:G3PD2_01:xglyc3p#010(2)
A1(85, 150) = A1(85, 150) - v(95); % source1:G3PD6_01:xglyc3p#010(2)
A1(85, 82) = A1(85, 82) - v(70); % source1:DHAPT_01:xdha#010(2)
%>>> xdhap#100#
A1(86, 86) = v(123) + v(240) + v(294) + v(268) + v(291) + v(267); % drain :COMBO38_01:TPI_01:G3PD2_r_01:NADSYN2_01:FBA_r_01:NADSYN1_01 
A1(86, 123) = A1(86, 123) - v(331); % source1:TPI_r_01:xg3p#001(4)
A1(86, 151) = A1(86, 151) - v(96); % source1:G3PD7_01:xglyc3p#100(1)
A1(86, 151) = A1(86, 151) - v(94); % source1:G3PD5_01:xglyc3p#100(1)
A1(86, 107) = A1(86, 107) - v(80); % source1:FBA_01:xfdp#100000(1)
A1(86, 83) = A1(86, 83) - v(70); % source1:DHAPT_02:xdha#100(1)
A1(86, 151) = A1(86, 151) - v(93); % source1:G3PD2_01:xglyc3p#100(1)
A1(86, 151) = A1(86, 151) - v(95); % source1:G3PD6_01:xglyc3p#100(1)
A1(86, 81) = A1(86, 81) - v(70); % source1:DHAPT_01:xdha#001(4)
%>>> xdkmpp#000001#
A1(87, 87) = v(74) + v(73); % drain :DKMPPD2_01:DKMPPD_01 
A1(87, 170) = A1(87, 170) - v(36); % source1:COMBOSPMD_02:xmetL#00001(16)
A1(87, 170) = A1(87, 170) - v(36); % source1:COMBOSPMD_01:xmetL#00001(16)
%>>> xdkmpp#010000#
A1(88, 88) = v(74) + v(73); % drain :DKMPPD2_01:DKMPPD_01 
A1(88, 196) = A1(88, 196) - v(36); % source1:COMBOSPMD_02:xr5p#01000(2)
A1(88, 196) = A1(88, 196) - v(36); % source1:COMBOSPMD_01:xr5p#01000(2)
%>>> xdkmpp#100000#
A1(89, 89) = v(74) + v(73); % drain :DKMPPD2_01:DKMPPD_01 
A1(89, 197) = A1(89, 197) - v(36); % source1:COMBOSPMD_02:xr5p#10000(1)
A1(89, 197) = A1(89, 197) - v(36); % source1:COMBOSPMD_01:xr5p#10000(1)
%>>> xe4p#0001#
A1(90, 90) = v(239) + v(68) + v(327); % drain :TKT2_01:COMBO25_01:TALA_r_01 
A1(90, 96) = A1(90, 96) - v(330); % source1:TKT2_r_01:xf6p#000001(32)
A1(90, 203) = A1(90, 203) - v(232); % source1:TALA_01:xs7p#0000001(64)
%>>> xe4p#0010#
A1(91, 91) = v(239) + v(68) + v(327); % drain :TKT2_01:COMBO25_01:TALA_r_01 
A1(91, 97) = A1(91, 97) - v(330); % source1:TKT2_r_01:xf6p#000010(16)
A1(91, 204) = A1(91, 204) - v(232); % source1:TALA_01:xs7p#0000010(32)
%>>> xe4p#0100#
A1(92, 92) = v(239) + v(68) + v(327); % drain :TKT2_01:COMBO25_01:TALA_r_01 
A1(92, 98) = A1(92, 98) - v(330); % source1:TKT2_r_01:xf6p#000100(8)
A1(92, 205) = A1(92, 205) - v(232); % source1:TALA_01:xs7p#0000100(16)
%>>> xe4p#1000#
A1(93, 93) = v(239) + v(68) + v(327); % drain :TKT2_01:COMBO25_01:TALA_r_01 
A1(93, 99) = A1(93, 99) - v(330); % source1:TKT2_r_01:xf6p#001000(4)
A1(93, 206) = A1(93, 206) - v(232); % source1:TALA_01:xs7p#0001000(8)
%>>> xetoh#01#
A1(94, 94) = v(289) + v(276); % drain :ETOHt2r_r_01:ADHEr_r_01 
A1(94, 36) = A1(94, 36) - v(33); % source1:ADHEr_01:xaccoa#01(2)
A1(94, 94) = A1(94, 94) - v(78); % source1:ETOHt2r_01:xetoh#01(2)
%>>> xetoh#10#
A1(95, 95) = v(289) + v(276); % drain :ETOHt2r_r_01:ADHEr_r_01 
A1(95, 37) = A1(95, 37) - v(33); % source1:ADHEr_01:xaccoa#10(1)
A1(95, 95) = A1(95, 95) - v(78); % source1:ETOHt2r_01:xetoh#10(1)
%>>> xf6p#000001#
A1(96, 96) = v(327) + v(311) + v(330) + v(185) + 2*v(266) + v(79) + 2*v(266) + v(79) + 2*v(265); % drain :TALA_r_01:PGI_r_01:TKT2_r_01:PFK_01:PEPTIDOSYN_01:F6PA_02:PEPTIDOSYN_02:F6PA_01:LPSSYN_01 
A1(96, 90) = A1(96, 90) - v(239); % source1:TKT2_01:xe4p#0001(8)
A1(96, 102) = A1(96, 102) - v(81); % source1:FBP_01:xfdp#000001(32)
A1(96, 123) = A1(96, 123) - v(290); % source1:F6PA_r_02:xg3p#001(4)
A1(96, 123) = A1(96, 123) - v(290); % source1:F6PA_r_01:xg3p#001(4)
A1(96, 123) = A1(96, 123) - v(232); % source1:TALA_01:xg3p#001(4)
A1(96, 126) = A1(96, 126) - v(188); % source1:PGI_01:xg6p#000001(32)
%>>> xf6p#000010#
A1(97, 97) = v(327) + v(311) + v(330) + v(185) + 2*v(266) + v(79) + 2*v(266) + v(79) + 2*v(265); % drain :TALA_r_01:PGI_r_01:TKT2_r_01:PFK_01:PEPTIDOSYN_01:F6PA_02:PEPTIDOSYN_02:F6PA_01:LPSSYN_01 
A1(97, 91) = A1(97, 91) - v(239); % source1:TKT2_01:xe4p#0010(4)
A1(97, 103) = A1(97, 103) - v(81); % source1:FBP_01:xfdp#000010(16)
A1(97, 124) = A1(97, 124) - v(290); % source1:F6PA_r_02:xg3p#010(2)
A1(97, 124) = A1(97, 124) - v(290); % source1:F6PA_r_01:xg3p#010(2)
A1(97, 124) = A1(97, 124) - v(232); % source1:TALA_01:xg3p#010(2)
A1(97, 127) = A1(97, 127) - v(188); % source1:PGI_01:xg6p#000010(16)
%>>> xf6p#000100#
A1(98, 98) = v(327) + v(311) + v(330) + v(185) + 2*v(266) + v(79) + 2*v(266) + v(79) + 2*v(265); % drain :TALA_r_01:PGI_r_01:TKT2_r_01:PFK_01:PEPTIDOSYN_01:F6PA_02:PEPTIDOSYN_02:F6PA_01:LPSSYN_01 
A1(98, 92) = A1(98, 92) - v(239); % source1:TKT2_01:xe4p#0100(2)
A1(98, 104) = A1(98, 104) - v(81); % source1:FBP_01:xfdp#000100(8)
A1(98, 125) = A1(98, 125) - v(290); % source1:F6PA_r_02:xg3p#100(1)
A1(98, 125) = A1(98, 125) - v(290); % source1:F6PA_r_01:xg3p#100(1)
A1(98, 125) = A1(98, 125) - v(232); % source1:TALA_01:xg3p#100(1)
A1(98, 128) = A1(98, 128) - v(188); % source1:PGI_01:xg6p#000100(8)
%>>> xf6p#001000#
A1(99, 99) = v(327) + v(311) + v(330) + v(185) + 2*v(266) + v(79) + 2*v(266) + v(79) + 2*v(265); % drain :TALA_r_01:PGI_r_01:TKT2_r_01:PFK_01:PEPTIDOSYN_01:F6PA_02:PEPTIDOSYN_02:F6PA_01:LPSSYN_01 
A1(99, 93) = A1(99, 93) - v(239); % source1:TKT2_01:xe4p#1000(1)
A1(99, 105) = A1(99, 105) - v(81); % source1:FBP_01:xfdp#001000(4)
A1(99, 81) = A1(99, 81) - v(290); % source1:F6PA_r_02:xdha#001(4)
A1(99, 83) = A1(99, 83) - v(290); % source1:F6PA_r_01:xdha#100(1)
A1(99, 207) = A1(99, 207) - v(232); % source1:TALA_01:xs7p#0010000(4)
A1(99, 129) = A1(99, 129) - v(188); % source1:PGI_01:xg6p#001000(4)
%>>> xf6p#010000#
A1(100, 100) = v(327) + v(311) + v(330) + v(185) + 2*v(266) + v(79) + 2*v(266) + v(79) + 2*v(265); % drain :TALA_r_01:PGI_r_01:TKT2_r_01:PFK_01:PEPTIDOSYN_01:F6PA_02:PEPTIDOSYN_02:F6PA_01:LPSSYN_01 
A1(100, 242) = A1(100, 242) - v(239); % source1:TKT2_01:xxu5pD#01000(2)
A1(100, 106) = A1(100, 106) - v(81); % source1:FBP_01:xfdp#010000(2)
A1(100, 82) = A1(100, 82) - v(290); % source1:F6PA_r_02:xdha#010(2)
A1(100, 82) = A1(100, 82) - v(290); % source1:F6PA_r_01:xdha#010(2)
A1(100, 208) = A1(100, 208) - v(232); % source1:TALA_01:xs7p#0100000(2)
A1(100, 130) = A1(100, 130) - v(188); % source1:PGI_01:xg6p#010000(2)
%>>> xf6p#100000#
A1(101, 101) = v(327) + v(311) + v(330) + v(185) + 2*v(266) + v(79) + 2*v(266) + v(79) + 2*v(265); % drain :TALA_r_01:PGI_r_01:TKT2_r_01:PFK_01:PEPTIDOSYN_01:F6PA_02:PEPTIDOSYN_02:F6PA_01:LPSSYN_01 
A1(101, 243) = A1(101, 243) - v(239); % source1:TKT2_01:xxu5pD#10000(1)
A1(101, 107) = A1(101, 107) - v(81); % source1:FBP_01:xfdp#100000(1)
A1(101, 83) = A1(101, 83) - v(290); % source1:F6PA_r_02:xdha#100(1)
A1(101, 81) = A1(101, 81) - v(290); % source1:F6PA_r_01:xdha#001(4)
A1(101, 209) = A1(101, 209) - v(232); % source1:TALA_01:xs7p#1000000(1)
A1(101, 131) = A1(101, 131) - v(188); % source1:PGI_01:xg6p#100000(1)
%>>> xfdp#000001#
A1(102, 102) = v(81) + v(80); % drain :FBP_01:FBA_01 
A1(102, 96) = A1(102, 96) - v(185); % source1:PFK_01:xf6p#000001(32)
A1(102, 123) = A1(102, 123) - v(291); % source1:FBA_r_01:xg3p#001(4)
%>>> xfdp#000010#
A1(103, 103) = v(81) + v(80); % drain :FBP_01:FBA_01 
A1(103, 97) = A1(103, 97) - v(185); % source1:PFK_01:xf6p#000010(16)
A1(103, 124) = A1(103, 124) - v(291); % source1:FBA_r_01:xg3p#010(2)
%>>> xfdp#000100#
A1(104, 104) = v(81) + v(80); % drain :FBP_01:FBA_01 
A1(104, 98) = A1(104, 98) - v(185); % source1:PFK_01:xf6p#000100(8)
A1(104, 125) = A1(104, 125) - v(291); % source1:FBA_r_01:xg3p#100(1)
%>>> xfdp#001000#
A1(105, 105) = v(81) + v(80); % drain :FBP_01:FBA_01 
A1(105, 99) = A1(105, 99) - v(185); % source1:PFK_01:xf6p#001000(4)
A1(105, 84) = A1(105, 84) - v(291); % source1:FBA_r_01:xdhap#001(4)
%>>> xfdp#010000#
A1(106, 106) = v(81) + v(80); % drain :FBP_01:FBA_01 
A1(106, 100) = A1(106, 100) - v(185); % source1:PFK_01:xf6p#010000(2)
A1(106, 85) = A1(106, 85) - v(291); % source1:FBA_r_01:xdhap#010(2)
%>>> xfdp#100000#
A1(107, 107) = v(81) + v(80); % drain :FBP_01:FBA_01 
A1(107, 101) = A1(107, 101) - v(185); % source1:PFK_01:xf6p#100000(1)
A1(107, 86) = A1(107, 86) - v(291); % source1:FBA_r_01:xdhap#100(1)
%>>> xformate#1#
A1(108, 108) = v(256) + v(292) + v(84) + v(83) + v(256) + v(82); % drain :IMPSYN2_02:FORt_r_01:FHL_01:FDH3_01:IMPSYN2_01:FDH2_01 
A1(108, 172) = A1(108, 172) - v(88); % source1:FTHFD_01:xmethf#1(1)
A1(108, 172) = A1(108, 172) - 3*v(259); % source1:FADSYN_03:xmethf#1(1)
A1(108, 89) = A1(108, 89) - v(73); % source1:DKMPPD_01:xdkmpp#100000(1)
A1(108, 172) = A1(108, 172) - v(269); % source1:THFSYN_01:xmethf#1(1)
A1(108, 108) = A1(108, 108) - v(85); % source1:FORt_01:xformate#1(1)
A1(108, 199) = A1(108, 199) - 3*v(259); % source1:FADSYN_01:xru5pD#00010(8)
A1(108, 199) = A1(108, 199) - 3*v(259); % source1:FADSYN_02:xru5pD#00010(8)
A1(108, 192) = A1(108, 192) - v(186); % source1:PFL_01:xpyr#100(1)
A1(108, 89) = A1(108, 89) - v(74); % source1:DKMPPD2_01:xdkmpp#100000(1)
%>>> xfum#0001#
A1(109, 109) = v(325) + v(325) + v(86) + v(87) + v(325) + v(87) + v(325) + v(325) + v(325) + v(325) + v(87) + v(325) + v(325) + v(325) + v(89) + v(325) + v(325) + v(325) + v(86) + v(325) + v(87) + v(86) + v(280) + v(280) + v(86) + v(89) + v(325) + v(325); % drain :SUCFUMt_r_11:SUCFUMt_r_07:FRD2_03:FRD3_01:SUCFUMt_r_06:FRD3_04:SUCFUMt_r_05:SUCFUMt_r_01:SUCFUMt_r_16:SUCFUMt_r_13:FRD3_03:SUCFUMt_r_15:SUCFUMt_r_02:SUCFUMt_r_08:rFUM_01:SUCFUMt_r_03:SUCFUMt_r_09:SUCFUMt_r_12:FRD2_04:SUCFUMt_r_14:FRD3_02:FRD2_01:ARGSL_r_01:ARGSL_r_02:FRD2_02:rFUM_02:SUCFUMt_r_10:SUCFUMt_r_04 
A1(109, 166) = A1(109, 166) - v(293); % source1:rFUM_r_02:xmalL#0001(8)
A1(109, 220) = A1(109, 220) - v(226); % source1:SUCD1i_04:xsucc#0001(8)
A1(109, 113) = A1(109, 113) - v(228); % source1:SUCFUMt_08:xfume#0001(8)
A1(109, 69) = A1(109, 69) - v(38); % source1:COMBO10_01:xaspL#1000(1)
A1(109, 116) = A1(109, 116) - v(228); % source1:SUCFUMt_12:xfume#1000(1)
A1(109, 63) = A1(109, 63) - v(44); % source1:ARGSL_02:xargsuc#0000000010(256)
A1(109, 113) = A1(109, 113) - v(228); % source1:SUCFUMt_02:xfume#0001(8)
A1(109, 113) = A1(109, 113) - v(228); % source1:SUCFUMt_13:xfume#0001(8)
A1(109, 113) = A1(109, 113) - v(228); % source1:SUCFUMt_09:xfume#0001(8)
A1(109, 113) = A1(109, 113) - v(90); % source1:FUMt22_03:xfume#0001(8)
A1(109, 223) = A1(109, 223) - v(226); % source1:SUCD1i_03:xsucc#1000(1)
A1(109, 116) = A1(109, 116) - v(228); % source1:SUCFUMt_03:xfume#1000(1)
A1(109, 66) = A1(109, 66) - v(256); % source1:IMPSYN2_02:xaspL#0001(8)
A1(109, 66) = A1(109, 66) - v(38); % source1:COMBO10_02:xaspL#0001(8)
A1(109, 66) = A1(109, 66) - v(255); % source1:IMPSYN1_01:xaspL#0001(8)
A1(109, 116) = A1(109, 116) - v(228); % source1:SUCFUMt_07:xfume#1000(1)
A1(109, 113) = A1(109, 113) - v(228); % source1:SUCFUMt_11:xfume#0001(8)
A1(109, 116) = A1(109, 116) - v(228); % source1:SUCFUMt_05:xfume#1000(1)
A1(109, 116) = A1(109, 116) - v(228); % source1:SUCFUMt_16:xfume#1000(1)
A1(109, 116) = A1(109, 116) - v(90); % source1:FUMt22_01:xfume#1000(1)
A1(109, 66) = A1(109, 66) - v(255); % source1:IMPSYN1_02:xaspL#0001(8)
A1(109, 113) = A1(109, 113) - v(228); % source1:SUCFUMt_15:xfume#0001(8)
A1(109, 113) = A1(109, 113) - v(91); % source1:FUMt23_03:xfume#0001(8)
A1(109, 116) = A1(109, 116) - v(228); % source1:SUCFUMt_10:xfume#1000(1)
A1(109, 113) = A1(109, 113) - v(91); % source1:FUMt23_02:xfume#0001(8)
A1(109, 116) = A1(109, 116) - v(228); % source1:SUCFUMt_01:xfume#1000(1)
A1(109, 113) = A1(109, 113) - v(228); % source1:SUCFUMt_06:xfume#0001(8)
A1(109, 116) = A1(109, 116) - v(228); % source1:SUCFUMt_14:xfume#1000(1)
A1(109, 220) = A1(109, 220) - v(226); % source1:SUCD1i_01:xsucc#0001(8)
A1(109, 116) = A1(109, 116) - v(90); % source1:FUMt22_04:xfume#1000(1)
A1(109, 116) = A1(109, 116) - v(91); % source1:FUMt23_04:xfume#1000(1)
A1(109, 66) = A1(109, 66) - v(256); % source1:IMPSYN2_01:xaspL#0001(8)
A1(109, 116) = A1(109, 116) - v(91); % source1:FUMt23_01:xfume#1000(1)
A1(109, 113) = A1(109, 113) - v(90); % source1:FUMt22_02:xfume#0001(8)
A1(109, 62) = A1(109, 62) - v(44); % source1:ARGSL_01:xargsuc#0000000001(512)
A1(109, 169) = A1(109, 169) - v(293); % source1:rFUM_r_01:xmalL#1000(1)
A1(109, 113) = A1(109, 113) - v(228); % source1:SUCFUMt_04:xfume#0001(8)
A1(109, 223) = A1(109, 223) - v(226); % source1:SUCD1i_02:xsucc#1000(1)
%>>> xfum#0010#
A1(110, 110) = v(325) + v(325) + v(86) + v(87) + v(325) + v(87) + v(325) + v(325) + v(325) + v(325) + v(87) + v(325) + v(325) + v(325) + v(89) + v(325) + v(325) + v(325) + v(86) + v(325) + v(87) + v(86) + v(280) + v(280) + v(86) + v(89) + v(325) + v(325); % drain :SUCFUMt_r_11:SUCFUMt_r_07:FRD2_03:FRD3_01:SUCFUMt_r_06:FRD3_04:SUCFUMt_r_05:SUCFUMt_r_01:SUCFUMt_r_16:SUCFUMt_r_13:FRD3_03:SUCFUMt_r_15:SUCFUMt_r_02:SUCFUMt_r_08:rFUM_01:SUCFUMt_r_03:SUCFUMt_r_09:SUCFUMt_r_12:FRD2_04:SUCFUMt_r_14:FRD3_02:FRD2_01:ARGSL_r_01:ARGSL_r_02:FRD2_02:rFUM_02:SUCFUMt_r_10:SUCFUMt_r_04 
A1(110, 167) = A1(110, 167) - v(293); % source1:rFUM_r_02:xmalL#0010(4)
A1(110, 221) = A1(110, 221) - v(226); % source1:SUCD1i_04:xsucc#0010(4)
A1(110, 114) = A1(110, 114) - v(228); % source1:SUCFUMt_08:xfume#0010(4)
A1(110, 68) = A1(110, 68) - v(38); % source1:COMBO10_01:xaspL#0100(2)
A1(110, 115) = A1(110, 115) - v(228); % source1:SUCFUMt_12:xfume#0100(2)
A1(110, 64) = A1(110, 64) - v(44); % source1:ARGSL_02:xargsuc#0000000100(128)
A1(110, 114) = A1(110, 114) - v(228); % source1:SUCFUMt_02:xfume#0010(4)
A1(110, 114) = A1(110, 114) - v(228); % source1:SUCFUMt_13:xfume#0010(4)
A1(110, 114) = A1(110, 114) - v(228); % source1:SUCFUMt_09:xfume#0010(4)
A1(110, 114) = A1(110, 114) - v(90); % source1:FUMt22_03:xfume#0010(4)
A1(110, 222) = A1(110, 222) - v(226); % source1:SUCD1i_03:xsucc#0100(2)
A1(110, 115) = A1(110, 115) - v(228); % source1:SUCFUMt_03:xfume#0100(2)
A1(110, 67) = A1(110, 67) - v(256); % source1:IMPSYN2_02:xaspL#0010(4)
A1(110, 67) = A1(110, 67) - v(38); % source1:COMBO10_02:xaspL#0010(4)
A1(110, 67) = A1(110, 67) - v(255); % source1:IMPSYN1_01:xaspL#0010(4)
A1(110, 115) = A1(110, 115) - v(228); % source1:SUCFUMt_07:xfume#0100(2)
A1(110, 114) = A1(110, 114) - v(228); % source1:SUCFUMt_11:xfume#0010(4)
A1(110, 115) = A1(110, 115) - v(228); % source1:SUCFUMt_05:xfume#0100(2)
A1(110, 115) = A1(110, 115) - v(228); % source1:SUCFUMt_16:xfume#0100(2)
A1(110, 115) = A1(110, 115) - v(90); % source1:FUMt22_01:xfume#0100(2)
A1(110, 67) = A1(110, 67) - v(255); % source1:IMPSYN1_02:xaspL#0010(4)
A1(110, 114) = A1(110, 114) - v(228); % source1:SUCFUMt_15:xfume#0010(4)
A1(110, 114) = A1(110, 114) - v(91); % source1:FUMt23_03:xfume#0010(4)
A1(110, 115) = A1(110, 115) - v(228); % source1:SUCFUMt_10:xfume#0100(2)
A1(110, 114) = A1(110, 114) - v(91); % source1:FUMt23_02:xfume#0010(4)
A1(110, 115) = A1(110, 115) - v(228); % source1:SUCFUMt_01:xfume#0100(2)
A1(110, 114) = A1(110, 114) - v(228); % source1:SUCFUMt_06:xfume#0010(4)
A1(110, 115) = A1(110, 115) - v(228); % source1:SUCFUMt_14:xfume#0100(2)
A1(110, 221) = A1(110, 221) - v(226); % source1:SUCD1i_01:xsucc#0010(4)
A1(110, 115) = A1(110, 115) - v(90); % source1:FUMt22_04:xfume#0100(2)
A1(110, 115) = A1(110, 115) - v(91); % source1:FUMt23_04:xfume#0100(2)
A1(110, 67) = A1(110, 67) - v(256); % source1:IMPSYN2_01:xaspL#0010(4)
A1(110, 115) = A1(110, 115) - v(91); % source1:FUMt23_01:xfume#0100(2)
A1(110, 114) = A1(110, 114) - v(90); % source1:FUMt22_02:xfume#0010(4)
A1(110, 65) = A1(110, 65) - v(44); % source1:ARGSL_01:xargsuc#0000001000(64)
A1(110, 168) = A1(110, 168) - v(293); % source1:rFUM_r_01:xmalL#0100(2)
A1(110, 114) = A1(110, 114) - v(228); % source1:SUCFUMt_04:xfume#0010(4)
A1(110, 222) = A1(110, 222) - v(226); % source1:SUCD1i_02:xsucc#0100(2)
%>>> xfum#0100#
A1(111, 111) = v(325) + v(325) + v(86) + v(87) + v(325) + v(87) + v(325) + v(325) + v(325) + v(325) + v(87) + v(325) + v(325) + v(325) + v(89) + v(325) + v(325) + v(325) + v(86) + v(325) + v(87) + v(86) + v(280) + v(280) + v(86) + v(89) + v(325) + v(325); % drain :SUCFUMt_r_11:SUCFUMt_r_07:FRD2_03:FRD3_01:SUCFUMt_r_06:FRD3_04:SUCFUMt_r_05:SUCFUMt_r_01:SUCFUMt_r_16:SUCFUMt_r_13:FRD3_03:SUCFUMt_r_15:SUCFUMt_r_02:SUCFUMt_r_08:rFUM_01:SUCFUMt_r_03:SUCFUMt_r_09:SUCFUMt_r_12:FRD2_04:SUCFUMt_r_14:FRD3_02:FRD2_01:ARGSL_r_01:ARGSL_r_02:FRD2_02:rFUM_02:SUCFUMt_r_10:SUCFUMt_r_04 
A1(111, 168) = A1(111, 168) - v(293); % source1:rFUM_r_02:xmalL#0100(2)
A1(111, 222) = A1(111, 222) - v(226); % source1:SUCD1i_04:xsucc#0100(2)
A1(111, 115) = A1(111, 115) - v(228); % source1:SUCFUMt_08:xfume#0100(2)
A1(111, 67) = A1(111, 67) - v(38); % source1:COMBO10_01:xaspL#0010(4)
A1(111, 114) = A1(111, 114) - v(228); % source1:SUCFUMt_12:xfume#0010(4)
A1(111, 65) = A1(111, 65) - v(44); % source1:ARGSL_02:xargsuc#0000001000(64)
A1(111, 115) = A1(111, 115) - v(228); % source1:SUCFUMt_02:xfume#0100(2)
A1(111, 115) = A1(111, 115) - v(228); % source1:SUCFUMt_13:xfume#0100(2)
A1(111, 115) = A1(111, 115) - v(228); % source1:SUCFUMt_09:xfume#0100(2)
A1(111, 115) = A1(111, 115) - v(90); % source1:FUMt22_03:xfume#0100(2)
A1(111, 221) = A1(111, 221) - v(226); % source1:SUCD1i_03:xsucc#0010(4)
A1(111, 114) = A1(111, 114) - v(228); % source1:SUCFUMt_03:xfume#0010(4)
A1(111, 68) = A1(111, 68) - v(256); % source1:IMPSYN2_02:xaspL#0100(2)
A1(111, 68) = A1(111, 68) - v(38); % source1:COMBO10_02:xaspL#0100(2)
A1(111, 68) = A1(111, 68) - v(255); % source1:IMPSYN1_01:xaspL#0100(2)
A1(111, 114) = A1(111, 114) - v(228); % source1:SUCFUMt_07:xfume#0010(4)
A1(111, 115) = A1(111, 115) - v(228); % source1:SUCFUMt_11:xfume#0100(2)
A1(111, 114) = A1(111, 114) - v(228); % source1:SUCFUMt_05:xfume#0010(4)
A1(111, 114) = A1(111, 114) - v(228); % source1:SUCFUMt_16:xfume#0010(4)
A1(111, 114) = A1(111, 114) - v(90); % source1:FUMt22_01:xfume#0010(4)
A1(111, 68) = A1(111, 68) - v(255); % source1:IMPSYN1_02:xaspL#0100(2)
A1(111, 115) = A1(111, 115) - v(228); % source1:SUCFUMt_15:xfume#0100(2)
A1(111, 115) = A1(111, 115) - v(91); % source1:FUMt23_03:xfume#0100(2)
A1(111, 114) = A1(111, 114) - v(228); % source1:SUCFUMt_10:xfume#0010(4)
A1(111, 115) = A1(111, 115) - v(91); % source1:FUMt23_02:xfume#0100(2)
A1(111, 114) = A1(111, 114) - v(228); % source1:SUCFUMt_01:xfume#0010(4)
A1(111, 115) = A1(111, 115) - v(228); % source1:SUCFUMt_06:xfume#0100(2)
A1(111, 114) = A1(111, 114) - v(228); % source1:SUCFUMt_14:xfume#0010(4)
A1(111, 222) = A1(111, 222) - v(226); % source1:SUCD1i_01:xsucc#0100(2)
A1(111, 114) = A1(111, 114) - v(90); % source1:FUMt22_04:xfume#0010(4)
A1(111, 114) = A1(111, 114) - v(91); % source1:FUMt23_04:xfume#0010(4)
A1(111, 68) = A1(111, 68) - v(256); % source1:IMPSYN2_01:xaspL#0100(2)
A1(111, 114) = A1(111, 114) - v(91); % source1:FUMt23_01:xfume#0010(4)
A1(111, 115) = A1(111, 115) - v(90); % source1:FUMt22_02:xfume#0100(2)
A1(111, 64) = A1(111, 64) - v(44); % source1:ARGSL_01:xargsuc#0000000100(128)
A1(111, 167) = A1(111, 167) - v(293); % source1:rFUM_r_01:xmalL#0010(4)
A1(111, 115) = A1(111, 115) - v(228); % source1:SUCFUMt_04:xfume#0100(2)
A1(111, 221) = A1(111, 221) - v(226); % source1:SUCD1i_02:xsucc#0010(4)
%>>> xfum#1000#
A1(112, 112) = v(325) + v(325) + v(86) + v(87) + v(325) + v(87) + v(325) + v(325) + v(325) + v(325) + v(87) + v(325) + v(325) + v(325) + v(89) + v(325) + v(325) + v(325) + v(86) + v(325) + v(87) + v(86) + v(280) + v(280) + v(86) + v(89) + v(325) + v(325); % drain :SUCFUMt_r_11:SUCFUMt_r_07:FRD2_03:FRD3_01:SUCFUMt_r_06:FRD3_04:SUCFUMt_r_05:SUCFUMt_r_01:SUCFUMt_r_16:SUCFUMt_r_13:FRD3_03:SUCFUMt_r_15:SUCFUMt_r_02:SUCFUMt_r_08:rFUM_01:SUCFUMt_r_03:SUCFUMt_r_09:SUCFUMt_r_12:FRD2_04:SUCFUMt_r_14:FRD3_02:FRD2_01:ARGSL_r_01:ARGSL_r_02:FRD2_02:rFUM_02:SUCFUMt_r_10:SUCFUMt_r_04 
A1(112, 169) = A1(112, 169) - v(293); % source1:rFUM_r_02:xmalL#1000(1)
A1(112, 223) = A1(112, 223) - v(226); % source1:SUCD1i_04:xsucc#1000(1)
A1(112, 116) = A1(112, 116) - v(228); % source1:SUCFUMt_08:xfume#1000(1)
A1(112, 66) = A1(112, 66) - v(38); % source1:COMBO10_01:xaspL#0001(8)
A1(112, 113) = A1(112, 113) - v(228); % source1:SUCFUMt_12:xfume#0001(8)
A1(112, 62) = A1(112, 62) - v(44); % source1:ARGSL_02:xargsuc#0000000001(512)
A1(112, 116) = A1(112, 116) - v(228); % source1:SUCFUMt_02:xfume#1000(1)
A1(112, 116) = A1(112, 116) - v(228); % source1:SUCFUMt_13:xfume#1000(1)
A1(112, 116) = A1(112, 116) - v(228); % source1:SUCFUMt_09:xfume#1000(1)
A1(112, 116) = A1(112, 116) - v(90); % source1:FUMt22_03:xfume#1000(1)
A1(112, 220) = A1(112, 220) - v(226); % source1:SUCD1i_03:xsucc#0001(8)
A1(112, 113) = A1(112, 113) - v(228); % source1:SUCFUMt_03:xfume#0001(8)
A1(112, 69) = A1(112, 69) - v(256); % source1:IMPSYN2_02:xaspL#1000(1)
A1(112, 69) = A1(112, 69) - v(38); % source1:COMBO10_02:xaspL#1000(1)
A1(112, 69) = A1(112, 69) - v(255); % source1:IMPSYN1_01:xaspL#1000(1)
A1(112, 113) = A1(112, 113) - v(228); % source1:SUCFUMt_07:xfume#0001(8)
A1(112, 116) = A1(112, 116) - v(228); % source1:SUCFUMt_11:xfume#1000(1)
A1(112, 113) = A1(112, 113) - v(228); % source1:SUCFUMt_05:xfume#0001(8)
A1(112, 113) = A1(112, 113) - v(228); % source1:SUCFUMt_16:xfume#0001(8)
A1(112, 113) = A1(112, 113) - v(90); % source1:FUMt22_01:xfume#0001(8)
A1(112, 69) = A1(112, 69) - v(255); % source1:IMPSYN1_02:xaspL#1000(1)
A1(112, 116) = A1(112, 116) - v(228); % source1:SUCFUMt_15:xfume#1000(1)
A1(112, 116) = A1(112, 116) - v(91); % source1:FUMt23_03:xfume#1000(1)
A1(112, 113) = A1(112, 113) - v(228); % source1:SUCFUMt_10:xfume#0001(8)
A1(112, 116) = A1(112, 116) - v(91); % source1:FUMt23_02:xfume#1000(1)
A1(112, 113) = A1(112, 113) - v(228); % source1:SUCFUMt_01:xfume#0001(8)
A1(112, 116) = A1(112, 116) - v(228); % source1:SUCFUMt_06:xfume#1000(1)
A1(112, 113) = A1(112, 113) - v(228); % source1:SUCFUMt_14:xfume#0001(8)
A1(112, 223) = A1(112, 223) - v(226); % source1:SUCD1i_01:xsucc#1000(1)
A1(112, 113) = A1(112, 113) - v(90); % source1:FUMt22_04:xfume#0001(8)
A1(112, 113) = A1(112, 113) - v(91); % source1:FUMt23_04:xfume#0001(8)
A1(112, 69) = A1(112, 69) - v(256); % source1:IMPSYN2_01:xaspL#1000(1)
A1(112, 113) = A1(112, 113) - v(91); % source1:FUMt23_01:xfume#0001(8)
A1(112, 116) = A1(112, 116) - v(90); % source1:FUMt22_02:xfume#1000(1)
A1(112, 63) = A1(112, 63) - v(44); % source1:ARGSL_01:xargsuc#0000000010(256)
A1(112, 166) = A1(112, 166) - v(293); % source1:rFUM_r_01:xmalL#0001(8)
A1(112, 116) = A1(112, 116) - v(228); % source1:SUCFUMt_04:xfume#1000(1)
A1(112, 220) = A1(112, 220) - v(226); % source1:SUCD1i_02:xsucc#0001(8)
%>>> xfume#0001#
A1(113, 113) = v(228) + v(228) + v(228) + v(91) + v(228) + v(228) + v(91) + v(228) + v(228) + v(228) + v(228) + v(90) + v(228) + v(6) + v(228) + v(90) + v(228) + v(91) + v(90) + v(91) + v(6) + v(228) + v(228) + v(228) + v(90) + v(228); % drain :SUCFUMt_15:SUCFUMt_08:SUCFUMt_12:FUMt23_03:SUCFUMt_10:SUCFUMt_02:FUMt23_02:SUCFUMt_13:SUCFUMt_09:SUCFUMt_01:SUCFUMt_06:FUMt22_03:SUCFUMt_03:EX_fum_01:SUCFUMt_14:FUMt22_04:SUCFUMt_07:FUMt23_04:FUMt22_02:FUMt23_01:EX_fum_02:SUCFUMt_11:SUCFUMt_05:SUCFUMt_16:FUMt22_01:SUCFUMt_04 
A1(113, 109) = A1(113, 109) - v(325); % source1:SUCFUMt_r_11:xfum#0001(8)
A1(113, 112) = A1(113, 112) - v(325); % source1:SUCFUMt_r_07:xfum#1000(1)
A1(113, 109) = A1(113, 109) - v(325); % source1:SUCFUMt_r_06:xfum#0001(8)
A1(113, 112) = A1(113, 112) - v(325); % source1:SUCFUMt_r_01:xfum#1000(1)
A1(113, 112) = A1(113, 112) - v(325); % source1:SUCFUMt_r_05:xfum#1000(1)
A1(113, 112) = A1(113, 112) - v(325); % source1:SUCFUMt_r_16:xfum#1000(1)
A1(113, 109) = A1(113, 109) - v(325); % source1:SUCFUMt_r_13:xfum#0001(8)
A1(113, 109) = A1(113, 109) - v(325); % source1:SUCFUMt_r_02:xfum#0001(8)
A1(113, 109) = A1(113, 109) - v(325); % source1:SUCFUMt_r_15:xfum#0001(8)
A1(113, 109) = A1(113, 109) - v(325); % source1:SUCFUMt_r_08:xfum#0001(8)
A1(113, 112) = A1(113, 112) - v(325); % source1:SUCFUMt_r_03:xfum#1000(1)
A1(113, 109) = A1(113, 109) - v(325); % source1:SUCFUMt_r_09:xfum#0001(8)
A1(113, 112) = A1(113, 112) - v(325); % source1:SUCFUMt_r_12:xfum#1000(1)
A1(113, 112) = A1(113, 112) - v(325); % source1:SUCFUMt_r_14:xfum#1000(1)
A1(113, 112) = A1(113, 112) - v(325); % source1:SUCFUMt_r_10:xfum#1000(1)
A1(113, 109) = A1(113, 109) - v(325); % source1:SUCFUMt_r_04:xfum#0001(8)
%>>> xfume#0010#
A1(114, 114) = v(228) + v(228) + v(228) + v(91) + v(228) + v(228) + v(91) + v(228) + v(228) + v(228) + v(228) + v(90) + v(228) + v(6) + v(228) + v(90) + v(228) + v(91) + v(90) + v(91) + v(6) + v(228) + v(228) + v(228) + v(90) + v(228); % drain :SUCFUMt_15:SUCFUMt_08:SUCFUMt_12:FUMt23_03:SUCFUMt_10:SUCFUMt_02:FUMt23_02:SUCFUMt_13:SUCFUMt_09:SUCFUMt_01:SUCFUMt_06:FUMt22_03:SUCFUMt_03:EX_fum_01:SUCFUMt_14:FUMt22_04:SUCFUMt_07:FUMt23_04:FUMt22_02:FUMt23_01:EX_fum_02:SUCFUMt_11:SUCFUMt_05:SUCFUMt_16:FUMt22_01:SUCFUMt_04 
A1(114, 110) = A1(114, 110) - v(325); % source1:SUCFUMt_r_11:xfum#0010(4)
A1(114, 111) = A1(114, 111) - v(325); % source1:SUCFUMt_r_07:xfum#0100(2)
A1(114, 110) = A1(114, 110) - v(325); % source1:SUCFUMt_r_06:xfum#0010(4)
A1(114, 111) = A1(114, 111) - v(325); % source1:SUCFUMt_r_01:xfum#0100(2)
A1(114, 111) = A1(114, 111) - v(325); % source1:SUCFUMt_r_05:xfum#0100(2)
A1(114, 111) = A1(114, 111) - v(325); % source1:SUCFUMt_r_16:xfum#0100(2)
A1(114, 110) = A1(114, 110) - v(325); % source1:SUCFUMt_r_13:xfum#0010(4)
A1(114, 110) = A1(114, 110) - v(325); % source1:SUCFUMt_r_02:xfum#0010(4)
A1(114, 110) = A1(114, 110) - v(325); % source1:SUCFUMt_r_15:xfum#0010(4)
A1(114, 110) = A1(114, 110) - v(325); % source1:SUCFUMt_r_08:xfum#0010(4)
A1(114, 111) = A1(114, 111) - v(325); % source1:SUCFUMt_r_03:xfum#0100(2)
A1(114, 110) = A1(114, 110) - v(325); % source1:SUCFUMt_r_09:xfum#0010(4)
A1(114, 111) = A1(114, 111) - v(325); % source1:SUCFUMt_r_12:xfum#0100(2)
A1(114, 111) = A1(114, 111) - v(325); % source1:SUCFUMt_r_14:xfum#0100(2)
A1(114, 111) = A1(114, 111) - v(325); % source1:SUCFUMt_r_10:xfum#0100(2)
A1(114, 110) = A1(114, 110) - v(325); % source1:SUCFUMt_r_04:xfum#0010(4)
%>>> xfume#0100#
A1(115, 115) = v(228) + v(228) + v(228) + v(91) + v(228) + v(228) + v(91) + v(228) + v(228) + v(228) + v(228) + v(90) + v(228) + v(6) + v(228) + v(90) + v(228) + v(91) + v(90) + v(91) + v(6) + v(228) + v(228) + v(228) + v(90) + v(228); % drain :SUCFUMt_15:SUCFUMt_08:SUCFUMt_12:FUMt23_03:SUCFUMt_10:SUCFUMt_02:FUMt23_02:SUCFUMt_13:SUCFUMt_09:SUCFUMt_01:SUCFUMt_06:FUMt22_03:SUCFUMt_03:EX_fum_01:SUCFUMt_14:FUMt22_04:SUCFUMt_07:FUMt23_04:FUMt22_02:FUMt23_01:EX_fum_02:SUCFUMt_11:SUCFUMt_05:SUCFUMt_16:FUMt22_01:SUCFUMt_04 
A1(115, 111) = A1(115, 111) - v(325); % source1:SUCFUMt_r_11:xfum#0100(2)
A1(115, 110) = A1(115, 110) - v(325); % source1:SUCFUMt_r_07:xfum#0010(4)
A1(115, 111) = A1(115, 111) - v(325); % source1:SUCFUMt_r_06:xfum#0100(2)
A1(115, 110) = A1(115, 110) - v(325); % source1:SUCFUMt_r_01:xfum#0010(4)
A1(115, 110) = A1(115, 110) - v(325); % source1:SUCFUMt_r_05:xfum#0010(4)
A1(115, 110) = A1(115, 110) - v(325); % source1:SUCFUMt_r_16:xfum#0010(4)
A1(115, 111) = A1(115, 111) - v(325); % source1:SUCFUMt_r_13:xfum#0100(2)
A1(115, 111) = A1(115, 111) - v(325); % source1:SUCFUMt_r_02:xfum#0100(2)
A1(115, 111) = A1(115, 111) - v(325); % source1:SUCFUMt_r_15:xfum#0100(2)
A1(115, 111) = A1(115, 111) - v(325); % source1:SUCFUMt_r_08:xfum#0100(2)
A1(115, 110) = A1(115, 110) - v(325); % source1:SUCFUMt_r_03:xfum#0010(4)
A1(115, 111) = A1(115, 111) - v(325); % source1:SUCFUMt_r_09:xfum#0100(2)
A1(115, 110) = A1(115, 110) - v(325); % source1:SUCFUMt_r_12:xfum#0010(4)
A1(115, 110) = A1(115, 110) - v(325); % source1:SUCFUMt_r_14:xfum#0010(4)
A1(115, 110) = A1(115, 110) - v(325); % source1:SUCFUMt_r_10:xfum#0010(4)
A1(115, 111) = A1(115, 111) - v(325); % source1:SUCFUMt_r_04:xfum#0100(2)
%>>> xfume#1000#
A1(116, 116) = v(228) + v(228) + v(228) + v(91) + v(228) + v(228) + v(91) + v(228) + v(228) + v(228) + v(228) + v(90) + v(228) + v(6) + v(228) + v(90) + v(228) + v(91) + v(90) + v(91) + v(6) + v(228) + v(228) + v(228) + v(90) + v(228); % drain :SUCFUMt_15:SUCFUMt_08:SUCFUMt_12:FUMt23_03:SUCFUMt_10:SUCFUMt_02:FUMt23_02:SUCFUMt_13:SUCFUMt_09:SUCFUMt_01:SUCFUMt_06:FUMt22_03:SUCFUMt_03:EX_fum_01:SUCFUMt_14:FUMt22_04:SUCFUMt_07:FUMt23_04:FUMt22_02:FUMt23_01:EX_fum_02:SUCFUMt_11:SUCFUMt_05:SUCFUMt_16:FUMt22_01:SUCFUMt_04 
A1(116, 112) = A1(116, 112) - v(325); % source1:SUCFUMt_r_11:xfum#1000(1)
A1(116, 109) = A1(116, 109) - v(325); % source1:SUCFUMt_r_07:xfum#0001(8)
A1(116, 112) = A1(116, 112) - v(325); % source1:SUCFUMt_r_06:xfum#1000(1)
A1(116, 109) = A1(116, 109) - v(325); % source1:SUCFUMt_r_01:xfum#0001(8)
A1(116, 109) = A1(116, 109) - v(325); % source1:SUCFUMt_r_05:xfum#0001(8)
A1(116, 109) = A1(116, 109) - v(325); % source1:SUCFUMt_r_16:xfum#0001(8)
A1(116, 112) = A1(116, 112) - v(325); % source1:SUCFUMt_r_13:xfum#1000(1)
A1(116, 112) = A1(116, 112) - v(325); % source1:SUCFUMt_r_02:xfum#1000(1)
A1(116, 112) = A1(116, 112) - v(325); % source1:SUCFUMt_r_15:xfum#1000(1)
A1(116, 112) = A1(116, 112) - v(325); % source1:SUCFUMt_r_08:xfum#1000(1)
A1(116, 109) = A1(116, 109) - v(325); % source1:SUCFUMt_r_03:xfum#0001(8)
A1(116, 112) = A1(116, 112) - v(325); % source1:SUCFUMt_r_09:xfum#1000(1)
A1(116, 109) = A1(116, 109) - v(325); % source1:SUCFUMt_r_12:xfum#0001(8)
A1(116, 109) = A1(116, 109) - v(325); % source1:SUCFUMt_r_14:xfum#0001(8)
A1(116, 109) = A1(116, 109) - v(325); % source1:SUCFUMt_r_10:xfum#0001(8)
A1(116, 112) = A1(116, 112) - v(325); % source1:SUCFUMt_r_04:xfum#1000(1)
%>>> xg1p#000001#
A1(117, 117) = v(104) + 0.003*v(1) + v(92) + 2*v(265) + v(192); % drain :COMBO36_01:BiomassEcoliGALUi_01:G1PP_01:LPSSYN_01:PGMT_01 
A1(117, 126) = A1(117, 126) - v(314); % source1:PGMT_r_01:xg6p#000001(32)
A1(117, 117) = A1(117, 117) - v(103); % source1:GLCP_01:xg1p#000001(32)
%>>> xg1p#000010#
A1(118, 118) = v(104) + 0.003*v(1) + v(92) + 2*v(265) + v(192); % drain :COMBO36_01:BiomassEcoliGALUi_01:G1PP_01:LPSSYN_01:PGMT_01 
A1(118, 127) = A1(118, 127) - v(314); % source1:PGMT_r_01:xg6p#000010(16)
A1(118, 118) = A1(118, 118) - v(103); % source1:GLCP_01:xg1p#000010(16)
%>>> xg1p#000100#
A1(119, 119) = v(104) + 0.003*v(1) + v(92) + 2*v(265) + v(192); % drain :COMBO36_01:BiomassEcoliGALUi_01:G1PP_01:LPSSYN_01:PGMT_01 
A1(119, 128) = A1(119, 128) - v(314); % source1:PGMT_r_01:xg6p#000100(8)
A1(119, 119) = A1(119, 119) - v(103); % source1:GLCP_01:xg1p#000100(8)
%>>> xg1p#001000#
A1(120, 120) = v(104) + 0.003*v(1) + v(92) + 2*v(265) + v(192); % drain :COMBO36_01:BiomassEcoliGALUi_01:G1PP_01:LPSSYN_01:PGMT_01 
A1(120, 129) = A1(120, 129) - v(314); % source1:PGMT_r_01:xg6p#001000(4)
A1(120, 120) = A1(120, 120) - v(103); % source1:GLCP_01:xg1p#001000(4)
%>>> xg1p#010000#
A1(121, 121) = v(104) + 0.003*v(1) + v(92) + 2*v(265) + v(192); % drain :COMBO36_01:BiomassEcoliGALUi_01:G1PP_01:LPSSYN_01:PGMT_01 
A1(121, 130) = A1(121, 130) - v(314); % source1:PGMT_r_01:xg6p#010000(2)
A1(121, 121) = A1(121, 121) - v(103); % source1:GLCP_01:xg1p#010000(2)
%>>> xg1p#100000#
A1(122, 122) = v(104) + 0.003*v(1) + v(92) + 2*v(265) + v(192); % drain :COMBO36_01:BiomassEcoliGALUi_01:G1PP_01:LPSSYN_01:PGMT_01 
A1(122, 131) = A1(122, 131) - v(314); % source1:PGMT_r_01:xg6p#100000(1)
A1(122, 122) = A1(122, 122) - v(103); % source1:GLCP_01:xg1p#100000(1)
%>>> xg3p#001#
A1(123, 123) = v(331) + v(290) + v(290) + v(330) + v(291) + v(100) + v(232) + v(329); % drain :TPI_r_01:F6PA_r_02:F6PA_r_01:TKT2_r_01:FBA_r_01:GAPD_01:TALA_01:TKT1_r_01 
A1(123, 126) = A1(123, 126) - v(75); % source1:EDA_01:xg6p#000001(32)
A1(123, 96) = A1(123, 96) - v(327); % source1:TALA_r_01:xf6p#000001(32)
A1(123, 1) = A1(123, 1) - v(296); % source1:GAPD_r_01:x13dpg#001(4)
A1(123, 239) = A1(123, 239) - v(238); % source1:TKT1_01:xxu5pD#00001(16)
A1(123, 102) = A1(123, 102) - v(80); % source1:FBA_01:xfdp#000001(32)
A1(123, 239) = A1(123, 239) - v(239); % source1:TKT2_01:xxu5pD#00001(16)
A1(123, 86) = A1(123, 86) - v(240); % source1:TPI_01:xdhap#100(1)
A1(123, 193) = A1(123, 193) - v(245); % source1:TRPS3_01:xr5p#00001(16)
A1(123, 96) = A1(123, 96) - v(79); % source1:F6PA_02:xf6p#000001(32)
A1(123, 96) = A1(123, 96) - v(79); % source1:F6PA_01:xf6p#000001(32)
A1(123, 193) = A1(123, 193) - v(243); % source1:TRPS1_01:xr5p#00001(16)
%>>> xg3p#010#
A1(124, 124) = v(331) + v(290) + v(290) + v(330) + v(291) + v(100) + v(232) + v(329); % drain :TPI_r_01:F6PA_r_02:F6PA_r_01:TKT2_r_01:FBA_r_01:GAPD_01:TALA_01:TKT1_r_01 
A1(124, 127) = A1(124, 127) - v(75); % source1:EDA_01:xg6p#000010(16)
A1(124, 97) = A1(124, 97) - v(327); % source1:TALA_r_01:xf6p#000010(16)
A1(124, 2) = A1(124, 2) - v(296); % source1:GAPD_r_01:x13dpg#010(2)
A1(124, 240) = A1(124, 240) - v(238); % source1:TKT1_01:xxu5pD#00010(8)
A1(124, 103) = A1(124, 103) - v(80); % source1:FBA_01:xfdp#000010(16)
A1(124, 240) = A1(124, 240) - v(239); % source1:TKT2_01:xxu5pD#00010(8)
A1(124, 85) = A1(124, 85) - v(240); % source1:TPI_01:xdhap#010(2)
A1(124, 194) = A1(124, 194) - v(245); % source1:TRPS3_01:xr5p#00010(8)
A1(124, 97) = A1(124, 97) - v(79); % source1:F6PA_02:xf6p#000010(16)
A1(124, 97) = A1(124, 97) - v(79); % source1:F6PA_01:xf6p#000010(16)
A1(124, 194) = A1(124, 194) - v(243); % source1:TRPS1_01:xr5p#00010(8)
%>>> xg3p#100#
A1(125, 125) = v(331) + v(290) + v(290) + v(330) + v(291) + v(100) + v(232) + v(329); % drain :TPI_r_01:F6PA_r_02:F6PA_r_01:TKT2_r_01:FBA_r_01:GAPD_01:TALA_01:TKT1_r_01 
A1(125, 128) = A1(125, 128) - v(75); % source1:EDA_01:xg6p#000100(8)
A1(125, 98) = A1(125, 98) - v(327); % source1:TALA_r_01:xf6p#000100(8)
A1(125, 3) = A1(125, 3) - v(296); % source1:GAPD_r_01:x13dpg#100(1)
A1(125, 241) = A1(125, 241) - v(238); % source1:TKT1_01:xxu5pD#00100(4)
A1(125, 104) = A1(125, 104) - v(80); % source1:FBA_01:xfdp#000100(8)
A1(125, 241) = A1(125, 241) - v(239); % source1:TKT2_01:xxu5pD#00100(4)
A1(125, 84) = A1(125, 84) - v(240); % source1:TPI_01:xdhap#001(4)
A1(125, 195) = A1(125, 195) - v(245); % source1:TRPS3_01:xr5p#00100(4)
A1(125, 98) = A1(125, 98) - v(79); % source1:F6PA_02:xf6p#000100(8)
A1(125, 98) = A1(125, 98) - v(79); % source1:F6PA_01:xf6p#000100(8)
A1(125, 195) = A1(125, 195) - v(243); % source1:TRPS1_01:xr5p#00100(4)
%>>> xg6p#000001#
A1(126, 126) = v(99) + v(314) + v(188); % drain :G6PDH2r_01:PGMT_r_01:PGI_01 
A1(126, 117) = A1(126, 117) - v(128); % source1:HEX1_01:xg1p#000001(32)
A1(126, 126) = A1(126, 126) - v(295); % source1:G6PDH2r_r_01:xg6p#000001(32)
A1(126, 96) = A1(126, 96) - v(311); % source1:PGI_r_01:xf6p#000001(32)
B1(126,:) = B1(126,:) + xglcDe.x000001' * v(105); % source1:GLCpts_01:xglcDe#000001(32)
A1(126, 117) = A1(126, 117) - v(192); % source1:PGMT_01:xg1p#000001(32)
%>>> xg6p#000010#
A1(127, 127) = v(99) + v(314) + v(188); % drain :G6PDH2r_01:PGMT_r_01:PGI_01 
A1(127, 118) = A1(127, 118) - v(128); % source1:HEX1_01:xg1p#000010(16)
A1(127, 127) = A1(127, 127) - v(295); % source1:G6PDH2r_r_01:xg6p#000010(16)
A1(127, 97) = A1(127, 97) - v(311); % source1:PGI_r_01:xf6p#000010(16)
B1(127,:) = B1(127,:) + xglcDe.x000010' * v(105); % source1:GLCpts_01:xglcDe#000010(16)
A1(127, 118) = A1(127, 118) - v(192); % source1:PGMT_01:xg1p#000010(16)
%>>> xg6p#000100#
A1(128, 128) = v(99) + v(314) + v(188); % drain :G6PDH2r_01:PGMT_r_01:PGI_01 
A1(128, 119) = A1(128, 119) - v(128); % source1:HEX1_01:xg1p#000100(8)
A1(128, 128) = A1(128, 128) - v(295); % source1:G6PDH2r_r_01:xg6p#000100(8)
A1(128, 98) = A1(128, 98) - v(311); % source1:PGI_r_01:xf6p#000100(8)
B1(128,:) = B1(128,:) + xglcDe.x000100' * v(105); % source1:GLCpts_01:xglcDe#000100(8)
A1(128, 119) = A1(128, 119) - v(192); % source1:PGMT_01:xg1p#000100(8)
%>>> xg6p#001000#
A1(129, 129) = v(99) + v(314) + v(188); % drain :G6PDH2r_01:PGMT_r_01:PGI_01 
A1(129, 120) = A1(129, 120) - v(128); % source1:HEX1_01:xg1p#001000(4)
A1(129, 129) = A1(129, 129) - v(295); % source1:G6PDH2r_r_01:xg6p#001000(4)
A1(129, 99) = A1(129, 99) - v(311); % source1:PGI_r_01:xf6p#001000(4)
B1(129,:) = B1(129,:) + xglcDe.x001000' * v(105); % source1:GLCpts_01:xglcDe#001000(4)
A1(129, 120) = A1(129, 120) - v(192); % source1:PGMT_01:xg1p#001000(4)
%>>> xg6p#010000#
A1(130, 130) = v(99) + v(314) + v(188); % drain :G6PDH2r_01:PGMT_r_01:PGI_01 
A1(130, 121) = A1(130, 121) - v(128); % source1:HEX1_01:xg1p#010000(2)
A1(130, 130) = A1(130, 130) - v(295); % source1:G6PDH2r_r_01:xg6p#010000(2)
A1(130, 100) = A1(130, 100) - v(311); % source1:PGI_r_01:xf6p#010000(2)
B1(130,:) = B1(130,:) + xglcDe.x010000' * v(105); % source1:GLCpts_01:xglcDe#010000(2)
A1(130, 121) = A1(130, 121) - v(192); % source1:PGMT_01:xg1p#010000(2)
%>>> xg6p#100000#
A1(131, 131) = v(99) + v(314) + v(188); % drain :G6PDH2r_01:PGMT_r_01:PGI_01 
A1(131, 122) = A1(131, 122) - v(128); % source1:HEX1_01:xg1p#100000(1)
A1(131, 131) = A1(131, 131) - v(295); % source1:G6PDH2r_r_01:xg6p#100000(1)
A1(131, 101) = A1(131, 101) - v(311); % source1:PGI_r_01:xf6p#100000(1)
B1(131,:) = B1(131,:) + xglcDe.x100000' * v(105); % source1:GLCpts_01:xglcDe#100000(1)
A1(131, 122) = A1(131, 122) - v(192); % source1:PGMT_01:xg1p#100000(1)
%>>> xglu5sa#00001#
A1(132, 132) = v(97); % drain :G5SADs_01 
A1(132, 47) = A1(132, 47) - v(157); % source1:NACODA_01:xacg5sa#0000100(16)
A1(132, 137) = A1(132, 137) - v(98); % source1:COMBO34_01:xgluL#00001(16)
%>>> xglu5sa#00010#
A1(133, 133) = v(97); % drain :G5SADs_01 
A1(133, 48) = A1(133, 48) - v(157); % source1:NACODA_01:xacg5sa#0001000(8)
A1(133, 138) = A1(133, 138) - v(98); % source1:COMBO34_01:xgluL#00010(8)
%>>> xglu5sa#00100#
A1(134, 134) = v(97); % drain :G5SADs_01 
A1(134, 49) = A1(134, 49) - v(157); % source1:NACODA_01:xacg5sa#0010000(4)
A1(134, 139) = A1(134, 139) - v(98); % source1:COMBO34_01:xgluL#00100(4)
%>>> xglu5sa#01000#
A1(135, 135) = v(97); % drain :G5SADs_01 
A1(135, 50) = A1(135, 50) - v(157); % source1:NACODA_01:xacg5sa#0100000(2)
A1(135, 140) = A1(135, 140) - v(98); % source1:COMBO34_01:xgluL#01000(2)
%>>> xglu5sa#10000#
A1(136, 136) = v(97); % drain :G5SADs_01 
A1(136, 51) = A1(136, 51) - v(157); % source1:NACODA_01:xacg5sa#1000000(1)
A1(136, 141) = A1(136, 141) - v(98); % source1:COMBO34_01:xgluL#10000(1)
%>>> xgluL#00001#
A1(137, 137) = v(333) + v(315) + v(274) + v(98) + v(24) + v(322) + v(147) + v(334) + v(333) + v(302) + v(187) + 0.25*v(1) + v(315) + v(315) + v(107) + v(249) + v(333) + v(279) + v(106) + v(283) + v(108) + v(333) + v(315); % drain :TYRTA_r_04:PHETA1_r_03:ACOTA_r_01:COMBO34_01:COMBO3_01:SDPTA_r_01:LEUTAi_01:VALTA_r_01:TYRTA_r_02:ILETA_r_01:COMBO47_01:BiomassEcoliGALUi_01:PHETA1_r_02:PHETA1_r_04:GLUDC_01:UNK3_01:TYRTA_r_01:ALATAL_r_01:GLNS_01:ASPTA_r_01:GLUDy_01:TYRTA_r_03:PHETA1_r_01 
A1(137, 137) = A1(137, 137) - v(124); % source1:GMPS2_01:xgluL#00001(16)
A1(137, 54) = A1(137, 54) - v(297); % source1:GLUDy_r_01:xakg#00001(16)
A1(137, 54) = A1(137, 54) - v(247); % source1:TYRTA_04:xakg#00001(16)
A1(137, 54) = A1(137, 54) - v(247); % source1:TYRTA_02:xakg#00001(16)
A1(137, 54) = A1(137, 54) - v(250); % source1:VALTA_01:xakg#00001(16)
A1(137, 54) = A1(137, 54) - 2*v(110); % source1:GLUSy_01:xakg#00001(16)
A1(137, 137) = A1(137, 137) - v(266); % source1:PEPTIDOSYN_02:xgluL#00001(16)
A1(137, 137) = A1(137, 137) - 2*v(265); % source1:LPSSYN_01:xgluL#00001(16)
A1(137, 137) = A1(137, 137) - 2*v(256); % source1:IMPSYN2_02:xgluL#00001(16)
A1(137, 137) = A1(137, 137) - 2*v(255); % source1:IMPSYN1_01:xgluL#00001(16)
A1(137, 54) = A1(137, 54) - v(247); % source1:TYRTA_03:xakg#00001(16)
A1(137, 54) = A1(137, 54) - v(193); % source1:PHETA1_01:xakg#00001(16)
A1(137, 54) = A1(137, 54) - v(30); % source1:ACOTA_01:xakg#00001(16)
A1(137, 54) = A1(137, 54) - v(22); % source1:COMBO2_01:xakg#00001(16)
A1(137, 137) = A1(137, 137) - v(266); % source1:PEPTIDOSYN_01:xgluL#00001(16)
A1(137, 54) = A1(137, 54) - v(51); % source1:ASPTA_01:xakg#00001(16)
A1(137, 54) = A1(137, 54) - v(21); % source1:ABTA_01:xakg#00001(16)
A1(137, 54) = A1(137, 54) - v(193); % source1:PHETA1_03:xakg#00001(16)
A1(137, 137) = A1(137, 137) - 2*v(255); % source1:IMPSYN1_02:xgluL#00001(16)
A1(137, 137) = A1(137, 137) - v(109); % source1:GLUN_01:xgluL#00001(16)
A1(137, 54) = A1(137, 54) - v(136); % source1:ILETA_01:xakg#00001(16)
A1(137, 137) = A1(137, 137) - 2*v(110); % source1:GLUSy_02:xgluL#00001(16)
A1(137, 4) = A1(137, 4) - v(182); % source1:P5CD_01:x1pyr5c#00001(16)
A1(137, 54) = A1(137, 54) - v(215); % source1:SDPTA_01:xakg#00001(16)
A1(137, 137) = A1(137, 137) - v(48); % source1:ASNS1_01:xgluL#00001(16)
A1(137, 137) = A1(137, 137) - v(254); % source1:CTPSYN_01:xgluL#00001(16)
A1(137, 54) = A1(137, 54) - v(41); % source1:ALATAL_01:xakg#00001(16)
A1(137, 54) = A1(137, 54) - v(247); % source1:TYRTA_01:xakg#00001(16)
A1(137, 54) = A1(137, 54) - v(22); % source1:COMBO2_02:xakg#00001(16)
A1(137, 54) = A1(137, 54) - v(193); % source1:PHETA1_04:xakg#00001(16)
A1(137, 137) = A1(137, 137) - v(54); % source1:CBPS_01:xgluL#00001(16)
A1(137, 137) = A1(137, 137) - 2*v(256); % source1:IMPSYN2_01:xgluL#00001(16)
A1(137, 137) = A1(137, 137) - v(43); % source1:COMBO15_01:xgluL#00001(16)
A1(137, 54) = A1(137, 54) - v(193); % source1:PHETA1_02:xakg#00001(16)
%>>> xgluL#00010#
A1(138, 138) = v(333) + v(315) + v(274) + v(98) + v(24) + v(322) + v(147) + v(334) + v(333) + v(302) + v(187) + 0.25*v(1) + v(315) + v(315) + v(107) + v(249) + v(333) + v(279) + v(106) + v(283) + v(108) + v(333) + v(315); % drain :TYRTA_r_04:PHETA1_r_03:ACOTA_r_01:COMBO34_01:COMBO3_01:SDPTA_r_01:LEUTAi_01:VALTA_r_01:TYRTA_r_02:ILETA_r_01:COMBO47_01:BiomassEcoliGALUi_01:PHETA1_r_02:PHETA1_r_04:GLUDC_01:UNK3_01:TYRTA_r_01:ALATAL_r_01:GLNS_01:ASPTA_r_01:GLUDy_01:TYRTA_r_03:PHETA1_r_01 
A1(138, 138) = A1(138, 138) - v(124); % source1:GMPS2_01:xgluL#00010(8)
A1(138, 55) = A1(138, 55) - v(297); % source1:GLUDy_r_01:xakg#00010(8)
A1(138, 55) = A1(138, 55) - v(247); % source1:TYRTA_04:xakg#00010(8)
A1(138, 55) = A1(138, 55) - v(247); % source1:TYRTA_02:xakg#00010(8)
A1(138, 55) = A1(138, 55) - v(250); % source1:VALTA_01:xakg#00010(8)
A1(138, 55) = A1(138, 55) - 2*v(110); % source1:GLUSy_01:xakg#00010(8)
A1(138, 138) = A1(138, 138) - v(266); % source1:PEPTIDOSYN_02:xgluL#00010(8)
A1(138, 138) = A1(138, 138) - 2*v(265); % source1:LPSSYN_01:xgluL#00010(8)
A1(138, 138) = A1(138, 138) - 2*v(256); % source1:IMPSYN2_02:xgluL#00010(8)
A1(138, 141) = A1(138, 141) - 2*v(255); % source1:IMPSYN1_01:xgluL#10000(1)
A1(138, 55) = A1(138, 55) - v(247); % source1:TYRTA_03:xakg#00010(8)
A1(138, 55) = A1(138, 55) - v(193); % source1:PHETA1_01:xakg#00010(8)
A1(138, 55) = A1(138, 55) - v(30); % source1:ACOTA_01:xakg#00010(8)
A1(138, 55) = A1(138, 55) - v(22); % source1:COMBO2_01:xakg#00010(8)
A1(138, 138) = A1(138, 138) - v(266); % source1:PEPTIDOSYN_01:xgluL#00010(8)
A1(138, 55) = A1(138, 55) - v(51); % source1:ASPTA_01:xakg#00010(8)
A1(138, 55) = A1(138, 55) - v(21); % source1:ABTA_01:xakg#00010(8)
A1(138, 55) = A1(138, 55) - v(193); % source1:PHETA1_03:xakg#00010(8)
A1(138, 138) = A1(138, 138) - 2*v(255); % source1:IMPSYN1_02:xgluL#00010(8)
A1(138, 138) = A1(138, 138) - v(109); % source1:GLUN_01:xgluL#00010(8)
A1(138, 55) = A1(138, 55) - v(136); % source1:ILETA_01:xakg#00010(8)
A1(138, 138) = A1(138, 138) - 2*v(110); % source1:GLUSy_02:xgluL#00010(8)
A1(138, 5) = A1(138, 5) - v(182); % source1:P5CD_01:x1pyr5c#00010(8)
A1(138, 55) = A1(138, 55) - v(215); % source1:SDPTA_01:xakg#00010(8)
A1(138, 138) = A1(138, 138) - v(48); % source1:ASNS1_01:xgluL#00010(8)
A1(138, 138) = A1(138, 138) - v(254); % source1:CTPSYN_01:xgluL#00010(8)
A1(138, 55) = A1(138, 55) - v(41); % source1:ALATAL_01:xakg#00010(8)
A1(138, 55) = A1(138, 55) - v(247); % source1:TYRTA_01:xakg#00010(8)
A1(138, 55) = A1(138, 55) - v(22); % source1:COMBO2_02:xakg#00010(8)
A1(138, 55) = A1(138, 55) - v(193); % source1:PHETA1_04:xakg#00010(8)
A1(138, 138) = A1(138, 138) - v(54); % source1:CBPS_01:xgluL#00010(8)
A1(138, 138) = A1(138, 138) - 2*v(256); % source1:IMPSYN2_01:xgluL#00010(8)
A1(138, 138) = A1(138, 138) - v(43); % source1:COMBO15_01:xgluL#00010(8)
A1(138, 55) = A1(138, 55) - v(193); % source1:PHETA1_02:xakg#00010(8)
%>>> xgluL#00100#
A1(139, 139) = v(333) + v(315) + v(274) + v(98) + v(24) + v(322) + v(147) + v(334) + v(333) + v(302) + v(187) + 0.25*v(1) + v(315) + v(315) + v(107) + v(249) + v(333) + v(279) + v(106) + v(283) + v(108) + v(333) + v(315); % drain :TYRTA_r_04:PHETA1_r_03:ACOTA_r_01:COMBO34_01:COMBO3_01:SDPTA_r_01:LEUTAi_01:VALTA_r_01:TYRTA_r_02:ILETA_r_01:COMBO47_01:BiomassEcoliGALUi_01:PHETA1_r_02:PHETA1_r_04:GLUDC_01:UNK3_01:TYRTA_r_01:ALATAL_r_01:GLNS_01:ASPTA_r_01:GLUDy_01:TYRTA_r_03:PHETA1_r_01 
A1(139, 139) = A1(139, 139) - v(124); % source1:GMPS2_01:xgluL#00100(4)
A1(139, 56) = A1(139, 56) - v(297); % source1:GLUDy_r_01:xakg#00100(4)
A1(139, 56) = A1(139, 56) - v(247); % source1:TYRTA_04:xakg#00100(4)
A1(139, 56) = A1(139, 56) - v(247); % source1:TYRTA_02:xakg#00100(4)
A1(139, 56) = A1(139, 56) - v(250); % source1:VALTA_01:xakg#00100(4)
A1(139, 56) = A1(139, 56) - 2*v(110); % source1:GLUSy_01:xakg#00100(4)
A1(139, 139) = A1(139, 139) - v(266); % source1:PEPTIDOSYN_02:xgluL#00100(4)
A1(139, 139) = A1(139, 139) - 2*v(265); % source1:LPSSYN_01:xgluL#00100(4)
A1(139, 139) = A1(139, 139) - 2*v(256); % source1:IMPSYN2_02:xgluL#00100(4)
A1(139, 140) = A1(139, 140) - 2*v(255); % source1:IMPSYN1_01:xgluL#01000(2)
A1(139, 56) = A1(139, 56) - v(247); % source1:TYRTA_03:xakg#00100(4)
A1(139, 56) = A1(139, 56) - v(193); % source1:PHETA1_01:xakg#00100(4)
A1(139, 56) = A1(139, 56) - v(30); % source1:ACOTA_01:xakg#00100(4)
A1(139, 56) = A1(139, 56) - v(22); % source1:COMBO2_01:xakg#00100(4)
A1(139, 139) = A1(139, 139) - v(266); % source1:PEPTIDOSYN_01:xgluL#00100(4)
A1(139, 56) = A1(139, 56) - v(51); % source1:ASPTA_01:xakg#00100(4)
A1(139, 56) = A1(139, 56) - v(21); % source1:ABTA_01:xakg#00100(4)
A1(139, 56) = A1(139, 56) - v(193); % source1:PHETA1_03:xakg#00100(4)
A1(139, 139) = A1(139, 139) - 2*v(255); % source1:IMPSYN1_02:xgluL#00100(4)
A1(139, 139) = A1(139, 139) - v(109); % source1:GLUN_01:xgluL#00100(4)
A1(139, 56) = A1(139, 56) - v(136); % source1:ILETA_01:xakg#00100(4)
A1(139, 139) = A1(139, 139) - 2*v(110); % source1:GLUSy_02:xgluL#00100(4)
A1(139, 6) = A1(139, 6) - v(182); % source1:P5CD_01:x1pyr5c#00100(4)
A1(139, 56) = A1(139, 56) - v(215); % source1:SDPTA_01:xakg#00100(4)
A1(139, 139) = A1(139, 139) - v(48); % source1:ASNS1_01:xgluL#00100(4)
A1(139, 139) = A1(139, 139) - v(254); % source1:CTPSYN_01:xgluL#00100(4)
A1(139, 56) = A1(139, 56) - v(41); % source1:ALATAL_01:xakg#00100(4)
A1(139, 56) = A1(139, 56) - v(247); % source1:TYRTA_01:xakg#00100(4)
A1(139, 56) = A1(139, 56) - v(22); % source1:COMBO2_02:xakg#00100(4)
A1(139, 56) = A1(139, 56) - v(193); % source1:PHETA1_04:xakg#00100(4)
A1(139, 139) = A1(139, 139) - v(54); % source1:CBPS_01:xgluL#00100(4)
A1(139, 139) = A1(139, 139) - 2*v(256); % source1:IMPSYN2_01:xgluL#00100(4)
A1(139, 139) = A1(139, 139) - v(43); % source1:COMBO15_01:xgluL#00100(4)
A1(139, 56) = A1(139, 56) - v(193); % source1:PHETA1_02:xakg#00100(4)
%>>> xgluL#01000#
A1(140, 140) = v(333) + v(315) + v(274) + v(98) + v(24) + v(322) + v(147) + v(334) + v(333) + v(302) + v(187) + 0.25*v(1) + v(315) + v(315) + v(107) + v(249) + v(333) + v(279) + v(106) + v(283) + v(108) + v(333) + v(315); % drain :TYRTA_r_04:PHETA1_r_03:ACOTA_r_01:COMBO34_01:COMBO3_01:SDPTA_r_01:LEUTAi_01:VALTA_r_01:TYRTA_r_02:ILETA_r_01:COMBO47_01:BiomassEcoliGALUi_01:PHETA1_r_02:PHETA1_r_04:GLUDC_01:UNK3_01:TYRTA_r_01:ALATAL_r_01:GLNS_01:ASPTA_r_01:GLUDy_01:TYRTA_r_03:PHETA1_r_01 
A1(140, 140) = A1(140, 140) - v(124); % source1:GMPS2_01:xgluL#01000(2)
A1(140, 57) = A1(140, 57) - v(297); % source1:GLUDy_r_01:xakg#01000(2)
A1(140, 57) = A1(140, 57) - v(247); % source1:TYRTA_04:xakg#01000(2)
A1(140, 57) = A1(140, 57) - v(247); % source1:TYRTA_02:xakg#01000(2)
A1(140, 57) = A1(140, 57) - v(250); % source1:VALTA_01:xakg#01000(2)
A1(140, 57) = A1(140, 57) - 2*v(110); % source1:GLUSy_01:xakg#01000(2)
A1(140, 140) = A1(140, 140) - v(266); % source1:PEPTIDOSYN_02:xgluL#01000(2)
A1(140, 140) = A1(140, 140) - 2*v(265); % source1:LPSSYN_01:xgluL#01000(2)
A1(140, 140) = A1(140, 140) - 2*v(256); % source1:IMPSYN2_02:xgluL#01000(2)
A1(140, 139) = A1(140, 139) - 2*v(255); % source1:IMPSYN1_01:xgluL#00100(4)
A1(140, 57) = A1(140, 57) - v(247); % source1:TYRTA_03:xakg#01000(2)
A1(140, 57) = A1(140, 57) - v(193); % source1:PHETA1_01:xakg#01000(2)
A1(140, 57) = A1(140, 57) - v(30); % source1:ACOTA_01:xakg#01000(2)
A1(140, 57) = A1(140, 57) - v(22); % source1:COMBO2_01:xakg#01000(2)
A1(140, 140) = A1(140, 140) - v(266); % source1:PEPTIDOSYN_01:xgluL#01000(2)
A1(140, 57) = A1(140, 57) - v(51); % source1:ASPTA_01:xakg#01000(2)
A1(140, 57) = A1(140, 57) - v(21); % source1:ABTA_01:xakg#01000(2)
A1(140, 57) = A1(140, 57) - v(193); % source1:PHETA1_03:xakg#01000(2)
A1(140, 140) = A1(140, 140) - 2*v(255); % source1:IMPSYN1_02:xgluL#01000(2)
A1(140, 140) = A1(140, 140) - v(109); % source1:GLUN_01:xgluL#01000(2)
A1(140, 57) = A1(140, 57) - v(136); % source1:ILETA_01:xakg#01000(2)
A1(140, 140) = A1(140, 140) - 2*v(110); % source1:GLUSy_02:xgluL#01000(2)
A1(140, 7) = A1(140, 7) - v(182); % source1:P5CD_01:x1pyr5c#01000(2)
A1(140, 57) = A1(140, 57) - v(215); % source1:SDPTA_01:xakg#01000(2)
A1(140, 140) = A1(140, 140) - v(48); % source1:ASNS1_01:xgluL#01000(2)
A1(140, 140) = A1(140, 140) - v(254); % source1:CTPSYN_01:xgluL#01000(2)
A1(140, 57) = A1(140, 57) - v(41); % source1:ALATAL_01:xakg#01000(2)
A1(140, 57) = A1(140, 57) - v(247); % source1:TYRTA_01:xakg#01000(2)
A1(140, 57) = A1(140, 57) - v(22); % source1:COMBO2_02:xakg#01000(2)
A1(140, 57) = A1(140, 57) - v(193); % source1:PHETA1_04:xakg#01000(2)
A1(140, 140) = A1(140, 140) - v(54); % source1:CBPS_01:xgluL#01000(2)
A1(140, 140) = A1(140, 140) - 2*v(256); % source1:IMPSYN2_01:xgluL#01000(2)
A1(140, 140) = A1(140, 140) - v(43); % source1:COMBO15_01:xgluL#01000(2)
A1(140, 57) = A1(140, 57) - v(193); % source1:PHETA1_02:xakg#01000(2)
%>>> xgluL#10000#
A1(141, 141) = v(333) + v(315) + v(274) + v(98) + v(24) + v(322) + v(147) + v(334) + v(333) + v(302) + v(187) + 0.25*v(1) + v(315) + v(315) + v(107) + v(249) + v(333) + v(279) + v(106) + v(283) + v(108) + v(333) + v(315); % drain :TYRTA_r_04:PHETA1_r_03:ACOTA_r_01:COMBO34_01:COMBO3_01:SDPTA_r_01:LEUTAi_01:VALTA_r_01:TYRTA_r_02:ILETA_r_01:COMBO47_01:BiomassEcoliGALUi_01:PHETA1_r_02:PHETA1_r_04:GLUDC_01:UNK3_01:TYRTA_r_01:ALATAL_r_01:GLNS_01:ASPTA_r_01:GLUDy_01:TYRTA_r_03:PHETA1_r_01 
A1(141, 141) = A1(141, 141) - v(124); % source1:GMPS2_01:xgluL#10000(1)
A1(141, 58) = A1(141, 58) - v(297); % source1:GLUDy_r_01:xakg#10000(1)
A1(141, 58) = A1(141, 58) - v(247); % source1:TYRTA_04:xakg#10000(1)
A1(141, 58) = A1(141, 58) - v(247); % source1:TYRTA_02:xakg#10000(1)
A1(141, 58) = A1(141, 58) - v(250); % source1:VALTA_01:xakg#10000(1)
A1(141, 58) = A1(141, 58) - 2*v(110); % source1:GLUSy_01:xakg#10000(1)
A1(141, 141) = A1(141, 141) - v(266); % source1:PEPTIDOSYN_02:xgluL#10000(1)
A1(141, 141) = A1(141, 141) - 2*v(265); % source1:LPSSYN_01:xgluL#10000(1)
A1(141, 141) = A1(141, 141) - 2*v(256); % source1:IMPSYN2_02:xgluL#10000(1)
A1(141, 138) = A1(141, 138) - 2*v(255); % source1:IMPSYN1_01:xgluL#00010(8)
A1(141, 58) = A1(141, 58) - v(247); % source1:TYRTA_03:xakg#10000(1)
A1(141, 58) = A1(141, 58) - v(193); % source1:PHETA1_01:xakg#10000(1)
A1(141, 58) = A1(141, 58) - v(30); % source1:ACOTA_01:xakg#10000(1)
A1(141, 58) = A1(141, 58) - v(22); % source1:COMBO2_01:xakg#10000(1)
A1(141, 141) = A1(141, 141) - v(266); % source1:PEPTIDOSYN_01:xgluL#10000(1)
A1(141, 58) = A1(141, 58) - v(51); % source1:ASPTA_01:xakg#10000(1)
A1(141, 58) = A1(141, 58) - v(21); % source1:ABTA_01:xakg#10000(1)
A1(141, 58) = A1(141, 58) - v(193); % source1:PHETA1_03:xakg#10000(1)
A1(141, 141) = A1(141, 141) - 2*v(255); % source1:IMPSYN1_02:xgluL#10000(1)
A1(141, 141) = A1(141, 141) - v(109); % source1:GLUN_01:xgluL#10000(1)
A1(141, 58) = A1(141, 58) - v(136); % source1:ILETA_01:xakg#10000(1)
A1(141, 141) = A1(141, 141) - 2*v(110); % source1:GLUSy_02:xgluL#10000(1)
A1(141, 8) = A1(141, 8) - v(182); % source1:P5CD_01:x1pyr5c#10000(1)
A1(141, 58) = A1(141, 58) - v(215); % source1:SDPTA_01:xakg#10000(1)
A1(141, 141) = A1(141, 141) - v(48); % source1:ASNS1_01:xgluL#10000(1)
A1(141, 141) = A1(141, 141) - v(254); % source1:CTPSYN_01:xgluL#10000(1)
A1(141, 58) = A1(141, 58) - v(41); % source1:ALATAL_01:xakg#10000(1)
A1(141, 58) = A1(141, 58) - v(247); % source1:TYRTA_01:xakg#10000(1)
A1(141, 58) = A1(141, 58) - v(22); % source1:COMBO2_02:xakg#10000(1)
A1(141, 58) = A1(141, 58) - v(193); % source1:PHETA1_04:xakg#10000(1)
A1(141, 141) = A1(141, 141) - v(54); % source1:CBPS_01:xgluL#10000(1)
A1(141, 141) = A1(141, 141) - 2*v(256); % source1:IMPSYN2_01:xgluL#10000(1)
A1(141, 141) = A1(141, 141) - v(43); % source1:COMBO15_01:xgluL#10000(1)
A1(141, 58) = A1(141, 58) - v(193); % source1:PHETA1_02:xakg#10000(1)
%>>> xglx#01#
A1(142, 142) = v(148) + 2*v(111) + v(117) + v(116); % drain :MALS_01:GLXCL_01:GLYCLTDy_01:GLYCLTDx_01 
A1(142, 155) = A1(142, 155) - v(120); % source1:GLYCTO4_01:xglyclt#01(2)
A1(142, 155) = A1(142, 155) - v(118); % source1:GLYCTO2_01:xglyclt#01(2)
A1(142, 161) = A1(142, 161) - v(135); % source1:ICL_01:xicit#010000(2)
A1(142, 155) = A1(142, 155) - v(119); % source1:GLYCTO3_01:xglyclt#01(2)
A1(142, 161) = A1(142, 161) - v(135); % source1:ICL_02:xicit#010000(2)
%>>> xglx#10#
A1(143, 143) = v(148) + 2*v(111) + v(117) + v(116); % drain :MALS_01:GLXCL_01:GLYCLTDy_01:GLYCLTDx_01 
A1(143, 156) = A1(143, 156) - v(120); % source1:GLYCTO4_01:xglyclt#10(1)
A1(143, 156) = A1(143, 156) - v(118); % source1:GLYCTO2_01:xglyclt#10(1)
A1(143, 162) = A1(143, 162) - v(135); % source1:ICL_01:xicit#100000(1)
A1(143, 156) = A1(143, 156) - v(119); % source1:GLYCTO3_01:xglyclt#10(1)
A1(143, 162) = A1(143, 162) - v(135); % source1:ICL_02:xicit#100000(1)
%>>> xgly#01#
A1(144, 144) = v(256) + v(255) + 0.582*v(1) + v(328) + v(256) + v(115) + v(255) + v(335); % drain :IMPSYN2_02:IMPSYN1_01:BiomassEcoliGALUi_01:THRAr_r_01:IMPSYN2_01:GLYCL_01:IMPSYN1_02:GHMT2_r_01 
A1(144, 234) = A1(144, 234) - v(236); % source1:THRAr_01:xthrL#0100(2)
A1(144, 234) = A1(144, 234) - v(112); % source1:COMBO37_01:xthrL#0100(2)
A1(144, 211) = A1(144, 211) - v(101); % source1:GHMT2_01:xserL#010(2)
%>>> xgly#10#
A1(145, 145) = v(256) + v(255) + 0.582*v(1) + v(328) + v(256) + v(115) + v(255) + v(335); % drain :IMPSYN2_02:IMPSYN1_01:BiomassEcoliGALUi_01:THRAr_r_01:IMPSYN2_01:GLYCL_01:IMPSYN1_02:GHMT2_r_01 
A1(145, 235) = A1(145, 235) - v(236); % source1:THRAr_01:xthrL#1000(1)
A1(145, 235) = A1(145, 235) - v(112); % source1:COMBO37_01:xthrL#1000(1)
A1(145, 212) = A1(145, 212) - v(101); % source1:GHMT2_01:xserL#100(1)
%>>> xglyc#001#
A1(146, 146) = v(121) + v(113) + v(122) + v(122) + v(113) + v(121) + v(113) + v(113) + v(121) + v(121); % drain :GLYCt_02:GLYCDx_03:GLYK_01:GLYK_02:GLYCDx_01:GLYCt_01:GLYCDx_04:GLYCDx_02:GLYCt_04:GLYCt_03 
A1(146, 154) = A1(146, 154) - v(298); % source1:GLYCt_r_01:xglyce#100(1)
A1(146, 151) = A1(146, 151) - v(270); % source1:G3PP_01:xglyc3p#100(1)
A1(146, 152) = A1(146, 152) - v(298); % source1:GLYCt_r_02:xglyce#001(4)
A1(146, 154) = A1(146, 154) - v(298); % source1:GLYCt_r_04:xglyce#100(1)
A1(146, 149) = A1(146, 149) - v(270); % source1:G3PP_02:xglyc3p#001(4)
A1(146, 149) = A1(146, 149) - v(264); % source1:CLPNSYN_02:xglyc3p#001(4)
A1(146, 152) = A1(146, 152) - v(298); % source1:GLYCt_r_03:xglyce#001(4)
A1(146, 151) = A1(146, 151) - v(264); % source1:CLPNSYN_01:xglyc3p#100(1)
%>>> xglyc#010#
A1(147, 147) = v(121) + v(113) + v(122) + v(122) + v(113) + v(121) + v(113) + v(113) + v(121) + v(121); % drain :GLYCt_02:GLYCDx_03:GLYK_01:GLYK_02:GLYCDx_01:GLYCt_01:GLYCDx_04:GLYCDx_02:GLYCt_04:GLYCt_03 
A1(147, 153) = A1(147, 153) - v(298); % source1:GLYCt_r_01:xglyce#010(2)
A1(147, 150) = A1(147, 150) - v(270); % source1:G3PP_01:xglyc3p#010(2)
A1(147, 153) = A1(147, 153) - v(298); % source1:GLYCt_r_02:xglyce#010(2)
A1(147, 153) = A1(147, 153) - v(298); % source1:GLYCt_r_04:xglyce#010(2)
A1(147, 150) = A1(147, 150) - v(270); % source1:G3PP_02:xglyc3p#010(2)
A1(147, 150) = A1(147, 150) - v(264); % source1:CLPNSYN_02:xglyc3p#010(2)
A1(147, 153) = A1(147, 153) - v(298); % source1:GLYCt_r_03:xglyce#010(2)
A1(147, 150) = A1(147, 150) - v(264); % source1:CLPNSYN_01:xglyc3p#010(2)
%>>> xglyc#100#
A1(148, 148) = v(121) + v(113) + v(122) + v(122) + v(113) + v(121) + v(113) + v(113) + v(121) + v(121); % drain :GLYCt_02:GLYCDx_03:GLYK_01:GLYK_02:GLYCDx_01:GLYCt_01:GLYCDx_04:GLYCDx_02:GLYCt_04:GLYCt_03 
A1(148, 152) = A1(148, 152) - v(298); % source1:GLYCt_r_01:xglyce#001(4)
A1(148, 149) = A1(148, 149) - v(270); % source1:G3PP_01:xglyc3p#001(4)
A1(148, 154) = A1(148, 154) - v(298); % source1:GLYCt_r_02:xglyce#100(1)
A1(148, 152) = A1(148, 152) - v(298); % source1:GLYCt_r_04:xglyce#001(4)
A1(148, 151) = A1(148, 151) - v(270); % source1:G3PP_02:xglyc3p#100(1)
A1(148, 151) = A1(148, 151) - v(264); % source1:CLPNSYN_02:xglyc3p#100(1)
A1(148, 154) = A1(148, 154) - v(298); % source1:GLYCt_r_03:xglyce#100(1)
A1(148, 149) = A1(148, 149) - v(264); % source1:CLPNSYN_01:xglyc3p#001(4)
%>>> xglyc3p#001#
A1(149, 149) = v(96) + v(260) + v(94) + 2*v(264) + v(270) + v(93) + v(95) + v(263) + v(270) + 2*v(264); % drain :G3PD7_01:CDPDAGSYN_01:G3PD5_01:CLPNSYN_02:G3PP_01:G3PD2_01:G3PD6_01:PGSYN_01:G3PP_02:CLPNSYN_01 
A1(149, 84) = A1(149, 84) - v(294); % source1:G3PD2_r_01:xdhap#001(4)
A1(149, 148) = A1(149, 148) - v(122); % source1:GLYK_01:xglyc#100(1)
A1(149, 146) = A1(149, 146) - v(122); % source1:GLYK_02:xglyc#001(4)
%>>> xglyc3p#010#
A1(150, 150) = v(96) + v(260) + v(94) + 2*v(264) + v(270) + v(93) + v(95) + v(263) + v(270) + 2*v(264); % drain :G3PD7_01:CDPDAGSYN_01:G3PD5_01:CLPNSYN_02:G3PP_01:G3PD2_01:G3PD6_01:PGSYN_01:G3PP_02:CLPNSYN_01 
A1(150, 85) = A1(150, 85) - v(294); % source1:G3PD2_r_01:xdhap#010(2)
A1(150, 147) = A1(150, 147) - v(122); % source1:GLYK_01:xglyc#010(2)
A1(150, 147) = A1(150, 147) - v(122); % source1:GLYK_02:xglyc#010(2)
%>>> xglyc3p#100#
A1(151, 151) = v(96) + v(260) + v(94) + 2*v(264) + v(270) + v(93) + v(95) + v(263) + v(270) + 2*v(264); % drain :G3PD7_01:CDPDAGSYN_01:G3PD5_01:CLPNSYN_02:G3PP_01:G3PD2_01:G3PD6_01:PGSYN_01:G3PP_02:CLPNSYN_01 
A1(151, 86) = A1(151, 86) - v(294); % source1:G3PD2_r_01:xdhap#100(1)
A1(151, 146) = A1(151, 146) - v(122); % source1:GLYK_01:xglyc#001(4)
A1(151, 148) = A1(151, 148) - v(122); % source1:GLYK_02:xglyc#100(1)
%>>> xglyce#001#
A1(152, 152) = v(298) + v(8) + v(298) + v(8) + v(298) + v(298); % drain :GLYCt_r_01:EX_glyc_01:GLYCt_r_02:EX_glyc_02:GLYCt_r_04:GLYCt_r_03 
A1(152, 146) = A1(152, 146) - v(121); % source1:GLYCt_02:xglyc#001(4)
A1(152, 148) = A1(152, 148) - v(121); % source1:GLYCt_04:xglyc#100(1)
A1(152, 146) = A1(152, 146) - v(121); % source1:GLYCt_03:xglyc#001(4)
A1(152, 148) = A1(152, 148) - v(121); % source1:GLYCt_01:xglyc#100(1)
%>>> xglyce#010#
A1(153, 153) = v(298) + v(8) + v(298) + v(8) + v(298) + v(298); % drain :GLYCt_r_01:EX_glyc_01:GLYCt_r_02:EX_glyc_02:GLYCt_r_04:GLYCt_r_03 
A1(153, 147) = A1(153, 147) - v(121); % source1:GLYCt_02:xglyc#010(2)
A1(153, 147) = A1(153, 147) - v(121); % source1:GLYCt_04:xglyc#010(2)
A1(153, 147) = A1(153, 147) - v(121); % source1:GLYCt_03:xglyc#010(2)
A1(153, 147) = A1(153, 147) - v(121); % source1:GLYCt_01:xglyc#010(2)
%>>> xglyce#100#
A1(154, 154) = v(298) + v(8) + v(298) + v(8) + v(298) + v(298); % drain :GLYCt_r_01:EX_glyc_01:GLYCt_r_02:EX_glyc_02:GLYCt_r_04:GLYCt_r_03 
A1(154, 148) = A1(154, 148) - v(121); % source1:GLYCt_02:xglyc#100(1)
A1(154, 146) = A1(154, 146) - v(121); % source1:GLYCt_04:xglyc#001(4)
A1(154, 148) = A1(154, 148) - v(121); % source1:GLYCt_03:xglyc#100(1)
A1(154, 146) = A1(154, 146) - v(121); % source1:GLYCt_01:xglyc#001(4)
%>>> xglyclt#01#
A1(155, 155) = v(120) + v(118) + v(119); % drain :GLYCTO4_01:GLYCTO2_01:GLYCTO3_01 
A1(155, 193) = A1(155, 193) - v(269); % source1:THFSYN_01:xr5p#00001(16)
A1(155, 142) = A1(155, 142) - v(117); % source1:GLYCLTDy_01:xglx#01(2)
A1(155, 142) = A1(155, 142) - v(116); % source1:GLYCLTDx_01:xglx#01(2)
%>>> xglyclt#10#
A1(156, 156) = v(120) + v(118) + v(119); % drain :GLYCTO4_01:GLYCTO2_01:GLYCTO3_01 
A1(156, 194) = A1(156, 194) - v(269); % source1:THFSYN_01:xr5p#00010(8)
A1(156, 143) = A1(156, 143) - v(117); % source1:GLYCLTDy_01:xglx#10(1)
A1(156, 143) = A1(156, 143) - v(116); % source1:GLYCLTDx_01:xglx#10(1)
%>>> xicit#000001#
A1(157, 157) = v(273) + v(135) + v(134) + v(135); % drain :rACONT_r_01:ICL_01:ICDHyr_01:ICL_02 
A1(157, 80) = A1(157, 80) - v(301); % source1:ICDHyr_r_01:xco2#1(1)
A1(157, 74) = A1(157, 74) - v(29); % source1:rACONT_01:xcit#000001(32)
%>>> xicit#000010#
A1(158, 158) = v(273) + v(135) + v(134) + v(135); % drain :rACONT_r_01:ICL_01:ICDHyr_01:ICL_02 
A1(158, 54) = A1(158, 54) - v(301); % source1:ICDHyr_r_01:xakg#00001(16)
A1(158, 75) = A1(158, 75) - v(29); % source1:rACONT_01:xcit#000010(16)
%>>> xicit#000100#
A1(159, 159) = v(273) + v(135) + v(134) + v(135); % drain :rACONT_r_01:ICL_01:ICDHyr_01:ICL_02 
A1(159, 55) = A1(159, 55) - v(301); % source1:ICDHyr_r_01:xakg#00010(8)
A1(159, 76) = A1(159, 76) - v(29); % source1:rACONT_01:xcit#000100(8)
%>>> xicit#001000#
A1(160, 160) = v(273) + v(135) + v(134) + v(135); % drain :rACONT_r_01:ICL_01:ICDHyr_01:ICL_02 
A1(160, 56) = A1(160, 56) - v(301); % source1:ICDHyr_r_01:xakg#00100(4)
A1(160, 77) = A1(160, 77) - v(29); % source1:rACONT_01:xcit#001000(4)
%>>> xicit#010000#
A1(161, 161) = v(273) + v(135) + v(134) + v(135); % drain :rACONT_r_01:ICL_01:ICDHyr_01:ICL_02 
A1(161, 57) = A1(161, 57) - v(301); % source1:ICDHyr_r_01:xakg#01000(2)
A1(161, 78) = A1(161, 78) - v(29); % source1:rACONT_01:xcit#010000(2)
%>>> xicit#100000#
A1(162, 162) = v(273) + v(135) + v(134) + v(135); % drain :rACONT_r_01:ICL_01:ICDHyr_01:ICL_02 
A1(162, 58) = A1(162, 58) - v(301); % source1:ICDHyr_r_01:xakg#10000(1)
A1(162, 79) = A1(162, 79) - v(29); % source1:rACONT_01:xcit#100000(1)
%>>> xlacD#001#
A1(163, 163) = v(285) + v(146) + v(145); % drain :DLACt2_r_01:LDHD2_01:LDHD_01 
A1(163, 190) = A1(163, 190) - v(306); % source1:LDHD_r_01:xpyr#001(4)
A1(163, 86) = A1(163, 86) - v(123); % source1:COMBO38_01:xdhap#100(1)
A1(163, 163) = A1(163, 163) - v(65); % source1:DLACt2_01:xlacD#001(4)
%>>> xlacD#010#
A1(164, 164) = v(285) + v(146) + v(145); % drain :DLACt2_r_01:LDHD2_01:LDHD_01 
A1(164, 191) = A1(164, 191) - v(306); % source1:LDHD_r_01:xpyr#010(2)
A1(164, 85) = A1(164, 85) - v(123); % source1:COMBO38_01:xdhap#010(2)
A1(164, 164) = A1(164, 164) - v(65); % source1:DLACt2_01:xlacD#010(2)
%>>> xlacD#100#
A1(165, 165) = v(285) + v(146) + v(145); % drain :DLACt2_r_01:LDHD2_01:LDHD_01 
A1(165, 192) = A1(165, 192) - v(306); % source1:LDHD_r_01:xpyr#100(1)
A1(165, 84) = A1(165, 84) - v(123); % source1:COMBO38_01:xdhap#001(4)
A1(165, 165) = A1(165, 165) - v(65); % source1:DLACt2_01:xlacD#100(1)
%>>> xmalL#0001#
A1(166, 166) = v(293) + v(151) + v(149) + v(152) + v(293) + v(153) + v(150); % drain :rFUM_r_02:MDH3_01:MDH_01:ME1_01:rFUM_r_01:ME2_01:MDH2_01 
A1(166, 37) = A1(166, 37) - v(148); % source1:MALS_01:xaccoa#10(1)
A1(166, 174) = A1(166, 174) - v(307); % source1:MDH_r_01:xoaa#0001(8)
A1(166, 112) = A1(166, 112) - v(89); % source1:rFUM_01:xfum#1000(1)
A1(166, 109) = A1(166, 109) - v(89); % source1:rFUM_02:xfum#0001(8)
%>>> xmalL#0010#
A1(167, 167) = v(293) + v(151) + v(149) + v(152) + v(293) + v(153) + v(150); % drain :rFUM_r_02:MDH3_01:MDH_01:ME1_01:rFUM_r_01:ME2_01:MDH2_01 
A1(167, 36) = A1(167, 36) - v(148); % source1:MALS_01:xaccoa#01(2)
A1(167, 175) = A1(167, 175) - v(307); % source1:MDH_r_01:xoaa#0010(4)
A1(167, 111) = A1(167, 111) - v(89); % source1:rFUM_01:xfum#0100(2)
A1(167, 110) = A1(167, 110) - v(89); % source1:rFUM_02:xfum#0010(4)
%>>> xmalL#0100#
A1(168, 168) = v(293) + v(151) + v(149) + v(152) + v(293) + v(153) + v(150); % drain :rFUM_r_02:MDH3_01:MDH_01:ME1_01:rFUM_r_01:ME2_01:MDH2_01 
A1(168, 142) = A1(168, 142) - v(148); % source1:MALS_01:xglx#01(2)
A1(168, 176) = A1(168, 176) - v(307); % source1:MDH_r_01:xoaa#0100(2)
A1(168, 110) = A1(168, 110) - v(89); % source1:rFUM_01:xfum#0010(4)
A1(168, 111) = A1(168, 111) - v(89); % source1:rFUM_02:xfum#0100(2)
%>>> xmalL#1000#
A1(169, 169) = v(293) + v(151) + v(149) + v(152) + v(293) + v(153) + v(150); % drain :rFUM_r_02:MDH3_01:MDH_01:ME1_01:rFUM_r_01:ME2_01:MDH2_01 
A1(169, 143) = A1(169, 143) - v(148); % source1:MALS_01:xglx#10(1)
A1(169, 177) = A1(169, 177) - v(307); % source1:MDH_r_01:xoaa#1000(1)
A1(169, 109) = A1(169, 109) - v(89); % source1:rFUM_01:xfum#0001(8)
A1(169, 112) = A1(169, 112) - v(89); % source1:rFUM_02:xfum#1000(1)
%>>> xmetL#00001#
A1(170, 170) = v(36) + 0.146*v(1) + v(36); % drain :COMBOSPMD_02:BiomassEcoliGALUi_01:COMBOSPMD_01 
A1(170, 173) = A1(170, 173) - v(61); % source1:COMBO22_02:xmlthf#1(1)
A1(170, 173) = A1(170, 173) - v(61); % source1:COMBO22_01:xmlthf#1(1)
A1(170, 14) = A1(170, 14) - v(249); % source1:UNK3_01:x2kmb#00001(16)
%>>> xmetL#10000#
A1(171, 171) = v(36) + 0.146*v(1) + v(36); % drain :COMBOSPMD_02:BiomassEcoliGALUi_01:COMBOSPMD_01 
A1(171, 73) = A1(171, 73) - v(61); % source1:COMBO22_02:xaspsa#1000(1)
A1(171, 73) = A1(171, 73) - v(61); % source1:COMBO22_01:xaspsa#1000(1)
A1(171, 15) = A1(171, 15) - v(249); % source1:UNK3_01:x2kmb#10000(1)
%>>> xmethf#1#
A1(172, 172) = v(309) + v(154); % drain :MTHFD_r_01:MTHFC_01 
A1(172, 173) = A1(172, 173) - v(155); % source1:MTHFD_01:xmlthf#1(1)
A1(172, 172) = A1(172, 172) - v(308); % source1:MTHFC_r_01:xmethf#1(1)
%>>> xmlthf#1#
A1(173, 173) = v(155) + v(257) + v(156) + v(335) + v(258) + v(258); % drain :MTHFD_01:dTTPSYN_01:MTHFR2_01:GHMT2_r_01:COASYN_02:COASYN_01 
A1(173, 172) = A1(173, 172) - v(309); % source1:MTHFD_r_01:xmethf#1(1)
A1(173, 210) = A1(173, 210) - v(101); % source1:GHMT2_01:xserL#001(4)
A1(173, 144) = A1(173, 144) - v(115); % source1:GLYCL_01:xgly#01(2)
%>>> xoaa#0001#
A1(174, 174) = v(307) + v(283) + v(58) + v(199); % drain :MDH_r_01:ASPTA_r_01:CS_01:PPCK_01 
A1(174, 80) = A1(174, 80) - v(198); % source1:PPC_01:xco2#1(1)
A1(174, 166) = A1(174, 166) - v(151); % source1:MDH3_01:xmalL#0001(8)
A1(174, 166) = A1(174, 166) - v(149); % source1:MDH_01:xmalL#0001(8)
A1(174, 66) = A1(174, 66) - v(51); % source1:ASPTA_01:xaspL#0001(8)
A1(174, 166) = A1(174, 166) - v(150); % source1:MDH2_01:xmalL#0001(8)
%>>> xoaa#0010#
A1(175, 175) = v(307) + v(283) + v(58) + v(199); % drain :MDH_r_01:ASPTA_r_01:CS_01:PPCK_01 
A1(175, 183) = A1(175, 183) - v(198); % source1:PPC_01:xpep#001(4)
A1(175, 167) = A1(175, 167) - v(151); % source1:MDH3_01:xmalL#0010(4)
A1(175, 167) = A1(175, 167) - v(149); % source1:MDH_01:xmalL#0010(4)
A1(175, 67) = A1(175, 67) - v(51); % source1:ASPTA_01:xaspL#0010(4)
A1(175, 167) = A1(175, 167) - v(150); % source1:MDH2_01:xmalL#0010(4)
%>>> xoaa#0100#
A1(176, 176) = v(307) + v(283) + v(58) + v(199); % drain :MDH_r_01:ASPTA_r_01:CS_01:PPCK_01 
A1(176, 184) = A1(176, 184) - v(198); % source1:PPC_01:xpep#010(2)
A1(176, 168) = A1(176, 168) - v(151); % source1:MDH3_01:xmalL#0100(2)
A1(176, 168) = A1(176, 168) - v(149); % source1:MDH_01:xmalL#0100(2)
A1(176, 68) = A1(176, 68) - v(51); % source1:ASPTA_01:xaspL#0100(2)
A1(176, 168) = A1(176, 168) - v(150); % source1:MDH2_01:xmalL#0100(2)
%>>> xoaa#1000#
A1(177, 177) = v(307) + v(283) + v(58) + v(199); % drain :MDH_r_01:ASPTA_r_01:CS_01:PPCK_01 
A1(177, 185) = A1(177, 185) - v(198); % source1:PPC_01:xpep#100(1)
A1(177, 169) = A1(177, 169) - v(151); % source1:MDH3_01:xmalL#1000(1)
A1(177, 169) = A1(177, 169) - v(149); % source1:MDH_01:xmalL#1000(1)
A1(177, 69) = A1(177, 69) - v(51); % source1:ASPTA_01:xaspL#1000(1)
A1(177, 169) = A1(177, 169) - v(150); % source1:MDH2_01:xmalL#1000(1)
%>>> xorn#00001#
A1(178, 178) = v(181) + v(179) + v(181); % drain :ORNDC_01:OCBT_01:ORNDC_02 
A1(178, 178) = A1(178, 178) - v(310); % source1:OCBT_r_01:xorn#00001(16)
A1(178, 47) = A1(178, 47) - v(28); % source1:ACODA_01:xacg5sa#0000100(16)
%>>> xorn#00010#
A1(179, 179) = v(181) + v(179) + v(181); % drain :ORNDC_01:OCBT_01:ORNDC_02 
A1(179, 179) = A1(179, 179) - v(310); % source1:OCBT_r_01:xorn#00010(8)
A1(179, 48) = A1(179, 48) - v(28); % source1:ACODA_01:xacg5sa#0001000(8)
%>>> xorn#00100#
A1(180, 180) = v(181) + v(179) + v(181); % drain :ORNDC_01:OCBT_01:ORNDC_02 
A1(180, 180) = A1(180, 180) - v(310); % source1:OCBT_r_01:xorn#00100(4)
A1(180, 49) = A1(180, 49) - v(28); % source1:ACODA_01:xacg5sa#0010000(4)
%>>> xorn#01000#
A1(181, 181) = v(181) + v(179) + v(181); % drain :ORNDC_01:OCBT_01:ORNDC_02 
A1(181, 181) = A1(181, 181) - v(310); % source1:OCBT_r_01:xorn#01000(2)
A1(181, 50) = A1(181, 50) - v(28); % source1:ACODA_01:xacg5sa#0100000(2)
%>>> xorn#10000#
A1(182, 182) = v(181) + v(179) + v(181); % drain :ORNDC_01:OCBT_01:ORNDC_02 
A1(182, 182) = A1(182, 182) - v(310); % source1:OCBT_r_01:xorn#10000(1)
A1(182, 51) = A1(182, 51) - v(28); % source1:ACODA_01:xacg5sa#1000000(1)
%>>> xpep#001#
A1(183, 183) = v(288) + v(198) + v(205) + v(207) + v(70) + v(266) + v(68) + v(266) + v(105) + 5*v(265) + v(70); % drain :ENO_r_01:PPC_01:PSCVT_01:PYK_01:DHAPT_02:PEPTIDOSYN_01:COMBO25_01:PEPTIDOSYN_02:GLCpts_01:LPSSYN_01:DHAPT_01 
A1(183, 183) = A1(183, 183) - v(317); % source1:PSCVT_r_01:xpep#001(4)
A1(183, 16) = A1(183, 16) - v(77); % source1:ENO_01:x2pg#001(4)
A1(183, 190) = A1(183, 190) - v(202); % source1:PPS_01:xpyr#001(4)
A1(183, 175) = A1(183, 175) - v(199); % source1:PPCK_01:xoaa#0010(4)
%>>> xpep#010#
A1(184, 184) = v(288) + v(198) + v(205) + v(207) + v(70) + v(266) + v(68) + v(266) + v(105) + 5*v(265) + v(70); % drain :ENO_r_01:PPC_01:PSCVT_01:PYK_01:DHAPT_02:PEPTIDOSYN_01:COMBO25_01:PEPTIDOSYN_02:GLCpts_01:LPSSYN_01:DHAPT_01 
A1(184, 184) = A1(184, 184) - v(317); % source1:PSCVT_r_01:xpep#010(2)
A1(184, 17) = A1(184, 17) - v(77); % source1:ENO_01:x2pg#010(2)
A1(184, 191) = A1(184, 191) - v(202); % source1:PPS_01:xpyr#010(2)
A1(184, 176) = A1(184, 176) - v(199); % source1:PPCK_01:xoaa#0100(2)
%>>> xpep#100#
A1(185, 185) = v(288) + v(198) + v(205) + v(207) + v(70) + v(266) + v(68) + v(266) + v(105) + 5*v(265) + v(70); % drain :ENO_r_01:PPC_01:PSCVT_01:PYK_01:DHAPT_02:PEPTIDOSYN_01:COMBO25_01:PEPTIDOSYN_02:GLCpts_01:LPSSYN_01:DHAPT_01 
A1(185, 185) = A1(185, 185) - v(317); % source1:PSCVT_r_01:xpep#100(1)
A1(185, 18) = A1(185, 18) - v(77); % source1:ENO_01:x2pg#100(1)
A1(185, 192) = A1(185, 192) - v(202); % source1:PPS_01:xpyr#100(1)
A1(185, 177) = A1(185, 177) - v(199); % source1:PPCK_01:xoaa#1000(1)
%>>> xptrc#0001#
A1(186, 186) = v(22) + v(36) + 0.035*v(1) + v(36) + v(22); % drain :COMBO2_01:COMBOSPMD_02:BiomassEcoliGALUi_01:COMBOSPMD_01:COMBO2_02 
A1(186, 181) = A1(186, 181) - v(181); % source1:ORNDC_01:xorn#01000(2)
A1(186, 178) = A1(186, 178) - v(181); % source1:ORNDC_02:xorn#00001(16)
%>>> xptrc#0010#
A1(187, 187) = v(22) + v(36) + 0.035*v(1) + v(36) + v(22); % drain :COMBO2_01:COMBOSPMD_02:BiomassEcoliGALUi_01:COMBOSPMD_01:COMBO2_02 
A1(187, 180) = A1(187, 180) - v(181); % source1:ORNDC_01:xorn#00100(4)
A1(187, 179) = A1(187, 179) - v(181); % source1:ORNDC_02:xorn#00010(8)
%>>> xptrc#0100#
A1(188, 188) = v(22) + v(36) + 0.035*v(1) + v(36) + v(22); % drain :COMBO2_01:COMBOSPMD_02:BiomassEcoliGALUi_01:COMBOSPMD_01:COMBO2_02 
A1(188, 179) = A1(188, 179) - v(181); % source1:ORNDC_01:xorn#00010(8)
A1(188, 180) = A1(188, 180) - v(181); % source1:ORNDC_02:xorn#00100(4)
%>>> xptrc#1000#
A1(189, 189) = v(22) + v(36) + 0.035*v(1) + v(36) + v(22); % drain :COMBO2_01:COMBOSPMD_02:BiomassEcoliGALUi_01:COMBOSPMD_01:COMBO2_02 
A1(189, 178) = A1(189, 178) - v(181); % source1:ORNDC_01:xorn#00001(16)
A1(189, 181) = A1(189, 181) - v(181); % source1:ORNDC_02:xorn#01000(2)
%>>> xpyr#001#
A1(190, 190) = v(306) + v(184) + v(25) + 2*v(27) + v(202) + v(196) + v(71) + v(279) + v(332) + v(319) + v(186); % drain :LDHD_r_01:PDH_01:COMBO4_01:COMBO5_01:PPS_01:POX_01:COMBO26_01:ALATAL_r_01:TRPAS2_r_01:PYRt2r_r_01:PFL_01 
A1(190, 183) = A1(190, 183) - v(269); % source1:THFSYN_01:xpep#001(4)
A1(190, 59) = A1(190, 59) - v(41); % source1:ALATAL_01:xalaL#001(4)
A1(190, 183) = A1(190, 183) - v(105); % source1:GLCpts_01:xpep#001(4)
A1(190, 190) = A1(190, 190) - v(208); % source1:PYRt2r_01:xpyr#001(4)
A1(190, 129) = A1(190, 129) - v(75); % source1:EDA_01:xg6p#001000(4)
A1(190, 163) = A1(190, 163) - v(145); % source1:LDHD_01:xlacD#001(4)
A1(190, 167) = A1(190, 167) - v(153); % source1:ME2_01:xmalL#0010(4)
A1(190, 183) = A1(190, 183) - v(207); % source1:PYK_01:xpep#001(4)
A1(190, 183) = A1(190, 183) - v(43); % source1:COMBO15_01:xpep#001(4)
A1(190, 183) = A1(190, 183) - v(70); % source1:DHAPT_02:xpep#001(4)
A1(190, 236) = A1(190, 236) - v(242); % source1:TRPAS2_01:xtrpL#00100000000(4)
A1(190, 210) = A1(190, 210) - v(61); % source1:COMBO22_02:xserL#001(4)
A1(190, 210) = A1(190, 210) - v(217); % source1:SERDL_01:xserL#001(4)
A1(190, 210) = A1(190, 210) - v(59); % source1:CYSDS_01:xserL#001(4)
A1(190, 167) = A1(190, 167) - v(152); % source1:ME1_01:xmalL#0010(4)
A1(190, 210) = A1(190, 210) - v(61); % source1:COMBO22_01:xserL#001(4)
A1(190, 163) = A1(190, 163) - v(146); % source1:LDHD2_01:xlacD#001(4)
A1(190, 183) = A1(190, 183) - v(70); % source1:DHAPT_01:xpep#001(4)
%>>> xpyr#010#
A1(191, 191) = v(306) + v(184) + v(25) + 2*v(27) + v(202) + v(196) + v(71) + v(279) + v(332) + v(319) + v(186); % drain :LDHD_r_01:PDH_01:COMBO4_01:COMBO5_01:PPS_01:POX_01:COMBO26_01:ALATAL_r_01:TRPAS2_r_01:PYRt2r_r_01:PFL_01 
A1(191, 184) = A1(191, 184) - v(269); % source1:THFSYN_01:xpep#010(2)
A1(191, 60) = A1(191, 60) - v(41); % source1:ALATAL_01:xalaL#010(2)
A1(191, 184) = A1(191, 184) - v(105); % source1:GLCpts_01:xpep#010(2)
A1(191, 191) = A1(191, 191) - v(208); % source1:PYRt2r_01:xpyr#010(2)
A1(191, 130) = A1(191, 130) - v(75); % source1:EDA_01:xg6p#010000(2)
A1(191, 164) = A1(191, 164) - v(145); % source1:LDHD_01:xlacD#010(2)
A1(191, 168) = A1(191, 168) - v(153); % source1:ME2_01:xmalL#0100(2)
A1(191, 184) = A1(191, 184) - v(207); % source1:PYK_01:xpep#010(2)
A1(191, 184) = A1(191, 184) - v(43); % source1:COMBO15_01:xpep#010(2)
A1(191, 184) = A1(191, 184) - v(70); % source1:DHAPT_02:xpep#010(2)
A1(191, 237) = A1(191, 237) - v(242); % source1:TRPAS2_01:xtrpL#01000000000(2)
A1(191, 211) = A1(191, 211) - v(61); % source1:COMBO22_02:xserL#010(2)
A1(191, 211) = A1(191, 211) - v(217); % source1:SERDL_01:xserL#010(2)
A1(191, 211) = A1(191, 211) - v(59); % source1:CYSDS_01:xserL#010(2)
A1(191, 168) = A1(191, 168) - v(152); % source1:ME1_01:xmalL#0100(2)
A1(191, 211) = A1(191, 211) - v(61); % source1:COMBO22_01:xserL#010(2)
A1(191, 164) = A1(191, 164) - v(146); % source1:LDHD2_01:xlacD#010(2)
A1(191, 184) = A1(191, 184) - v(70); % source1:DHAPT_01:xpep#010(2)
%>>> xpyr#100#
A1(192, 192) = v(306) + v(184) + v(25) + 2*v(27) + v(202) + v(196) + v(71) + v(279) + v(332) + v(319) + v(186); % drain :LDHD_r_01:PDH_01:COMBO4_01:COMBO5_01:PPS_01:POX_01:COMBO26_01:ALATAL_r_01:TRPAS2_r_01:PYRt2r_r_01:PFL_01 
A1(192, 185) = A1(192, 185) - v(269); % source1:THFSYN_01:xpep#100(1)
A1(192, 61) = A1(192, 61) - v(41); % source1:ALATAL_01:xalaL#100(1)
A1(192, 185) = A1(192, 185) - v(105); % source1:GLCpts_01:xpep#100(1)
A1(192, 192) = A1(192, 192) - v(208); % source1:PYRt2r_01:xpyr#100(1)
A1(192, 131) = A1(192, 131) - v(75); % source1:EDA_01:xg6p#100000(1)
A1(192, 165) = A1(192, 165) - v(145); % source1:LDHD_01:xlacD#100(1)
A1(192, 169) = A1(192, 169) - v(153); % source1:ME2_01:xmalL#1000(1)
A1(192, 185) = A1(192, 185) - v(207); % source1:PYK_01:xpep#100(1)
A1(192, 185) = A1(192, 185) - v(43); % source1:COMBO15_01:xpep#100(1)
A1(192, 185) = A1(192, 185) - v(70); % source1:DHAPT_02:xpep#100(1)
A1(192, 238) = A1(192, 238) - v(242); % source1:TRPAS2_01:xtrpL#10000000000(1)
A1(192, 212) = A1(192, 212) - v(61); % source1:COMBO22_02:xserL#100(1)
A1(192, 212) = A1(192, 212) - v(217); % source1:SERDL_01:xserL#100(1)
A1(192, 212) = A1(192, 212) - v(59); % source1:CYSDS_01:xserL#100(1)
A1(192, 169) = A1(192, 169) - v(152); % source1:ME1_01:xmalL#1000(1)
A1(192, 212) = A1(192, 212) - v(61); % source1:COMBO22_01:xserL#100(1)
A1(192, 165) = A1(192, 165) - v(146); % source1:LDHD2_01:xlacD#100(1)
A1(192, 185) = A1(192, 185) - v(70); % source1:DHAPT_01:xpep#100(1)
%>>> xr5p#00001#
A1(193, 193) = v(213) + v(204) + v(238); % drain :RPI_01:PRPPS_01:TKT1_01 
A1(193, 198) = A1(193, 198) - v(321); % source1:RPI_r_01:xru5pD#00001(16)
A1(193, 203) = A1(193, 203) - v(329); % source1:TKT1_r_01:xs7p#0000001(64)
A1(193, 193) = A1(193, 193) - v(316); % source1:PRPPS_r_01:xr5p#00001(16)
%>>> xr5p#00010#
A1(194, 194) = v(213) + v(204) + v(238); % drain :RPI_01:PRPPS_01:TKT1_01 
A1(194, 199) = A1(194, 199) - v(321); % source1:RPI_r_01:xru5pD#00010(8)
A1(194, 204) = A1(194, 204) - v(329); % source1:TKT1_r_01:xs7p#0000010(32)
A1(194, 194) = A1(194, 194) - v(316); % source1:PRPPS_r_01:xr5p#00010(8)
%>>> xr5p#00100#
A1(195, 195) = v(213) + v(204) + v(238); % drain :RPI_01:PRPPS_01:TKT1_01 
A1(195, 200) = A1(195, 200) - v(321); % source1:RPI_r_01:xru5pD#00100(4)
A1(195, 205) = A1(195, 205) - v(329); % source1:TKT1_r_01:xs7p#0000100(16)
A1(195, 195) = A1(195, 195) - v(316); % source1:PRPPS_r_01:xr5p#00100(4)
%>>> xr5p#01000#
A1(196, 196) = v(213) + v(204) + v(238); % drain :RPI_01:PRPPS_01:TKT1_01 
A1(196, 201) = A1(196, 201) - v(321); % source1:RPI_r_01:xru5pD#01000(2)
A1(196, 206) = A1(196, 206) - v(329); % source1:TKT1_r_01:xs7p#0001000(8)
A1(196, 196) = A1(196, 196) - v(316); % source1:PRPPS_r_01:xr5p#01000(2)
%>>> xr5p#10000#
A1(197, 197) = v(213) + v(204) + v(238); % drain :RPI_01:PRPPS_01:TKT1_01 
A1(197, 202) = A1(197, 202) - v(321); % source1:RPI_r_01:xru5pD#10000(1)
A1(197, 207) = A1(197, 207) - v(329); % source1:TKT1_r_01:xs7p#0010000(4)
A1(197, 197) = A1(197, 197) - v(316); % source1:PRPPS_r_01:xr5p#10000(1)
%>>> xru5pD#00001#
A1(198, 198) = v(321) + v(212) + 2*v(259) + 2*v(259) + 5*v(265) + 2*v(259); % drain :RPI_r_01:RPE_01:FADSYN_02:FADSYN_01:LPSSYN_01:FADSYN_03 
A1(198, 193) = A1(198, 193) - v(213); % source1:RPI_01:xr5p#00001(16)
A1(198, 126) = A1(198, 126) - v(125); % source1:GND_01:xg6p#000001(32)
A1(198, 239) = A1(198, 239) - v(320); % source1:RPE_r_01:xxu5pD#00001(16)
%>>> xru5pD#00010#
A1(199, 199) = v(321) + v(212) + 2*v(259) + 2*v(259) + 5*v(265) + 2*v(259); % drain :RPI_r_01:RPE_01:FADSYN_02:FADSYN_01:LPSSYN_01:FADSYN_03 
A1(199, 194) = A1(199, 194) - v(213); % source1:RPI_01:xr5p#00010(8)
A1(199, 127) = A1(199, 127) - v(125); % source1:GND_01:xg6p#000010(16)
A1(199, 240) = A1(199, 240) - v(320); % source1:RPE_r_01:xxu5pD#00010(8)
%>>> xru5pD#00100#
A1(200, 200) = v(321) + v(212) + 2*v(259) + 2*v(259) + 5*v(265) + 2*v(259); % drain :RPI_r_01:RPE_01:FADSYN_02:FADSYN_01:LPSSYN_01:FADSYN_03 
A1(200, 195) = A1(200, 195) - v(213); % source1:RPI_01:xr5p#00100(4)
A1(200, 128) = A1(200, 128) - v(125); % source1:GND_01:xg6p#000100(8)
A1(200, 241) = A1(200, 241) - v(320); % source1:RPE_r_01:xxu5pD#00100(4)
%>>> xru5pD#01000#
A1(201, 201) = v(321) + v(212) + 2*v(259) + 2*v(259) + 5*v(265) + 2*v(259); % drain :RPI_r_01:RPE_01:FADSYN_02:FADSYN_01:LPSSYN_01:FADSYN_03 
A1(201, 196) = A1(201, 196) - v(213); % source1:RPI_01:xr5p#01000(2)
A1(201, 129) = A1(201, 129) - v(125); % source1:GND_01:xg6p#001000(4)
A1(201, 242) = A1(201, 242) - v(320); % source1:RPE_r_01:xxu5pD#01000(2)
%>>> xru5pD#10000#
A1(202, 202) = v(321) + v(212) + 2*v(259) + 2*v(259) + 5*v(265) + 2*v(259); % drain :RPI_r_01:RPE_01:FADSYN_02:FADSYN_01:LPSSYN_01:FADSYN_03 
A1(202, 197) = A1(202, 197) - v(213); % source1:RPI_01:xr5p#10000(1)
A1(202, 130) = A1(202, 130) - v(125); % source1:GND_01:xg6p#010000(2)
A1(202, 243) = A1(202, 243) - v(320); % source1:RPE_r_01:xxu5pD#10000(1)
%>>> xs7p#0000001#
A1(203, 203) = v(329) + 3*v(265) + v(232); % drain :TKT1_r_01:LPSSYN_01:TALA_01 
A1(203, 90) = A1(203, 90) - v(327); % source1:TALA_r_01:xe4p#0001(8)
A1(203, 193) = A1(203, 193) - v(238); % source1:TKT1_01:xr5p#00001(16)
%>>> xs7p#0000010#
A1(204, 204) = v(329) + 3*v(265) + v(232); % drain :TKT1_r_01:LPSSYN_01:TALA_01 
A1(204, 91) = A1(204, 91) - v(327); % source1:TALA_r_01:xe4p#0010(4)
A1(204, 194) = A1(204, 194) - v(238); % source1:TKT1_01:xr5p#00010(8)
%>>> xs7p#0000100#
A1(205, 205) = v(329) + 3*v(265) + v(232); % drain :TKT1_r_01:LPSSYN_01:TALA_01 
A1(205, 92) = A1(205, 92) - v(327); % source1:TALA_r_01:xe4p#0100(2)
A1(205, 195) = A1(205, 195) - v(238); % source1:TKT1_01:xr5p#00100(4)
%>>> xs7p#0001000#
A1(206, 206) = v(329) + 3*v(265) + v(232); % drain :TKT1_r_01:LPSSYN_01:TALA_01 
A1(206, 93) = A1(206, 93) - v(327); % source1:TALA_r_01:xe4p#1000(1)
A1(206, 196) = A1(206, 196) - v(238); % source1:TKT1_01:xr5p#01000(2)
%>>> xs7p#0010000#
A1(207, 207) = v(329) + 3*v(265) + v(232); % drain :TKT1_r_01:LPSSYN_01:TALA_01 
A1(207, 99) = A1(207, 99) - v(327); % source1:TALA_r_01:xf6p#001000(4)
A1(207, 197) = A1(207, 197) - v(238); % source1:TKT1_01:xr5p#10000(1)
%>>> xs7p#0100000#
A1(208, 208) = v(329) + 3*v(265) + v(232); % drain :TKT1_r_01:LPSSYN_01:TALA_01 
A1(208, 100) = A1(208, 100) - v(327); % source1:TALA_r_01:xf6p#010000(2)
A1(208, 242) = A1(208, 242) - v(238); % source1:TKT1_01:xxu5pD#01000(2)
%>>> xs7p#1000000#
A1(209, 209) = v(329) + 3*v(265) + v(232); % drain :TKT1_r_01:LPSSYN_01:TALA_01 
A1(209, 101) = A1(209, 101) - v(327); % source1:TALA_r_01:xf6p#100000(1)
A1(209, 243) = A1(209, 243) - v(238); % source1:TKT1_01:xxu5pD#10000(1)
%>>> xserL#001#
A1(210, 210) = v(217) + v(261) + v(216) + 0.205*v(1) + v(244) + v(101) + v(262) + v(243); % drain :SERDL_01:PSSYN_01:SERAT_01:BiomassEcoliGALUi_01:TRPS2_01:GHMT2_01:PESYN_01:TRPS1_01 
A1(210, 210) = A1(210, 210) - v(323); % source1:SERAT_r_01:xserL#001(4)
A1(210, 173) = A1(210, 173) - v(335); % source1:GHMT2_r_01:xmlthf#1(1)
A1(210, 23) = A1(210, 23) - v(187); % source1:COMBO47_01:x3pg#001(4)
%>>> xserL#010#
A1(211, 211) = v(217) + v(261) + v(216) + 0.205*v(1) + v(244) + v(101) + v(262) + v(243); % drain :SERDL_01:PSSYN_01:SERAT_01:BiomassEcoliGALUi_01:TRPS2_01:GHMT2_01:PESYN_01:TRPS1_01 
A1(211, 211) = A1(211, 211) - v(323); % source1:SERAT_r_01:xserL#010(2)
A1(211, 144) = A1(211, 144) - v(335); % source1:GHMT2_r_01:xgly#01(2)
A1(211, 24) = A1(211, 24) - v(187); % source1:COMBO47_01:x3pg#010(2)
%>>> xserL#100#
A1(212, 212) = v(217) + v(261) + v(216) + 0.205*v(1) + v(244) + v(101) + v(262) + v(243); % drain :SERDL_01:PSSYN_01:SERAT_01:BiomassEcoliGALUi_01:TRPS2_01:GHMT2_01:PESYN_01:TRPS1_01 
A1(212, 212) = A1(212, 212) - v(323); % source1:SERAT_r_01:xserL#100(1)
A1(212, 145) = A1(212, 145) - v(335); % source1:GHMT2_r_01:xgly#10(1)
A1(212, 25) = A1(212, 25) - v(187); % source1:COMBO47_01:x3pg#100(1)
%>>> xskm5p#1000000#
A1(213, 213) = v(205); % drain :PSCVT_01 
A1(213, 213) = A1(213, 213) - v(317); % source1:PSCVT_r_01:xskm5p#1000000(1)
A1(213, 21) = A1(213, 21) - v(219); % source1:SHKK_01:x3dhsk#1000000(1)
%>>> xsl2a6o#00000000001#
A1(214, 214) = v(322); % drain :SDPTA_r_01 
A1(214, 214) = A1(214, 214) - v(215); % source1:SDPTA_01:xsl2a6o#00000000001(1024)
A1(214, 228) = A1(214, 228) - v(71); % source1:COMBO26_01:xsuccoa#0001(8)
%>>> xsl2a6o#00000000010#
A1(215, 215) = v(322); % drain :SDPTA_r_01 
A1(215, 215) = A1(215, 215) - v(215); % source1:SDPTA_01:xsl2a6o#00000000010(512)
A1(215, 229) = A1(215, 229) - v(71); % source1:COMBO26_01:xsuccoa#0010(4)
%>>> xsl2a6o#00000000100#
A1(216, 216) = v(322); % drain :SDPTA_r_01 
A1(216, 216) = A1(216, 216) - v(215); % source1:SDPTA_01:xsl2a6o#00000000100(256)
A1(216, 230) = A1(216, 230) - v(71); % source1:COMBO26_01:xsuccoa#0100(2)
%>>> xsl2a6o#00000001000#
A1(217, 217) = v(322); % drain :SDPTA_r_01 
A1(217, 217) = A1(217, 217) - v(215); % source1:SDPTA_01:xsl2a6o#00000001000(128)
A1(217, 231) = A1(217, 231) - v(71); % source1:COMBO26_01:xsuccoa#1000(1)
%>>> xsl2a6o#00000010000#
A1(218, 218) = v(322); % drain :SDPTA_r_01 
A1(218, 218) = A1(218, 218) - v(215); % source1:SDPTA_01:xsl2a6o#00000010000(64)
A1(218, 192) = A1(218, 192) - v(71); % source1:COMBO26_01:xpyr#100(1)
%>>> xsl2a6o#10000000000#
A1(219, 219) = v(322); % drain :SDPTA_r_01 
A1(219, 219) = A1(219, 219) - v(215); % source1:SDPTA_01:xsl2a6o#10000000000(1)
A1(219, 73) = A1(219, 73) - v(71); % source1:COMBO26_01:xaspsa#1000(1)
%>>> xsucc#0001#
A1(220, 220) = v(229) + v(226) + v(228) + v(228) + v(225) + v(228) + v(225) + v(228) + v(228) + v(228) + v(228) + v(228) + v(228) + v(226) + v(228) + v(225) + v(228) + v(226) + v(228) + v(228) + v(228) + v(228) + v(228) + v(226) + v(225) + v(229); % drain :SUCOAS_02:SUCD1i_04:SUCFUMt_15:SUCFUMt_08:SUCCt2b_04:SUCFUMt_12:SUCCt2b_02:SUCFUMt_10:SUCFUMt_02:SUCFUMt_13:SUCFUMt_09:SUCFUMt_01:SUCFUMt_06:SUCD1i_03:SUCFUMt_03:SUCCt2b_03:SUCFUMt_14:SUCD1i_01:SUCFUMt_07:SUCFUMt_11:SUCFUMt_05:SUCFUMt_16:SUCFUMt_04:SUCD1i_02:SUCCt2b_01:SUCOAS_01 
A1(220, 227) = A1(220, 227) - v(325); % source1:SUCFUMt_r_11:xsucce#1000(1)
A1(220, 224) = A1(220, 224) - v(325); % source1:SUCFUMt_r_07:xsucce#0001(8)
A1(220, 109) = A1(220, 109) - v(87); % source1:FRD3_01:xfum#0001(8)
A1(220, 231) = A1(220, 231) - v(326); % source1:SUCOAS_r_01:xsuccoa#1000(1)
A1(220, 227) = A1(220, 227) - v(325); % source1:SUCFUMt_r_06:xsucce#1000(1)
A1(220, 109) = A1(220, 109) - v(87); % source1:FRD3_04:xfum#0001(8)
A1(220, 224) = A1(220, 224) - v(223); % source1:SUCCt22_03:xsucce#0001(8)
A1(220, 227) = A1(220, 227) - v(325); % source1:SUCFUMt_r_05:xsucce#1000(1)
A1(220, 217) = A1(220, 217) - v(214); % source1:SDPDS_02:xsl2a6o#00000001000(128)
A1(220, 224) = A1(220, 224) - v(325); % source1:SUCFUMt_r_16:xsucce#0001(8)
A1(220, 227) = A1(220, 227) - v(223); % source1:SUCCt22_04:xsucce#1000(1)
A1(220, 224) = A1(220, 224) - v(325); % source1:SUCFUMt_r_08:xsucce#0001(8)
A1(220, 26) = A1(220, 26) - v(221); % source1:SSALy_02:x4abut#0001(8)
A1(220, 214) = A1(220, 214) - v(214); % source1:SDPDS_03:xsl2a6o#00000000001(1024)
A1(220, 227) = A1(220, 227) - v(224); % source1:SUCCt23_04:xsucce#1000(1)
A1(220, 224) = A1(220, 224) - v(325); % source1:SUCFUMt_r_09:xsucce#0001(8)
A1(220, 224) = A1(220, 224) - v(224); % source1:SUCCt23_03:xsucce#0001(8)
A1(220, 224) = A1(220, 224) - v(222); % source1:SUCCabc_03:xsucce#0001(8)
A1(220, 227) = A1(220, 227) - v(325); % source1:SUCFUMt_r_14:xsucce#1000(1)
A1(220, 228) = A1(220, 228) - v(61); % source1:COMBO22_02:xsuccoa#0001(8)
A1(220, 224) = A1(220, 224) - v(224); % source1:SUCCt23_02:xsucce#0001(8)
A1(220, 26) = A1(220, 26) - v(220); % source1:SSALx_02:x4abut#0001(8)
A1(220, 227) = A1(220, 227) - v(325); % source1:SUCFUMt_r_04:xsucce#1000(1)
A1(220, 158) = A1(220, 158) - v(135); % source1:ICL_02:xicit#000010(16)
A1(220, 227) = A1(220, 227) - v(222); % source1:SUCCabc_04:xsucce#1000(1)
A1(220, 112) = A1(220, 112) - v(86); % source1:FRD2_03:xfum#1000(1)
A1(220, 29) = A1(220, 29) - v(221); % source1:SSALy_01:x4abut#1000(1)
A1(220, 227) = A1(220, 227) - v(223); % source1:SUCCt22_01:xsucce#1000(1)
A1(220, 224) = A1(220, 224) - v(222); % source1:SUCCabc_02:xsucce#0001(8)
A1(220, 227) = A1(220, 227) - v(224); % source1:SUCCt23_01:xsucce#1000(1)
A1(220, 224) = A1(220, 224) - v(325); % source1:SUCFUMt_r_01:xsucce#0001(8)
A1(220, 214) = A1(220, 214) - v(214); % source1:SDPDS_01:xsl2a6o#00000000001(1024)
A1(220, 227) = A1(220, 227) - v(325); % source1:SUCFUMt_r_13:xsucce#1000(1)
A1(220, 112) = A1(220, 112) - v(87); % source1:FRD3_03:xfum#1000(1)
A1(220, 29) = A1(220, 29) - v(220); % source1:SSALx_01:x4abut#1000(1)
A1(220, 224) = A1(220, 224) - v(325); % source1:SUCFUMt_r_15:xsucce#0001(8)
A1(220, 224) = A1(220, 224) - v(325); % source1:SUCFUMt_r_02:xsucce#0001(8)
A1(220, 227) = A1(220, 227) - v(222); % source1:SUCCabc_01:xsucce#1000(1)
A1(220, 227) = A1(220, 227) - v(325); % source1:SUCFUMt_r_03:xsucce#1000(1)
A1(220, 157) = A1(220, 157) - v(135); % source1:ICL_01:xicit#000001(32)
A1(220, 227) = A1(220, 227) - v(325); % source1:SUCFUMt_r_12:xsucce#1000(1)
A1(220, 217) = A1(220, 217) - v(214); % source1:SDPDS_04:xsl2a6o#00000001000(128)
A1(220, 109) = A1(220, 109) - v(86); % source1:FRD2_04:xfum#0001(8)
A1(220, 112) = A1(220, 112) - v(87); % source1:FRD3_02:xfum#1000(1)
A1(220, 228) = A1(220, 228) - v(326); % source1:SUCOAS_r_02:xsuccoa#0001(8)
A1(220, 109) = A1(220, 109) - v(86); % source1:FRD2_01:xfum#0001(8)
A1(220, 231) = A1(220, 231) - v(61); % source1:COMBO22_01:xsuccoa#1000(1)
A1(220, 224) = A1(220, 224) - v(223); % source1:SUCCt22_02:xsucce#0001(8)
A1(220, 112) = A1(220, 112) - v(86); % source1:FRD2_02:xfum#1000(1)
A1(220, 224) = A1(220, 224) - v(325); % source1:SUCFUMt_r_10:xsucce#0001(8)
%>>> xsucc#0010#
A1(221, 221) = v(229) + v(226) + v(228) + v(228) + v(225) + v(228) + v(225) + v(228) + v(228) + v(228) + v(228) + v(228) + v(228) + v(226) + v(228) + v(225) + v(228) + v(226) + v(228) + v(228) + v(228) + v(228) + v(228) + v(226) + v(225) + v(229); % drain :SUCOAS_02:SUCD1i_04:SUCFUMt_15:SUCFUMt_08:SUCCt2b_04:SUCFUMt_12:SUCCt2b_02:SUCFUMt_10:SUCFUMt_02:SUCFUMt_13:SUCFUMt_09:SUCFUMt_01:SUCFUMt_06:SUCD1i_03:SUCFUMt_03:SUCCt2b_03:SUCFUMt_14:SUCD1i_01:SUCFUMt_07:SUCFUMt_11:SUCFUMt_05:SUCFUMt_16:SUCFUMt_04:SUCD1i_02:SUCCt2b_01:SUCOAS_01 
A1(221, 226) = A1(221, 226) - v(325); % source1:SUCFUMt_r_11:xsucce#0100(2)
A1(221, 225) = A1(221, 225) - v(325); % source1:SUCFUMt_r_07:xsucce#0010(4)
A1(221, 110) = A1(221, 110) - v(87); % source1:FRD3_01:xfum#0010(4)
A1(221, 230) = A1(221, 230) - v(326); % source1:SUCOAS_r_01:xsuccoa#0100(2)
A1(221, 226) = A1(221, 226) - v(325); % source1:SUCFUMt_r_06:xsucce#0100(2)
A1(221, 110) = A1(221, 110) - v(87); % source1:FRD3_04:xfum#0010(4)
A1(221, 225) = A1(221, 225) - v(223); % source1:SUCCt22_03:xsucce#0010(4)
A1(221, 226) = A1(221, 226) - v(325); % source1:SUCFUMt_r_05:xsucce#0100(2)
A1(221, 216) = A1(221, 216) - v(214); % source1:SDPDS_02:xsl2a6o#00000000100(256)
A1(221, 225) = A1(221, 225) - v(325); % source1:SUCFUMt_r_16:xsucce#0010(4)
A1(221, 226) = A1(221, 226) - v(223); % source1:SUCCt22_04:xsucce#0100(2)
A1(221, 225) = A1(221, 225) - v(325); % source1:SUCFUMt_r_08:xsucce#0010(4)
A1(221, 27) = A1(221, 27) - v(221); % source1:SSALy_02:x4abut#0010(4)
A1(221, 215) = A1(221, 215) - v(214); % source1:SDPDS_03:xsl2a6o#00000000010(512)
A1(221, 226) = A1(221, 226) - v(224); % source1:SUCCt23_04:xsucce#0100(2)
A1(221, 225) = A1(221, 225) - v(325); % source1:SUCFUMt_r_09:xsucce#0010(4)
A1(221, 225) = A1(221, 225) - v(224); % source1:SUCCt23_03:xsucce#0010(4)
A1(221, 225) = A1(221, 225) - v(222); % source1:SUCCabc_03:xsucce#0010(4)
A1(221, 226) = A1(221, 226) - v(325); % source1:SUCFUMt_r_14:xsucce#0100(2)
A1(221, 229) = A1(221, 229) - v(61); % source1:COMBO22_02:xsuccoa#0010(4)
A1(221, 225) = A1(221, 225) - v(224); % source1:SUCCt23_02:xsucce#0010(4)
A1(221, 27) = A1(221, 27) - v(220); % source1:SSALx_02:x4abut#0010(4)
A1(221, 226) = A1(221, 226) - v(325); % source1:SUCFUMt_r_04:xsucce#0100(2)
A1(221, 159) = A1(221, 159) - v(135); % source1:ICL_02:xicit#000100(8)
A1(221, 226) = A1(221, 226) - v(222); % source1:SUCCabc_04:xsucce#0100(2)
A1(221, 111) = A1(221, 111) - v(86); % source1:FRD2_03:xfum#0100(2)
A1(221, 28) = A1(221, 28) - v(221); % source1:SSALy_01:x4abut#0100(2)
A1(221, 226) = A1(221, 226) - v(223); % source1:SUCCt22_01:xsucce#0100(2)
A1(221, 225) = A1(221, 225) - v(222); % source1:SUCCabc_02:xsucce#0010(4)
A1(221, 226) = A1(221, 226) - v(224); % source1:SUCCt23_01:xsucce#0100(2)
A1(221, 225) = A1(221, 225) - v(325); % source1:SUCFUMt_r_01:xsucce#0010(4)
A1(221, 215) = A1(221, 215) - v(214); % source1:SDPDS_01:xsl2a6o#00000000010(512)
A1(221, 226) = A1(221, 226) - v(325); % source1:SUCFUMt_r_13:xsucce#0100(2)
A1(221, 111) = A1(221, 111) - v(87); % source1:FRD3_03:xfum#0100(2)
A1(221, 28) = A1(221, 28) - v(220); % source1:SSALx_01:x4abut#0100(2)
A1(221, 225) = A1(221, 225) - v(325); % source1:SUCFUMt_r_15:xsucce#0010(4)
A1(221, 225) = A1(221, 225) - v(325); % source1:SUCFUMt_r_02:xsucce#0010(4)
A1(221, 226) = A1(221, 226) - v(222); % source1:SUCCabc_01:xsucce#0100(2)
A1(221, 226) = A1(221, 226) - v(325); % source1:SUCFUMt_r_03:xsucce#0100(2)
A1(221, 160) = A1(221, 160) - v(135); % source1:ICL_01:xicit#001000(4)
A1(221, 226) = A1(221, 226) - v(325); % source1:SUCFUMt_r_12:xsucce#0100(2)
A1(221, 216) = A1(221, 216) - v(214); % source1:SDPDS_04:xsl2a6o#00000000100(256)
A1(221, 110) = A1(221, 110) - v(86); % source1:FRD2_04:xfum#0010(4)
A1(221, 111) = A1(221, 111) - v(87); % source1:FRD3_02:xfum#0100(2)
A1(221, 229) = A1(221, 229) - v(326); % source1:SUCOAS_r_02:xsuccoa#0010(4)
A1(221, 110) = A1(221, 110) - v(86); % source1:FRD2_01:xfum#0010(4)
A1(221, 230) = A1(221, 230) - v(61); % source1:COMBO22_01:xsuccoa#0100(2)
A1(221, 225) = A1(221, 225) - v(223); % source1:SUCCt22_02:xsucce#0010(4)
A1(221, 111) = A1(221, 111) - v(86); % source1:FRD2_02:xfum#0100(2)
A1(221, 225) = A1(221, 225) - v(325); % source1:SUCFUMt_r_10:xsucce#0010(4)
%>>> xsucc#0100#
A1(222, 222) = v(229) + v(226) + v(228) + v(228) + v(225) + v(228) + v(225) + v(228) + v(228) + v(228) + v(228) + v(228) + v(228) + v(226) + v(228) + v(225) + v(228) + v(226) + v(228) + v(228) + v(228) + v(228) + v(228) + v(226) + v(225) + v(229); % drain :SUCOAS_02:SUCD1i_04:SUCFUMt_15:SUCFUMt_08:SUCCt2b_04:SUCFUMt_12:SUCCt2b_02:SUCFUMt_10:SUCFUMt_02:SUCFUMt_13:SUCFUMt_09:SUCFUMt_01:SUCFUMt_06:SUCD1i_03:SUCFUMt_03:SUCCt2b_03:SUCFUMt_14:SUCD1i_01:SUCFUMt_07:SUCFUMt_11:SUCFUMt_05:SUCFUMt_16:SUCFUMt_04:SUCD1i_02:SUCCt2b_01:SUCOAS_01 
A1(222, 225) = A1(222, 225) - v(325); % source1:SUCFUMt_r_11:xsucce#0010(4)
A1(222, 226) = A1(222, 226) - v(325); % source1:SUCFUMt_r_07:xsucce#0100(2)
A1(222, 111) = A1(222, 111) - v(87); % source1:FRD3_01:xfum#0100(2)
A1(222, 229) = A1(222, 229) - v(326); % source1:SUCOAS_r_01:xsuccoa#0010(4)
A1(222, 225) = A1(222, 225) - v(325); % source1:SUCFUMt_r_06:xsucce#0010(4)
A1(222, 111) = A1(222, 111) - v(87); % source1:FRD3_04:xfum#0100(2)
A1(222, 226) = A1(222, 226) - v(223); % source1:SUCCt22_03:xsucce#0100(2)
A1(222, 225) = A1(222, 225) - v(325); % source1:SUCFUMt_r_05:xsucce#0010(4)
A1(222, 215) = A1(222, 215) - v(214); % source1:SDPDS_02:xsl2a6o#00000000010(512)
A1(222, 226) = A1(222, 226) - v(325); % source1:SUCFUMt_r_16:xsucce#0100(2)
A1(222, 225) = A1(222, 225) - v(223); % source1:SUCCt22_04:xsucce#0010(4)
A1(222, 226) = A1(222, 226) - v(325); % source1:SUCFUMt_r_08:xsucce#0100(2)
A1(222, 28) = A1(222, 28) - v(221); % source1:SSALy_02:x4abut#0100(2)
A1(222, 216) = A1(222, 216) - v(214); % source1:SDPDS_03:xsl2a6o#00000000100(256)
A1(222, 225) = A1(222, 225) - v(224); % source1:SUCCt23_04:xsucce#0010(4)
A1(222, 226) = A1(222, 226) - v(325); % source1:SUCFUMt_r_09:xsucce#0100(2)
A1(222, 226) = A1(222, 226) - v(224); % source1:SUCCt23_03:xsucce#0100(2)
A1(222, 226) = A1(222, 226) - v(222); % source1:SUCCabc_03:xsucce#0100(2)
A1(222, 225) = A1(222, 225) - v(325); % source1:SUCFUMt_r_14:xsucce#0010(4)
A1(222, 230) = A1(222, 230) - v(61); % source1:COMBO22_02:xsuccoa#0100(2)
A1(222, 226) = A1(222, 226) - v(224); % source1:SUCCt23_02:xsucce#0100(2)
A1(222, 28) = A1(222, 28) - v(220); % source1:SSALx_02:x4abut#0100(2)
A1(222, 225) = A1(222, 225) - v(325); % source1:SUCFUMt_r_04:xsucce#0010(4)
A1(222, 160) = A1(222, 160) - v(135); % source1:ICL_02:xicit#001000(4)
A1(222, 225) = A1(222, 225) - v(222); % source1:SUCCabc_04:xsucce#0010(4)
A1(222, 110) = A1(222, 110) - v(86); % source1:FRD2_03:xfum#0010(4)
A1(222, 27) = A1(222, 27) - v(221); % source1:SSALy_01:x4abut#0010(4)
A1(222, 225) = A1(222, 225) - v(223); % source1:SUCCt22_01:xsucce#0010(4)
A1(222, 226) = A1(222, 226) - v(222); % source1:SUCCabc_02:xsucce#0100(2)
A1(222, 225) = A1(222, 225) - v(224); % source1:SUCCt23_01:xsucce#0010(4)
A1(222, 226) = A1(222, 226) - v(325); % source1:SUCFUMt_r_01:xsucce#0100(2)
A1(222, 216) = A1(222, 216) - v(214); % source1:SDPDS_01:xsl2a6o#00000000100(256)
A1(222, 225) = A1(222, 225) - v(325); % source1:SUCFUMt_r_13:xsucce#0010(4)
A1(222, 110) = A1(222, 110) - v(87); % source1:FRD3_03:xfum#0010(4)
A1(222, 27) = A1(222, 27) - v(220); % source1:SSALx_01:x4abut#0010(4)
A1(222, 226) = A1(222, 226) - v(325); % source1:SUCFUMt_r_15:xsucce#0100(2)
A1(222, 226) = A1(222, 226) - v(325); % source1:SUCFUMt_r_02:xsucce#0100(2)
A1(222, 225) = A1(222, 225) - v(222); % source1:SUCCabc_01:xsucce#0010(4)
A1(222, 225) = A1(222, 225) - v(325); % source1:SUCFUMt_r_03:xsucce#0010(4)
A1(222, 159) = A1(222, 159) - v(135); % source1:ICL_01:xicit#000100(8)
A1(222, 225) = A1(222, 225) - v(325); % source1:SUCFUMt_r_12:xsucce#0010(4)
A1(222, 215) = A1(222, 215) - v(214); % source1:SDPDS_04:xsl2a6o#00000000010(512)
A1(222, 111) = A1(222, 111) - v(86); % source1:FRD2_04:xfum#0100(2)
A1(222, 110) = A1(222, 110) - v(87); % source1:FRD3_02:xfum#0010(4)
A1(222, 230) = A1(222, 230) - v(326); % source1:SUCOAS_r_02:xsuccoa#0100(2)
A1(222, 111) = A1(222, 111) - v(86); % source1:FRD2_01:xfum#0100(2)
A1(222, 229) = A1(222, 229) - v(61); % source1:COMBO22_01:xsuccoa#0010(4)
A1(222, 226) = A1(222, 226) - v(223); % source1:SUCCt22_02:xsucce#0100(2)
A1(222, 110) = A1(222, 110) - v(86); % source1:FRD2_02:xfum#0010(4)
A1(222, 226) = A1(222, 226) - v(325); % source1:SUCFUMt_r_10:xsucce#0100(2)
%>>> xsucc#1000#
A1(223, 223) = v(229) + v(226) + v(228) + v(228) + v(225) + v(228) + v(225) + v(228) + v(228) + v(228) + v(228) + v(228) + v(228) + v(226) + v(228) + v(225) + v(228) + v(226) + v(228) + v(228) + v(228) + v(228) + v(228) + v(226) + v(225) + v(229); % drain :SUCOAS_02:SUCD1i_04:SUCFUMt_15:SUCFUMt_08:SUCCt2b_04:SUCFUMt_12:SUCCt2b_02:SUCFUMt_10:SUCFUMt_02:SUCFUMt_13:SUCFUMt_09:SUCFUMt_01:SUCFUMt_06:SUCD1i_03:SUCFUMt_03:SUCCt2b_03:SUCFUMt_14:SUCD1i_01:SUCFUMt_07:SUCFUMt_11:SUCFUMt_05:SUCFUMt_16:SUCFUMt_04:SUCD1i_02:SUCCt2b_01:SUCOAS_01 
A1(223, 224) = A1(223, 224) - v(325); % source1:SUCFUMt_r_11:xsucce#0001(8)
A1(223, 227) = A1(223, 227) - v(325); % source1:SUCFUMt_r_07:xsucce#1000(1)
A1(223, 112) = A1(223, 112) - v(87); % source1:FRD3_01:xfum#1000(1)
A1(223, 228) = A1(223, 228) - v(326); % source1:SUCOAS_r_01:xsuccoa#0001(8)
A1(223, 224) = A1(223, 224) - v(325); % source1:SUCFUMt_r_06:xsucce#0001(8)
A1(223, 112) = A1(223, 112) - v(87); % source1:FRD3_04:xfum#1000(1)
A1(223, 227) = A1(223, 227) - v(223); % source1:SUCCt22_03:xsucce#1000(1)
A1(223, 224) = A1(223, 224) - v(325); % source1:SUCFUMt_r_05:xsucce#0001(8)
A1(223, 214) = A1(223, 214) - v(214); % source1:SDPDS_02:xsl2a6o#00000000001(1024)
A1(223, 227) = A1(223, 227) - v(325); % source1:SUCFUMt_r_16:xsucce#1000(1)
A1(223, 224) = A1(223, 224) - v(223); % source1:SUCCt22_04:xsucce#0001(8)
A1(223, 227) = A1(223, 227) - v(325); % source1:SUCFUMt_r_08:xsucce#1000(1)
A1(223, 29) = A1(223, 29) - v(221); % source1:SSALy_02:x4abut#1000(1)
A1(223, 217) = A1(223, 217) - v(214); % source1:SDPDS_03:xsl2a6o#00000001000(128)
A1(223, 224) = A1(223, 224) - v(224); % source1:SUCCt23_04:xsucce#0001(8)
A1(223, 227) = A1(223, 227) - v(325); % source1:SUCFUMt_r_09:xsucce#1000(1)
A1(223, 227) = A1(223, 227) - v(224); % source1:SUCCt23_03:xsucce#1000(1)
A1(223, 227) = A1(223, 227) - v(222); % source1:SUCCabc_03:xsucce#1000(1)
A1(223, 224) = A1(223, 224) - v(325); % source1:SUCFUMt_r_14:xsucce#0001(8)
A1(223, 231) = A1(223, 231) - v(61); % source1:COMBO22_02:xsuccoa#1000(1)
A1(223, 227) = A1(223, 227) - v(224); % source1:SUCCt23_02:xsucce#1000(1)
A1(223, 29) = A1(223, 29) - v(220); % source1:SSALx_02:x4abut#1000(1)
A1(223, 224) = A1(223, 224) - v(325); % source1:SUCFUMt_r_04:xsucce#0001(8)
A1(223, 157) = A1(223, 157) - v(135); % source1:ICL_02:xicit#000001(32)
A1(223, 224) = A1(223, 224) - v(222); % source1:SUCCabc_04:xsucce#0001(8)
A1(223, 109) = A1(223, 109) - v(86); % source1:FRD2_03:xfum#0001(8)
A1(223, 26) = A1(223, 26) - v(221); % source1:SSALy_01:x4abut#0001(8)
A1(223, 224) = A1(223, 224) - v(223); % source1:SUCCt22_01:xsucce#0001(8)
A1(223, 227) = A1(223, 227) - v(222); % source1:SUCCabc_02:xsucce#1000(1)
A1(223, 224) = A1(223, 224) - v(224); % source1:SUCCt23_01:xsucce#0001(8)
A1(223, 227) = A1(223, 227) - v(325); % source1:SUCFUMt_r_01:xsucce#1000(1)
A1(223, 217) = A1(223, 217) - v(214); % source1:SDPDS_01:xsl2a6o#00000001000(128)
A1(223, 224) = A1(223, 224) - v(325); % source1:SUCFUMt_r_13:xsucce#0001(8)
A1(223, 109) = A1(223, 109) - v(87); % source1:FRD3_03:xfum#0001(8)
A1(223, 26) = A1(223, 26) - v(220); % source1:SSALx_01:x4abut#0001(8)
A1(223, 227) = A1(223, 227) - v(325); % source1:SUCFUMt_r_15:xsucce#1000(1)
A1(223, 227) = A1(223, 227) - v(325); % source1:SUCFUMt_r_02:xsucce#1000(1)
A1(223, 224) = A1(223, 224) - v(222); % source1:SUCCabc_01:xsucce#0001(8)
A1(223, 224) = A1(223, 224) - v(325); % source1:SUCFUMt_r_03:xsucce#0001(8)
A1(223, 158) = A1(223, 158) - v(135); % source1:ICL_01:xicit#000010(16)
A1(223, 224) = A1(223, 224) - v(325); % source1:SUCFUMt_r_12:xsucce#0001(8)
A1(223, 214) = A1(223, 214) - v(214); % source1:SDPDS_04:xsl2a6o#00000000001(1024)
A1(223, 112) = A1(223, 112) - v(86); % source1:FRD2_04:xfum#1000(1)
A1(223, 109) = A1(223, 109) - v(87); % source1:FRD3_02:xfum#0001(8)
A1(223, 231) = A1(223, 231) - v(326); % source1:SUCOAS_r_02:xsuccoa#1000(1)
A1(223, 112) = A1(223, 112) - v(86); % source1:FRD2_01:xfum#1000(1)
A1(223, 228) = A1(223, 228) - v(61); % source1:COMBO22_01:xsuccoa#0001(8)
A1(223, 227) = A1(223, 227) - v(223); % source1:SUCCt22_02:xsucce#1000(1)
A1(223, 109) = A1(223, 109) - v(86); % source1:FRD2_02:xfum#0001(8)
A1(223, 227) = A1(223, 227) - v(325); % source1:SUCFUMt_r_10:xsucce#1000(1)
%>>> xsucce#0001#
A1(224, 224) = v(325) + v(222) + v(325) + v(325) + v(223) + v(222) + v(224) + v(20) + v(223) + v(325) + v(325) + v(325) + v(325) + v(223) + v(325) + v(325) + v(325) + v(222) + v(224) + v(325) + v(325) + v(224) + v(325) + v(222) + v(325) + v(224) + v(223) + v(325) + v(325) + v(20); % drain :SUCFUMt_r_11:SUCCabc_04:SUCFUMt_r_07:SUCFUMt_r_06:SUCCt22_01:SUCCabc_02:SUCCt23_01:EX_succ_02:SUCCt22_03:SUCFUMt_r_05:SUCFUMt_r_01:SUCFUMt_r_16:SUCFUMt_r_13:SUCCt22_04:SUCFUMt_r_15:SUCFUMt_r_02:SUCFUMt_r_08:SUCCabc_01:SUCCt23_04:SUCFUMt_r_03:SUCFUMt_r_09:SUCCt23_03:SUCFUMt_r_12:SUCCabc_03:SUCFUMt_r_14:SUCCt23_02:SUCCt22_02:SUCFUMt_r_10:SUCFUMt_r_04:EX_succ_01 
A1(224, 220) = A1(224, 220) - v(228); % source1:SUCFUMt_15:xsucc#0001(8)
A1(224, 220) = A1(224, 220) - v(228); % source1:SUCFUMt_08:xsucc#0001(8)
A1(224, 223) = A1(224, 223) - v(225); % source1:SUCCt2b_04:xsucc#1000(1)
A1(224, 223) = A1(224, 223) - v(228); % source1:SUCFUMt_12:xsucc#1000(1)
A1(224, 220) = A1(224, 220) - v(225); % source1:SUCCt2b_02:xsucc#0001(8)
A1(224, 220) = A1(224, 220) - v(228); % source1:SUCFUMt_10:xsucc#0001(8)
A1(224, 220) = A1(224, 220) - v(228); % source1:SUCFUMt_02:xsucc#0001(8)
A1(224, 223) = A1(224, 223) - v(228); % source1:SUCFUMt_13:xsucc#1000(1)
A1(224, 220) = A1(224, 220) - v(228); % source1:SUCFUMt_09:xsucc#0001(8)
A1(224, 220) = A1(224, 220) - v(228); % source1:SUCFUMt_01:xsucc#0001(8)
A1(224, 223) = A1(224, 223) - v(228); % source1:SUCFUMt_06:xsucc#1000(1)
A1(224, 220) = A1(224, 220) - v(225); % source1:SUCCt2b_03:xsucc#0001(8)
A1(224, 223) = A1(224, 223) - v(228); % source1:SUCFUMt_03:xsucc#1000(1)
A1(224, 223) = A1(224, 223) - v(228); % source1:SUCFUMt_14:xsucc#1000(1)
A1(224, 220) = A1(224, 220) - v(228); % source1:SUCFUMt_07:xsucc#0001(8)
A1(224, 223) = A1(224, 223) - v(228); % source1:SUCFUMt_11:xsucc#1000(1)
A1(224, 223) = A1(224, 223) - v(228); % source1:SUCFUMt_05:xsucc#1000(1)
A1(224, 220) = A1(224, 220) - v(228); % source1:SUCFUMt_16:xsucc#0001(8)
A1(224, 223) = A1(224, 223) - v(228); % source1:SUCFUMt_04:xsucc#1000(1)
A1(224, 223) = A1(224, 223) - v(225); % source1:SUCCt2b_01:xsucc#1000(1)
%>>> xsucce#0010#
A1(225, 225) = v(325) + v(222) + v(325) + v(325) + v(223) + v(222) + v(224) + v(20) + v(223) + v(325) + v(325) + v(325) + v(325) + v(223) + v(325) + v(325) + v(325) + v(222) + v(224) + v(325) + v(325) + v(224) + v(325) + v(222) + v(325) + v(224) + v(223) + v(325) + v(325) + v(20); % drain :SUCFUMt_r_11:SUCCabc_04:SUCFUMt_r_07:SUCFUMt_r_06:SUCCt22_01:SUCCabc_02:SUCCt23_01:EX_succ_02:SUCCt22_03:SUCFUMt_r_05:SUCFUMt_r_01:SUCFUMt_r_16:SUCFUMt_r_13:SUCCt22_04:SUCFUMt_r_15:SUCFUMt_r_02:SUCFUMt_r_08:SUCCabc_01:SUCCt23_04:SUCFUMt_r_03:SUCFUMt_r_09:SUCCt23_03:SUCFUMt_r_12:SUCCabc_03:SUCFUMt_r_14:SUCCt23_02:SUCCt22_02:SUCFUMt_r_10:SUCFUMt_r_04:EX_succ_01 
A1(225, 221) = A1(225, 221) - v(228); % source1:SUCFUMt_15:xsucc#0010(4)
A1(225, 221) = A1(225, 221) - v(228); % source1:SUCFUMt_08:xsucc#0010(4)
A1(225, 222) = A1(225, 222) - v(225); % source1:SUCCt2b_04:xsucc#0100(2)
A1(225, 222) = A1(225, 222) - v(228); % source1:SUCFUMt_12:xsucc#0100(2)
A1(225, 221) = A1(225, 221) - v(225); % source1:SUCCt2b_02:xsucc#0010(4)
A1(225, 221) = A1(225, 221) - v(228); % source1:SUCFUMt_10:xsucc#0010(4)
A1(225, 221) = A1(225, 221) - v(228); % source1:SUCFUMt_02:xsucc#0010(4)
A1(225, 222) = A1(225, 222) - v(228); % source1:SUCFUMt_13:xsucc#0100(2)
A1(225, 221) = A1(225, 221) - v(228); % source1:SUCFUMt_09:xsucc#0010(4)
A1(225, 221) = A1(225, 221) - v(228); % source1:SUCFUMt_01:xsucc#0010(4)
A1(225, 222) = A1(225, 222) - v(228); % source1:SUCFUMt_06:xsucc#0100(2)
A1(225, 221) = A1(225, 221) - v(225); % source1:SUCCt2b_03:xsucc#0010(4)
A1(225, 222) = A1(225, 222) - v(228); % source1:SUCFUMt_03:xsucc#0100(2)
A1(225, 222) = A1(225, 222) - v(228); % source1:SUCFUMt_14:xsucc#0100(2)
A1(225, 221) = A1(225, 221) - v(228); % source1:SUCFUMt_07:xsucc#0010(4)
A1(225, 222) = A1(225, 222) - v(228); % source1:SUCFUMt_11:xsucc#0100(2)
A1(225, 222) = A1(225, 222) - v(228); % source1:SUCFUMt_05:xsucc#0100(2)
A1(225, 221) = A1(225, 221) - v(228); % source1:SUCFUMt_16:xsucc#0010(4)
A1(225, 222) = A1(225, 222) - v(228); % source1:SUCFUMt_04:xsucc#0100(2)
A1(225, 222) = A1(225, 222) - v(225); % source1:SUCCt2b_01:xsucc#0100(2)
%>>> xsucce#0100#
A1(226, 226) = v(325) + v(222) + v(325) + v(325) + v(223) + v(222) + v(224) + v(20) + v(223) + v(325) + v(325) + v(325) + v(325) + v(223) + v(325) + v(325) + v(325) + v(222) + v(224) + v(325) + v(325) + v(224) + v(325) + v(222) + v(325) + v(224) + v(223) + v(325) + v(325) + v(20); % drain :SUCFUMt_r_11:SUCCabc_04:SUCFUMt_r_07:SUCFUMt_r_06:SUCCt22_01:SUCCabc_02:SUCCt23_01:EX_succ_02:SUCCt22_03:SUCFUMt_r_05:SUCFUMt_r_01:SUCFUMt_r_16:SUCFUMt_r_13:SUCCt22_04:SUCFUMt_r_15:SUCFUMt_r_02:SUCFUMt_r_08:SUCCabc_01:SUCCt23_04:SUCFUMt_r_03:SUCFUMt_r_09:SUCCt23_03:SUCFUMt_r_12:SUCCabc_03:SUCFUMt_r_14:SUCCt23_02:SUCCt22_02:SUCFUMt_r_10:SUCFUMt_r_04:EX_succ_01 
A1(226, 222) = A1(226, 222) - v(228); % source1:SUCFUMt_15:xsucc#0100(2)
A1(226, 222) = A1(226, 222) - v(228); % source1:SUCFUMt_08:xsucc#0100(2)
A1(226, 221) = A1(226, 221) - v(225); % source1:SUCCt2b_04:xsucc#0010(4)
A1(226, 221) = A1(226, 221) - v(228); % source1:SUCFUMt_12:xsucc#0010(4)
A1(226, 222) = A1(226, 222) - v(225); % source1:SUCCt2b_02:xsucc#0100(2)
A1(226, 222) = A1(226, 222) - v(228); % source1:SUCFUMt_10:xsucc#0100(2)
A1(226, 222) = A1(226, 222) - v(228); % source1:SUCFUMt_02:xsucc#0100(2)
A1(226, 221) = A1(226, 221) - v(228); % source1:SUCFUMt_13:xsucc#0010(4)
A1(226, 222) = A1(226, 222) - v(228); % source1:SUCFUMt_09:xsucc#0100(2)
A1(226, 222) = A1(226, 222) - v(228); % source1:SUCFUMt_01:xsucc#0100(2)
A1(226, 221) = A1(226, 221) - v(228); % source1:SUCFUMt_06:xsucc#0010(4)
A1(226, 222) = A1(226, 222) - v(225); % source1:SUCCt2b_03:xsucc#0100(2)
A1(226, 221) = A1(226, 221) - v(228); % source1:SUCFUMt_03:xsucc#0010(4)
A1(226, 221) = A1(226, 221) - v(228); % source1:SUCFUMt_14:xsucc#0010(4)
A1(226, 222) = A1(226, 222) - v(228); % source1:SUCFUMt_07:xsucc#0100(2)
A1(226, 221) = A1(226, 221) - v(228); % source1:SUCFUMt_11:xsucc#0010(4)
A1(226, 221) = A1(226, 221) - v(228); % source1:SUCFUMt_05:xsucc#0010(4)
A1(226, 222) = A1(226, 222) - v(228); % source1:SUCFUMt_16:xsucc#0100(2)
A1(226, 221) = A1(226, 221) - v(228); % source1:SUCFUMt_04:xsucc#0010(4)
A1(226, 221) = A1(226, 221) - v(225); % source1:SUCCt2b_01:xsucc#0010(4)
%>>> xsucce#1000#
A1(227, 227) = v(325) + v(222) + v(325) + v(325) + v(223) + v(222) + v(224) + v(20) + v(223) + v(325) + v(325) + v(325) + v(325) + v(223) + v(325) + v(325) + v(325) + v(222) + v(224) + v(325) + v(325) + v(224) + v(325) + v(222) + v(325) + v(224) + v(223) + v(325) + v(325) + v(20); % drain :SUCFUMt_r_11:SUCCabc_04:SUCFUMt_r_07:SUCFUMt_r_06:SUCCt22_01:SUCCabc_02:SUCCt23_01:EX_succ_02:SUCCt22_03:SUCFUMt_r_05:SUCFUMt_r_01:SUCFUMt_r_16:SUCFUMt_r_13:SUCCt22_04:SUCFUMt_r_15:SUCFUMt_r_02:SUCFUMt_r_08:SUCCabc_01:SUCCt23_04:SUCFUMt_r_03:SUCFUMt_r_09:SUCCt23_03:SUCFUMt_r_12:SUCCabc_03:SUCFUMt_r_14:SUCCt23_02:SUCCt22_02:SUCFUMt_r_10:SUCFUMt_r_04:EX_succ_01 
A1(227, 223) = A1(227, 223) - v(228); % source1:SUCFUMt_15:xsucc#1000(1)
A1(227, 223) = A1(227, 223) - v(228); % source1:SUCFUMt_08:xsucc#1000(1)
A1(227, 220) = A1(227, 220) - v(225); % source1:SUCCt2b_04:xsucc#0001(8)
A1(227, 220) = A1(227, 220) - v(228); % source1:SUCFUMt_12:xsucc#0001(8)
A1(227, 223) = A1(227, 223) - v(225); % source1:SUCCt2b_02:xsucc#1000(1)
A1(227, 223) = A1(227, 223) - v(228); % source1:SUCFUMt_10:xsucc#1000(1)
A1(227, 223) = A1(227, 223) - v(228); % source1:SUCFUMt_02:xsucc#1000(1)
A1(227, 220) = A1(227, 220) - v(228); % source1:SUCFUMt_13:xsucc#0001(8)
A1(227, 223) = A1(227, 223) - v(228); % source1:SUCFUMt_09:xsucc#1000(1)
A1(227, 223) = A1(227, 223) - v(228); % source1:SUCFUMt_01:xsucc#1000(1)
A1(227, 220) = A1(227, 220) - v(228); % source1:SUCFUMt_06:xsucc#0001(8)
A1(227, 223) = A1(227, 223) - v(225); % source1:SUCCt2b_03:xsucc#1000(1)
A1(227, 220) = A1(227, 220) - v(228); % source1:SUCFUMt_03:xsucc#0001(8)
A1(227, 220) = A1(227, 220) - v(228); % source1:SUCFUMt_14:xsucc#0001(8)
A1(227, 223) = A1(227, 223) - v(228); % source1:SUCFUMt_07:xsucc#1000(1)
A1(227, 220) = A1(227, 220) - v(228); % source1:SUCFUMt_11:xsucc#0001(8)
A1(227, 220) = A1(227, 220) - v(228); % source1:SUCFUMt_05:xsucc#0001(8)
A1(227, 223) = A1(227, 223) - v(228); % source1:SUCFUMt_16:xsucc#1000(1)
A1(227, 220) = A1(227, 220) - v(228); % source1:SUCFUMt_04:xsucc#0001(8)
A1(227, 220) = A1(227, 220) - v(225); % source1:SUCCt2b_01:xsucc#0001(8)
%>>> xsuccoa#0001#
A1(228, 228) = v(326) + v(71) + v(61) + 3e-06*v(1) + v(61) + v(326); % drain :SUCOAS_r_02:COMBO26_01:COMBO22_02:BiomassEcoliGALUi_01:COMBO22_01:SUCOAS_r_01 
A1(228, 54) = A1(228, 54) - v(233); % source1:TESTAKGDH_01:xakg#00001(16)
A1(228, 220) = A1(228, 220) - v(229); % source1:SUCOAS_02:xsucc#0001(8)
A1(228, 223) = A1(228, 223) - v(229); % source1:SUCOAS_01:xsucc#1000(1)
%>>> xsuccoa#0010#
A1(229, 229) = v(326) + v(71) + v(61) + 3e-06*v(1) + v(61) + v(326); % drain :SUCOAS_r_02:COMBO26_01:COMBO22_02:BiomassEcoliGALUi_01:COMBO22_01:SUCOAS_r_01 
A1(229, 55) = A1(229, 55) - v(233); % source1:TESTAKGDH_01:xakg#00010(8)
A1(229, 221) = A1(229, 221) - v(229); % source1:SUCOAS_02:xsucc#0010(4)
A1(229, 222) = A1(229, 222) - v(229); % source1:SUCOAS_01:xsucc#0100(2)
%>>> xsuccoa#0100#
A1(230, 230) = v(326) + v(71) + v(61) + 3e-06*v(1) + v(61) + v(326); % drain :SUCOAS_r_02:COMBO26_01:COMBO22_02:BiomassEcoliGALUi_01:COMBO22_01:SUCOAS_r_01 
A1(230, 56) = A1(230, 56) - v(233); % source1:TESTAKGDH_01:xakg#00100(4)
A1(230, 222) = A1(230, 222) - v(229); % source1:SUCOAS_02:xsucc#0100(2)
A1(230, 221) = A1(230, 221) - v(229); % source1:SUCOAS_01:xsucc#0010(4)
%>>> xsuccoa#1000#
A1(231, 231) = v(326) + v(71) + v(61) + 3e-06*v(1) + v(61) + v(326); % drain :SUCOAS_r_02:COMBO26_01:COMBO22_02:BiomassEcoliGALUi_01:COMBO22_01:SUCOAS_r_01 
A1(231, 57) = A1(231, 57) - v(233); % source1:TESTAKGDH_01:xakg#01000(2)
A1(231, 223) = A1(231, 223) - v(229); % source1:SUCOAS_02:xsucc#1000(1)
A1(231, 220) = A1(231, 220) - v(229); % source1:SUCOAS_01:xsucc#0001(8)
%>>> xthrL#0001#
A1(232, 232) = v(237) + v(236) + 0.241*v(1) + v(112); % drain :THRDL_01:THRAr_01:BiomassEcoliGALUi_01:COMBO37_01 
A1(232, 232) = A1(232, 232) - v(328); % source1:THRAr_r_01:xthrL#0001(8)
A1(232, 70) = A1(232, 70) - v(130); % source1:COMBO41_01:xaspsa#0001(8)
%>>> xthrL#0010#
A1(233, 233) = v(237) + v(236) + 0.241*v(1) + v(112); % drain :THRDL_01:THRAr_01:BiomassEcoliGALUi_01:COMBO37_01 
A1(233, 233) = A1(233, 233) - v(328); % source1:THRAr_r_01:xthrL#0010(4)
A1(233, 71) = A1(233, 71) - v(130); % source1:COMBO41_01:xaspsa#0010(4)
%>>> xthrL#0100#
A1(234, 234) = v(237) + v(236) + 0.241*v(1) + v(112); % drain :THRDL_01:THRAr_01:BiomassEcoliGALUi_01:COMBO37_01 
A1(234, 144) = A1(234, 144) - v(328); % source1:THRAr_r_01:xgly#01(2)
A1(234, 72) = A1(234, 72) - v(130); % source1:COMBO41_01:xaspsa#0100(2)
%>>> xthrL#1000#
A1(235, 235) = v(237) + v(236) + 0.241*v(1) + v(112); % drain :THRDL_01:THRAr_01:BiomassEcoliGALUi_01:COMBO37_01 
A1(235, 145) = A1(235, 145) - v(328); % source1:THRAr_r_01:xgly#10(1)
A1(235, 73) = A1(235, 73) - v(130); % source1:COMBO41_01:xaspsa#1000(1)
%>>> xtrpL#00100000000#
A1(236, 236) = v(242) + 0.054*v(1); % drain :TRPAS2_01:BiomassEcoliGALUi_01 
A1(236, 190) = A1(236, 190) - v(332); % source1:TRPAS2_r_01:xpyr#001(4)
A1(236, 210) = A1(236, 210) - v(244); % source1:TRPS2_01:xserL#001(4)
A1(236, 210) = A1(236, 210) - v(243); % source1:TRPS1_01:xserL#001(4)
%>>> xtrpL#01000000000#
A1(237, 237) = v(242) + 0.054*v(1); % drain :TRPAS2_01:BiomassEcoliGALUi_01 
A1(237, 191) = A1(237, 191) - v(332); % source1:TRPAS2_r_01:xpyr#010(2)
A1(237, 211) = A1(237, 211) - v(244); % source1:TRPS2_01:xserL#010(2)
A1(237, 211) = A1(237, 211) - v(243); % source1:TRPS1_01:xserL#010(2)
%>>> xtrpL#10000000000#
A1(238, 238) = v(242) + 0.054*v(1); % drain :TRPAS2_01:BiomassEcoliGALUi_01 
A1(238, 192) = A1(238, 192) - v(332); % source1:TRPAS2_r_01:xpyr#100(1)
A1(238, 212) = A1(238, 212) - v(244); % source1:TRPS2_01:xserL#100(1)
A1(238, 212) = A1(238, 212) - v(243); % source1:TRPS1_01:xserL#100(1)
%>>> xxu5pD#00001#
A1(239, 239) = v(239) + v(320) + v(238); % drain :TKT2_01:RPE_r_01:TKT1_01 
A1(239, 123) = A1(239, 123) - v(330); % source1:TKT2_r_01:xg3p#001(4)
A1(239, 198) = A1(239, 198) - v(212); % source1:RPE_01:xru5pD#00001(16)
A1(239, 123) = A1(239, 123) - v(329); % source1:TKT1_r_01:xg3p#001(4)
%>>> xxu5pD#00010#
A1(240, 240) = v(239) + v(320) + v(238); % drain :TKT2_01:RPE_r_01:TKT1_01 
A1(240, 124) = A1(240, 124) - v(330); % source1:TKT2_r_01:xg3p#010(2)
A1(240, 199) = A1(240, 199) - v(212); % source1:RPE_01:xru5pD#00010(8)
A1(240, 124) = A1(240, 124) - v(329); % source1:TKT1_r_01:xg3p#010(2)
%>>> xxu5pD#00100#
A1(241, 241) = v(239) + v(320) + v(238); % drain :TKT2_01:RPE_r_01:TKT1_01 
A1(241, 125) = A1(241, 125) - v(330); % source1:TKT2_r_01:xg3p#100(1)
A1(241, 200) = A1(241, 200) - v(212); % source1:RPE_01:xru5pD#00100(4)
A1(241, 125) = A1(241, 125) - v(329); % source1:TKT1_r_01:xg3p#100(1)
%>>> xxu5pD#01000#
A1(242, 242) = v(239) + v(320) + v(238); % drain :TKT2_01:RPE_r_01:TKT1_01 
A1(242, 100) = A1(242, 100) - v(330); % source1:TKT2_r_01:xf6p#010000(2)
A1(242, 201) = A1(242, 201) - v(212); % source1:RPE_01:xru5pD#01000(2)
A1(242, 208) = A1(242, 208) - v(329); % source1:TKT1_r_01:xs7p#0100000(2)
%>>> xxu5pD#10000#
A1(243, 243) = v(239) + v(320) + v(238); % drain :TKT2_01:RPE_r_01:TKT1_01 
A1(243, 101) = A1(243, 101) - v(330); % source1:TKT2_r_01:xf6p#100000(1)
A1(243, 202) = A1(243, 202) - v(212); % source1:RPE_01:xru5pD#10000(1)
A1(243, 209) = A1(243, 209) - v(329); % source1:TKT1_r_01:xs7p#1000000(1)
x1 = solveLin(A1, B1);  

% level: 2 of size 164
A2 = sparse(164, 164);
B2 = zeros(164, 3);
%>>> x13dpg#011#
A2(1, 1) = v(296) + v(312); % drain :GAPD_r_01:PGK_r_01 
A2(1, 11) = A2(1, 11) - v(189); % source1:PGK_01:x3pg#011(6)
A2(1, 81) = A2(1, 81) - v(100); % source1:GAPD_01:xg3p#011(6)
%>>> x13dpg#110#
A2(2, 2) = v(296) + v(312); % drain :GAPD_r_01:PGK_r_01 
A2(2, 12) = A2(2, 12) - v(189); % source1:PGK_01:x3pg#110(3)
A2(2, 82) = A2(2, 82) - v(100); % source1:GAPD_01:xg3p#110(3)
%>>> x1pyr5c#00011#
A2(3, 3) = v(182) + v(183); % drain :P5CD_01:P5CR_01 
A2(3, 87) = A2(3, 87) - v(97); % source1:G5SADs_01:xglu5sa#00011(24)
A2(3, 3) = A2(3, 3) - v(203); % source1:PROD2_01:x1pyr5c#00011(24)
%>>> x1pyr5c#00110#
A2(4, 4) = v(182) + v(183); % drain :P5CD_01:P5CR_01 
A2(4, 88) = A2(4, 88) - v(97); % source1:G5SADs_01:xglu5sa#00110(12)
A2(4, 4) = A2(4, 4) - v(203); % source1:PROD2_01:x1pyr5c#00110(12)
%>>> x1pyr5c#01100#
A2(5, 5) = v(182) + v(183); % drain :P5CD_01:P5CR_01 
A2(5, 89) = A2(5, 89) - v(97); % source1:G5SADs_01:xglu5sa#01100(6)
A2(5, 5) = A2(5, 5) - v(203); % source1:PROD2_01:x1pyr5c#01100(6)
%>>> x1pyr5c#10001#
A2(6, 6) = v(182) + v(183); % drain :P5CD_01:P5CR_01 
A2(6, 90) = A2(6, 90) - v(97); % source1:G5SADs_01:xglu5sa#10001(17)
A2(6, 6) = A2(6, 6) - v(203); % source1:PROD2_01:x1pyr5c#10001(17)
%>>> x1pyr5c#11000#
A2(7, 7) = v(182) + v(183); % drain :P5CD_01:P5CR_01 
A2(7, 91) = A2(7, 91) - v(97); % source1:G5SADs_01:xglu5sa#11000(3)
A2(7, 7) = A2(7, 7) - v(203); % source1:PROD2_01:x1pyr5c#11000(3)
%>>> x2pg#011#
A2(8, 8) = v(77) + v(191); % drain :ENO_01:PGM_01 
A2(8, 123) = A2(8, 123) - v(288); % source1:ENO_r_01:xpep#011(6)
A2(8, 11) = A2(8, 11) - v(313); % source1:PGM_r_01:x3pg#011(6)
%>>> x2pg#110#
A2(9, 9) = v(77) + v(191); % drain :ENO_01:PGM_01 
A2(9, 124) = A2(9, 124) - v(288); % source1:ENO_r_01:xpep#110(3)
A2(9, 12) = A2(9, 12) - v(313); % source1:PGM_r_01:x3pg#110(3)
%>>> x34hpp#110000000#
A2(10, 10) = v(333) + v(333) + v(333) + v(333); % drain :TYRTA_r_04:TYRTA_r_02:TYRTA_r_01:TYRTA_r_03 
A2(10, 124) = A2(10, 124) - v(200); % source1:PPND_01:xpep#110(3)
A2(10, 161) = A2(10, 161) - v(247); % source1:TYRTA_01:xtyrL#110000000(3)
A2(10, 161) = A2(10, 161) - v(247); % source1:TYRTA_03:xtyrL#110000000(3)
A2(10, 161) = A2(10, 161) - v(247); % source1:TYRTA_04:xtyrL#110000000(3)
A2(10, 161) = A2(10, 161) - v(247); % source1:TYRTA_02:xtyrL#110000000(3)
A2(10, 124) = A2(10, 124) - v(200); % source1:PPND_02:xpep#110(3)
%>>> x3pg#011#
A2(11, 11) = v(189) + v(313) + v(187); % drain :PGK_01:PGM_r_01:COMBO47_01 
B2(11,:) = B2(11,:) + conv(x1(142,:), x1(142,:)) * v(114); % source2:GLYCK_01:xglx#01(2):xglx#01(2)
A2(11, 1) = A2(11, 1) - v(312); % source1:PGK_r_01:x13dpg#011(6)
A2(11, 8) = A2(11, 8) - v(191); % source1:PGM_01:x2pg#011(6)
%>>> x3pg#110#
A2(12, 12) = v(189) + v(313) + v(187); % drain :PGK_01:PGM_r_01:COMBO47_01 
A2(12, 97) = A2(12, 97) - v(114); % source1:GLYCK_01:xglx#11(3)
A2(12, 2) = A2(12, 2) - v(312); % source1:PGK_r_01:x13dpg#110(3)
A2(12, 9) = A2(12, 9) - v(191); % source1:PGM_01:x2pg#110(3)
%>>> x4abut#0011#
A2(13, 13) = v(21); % drain :ABTA_01 
A2(13, 129) = A2(13, 129) - v(22); % source1:COMBO2_01:xptrc#1100(3)
A2(13, 94) = A2(13, 94) - v(107); % source1:GLUDC_01:xgluL#01100(6)
A2(13, 127) = A2(13, 127) - v(22); % source1:COMBO2_02:xptrc#0011(12)
%>>> x4abut#0110#
A2(14, 14) = v(21); % drain :ABTA_01 
A2(14, 128) = A2(14, 128) - v(22); % source1:COMBO2_01:xptrc#0110(6)
A2(14, 93) = A2(14, 93) - v(107); % source1:GLUDC_01:xgluL#00110(12)
A2(14, 128) = A2(14, 128) - v(22); % source1:COMBO2_02:xptrc#0110(6)
%>>> x4abut#1100#
A2(15, 15) = v(21); % drain :ABTA_01 
A2(15, 127) = A2(15, 127) - v(22); % source1:COMBO2_01:xptrc#0011(12)
A2(15, 92) = A2(15, 92) - v(107); % source1:GLUDC_01:xgluL#00011(24)
A2(15, 129) = A2(15, 129) - v(22); % source1:COMBO2_02:xptrc#1100(3)
%>>> x4pasp#0011#
A2(16, 16) = v(281) + v(282); % drain :ASAD_r_01:ASPK_r_01 
A2(16, 47) = A2(16, 47) - v(46); % source1:ASAD_01:xaspsa#0011(12)
A2(16, 44) = A2(16, 44) - v(50); % source1:ASPK_01:xaspL#0011(12)
%>>> x4pasp#0110#
A2(17, 17) = v(281) + v(282); % drain :ASAD_r_01:ASPK_r_01 
A2(17, 48) = A2(17, 48) - v(46); % source1:ASAD_01:xaspsa#0110(6)
A2(17, 45) = A2(17, 45) - v(50); % source1:ASPK_01:xaspL#0110(6)
%>>> x4pasp#1100#
A2(18, 18) = v(281) + v(282); % drain :ASAD_r_01:ASPK_r_01 
A2(18, 49) = A2(18, 49) - v(46); % source1:ASAD_01:xaspsa#1100(3)
A2(18, 46) = A2(18, 46) - v(50); % source1:ASPK_01:xaspL#1100(3)
%>>> xac#11#
A2(19, 19) = v(275) + v(26) + v(31); % drain :ACt2r_r_01:ACKr_01:ACS_01 
A2(19, 20) = A2(19, 20) - v(60); % source1:CYSS_01:xaccoa#11(3)
A2(19, 130) = A2(19, 130) - v(196); % source1:POX_01:xpyr#011(6)
A2(19, 27) = A2(19, 27) - v(157); % source1:NACODA_01:xacg5sa#0000011(96)
A2(19, 157) = A2(19, 157) - v(42); % source1:ALDD2x_01:xthrL#0011(12)
A2(19, 27) = A2(19, 27) - v(28); % source1:ACODA_01:xacg5sa#0000011(96)
A2(19, 20) = A2(19, 20) - 2*v(265); % source1:LPSSYN_01:xaccoa#11(3)
A2(19, 19) = A2(19, 19) - v(32); % source1:ACt2r_01:xac#11(3)
A2(19, 33) = A2(19, 33) - v(272); % source1:ACKr_r_01:xactp#11(3)
%>>> xaccoa#11#
A2(20, 20) = v(148) + v(141) + v(216) + 5e-05*v(1) + 16.86*v(260) + v(24) + v(206) + v(33) + 2*v(266) + 2*v(266) + v(58) + 43*v(265); % drain :MALS_01:IPPS_01:SERAT_01:BiomassEcoliGALUi_01:CDPDAGSYN_01:COMBO3_01:PTAr_01:ADHEr_01:PEPTIDOSYN_01:PEPTIDOSYN_02:CS_01:LPSSYN_01 
A2(20, 157) = A2(20, 157) - v(23); % source1:ACALDi_01:xthrL#0011(12)
A2(20, 130) = A2(20, 130) - v(184); % source1:PDH_01:xpyr#011(6)
A2(20, 20) = A2(20, 20) - v(323); % source1:SERAT_r_01:xaccoa#11(3)
A2(20, 62) = A2(20, 62) - v(276); % source1:ADHEr_r_01:xetoh#11(3)
A2(20, 19) = A2(20, 19) - v(31); % source1:ACS_01:xac#11(3)
A2(20, 157) = A2(20, 157) - v(112); % source1:COMBO37_01:xthrL#0011(12)
A2(20, 130) = A2(20, 130) - v(186); % source1:PFL_01:xpyr#011(6)
A2(20, 33) = A2(20, 33) - v(318); % source1:PTAr_r_01:xactp#11(3)
%>>> xacg5p#0000011#
A2(21, 21) = v(277); % drain :AGPR_r_01 
A2(21, 27) = A2(21, 27) - v(39); % source1:AGPR_01:xacg5sa#0000011(96)
A2(21, 20) = A2(21, 20) - v(24); % source1:COMBO3_01:xaccoa#11(3)
%>>> xacg5p#0001100#
A2(22, 22) = v(277); % drain :AGPR_r_01 
A2(22, 28) = A2(22, 28) - v(39); % source1:AGPR_01:xacg5sa#0001100(24)
A2(22, 92) = A2(22, 92) - v(24); % source1:COMBO3_01:xgluL#00011(24)
%>>> xacg5p#0011000#
A2(23, 23) = v(277); % drain :AGPR_r_01 
A2(23, 29) = A2(23, 29) - v(39); % source1:AGPR_01:xacg5sa#0011000(12)
A2(23, 93) = A2(23, 93) - v(24); % source1:COMBO3_01:xgluL#00110(12)
%>>> xacg5p#0110000#
A2(24, 24) = v(277); % drain :AGPR_r_01 
A2(24, 30) = A2(24, 30) - v(39); % source1:AGPR_01:xacg5sa#0110000(6)
A2(24, 94) = A2(24, 94) - v(24); % source1:COMBO3_01:xgluL#01100(6)
%>>> xacg5p#1000100#
A2(25, 25) = v(277); % drain :AGPR_r_01 
A2(25, 31) = A2(25, 31) - v(39); % source1:AGPR_01:xacg5sa#1000100(17)
A2(25, 95) = A2(25, 95) - v(24); % source1:COMBO3_01:xgluL#10001(17)
%>>> xacg5p#1100000#
A2(26, 26) = v(277); % drain :AGPR_r_01 
A2(26, 32) = A2(26, 32) - v(39); % source1:AGPR_01:xacg5sa#1100000(3)
A2(26, 96) = A2(26, 96) - v(24); % source1:COMBO3_01:xgluL#11000(3)
%>>> xacg5sa#0000011#
A2(27, 27) = v(157) + v(274) + v(39); % drain :NACODA_01:ACOTA_r_01:AGPR_01 
A2(27, 21) = A2(27, 21) - v(277); % source1:AGPR_r_01:xacg5p#0000011(96)
A2(27, 27) = A2(27, 27) - v(30); % source1:ACOTA_01:xacg5sa#0000011(96)
%>>> xacg5sa#0001100#
A2(28, 28) = v(157) + v(274) + v(39); % drain :NACODA_01:ACOTA_r_01:AGPR_01 
A2(28, 22) = A2(28, 22) - v(277); % source1:AGPR_r_01:xacg5p#0001100(24)
A2(28, 28) = A2(28, 28) - v(30); % source1:ACOTA_01:xacg5sa#0001100(24)
%>>> xacg5sa#0011000#
A2(29, 29) = v(157) + v(274) + v(39); % drain :NACODA_01:ACOTA_r_01:AGPR_01 
A2(29, 23) = A2(29, 23) - v(277); % source1:AGPR_r_01:xacg5p#0011000(12)
A2(29, 29) = A2(29, 29) - v(30); % source1:ACOTA_01:xacg5sa#0011000(12)
%>>> xacg5sa#0110000#
A2(30, 30) = v(157) + v(274) + v(39); % drain :NACODA_01:ACOTA_r_01:AGPR_01 
A2(30, 24) = A2(30, 24) - v(277); % source1:AGPR_r_01:xacg5p#0110000(6)
A2(30, 30) = A2(30, 30) - v(30); % source1:ACOTA_01:xacg5sa#0110000(6)
%>>> xacg5sa#1000100#
A2(31, 31) = v(157) + v(274) + v(39); % drain :NACODA_01:ACOTA_r_01:AGPR_01 
A2(31, 25) = A2(31, 25) - v(277); % source1:AGPR_r_01:xacg5p#1000100(17)
A2(31, 31) = A2(31, 31) - v(30); % source1:ACOTA_01:xacg5sa#1000100(17)
%>>> xacg5sa#1100000#
A2(32, 32) = v(157) + v(274) + v(39); % drain :NACODA_01:ACOTA_r_01:AGPR_01 
A2(32, 26) = A2(32, 26) - v(277); % source1:AGPR_r_01:xacg5p#1100000(3)
A2(32, 32) = A2(32, 32) - v(30); % source1:ACOTA_01:xacg5sa#1100000(3)
%>>> xactp#11#
A2(33, 33) = v(318) + v(272); % drain :PTAr_r_01:ACKr_r_01 
A2(33, 19) = A2(33, 19) - v(26); % source1:ACKr_01:xac#11(3)
A2(33, 20) = A2(33, 20) - v(206); % source1:PTAr_01:xaccoa#11(3)
%>>> xakg#00011#
A2(34, 34) = v(215) + v(110) + v(297) + v(247) + v(247) + v(250) + v(247) + v(41) + v(110) + v(22) + v(301) + v(193) + v(233) + v(247) + v(193) + v(30) + v(22) + v(51) + v(21) + v(193) + v(193) + v(136); % drain :SDPTA_01:GLUSy_02:GLUDy_r_01:TYRTA_04:TYRTA_02:VALTA_01:TYRTA_01:ALATAL_01:GLUSy_01:COMBO2_02:ICDHyr_r_01:PHETA1_04:TESTAKGDH_01:TYRTA_03:PHETA1_01:ACOTA_01:COMBO2_01:ASPTA_01:ABTA_01:PHETA1_02:PHETA1_03:ILETA_01 
A2(34, 92) = A2(34, 92) - v(333); % source1:TYRTA_r_04:xgluL#00011(24)
A2(34, 92) = A2(34, 92) - v(315); % source1:PHETA1_r_03:xgluL#00011(24)
A2(34, 92) = A2(34, 92) - v(274); % source1:ACOTA_r_01:xgluL#00011(24)
A2(34, 92) = A2(34, 92) - v(322); % source1:SDPTA_r_01:xgluL#00011(24)
A2(34, 92) = A2(34, 92) - v(147); % source1:LEUTAi_01:xgluL#00011(24)
A2(34, 92) = A2(34, 92) - v(334); % source1:VALTA_r_01:xgluL#00011(24)
A2(34, 92) = A2(34, 92) - v(333); % source1:TYRTA_r_02:xgluL#00011(24)
A2(34, 92) = A2(34, 92) - v(302); % source1:ILETA_r_01:xgluL#00011(24)
A2(34, 92) = A2(34, 92) - v(187); % source1:COMBO47_01:xgluL#00011(24)
A2(34, 92) = A2(34, 92) - v(315); % source1:PHETA1_r_02:xgluL#00011(24)
A2(34, 92) = A2(34, 92) - v(315); % source1:PHETA1_r_04:xgluL#00011(24)
A2(34, 92) = A2(34, 92) - v(249); % source1:UNK3_01:xgluL#00011(24)
A2(34, 92) = A2(34, 92) - v(333); % source1:TYRTA_r_01:xgluL#00011(24)
A2(34, 92) = A2(34, 92) - v(279); % source1:ALATAL_r_01:xgluL#00011(24)
A2(34, 92) = A2(34, 92) - v(251); % source1:HISSYN_01:xgluL#00011(24)
A2(34, 92) = A2(34, 92) - v(283); % source1:ASPTA_r_01:xgluL#00011(24)
A2(34, 106) = A2(34, 106) - v(134); % source1:ICDHyr_01:xicit#000110(24)
A2(34, 92) = A2(34, 92) - v(108); % source1:GLUDy_01:xgluL#00011(24)
A2(34, 92) = A2(34, 92) - v(333); % source1:TYRTA_r_03:xgluL#00011(24)
A2(34, 92) = A2(34, 92) - v(315); % source1:PHETA1_r_01:xgluL#00011(24)
%>>> xakg#00110#
A2(35, 35) = v(215) + v(110) + v(297) + v(247) + v(247) + v(250) + v(247) + v(41) + v(110) + v(22) + v(301) + v(193) + v(233) + v(247) + v(193) + v(30) + v(22) + v(51) + v(21) + v(193) + v(193) + v(136); % drain :SDPTA_01:GLUSy_02:GLUDy_r_01:TYRTA_04:TYRTA_02:VALTA_01:TYRTA_01:ALATAL_01:GLUSy_01:COMBO2_02:ICDHyr_r_01:PHETA1_04:TESTAKGDH_01:TYRTA_03:PHETA1_01:ACOTA_01:COMBO2_01:ASPTA_01:ABTA_01:PHETA1_02:PHETA1_03:ILETA_01 
A2(35, 93) = A2(35, 93) - v(333); % source1:TYRTA_r_04:xgluL#00110(12)
A2(35, 93) = A2(35, 93) - v(315); % source1:PHETA1_r_03:xgluL#00110(12)
A2(35, 93) = A2(35, 93) - v(274); % source1:ACOTA_r_01:xgluL#00110(12)
A2(35, 93) = A2(35, 93) - v(322); % source1:SDPTA_r_01:xgluL#00110(12)
A2(35, 93) = A2(35, 93) - v(147); % source1:LEUTAi_01:xgluL#00110(12)
A2(35, 93) = A2(35, 93) - v(334); % source1:VALTA_r_01:xgluL#00110(12)
A2(35, 93) = A2(35, 93) - v(333); % source1:TYRTA_r_02:xgluL#00110(12)
A2(35, 93) = A2(35, 93) - v(302); % source1:ILETA_r_01:xgluL#00110(12)
A2(35, 93) = A2(35, 93) - v(187); % source1:COMBO47_01:xgluL#00110(12)
A2(35, 93) = A2(35, 93) - v(315); % source1:PHETA1_r_02:xgluL#00110(12)
A2(35, 93) = A2(35, 93) - v(315); % source1:PHETA1_r_04:xgluL#00110(12)
A2(35, 93) = A2(35, 93) - v(249); % source1:UNK3_01:xgluL#00110(12)
A2(35, 93) = A2(35, 93) - v(333); % source1:TYRTA_r_01:xgluL#00110(12)
A2(35, 93) = A2(35, 93) - v(279); % source1:ALATAL_r_01:xgluL#00110(12)
A2(35, 93) = A2(35, 93) - v(251); % source1:HISSYN_01:xgluL#00110(12)
A2(35, 93) = A2(35, 93) - v(283); % source1:ASPTA_r_01:xgluL#00110(12)
A2(35, 108) = A2(35, 108) - v(134); % source1:ICDHyr_01:xicit#001100(12)
A2(35, 93) = A2(35, 93) - v(108); % source1:GLUDy_01:xgluL#00110(12)
A2(35, 93) = A2(35, 93) - v(333); % source1:TYRTA_r_03:xgluL#00110(12)
A2(35, 93) = A2(35, 93) - v(315); % source1:PHETA1_r_01:xgluL#00110(12)
%>>> xakg#01100#
A2(36, 36) = v(215) + v(110) + v(297) + v(247) + v(247) + v(250) + v(247) + v(41) + v(110) + v(22) + v(301) + v(193) + v(233) + v(247) + v(193) + v(30) + v(22) + v(51) + v(21) + v(193) + v(193) + v(136); % drain :SDPTA_01:GLUSy_02:GLUDy_r_01:TYRTA_04:TYRTA_02:VALTA_01:TYRTA_01:ALATAL_01:GLUSy_01:COMBO2_02:ICDHyr_r_01:PHETA1_04:TESTAKGDH_01:TYRTA_03:PHETA1_01:ACOTA_01:COMBO2_01:ASPTA_01:ABTA_01:PHETA1_02:PHETA1_03:ILETA_01 
A2(36, 94) = A2(36, 94) - v(333); % source1:TYRTA_r_04:xgluL#01100(6)
A2(36, 94) = A2(36, 94) - v(315); % source1:PHETA1_r_03:xgluL#01100(6)
A2(36, 94) = A2(36, 94) - v(274); % source1:ACOTA_r_01:xgluL#01100(6)
A2(36, 94) = A2(36, 94) - v(322); % source1:SDPTA_r_01:xgluL#01100(6)
A2(36, 94) = A2(36, 94) - v(147); % source1:LEUTAi_01:xgluL#01100(6)
A2(36, 94) = A2(36, 94) - v(334); % source1:VALTA_r_01:xgluL#01100(6)
A2(36, 94) = A2(36, 94) - v(333); % source1:TYRTA_r_02:xgluL#01100(6)
A2(36, 94) = A2(36, 94) - v(302); % source1:ILETA_r_01:xgluL#01100(6)
A2(36, 94) = A2(36, 94) - v(187); % source1:COMBO47_01:xgluL#01100(6)
A2(36, 94) = A2(36, 94) - v(315); % source1:PHETA1_r_02:xgluL#01100(6)
A2(36, 94) = A2(36, 94) - v(315); % source1:PHETA1_r_04:xgluL#01100(6)
A2(36, 94) = A2(36, 94) - v(249); % source1:UNK3_01:xgluL#01100(6)
A2(36, 94) = A2(36, 94) - v(333); % source1:TYRTA_r_01:xgluL#01100(6)
A2(36, 94) = A2(36, 94) - v(279); % source1:ALATAL_r_01:xgluL#01100(6)
A2(36, 94) = A2(36, 94) - v(251); % source1:HISSYN_01:xgluL#01100(6)
A2(36, 94) = A2(36, 94) - v(283); % source1:ASPTA_r_01:xgluL#01100(6)
A2(36, 109) = A2(36, 109) - v(134); % source1:ICDHyr_01:xicit#011000(6)
A2(36, 94) = A2(36, 94) - v(108); % source1:GLUDy_01:xgluL#01100(6)
A2(36, 94) = A2(36, 94) - v(333); % source1:TYRTA_r_03:xgluL#01100(6)
A2(36, 94) = A2(36, 94) - v(315); % source1:PHETA1_r_01:xgluL#01100(6)
%>>> xakg#10001#
A2(37, 37) = v(215) + v(110) + v(297) + v(247) + v(247) + v(250) + v(247) + v(41) + v(110) + v(22) + v(301) + v(193) + v(233) + v(247) + v(193) + v(30) + v(22) + v(51) + v(21) + v(193) + v(193) + v(136); % drain :SDPTA_01:GLUSy_02:GLUDy_r_01:TYRTA_04:TYRTA_02:VALTA_01:TYRTA_01:ALATAL_01:GLUSy_01:COMBO2_02:ICDHyr_r_01:PHETA1_04:TESTAKGDH_01:TYRTA_03:PHETA1_01:ACOTA_01:COMBO2_01:ASPTA_01:ABTA_01:PHETA1_02:PHETA1_03:ILETA_01 
A2(37, 95) = A2(37, 95) - v(333); % source1:TYRTA_r_04:xgluL#10001(17)
A2(37, 95) = A2(37, 95) - v(315); % source1:PHETA1_r_03:xgluL#10001(17)
A2(37, 95) = A2(37, 95) - v(274); % source1:ACOTA_r_01:xgluL#10001(17)
A2(37, 95) = A2(37, 95) - v(322); % source1:SDPTA_r_01:xgluL#10001(17)
A2(37, 95) = A2(37, 95) - v(147); % source1:LEUTAi_01:xgluL#10001(17)
A2(37, 95) = A2(37, 95) - v(334); % source1:VALTA_r_01:xgluL#10001(17)
A2(37, 95) = A2(37, 95) - v(333); % source1:TYRTA_r_02:xgluL#10001(17)
A2(37, 95) = A2(37, 95) - v(302); % source1:ILETA_r_01:xgluL#10001(17)
A2(37, 95) = A2(37, 95) - v(187); % source1:COMBO47_01:xgluL#10001(17)
A2(37, 95) = A2(37, 95) - v(315); % source1:PHETA1_r_02:xgluL#10001(17)
A2(37, 95) = A2(37, 95) - v(315); % source1:PHETA1_r_04:xgluL#10001(17)
A2(37, 95) = A2(37, 95) - v(249); % source1:UNK3_01:xgluL#10001(17)
A2(37, 95) = A2(37, 95) - v(333); % source1:TYRTA_r_01:xgluL#10001(17)
A2(37, 95) = A2(37, 95) - v(279); % source1:ALATAL_r_01:xgluL#10001(17)
A2(37, 95) = A2(37, 95) - v(251); % source1:HISSYN_01:xgluL#10001(17)
A2(37, 95) = A2(37, 95) - v(283); % source1:ASPTA_r_01:xgluL#10001(17)
A2(37, 110) = A2(37, 110) - v(134); % source1:ICDHyr_01:xicit#100010(17)
A2(37, 95) = A2(37, 95) - v(108); % source1:GLUDy_01:xgluL#10001(17)
A2(37, 95) = A2(37, 95) - v(333); % source1:TYRTA_r_03:xgluL#10001(17)
A2(37, 95) = A2(37, 95) - v(315); % source1:PHETA1_r_01:xgluL#10001(17)
%>>> xakg#11000#
A2(38, 38) = v(215) + v(110) + v(297) + v(247) + v(247) + v(250) + v(247) + v(41) + v(110) + v(22) + v(301) + v(193) + v(233) + v(247) + v(193) + v(30) + v(22) + v(51) + v(21) + v(193) + v(193) + v(136); % drain :SDPTA_01:GLUSy_02:GLUDy_r_01:TYRTA_04:TYRTA_02:VALTA_01:TYRTA_01:ALATAL_01:GLUSy_01:COMBO2_02:ICDHyr_r_01:PHETA1_04:TESTAKGDH_01:TYRTA_03:PHETA1_01:ACOTA_01:COMBO2_01:ASPTA_01:ABTA_01:PHETA1_02:PHETA1_03:ILETA_01 
A2(38, 96) = A2(38, 96) - v(333); % source1:TYRTA_r_04:xgluL#11000(3)
A2(38, 96) = A2(38, 96) - v(315); % source1:PHETA1_r_03:xgluL#11000(3)
A2(38, 96) = A2(38, 96) - v(274); % source1:ACOTA_r_01:xgluL#11000(3)
A2(38, 96) = A2(38, 96) - v(322); % source1:SDPTA_r_01:xgluL#11000(3)
A2(38, 96) = A2(38, 96) - v(147); % source1:LEUTAi_01:xgluL#11000(3)
A2(38, 96) = A2(38, 96) - v(334); % source1:VALTA_r_01:xgluL#11000(3)
A2(38, 96) = A2(38, 96) - v(333); % source1:TYRTA_r_02:xgluL#11000(3)
A2(38, 96) = A2(38, 96) - v(302); % source1:ILETA_r_01:xgluL#11000(3)
A2(38, 96) = A2(38, 96) - v(187); % source1:COMBO47_01:xgluL#11000(3)
A2(38, 96) = A2(38, 96) - v(315); % source1:PHETA1_r_02:xgluL#11000(3)
A2(38, 96) = A2(38, 96) - v(315); % source1:PHETA1_r_04:xgluL#11000(3)
A2(38, 96) = A2(38, 96) - v(249); % source1:UNK3_01:xgluL#11000(3)
A2(38, 96) = A2(38, 96) - v(333); % source1:TYRTA_r_01:xgluL#11000(3)
A2(38, 96) = A2(38, 96) - v(279); % source1:ALATAL_r_01:xgluL#11000(3)
A2(38, 96) = A2(38, 96) - v(251); % source1:HISSYN_01:xgluL#11000(3)
A2(38, 96) = A2(38, 96) - v(283); % source1:ASPTA_r_01:xgluL#11000(3)
A2(38, 111) = A2(38, 111) - v(134); % source1:ICDHyr_01:xicit#110000(3)
A2(38, 96) = A2(38, 96) - v(108); % source1:GLUDy_01:xgluL#11000(3)
A2(38, 96) = A2(38, 96) - v(333); % source1:TYRTA_r_03:xgluL#11000(3)
A2(38, 96) = A2(38, 96) - v(315); % source1:PHETA1_r_01:xgluL#11000(3)
%>>> xalaL#011#
A2(39, 39) = v(266) + v(41) + 0.488*v(1) + v(266) + v(40); % drain :PEPTIDOSYN_01:ALATAL_01:BiomassEcoliGALUi_01:PEPTIDOSYN_02:ALAR_01 
A2(39, 130) = A2(39, 130) - v(279); % source1:ALATAL_r_01:xpyr#011(6)
A2(39, 39) = A2(39, 39) - v(278); % source1:ALAR_r_01:xalaL#011(6)
%>>> xalaL#110#
A2(40, 40) = v(266) + v(41) + 0.488*v(1) + v(266) + v(40); % drain :PEPTIDOSYN_01:ALATAL_01:BiomassEcoliGALUi_01:PEPTIDOSYN_02:ALAR_01 
A2(40, 131) = A2(40, 131) - v(279); % source1:ALATAL_r_01:xpyr#110(3)
A2(40, 40) = A2(40, 40) - v(278); % source1:ALAR_r_01:xalaL#110(3)
%>>> xargsuc#0000000110#
A2(41, 41) = v(44) + v(44); % drain :ARGSL_01:ARGSL_02 
A2(41, 73) = A2(41, 73) - v(280); % source1:ARGSL_r_01:xfum#1100(3)
A2(41, 44) = A2(41, 44) - v(45); % source1:ARGSS_01:xaspL#0011(12)
A2(41, 71) = A2(41, 71) - v(280); % source1:ARGSL_r_02:xfum#0011(12)
%>>> xargsuc#0000001001#
A2(42, 42) = v(44) + v(44); % drain :ARGSL_01:ARGSL_02 
A2(42, 71) = A2(42, 71) - v(280); % source1:ARGSL_r_01:xfum#0011(12)
A2(42, 46) = A2(42, 46) - v(45); % source1:ARGSS_01:xaspL#1100(3)
A2(42, 73) = A2(42, 73) - v(280); % source1:ARGSL_r_02:xfum#1100(3)
%>>> xargsuc#0000001100#
A2(43, 43) = v(44) + v(44); % drain :ARGSL_01:ARGSL_02 
A2(43, 72) = A2(43, 72) - v(280); % source1:ARGSL_r_01:xfum#0110(6)
A2(43, 45) = A2(43, 45) - v(45); % source1:ARGSS_01:xaspL#0110(6)
A2(43, 72) = A2(43, 72) - v(280); % source1:ARGSL_r_02:xfum#0110(6)
%>>> xaspL#0011#
A2(44, 44) = v(45) + v(256) + v(38) + v(255) + v(38) + 0.229*v(1) + v(48) + v(256) + v(252) + v(50) + v(267) + v(51) + v(268) + v(253) + v(255) + v(258) + v(258); % drain :ARGSS_01:IMPSYN2_02:COMBO10_02:IMPSYN1_01:COMBO10_01:BiomassEcoliGALUi_01:ASNS1_01:IMPSYN2_01:UMPSYN1_01:ASPK_01:NADSYN1_01:ASPTA_01:NADSYN2_01:UMPSYN2_01:IMPSYN1_02:COASYN_02:COASYN_01 
A2(44, 44) = A2(44, 44) - v(47); % source1:ASNN_01:xaspL#0011(12)
A2(44, 117) = A2(44, 117) - v(283); % source1:ASPTA_r_01:xoaa#0011(12)
A2(44, 16) = A2(44, 16) - v(282); % source1:ASPK_r_01:x4pasp#0011(12)
%>>> xaspL#0110#
A2(45, 45) = v(45) + v(256) + v(38) + v(255) + v(38) + 0.229*v(1) + v(48) + v(256) + v(252) + v(50) + v(267) + v(51) + v(268) + v(253) + v(255) + v(258) + v(258); % drain :ARGSS_01:IMPSYN2_02:COMBO10_02:IMPSYN1_01:COMBO10_01:BiomassEcoliGALUi_01:ASNS1_01:IMPSYN2_01:UMPSYN1_01:ASPK_01:NADSYN1_01:ASPTA_01:NADSYN2_01:UMPSYN2_01:IMPSYN1_02:COASYN_02:COASYN_01 
A2(45, 45) = A2(45, 45) - v(47); % source1:ASNN_01:xaspL#0110(6)
A2(45, 118) = A2(45, 118) - v(283); % source1:ASPTA_r_01:xoaa#0110(6)
A2(45, 17) = A2(45, 17) - v(282); % source1:ASPK_r_01:x4pasp#0110(6)
%>>> xaspL#1100#
A2(46, 46) = v(45) + v(256) + v(38) + v(255) + v(38) + 0.229*v(1) + v(48) + v(256) + v(252) + v(50) + v(267) + v(51) + v(268) + v(253) + v(255) + v(258) + v(258); % drain :ARGSS_01:IMPSYN2_02:COMBO10_02:IMPSYN1_01:COMBO10_01:BiomassEcoliGALUi_01:ASNS1_01:IMPSYN2_01:UMPSYN1_01:ASPK_01:NADSYN1_01:ASPTA_01:NADSYN2_01:UMPSYN2_01:IMPSYN1_02:COASYN_02:COASYN_01 
A2(46, 46) = A2(46, 46) - v(47); % source1:ASNN_01:xaspL#1100(3)
A2(46, 119) = A2(46, 119) - v(283); % source1:ASPTA_r_01:xoaa#1100(3)
A2(46, 18) = A2(46, 18) - v(282); % source1:ASPK_r_01:x4pasp#1100(3)
%>>> xaspsa#0011#
A2(47, 47) = v(71) + v(46) + v(300); % drain :COMBO26_01:ASAD_01:HSDy_r_01 
A2(47, 47) = A2(47, 47) - v(129); % source1:HSDy_01:xaspsa#0011(12)
A2(47, 16) = A2(47, 16) - v(281); % source1:ASAD_r_01:x4pasp#0011(12)
%>>> xaspsa#0110#
A2(48, 48) = v(71) + v(46) + v(300); % drain :COMBO26_01:ASAD_01:HSDy_r_01 
A2(48, 48) = A2(48, 48) - v(129); % source1:HSDy_01:xaspsa#0110(6)
A2(48, 17) = A2(48, 17) - v(281); % source1:ASAD_r_01:x4pasp#0110(6)
%>>> xaspsa#1100#
A2(49, 49) = v(71) + v(46) + v(300); % drain :COMBO26_01:ASAD_01:HSDy_r_01 
A2(49, 49) = A2(49, 49) - v(129); % source1:HSDy_01:xaspsa#1100(3)
A2(49, 18) = A2(49, 18) - v(281); % source1:ASAD_r_01:x4pasp#1100(3)
%>>> xcit#000110#
A2(50, 50) = v(29); % drain :rACONT_01 
A2(50, 106) = A2(50, 106) - v(273); % source1:rACONT_r_01:xicit#000110(24)
A2(50, 20) = A2(50, 20) - v(58); % source1:CS_01:xaccoa#11(3)
%>>> xcit#001001#
A2(51, 51) = v(29); % drain :rACONT_01 
A2(51, 107) = A2(51, 107) - v(273); % source1:rACONT_r_01:xicit#001001(36)
A2(51, 119) = A2(51, 119) - v(58); % source1:CS_01:xoaa#1100(3)
%>>> xcit#001100#
A2(52, 52) = v(29); % drain :rACONT_01 
A2(52, 108) = A2(52, 108) - v(273); % source1:rACONT_r_01:xicit#001100(12)
B2(52,:) = B2(52,:) + conv(x1(36,:), x1(176,:)) * v(58); % source2:CS_01:xaccoa#01(2):xoaa#0100(2)
%>>> xcit#011000#
A2(53, 53) = v(29); % drain :rACONT_01 
A2(53, 109) = A2(53, 109) - v(273); % source1:rACONT_r_01:xicit#011000(6)
A2(53, 118) = A2(53, 118) - v(58); % source1:CS_01:xoaa#0110(6)
%>>> xcit#100010#
A2(54, 54) = v(29); % drain :rACONT_01 
A2(54, 110) = A2(54, 110) - v(273); % source1:rACONT_r_01:xicit#100010(17)
B2(54,:) = B2(54,:) + conv(x1(37,:), x1(174,:)) * v(58); % source2:CS_01:xaccoa#10(1):xoaa#0001(8)
%>>> xcit#110000#
A2(55, 55) = v(29); % drain :rACONT_01 
A2(55, 111) = A2(55, 111) - v(273); % source1:rACONT_r_01:xicit#110000(3)
A2(55, 117) = A2(55, 117) - v(58); % source1:CS_01:xoaa#0011(12)
%>>> xdha#011#
A2(56, 56) = v(70) + v(290) + v(290) + v(70); % drain :DHAPT_02:F6PA_r_02:F6PA_r_01:DHAPT_01 
A2(56, 100) = A2(56, 100) - v(113); % source1:GLYCDx_04:xglyc#110(3)
A2(56, 99) = A2(56, 99) - v(113); % source1:GLYCDx_03:xglyc#011(6)
A2(56, 99) = A2(56, 99) - v(113); % source1:GLYCDx_02:xglyc#011(6)
A2(56, 65) = A2(56, 65) - v(79); % source1:F6PA_02:xf6p#011000(6)
A2(56, 100) = A2(56, 100) - v(113); % source1:GLYCDx_01:xglyc#110(3)
A2(56, 66) = A2(56, 66) - v(79); % source1:F6PA_01:xf6p#110000(3)
%>>> xdha#110#
A2(57, 57) = v(70) + v(290) + v(290) + v(70); % drain :DHAPT_02:F6PA_r_02:F6PA_r_01:DHAPT_01 
A2(57, 99) = A2(57, 99) - v(113); % source1:GLYCDx_04:xglyc#011(6)
A2(57, 100) = A2(57, 100) - v(113); % source1:GLYCDx_03:xglyc#110(3)
A2(57, 100) = A2(57, 100) - v(113); % source1:GLYCDx_02:xglyc#110(3)
A2(57, 66) = A2(57, 66) - v(79); % source1:F6PA_02:xf6p#110000(3)
A2(57, 99) = A2(57, 99) - v(113); % source1:GLYCDx_01:xglyc#011(6)
A2(57, 65) = A2(57, 65) - v(79); % source1:F6PA_01:xf6p#011000(6)
%>>> xdhap#011#
A2(58, 58) = v(123) + v(240) + v(294) + v(268) + v(291) + v(267); % drain :COMBO38_01:TPI_01:G3PD2_r_01:NADSYN2_01:FBA_r_01:NADSYN1_01 
A2(58, 82) = A2(58, 82) - v(331); % source1:TPI_r_01:xg3p#110(3)
A2(58, 101) = A2(58, 101) - v(96); % source1:G3PD7_01:xglyc3p#011(6)
A2(58, 101) = A2(58, 101) - v(94); % source1:G3PD5_01:xglyc3p#011(6)
A2(58, 69) = A2(58, 69) - v(80); % source1:FBA_01:xfdp#011000(6)
A2(58, 56) = A2(58, 56) - v(70); % source1:DHAPT_02:xdha#011(6)
A2(58, 101) = A2(58, 101) - v(93); % source1:G3PD2_01:xglyc3p#011(6)
A2(58, 101) = A2(58, 101) - v(95); % source1:G3PD6_01:xglyc3p#011(6)
A2(58, 57) = A2(58, 57) - v(70); % source1:DHAPT_01:xdha#110(3)
%>>> xdhap#110#
A2(59, 59) = v(123) + v(240) + v(294) + v(268) + v(291) + v(267); % drain :COMBO38_01:TPI_01:G3PD2_r_01:NADSYN2_01:FBA_r_01:NADSYN1_01 
A2(59, 81) = A2(59, 81) - v(331); % source1:TPI_r_01:xg3p#011(6)
A2(59, 102) = A2(59, 102) - v(96); % source1:G3PD7_01:xglyc3p#110(3)
A2(59, 102) = A2(59, 102) - v(94); % source1:G3PD5_01:xglyc3p#110(3)
A2(59, 70) = A2(59, 70) - v(80); % source1:FBA_01:xfdp#110000(3)
A2(59, 57) = A2(59, 57) - v(70); % source1:DHAPT_02:xdha#110(3)
A2(59, 102) = A2(59, 102) - v(93); % source1:G3PD2_01:xglyc3p#110(3)
A2(59, 102) = A2(59, 102) - v(95); % source1:G3PD6_01:xglyc3p#110(3)
A2(59, 56) = A2(59, 56) - v(70); % source1:DHAPT_01:xdha#011(6)
%>>> xe4p#0011#
A2(60, 60) = v(239) + v(68) + v(327); % drain :TKT2_01:COMBO25_01:TALA_r_01 
A2(60, 63) = A2(60, 63) - v(330); % source1:TKT2_r_01:xf6p#000011(48)
A2(60, 138) = A2(60, 138) - v(232); % source1:TALA_01:xs7p#0000011(96)
%>>> xe4p#0110#
A2(61, 61) = v(239) + v(68) + v(327); % drain :TKT2_01:COMBO25_01:TALA_r_01 
A2(61, 64) = A2(61, 64) - v(330); % source1:TKT2_r_01:xf6p#000110(24)
A2(61, 139) = A2(61, 139) - v(232); % source1:TALA_01:xs7p#0000110(48)
%>>> xetoh#11#
A2(62, 62) = v(289) + v(276); % drain :ETOHt2r_r_01:ADHEr_r_01 
A2(62, 20) = A2(62, 20) - v(33); % source1:ADHEr_01:xaccoa#11(3)
A2(62, 62) = A2(62, 62) - v(78); % source1:ETOHt2r_01:xetoh#11(3)
%>>> xf6p#000011#
A2(63, 63) = v(327) + v(311) + v(330) + v(185) + 2*v(266) + v(79) + 2*v(266) + v(79) + 2*v(265); % drain :TALA_r_01:PGI_r_01:TKT2_r_01:PFK_01:PEPTIDOSYN_01:F6PA_02:PEPTIDOSYN_02:F6PA_01:LPSSYN_01 
A2(63, 60) = A2(63, 60) - v(239); % source1:TKT2_01:xe4p#0011(12)
A2(63, 67) = A2(63, 67) - v(81); % source1:FBP_01:xfdp#000011(48)
A2(63, 81) = A2(63, 81) - v(290); % source1:F6PA_r_02:xg3p#011(6)
A2(63, 81) = A2(63, 81) - v(290); % source1:F6PA_r_01:xg3p#011(6)
A2(63, 81) = A2(63, 81) - v(232); % source1:TALA_01:xg3p#011(6)
A2(63, 83) = A2(63, 83) - v(188); % source1:PGI_01:xg6p#000011(48)
%>>> xf6p#000110#
A2(64, 64) = v(327) + v(311) + v(330) + v(185) + 2*v(266) + v(79) + 2*v(266) + v(79) + 2*v(265); % drain :TALA_r_01:PGI_r_01:TKT2_r_01:PFK_01:PEPTIDOSYN_01:F6PA_02:PEPTIDOSYN_02:F6PA_01:LPSSYN_01 
A2(64, 61) = A2(64, 61) - v(239); % source1:TKT2_01:xe4p#0110(6)
A2(64, 68) = A2(64, 68) - v(81); % source1:FBP_01:xfdp#000110(24)
A2(64, 82) = A2(64, 82) - v(290); % source1:F6PA_r_02:xg3p#110(3)
A2(64, 82) = A2(64, 82) - v(290); % source1:F6PA_r_01:xg3p#110(3)
A2(64, 82) = A2(64, 82) - v(232); % source1:TALA_01:xg3p#110(3)
A2(64, 84) = A2(64, 84) - v(188); % source1:PGI_01:xg6p#000110(24)
%>>> xf6p#011000#
A2(65, 65) = v(327) + v(311) + v(330) + v(185) + 2*v(266) + v(79) + 2*v(266) + v(79) + 2*v(265); % drain :TALA_r_01:PGI_r_01:TKT2_r_01:PFK_01:PEPTIDOSYN_01:F6PA_02:PEPTIDOSYN_02:F6PA_01:LPSSYN_01 
B2(65,:) = B2(65,:) + conv(x1(242,:), x1(93,:)) * v(239); % source2:TKT2_01:xxu5pD#01000(2):xe4p#1000(1)
A2(65, 69) = A2(65, 69) - v(81); % source1:FBP_01:xfdp#011000(6)
A2(65, 56) = A2(65, 56) - v(290); % source1:F6PA_r_02:xdha#011(6)
A2(65, 57) = A2(65, 57) - v(290); % source1:F6PA_r_01:xdha#110(3)
A2(65, 141) = A2(65, 141) - v(232); % source1:TALA_01:xs7p#0110000(6)
A2(65, 85) = A2(65, 85) - v(188); % source1:PGI_01:xg6p#011000(6)
%>>> xf6p#110000#
A2(66, 66) = v(327) + v(311) + v(330) + v(185) + 2*v(266) + v(79) + 2*v(266) + v(79) + 2*v(265); % drain :TALA_r_01:PGI_r_01:TKT2_r_01:PFK_01:PEPTIDOSYN_01:F6PA_02:PEPTIDOSYN_02:F6PA_01:LPSSYN_01 
A2(66, 164) = A2(66, 164) - v(239); % source1:TKT2_01:xxu5pD#11000(3)
A2(66, 70) = A2(66, 70) - v(81); % source1:FBP_01:xfdp#110000(3)
A2(66, 57) = A2(66, 57) - v(290); % source1:F6PA_r_02:xdha#110(3)
A2(66, 56) = A2(66, 56) - v(290); % source1:F6PA_r_01:xdha#011(6)
A2(66, 142) = A2(66, 142) - v(232); % source1:TALA_01:xs7p#1100000(3)
A2(66, 86) = A2(66, 86) - v(188); % source1:PGI_01:xg6p#110000(3)
%>>> xfdp#000011#
A2(67, 67) = v(81) + v(80); % drain :FBP_01:FBA_01 
A2(67, 63) = A2(67, 63) - v(185); % source1:PFK_01:xf6p#000011(48)
A2(67, 81) = A2(67, 81) - v(291); % source1:FBA_r_01:xg3p#011(6)
%>>> xfdp#000110#
A2(68, 68) = v(81) + v(80); % drain :FBP_01:FBA_01 
A2(68, 64) = A2(68, 64) - v(185); % source1:PFK_01:xf6p#000110(24)
A2(68, 82) = A2(68, 82) - v(291); % source1:FBA_r_01:xg3p#110(3)
%>>> xfdp#011000#
A2(69, 69) = v(81) + v(80); % drain :FBP_01:FBA_01 
A2(69, 65) = A2(69, 65) - v(185); % source1:PFK_01:xf6p#011000(6)
A2(69, 58) = A2(69, 58) - v(291); % source1:FBA_r_01:xdhap#011(6)
%>>> xfdp#110000#
A2(70, 70) = v(81) + v(80); % drain :FBP_01:FBA_01 
A2(70, 66) = A2(70, 66) - v(185); % source1:PFK_01:xf6p#110000(3)
A2(70, 59) = A2(70, 59) - v(291); % source1:FBA_r_01:xdhap#110(3)
%>>> xfum#0011#
A2(71, 71) = v(325) + v(325) + v(86) + v(87) + v(325) + v(87) + v(325) + v(325) + v(325) + v(325) + v(87) + v(325) + v(325) + v(325) + v(89) + v(325) + v(325) + v(325) + v(86) + v(325) + v(87) + v(86) + v(280) + v(280) + v(86) + v(89) + v(325) + v(325); % drain :SUCFUMt_r_11:SUCFUMt_r_07:FRD2_03:FRD3_01:SUCFUMt_r_06:FRD3_04:SUCFUMt_r_05:SUCFUMt_r_01:SUCFUMt_r_16:SUCFUMt_r_13:FRD3_03:SUCFUMt_r_15:SUCFUMt_r_02:SUCFUMt_r_08:rFUM_01:SUCFUMt_r_03:SUCFUMt_r_09:SUCFUMt_r_12:FRD2_04:SUCFUMt_r_14:FRD3_02:FRD2_01:ARGSL_r_01:ARGSL_r_02:FRD2_02:rFUM_02:SUCFUMt_r_10:SUCFUMt_r_04 
A2(71, 114) = A2(71, 114) - v(293); % source1:rFUM_r_02:xmalL#0011(12)
A2(71, 148) = A2(71, 148) - v(226); % source1:SUCD1i_04:xsucc#0011(12)
A2(71, 74) = A2(71, 74) - v(228); % source1:SUCFUMt_08:xfume#0011(12)
A2(71, 46) = A2(71, 46) - v(38); % source1:COMBO10_01:xaspL#1100(3)
A2(71, 76) = A2(71, 76) - v(228); % source1:SUCFUMt_12:xfume#1100(3)
A2(71, 41) = A2(71, 41) - v(44); % source1:ARGSL_02:xargsuc#0000000110(384)
A2(71, 74) = A2(71, 74) - v(228); % source1:SUCFUMt_02:xfume#0011(12)
A2(71, 74) = A2(71, 74) - v(228); % source1:SUCFUMt_13:xfume#0011(12)
A2(71, 74) = A2(71, 74) - v(228); % source1:SUCFUMt_09:xfume#0011(12)
A2(71, 74) = A2(71, 74) - v(90); % source1:FUMt22_03:xfume#0011(12)
A2(71, 150) = A2(71, 150) - v(226); % source1:SUCD1i_03:xsucc#1100(3)
A2(71, 76) = A2(71, 76) - v(228); % source1:SUCFUMt_03:xfume#1100(3)
A2(71, 44) = A2(71, 44) - v(256); % source1:IMPSYN2_02:xaspL#0011(12)
A2(71, 44) = A2(71, 44) - v(38); % source1:COMBO10_02:xaspL#0011(12)
A2(71, 44) = A2(71, 44) - v(255); % source1:IMPSYN1_01:xaspL#0011(12)
A2(71, 76) = A2(71, 76) - v(228); % source1:SUCFUMt_07:xfume#1100(3)
A2(71, 74) = A2(71, 74) - v(228); % source1:SUCFUMt_11:xfume#0011(12)
A2(71, 76) = A2(71, 76) - v(228); % source1:SUCFUMt_05:xfume#1100(3)
A2(71, 76) = A2(71, 76) - v(228); % source1:SUCFUMt_16:xfume#1100(3)
A2(71, 76) = A2(71, 76) - v(90); % source1:FUMt22_01:xfume#1100(3)
A2(71, 44) = A2(71, 44) - v(255); % source1:IMPSYN1_02:xaspL#0011(12)
A2(71, 74) = A2(71, 74) - v(228); % source1:SUCFUMt_15:xfume#0011(12)
A2(71, 74) = A2(71, 74) - v(91); % source1:FUMt23_03:xfume#0011(12)
A2(71, 76) = A2(71, 76) - v(228); % source1:SUCFUMt_10:xfume#1100(3)
A2(71, 74) = A2(71, 74) - v(91); % source1:FUMt23_02:xfume#0011(12)
A2(71, 76) = A2(71, 76) - v(228); % source1:SUCFUMt_01:xfume#1100(3)
A2(71, 74) = A2(71, 74) - v(228); % source1:SUCFUMt_06:xfume#0011(12)
A2(71, 76) = A2(71, 76) - v(228); % source1:SUCFUMt_14:xfume#1100(3)
A2(71, 148) = A2(71, 148) - v(226); % source1:SUCD1i_01:xsucc#0011(12)
A2(71, 76) = A2(71, 76) - v(90); % source1:FUMt22_04:xfume#1100(3)
A2(71, 76) = A2(71, 76) - v(91); % source1:FUMt23_04:xfume#1100(3)
A2(71, 44) = A2(71, 44) - v(256); % source1:IMPSYN2_01:xaspL#0011(12)
A2(71, 76) = A2(71, 76) - v(91); % source1:FUMt23_01:xfume#1100(3)
A2(71, 74) = A2(71, 74) - v(90); % source1:FUMt22_02:xfume#0011(12)
A2(71, 42) = A2(71, 42) - v(44); % source1:ARGSL_01:xargsuc#0000001001(576)
A2(71, 116) = A2(71, 116) - v(293); % source1:rFUM_r_01:xmalL#1100(3)
A2(71, 74) = A2(71, 74) - v(228); % source1:SUCFUMt_04:xfume#0011(12)
A2(71, 150) = A2(71, 150) - v(226); % source1:SUCD1i_02:xsucc#1100(3)
%>>> xfum#0110#
A2(72, 72) = v(325) + v(325) + v(86) + v(87) + v(325) + v(87) + v(325) + v(325) + v(325) + v(325) + v(87) + v(325) + v(325) + v(325) + v(89) + v(325) + v(325) + v(325) + v(86) + v(325) + v(87) + v(86) + v(280) + v(280) + v(86) + v(89) + v(325) + v(325); % drain :SUCFUMt_r_11:SUCFUMt_r_07:FRD2_03:FRD3_01:SUCFUMt_r_06:FRD3_04:SUCFUMt_r_05:SUCFUMt_r_01:SUCFUMt_r_16:SUCFUMt_r_13:FRD3_03:SUCFUMt_r_15:SUCFUMt_r_02:SUCFUMt_r_08:rFUM_01:SUCFUMt_r_03:SUCFUMt_r_09:SUCFUMt_r_12:FRD2_04:SUCFUMt_r_14:FRD3_02:FRD2_01:ARGSL_r_01:ARGSL_r_02:FRD2_02:rFUM_02:SUCFUMt_r_10:SUCFUMt_r_04 
A2(72, 115) = A2(72, 115) - v(293); % source1:rFUM_r_02:xmalL#0110(6)
A2(72, 149) = A2(72, 149) - v(226); % source1:SUCD1i_04:xsucc#0110(6)
A2(72, 75) = A2(72, 75) - v(228); % source1:SUCFUMt_08:xfume#0110(6)
A2(72, 45) = A2(72, 45) - v(38); % source1:COMBO10_01:xaspL#0110(6)
A2(72, 75) = A2(72, 75) - v(228); % source1:SUCFUMt_12:xfume#0110(6)
A2(72, 43) = A2(72, 43) - v(44); % source1:ARGSL_02:xargsuc#0000001100(192)
A2(72, 75) = A2(72, 75) - v(228); % source1:SUCFUMt_02:xfume#0110(6)
A2(72, 75) = A2(72, 75) - v(228); % source1:SUCFUMt_13:xfume#0110(6)
A2(72, 75) = A2(72, 75) - v(228); % source1:SUCFUMt_09:xfume#0110(6)
A2(72, 75) = A2(72, 75) - v(90); % source1:FUMt22_03:xfume#0110(6)
A2(72, 149) = A2(72, 149) - v(226); % source1:SUCD1i_03:xsucc#0110(6)
A2(72, 75) = A2(72, 75) - v(228); % source1:SUCFUMt_03:xfume#0110(6)
A2(72, 45) = A2(72, 45) - v(256); % source1:IMPSYN2_02:xaspL#0110(6)
A2(72, 45) = A2(72, 45) - v(38); % source1:COMBO10_02:xaspL#0110(6)
A2(72, 45) = A2(72, 45) - v(255); % source1:IMPSYN1_01:xaspL#0110(6)
A2(72, 75) = A2(72, 75) - v(228); % source1:SUCFUMt_07:xfume#0110(6)
A2(72, 75) = A2(72, 75) - v(228); % source1:SUCFUMt_11:xfume#0110(6)
A2(72, 75) = A2(72, 75) - v(228); % source1:SUCFUMt_05:xfume#0110(6)
A2(72, 75) = A2(72, 75) - v(228); % source1:SUCFUMt_16:xfume#0110(6)
A2(72, 75) = A2(72, 75) - v(90); % source1:FUMt22_01:xfume#0110(6)
A2(72, 45) = A2(72, 45) - v(255); % source1:IMPSYN1_02:xaspL#0110(6)
A2(72, 75) = A2(72, 75) - v(228); % source1:SUCFUMt_15:xfume#0110(6)
A2(72, 75) = A2(72, 75) - v(91); % source1:FUMt23_03:xfume#0110(6)
A2(72, 75) = A2(72, 75) - v(228); % source1:SUCFUMt_10:xfume#0110(6)
A2(72, 75) = A2(72, 75) - v(91); % source1:FUMt23_02:xfume#0110(6)
A2(72, 75) = A2(72, 75) - v(228); % source1:SUCFUMt_01:xfume#0110(6)
A2(72, 75) = A2(72, 75) - v(228); % source1:SUCFUMt_06:xfume#0110(6)
A2(72, 75) = A2(72, 75) - v(228); % source1:SUCFUMt_14:xfume#0110(6)
A2(72, 149) = A2(72, 149) - v(226); % source1:SUCD1i_01:xsucc#0110(6)
A2(72, 75) = A2(72, 75) - v(90); % source1:FUMt22_04:xfume#0110(6)
A2(72, 75) = A2(72, 75) - v(91); % source1:FUMt23_04:xfume#0110(6)
A2(72, 45) = A2(72, 45) - v(256); % source1:IMPSYN2_01:xaspL#0110(6)
A2(72, 75) = A2(72, 75) - v(91); % source1:FUMt23_01:xfume#0110(6)
A2(72, 75) = A2(72, 75) - v(90); % source1:FUMt22_02:xfume#0110(6)
A2(72, 43) = A2(72, 43) - v(44); % source1:ARGSL_01:xargsuc#0000001100(192)
A2(72, 115) = A2(72, 115) - v(293); % source1:rFUM_r_01:xmalL#0110(6)
A2(72, 75) = A2(72, 75) - v(228); % source1:SUCFUMt_04:xfume#0110(6)
A2(72, 149) = A2(72, 149) - v(226); % source1:SUCD1i_02:xsucc#0110(6)
%>>> xfum#1100#
A2(73, 73) = v(325) + v(325) + v(86) + v(87) + v(325) + v(87) + v(325) + v(325) + v(325) + v(325) + v(87) + v(325) + v(325) + v(325) + v(89) + v(325) + v(325) + v(325) + v(86) + v(325) + v(87) + v(86) + v(280) + v(280) + v(86) + v(89) + v(325) + v(325); % drain :SUCFUMt_r_11:SUCFUMt_r_07:FRD2_03:FRD3_01:SUCFUMt_r_06:FRD3_04:SUCFUMt_r_05:SUCFUMt_r_01:SUCFUMt_r_16:SUCFUMt_r_13:FRD3_03:SUCFUMt_r_15:SUCFUMt_r_02:SUCFUMt_r_08:rFUM_01:SUCFUMt_r_03:SUCFUMt_r_09:SUCFUMt_r_12:FRD2_04:SUCFUMt_r_14:FRD3_02:FRD2_01:ARGSL_r_01:ARGSL_r_02:FRD2_02:rFUM_02:SUCFUMt_r_10:SUCFUMt_r_04 
A2(73, 116) = A2(73, 116) - v(293); % source1:rFUM_r_02:xmalL#1100(3)
A2(73, 150) = A2(73, 150) - v(226); % source1:SUCD1i_04:xsucc#1100(3)
A2(73, 76) = A2(73, 76) - v(228); % source1:SUCFUMt_08:xfume#1100(3)
A2(73, 44) = A2(73, 44) - v(38); % source1:COMBO10_01:xaspL#0011(12)
A2(73, 74) = A2(73, 74) - v(228); % source1:SUCFUMt_12:xfume#0011(12)
A2(73, 42) = A2(73, 42) - v(44); % source1:ARGSL_02:xargsuc#0000001001(576)
A2(73, 76) = A2(73, 76) - v(228); % source1:SUCFUMt_02:xfume#1100(3)
A2(73, 76) = A2(73, 76) - v(228); % source1:SUCFUMt_13:xfume#1100(3)
A2(73, 76) = A2(73, 76) - v(228); % source1:SUCFUMt_09:xfume#1100(3)
A2(73, 76) = A2(73, 76) - v(90); % source1:FUMt22_03:xfume#1100(3)
A2(73, 148) = A2(73, 148) - v(226); % source1:SUCD1i_03:xsucc#0011(12)
A2(73, 74) = A2(73, 74) - v(228); % source1:SUCFUMt_03:xfume#0011(12)
A2(73, 46) = A2(73, 46) - v(256); % source1:IMPSYN2_02:xaspL#1100(3)
A2(73, 46) = A2(73, 46) - v(38); % source1:COMBO10_02:xaspL#1100(3)
A2(73, 46) = A2(73, 46) - v(255); % source1:IMPSYN1_01:xaspL#1100(3)
A2(73, 74) = A2(73, 74) - v(228); % source1:SUCFUMt_07:xfume#0011(12)
A2(73, 76) = A2(73, 76) - v(228); % source1:SUCFUMt_11:xfume#1100(3)
A2(73, 74) = A2(73, 74) - v(228); % source1:SUCFUMt_05:xfume#0011(12)
A2(73, 74) = A2(73, 74) - v(228); % source1:SUCFUMt_16:xfume#0011(12)
A2(73, 74) = A2(73, 74) - v(90); % source1:FUMt22_01:xfume#0011(12)
A2(73, 46) = A2(73, 46) - v(255); % source1:IMPSYN1_02:xaspL#1100(3)
A2(73, 76) = A2(73, 76) - v(228); % source1:SUCFUMt_15:xfume#1100(3)
A2(73, 76) = A2(73, 76) - v(91); % source1:FUMt23_03:xfume#1100(3)
A2(73, 74) = A2(73, 74) - v(228); % source1:SUCFUMt_10:xfume#0011(12)
A2(73, 76) = A2(73, 76) - v(91); % source1:FUMt23_02:xfume#1100(3)
A2(73, 74) = A2(73, 74) - v(228); % source1:SUCFUMt_01:xfume#0011(12)
A2(73, 76) = A2(73, 76) - v(228); % source1:SUCFUMt_06:xfume#1100(3)
A2(73, 74) = A2(73, 74) - v(228); % source1:SUCFUMt_14:xfume#0011(12)
A2(73, 150) = A2(73, 150) - v(226); % source1:SUCD1i_01:xsucc#1100(3)
A2(73, 74) = A2(73, 74) - v(90); % source1:FUMt22_04:xfume#0011(12)
A2(73, 74) = A2(73, 74) - v(91); % source1:FUMt23_04:xfume#0011(12)
A2(73, 46) = A2(73, 46) - v(256); % source1:IMPSYN2_01:xaspL#1100(3)
A2(73, 74) = A2(73, 74) - v(91); % source1:FUMt23_01:xfume#0011(12)
A2(73, 76) = A2(73, 76) - v(90); % source1:FUMt22_02:xfume#1100(3)
A2(73, 41) = A2(73, 41) - v(44); % source1:ARGSL_01:xargsuc#0000000110(384)
A2(73, 114) = A2(73, 114) - v(293); % source1:rFUM_r_01:xmalL#0011(12)
A2(73, 76) = A2(73, 76) - v(228); % source1:SUCFUMt_04:xfume#1100(3)
A2(73, 148) = A2(73, 148) - v(226); % source1:SUCD1i_02:xsucc#0011(12)
%>>> xfume#0011#
A2(74, 74) = v(228) + v(228) + v(228) + v(91) + v(228) + v(228) + v(91) + v(228) + v(228) + v(228) + v(228) + v(90) + v(228) + v(6) + v(228) + v(90) + v(228) + v(91) + v(90) + v(91) + v(6) + v(228) + v(228) + v(228) + v(90) + v(228); % drain :SUCFUMt_15:SUCFUMt_08:SUCFUMt_12:FUMt23_03:SUCFUMt_10:SUCFUMt_02:FUMt23_02:SUCFUMt_13:SUCFUMt_09:SUCFUMt_01:SUCFUMt_06:FUMt22_03:SUCFUMt_03:EX_fum_01:SUCFUMt_14:FUMt22_04:SUCFUMt_07:FUMt23_04:FUMt22_02:FUMt23_01:EX_fum_02:SUCFUMt_11:SUCFUMt_05:SUCFUMt_16:FUMt22_01:SUCFUMt_04 
A2(74, 71) = A2(74, 71) - v(325); % source1:SUCFUMt_r_11:xfum#0011(12)
A2(74, 73) = A2(74, 73) - v(325); % source1:SUCFUMt_r_07:xfum#1100(3)
A2(74, 71) = A2(74, 71) - v(325); % source1:SUCFUMt_r_06:xfum#0011(12)
A2(74, 73) = A2(74, 73) - v(325); % source1:SUCFUMt_r_01:xfum#1100(3)
A2(74, 73) = A2(74, 73) - v(325); % source1:SUCFUMt_r_05:xfum#1100(3)
A2(74, 73) = A2(74, 73) - v(325); % source1:SUCFUMt_r_16:xfum#1100(3)
A2(74, 71) = A2(74, 71) - v(325); % source1:SUCFUMt_r_13:xfum#0011(12)
A2(74, 71) = A2(74, 71) - v(325); % source1:SUCFUMt_r_02:xfum#0011(12)
A2(74, 71) = A2(74, 71) - v(325); % source1:SUCFUMt_r_15:xfum#0011(12)
A2(74, 71) = A2(74, 71) - v(325); % source1:SUCFUMt_r_08:xfum#0011(12)
A2(74, 73) = A2(74, 73) - v(325); % source1:SUCFUMt_r_03:xfum#1100(3)
A2(74, 71) = A2(74, 71) - v(325); % source1:SUCFUMt_r_09:xfum#0011(12)
A2(74, 73) = A2(74, 73) - v(325); % source1:SUCFUMt_r_12:xfum#1100(3)
A2(74, 73) = A2(74, 73) - v(325); % source1:SUCFUMt_r_14:xfum#1100(3)
A2(74, 73) = A2(74, 73) - v(325); % source1:SUCFUMt_r_10:xfum#1100(3)
A2(74, 71) = A2(74, 71) - v(325); % source1:SUCFUMt_r_04:xfum#0011(12)
%>>> xfume#0110#
A2(75, 75) = v(228) + v(228) + v(228) + v(91) + v(228) + v(228) + v(91) + v(228) + v(228) + v(228) + v(228) + v(90) + v(228) + v(6) + v(228) + v(90) + v(228) + v(91) + v(90) + v(91) + v(6) + v(228) + v(228) + v(228) + v(90) + v(228); % drain :SUCFUMt_15:SUCFUMt_08:SUCFUMt_12:FUMt23_03:SUCFUMt_10:SUCFUMt_02:FUMt23_02:SUCFUMt_13:SUCFUMt_09:SUCFUMt_01:SUCFUMt_06:FUMt22_03:SUCFUMt_03:EX_fum_01:SUCFUMt_14:FUMt22_04:SUCFUMt_07:FUMt23_04:FUMt22_02:FUMt23_01:EX_fum_02:SUCFUMt_11:SUCFUMt_05:SUCFUMt_16:FUMt22_01:SUCFUMt_04 
A2(75, 72) = A2(75, 72) - v(325); % source1:SUCFUMt_r_11:xfum#0110(6)
A2(75, 72) = A2(75, 72) - v(325); % source1:SUCFUMt_r_07:xfum#0110(6)
A2(75, 72) = A2(75, 72) - v(325); % source1:SUCFUMt_r_06:xfum#0110(6)
A2(75, 72) = A2(75, 72) - v(325); % source1:SUCFUMt_r_01:xfum#0110(6)
A2(75, 72) = A2(75, 72) - v(325); % source1:SUCFUMt_r_05:xfum#0110(6)
A2(75, 72) = A2(75, 72) - v(325); % source1:SUCFUMt_r_16:xfum#0110(6)
A2(75, 72) = A2(75, 72) - v(325); % source1:SUCFUMt_r_13:xfum#0110(6)
A2(75, 72) = A2(75, 72) - v(325); % source1:SUCFUMt_r_02:xfum#0110(6)
A2(75, 72) = A2(75, 72) - v(325); % source1:SUCFUMt_r_15:xfum#0110(6)
A2(75, 72) = A2(75, 72) - v(325); % source1:SUCFUMt_r_08:xfum#0110(6)
A2(75, 72) = A2(75, 72) - v(325); % source1:SUCFUMt_r_03:xfum#0110(6)
A2(75, 72) = A2(75, 72) - v(325); % source1:SUCFUMt_r_09:xfum#0110(6)
A2(75, 72) = A2(75, 72) - v(325); % source1:SUCFUMt_r_12:xfum#0110(6)
A2(75, 72) = A2(75, 72) - v(325); % source1:SUCFUMt_r_14:xfum#0110(6)
A2(75, 72) = A2(75, 72) - v(325); % source1:SUCFUMt_r_10:xfum#0110(6)
A2(75, 72) = A2(75, 72) - v(325); % source1:SUCFUMt_r_04:xfum#0110(6)
%>>> xfume#1100#
A2(76, 76) = v(228) + v(228) + v(228) + v(91) + v(228) + v(228) + v(91) + v(228) + v(228) + v(228) + v(228) + v(90) + v(228) + v(6) + v(228) + v(90) + v(228) + v(91) + v(90) + v(91) + v(6) + v(228) + v(228) + v(228) + v(90) + v(228); % drain :SUCFUMt_15:SUCFUMt_08:SUCFUMt_12:FUMt23_03:SUCFUMt_10:SUCFUMt_02:FUMt23_02:SUCFUMt_13:SUCFUMt_09:SUCFUMt_01:SUCFUMt_06:FUMt22_03:SUCFUMt_03:EX_fum_01:SUCFUMt_14:FUMt22_04:SUCFUMt_07:FUMt23_04:FUMt22_02:FUMt23_01:EX_fum_02:SUCFUMt_11:SUCFUMt_05:SUCFUMt_16:FUMt22_01:SUCFUMt_04 
A2(76, 73) = A2(76, 73) - v(325); % source1:SUCFUMt_r_11:xfum#1100(3)
A2(76, 71) = A2(76, 71) - v(325); % source1:SUCFUMt_r_07:xfum#0011(12)
A2(76, 73) = A2(76, 73) - v(325); % source1:SUCFUMt_r_06:xfum#1100(3)
A2(76, 71) = A2(76, 71) - v(325); % source1:SUCFUMt_r_01:xfum#0011(12)
A2(76, 71) = A2(76, 71) - v(325); % source1:SUCFUMt_r_05:xfum#0011(12)
A2(76, 71) = A2(76, 71) - v(325); % source1:SUCFUMt_r_16:xfum#0011(12)
A2(76, 73) = A2(76, 73) - v(325); % source1:SUCFUMt_r_13:xfum#1100(3)
A2(76, 73) = A2(76, 73) - v(325); % source1:SUCFUMt_r_02:xfum#1100(3)
A2(76, 73) = A2(76, 73) - v(325); % source1:SUCFUMt_r_15:xfum#1100(3)
A2(76, 73) = A2(76, 73) - v(325); % source1:SUCFUMt_r_08:xfum#1100(3)
A2(76, 71) = A2(76, 71) - v(325); % source1:SUCFUMt_r_03:xfum#0011(12)
A2(76, 73) = A2(76, 73) - v(325); % source1:SUCFUMt_r_09:xfum#1100(3)
A2(76, 71) = A2(76, 71) - v(325); % source1:SUCFUMt_r_12:xfum#0011(12)
A2(76, 71) = A2(76, 71) - v(325); % source1:SUCFUMt_r_14:xfum#0011(12)
A2(76, 71) = A2(76, 71) - v(325); % source1:SUCFUMt_r_10:xfum#0011(12)
A2(76, 73) = A2(76, 73) - v(325); % source1:SUCFUMt_r_04:xfum#1100(3)
%>>> xg1p#000011#
A2(77, 77) = v(104) + 0.003*v(1) + v(92) + 2*v(265) + v(192); % drain :COMBO36_01:BiomassEcoliGALUi_01:G1PP_01:LPSSYN_01:PGMT_01 
A2(77, 83) = A2(77, 83) - v(314); % source1:PGMT_r_01:xg6p#000011(48)
A2(77, 77) = A2(77, 77) - v(103); % source1:GLCP_01:xg1p#000011(48)
%>>> xg1p#000110#
A2(78, 78) = v(104) + 0.003*v(1) + v(92) + 2*v(265) + v(192); % drain :COMBO36_01:BiomassEcoliGALUi_01:G1PP_01:LPSSYN_01:PGMT_01 
A2(78, 84) = A2(78, 84) - v(314); % source1:PGMT_r_01:xg6p#000110(24)
A2(78, 78) = A2(78, 78) - v(103); % source1:GLCP_01:xg1p#000110(24)
%>>> xg1p#011000#
A2(79, 79) = v(104) + 0.003*v(1) + v(92) + 2*v(265) + v(192); % drain :COMBO36_01:BiomassEcoliGALUi_01:G1PP_01:LPSSYN_01:PGMT_01 
A2(79, 85) = A2(79, 85) - v(314); % source1:PGMT_r_01:xg6p#011000(6)
A2(79, 79) = A2(79, 79) - v(103); % source1:GLCP_01:xg1p#011000(6)
%>>> xg1p#110000#
A2(80, 80) = v(104) + 0.003*v(1) + v(92) + 2*v(265) + v(192); % drain :COMBO36_01:BiomassEcoliGALUi_01:G1PP_01:LPSSYN_01:PGMT_01 
A2(80, 86) = A2(80, 86) - v(314); % source1:PGMT_r_01:xg6p#110000(3)
A2(80, 80) = A2(80, 80) - v(103); % source1:GLCP_01:xg1p#110000(3)
%>>> xg3p#011#
A2(81, 81) = v(331) + v(290) + v(290) + v(330) + v(291) + v(100) + v(232) + v(329); % drain :TPI_r_01:F6PA_r_02:F6PA_r_01:TKT2_r_01:FBA_r_01:GAPD_01:TALA_01:TKT1_r_01 
A2(81, 83) = A2(81, 83) - v(75); % source1:EDA_01:xg6p#000011(48)
A2(81, 63) = A2(81, 63) - v(327); % source1:TALA_r_01:xf6p#000011(48)
A2(81, 1) = A2(81, 1) - v(296); % source1:GAPD_r_01:x13dpg#011(6)
A2(81, 162) = A2(81, 162) - v(238); % source1:TKT1_01:xxu5pD#00011(24)
A2(81, 67) = A2(81, 67) - v(80); % source1:FBA_01:xfdp#000011(48)
A2(81, 162) = A2(81, 162) - v(239); % source1:TKT2_01:xxu5pD#00011(24)
A2(81, 59) = A2(81, 59) - v(240); % source1:TPI_01:xdhap#110(3)
A2(81, 132) = A2(81, 132) - v(245); % source1:TRPS3_01:xr5p#00011(24)
A2(81, 63) = A2(81, 63) - v(79); % source1:F6PA_02:xf6p#000011(48)
A2(81, 63) = A2(81, 63) - v(79); % source1:F6PA_01:xf6p#000011(48)
A2(81, 132) = A2(81, 132) - v(243); % source1:TRPS1_01:xr5p#00011(24)
%>>> xg3p#110#
A2(82, 82) = v(331) + v(290) + v(290) + v(330) + v(291) + v(100) + v(232) + v(329); % drain :TPI_r_01:F6PA_r_02:F6PA_r_01:TKT2_r_01:FBA_r_01:GAPD_01:TALA_01:TKT1_r_01 
A2(82, 84) = A2(82, 84) - v(75); % source1:EDA_01:xg6p#000110(24)
A2(82, 64) = A2(82, 64) - v(327); % source1:TALA_r_01:xf6p#000110(24)
A2(82, 2) = A2(82, 2) - v(296); % source1:GAPD_r_01:x13dpg#110(3)
A2(82, 163) = A2(82, 163) - v(238); % source1:TKT1_01:xxu5pD#00110(12)
A2(82, 68) = A2(82, 68) - v(80); % source1:FBA_01:xfdp#000110(24)
A2(82, 163) = A2(82, 163) - v(239); % source1:TKT2_01:xxu5pD#00110(12)
A2(82, 58) = A2(82, 58) - v(240); % source1:TPI_01:xdhap#011(6)
A2(82, 133) = A2(82, 133) - v(245); % source1:TRPS3_01:xr5p#00110(12)
A2(82, 64) = A2(82, 64) - v(79); % source1:F6PA_02:xf6p#000110(24)
A2(82, 64) = A2(82, 64) - v(79); % source1:F6PA_01:xf6p#000110(24)
A2(82, 133) = A2(82, 133) - v(243); % source1:TRPS1_01:xr5p#00110(12)
%>>> xg6p#000011#
A2(83, 83) = v(99) + v(314) + v(188); % drain :G6PDH2r_01:PGMT_r_01:PGI_01 
A2(83, 77) = A2(83, 77) - v(128); % source1:HEX1_01:xg1p#000011(48)
A2(83, 83) = A2(83, 83) - v(295); % source1:G6PDH2r_r_01:xg6p#000011(48)
A2(83, 63) = A2(83, 63) - v(311); % source1:PGI_r_01:xf6p#000011(48)
B2(83,:) = B2(83,:) + xglcDe.x000011' * v(105); % source1:GLCpts_01:xglcDe#000011(48)
A2(83, 77) = A2(83, 77) - v(192); % source1:PGMT_01:xg1p#000011(48)
%>>> xg6p#000110#
A2(84, 84) = v(99) + v(314) + v(188); % drain :G6PDH2r_01:PGMT_r_01:PGI_01 
A2(84, 78) = A2(84, 78) - v(128); % source1:HEX1_01:xg1p#000110(24)
A2(84, 84) = A2(84, 84) - v(295); % source1:G6PDH2r_r_01:xg6p#000110(24)
A2(84, 64) = A2(84, 64) - v(311); % source1:PGI_r_01:xf6p#000110(24)
B2(84,:) = B2(84,:) + xglcDe.x000110' * v(105); % source1:GLCpts_01:xglcDe#000110(24)
A2(84, 78) = A2(84, 78) - v(192); % source1:PGMT_01:xg1p#000110(24)
%>>> xg6p#011000#
A2(85, 85) = v(99) + v(314) + v(188); % drain :G6PDH2r_01:PGMT_r_01:PGI_01 
A2(85, 79) = A2(85, 79) - v(128); % source1:HEX1_01:xg1p#011000(6)
A2(85, 85) = A2(85, 85) - v(295); % source1:G6PDH2r_r_01:xg6p#011000(6)
A2(85, 65) = A2(85, 65) - v(311); % source1:PGI_r_01:xf6p#011000(6)
B2(85,:) = B2(85,:) + xglcDe.x011000' * v(105); % source1:GLCpts_01:xglcDe#011000(6)
A2(85, 79) = A2(85, 79) - v(192); % source1:PGMT_01:xg1p#011000(6)
%>>> xg6p#110000#
A2(86, 86) = v(99) + v(314) + v(188); % drain :G6PDH2r_01:PGMT_r_01:PGI_01 
A2(86, 80) = A2(86, 80) - v(128); % source1:HEX1_01:xg1p#110000(3)
A2(86, 86) = A2(86, 86) - v(295); % source1:G6PDH2r_r_01:xg6p#110000(3)
A2(86, 66) = A2(86, 66) - v(311); % source1:PGI_r_01:xf6p#110000(3)
B2(86,:) = B2(86,:) + xglcDe.x110000' * v(105); % source1:GLCpts_01:xglcDe#110000(3)
A2(86, 80) = A2(86, 80) - v(192); % source1:PGMT_01:xg1p#110000(3)
%>>> xglu5sa#00011#
A2(87, 87) = v(97); % drain :G5SADs_01 
A2(87, 28) = A2(87, 28) - v(157); % source1:NACODA_01:xacg5sa#0001100(24)
A2(87, 92) = A2(87, 92) - v(98); % source1:COMBO34_01:xgluL#00011(24)
%>>> xglu5sa#00110#
A2(88, 88) = v(97); % drain :G5SADs_01 
A2(88, 29) = A2(88, 29) - v(157); % source1:NACODA_01:xacg5sa#0011000(12)
A2(88, 93) = A2(88, 93) - v(98); % source1:COMBO34_01:xgluL#00110(12)
%>>> xglu5sa#01100#
A2(89, 89) = v(97); % drain :G5SADs_01 
A2(89, 30) = A2(89, 30) - v(157); % source1:NACODA_01:xacg5sa#0110000(6)
A2(89, 94) = A2(89, 94) - v(98); % source1:COMBO34_01:xgluL#01100(6)
%>>> xglu5sa#10001#
A2(90, 90) = v(97); % drain :G5SADs_01 
A2(90, 31) = A2(90, 31) - v(157); % source1:NACODA_01:xacg5sa#1000100(17)
A2(90, 95) = A2(90, 95) - v(98); % source1:COMBO34_01:xgluL#10001(17)
%>>> xglu5sa#11000#
A2(91, 91) = v(97); % drain :G5SADs_01 
A2(91, 32) = A2(91, 32) - v(157); % source1:NACODA_01:xacg5sa#1100000(3)
A2(91, 96) = A2(91, 96) - v(98); % source1:COMBO34_01:xgluL#11000(3)
%>>> xgluL#00011#
A2(92, 92) = v(333) + v(315) + v(274) + v(98) + v(24) + v(322) + v(147) + v(334) + v(333) + v(302) + v(187) + 0.25*v(1) + v(315) + v(315) + v(107) + v(249) + v(333) + v(279) + v(106) + v(283) + v(108) + v(333) + v(315); % drain :TYRTA_r_04:PHETA1_r_03:ACOTA_r_01:COMBO34_01:COMBO3_01:SDPTA_r_01:LEUTAi_01:VALTA_r_01:TYRTA_r_02:ILETA_r_01:COMBO47_01:BiomassEcoliGALUi_01:PHETA1_r_02:PHETA1_r_04:GLUDC_01:UNK3_01:TYRTA_r_01:ALATAL_r_01:GLNS_01:ASPTA_r_01:GLUDy_01:TYRTA_r_03:PHETA1_r_01 
A2(92, 92) = A2(92, 92) - v(124); % source1:GMPS2_01:xgluL#00011(24)
A2(92, 34) = A2(92, 34) - v(297); % source1:GLUDy_r_01:xakg#00011(24)
A2(92, 34) = A2(92, 34) - v(247); % source1:TYRTA_04:xakg#00011(24)
A2(92, 34) = A2(92, 34) - v(247); % source1:TYRTA_02:xakg#00011(24)
A2(92, 34) = A2(92, 34) - v(250); % source1:VALTA_01:xakg#00011(24)
A2(92, 34) = A2(92, 34) - 2*v(110); % source1:GLUSy_01:xakg#00011(24)
A2(92, 92) = A2(92, 92) - v(266); % source1:PEPTIDOSYN_02:xgluL#00011(24)
A2(92, 92) = A2(92, 92) - 2*v(265); % source1:LPSSYN_01:xgluL#00011(24)
A2(92, 92) = A2(92, 92) - 2*v(256); % source1:IMPSYN2_02:xgluL#00011(24)
A2(92, 95) = A2(92, 95) - 2*v(255); % source1:IMPSYN1_01:xgluL#10001(17)
A2(92, 34) = A2(92, 34) - v(247); % source1:TYRTA_03:xakg#00011(24)
A2(92, 34) = A2(92, 34) - v(193); % source1:PHETA1_01:xakg#00011(24)
A2(92, 34) = A2(92, 34) - v(30); % source1:ACOTA_01:xakg#00011(24)
A2(92, 34) = A2(92, 34) - v(22); % source1:COMBO2_01:xakg#00011(24)
A2(92, 92) = A2(92, 92) - v(266); % source1:PEPTIDOSYN_01:xgluL#00011(24)
A2(92, 34) = A2(92, 34) - v(51); % source1:ASPTA_01:xakg#00011(24)
A2(92, 34) = A2(92, 34) - v(21); % source1:ABTA_01:xakg#00011(24)
A2(92, 34) = A2(92, 34) - v(193); % source1:PHETA1_03:xakg#00011(24)
A2(92, 92) = A2(92, 92) - 2*v(255); % source1:IMPSYN1_02:xgluL#00011(24)
A2(92, 92) = A2(92, 92) - v(109); % source1:GLUN_01:xgluL#00011(24)
A2(92, 34) = A2(92, 34) - v(136); % source1:ILETA_01:xakg#00011(24)
A2(92, 92) = A2(92, 92) - 2*v(110); % source1:GLUSy_02:xgluL#00011(24)
A2(92, 3) = A2(92, 3) - v(182); % source1:P5CD_01:x1pyr5c#00011(24)
A2(92, 34) = A2(92, 34) - v(215); % source1:SDPTA_01:xakg#00011(24)
A2(92, 92) = A2(92, 92) - v(48); % source1:ASNS1_01:xgluL#00011(24)
A2(92, 92) = A2(92, 92) - v(254); % source1:CTPSYN_01:xgluL#00011(24)
A2(92, 34) = A2(92, 34) - v(41); % source1:ALATAL_01:xakg#00011(24)
A2(92, 34) = A2(92, 34) - v(247); % source1:TYRTA_01:xakg#00011(24)
A2(92, 34) = A2(92, 34) - v(22); % source1:COMBO2_02:xakg#00011(24)
A2(92, 34) = A2(92, 34) - v(193); % source1:PHETA1_04:xakg#00011(24)
A2(92, 92) = A2(92, 92) - v(54); % source1:CBPS_01:xgluL#00011(24)
A2(92, 92) = A2(92, 92) - 2*v(256); % source1:IMPSYN2_01:xgluL#00011(24)
A2(92, 92) = A2(92, 92) - v(43); % source1:COMBO15_01:xgluL#00011(24)
A2(92, 34) = A2(92, 34) - v(193); % source1:PHETA1_02:xakg#00011(24)
%>>> xgluL#00110#
A2(93, 93) = v(333) + v(315) + v(274) + v(98) + v(24) + v(322) + v(147) + v(334) + v(333) + v(302) + v(187) + 0.25*v(1) + v(315) + v(315) + v(107) + v(249) + v(333) + v(279) + v(106) + v(283) + v(108) + v(333) + v(315); % drain :TYRTA_r_04:PHETA1_r_03:ACOTA_r_01:COMBO34_01:COMBO3_01:SDPTA_r_01:LEUTAi_01:VALTA_r_01:TYRTA_r_02:ILETA_r_01:COMBO47_01:BiomassEcoliGALUi_01:PHETA1_r_02:PHETA1_r_04:GLUDC_01:UNK3_01:TYRTA_r_01:ALATAL_r_01:GLNS_01:ASPTA_r_01:GLUDy_01:TYRTA_r_03:PHETA1_r_01 
A2(93, 93) = A2(93, 93) - v(124); % source1:GMPS2_01:xgluL#00110(12)
A2(93, 35) = A2(93, 35) - v(297); % source1:GLUDy_r_01:xakg#00110(12)
A2(93, 35) = A2(93, 35) - v(247); % source1:TYRTA_04:xakg#00110(12)
A2(93, 35) = A2(93, 35) - v(247); % source1:TYRTA_02:xakg#00110(12)
A2(93, 35) = A2(93, 35) - v(250); % source1:VALTA_01:xakg#00110(12)
A2(93, 35) = A2(93, 35) - 2*v(110); % source1:GLUSy_01:xakg#00110(12)
A2(93, 93) = A2(93, 93) - v(266); % source1:PEPTIDOSYN_02:xgluL#00110(12)
A2(93, 93) = A2(93, 93) - 2*v(265); % source1:LPSSYN_01:xgluL#00110(12)
A2(93, 93) = A2(93, 93) - 2*v(256); % source1:IMPSYN2_02:xgluL#00110(12)
A2(93, 96) = A2(93, 96) - 2*v(255); % source1:IMPSYN1_01:xgluL#11000(3)
A2(93, 35) = A2(93, 35) - v(247); % source1:TYRTA_03:xakg#00110(12)
A2(93, 35) = A2(93, 35) - v(193); % source1:PHETA1_01:xakg#00110(12)
A2(93, 35) = A2(93, 35) - v(30); % source1:ACOTA_01:xakg#00110(12)
A2(93, 35) = A2(93, 35) - v(22); % source1:COMBO2_01:xakg#00110(12)
A2(93, 93) = A2(93, 93) - v(266); % source1:PEPTIDOSYN_01:xgluL#00110(12)
A2(93, 35) = A2(93, 35) - v(51); % source1:ASPTA_01:xakg#00110(12)
A2(93, 35) = A2(93, 35) - v(21); % source1:ABTA_01:xakg#00110(12)
A2(93, 35) = A2(93, 35) - v(193); % source1:PHETA1_03:xakg#00110(12)
A2(93, 93) = A2(93, 93) - 2*v(255); % source1:IMPSYN1_02:xgluL#00110(12)
A2(93, 93) = A2(93, 93) - v(109); % source1:GLUN_01:xgluL#00110(12)
A2(93, 35) = A2(93, 35) - v(136); % source1:ILETA_01:xakg#00110(12)
A2(93, 93) = A2(93, 93) - 2*v(110); % source1:GLUSy_02:xgluL#00110(12)
A2(93, 4) = A2(93, 4) - v(182); % source1:P5CD_01:x1pyr5c#00110(12)
A2(93, 35) = A2(93, 35) - v(215); % source1:SDPTA_01:xakg#00110(12)
A2(93, 93) = A2(93, 93) - v(48); % source1:ASNS1_01:xgluL#00110(12)
A2(93, 93) = A2(93, 93) - v(254); % source1:CTPSYN_01:xgluL#00110(12)
A2(93, 35) = A2(93, 35) - v(41); % source1:ALATAL_01:xakg#00110(12)
A2(93, 35) = A2(93, 35) - v(247); % source1:TYRTA_01:xakg#00110(12)
A2(93, 35) = A2(93, 35) - v(22); % source1:COMBO2_02:xakg#00110(12)
A2(93, 35) = A2(93, 35) - v(193); % source1:PHETA1_04:xakg#00110(12)
A2(93, 93) = A2(93, 93) - v(54); % source1:CBPS_01:xgluL#00110(12)
A2(93, 93) = A2(93, 93) - 2*v(256); % source1:IMPSYN2_01:xgluL#00110(12)
A2(93, 93) = A2(93, 93) - v(43); % source1:COMBO15_01:xgluL#00110(12)
A2(93, 35) = A2(93, 35) - v(193); % source1:PHETA1_02:xakg#00110(12)
%>>> xgluL#01100#
A2(94, 94) = v(333) + v(315) + v(274) + v(98) + v(24) + v(322) + v(147) + v(334) + v(333) + v(302) + v(187) + 0.25*v(1) + v(315) + v(315) + v(107) + v(249) + v(333) + v(279) + v(106) + v(283) + v(108) + v(333) + v(315); % drain :TYRTA_r_04:PHETA1_r_03:ACOTA_r_01:COMBO34_01:COMBO3_01:SDPTA_r_01:LEUTAi_01:VALTA_r_01:TYRTA_r_02:ILETA_r_01:COMBO47_01:BiomassEcoliGALUi_01:PHETA1_r_02:PHETA1_r_04:GLUDC_01:UNK3_01:TYRTA_r_01:ALATAL_r_01:GLNS_01:ASPTA_r_01:GLUDy_01:TYRTA_r_03:PHETA1_r_01 
A2(94, 94) = A2(94, 94) - v(124); % source1:GMPS2_01:xgluL#01100(6)
A2(94, 36) = A2(94, 36) - v(297); % source1:GLUDy_r_01:xakg#01100(6)
A2(94, 36) = A2(94, 36) - v(247); % source1:TYRTA_04:xakg#01100(6)
A2(94, 36) = A2(94, 36) - v(247); % source1:TYRTA_02:xakg#01100(6)
A2(94, 36) = A2(94, 36) - v(250); % source1:VALTA_01:xakg#01100(6)
A2(94, 36) = A2(94, 36) - 2*v(110); % source1:GLUSy_01:xakg#01100(6)
A2(94, 94) = A2(94, 94) - v(266); % source1:PEPTIDOSYN_02:xgluL#01100(6)
A2(94, 94) = A2(94, 94) - 2*v(265); % source1:LPSSYN_01:xgluL#01100(6)
A2(94, 94) = A2(94, 94) - 2*v(256); % source1:IMPSYN2_02:xgluL#01100(6)
A2(94, 94) = A2(94, 94) - 2*v(255); % source1:IMPSYN1_01:xgluL#01100(6)
A2(94, 36) = A2(94, 36) - v(247); % source1:TYRTA_03:xakg#01100(6)
A2(94, 36) = A2(94, 36) - v(193); % source1:PHETA1_01:xakg#01100(6)
A2(94, 36) = A2(94, 36) - v(30); % source1:ACOTA_01:xakg#01100(6)
A2(94, 36) = A2(94, 36) - v(22); % source1:COMBO2_01:xakg#01100(6)
A2(94, 94) = A2(94, 94) - v(266); % source1:PEPTIDOSYN_01:xgluL#01100(6)
A2(94, 36) = A2(94, 36) - v(51); % source1:ASPTA_01:xakg#01100(6)
A2(94, 36) = A2(94, 36) - v(21); % source1:ABTA_01:xakg#01100(6)
A2(94, 36) = A2(94, 36) - v(193); % source1:PHETA1_03:xakg#01100(6)
A2(94, 94) = A2(94, 94) - 2*v(255); % source1:IMPSYN1_02:xgluL#01100(6)
A2(94, 94) = A2(94, 94) - v(109); % source1:GLUN_01:xgluL#01100(6)
A2(94, 36) = A2(94, 36) - v(136); % source1:ILETA_01:xakg#01100(6)
A2(94, 94) = A2(94, 94) - 2*v(110); % source1:GLUSy_02:xgluL#01100(6)
A2(94, 5) = A2(94, 5) - v(182); % source1:P5CD_01:x1pyr5c#01100(6)
A2(94, 36) = A2(94, 36) - v(215); % source1:SDPTA_01:xakg#01100(6)
A2(94, 94) = A2(94, 94) - v(48); % source1:ASNS1_01:xgluL#01100(6)
A2(94, 94) = A2(94, 94) - v(254); % source1:CTPSYN_01:xgluL#01100(6)
A2(94, 36) = A2(94, 36) - v(41); % source1:ALATAL_01:xakg#01100(6)
A2(94, 36) = A2(94, 36) - v(247); % source1:TYRTA_01:xakg#01100(6)
A2(94, 36) = A2(94, 36) - v(22); % source1:COMBO2_02:xakg#01100(6)
A2(94, 36) = A2(94, 36) - v(193); % source1:PHETA1_04:xakg#01100(6)
A2(94, 94) = A2(94, 94) - v(54); % source1:CBPS_01:xgluL#01100(6)
A2(94, 94) = A2(94, 94) - 2*v(256); % source1:IMPSYN2_01:xgluL#01100(6)
A2(94, 94) = A2(94, 94) - v(43); % source1:COMBO15_01:xgluL#01100(6)
A2(94, 36) = A2(94, 36) - v(193); % source1:PHETA1_02:xakg#01100(6)
%>>> xgluL#10001#
A2(95, 95) = v(333) + v(315) + v(274) + v(98) + v(24) + v(322) + v(147) + v(334) + v(333) + v(302) + v(187) + 0.25*v(1) + v(315) + v(315) + v(107) + v(249) + v(333) + v(279) + v(106) + v(283) + v(108) + v(333) + v(315); % drain :TYRTA_r_04:PHETA1_r_03:ACOTA_r_01:COMBO34_01:COMBO3_01:SDPTA_r_01:LEUTAi_01:VALTA_r_01:TYRTA_r_02:ILETA_r_01:COMBO47_01:BiomassEcoliGALUi_01:PHETA1_r_02:PHETA1_r_04:GLUDC_01:UNK3_01:TYRTA_r_01:ALATAL_r_01:GLNS_01:ASPTA_r_01:GLUDy_01:TYRTA_r_03:PHETA1_r_01 
A2(95, 95) = A2(95, 95) - v(124); % source1:GMPS2_01:xgluL#10001(17)
A2(95, 37) = A2(95, 37) - v(297); % source1:GLUDy_r_01:xakg#10001(17)
A2(95, 37) = A2(95, 37) - v(247); % source1:TYRTA_04:xakg#10001(17)
A2(95, 37) = A2(95, 37) - v(247); % source1:TYRTA_02:xakg#10001(17)
A2(95, 37) = A2(95, 37) - v(250); % source1:VALTA_01:xakg#10001(17)
A2(95, 37) = A2(95, 37) - 2*v(110); % source1:GLUSy_01:xakg#10001(17)
A2(95, 95) = A2(95, 95) - v(266); % source1:PEPTIDOSYN_02:xgluL#10001(17)
A2(95, 95) = A2(95, 95) - 2*v(265); % source1:LPSSYN_01:xgluL#10001(17)
A2(95, 95) = A2(95, 95) - 2*v(256); % source1:IMPSYN2_02:xgluL#10001(17)
A2(95, 92) = A2(95, 92) - 2*v(255); % source1:IMPSYN1_01:xgluL#00011(24)
A2(95, 37) = A2(95, 37) - v(247); % source1:TYRTA_03:xakg#10001(17)
A2(95, 37) = A2(95, 37) - v(193); % source1:PHETA1_01:xakg#10001(17)
A2(95, 37) = A2(95, 37) - v(30); % source1:ACOTA_01:xakg#10001(17)
A2(95, 37) = A2(95, 37) - v(22); % source1:COMBO2_01:xakg#10001(17)
A2(95, 95) = A2(95, 95) - v(266); % source1:PEPTIDOSYN_01:xgluL#10001(17)
A2(95, 37) = A2(95, 37) - v(51); % source1:ASPTA_01:xakg#10001(17)
A2(95, 37) = A2(95, 37) - v(21); % source1:ABTA_01:xakg#10001(17)
A2(95, 37) = A2(95, 37) - v(193); % source1:PHETA1_03:xakg#10001(17)
A2(95, 95) = A2(95, 95) - 2*v(255); % source1:IMPSYN1_02:xgluL#10001(17)
A2(95, 95) = A2(95, 95) - v(109); % source1:GLUN_01:xgluL#10001(17)
A2(95, 37) = A2(95, 37) - v(136); % source1:ILETA_01:xakg#10001(17)
A2(95, 95) = A2(95, 95) - 2*v(110); % source1:GLUSy_02:xgluL#10001(17)
A2(95, 6) = A2(95, 6) - v(182); % source1:P5CD_01:x1pyr5c#10001(17)
A2(95, 37) = A2(95, 37) - v(215); % source1:SDPTA_01:xakg#10001(17)
A2(95, 95) = A2(95, 95) - v(48); % source1:ASNS1_01:xgluL#10001(17)
A2(95, 95) = A2(95, 95) - v(254); % source1:CTPSYN_01:xgluL#10001(17)
A2(95, 37) = A2(95, 37) - v(41); % source1:ALATAL_01:xakg#10001(17)
A2(95, 37) = A2(95, 37) - v(247); % source1:TYRTA_01:xakg#10001(17)
A2(95, 37) = A2(95, 37) - v(22); % source1:COMBO2_02:xakg#10001(17)
A2(95, 37) = A2(95, 37) - v(193); % source1:PHETA1_04:xakg#10001(17)
A2(95, 95) = A2(95, 95) - v(54); % source1:CBPS_01:xgluL#10001(17)
A2(95, 95) = A2(95, 95) - 2*v(256); % source1:IMPSYN2_01:xgluL#10001(17)
A2(95, 95) = A2(95, 95) - v(43); % source1:COMBO15_01:xgluL#10001(17)
A2(95, 37) = A2(95, 37) - v(193); % source1:PHETA1_02:xakg#10001(17)
%>>> xgluL#11000#
A2(96, 96) = v(333) + v(315) + v(274) + v(98) + v(24) + v(322) + v(147) + v(334) + v(333) + v(302) + v(187) + 0.25*v(1) + v(315) + v(315) + v(107) + v(249) + v(333) + v(279) + v(106) + v(283) + v(108) + v(333) + v(315); % drain :TYRTA_r_04:PHETA1_r_03:ACOTA_r_01:COMBO34_01:COMBO3_01:SDPTA_r_01:LEUTAi_01:VALTA_r_01:TYRTA_r_02:ILETA_r_01:COMBO47_01:BiomassEcoliGALUi_01:PHETA1_r_02:PHETA1_r_04:GLUDC_01:UNK3_01:TYRTA_r_01:ALATAL_r_01:GLNS_01:ASPTA_r_01:GLUDy_01:TYRTA_r_03:PHETA1_r_01 
A2(96, 96) = A2(96, 96) - v(124); % source1:GMPS2_01:xgluL#11000(3)
A2(96, 38) = A2(96, 38) - v(297); % source1:GLUDy_r_01:xakg#11000(3)
A2(96, 38) = A2(96, 38) - v(247); % source1:TYRTA_04:xakg#11000(3)
A2(96, 38) = A2(96, 38) - v(247); % source1:TYRTA_02:xakg#11000(3)
A2(96, 38) = A2(96, 38) - v(250); % source1:VALTA_01:xakg#11000(3)
A2(96, 38) = A2(96, 38) - 2*v(110); % source1:GLUSy_01:xakg#11000(3)
A2(96, 96) = A2(96, 96) - v(266); % source1:PEPTIDOSYN_02:xgluL#11000(3)
A2(96, 96) = A2(96, 96) - 2*v(265); % source1:LPSSYN_01:xgluL#11000(3)
A2(96, 96) = A2(96, 96) - 2*v(256); % source1:IMPSYN2_02:xgluL#11000(3)
A2(96, 93) = A2(96, 93) - 2*v(255); % source1:IMPSYN1_01:xgluL#00110(12)
A2(96, 38) = A2(96, 38) - v(247); % source1:TYRTA_03:xakg#11000(3)
A2(96, 38) = A2(96, 38) - v(193); % source1:PHETA1_01:xakg#11000(3)
A2(96, 38) = A2(96, 38) - v(30); % source1:ACOTA_01:xakg#11000(3)
A2(96, 38) = A2(96, 38) - v(22); % source1:COMBO2_01:xakg#11000(3)
A2(96, 96) = A2(96, 96) - v(266); % source1:PEPTIDOSYN_01:xgluL#11000(3)
A2(96, 38) = A2(96, 38) - v(51); % source1:ASPTA_01:xakg#11000(3)
A2(96, 38) = A2(96, 38) - v(21); % source1:ABTA_01:xakg#11000(3)
A2(96, 38) = A2(96, 38) - v(193); % source1:PHETA1_03:xakg#11000(3)
A2(96, 96) = A2(96, 96) - 2*v(255); % source1:IMPSYN1_02:xgluL#11000(3)
A2(96, 96) = A2(96, 96) - v(109); % source1:GLUN_01:xgluL#11000(3)
A2(96, 38) = A2(96, 38) - v(136); % source1:ILETA_01:xakg#11000(3)
A2(96, 96) = A2(96, 96) - 2*v(110); % source1:GLUSy_02:xgluL#11000(3)
A2(96, 7) = A2(96, 7) - v(182); % source1:P5CD_01:x1pyr5c#11000(3)
A2(96, 38) = A2(96, 38) - v(215); % source1:SDPTA_01:xakg#11000(3)
A2(96, 96) = A2(96, 96) - v(48); % source1:ASNS1_01:xgluL#11000(3)
A2(96, 96) = A2(96, 96) - v(254); % source1:CTPSYN_01:xgluL#11000(3)
A2(96, 38) = A2(96, 38) - v(41); % source1:ALATAL_01:xakg#11000(3)
A2(96, 38) = A2(96, 38) - v(247); % source1:TYRTA_01:xakg#11000(3)
A2(96, 38) = A2(96, 38) - v(22); % source1:COMBO2_02:xakg#11000(3)
A2(96, 38) = A2(96, 38) - v(193); % source1:PHETA1_04:xakg#11000(3)
A2(96, 96) = A2(96, 96) - v(54); % source1:CBPS_01:xgluL#11000(3)
A2(96, 96) = A2(96, 96) - 2*v(256); % source1:IMPSYN2_01:xgluL#11000(3)
A2(96, 96) = A2(96, 96) - v(43); % source1:COMBO15_01:xgluL#11000(3)
A2(96, 38) = A2(96, 38) - v(193); % source1:PHETA1_02:xakg#11000(3)
%>>> xglx#11#
A2(97, 97) = v(148) + 2*v(111) + v(117) + v(116); % drain :MALS_01:GLXCL_01:GLYCLTDy_01:GLYCLTDx_01 
A2(97, 105) = A2(97, 105) - v(120); % source1:GLYCTO4_01:xglyclt#11(3)
A2(97, 105) = A2(97, 105) - v(118); % source1:GLYCTO2_01:xglyclt#11(3)
A2(97, 111) = A2(97, 111) - v(135); % source1:ICL_01:xicit#110000(3)
A2(97, 105) = A2(97, 105) - v(119); % source1:GLYCTO3_01:xglyclt#11(3)
A2(97, 111) = A2(97, 111) - v(135); % source1:ICL_02:xicit#110000(3)
%>>> xgly#11#
A2(98, 98) = v(256) + v(255) + 0.582*v(1) + v(328) + v(256) + v(115) + v(255) + v(335); % drain :IMPSYN2_02:IMPSYN1_01:BiomassEcoliGALUi_01:THRAr_r_01:IMPSYN2_01:GLYCL_01:IMPSYN1_02:GHMT2_r_01 
A2(98, 158) = A2(98, 158) - v(236); % source1:THRAr_01:xthrL#1100(3)
A2(98, 158) = A2(98, 158) - v(112); % source1:COMBO37_01:xthrL#1100(3)
A2(98, 144) = A2(98, 144) - v(101); % source1:GHMT2_01:xserL#110(3)
%>>> xglyc#011#
A2(99, 99) = v(121) + v(113) + v(122) + v(122) + v(113) + v(121) + v(113) + v(113) + v(121) + v(121); % drain :GLYCt_02:GLYCDx_03:GLYK_01:GLYK_02:GLYCDx_01:GLYCt_01:GLYCDx_04:GLYCDx_02:GLYCt_04:GLYCt_03 
A2(99, 104) = A2(99, 104) - v(298); % source1:GLYCt_r_01:xglyce#110(3)
A2(99, 102) = A2(99, 102) - v(270); % source1:G3PP_01:xglyc3p#110(3)
A2(99, 103) = A2(99, 103) - v(298); % source1:GLYCt_r_02:xglyce#011(6)
A2(99, 104) = A2(99, 104) - v(298); % source1:GLYCt_r_04:xglyce#110(3)
A2(99, 101) = A2(99, 101) - v(270); % source1:G3PP_02:xglyc3p#011(6)
A2(99, 101) = A2(99, 101) - v(264); % source1:CLPNSYN_02:xglyc3p#011(6)
A2(99, 103) = A2(99, 103) - v(298); % source1:GLYCt_r_03:xglyce#011(6)
A2(99, 102) = A2(99, 102) - v(264); % source1:CLPNSYN_01:xglyc3p#110(3)
%>>> xglyc#110#
A2(100, 100) = v(121) + v(113) + v(122) + v(122) + v(113) + v(121) + v(113) + v(113) + v(121) + v(121); % drain :GLYCt_02:GLYCDx_03:GLYK_01:GLYK_02:GLYCDx_01:GLYCt_01:GLYCDx_04:GLYCDx_02:GLYCt_04:GLYCt_03 
A2(100, 103) = A2(100, 103) - v(298); % source1:GLYCt_r_01:xglyce#011(6)
A2(100, 101) = A2(100, 101) - v(270); % source1:G3PP_01:xglyc3p#011(6)
A2(100, 104) = A2(100, 104) - v(298); % source1:GLYCt_r_02:xglyce#110(3)
A2(100, 103) = A2(100, 103) - v(298); % source1:GLYCt_r_04:xglyce#011(6)
A2(100, 102) = A2(100, 102) - v(270); % source1:G3PP_02:xglyc3p#110(3)
A2(100, 102) = A2(100, 102) - v(264); % source1:CLPNSYN_02:xglyc3p#110(3)
A2(100, 104) = A2(100, 104) - v(298); % source1:GLYCt_r_03:xglyce#110(3)
A2(100, 101) = A2(100, 101) - v(264); % source1:CLPNSYN_01:xglyc3p#011(6)
%>>> xglyc3p#011#
A2(101, 101) = v(96) + v(260) + v(94) + 2*v(264) + v(270) + v(93) + v(95) + v(263) + v(270) + 2*v(264); % drain :G3PD7_01:CDPDAGSYN_01:G3PD5_01:CLPNSYN_02:G3PP_01:G3PD2_01:G3PD6_01:PGSYN_01:G3PP_02:CLPNSYN_01 
A2(101, 58) = A2(101, 58) - v(294); % source1:G3PD2_r_01:xdhap#011(6)
A2(101, 100) = A2(101, 100) - v(122); % source1:GLYK_01:xglyc#110(3)
A2(101, 99) = A2(101, 99) - v(122); % source1:GLYK_02:xglyc#011(6)
%>>> xglyc3p#110#
A2(102, 102) = v(96) + v(260) + v(94) + 2*v(264) + v(270) + v(93) + v(95) + v(263) + v(270) + 2*v(264); % drain :G3PD7_01:CDPDAGSYN_01:G3PD5_01:CLPNSYN_02:G3PP_01:G3PD2_01:G3PD6_01:PGSYN_01:G3PP_02:CLPNSYN_01 
A2(102, 59) = A2(102, 59) - v(294); % source1:G3PD2_r_01:xdhap#110(3)
A2(102, 99) = A2(102, 99) - v(122); % source1:GLYK_01:xglyc#011(6)
A2(102, 100) = A2(102, 100) - v(122); % source1:GLYK_02:xglyc#110(3)
%>>> xglyce#011#
A2(103, 103) = v(298) + v(8) + v(298) + v(8) + v(298) + v(298); % drain :GLYCt_r_01:EX_glyc_01:GLYCt_r_02:EX_glyc_02:GLYCt_r_04:GLYCt_r_03 
A2(103, 99) = A2(103, 99) - v(121); % source1:GLYCt_02:xglyc#011(6)
A2(103, 100) = A2(103, 100) - v(121); % source1:GLYCt_04:xglyc#110(3)
A2(103, 99) = A2(103, 99) - v(121); % source1:GLYCt_03:xglyc#011(6)
A2(103, 100) = A2(103, 100) - v(121); % source1:GLYCt_01:xglyc#110(3)
%>>> xglyce#110#
A2(104, 104) = v(298) + v(8) + v(298) + v(8) + v(298) + v(298); % drain :GLYCt_r_01:EX_glyc_01:GLYCt_r_02:EX_glyc_02:GLYCt_r_04:GLYCt_r_03 
A2(104, 100) = A2(104, 100) - v(121); % source1:GLYCt_02:xglyc#110(3)
A2(104, 99) = A2(104, 99) - v(121); % source1:GLYCt_04:xglyc#011(6)
A2(104, 100) = A2(104, 100) - v(121); % source1:GLYCt_03:xglyc#110(3)
A2(104, 99) = A2(104, 99) - v(121); % source1:GLYCt_01:xglyc#011(6)
%>>> xglyclt#11#
A2(105, 105) = v(120) + v(118) + v(119); % drain :GLYCTO4_01:GLYCTO2_01:GLYCTO3_01 
A2(105, 132) = A2(105, 132) - v(269); % source1:THFSYN_01:xr5p#00011(24)
A2(105, 97) = A2(105, 97) - v(117); % source1:GLYCLTDy_01:xglx#11(3)
A2(105, 97) = A2(105, 97) - v(116); % source1:GLYCLTDx_01:xglx#11(3)
%>>> xicit#000110#
A2(106, 106) = v(273) + v(135) + v(134) + v(135); % drain :rACONT_r_01:ICL_01:ICDHyr_01:ICL_02 
A2(106, 34) = A2(106, 34) - v(301); % source1:ICDHyr_r_01:xakg#00011(24)
A2(106, 50) = A2(106, 50) - v(29); % source1:rACONT_01:xcit#000110(24)
%>>> xicit#001001#
A2(107, 107) = v(273) + v(135) + v(134) + v(135); % drain :rACONT_r_01:ICL_01:ICDHyr_01:ICL_02 
B2(107,:) = B2(107,:) + conv(x1(56,:), x1(80,:)) * v(301); % source2:ICDHyr_r_01:xakg#00100(4):xco2#1(1)
A2(107, 51) = A2(107, 51) - v(29); % source1:rACONT_01:xcit#001001(36)
%>>> xicit#001100#
A2(108, 108) = v(273) + v(135) + v(134) + v(135); % drain :rACONT_r_01:ICL_01:ICDHyr_01:ICL_02 
A2(108, 35) = A2(108, 35) - v(301); % source1:ICDHyr_r_01:xakg#00110(12)
A2(108, 52) = A2(108, 52) - v(29); % source1:rACONT_01:xcit#001100(12)
%>>> xicit#011000#
A2(109, 109) = v(273) + v(135) + v(134) + v(135); % drain :rACONT_r_01:ICL_01:ICDHyr_01:ICL_02 
A2(109, 36) = A2(109, 36) - v(301); % source1:ICDHyr_r_01:xakg#01100(6)
A2(109, 53) = A2(109, 53) - v(29); % source1:rACONT_01:xcit#011000(6)
%>>> xicit#100010#
A2(110, 110) = v(273) + v(135) + v(134) + v(135); % drain :rACONT_r_01:ICL_01:ICDHyr_01:ICL_02 
A2(110, 37) = A2(110, 37) - v(301); % source1:ICDHyr_r_01:xakg#10001(17)
A2(110, 54) = A2(110, 54) - v(29); % source1:rACONT_01:xcit#100010(17)
%>>> xicit#110000#
A2(111, 111) = v(273) + v(135) + v(134) + v(135); % drain :rACONT_r_01:ICL_01:ICDHyr_01:ICL_02 
A2(111, 38) = A2(111, 38) - v(301); % source1:ICDHyr_r_01:xakg#11000(3)
A2(111, 55) = A2(111, 55) - v(29); % source1:rACONT_01:xcit#110000(3)
%>>> xlacD#011#
A2(112, 112) = v(285) + v(146) + v(145); % drain :DLACt2_r_01:LDHD2_01:LDHD_01 
A2(112, 130) = A2(112, 130) - v(306); % source1:LDHD_r_01:xpyr#011(6)
A2(112, 59) = A2(112, 59) - v(123); % source1:COMBO38_01:xdhap#110(3)
A2(112, 112) = A2(112, 112) - v(65); % source1:DLACt2_01:xlacD#011(6)
%>>> xlacD#110#
A2(113, 113) = v(285) + v(146) + v(145); % drain :DLACt2_r_01:LDHD2_01:LDHD_01 
A2(113, 131) = A2(113, 131) - v(306); % source1:LDHD_r_01:xpyr#110(3)
A2(113, 58) = A2(113, 58) - v(123); % source1:COMBO38_01:xdhap#011(6)
A2(113, 113) = A2(113, 113) - v(65); % source1:DLACt2_01:xlacD#110(3)
%>>> xmalL#0011#
A2(114, 114) = v(293) + v(151) + v(149) + v(152) + v(293) + v(153) + v(150); % drain :rFUM_r_02:MDH3_01:MDH_01:ME1_01:rFUM_r_01:ME2_01:MDH2_01 
A2(114, 20) = A2(114, 20) - v(148); % source1:MALS_01:xaccoa#11(3)
A2(114, 117) = A2(114, 117) - v(307); % source1:MDH_r_01:xoaa#0011(12)
A2(114, 73) = A2(114, 73) - v(89); % source1:rFUM_01:xfum#1100(3)
A2(114, 71) = A2(114, 71) - v(89); % source1:rFUM_02:xfum#0011(12)
%>>> xmalL#0110#
A2(115, 115) = v(293) + v(151) + v(149) + v(152) + v(293) + v(153) + v(150); % drain :rFUM_r_02:MDH3_01:MDH_01:ME1_01:rFUM_r_01:ME2_01:MDH2_01 
B2(115,:) = B2(115,:) + conv(x1(142,:), x1(36,:)) * v(148); % source2:MALS_01:xglx#01(2):xaccoa#01(2)
A2(115, 118) = A2(115, 118) - v(307); % source1:MDH_r_01:xoaa#0110(6)
A2(115, 72) = A2(115, 72) - v(89); % source1:rFUM_01:xfum#0110(6)
A2(115, 72) = A2(115, 72) - v(89); % source1:rFUM_02:xfum#0110(6)
%>>> xmalL#1100#
A2(116, 116) = v(293) + v(151) + v(149) + v(152) + v(293) + v(153) + v(150); % drain :rFUM_r_02:MDH3_01:MDH_01:ME1_01:rFUM_r_01:ME2_01:MDH2_01 
A2(116, 97) = A2(116, 97) - v(148); % source1:MALS_01:xglx#11(3)
A2(116, 119) = A2(116, 119) - v(307); % source1:MDH_r_01:xoaa#1100(3)
A2(116, 71) = A2(116, 71) - v(89); % source1:rFUM_01:xfum#0011(12)
A2(116, 73) = A2(116, 73) - v(89); % source1:rFUM_02:xfum#1100(3)
%>>> xoaa#0011#
A2(117, 117) = v(307) + v(283) + v(58) + v(199); % drain :MDH_r_01:ASPTA_r_01:CS_01:PPCK_01 
B2(117,:) = B2(117,:) + conv(x1(80,:), x1(183,:)) * v(198); % source2:PPC_01:xco2#1(1):xpep#001(4)
A2(117, 114) = A2(117, 114) - v(151); % source1:MDH3_01:xmalL#0011(12)
A2(117, 114) = A2(117, 114) - v(149); % source1:MDH_01:xmalL#0011(12)
A2(117, 44) = A2(117, 44) - v(51); % source1:ASPTA_01:xaspL#0011(12)
A2(117, 114) = A2(117, 114) - v(150); % source1:MDH2_01:xmalL#0011(12)
%>>> xoaa#0110#
A2(118, 118) = v(307) + v(283) + v(58) + v(199); % drain :MDH_r_01:ASPTA_r_01:CS_01:PPCK_01 
A2(118, 123) = A2(118, 123) - v(198); % source1:PPC_01:xpep#011(6)
A2(118, 115) = A2(118, 115) - v(151); % source1:MDH3_01:xmalL#0110(6)
A2(118, 115) = A2(118, 115) - v(149); % source1:MDH_01:xmalL#0110(6)
A2(118, 45) = A2(118, 45) - v(51); % source1:ASPTA_01:xaspL#0110(6)
A2(118, 115) = A2(118, 115) - v(150); % source1:MDH2_01:xmalL#0110(6)
%>>> xoaa#1100#
A2(119, 119) = v(307) + v(283) + v(58) + v(199); % drain :MDH_r_01:ASPTA_r_01:CS_01:PPCK_01 
A2(119, 124) = A2(119, 124) - v(198); % source1:PPC_01:xpep#110(3)
A2(119, 116) = A2(119, 116) - v(151); % source1:MDH3_01:xmalL#1100(3)
A2(119, 116) = A2(119, 116) - v(149); % source1:MDH_01:xmalL#1100(3)
A2(119, 46) = A2(119, 46) - v(51); % source1:ASPTA_01:xaspL#1100(3)
A2(119, 116) = A2(119, 116) - v(150); % source1:MDH2_01:xmalL#1100(3)
%>>> xorn#00011#
A2(120, 120) = v(181) + v(179) + v(181); % drain :ORNDC_01:OCBT_01:ORNDC_02 
A2(120, 120) = A2(120, 120) - v(310); % source1:OCBT_r_01:xorn#00011(24)
A2(120, 28) = A2(120, 28) - v(28); % source1:ACODA_01:xacg5sa#0001100(24)
%>>> xorn#00110#
A2(121, 121) = v(181) + v(179) + v(181); % drain :ORNDC_01:OCBT_01:ORNDC_02 
A2(121, 121) = A2(121, 121) - v(310); % source1:OCBT_r_01:xorn#00110(12)
A2(121, 29) = A2(121, 29) - v(28); % source1:ACODA_01:xacg5sa#0011000(12)
%>>> xorn#01100#
A2(122, 122) = v(181) + v(179) + v(181); % drain :ORNDC_01:OCBT_01:ORNDC_02 
A2(122, 122) = A2(122, 122) - v(310); % source1:OCBT_r_01:xorn#01100(6)
A2(122, 30) = A2(122, 30) - v(28); % source1:ACODA_01:xacg5sa#0110000(6)
%>>> xpep#011#
A2(123, 123) = v(288) + v(198) + v(205) + v(207) + v(70) + v(266) + v(68) + v(266) + v(105) + 5*v(265) + v(70); % drain :ENO_r_01:PPC_01:PSCVT_01:PYK_01:DHAPT_02:PEPTIDOSYN_01:COMBO25_01:PEPTIDOSYN_02:GLCpts_01:LPSSYN_01:DHAPT_01 
A2(123, 123) = A2(123, 123) - v(317); % source1:PSCVT_r_01:xpep#011(6)
A2(123, 8) = A2(123, 8) - v(77); % source1:ENO_01:x2pg#011(6)
A2(123, 130) = A2(123, 130) - v(202); % source1:PPS_01:xpyr#011(6)
A2(123, 118) = A2(123, 118) - v(199); % source1:PPCK_01:xoaa#0110(6)
%>>> xpep#110#
A2(124, 124) = v(288) + v(198) + v(205) + v(207) + v(70) + v(266) + v(68) + v(266) + v(105) + 5*v(265) + v(70); % drain :ENO_r_01:PPC_01:PSCVT_01:PYK_01:DHAPT_02:PEPTIDOSYN_01:COMBO25_01:PEPTIDOSYN_02:GLCpts_01:LPSSYN_01:DHAPT_01 
A2(124, 124) = A2(124, 124) - v(317); % source1:PSCVT_r_01:xpep#110(3)
A2(124, 9) = A2(124, 9) - v(77); % source1:ENO_01:x2pg#110(3)
A2(124, 131) = A2(124, 131) - v(202); % source1:PPS_01:xpyr#110(3)
A2(124, 119) = A2(124, 119) - v(199); % source1:PPCK_01:xoaa#1100(3)
%>>> xpheL#110000000#
A2(125, 125) = v(193) + 0.176*v(1) + v(193) + v(193) + v(193); % drain :PHETA1_04:BiomassEcoliGALUi_01:PHETA1_02:PHETA1_03:PHETA1_01 
A2(125, 126) = A2(125, 126) - v(315); % source1:PHETA1_r_02:xphpyr#110000000(3)
A2(125, 126) = A2(125, 126) - v(315); % source1:PHETA1_r_04:xphpyr#110000000(3)
A2(125, 126) = A2(125, 126) - v(315); % source1:PHETA1_r_03:xphpyr#110000000(3)
A2(125, 126) = A2(125, 126) - v(315); % source1:PHETA1_r_01:xphpyr#110000000(3)
%>>> xphpyr#110000000#
A2(126, 126) = v(315) + v(315) + v(315) + v(315); % drain :PHETA1_r_02:PHETA1_r_04:PHETA1_r_03:PHETA1_r_01 
A2(126, 124) = A2(126, 124) - v(201); % source1:PPNDH_02:xpep#110(3)
A2(126, 125) = A2(126, 125) - v(193); % source1:PHETA1_04:xpheL#110000000(3)
A2(126, 125) = A2(126, 125) - v(193); % source1:PHETA1_02:xpheL#110000000(3)
A2(126, 125) = A2(126, 125) - v(193); % source1:PHETA1_03:xpheL#110000000(3)
A2(126, 125) = A2(126, 125) - v(193); % source1:PHETA1_01:xpheL#110000000(3)
A2(126, 124) = A2(126, 124) - v(201); % source1:PPNDH_01:xpep#110(3)
%>>> xptrc#0011#
A2(127, 127) = v(22) + v(36) + 0.035*v(1) + v(36) + v(22); % drain :COMBO2_01:COMBOSPMD_02:BiomassEcoliGALUi_01:COMBOSPMD_01:COMBO2_02 
A2(127, 122) = A2(127, 122) - v(181); % source1:ORNDC_01:xorn#01100(6)
A2(127, 120) = A2(127, 120) - v(181); % source1:ORNDC_02:xorn#00011(24)
%>>> xptrc#0110#
A2(128, 128) = v(22) + v(36) + 0.035*v(1) + v(36) + v(22); % drain :COMBO2_01:COMBOSPMD_02:BiomassEcoliGALUi_01:COMBOSPMD_01:COMBO2_02 
A2(128, 121) = A2(128, 121) - v(181); % source1:ORNDC_01:xorn#00110(12)
A2(128, 121) = A2(128, 121) - v(181); % source1:ORNDC_02:xorn#00110(12)
%>>> xptrc#1100#
A2(129, 129) = v(22) + v(36) + 0.035*v(1) + v(36) + v(22); % drain :COMBO2_01:COMBOSPMD_02:BiomassEcoliGALUi_01:COMBOSPMD_01:COMBO2_02 
A2(129, 120) = A2(129, 120) - v(181); % source1:ORNDC_01:xorn#00011(24)
A2(129, 122) = A2(129, 122) - v(181); % source1:ORNDC_02:xorn#01100(6)
%>>> xpyr#011#
A2(130, 130) = v(306) + v(184) + v(25) + 2*v(27) + v(202) + v(196) + v(71) + v(279) + v(332) + v(319) + v(186); % drain :LDHD_r_01:PDH_01:COMBO4_01:COMBO5_01:PPS_01:POX_01:COMBO26_01:ALATAL_r_01:TRPAS2_r_01:PYRt2r_r_01:PFL_01 
A2(130, 123) = A2(130, 123) - v(269); % source1:THFSYN_01:xpep#011(6)
A2(130, 39) = A2(130, 39) - v(41); % source1:ALATAL_01:xalaL#011(6)
A2(130, 123) = A2(130, 123) - v(105); % source1:GLCpts_01:xpep#011(6)
A2(130, 130) = A2(130, 130) - v(208); % source1:PYRt2r_01:xpyr#011(6)
A2(130, 85) = A2(130, 85) - v(75); % source1:EDA_01:xg6p#011000(6)
A2(130, 112) = A2(130, 112) - v(145); % source1:LDHD_01:xlacD#011(6)
A2(130, 115) = A2(130, 115) - v(153); % source1:ME2_01:xmalL#0110(6)
A2(130, 123) = A2(130, 123) - v(207); % source1:PYK_01:xpep#011(6)
A2(130, 123) = A2(130, 123) - v(43); % source1:COMBO15_01:xpep#011(6)
A2(130, 123) = A2(130, 123) - v(70); % source1:DHAPT_02:xpep#011(6)
A2(130, 159) = A2(130, 159) - v(242); % source1:TRPAS2_01:xtrpL#01100000000(6)
A2(130, 143) = A2(130, 143) - v(61); % source1:COMBO22_02:xserL#011(6)
A2(130, 143) = A2(130, 143) - v(217); % source1:SERDL_01:xserL#011(6)
A2(130, 143) = A2(130, 143) - v(59); % source1:CYSDS_01:xserL#011(6)
A2(130, 115) = A2(130, 115) - v(152); % source1:ME1_01:xmalL#0110(6)
A2(130, 143) = A2(130, 143) - v(61); % source1:COMBO22_01:xserL#011(6)
A2(130, 112) = A2(130, 112) - v(146); % source1:LDHD2_01:xlacD#011(6)
A2(130, 123) = A2(130, 123) - v(70); % source1:DHAPT_01:xpep#011(6)
%>>> xpyr#110#
A2(131, 131) = v(306) + v(184) + v(25) + 2*v(27) + v(202) + v(196) + v(71) + v(279) + v(332) + v(319) + v(186); % drain :LDHD_r_01:PDH_01:COMBO4_01:COMBO5_01:PPS_01:POX_01:COMBO26_01:ALATAL_r_01:TRPAS2_r_01:PYRt2r_r_01:PFL_01 
A2(131, 124) = A2(131, 124) - v(269); % source1:THFSYN_01:xpep#110(3)
A2(131, 40) = A2(131, 40) - v(41); % source1:ALATAL_01:xalaL#110(3)
A2(131, 124) = A2(131, 124) - v(105); % source1:GLCpts_01:xpep#110(3)
A2(131, 131) = A2(131, 131) - v(208); % source1:PYRt2r_01:xpyr#110(3)
A2(131, 86) = A2(131, 86) - v(75); % source1:EDA_01:xg6p#110000(3)
A2(131, 113) = A2(131, 113) - v(145); % source1:LDHD_01:xlacD#110(3)
A2(131, 116) = A2(131, 116) - v(153); % source1:ME2_01:xmalL#1100(3)
A2(131, 124) = A2(131, 124) - v(207); % source1:PYK_01:xpep#110(3)
A2(131, 124) = A2(131, 124) - v(43); % source1:COMBO15_01:xpep#110(3)
A2(131, 124) = A2(131, 124) - v(70); % source1:DHAPT_02:xpep#110(3)
A2(131, 160) = A2(131, 160) - v(242); % source1:TRPAS2_01:xtrpL#11000000000(3)
A2(131, 144) = A2(131, 144) - v(61); % source1:COMBO22_02:xserL#110(3)
A2(131, 144) = A2(131, 144) - v(217); % source1:SERDL_01:xserL#110(3)
A2(131, 144) = A2(131, 144) - v(59); % source1:CYSDS_01:xserL#110(3)
A2(131, 116) = A2(131, 116) - v(152); % source1:ME1_01:xmalL#1100(3)
A2(131, 144) = A2(131, 144) - v(61); % source1:COMBO22_01:xserL#110(3)
A2(131, 113) = A2(131, 113) - v(146); % source1:LDHD2_01:xlacD#110(3)
A2(131, 124) = A2(131, 124) - v(70); % source1:DHAPT_01:xpep#110(3)
%>>> xr5p#00011#
A2(132, 132) = v(213) + v(204) + v(238); % drain :RPI_01:PRPPS_01:TKT1_01 
A2(132, 135) = A2(132, 135) - v(321); % source1:RPI_r_01:xru5pD#00011(24)
A2(132, 138) = A2(132, 138) - v(329); % source1:TKT1_r_01:xs7p#0000011(96)
A2(132, 132) = A2(132, 132) - v(316); % source1:PRPPS_r_01:xr5p#00011(24)
%>>> xr5p#00110#
A2(133, 133) = v(213) + v(204) + v(238); % drain :RPI_01:PRPPS_01:TKT1_01 
A2(133, 136) = A2(133, 136) - v(321); % source1:RPI_r_01:xru5pD#00110(12)
A2(133, 139) = A2(133, 139) - v(329); % source1:TKT1_r_01:xs7p#0000110(48)
A2(133, 133) = A2(133, 133) - v(316); % source1:PRPPS_r_01:xr5p#00110(12)
%>>> xr5p#11000#
A2(134, 134) = v(213) + v(204) + v(238); % drain :RPI_01:PRPPS_01:TKT1_01 
A2(134, 137) = A2(134, 137) - v(321); % source1:RPI_r_01:xru5pD#11000(3)
A2(134, 140) = A2(134, 140) - v(329); % source1:TKT1_r_01:xs7p#0011000(12)
A2(134, 134) = A2(134, 134) - v(316); % source1:PRPPS_r_01:xr5p#11000(3)
%>>> xru5pD#00011#
A2(135, 135) = v(321) + v(212) + 2*v(259) + 2*v(259) + 5*v(265) + 2*v(259); % drain :RPI_r_01:RPE_01:FADSYN_02:FADSYN_01:LPSSYN_01:FADSYN_03 
A2(135, 132) = A2(135, 132) - v(213); % source1:RPI_01:xr5p#00011(24)
A2(135, 83) = A2(135, 83) - v(125); % source1:GND_01:xg6p#000011(48)
A2(135, 162) = A2(135, 162) - v(320); % source1:RPE_r_01:xxu5pD#00011(24)
%>>> xru5pD#00110#
A2(136, 136) = v(321) + v(212) + 2*v(259) + 2*v(259) + 5*v(265) + 2*v(259); % drain :RPI_r_01:RPE_01:FADSYN_02:FADSYN_01:LPSSYN_01:FADSYN_03 
A2(136, 133) = A2(136, 133) - v(213); % source1:RPI_01:xr5p#00110(12)
A2(136, 84) = A2(136, 84) - v(125); % source1:GND_01:xg6p#000110(24)
A2(136, 163) = A2(136, 163) - v(320); % source1:RPE_r_01:xxu5pD#00110(12)
%>>> xru5pD#11000#
A2(137, 137) = v(321) + v(212) + 2*v(259) + 2*v(259) + 5*v(265) + 2*v(259); % drain :RPI_r_01:RPE_01:FADSYN_02:FADSYN_01:LPSSYN_01:FADSYN_03 
A2(137, 134) = A2(137, 134) - v(213); % source1:RPI_01:xr5p#11000(3)
A2(137, 85) = A2(137, 85) - v(125); % source1:GND_01:xg6p#011000(6)
A2(137, 164) = A2(137, 164) - v(320); % source1:RPE_r_01:xxu5pD#11000(3)
%>>> xs7p#0000011#
A2(138, 138) = v(329) + 3*v(265) + v(232); % drain :TKT1_r_01:LPSSYN_01:TALA_01 
A2(138, 60) = A2(138, 60) - v(327); % source1:TALA_r_01:xe4p#0011(12)
A2(138, 132) = A2(138, 132) - v(238); % source1:TKT1_01:xr5p#00011(24)
%>>> xs7p#0000110#
A2(139, 139) = v(329) + 3*v(265) + v(232); % drain :TKT1_r_01:LPSSYN_01:TALA_01 
A2(139, 61) = A2(139, 61) - v(327); % source1:TALA_r_01:xe4p#0110(6)
A2(139, 133) = A2(139, 133) - v(238); % source1:TKT1_01:xr5p#00110(12)
%>>> xs7p#0011000#
A2(140, 140) = v(329) + 3*v(265) + v(232); % drain :TKT1_r_01:LPSSYN_01:TALA_01 
B2(140,:) = B2(140,:) + conv(x1(93,:), x1(99,:)) * v(327); % source2:TALA_r_01:xe4p#1000(1):xf6p#001000(4)
A2(140, 134) = A2(140, 134) - v(238); % source1:TKT1_01:xr5p#11000(3)
%>>> xs7p#0110000#
A2(141, 141) = v(329) + 3*v(265) + v(232); % drain :TKT1_r_01:LPSSYN_01:TALA_01 
A2(141, 65) = A2(141, 65) - v(327); % source1:TALA_r_01:xf6p#011000(6)
B2(141,:) = B2(141,:) + conv(x1(197,:), x1(242,:)) * v(238); % source2:TKT1_01:xr5p#10000(1):xxu5pD#01000(2)
%>>> xs7p#1100000#
A2(142, 142) = v(329) + 3*v(265) + v(232); % drain :TKT1_r_01:LPSSYN_01:TALA_01 
A2(142, 66) = A2(142, 66) - v(327); % source1:TALA_r_01:xf6p#110000(3)
A2(142, 164) = A2(142, 164) - v(238); % source1:TKT1_01:xxu5pD#11000(3)
%>>> xserL#011#
A2(143, 143) = v(217) + v(261) + v(216) + 0.205*v(1) + v(244) + v(101) + v(262) + v(243); % drain :SERDL_01:PSSYN_01:SERAT_01:BiomassEcoliGALUi_01:TRPS2_01:GHMT2_01:PESYN_01:TRPS1_01 
A2(143, 143) = A2(143, 143) - v(323); % source1:SERAT_r_01:xserL#011(6)
B2(143,:) = B2(143,:) + conv(x1(144,:), x1(173,:)) * v(335); % source2:GHMT2_r_01:xgly#01(2):xmlthf#1(1)
A2(143, 11) = A2(143, 11) - v(187); % source1:COMBO47_01:x3pg#011(6)
%>>> xserL#110#
A2(144, 144) = v(217) + v(261) + v(216) + 0.205*v(1) + v(244) + v(101) + v(262) + v(243); % drain :SERDL_01:PSSYN_01:SERAT_01:BiomassEcoliGALUi_01:TRPS2_01:GHMT2_01:PESYN_01:TRPS1_01 
A2(144, 144) = A2(144, 144) - v(323); % source1:SERAT_r_01:xserL#110(3)
A2(144, 98) = A2(144, 98) - v(335); % source1:GHMT2_r_01:xgly#11(3)
A2(144, 12) = A2(144, 12) - v(187); % source1:COMBO47_01:x3pg#110(3)
%>>> xsl2a6o#00000000011#
A2(145, 145) = v(322); % drain :SDPTA_r_01 
A2(145, 145) = A2(145, 145) - v(215); % source1:SDPTA_01:xsl2a6o#00000000011(1536)
A2(145, 154) = A2(145, 154) - v(71); % source1:COMBO26_01:xsuccoa#0011(12)
%>>> xsl2a6o#00000000110#
A2(146, 146) = v(322); % drain :SDPTA_r_01 
A2(146, 146) = A2(146, 146) - v(215); % source1:SDPTA_01:xsl2a6o#00000000110(768)
A2(146, 155) = A2(146, 155) - v(71); % source1:COMBO26_01:xsuccoa#0110(6)
%>>> xsl2a6o#00000001100#
A2(147, 147) = v(322); % drain :SDPTA_r_01 
A2(147, 147) = A2(147, 147) - v(215); % source1:SDPTA_01:xsl2a6o#00000001100(384)
A2(147, 156) = A2(147, 156) - v(71); % source1:COMBO26_01:xsuccoa#1100(3)
%>>> xsucc#0011#
A2(148, 148) = v(229) + v(226) + v(228) + v(228) + v(225) + v(228) + v(225) + v(228) + v(228) + v(228) + v(228) + v(228) + v(228) + v(226) + v(228) + v(225) + v(228) + v(226) + v(228) + v(228) + v(228) + v(228) + v(228) + v(226) + v(225) + v(229); % drain :SUCOAS_02:SUCD1i_04:SUCFUMt_15:SUCFUMt_08:SUCCt2b_04:SUCFUMt_12:SUCCt2b_02:SUCFUMt_10:SUCFUMt_02:SUCFUMt_13:SUCFUMt_09:SUCFUMt_01:SUCFUMt_06:SUCD1i_03:SUCFUMt_03:SUCCt2b_03:SUCFUMt_14:SUCD1i_01:SUCFUMt_07:SUCFUMt_11:SUCFUMt_05:SUCFUMt_16:SUCFUMt_04:SUCD1i_02:SUCCt2b_01:SUCOAS_01 
A2(148, 153) = A2(148, 153) - v(325); % source1:SUCFUMt_r_11:xsucce#1100(3)
A2(148, 151) = A2(148, 151) - v(325); % source1:SUCFUMt_r_07:xsucce#0011(12)
A2(148, 71) = A2(148, 71) - v(87); % source1:FRD3_01:xfum#0011(12)
A2(148, 156) = A2(148, 156) - v(326); % source1:SUCOAS_r_01:xsuccoa#1100(3)
A2(148, 153) = A2(148, 153) - v(325); % source1:SUCFUMt_r_06:xsucce#1100(3)
A2(148, 71) = A2(148, 71) - v(87); % source1:FRD3_04:xfum#0011(12)
A2(148, 151) = A2(148, 151) - v(223); % source1:SUCCt22_03:xsucce#0011(12)
A2(148, 153) = A2(148, 153) - v(325); % source1:SUCFUMt_r_05:xsucce#1100(3)
A2(148, 147) = A2(148, 147) - v(214); % source1:SDPDS_02:xsl2a6o#00000001100(384)
A2(148, 151) = A2(148, 151) - v(325); % source1:SUCFUMt_r_16:xsucce#0011(12)
A2(148, 153) = A2(148, 153) - v(223); % source1:SUCCt22_04:xsucce#1100(3)
A2(148, 151) = A2(148, 151) - v(325); % source1:SUCFUMt_r_08:xsucce#0011(12)
A2(148, 13) = A2(148, 13) - v(221); % source1:SSALy_02:x4abut#0011(12)
A2(148, 145) = A2(148, 145) - v(214); % source1:SDPDS_03:xsl2a6o#00000000011(1536)
A2(148, 153) = A2(148, 153) - v(224); % source1:SUCCt23_04:xsucce#1100(3)
A2(148, 151) = A2(148, 151) - v(325); % source1:SUCFUMt_r_09:xsucce#0011(12)
A2(148, 151) = A2(148, 151) - v(224); % source1:SUCCt23_03:xsucce#0011(12)
A2(148, 151) = A2(148, 151) - v(222); % source1:SUCCabc_03:xsucce#0011(12)
A2(148, 153) = A2(148, 153) - v(325); % source1:SUCFUMt_r_14:xsucce#1100(3)
A2(148, 154) = A2(148, 154) - v(61); % source1:COMBO22_02:xsuccoa#0011(12)
A2(148, 151) = A2(148, 151) - v(224); % source1:SUCCt23_02:xsucce#0011(12)
A2(148, 13) = A2(148, 13) - v(220); % source1:SSALx_02:x4abut#0011(12)
A2(148, 153) = A2(148, 153) - v(325); % source1:SUCFUMt_r_04:xsucce#1100(3)
A2(148, 106) = A2(148, 106) - v(135); % source1:ICL_02:xicit#000110(24)
A2(148, 153) = A2(148, 153) - v(222); % source1:SUCCabc_04:xsucce#1100(3)
A2(148, 73) = A2(148, 73) - v(86); % source1:FRD2_03:xfum#1100(3)
A2(148, 15) = A2(148, 15) - v(221); % source1:SSALy_01:x4abut#1100(3)
A2(148, 153) = A2(148, 153) - v(223); % source1:SUCCt22_01:xsucce#1100(3)
A2(148, 151) = A2(148, 151) - v(222); % source1:SUCCabc_02:xsucce#0011(12)
A2(148, 153) = A2(148, 153) - v(224); % source1:SUCCt23_01:xsucce#1100(3)
A2(148, 151) = A2(148, 151) - v(325); % source1:SUCFUMt_r_01:xsucce#0011(12)
A2(148, 145) = A2(148, 145) - v(214); % source1:SDPDS_01:xsl2a6o#00000000011(1536)
A2(148, 153) = A2(148, 153) - v(325); % source1:SUCFUMt_r_13:xsucce#1100(3)
A2(148, 73) = A2(148, 73) - v(87); % source1:FRD3_03:xfum#1100(3)
A2(148, 15) = A2(148, 15) - v(220); % source1:SSALx_01:x4abut#1100(3)
A2(148, 151) = A2(148, 151) - v(325); % source1:SUCFUMt_r_15:xsucce#0011(12)
A2(148, 151) = A2(148, 151) - v(325); % source1:SUCFUMt_r_02:xsucce#0011(12)
A2(148, 153) = A2(148, 153) - v(222); % source1:SUCCabc_01:xsucce#1100(3)
A2(148, 153) = A2(148, 153) - v(325); % source1:SUCFUMt_r_03:xsucce#1100(3)
A2(148, 107) = A2(148, 107) - v(135); % source1:ICL_01:xicit#001001(36)
A2(148, 153) = A2(148, 153) - v(325); % source1:SUCFUMt_r_12:xsucce#1100(3)
A2(148, 147) = A2(148, 147) - v(214); % source1:SDPDS_04:xsl2a6o#00000001100(384)
A2(148, 71) = A2(148, 71) - v(86); % source1:FRD2_04:xfum#0011(12)
A2(148, 73) = A2(148, 73) - v(87); % source1:FRD3_02:xfum#1100(3)
A2(148, 154) = A2(148, 154) - v(326); % source1:SUCOAS_r_02:xsuccoa#0011(12)
A2(148, 71) = A2(148, 71) - v(86); % source1:FRD2_01:xfum#0011(12)
A2(148, 156) = A2(148, 156) - v(61); % source1:COMBO22_01:xsuccoa#1100(3)
A2(148, 151) = A2(148, 151) - v(223); % source1:SUCCt22_02:xsucce#0011(12)
A2(148, 73) = A2(148, 73) - v(86); % source1:FRD2_02:xfum#1100(3)
A2(148, 151) = A2(148, 151) - v(325); % source1:SUCFUMt_r_10:xsucce#0011(12)
%>>> xsucc#0110#
A2(149, 149) = v(229) + v(226) + v(228) + v(228) + v(225) + v(228) + v(225) + v(228) + v(228) + v(228) + v(228) + v(228) + v(228) + v(226) + v(228) + v(225) + v(228) + v(226) + v(228) + v(228) + v(228) + v(228) + v(228) + v(226) + v(225) + v(229); % drain :SUCOAS_02:SUCD1i_04:SUCFUMt_15:SUCFUMt_08:SUCCt2b_04:SUCFUMt_12:SUCCt2b_02:SUCFUMt_10:SUCFUMt_02:SUCFUMt_13:SUCFUMt_09:SUCFUMt_01:SUCFUMt_06:SUCD1i_03:SUCFUMt_03:SUCCt2b_03:SUCFUMt_14:SUCD1i_01:SUCFUMt_07:SUCFUMt_11:SUCFUMt_05:SUCFUMt_16:SUCFUMt_04:SUCD1i_02:SUCCt2b_01:SUCOAS_01 
A2(149, 152) = A2(149, 152) - v(325); % source1:SUCFUMt_r_11:xsucce#0110(6)
A2(149, 152) = A2(149, 152) - v(325); % source1:SUCFUMt_r_07:xsucce#0110(6)
A2(149, 72) = A2(149, 72) - v(87); % source1:FRD3_01:xfum#0110(6)
A2(149, 155) = A2(149, 155) - v(326); % source1:SUCOAS_r_01:xsuccoa#0110(6)
A2(149, 152) = A2(149, 152) - v(325); % source1:SUCFUMt_r_06:xsucce#0110(6)
A2(149, 72) = A2(149, 72) - v(87); % source1:FRD3_04:xfum#0110(6)
A2(149, 152) = A2(149, 152) - v(223); % source1:SUCCt22_03:xsucce#0110(6)
A2(149, 152) = A2(149, 152) - v(325); % source1:SUCFUMt_r_05:xsucce#0110(6)
A2(149, 146) = A2(149, 146) - v(214); % source1:SDPDS_02:xsl2a6o#00000000110(768)
A2(149, 152) = A2(149, 152) - v(325); % source1:SUCFUMt_r_16:xsucce#0110(6)
A2(149, 152) = A2(149, 152) - v(223); % source1:SUCCt22_04:xsucce#0110(6)
A2(149, 152) = A2(149, 152) - v(325); % source1:SUCFUMt_r_08:xsucce#0110(6)
A2(149, 14) = A2(149, 14) - v(221); % source1:SSALy_02:x4abut#0110(6)
A2(149, 146) = A2(149, 146) - v(214); % source1:SDPDS_03:xsl2a6o#00000000110(768)
A2(149, 152) = A2(149, 152) - v(224); % source1:SUCCt23_04:xsucce#0110(6)
A2(149, 152) = A2(149, 152) - v(325); % source1:SUCFUMt_r_09:xsucce#0110(6)
A2(149, 152) = A2(149, 152) - v(224); % source1:SUCCt23_03:xsucce#0110(6)
A2(149, 152) = A2(149, 152) - v(222); % source1:SUCCabc_03:xsucce#0110(6)
A2(149, 152) = A2(149, 152) - v(325); % source1:SUCFUMt_r_14:xsucce#0110(6)
A2(149, 155) = A2(149, 155) - v(61); % source1:COMBO22_02:xsuccoa#0110(6)
A2(149, 152) = A2(149, 152) - v(224); % source1:SUCCt23_02:xsucce#0110(6)
A2(149, 14) = A2(149, 14) - v(220); % source1:SSALx_02:x4abut#0110(6)
A2(149, 152) = A2(149, 152) - v(325); % source1:SUCFUMt_r_04:xsucce#0110(6)
A2(149, 108) = A2(149, 108) - v(135); % source1:ICL_02:xicit#001100(12)
A2(149, 152) = A2(149, 152) - v(222); % source1:SUCCabc_04:xsucce#0110(6)
A2(149, 72) = A2(149, 72) - v(86); % source1:FRD2_03:xfum#0110(6)
A2(149, 14) = A2(149, 14) - v(221); % source1:SSALy_01:x4abut#0110(6)
A2(149, 152) = A2(149, 152) - v(223); % source1:SUCCt22_01:xsucce#0110(6)
A2(149, 152) = A2(149, 152) - v(222); % source1:SUCCabc_02:xsucce#0110(6)
A2(149, 152) = A2(149, 152) - v(224); % source1:SUCCt23_01:xsucce#0110(6)
A2(149, 152) = A2(149, 152) - v(325); % source1:SUCFUMt_r_01:xsucce#0110(6)
A2(149, 146) = A2(149, 146) - v(214); % source1:SDPDS_01:xsl2a6o#00000000110(768)
A2(149, 152) = A2(149, 152) - v(325); % source1:SUCFUMt_r_13:xsucce#0110(6)
A2(149, 72) = A2(149, 72) - v(87); % source1:FRD3_03:xfum#0110(6)
A2(149, 14) = A2(149, 14) - v(220); % source1:SSALx_01:x4abut#0110(6)
A2(149, 152) = A2(149, 152) - v(325); % source1:SUCFUMt_r_15:xsucce#0110(6)
A2(149, 152) = A2(149, 152) - v(325); % source1:SUCFUMt_r_02:xsucce#0110(6)
A2(149, 152) = A2(149, 152) - v(222); % source1:SUCCabc_01:xsucce#0110(6)
A2(149, 152) = A2(149, 152) - v(325); % source1:SUCFUMt_r_03:xsucce#0110(6)
A2(149, 108) = A2(149, 108) - v(135); % source1:ICL_01:xicit#001100(12)
A2(149, 152) = A2(149, 152) - v(325); % source1:SUCFUMt_r_12:xsucce#0110(6)
A2(149, 146) = A2(149, 146) - v(214); % source1:SDPDS_04:xsl2a6o#00000000110(768)
A2(149, 72) = A2(149, 72) - v(86); % source1:FRD2_04:xfum#0110(6)
A2(149, 72) = A2(149, 72) - v(87); % source1:FRD3_02:xfum#0110(6)
A2(149, 155) = A2(149, 155) - v(326); % source1:SUCOAS_r_02:xsuccoa#0110(6)
A2(149, 72) = A2(149, 72) - v(86); % source1:FRD2_01:xfum#0110(6)
A2(149, 155) = A2(149, 155) - v(61); % source1:COMBO22_01:xsuccoa#0110(6)
A2(149, 152) = A2(149, 152) - v(223); % source1:SUCCt22_02:xsucce#0110(6)
A2(149, 72) = A2(149, 72) - v(86); % source1:FRD2_02:xfum#0110(6)
A2(149, 152) = A2(149, 152) - v(325); % source1:SUCFUMt_r_10:xsucce#0110(6)
%>>> xsucc#1100#
A2(150, 150) = v(229) + v(226) + v(228) + v(228) + v(225) + v(228) + v(225) + v(228) + v(228) + v(228) + v(228) + v(228) + v(228) + v(226) + v(228) + v(225) + v(228) + v(226) + v(228) + v(228) + v(228) + v(228) + v(228) + v(226) + v(225) + v(229); % drain :SUCOAS_02:SUCD1i_04:SUCFUMt_15:SUCFUMt_08:SUCCt2b_04:SUCFUMt_12:SUCCt2b_02:SUCFUMt_10:SUCFUMt_02:SUCFUMt_13:SUCFUMt_09:SUCFUMt_01:SUCFUMt_06:SUCD1i_03:SUCFUMt_03:SUCCt2b_03:SUCFUMt_14:SUCD1i_01:SUCFUMt_07:SUCFUMt_11:SUCFUMt_05:SUCFUMt_16:SUCFUMt_04:SUCD1i_02:SUCCt2b_01:SUCOAS_01 
A2(150, 151) = A2(150, 151) - v(325); % source1:SUCFUMt_r_11:xsucce#0011(12)
A2(150, 153) = A2(150, 153) - v(325); % source1:SUCFUMt_r_07:xsucce#1100(3)
A2(150, 73) = A2(150, 73) - v(87); % source1:FRD3_01:xfum#1100(3)
A2(150, 154) = A2(150, 154) - v(326); % source1:SUCOAS_r_01:xsuccoa#0011(12)
A2(150, 151) = A2(150, 151) - v(325); % source1:SUCFUMt_r_06:xsucce#0011(12)
A2(150, 73) = A2(150, 73) - v(87); % source1:FRD3_04:xfum#1100(3)
A2(150, 153) = A2(150, 153) - v(223); % source1:SUCCt22_03:xsucce#1100(3)
A2(150, 151) = A2(150, 151) - v(325); % source1:SUCFUMt_r_05:xsucce#0011(12)
A2(150, 145) = A2(150, 145) - v(214); % source1:SDPDS_02:xsl2a6o#00000000011(1536)
A2(150, 153) = A2(150, 153) - v(325); % source1:SUCFUMt_r_16:xsucce#1100(3)
A2(150, 151) = A2(150, 151) - v(223); % source1:SUCCt22_04:xsucce#0011(12)
A2(150, 153) = A2(150, 153) - v(325); % source1:SUCFUMt_r_08:xsucce#1100(3)
A2(150, 15) = A2(150, 15) - v(221); % source1:SSALy_02:x4abut#1100(3)
A2(150, 147) = A2(150, 147) - v(214); % source1:SDPDS_03:xsl2a6o#00000001100(384)
A2(150, 151) = A2(150, 151) - v(224); % source1:SUCCt23_04:xsucce#0011(12)
A2(150, 153) = A2(150, 153) - v(325); % source1:SUCFUMt_r_09:xsucce#1100(3)
A2(150, 153) = A2(150, 153) - v(224); % source1:SUCCt23_03:xsucce#1100(3)
A2(150, 153) = A2(150, 153) - v(222); % source1:SUCCabc_03:xsucce#1100(3)
A2(150, 151) = A2(150, 151) - v(325); % source1:SUCFUMt_r_14:xsucce#0011(12)
A2(150, 156) = A2(150, 156) - v(61); % source1:COMBO22_02:xsuccoa#1100(3)
A2(150, 153) = A2(150, 153) - v(224); % source1:SUCCt23_02:xsucce#1100(3)
A2(150, 15) = A2(150, 15) - v(220); % source1:SSALx_02:x4abut#1100(3)
A2(150, 151) = A2(150, 151) - v(325); % source1:SUCFUMt_r_04:xsucce#0011(12)
A2(150, 107) = A2(150, 107) - v(135); % source1:ICL_02:xicit#001001(36)
A2(150, 151) = A2(150, 151) - v(222); % source1:SUCCabc_04:xsucce#0011(12)
A2(150, 71) = A2(150, 71) - v(86); % source1:FRD2_03:xfum#0011(12)
A2(150, 13) = A2(150, 13) - v(221); % source1:SSALy_01:x4abut#0011(12)
A2(150, 151) = A2(150, 151) - v(223); % source1:SUCCt22_01:xsucce#0011(12)
A2(150, 153) = A2(150, 153) - v(222); % source1:SUCCabc_02:xsucce#1100(3)
A2(150, 151) = A2(150, 151) - v(224); % source1:SUCCt23_01:xsucce#0011(12)
A2(150, 153) = A2(150, 153) - v(325); % source1:SUCFUMt_r_01:xsucce#1100(3)
A2(150, 147) = A2(150, 147) - v(214); % source1:SDPDS_01:xsl2a6o#00000001100(384)
A2(150, 151) = A2(150, 151) - v(325); % source1:SUCFUMt_r_13:xsucce#0011(12)
A2(150, 71) = A2(150, 71) - v(87); % source1:FRD3_03:xfum#0011(12)
A2(150, 13) = A2(150, 13) - v(220); % source1:SSALx_01:x4abut#0011(12)
A2(150, 153) = A2(150, 153) - v(325); % source1:SUCFUMt_r_15:xsucce#1100(3)
A2(150, 153) = A2(150, 153) - v(325); % source1:SUCFUMt_r_02:xsucce#1100(3)
A2(150, 151) = A2(150, 151) - v(222); % source1:SUCCabc_01:xsucce#0011(12)
A2(150, 151) = A2(150, 151) - v(325); % source1:SUCFUMt_r_03:xsucce#0011(12)
A2(150, 106) = A2(150, 106) - v(135); % source1:ICL_01:xicit#000110(24)
A2(150, 151) = A2(150, 151) - v(325); % source1:SUCFUMt_r_12:xsucce#0011(12)
A2(150, 145) = A2(150, 145) - v(214); % source1:SDPDS_04:xsl2a6o#00000000011(1536)
A2(150, 73) = A2(150, 73) - v(86); % source1:FRD2_04:xfum#1100(3)
A2(150, 71) = A2(150, 71) - v(87); % source1:FRD3_02:xfum#0011(12)
A2(150, 156) = A2(150, 156) - v(326); % source1:SUCOAS_r_02:xsuccoa#1100(3)
A2(150, 73) = A2(150, 73) - v(86); % source1:FRD2_01:xfum#1100(3)
A2(150, 154) = A2(150, 154) - v(61); % source1:COMBO22_01:xsuccoa#0011(12)
A2(150, 153) = A2(150, 153) - v(223); % source1:SUCCt22_02:xsucce#1100(3)
A2(150, 71) = A2(150, 71) - v(86); % source1:FRD2_02:xfum#0011(12)
A2(150, 153) = A2(150, 153) - v(325); % source1:SUCFUMt_r_10:xsucce#1100(3)
%>>> xsucce#0011#
A2(151, 151) = v(325) + v(222) + v(325) + v(325) + v(223) + v(222) + v(224) + v(20) + v(223) + v(325) + v(325) + v(325) + v(325) + v(223) + v(325) + v(325) + v(325) + v(222) + v(224) + v(325) + v(325) + v(224) + v(325) + v(222) + v(325) + v(224) + v(223) + v(325) + v(325) + v(20); % drain :SUCFUMt_r_11:SUCCabc_04:SUCFUMt_r_07:SUCFUMt_r_06:SUCCt22_01:SUCCabc_02:SUCCt23_01:EX_succ_02:SUCCt22_03:SUCFUMt_r_05:SUCFUMt_r_01:SUCFUMt_r_16:SUCFUMt_r_13:SUCCt22_04:SUCFUMt_r_15:SUCFUMt_r_02:SUCFUMt_r_08:SUCCabc_01:SUCCt23_04:SUCFUMt_r_03:SUCFUMt_r_09:SUCCt23_03:SUCFUMt_r_12:SUCCabc_03:SUCFUMt_r_14:SUCCt23_02:SUCCt22_02:SUCFUMt_r_10:SUCFUMt_r_04:EX_succ_01 
A2(151, 148) = A2(151, 148) - v(228); % source1:SUCFUMt_15:xsucc#0011(12)
A2(151, 148) = A2(151, 148) - v(228); % source1:SUCFUMt_08:xsucc#0011(12)
A2(151, 150) = A2(151, 150) - v(225); % source1:SUCCt2b_04:xsucc#1100(3)
A2(151, 150) = A2(151, 150) - v(228); % source1:SUCFUMt_12:xsucc#1100(3)
A2(151, 148) = A2(151, 148) - v(225); % source1:SUCCt2b_02:xsucc#0011(12)
A2(151, 148) = A2(151, 148) - v(228); % source1:SUCFUMt_10:xsucc#0011(12)
A2(151, 148) = A2(151, 148) - v(228); % source1:SUCFUMt_02:xsucc#0011(12)
A2(151, 150) = A2(151, 150) - v(228); % source1:SUCFUMt_13:xsucc#1100(3)
A2(151, 148) = A2(151, 148) - v(228); % source1:SUCFUMt_09:xsucc#0011(12)
A2(151, 148) = A2(151, 148) - v(228); % source1:SUCFUMt_01:xsucc#0011(12)
A2(151, 150) = A2(151, 150) - v(228); % source1:SUCFUMt_06:xsucc#1100(3)
A2(151, 148) = A2(151, 148) - v(225); % source1:SUCCt2b_03:xsucc#0011(12)
A2(151, 150) = A2(151, 150) - v(228); % source1:SUCFUMt_03:xsucc#1100(3)
A2(151, 150) = A2(151, 150) - v(228); % source1:SUCFUMt_14:xsucc#1100(3)
A2(151, 148) = A2(151, 148) - v(228); % source1:SUCFUMt_07:xsucc#0011(12)
A2(151, 150) = A2(151, 150) - v(228); % source1:SUCFUMt_11:xsucc#1100(3)
A2(151, 150) = A2(151, 150) - v(228); % source1:SUCFUMt_05:xsucc#1100(3)
A2(151, 148) = A2(151, 148) - v(228); % source1:SUCFUMt_16:xsucc#0011(12)
A2(151, 150) = A2(151, 150) - v(228); % source1:SUCFUMt_04:xsucc#1100(3)
A2(151, 150) = A2(151, 150) - v(225); % source1:SUCCt2b_01:xsucc#1100(3)
%>>> xsucce#0110#
A2(152, 152) = v(325) + v(222) + v(325) + v(325) + v(223) + v(222) + v(224) + v(20) + v(223) + v(325) + v(325) + v(325) + v(325) + v(223) + v(325) + v(325) + v(325) + v(222) + v(224) + v(325) + v(325) + v(224) + v(325) + v(222) + v(325) + v(224) + v(223) + v(325) + v(325) + v(20); % drain :SUCFUMt_r_11:SUCCabc_04:SUCFUMt_r_07:SUCFUMt_r_06:SUCCt22_01:SUCCabc_02:SUCCt23_01:EX_succ_02:SUCCt22_03:SUCFUMt_r_05:SUCFUMt_r_01:SUCFUMt_r_16:SUCFUMt_r_13:SUCCt22_04:SUCFUMt_r_15:SUCFUMt_r_02:SUCFUMt_r_08:SUCCabc_01:SUCCt23_04:SUCFUMt_r_03:SUCFUMt_r_09:SUCCt23_03:SUCFUMt_r_12:SUCCabc_03:SUCFUMt_r_14:SUCCt23_02:SUCCt22_02:SUCFUMt_r_10:SUCFUMt_r_04:EX_succ_01 
A2(152, 149) = A2(152, 149) - v(228); % source1:SUCFUMt_15:xsucc#0110(6)
A2(152, 149) = A2(152, 149) - v(228); % source1:SUCFUMt_08:xsucc#0110(6)
A2(152, 149) = A2(152, 149) - v(225); % source1:SUCCt2b_04:xsucc#0110(6)
A2(152, 149) = A2(152, 149) - v(228); % source1:SUCFUMt_12:xsucc#0110(6)
A2(152, 149) = A2(152, 149) - v(225); % source1:SUCCt2b_02:xsucc#0110(6)
A2(152, 149) = A2(152, 149) - v(228); % source1:SUCFUMt_10:xsucc#0110(6)
A2(152, 149) = A2(152, 149) - v(228); % source1:SUCFUMt_02:xsucc#0110(6)
A2(152, 149) = A2(152, 149) - v(228); % source1:SUCFUMt_13:xsucc#0110(6)
A2(152, 149) = A2(152, 149) - v(228); % source1:SUCFUMt_09:xsucc#0110(6)
A2(152, 149) = A2(152, 149) - v(228); % source1:SUCFUMt_01:xsucc#0110(6)
A2(152, 149) = A2(152, 149) - v(228); % source1:SUCFUMt_06:xsucc#0110(6)
A2(152, 149) = A2(152, 149) - v(225); % source1:SUCCt2b_03:xsucc#0110(6)
A2(152, 149) = A2(152, 149) - v(228); % source1:SUCFUMt_03:xsucc#0110(6)
A2(152, 149) = A2(152, 149) - v(228); % source1:SUCFUMt_14:xsucc#0110(6)
A2(152, 149) = A2(152, 149) - v(228); % source1:SUCFUMt_07:xsucc#0110(6)
A2(152, 149) = A2(152, 149) - v(228); % source1:SUCFUMt_11:xsucc#0110(6)
A2(152, 149) = A2(152, 149) - v(228); % source1:SUCFUMt_05:xsucc#0110(6)
A2(152, 149) = A2(152, 149) - v(228); % source1:SUCFUMt_16:xsucc#0110(6)
A2(152, 149) = A2(152, 149) - v(228); % source1:SUCFUMt_04:xsucc#0110(6)
A2(152, 149) = A2(152, 149) - v(225); % source1:SUCCt2b_01:xsucc#0110(6)
%>>> xsucce#1100#
A2(153, 153) = v(325) + v(222) + v(325) + v(325) + v(223) + v(222) + v(224) + v(20) + v(223) + v(325) + v(325) + v(325) + v(325) + v(223) + v(325) + v(325) + v(325) + v(222) + v(224) + v(325) + v(325) + v(224) + v(325) + v(222) + v(325) + v(224) + v(223) + v(325) + v(325) + v(20); % drain :SUCFUMt_r_11:SUCCabc_04:SUCFUMt_r_07:SUCFUMt_r_06:SUCCt22_01:SUCCabc_02:SUCCt23_01:EX_succ_02:SUCCt22_03:SUCFUMt_r_05:SUCFUMt_r_01:SUCFUMt_r_16:SUCFUMt_r_13:SUCCt22_04:SUCFUMt_r_15:SUCFUMt_r_02:SUCFUMt_r_08:SUCCabc_01:SUCCt23_04:SUCFUMt_r_03:SUCFUMt_r_09:SUCCt23_03:SUCFUMt_r_12:SUCCabc_03:SUCFUMt_r_14:SUCCt23_02:SUCCt22_02:SUCFUMt_r_10:SUCFUMt_r_04:EX_succ_01 
A2(153, 150) = A2(153, 150) - v(228); % source1:SUCFUMt_15:xsucc#1100(3)
A2(153, 150) = A2(153, 150) - v(228); % source1:SUCFUMt_08:xsucc#1100(3)
A2(153, 148) = A2(153, 148) - v(225); % source1:SUCCt2b_04:xsucc#0011(12)
A2(153, 148) = A2(153, 148) - v(228); % source1:SUCFUMt_12:xsucc#0011(12)
A2(153, 150) = A2(153, 150) - v(225); % source1:SUCCt2b_02:xsucc#1100(3)
A2(153, 150) = A2(153, 150) - v(228); % source1:SUCFUMt_10:xsucc#1100(3)
A2(153, 150) = A2(153, 150) - v(228); % source1:SUCFUMt_02:xsucc#1100(3)
A2(153, 148) = A2(153, 148) - v(228); % source1:SUCFUMt_13:xsucc#0011(12)
A2(153, 150) = A2(153, 150) - v(228); % source1:SUCFUMt_09:xsucc#1100(3)
A2(153, 150) = A2(153, 150) - v(228); % source1:SUCFUMt_01:xsucc#1100(3)
A2(153, 148) = A2(153, 148) - v(228); % source1:SUCFUMt_06:xsucc#0011(12)
A2(153, 150) = A2(153, 150) - v(225); % source1:SUCCt2b_03:xsucc#1100(3)
A2(153, 148) = A2(153, 148) - v(228); % source1:SUCFUMt_03:xsucc#0011(12)
A2(153, 148) = A2(153, 148) - v(228); % source1:SUCFUMt_14:xsucc#0011(12)
A2(153, 150) = A2(153, 150) - v(228); % source1:SUCFUMt_07:xsucc#1100(3)
A2(153, 148) = A2(153, 148) - v(228); % source1:SUCFUMt_11:xsucc#0011(12)
A2(153, 148) = A2(153, 148) - v(228); % source1:SUCFUMt_05:xsucc#0011(12)
A2(153, 150) = A2(153, 150) - v(228); % source1:SUCFUMt_16:xsucc#1100(3)
A2(153, 148) = A2(153, 148) - v(228); % source1:SUCFUMt_04:xsucc#0011(12)
A2(153, 148) = A2(153, 148) - v(225); % source1:SUCCt2b_01:xsucc#0011(12)
%>>> xsuccoa#0011#
A2(154, 154) = v(326) + v(71) + v(61) + 3e-06*v(1) + v(61) + v(326); % drain :SUCOAS_r_02:COMBO26_01:COMBO22_02:BiomassEcoliGALUi_01:COMBO22_01:SUCOAS_r_01 
A2(154, 34) = A2(154, 34) - v(233); % source1:TESTAKGDH_01:xakg#00011(24)
A2(154, 148) = A2(154, 148) - v(229); % source1:SUCOAS_02:xsucc#0011(12)
A2(154, 150) = A2(154, 150) - v(229); % source1:SUCOAS_01:xsucc#1100(3)
%>>> xsuccoa#0110#
A2(155, 155) = v(326) + v(71) + v(61) + 3e-06*v(1) + v(61) + v(326); % drain :SUCOAS_r_02:COMBO26_01:COMBO22_02:BiomassEcoliGALUi_01:COMBO22_01:SUCOAS_r_01 
A2(155, 35) = A2(155, 35) - v(233); % source1:TESTAKGDH_01:xakg#00110(12)
A2(155, 149) = A2(155, 149) - v(229); % source1:SUCOAS_02:xsucc#0110(6)
A2(155, 149) = A2(155, 149) - v(229); % source1:SUCOAS_01:xsucc#0110(6)
%>>> xsuccoa#1100#
A2(156, 156) = v(326) + v(71) + v(61) + 3e-06*v(1) + v(61) + v(326); % drain :SUCOAS_r_02:COMBO26_01:COMBO22_02:BiomassEcoliGALUi_01:COMBO22_01:SUCOAS_r_01 
A2(156, 36) = A2(156, 36) - v(233); % source1:TESTAKGDH_01:xakg#01100(6)
A2(156, 150) = A2(156, 150) - v(229); % source1:SUCOAS_02:xsucc#1100(3)
A2(156, 148) = A2(156, 148) - v(229); % source1:SUCOAS_01:xsucc#0011(12)
%>>> xthrL#0011#
A2(157, 157) = v(237) + v(236) + 0.241*v(1) + v(112); % drain :THRDL_01:THRAr_01:BiomassEcoliGALUi_01:COMBO37_01 
A2(157, 157) = A2(157, 157) - v(328); % source1:THRAr_r_01:xthrL#0011(12)
A2(157, 47) = A2(157, 47) - v(130); % source1:COMBO41_01:xaspsa#0011(12)
%>>> xthrL#1100#
A2(158, 158) = v(237) + v(236) + 0.241*v(1) + v(112); % drain :THRDL_01:THRAr_01:BiomassEcoliGALUi_01:COMBO37_01 
A2(158, 98) = A2(158, 98) - v(328); % source1:THRAr_r_01:xgly#11(3)
A2(158, 49) = A2(158, 49) - v(130); % source1:COMBO41_01:xaspsa#1100(3)
%>>> xtrpL#01100000000#
A2(159, 159) = v(242) + 0.054*v(1); % drain :TRPAS2_01:BiomassEcoliGALUi_01 
A2(159, 130) = A2(159, 130) - v(332); % source1:TRPAS2_r_01:xpyr#011(6)
A2(159, 143) = A2(159, 143) - v(244); % source1:TRPS2_01:xserL#011(6)
A2(159, 143) = A2(159, 143) - v(243); % source1:TRPS1_01:xserL#011(6)
%>>> xtrpL#11000000000#
A2(160, 160) = v(242) + 0.054*v(1); % drain :TRPAS2_01:BiomassEcoliGALUi_01 
A2(160, 131) = A2(160, 131) - v(332); % source1:TRPAS2_r_01:xpyr#110(3)
A2(160, 144) = A2(160, 144) - v(244); % source1:TRPS2_01:xserL#110(3)
A2(160, 144) = A2(160, 144) - v(243); % source1:TRPS1_01:xserL#110(3)
%>>> xtyrL#110000000#
A2(161, 161) = v(247) + 0.131*v(1) + v(247) + v(247) + v(247); % drain :TYRTA_01:BiomassEcoliGALUi_01:TYRTA_03:TYRTA_04:TYRTA_02 
A2(161, 10) = A2(161, 10) - v(333); % source1:TYRTA_r_04:x34hpp#110000000(3)
A2(161, 10) = A2(161, 10) - v(333); % source1:TYRTA_r_02:x34hpp#110000000(3)
A2(161, 10) = A2(161, 10) - v(333); % source1:TYRTA_r_01:x34hpp#110000000(3)
A2(161, 10) = A2(161, 10) - v(333); % source1:TYRTA_r_03:x34hpp#110000000(3)
%>>> xxu5pD#00011#
A2(162, 162) = v(239) + v(320) + v(238); % drain :TKT2_01:RPE_r_01:TKT1_01 
A2(162, 81) = A2(162, 81) - v(330); % source1:TKT2_r_01:xg3p#011(6)
A2(162, 135) = A2(162, 135) - v(212); % source1:RPE_01:xru5pD#00011(24)
A2(162, 81) = A2(162, 81) - v(329); % source1:TKT1_r_01:xg3p#011(6)
%>>> xxu5pD#00110#
A2(163, 163) = v(239) + v(320) + v(238); % drain :TKT2_01:RPE_r_01:TKT1_01 
A2(163, 82) = A2(163, 82) - v(330); % source1:TKT2_r_01:xg3p#110(3)
A2(163, 136) = A2(163, 136) - v(212); % source1:RPE_01:xru5pD#00110(12)
A2(163, 82) = A2(163, 82) - v(329); % source1:TKT1_r_01:xg3p#110(3)
%>>> xxu5pD#11000#
A2(164, 164) = v(239) + v(320) + v(238); % drain :TKT2_01:RPE_r_01:TKT1_01 
A2(164, 66) = A2(164, 66) - v(330); % source1:TKT2_r_01:xf6p#110000(3)
A2(164, 137) = A2(164, 137) - v(212); % source1:RPE_01:xru5pD#11000(3)
A2(164, 142) = A2(164, 142) - v(329); % source1:TKT1_r_01:xs7p#1100000(3)
x2 = solveLin(A2, B2);  

% level: 3 of size 103
A3 = sparse(103, 103);
B3 = zeros(103, 4);
%>>> x13dpg#111#
A3(1, 1) = v(296) + v(312); % drain :GAPD_r_01:PGK_r_01 
A3(1, 7) = A3(1, 7) - v(189); % source1:PGK_01:x3pg#111(7)
A3(1, 53) = A3(1, 53) - v(100); % source1:GAPD_01:xg3p#111(7)
%>>> x1pyr5c#00111#
A3(2, 2) = v(182) + v(183); % drain :P5CD_01:P5CR_01 
A3(2, 57) = A3(2, 57) - v(97); % source1:G5SADs_01:xglu5sa#00111(28)
A3(2, 2) = A3(2, 2) - v(203); % source1:PROD2_01:x1pyr5c#00111(28)
%>>> x1pyr5c#01110#
A3(3, 3) = v(182) + v(183); % drain :P5CD_01:P5CR_01 
A3(3, 58) = A3(3, 58) - v(97); % source1:G5SADs_01:xglu5sa#01110(14)
A3(3, 3) = A3(3, 3) - v(203); % source1:PROD2_01:x1pyr5c#01110(14)
%>>> x1pyr5c#11001#
A3(4, 4) = v(182) + v(183); % drain :P5CD_01:P5CR_01 
A3(4, 59) = A3(4, 59) - v(97); % source1:G5SADs_01:xglu5sa#11001(19)
A3(4, 4) = A3(4, 4) - v(203); % source1:PROD2_01:x1pyr5c#11001(19)
%>>> x1pyr5c#11100#
A3(5, 5) = v(182) + v(183); % drain :P5CD_01:P5CR_01 
A3(5, 60) = A3(5, 60) - v(97); % source1:G5SADs_01:xglu5sa#11100(7)
A3(5, 5) = A3(5, 5) - v(203); % source1:PROD2_01:x1pyr5c#11100(7)
%>>> x2pg#111#
A3(6, 6) = v(77) + v(191); % drain :ENO_01:PGM_01 
A3(6, 80) = A3(6, 80) - v(288); % source1:ENO_r_01:xpep#111(7)
A3(6, 7) = A3(6, 7) - v(313); % source1:PGM_r_01:x3pg#111(7)
%>>> x3pg#111#
A3(7, 7) = v(189) + v(313) + v(187); % drain :PGK_01:PGM_r_01:COMBO47_01 
B3(7,:) = B3(7,:) + conv(x2(97,:), x1(142,:)) * v(114); % source2:GLYCK_01:xglx#11(3):xglx#01(2)
A3(7, 1) = A3(7, 1) - v(312); % source1:PGK_r_01:x13dpg#111(7)
A3(7, 6) = A3(7, 6) - v(191); % source1:PGM_01:x2pg#111(7)
%>>> x4abut#0111#
A3(8, 8) = v(21); % drain :ABTA_01 
A3(8, 82) = A3(8, 82) - v(22); % source1:COMBO2_01:xptrc#1110(7)
A3(8, 62) = A3(8, 62) - v(107); % source1:GLUDC_01:xgluL#01110(14)
A3(8, 81) = A3(8, 81) - v(22); % source1:COMBO2_02:xptrc#0111(14)
%>>> x4abut#1110#
A3(9, 9) = v(21); % drain :ABTA_01 
A3(9, 81) = A3(9, 81) - v(22); % source1:COMBO2_01:xptrc#0111(14)
A3(9, 61) = A3(9, 61) - v(107); % source1:GLUDC_01:xgluL#00111(28)
A3(9, 82) = A3(9, 82) - v(22); % source1:COMBO2_02:xptrc#1110(7)
%>>> x4pasp#0111#
A3(10, 10) = v(281) + v(282); % drain :ASAD_r_01:ASPK_r_01 
A3(10, 29) = A3(10, 29) - v(46); % source1:ASAD_01:xaspsa#0111(14)
A3(10, 27) = A3(10, 27) - v(50); % source1:ASPK_01:xaspL#0111(14)
%>>> x4pasp#1110#
A3(11, 11) = v(281) + v(282); % drain :ASAD_r_01:ASPK_r_01 
A3(11, 30) = A3(11, 30) - v(46); % source1:ASAD_01:xaspsa#1110(7)
A3(11, 28) = A3(11, 28) - v(50); % source1:ASPK_01:xaspL#1110(7)
%>>> xacg5p#0011100#
A3(12, 12) = v(277); % drain :AGPR_r_01 
A3(12, 16) = A3(12, 16) - v(39); % source1:AGPR_01:xacg5sa#0011100(28)
A3(12, 61) = A3(12, 61) - v(24); % source1:COMBO3_01:xgluL#00111(28)
%>>> xacg5p#0111000#
A3(13, 13) = v(277); % drain :AGPR_r_01 
A3(13, 17) = A3(13, 17) - v(39); % source1:AGPR_01:xacg5sa#0111000(14)
A3(13, 62) = A3(13, 62) - v(24); % source1:COMBO3_01:xgluL#01110(14)
%>>> xacg5p#1100100#
A3(14, 14) = v(277); % drain :AGPR_r_01 
A3(14, 18) = A3(14, 18) - v(39); % source1:AGPR_01:xacg5sa#1100100(19)
A3(14, 63) = A3(14, 63) - v(24); % source1:COMBO3_01:xgluL#11001(19)
%>>> xacg5p#1110000#
A3(15, 15) = v(277); % drain :AGPR_r_01 
A3(15, 19) = A3(15, 19) - v(39); % source1:AGPR_01:xacg5sa#1110000(7)
A3(15, 64) = A3(15, 64) - v(24); % source1:COMBO3_01:xgluL#11100(7)
%>>> xacg5sa#0011100#
A3(16, 16) = v(157) + v(274) + v(39); % drain :NACODA_01:ACOTA_r_01:AGPR_01 
A3(16, 12) = A3(16, 12) - v(277); % source1:AGPR_r_01:xacg5p#0011100(28)
A3(16, 16) = A3(16, 16) - v(30); % source1:ACOTA_01:xacg5sa#0011100(28)
%>>> xacg5sa#0111000#
A3(17, 17) = v(157) + v(274) + v(39); % drain :NACODA_01:ACOTA_r_01:AGPR_01 
A3(17, 13) = A3(17, 13) - v(277); % source1:AGPR_r_01:xacg5p#0111000(14)
A3(17, 17) = A3(17, 17) - v(30); % source1:ACOTA_01:xacg5sa#0111000(14)
%>>> xacg5sa#1100100#
A3(18, 18) = v(157) + v(274) + v(39); % drain :NACODA_01:ACOTA_r_01:AGPR_01 
A3(18, 14) = A3(18, 14) - v(277); % source1:AGPR_r_01:xacg5p#1100100(19)
A3(18, 18) = A3(18, 18) - v(30); % source1:ACOTA_01:xacg5sa#1100100(19)
%>>> xacg5sa#1110000#
A3(19, 19) = v(157) + v(274) + v(39); % drain :NACODA_01:ACOTA_r_01:AGPR_01 
A3(19, 15) = A3(19, 15) - v(277); % source1:AGPR_r_01:xacg5p#1110000(7)
A3(19, 19) = A3(19, 19) - v(30); % source1:ACOTA_01:xacg5sa#1110000(7)
%>>> xakg#00111#
A3(20, 20) = v(215) + v(110) + v(297) + v(247) + v(247) + v(250) + v(247) + v(41) + v(110) + v(22) + v(301) + v(193) + v(233) + v(247) + v(193) + v(30) + v(22) + v(51) + v(21) + v(193) + v(193) + v(136); % drain :SDPTA_01:GLUSy_02:GLUDy_r_01:TYRTA_04:TYRTA_02:VALTA_01:TYRTA_01:ALATAL_01:GLUSy_01:COMBO2_02:ICDHyr_r_01:PHETA1_04:TESTAKGDH_01:TYRTA_03:PHETA1_01:ACOTA_01:COMBO2_01:ASPTA_01:ABTA_01:PHETA1_02:PHETA1_03:ILETA_01 
A3(20, 61) = A3(20, 61) - v(333); % source1:TYRTA_r_04:xgluL#00111(28)
A3(20, 61) = A3(20, 61) - v(315); % source1:PHETA1_r_03:xgluL#00111(28)
A3(20, 61) = A3(20, 61) - v(274); % source1:ACOTA_r_01:xgluL#00111(28)
A3(20, 61) = A3(20, 61) - v(322); % source1:SDPTA_r_01:xgluL#00111(28)
A3(20, 61) = A3(20, 61) - v(147); % source1:LEUTAi_01:xgluL#00111(28)
A3(20, 61) = A3(20, 61) - v(334); % source1:VALTA_r_01:xgluL#00111(28)
A3(20, 61) = A3(20, 61) - v(333); % source1:TYRTA_r_02:xgluL#00111(28)
A3(20, 61) = A3(20, 61) - v(302); % source1:ILETA_r_01:xgluL#00111(28)
A3(20, 61) = A3(20, 61) - v(187); % source1:COMBO47_01:xgluL#00111(28)
A3(20, 61) = A3(20, 61) - v(315); % source1:PHETA1_r_02:xgluL#00111(28)
A3(20, 61) = A3(20, 61) - v(315); % source1:PHETA1_r_04:xgluL#00111(28)
A3(20, 61) = A3(20, 61) - v(249); % source1:UNK3_01:xgluL#00111(28)
A3(20, 61) = A3(20, 61) - v(333); % source1:TYRTA_r_01:xgluL#00111(28)
A3(20, 61) = A3(20, 61) - v(279); % source1:ALATAL_r_01:xgluL#00111(28)
A3(20, 61) = A3(20, 61) - v(251); % source1:HISSYN_01:xgluL#00111(28)
A3(20, 61) = A3(20, 61) - v(283); % source1:ASPTA_r_01:xgluL#00111(28)
A3(20, 69) = A3(20, 69) - v(134); % source1:ICDHyr_01:xicit#001110(28)
A3(20, 61) = A3(20, 61) - v(108); % source1:GLUDy_01:xgluL#00111(28)
A3(20, 61) = A3(20, 61) - v(333); % source1:TYRTA_r_03:xgluL#00111(28)
A3(20, 61) = A3(20, 61) - v(315); % source1:PHETA1_r_01:xgluL#00111(28)
%>>> xakg#01110#
A3(21, 21) = v(215) + v(110) + v(297) + v(247) + v(247) + v(250) + v(247) + v(41) + v(110) + v(22) + v(301) + v(193) + v(233) + v(247) + v(193) + v(30) + v(22) + v(51) + v(21) + v(193) + v(193) + v(136); % drain :SDPTA_01:GLUSy_02:GLUDy_r_01:TYRTA_04:TYRTA_02:VALTA_01:TYRTA_01:ALATAL_01:GLUSy_01:COMBO2_02:ICDHyr_r_01:PHETA1_04:TESTAKGDH_01:TYRTA_03:PHETA1_01:ACOTA_01:COMBO2_01:ASPTA_01:ABTA_01:PHETA1_02:PHETA1_03:ILETA_01 
A3(21, 62) = A3(21, 62) - v(333); % source1:TYRTA_r_04:xgluL#01110(14)
A3(21, 62) = A3(21, 62) - v(315); % source1:PHETA1_r_03:xgluL#01110(14)
A3(21, 62) = A3(21, 62) - v(274); % source1:ACOTA_r_01:xgluL#01110(14)
A3(21, 62) = A3(21, 62) - v(322); % source1:SDPTA_r_01:xgluL#01110(14)
A3(21, 62) = A3(21, 62) - v(147); % source1:LEUTAi_01:xgluL#01110(14)
A3(21, 62) = A3(21, 62) - v(334); % source1:VALTA_r_01:xgluL#01110(14)
A3(21, 62) = A3(21, 62) - v(333); % source1:TYRTA_r_02:xgluL#01110(14)
A3(21, 62) = A3(21, 62) - v(302); % source1:ILETA_r_01:xgluL#01110(14)
A3(21, 62) = A3(21, 62) - v(187); % source1:COMBO47_01:xgluL#01110(14)
A3(21, 62) = A3(21, 62) - v(315); % source1:PHETA1_r_02:xgluL#01110(14)
A3(21, 62) = A3(21, 62) - v(315); % source1:PHETA1_r_04:xgluL#01110(14)
A3(21, 62) = A3(21, 62) - v(249); % source1:UNK3_01:xgluL#01110(14)
A3(21, 62) = A3(21, 62) - v(333); % source1:TYRTA_r_01:xgluL#01110(14)
A3(21, 62) = A3(21, 62) - v(279); % source1:ALATAL_r_01:xgluL#01110(14)
A3(21, 62) = A3(21, 62) - v(251); % source1:HISSYN_01:xgluL#01110(14)
A3(21, 62) = A3(21, 62) - v(283); % source1:ASPTA_r_01:xgluL#01110(14)
A3(21, 70) = A3(21, 70) - v(134); % source1:ICDHyr_01:xicit#011100(14)
A3(21, 62) = A3(21, 62) - v(108); % source1:GLUDy_01:xgluL#01110(14)
A3(21, 62) = A3(21, 62) - v(333); % source1:TYRTA_r_03:xgluL#01110(14)
A3(21, 62) = A3(21, 62) - v(315); % source1:PHETA1_r_01:xgluL#01110(14)
%>>> xakg#11001#
A3(22, 22) = v(215) + v(110) + v(297) + v(247) + v(247) + v(250) + v(247) + v(41) + v(110) + v(22) + v(301) + v(193) + v(233) + v(247) + v(193) + v(30) + v(22) + v(51) + v(21) + v(193) + v(193) + v(136); % drain :SDPTA_01:GLUSy_02:GLUDy_r_01:TYRTA_04:TYRTA_02:VALTA_01:TYRTA_01:ALATAL_01:GLUSy_01:COMBO2_02:ICDHyr_r_01:PHETA1_04:TESTAKGDH_01:TYRTA_03:PHETA1_01:ACOTA_01:COMBO2_01:ASPTA_01:ABTA_01:PHETA1_02:PHETA1_03:ILETA_01 
A3(22, 63) = A3(22, 63) - v(333); % source1:TYRTA_r_04:xgluL#11001(19)
A3(22, 63) = A3(22, 63) - v(315); % source1:PHETA1_r_03:xgluL#11001(19)
A3(22, 63) = A3(22, 63) - v(274); % source1:ACOTA_r_01:xgluL#11001(19)
A3(22, 63) = A3(22, 63) - v(322); % source1:SDPTA_r_01:xgluL#11001(19)
A3(22, 63) = A3(22, 63) - v(147); % source1:LEUTAi_01:xgluL#11001(19)
A3(22, 63) = A3(22, 63) - v(334); % source1:VALTA_r_01:xgluL#11001(19)
A3(22, 63) = A3(22, 63) - v(333); % source1:TYRTA_r_02:xgluL#11001(19)
A3(22, 63) = A3(22, 63) - v(302); % source1:ILETA_r_01:xgluL#11001(19)
A3(22, 63) = A3(22, 63) - v(187); % source1:COMBO47_01:xgluL#11001(19)
A3(22, 63) = A3(22, 63) - v(315); % source1:PHETA1_r_02:xgluL#11001(19)
A3(22, 63) = A3(22, 63) - v(315); % source1:PHETA1_r_04:xgluL#11001(19)
A3(22, 63) = A3(22, 63) - v(249); % source1:UNK3_01:xgluL#11001(19)
A3(22, 63) = A3(22, 63) - v(333); % source1:TYRTA_r_01:xgluL#11001(19)
A3(22, 63) = A3(22, 63) - v(279); % source1:ALATAL_r_01:xgluL#11001(19)
A3(22, 63) = A3(22, 63) - v(251); % source1:HISSYN_01:xgluL#11001(19)
A3(22, 63) = A3(22, 63) - v(283); % source1:ASPTA_r_01:xgluL#11001(19)
A3(22, 71) = A3(22, 71) - v(134); % source1:ICDHyr_01:xicit#110010(19)
A3(22, 63) = A3(22, 63) - v(108); % source1:GLUDy_01:xgluL#11001(19)
A3(22, 63) = A3(22, 63) - v(333); % source1:TYRTA_r_03:xgluL#11001(19)
A3(22, 63) = A3(22, 63) - v(315); % source1:PHETA1_r_01:xgluL#11001(19)
%>>> xakg#11100#
A3(23, 23) = v(215) + v(110) + v(297) + v(247) + v(247) + v(250) + v(247) + v(41) + v(110) + v(22) + v(301) + v(193) + v(233) + v(247) + v(193) + v(30) + v(22) + v(51) + v(21) + v(193) + v(193) + v(136); % drain :SDPTA_01:GLUSy_02:GLUDy_r_01:TYRTA_04:TYRTA_02:VALTA_01:TYRTA_01:ALATAL_01:GLUSy_01:COMBO2_02:ICDHyr_r_01:PHETA1_04:TESTAKGDH_01:TYRTA_03:PHETA1_01:ACOTA_01:COMBO2_01:ASPTA_01:ABTA_01:PHETA1_02:PHETA1_03:ILETA_01 
A3(23, 64) = A3(23, 64) - v(333); % source1:TYRTA_r_04:xgluL#11100(7)
A3(23, 64) = A3(23, 64) - v(315); % source1:PHETA1_r_03:xgluL#11100(7)
A3(23, 64) = A3(23, 64) - v(274); % source1:ACOTA_r_01:xgluL#11100(7)
A3(23, 64) = A3(23, 64) - v(322); % source1:SDPTA_r_01:xgluL#11100(7)
A3(23, 64) = A3(23, 64) - v(147); % source1:LEUTAi_01:xgluL#11100(7)
A3(23, 64) = A3(23, 64) - v(334); % source1:VALTA_r_01:xgluL#11100(7)
A3(23, 64) = A3(23, 64) - v(333); % source1:TYRTA_r_02:xgluL#11100(7)
A3(23, 64) = A3(23, 64) - v(302); % source1:ILETA_r_01:xgluL#11100(7)
A3(23, 64) = A3(23, 64) - v(187); % source1:COMBO47_01:xgluL#11100(7)
A3(23, 64) = A3(23, 64) - v(315); % source1:PHETA1_r_02:xgluL#11100(7)
A3(23, 64) = A3(23, 64) - v(315); % source1:PHETA1_r_04:xgluL#11100(7)
A3(23, 64) = A3(23, 64) - v(249); % source1:UNK3_01:xgluL#11100(7)
A3(23, 64) = A3(23, 64) - v(333); % source1:TYRTA_r_01:xgluL#11100(7)
A3(23, 64) = A3(23, 64) - v(279); % source1:ALATAL_r_01:xgluL#11100(7)
A3(23, 64) = A3(23, 64) - v(251); % source1:HISSYN_01:xgluL#11100(7)
A3(23, 64) = A3(23, 64) - v(283); % source1:ASPTA_r_01:xgluL#11100(7)
A3(23, 72) = A3(23, 72) - v(134); % source1:ICDHyr_01:xicit#111000(7)
A3(23, 64) = A3(23, 64) - v(108); % source1:GLUDy_01:xgluL#11100(7)
A3(23, 64) = A3(23, 64) - v(333); % source1:TYRTA_r_03:xgluL#11100(7)
A3(23, 64) = A3(23, 64) - v(315); % source1:PHETA1_r_01:xgluL#11100(7)
%>>> xalaL#111#
A3(24, 24) = v(266) + v(41) + 0.488*v(1) + v(266) + v(40); % drain :PEPTIDOSYN_01:ALATAL_01:BiomassEcoliGALUi_01:PEPTIDOSYN_02:ALAR_01 
A3(24, 83) = A3(24, 83) - v(279); % source1:ALATAL_r_01:xpyr#111(7)
A3(24, 24) = A3(24, 24) - v(278); % source1:ALAR_r_01:xalaL#111(7)
%>>> xargsuc#0000001101#
A3(25, 25) = v(44) + v(44); % drain :ARGSL_01:ARGSL_02 
A3(25, 46) = A3(25, 46) - v(280); % source1:ARGSL_r_01:xfum#0111(14)
A3(25, 28) = A3(25, 28) - v(45); % source1:ARGSS_01:xaspL#1110(7)
A3(25, 47) = A3(25, 47) - v(280); % source1:ARGSL_r_02:xfum#1110(7)
%>>> xargsuc#0000001110#
A3(26, 26) = v(44) + v(44); % drain :ARGSL_01:ARGSL_02 
A3(26, 47) = A3(26, 47) - v(280); % source1:ARGSL_r_01:xfum#1110(7)
A3(26, 27) = A3(26, 27) - v(45); % source1:ARGSS_01:xaspL#0111(14)
A3(26, 46) = A3(26, 46) - v(280); % source1:ARGSL_r_02:xfum#0111(14)
%>>> xaspL#0111#
A3(27, 27) = v(45) + v(256) + v(38) + v(255) + v(38) + 0.229*v(1) + v(48) + v(256) + v(252) + v(50) + v(267) + v(51) + v(268) + v(253) + v(255) + v(258) + v(258); % drain :ARGSS_01:IMPSYN2_02:COMBO10_02:IMPSYN1_01:COMBO10_01:BiomassEcoliGALUi_01:ASNS1_01:IMPSYN2_01:UMPSYN1_01:ASPK_01:NADSYN1_01:ASPTA_01:NADSYN2_01:UMPSYN2_01:IMPSYN1_02:COASYN_02:COASYN_01 
A3(27, 27) = A3(27, 27) - v(47); % source1:ASNN_01:xaspL#0111(14)
A3(27, 76) = A3(27, 76) - v(283); % source1:ASPTA_r_01:xoaa#0111(14)
A3(27, 10) = A3(27, 10) - v(282); % source1:ASPK_r_01:x4pasp#0111(14)
%>>> xaspL#1110#
A3(28, 28) = v(45) + v(256) + v(38) + v(255) + v(38) + 0.229*v(1) + v(48) + v(256) + v(252) + v(50) + v(267) + v(51) + v(268) + v(253) + v(255) + v(258) + v(258); % drain :ARGSS_01:IMPSYN2_02:COMBO10_02:IMPSYN1_01:COMBO10_01:BiomassEcoliGALUi_01:ASNS1_01:IMPSYN2_01:UMPSYN1_01:ASPK_01:NADSYN1_01:ASPTA_01:NADSYN2_01:UMPSYN2_01:IMPSYN1_02:COASYN_02:COASYN_01 
A3(28, 28) = A3(28, 28) - v(47); % source1:ASNN_01:xaspL#1110(7)
A3(28, 77) = A3(28, 77) - v(283); % source1:ASPTA_r_01:xoaa#1110(7)
A3(28, 11) = A3(28, 11) - v(282); % source1:ASPK_r_01:x4pasp#1110(7)
%>>> xaspsa#0111#
A3(29, 29) = v(71) + v(46) + v(300); % drain :COMBO26_01:ASAD_01:HSDy_r_01 
A3(29, 29) = A3(29, 29) - v(129); % source1:HSDy_01:xaspsa#0111(14)
A3(29, 10) = A3(29, 10) - v(281); % source1:ASAD_r_01:x4pasp#0111(14)
%>>> xaspsa#1110#
A3(30, 30) = v(71) + v(46) + v(300); % drain :COMBO26_01:ASAD_01:HSDy_r_01 
A3(30, 30) = A3(30, 30) - v(129); % source1:HSDy_01:xaspsa#1110(7)
A3(30, 11) = A3(30, 11) - v(281); % source1:ASAD_r_01:x4pasp#1110(7)
%>>> xcit#001101#
A3(31, 31) = v(29); % drain :rACONT_01 
A3(31, 68) = A3(31, 68) - v(273); % source1:rACONT_r_01:xicit#001101(44)
B3(31,:) = B3(31,:) + conv(x1(36,:), x2(119,:)) * v(58); % source2:CS_01:xaccoa#01(2):xoaa#1100(3)
%>>> xcit#001110#
A3(32, 32) = v(29); % drain :rACONT_01 
A3(32, 69) = A3(32, 69) - v(273); % source1:rACONT_r_01:xicit#001110(28)
B3(32,:) = B3(32,:) + conv(x2(20,:), x1(176,:)) * v(58); % source2:CS_01:xaccoa#11(3):xoaa#0100(2)
%>>> xcit#011100#
A3(33, 33) = v(29); % drain :rACONT_01 
A3(33, 70) = A3(33, 70) - v(273); % source1:rACONT_r_01:xicit#011100(14)
B3(33,:) = B3(33,:) + conv(x1(36,:), x2(118,:)) * v(58); % source2:CS_01:xaccoa#01(2):xoaa#0110(6)
%>>> xcit#110010#
A3(34, 34) = v(29); % drain :rACONT_01 
A3(34, 71) = A3(34, 71) - v(273); % source1:rACONT_r_01:xicit#110010(19)
B3(34,:) = B3(34,:) + conv(x1(37,:), x2(117,:)) * v(58); % source2:CS_01:xaccoa#10(1):xoaa#0011(12)
%>>> xcit#111000#
A3(35, 35) = v(29); % drain :rACONT_01 
A3(35, 72) = A3(35, 72) - v(273); % source1:rACONT_r_01:xicit#111000(7)
A3(35, 76) = A3(35, 76) - v(58); % source1:CS_01:xoaa#0111(14)
%>>> xdha#111#
A3(36, 36) = v(70) + v(290) + v(290) + v(70); % drain :DHAPT_02:F6PA_r_02:F6PA_r_01:DHAPT_01 
A3(36, 65) = A3(36, 65) - v(113); % source1:GLYCDx_04:xglyc#111(7)
A3(36, 65) = A3(36, 65) - v(113); % source1:GLYCDx_03:xglyc#111(7)
A3(36, 65) = A3(36, 65) - v(113); % source1:GLYCDx_02:xglyc#111(7)
A3(36, 42) = A3(36, 42) - v(79); % source1:F6PA_02:xf6p#111000(7)
A3(36, 65) = A3(36, 65) - v(113); % source1:GLYCDx_01:xglyc#111(7)
A3(36, 42) = A3(36, 42) - v(79); % source1:F6PA_01:xf6p#111000(7)
%>>> xdhap#111#
A3(37, 37) = v(123) + v(240) + v(294) + v(268) + v(291) + v(267); % drain :COMBO38_01:TPI_01:G3PD2_r_01:NADSYN2_01:FBA_r_01:NADSYN1_01 
A3(37, 53) = A3(37, 53) - v(331); % source1:TPI_r_01:xg3p#111(7)
A3(37, 66) = A3(37, 66) - v(96); % source1:G3PD7_01:xglyc3p#111(7)
A3(37, 66) = A3(37, 66) - v(94); % source1:G3PD5_01:xglyc3p#111(7)
A3(37, 45) = A3(37, 45) - v(80); % source1:FBA_01:xfdp#111000(7)
A3(37, 36) = A3(37, 36) - v(70); % source1:DHAPT_02:xdha#111(7)
A3(37, 66) = A3(37, 66) - v(93); % source1:G3PD2_01:xglyc3p#111(7)
A3(37, 66) = A3(37, 66) - v(95); % source1:G3PD6_01:xglyc3p#111(7)
A3(37, 36) = A3(37, 36) - v(70); % source1:DHAPT_01:xdha#111(7)
%>>> xe4p#0111#
A3(38, 38) = v(239) + v(68) + v(327); % drain :TKT2_01:COMBO25_01:TALA_r_01 
A3(38, 40) = A3(38, 40) - v(330); % source1:TKT2_r_01:xf6p#000111(56)
A3(38, 88) = A3(38, 88) - v(232); % source1:TALA_01:xs7p#0000111(112)
%>>> xe4p#1110#
A3(39, 39) = v(239) + v(68) + v(327); % drain :TKT2_01:COMBO25_01:TALA_r_01 
A3(39, 41) = A3(39, 41) - v(330); % source1:TKT2_r_01:xf6p#001110(28)
A3(39, 89) = A3(39, 89) - v(232); % source1:TALA_01:xs7p#0001110(56)
%>>> xf6p#000111#
A3(40, 40) = v(327) + v(311) + v(330) + v(185) + 2*v(266) + v(79) + 2*v(266) + v(79) + 2*v(265); % drain :TALA_r_01:PGI_r_01:TKT2_r_01:PFK_01:PEPTIDOSYN_01:F6PA_02:PEPTIDOSYN_02:F6PA_01:LPSSYN_01 
A3(40, 38) = A3(40, 38) - v(239); % source1:TKT2_01:xe4p#0111(14)
A3(40, 43) = A3(40, 43) - v(81); % source1:FBP_01:xfdp#000111(56)
A3(40, 53) = A3(40, 53) - v(290); % source1:F6PA_r_02:xg3p#111(7)
A3(40, 53) = A3(40, 53) - v(290); % source1:F6PA_r_01:xg3p#111(7)
A3(40, 53) = A3(40, 53) - v(232); % source1:TALA_01:xg3p#111(7)
A3(40, 54) = A3(40, 54) - v(188); % source1:PGI_01:xg6p#000111(56)
%>>> xf6p#001110#
A3(41, 41) = v(327) + v(311) + v(330) + v(185) + 2*v(266) + v(79) + 2*v(266) + v(79) + 2*v(265); % drain :TALA_r_01:PGI_r_01:TKT2_r_01:PFK_01:PEPTIDOSYN_01:F6PA_02:PEPTIDOSYN_02:F6PA_01:LPSSYN_01 
A3(41, 39) = A3(41, 39) - v(239); % source1:TKT2_01:xe4p#1110(7)
A3(41, 44) = A3(41, 44) - v(81); % source1:FBP_01:xfdp#001110(28)
B3(41,:) = B3(41,:) + conv(x2(82,:), x1(81,:)) * v(290); % source2:F6PA_r_02:xg3p#110(3):xdha#001(4)
B3(41,:) = B3(41,:) + conv(x2(82,:), x1(83,:)) * v(290); % source2:F6PA_r_01:xg3p#110(3):xdha#100(1)
B3(41,:) = B3(41,:) + conv(x2(82,:), x1(207,:)) * v(232); % source2:TALA_01:xg3p#110(3):xs7p#0010000(4)
A3(41, 55) = A3(41, 55) - v(188); % source1:PGI_01:xg6p#001110(28)
%>>> xf6p#111000#
A3(42, 42) = v(327) + v(311) + v(330) + v(185) + 2*v(266) + v(79) + 2*v(266) + v(79) + 2*v(265); % drain :TALA_r_01:PGI_r_01:TKT2_r_01:PFK_01:PEPTIDOSYN_01:F6PA_02:PEPTIDOSYN_02:F6PA_01:LPSSYN_01 
B3(42,:) = B3(42,:) + conv(x2(164,:), x1(93,:)) * v(239); % source2:TKT2_01:xxu5pD#11000(3):xe4p#1000(1)
A3(42, 45) = A3(42, 45) - v(81); % source1:FBP_01:xfdp#111000(7)
A3(42, 36) = A3(42, 36) - v(290); % source1:F6PA_r_02:xdha#111(7)
A3(42, 36) = A3(42, 36) - v(290); % source1:F6PA_r_01:xdha#111(7)
A3(42, 90) = A3(42, 90) - v(232); % source1:TALA_01:xs7p#1110000(7)
A3(42, 56) = A3(42, 56) - v(188); % source1:PGI_01:xg6p#111000(7)
%>>> xfdp#000111#
A3(43, 43) = v(81) + v(80); % drain :FBP_01:FBA_01 
A3(43, 40) = A3(43, 40) - v(185); % source1:PFK_01:xf6p#000111(56)
A3(43, 53) = A3(43, 53) - v(291); % source1:FBA_r_01:xg3p#111(7)
%>>> xfdp#001110#
A3(44, 44) = v(81) + v(80); % drain :FBP_01:FBA_01 
A3(44, 41) = A3(44, 41) - v(185); % source1:PFK_01:xf6p#001110(28)
B3(44,:) = B3(44,:) + conv(x1(84,:), x2(82,:)) * v(291); % source2:FBA_r_01:xdhap#001(4):xg3p#110(3)
%>>> xfdp#111000#
A3(45, 45) = v(81) + v(80); % drain :FBP_01:FBA_01 
A3(45, 42) = A3(45, 42) - v(185); % source1:PFK_01:xf6p#111000(7)
A3(45, 37) = A3(45, 37) - v(291); % source1:FBA_r_01:xdhap#111(7)
%>>> xfum#0111#
A3(46, 46) = v(325) + v(325) + v(86) + v(87) + v(325) + v(87) + v(325) + v(325) + v(325) + v(325) + v(87) + v(325) + v(325) + v(325) + v(89) + v(325) + v(325) + v(325) + v(86) + v(325) + v(87) + v(86) + v(280) + v(280) + v(86) + v(89) + v(325) + v(325); % drain :SUCFUMt_r_11:SUCFUMt_r_07:FRD2_03:FRD3_01:SUCFUMt_r_06:FRD3_04:SUCFUMt_r_05:SUCFUMt_r_01:SUCFUMt_r_16:SUCFUMt_r_13:FRD3_03:SUCFUMt_r_15:SUCFUMt_r_02:SUCFUMt_r_08:rFUM_01:SUCFUMt_r_03:SUCFUMt_r_09:SUCFUMt_r_12:FRD2_04:SUCFUMt_r_14:FRD3_02:FRD2_01:ARGSL_r_01:ARGSL_r_02:FRD2_02:rFUM_02:SUCFUMt_r_10:SUCFUMt_r_04 
A3(46, 74) = A3(46, 74) - v(293); % source1:rFUM_r_02:xmalL#0111(14)
A3(46, 94) = A3(46, 94) - v(226); % source1:SUCD1i_04:xsucc#0111(14)
A3(46, 48) = A3(46, 48) - v(228); % source1:SUCFUMt_08:xfume#0111(14)
A3(46, 28) = A3(46, 28) - v(38); % source1:COMBO10_01:xaspL#1110(7)
A3(46, 49) = A3(46, 49) - v(228); % source1:SUCFUMt_12:xfume#1110(7)
A3(46, 26) = A3(46, 26) - v(44); % source1:ARGSL_02:xargsuc#0000001110(448)
A3(46, 48) = A3(46, 48) - v(228); % source1:SUCFUMt_02:xfume#0111(14)
A3(46, 48) = A3(46, 48) - v(228); % source1:SUCFUMt_13:xfume#0111(14)
A3(46, 48) = A3(46, 48) - v(228); % source1:SUCFUMt_09:xfume#0111(14)
A3(46, 48) = A3(46, 48) - v(90); % source1:FUMt22_03:xfume#0111(14)
A3(46, 95) = A3(46, 95) - v(226); % source1:SUCD1i_03:xsucc#1110(7)
A3(46, 49) = A3(46, 49) - v(228); % source1:SUCFUMt_03:xfume#1110(7)
A3(46, 27) = A3(46, 27) - v(256); % source1:IMPSYN2_02:xaspL#0111(14)
A3(46, 27) = A3(46, 27) - v(38); % source1:COMBO10_02:xaspL#0111(14)
A3(46, 27) = A3(46, 27) - v(255); % source1:IMPSYN1_01:xaspL#0111(14)
A3(46, 49) = A3(46, 49) - v(228); % source1:SUCFUMt_07:xfume#1110(7)
A3(46, 48) = A3(46, 48) - v(228); % source1:SUCFUMt_11:xfume#0111(14)
A3(46, 49) = A3(46, 49) - v(228); % source1:SUCFUMt_05:xfume#1110(7)
A3(46, 49) = A3(46, 49) - v(228); % source1:SUCFUMt_16:xfume#1110(7)
A3(46, 49) = A3(46, 49) - v(90); % source1:FUMt22_01:xfume#1110(7)
A3(46, 27) = A3(46, 27) - v(255); % source1:IMPSYN1_02:xaspL#0111(14)
A3(46, 48) = A3(46, 48) - v(228); % source1:SUCFUMt_15:xfume#0111(14)
A3(46, 48) = A3(46, 48) - v(91); % source1:FUMt23_03:xfume#0111(14)
A3(46, 49) = A3(46, 49) - v(228); % source1:SUCFUMt_10:xfume#1110(7)
A3(46, 48) = A3(46, 48) - v(91); % source1:FUMt23_02:xfume#0111(14)
A3(46, 49) = A3(46, 49) - v(228); % source1:SUCFUMt_01:xfume#1110(7)
A3(46, 48) = A3(46, 48) - v(228); % source1:SUCFUMt_06:xfume#0111(14)
A3(46, 49) = A3(46, 49) - v(228); % source1:SUCFUMt_14:xfume#1110(7)
A3(46, 94) = A3(46, 94) - v(226); % source1:SUCD1i_01:xsucc#0111(14)
A3(46, 49) = A3(46, 49) - v(90); % source1:FUMt22_04:xfume#1110(7)
A3(46, 49) = A3(46, 49) - v(91); % source1:FUMt23_04:xfume#1110(7)
A3(46, 27) = A3(46, 27) - v(256); % source1:IMPSYN2_01:xaspL#0111(14)
A3(46, 49) = A3(46, 49) - v(91); % source1:FUMt23_01:xfume#1110(7)
A3(46, 48) = A3(46, 48) - v(90); % source1:FUMt22_02:xfume#0111(14)
A3(46, 25) = A3(46, 25) - v(44); % source1:ARGSL_01:xargsuc#0000001101(704)
A3(46, 75) = A3(46, 75) - v(293); % source1:rFUM_r_01:xmalL#1110(7)
A3(46, 48) = A3(46, 48) - v(228); % source1:SUCFUMt_04:xfume#0111(14)
A3(46, 95) = A3(46, 95) - v(226); % source1:SUCD1i_02:xsucc#1110(7)
%>>> xfum#1110#
A3(47, 47) = v(325) + v(325) + v(86) + v(87) + v(325) + v(87) + v(325) + v(325) + v(325) + v(325) + v(87) + v(325) + v(325) + v(325) + v(89) + v(325) + v(325) + v(325) + v(86) + v(325) + v(87) + v(86) + v(280) + v(280) + v(86) + v(89) + v(325) + v(325); % drain :SUCFUMt_r_11:SUCFUMt_r_07:FRD2_03:FRD3_01:SUCFUMt_r_06:FRD3_04:SUCFUMt_r_05:SUCFUMt_r_01:SUCFUMt_r_16:SUCFUMt_r_13:FRD3_03:SUCFUMt_r_15:SUCFUMt_r_02:SUCFUMt_r_08:rFUM_01:SUCFUMt_r_03:SUCFUMt_r_09:SUCFUMt_r_12:FRD2_04:SUCFUMt_r_14:FRD3_02:FRD2_01:ARGSL_r_01:ARGSL_r_02:FRD2_02:rFUM_02:SUCFUMt_r_10:SUCFUMt_r_04 
A3(47, 75) = A3(47, 75) - v(293); % source1:rFUM_r_02:xmalL#1110(7)
A3(47, 95) = A3(47, 95) - v(226); % source1:SUCD1i_04:xsucc#1110(7)
A3(47, 49) = A3(47, 49) - v(228); % source1:SUCFUMt_08:xfume#1110(7)
A3(47, 27) = A3(47, 27) - v(38); % source1:COMBO10_01:xaspL#0111(14)
A3(47, 48) = A3(47, 48) - v(228); % source1:SUCFUMt_12:xfume#0111(14)
A3(47, 25) = A3(47, 25) - v(44); % source1:ARGSL_02:xargsuc#0000001101(704)
A3(47, 49) = A3(47, 49) - v(228); % source1:SUCFUMt_02:xfume#1110(7)
A3(47, 49) = A3(47, 49) - v(228); % source1:SUCFUMt_13:xfume#1110(7)
A3(47, 49) = A3(47, 49) - v(228); % source1:SUCFUMt_09:xfume#1110(7)
A3(47, 49) = A3(47, 49) - v(90); % source1:FUMt22_03:xfume#1110(7)
A3(47, 94) = A3(47, 94) - v(226); % source1:SUCD1i_03:xsucc#0111(14)
A3(47, 48) = A3(47, 48) - v(228); % source1:SUCFUMt_03:xfume#0111(14)
A3(47, 28) = A3(47, 28) - v(256); % source1:IMPSYN2_02:xaspL#1110(7)
A3(47, 28) = A3(47, 28) - v(38); % source1:COMBO10_02:xaspL#1110(7)
A3(47, 28) = A3(47, 28) - v(255); % source1:IMPSYN1_01:xaspL#1110(7)
A3(47, 48) = A3(47, 48) - v(228); % source1:SUCFUMt_07:xfume#0111(14)
A3(47, 49) = A3(47, 49) - v(228); % source1:SUCFUMt_11:xfume#1110(7)
A3(47, 48) = A3(47, 48) - v(228); % source1:SUCFUMt_05:xfume#0111(14)
A3(47, 48) = A3(47, 48) - v(228); % source1:SUCFUMt_16:xfume#0111(14)
A3(47, 48) = A3(47, 48) - v(90); % source1:FUMt22_01:xfume#0111(14)
A3(47, 28) = A3(47, 28) - v(255); % source1:IMPSYN1_02:xaspL#1110(7)
A3(47, 49) = A3(47, 49) - v(228); % source1:SUCFUMt_15:xfume#1110(7)
A3(47, 49) = A3(47, 49) - v(91); % source1:FUMt23_03:xfume#1110(7)
A3(47, 48) = A3(47, 48) - v(228); % source1:SUCFUMt_10:xfume#0111(14)
A3(47, 49) = A3(47, 49) - v(91); % source1:FUMt23_02:xfume#1110(7)
A3(47, 48) = A3(47, 48) - v(228); % source1:SUCFUMt_01:xfume#0111(14)
A3(47, 49) = A3(47, 49) - v(228); % source1:SUCFUMt_06:xfume#1110(7)
A3(47, 48) = A3(47, 48) - v(228); % source1:SUCFUMt_14:xfume#0111(14)
A3(47, 95) = A3(47, 95) - v(226); % source1:SUCD1i_01:xsucc#1110(7)
A3(47, 48) = A3(47, 48) - v(90); % source1:FUMt22_04:xfume#0111(14)
A3(47, 48) = A3(47, 48) - v(91); % source1:FUMt23_04:xfume#0111(14)
A3(47, 28) = A3(47, 28) - v(256); % source1:IMPSYN2_01:xaspL#1110(7)
A3(47, 48) = A3(47, 48) - v(91); % source1:FUMt23_01:xfume#0111(14)
A3(47, 49) = A3(47, 49) - v(90); % source1:FUMt22_02:xfume#1110(7)
A3(47, 26) = A3(47, 26) - v(44); % source1:ARGSL_01:xargsuc#0000001110(448)
A3(47, 74) = A3(47, 74) - v(293); % source1:rFUM_r_01:xmalL#0111(14)
A3(47, 49) = A3(47, 49) - v(228); % source1:SUCFUMt_04:xfume#1110(7)
A3(47, 94) = A3(47, 94) - v(226); % source1:SUCD1i_02:xsucc#0111(14)
%>>> xfume#0111#
A3(48, 48) = v(228) + v(228) + v(228) + v(91) + v(228) + v(228) + v(91) + v(228) + v(228) + v(228) + v(228) + v(90) + v(228) + v(6) + v(228) + v(90) + v(228) + v(91) + v(90) + v(91) + v(6) + v(228) + v(228) + v(228) + v(90) + v(228); % drain :SUCFUMt_15:SUCFUMt_08:SUCFUMt_12:FUMt23_03:SUCFUMt_10:SUCFUMt_02:FUMt23_02:SUCFUMt_13:SUCFUMt_09:SUCFUMt_01:SUCFUMt_06:FUMt22_03:SUCFUMt_03:EX_fum_01:SUCFUMt_14:FUMt22_04:SUCFUMt_07:FUMt23_04:FUMt22_02:FUMt23_01:EX_fum_02:SUCFUMt_11:SUCFUMt_05:SUCFUMt_16:FUMt22_01:SUCFUMt_04 
A3(48, 46) = A3(48, 46) - v(325); % source1:SUCFUMt_r_11:xfum#0111(14)
A3(48, 47) = A3(48, 47) - v(325); % source1:SUCFUMt_r_07:xfum#1110(7)
A3(48, 46) = A3(48, 46) - v(325); % source1:SUCFUMt_r_06:xfum#0111(14)
A3(48, 47) = A3(48, 47) - v(325); % source1:SUCFUMt_r_01:xfum#1110(7)
A3(48, 47) = A3(48, 47) - v(325); % source1:SUCFUMt_r_05:xfum#1110(7)
A3(48, 47) = A3(48, 47) - v(325); % source1:SUCFUMt_r_16:xfum#1110(7)
A3(48, 46) = A3(48, 46) - v(325); % source1:SUCFUMt_r_13:xfum#0111(14)
A3(48, 46) = A3(48, 46) - v(325); % source1:SUCFUMt_r_02:xfum#0111(14)
A3(48, 46) = A3(48, 46) - v(325); % source1:SUCFUMt_r_15:xfum#0111(14)
A3(48, 46) = A3(48, 46) - v(325); % source1:SUCFUMt_r_08:xfum#0111(14)
A3(48, 47) = A3(48, 47) - v(325); % source1:SUCFUMt_r_03:xfum#1110(7)
A3(48, 46) = A3(48, 46) - v(325); % source1:SUCFUMt_r_09:xfum#0111(14)
A3(48, 47) = A3(48, 47) - v(325); % source1:SUCFUMt_r_12:xfum#1110(7)
A3(48, 47) = A3(48, 47) - v(325); % source1:SUCFUMt_r_14:xfum#1110(7)
A3(48, 47) = A3(48, 47) - v(325); % source1:SUCFUMt_r_10:xfum#1110(7)
A3(48, 46) = A3(48, 46) - v(325); % source1:SUCFUMt_r_04:xfum#0111(14)
%>>> xfume#1110#
A3(49, 49) = v(228) + v(228) + v(228) + v(91) + v(228) + v(228) + v(91) + v(228) + v(228) + v(228) + v(228) + v(90) + v(228) + v(6) + v(228) + v(90) + v(228) + v(91) + v(90) + v(91) + v(6) + v(228) + v(228) + v(228) + v(90) + v(228); % drain :SUCFUMt_15:SUCFUMt_08:SUCFUMt_12:FUMt23_03:SUCFUMt_10:SUCFUMt_02:FUMt23_02:SUCFUMt_13:SUCFUMt_09:SUCFUMt_01:SUCFUMt_06:FUMt22_03:SUCFUMt_03:EX_fum_01:SUCFUMt_14:FUMt22_04:SUCFUMt_07:FUMt23_04:FUMt22_02:FUMt23_01:EX_fum_02:SUCFUMt_11:SUCFUMt_05:SUCFUMt_16:FUMt22_01:SUCFUMt_04 
A3(49, 47) = A3(49, 47) - v(325); % source1:SUCFUMt_r_11:xfum#1110(7)
A3(49, 46) = A3(49, 46) - v(325); % source1:SUCFUMt_r_07:xfum#0111(14)
A3(49, 47) = A3(49, 47) - v(325); % source1:SUCFUMt_r_06:xfum#1110(7)
A3(49, 46) = A3(49, 46) - v(325); % source1:SUCFUMt_r_01:xfum#0111(14)
A3(49, 46) = A3(49, 46) - v(325); % source1:SUCFUMt_r_05:xfum#0111(14)
A3(49, 46) = A3(49, 46) - v(325); % source1:SUCFUMt_r_16:xfum#0111(14)
A3(49, 47) = A3(49, 47) - v(325); % source1:SUCFUMt_r_13:xfum#1110(7)
A3(49, 47) = A3(49, 47) - v(325); % source1:SUCFUMt_r_02:xfum#1110(7)
A3(49, 47) = A3(49, 47) - v(325); % source1:SUCFUMt_r_15:xfum#1110(7)
A3(49, 47) = A3(49, 47) - v(325); % source1:SUCFUMt_r_08:xfum#1110(7)
A3(49, 46) = A3(49, 46) - v(325); % source1:SUCFUMt_r_03:xfum#0111(14)
A3(49, 47) = A3(49, 47) - v(325); % source1:SUCFUMt_r_09:xfum#1110(7)
A3(49, 46) = A3(49, 46) - v(325); % source1:SUCFUMt_r_12:xfum#0111(14)
A3(49, 46) = A3(49, 46) - v(325); % source1:SUCFUMt_r_14:xfum#0111(14)
A3(49, 46) = A3(49, 46) - v(325); % source1:SUCFUMt_r_10:xfum#0111(14)
A3(49, 47) = A3(49, 47) - v(325); % source1:SUCFUMt_r_04:xfum#1110(7)
%>>> xg1p#000111#
A3(50, 50) = v(104) + 0.003*v(1) + v(92) + 2*v(265) + v(192); % drain :COMBO36_01:BiomassEcoliGALUi_01:G1PP_01:LPSSYN_01:PGMT_01 
A3(50, 54) = A3(50, 54) - v(314); % source1:PGMT_r_01:xg6p#000111(56)
A3(50, 50) = A3(50, 50) - v(103); % source1:GLCP_01:xg1p#000111(56)
%>>> xg1p#001110#
A3(51, 51) = v(104) + 0.003*v(1) + v(92) + 2*v(265) + v(192); % drain :COMBO36_01:BiomassEcoliGALUi_01:G1PP_01:LPSSYN_01:PGMT_01 
A3(51, 55) = A3(51, 55) - v(314); % source1:PGMT_r_01:xg6p#001110(28)
A3(51, 51) = A3(51, 51) - v(103); % source1:GLCP_01:xg1p#001110(28)
%>>> xg1p#111000#
A3(52, 52) = v(104) + 0.003*v(1) + v(92) + 2*v(265) + v(192); % drain :COMBO36_01:BiomassEcoliGALUi_01:G1PP_01:LPSSYN_01:PGMT_01 
A3(52, 56) = A3(52, 56) - v(314); % source1:PGMT_r_01:xg6p#111000(7)
A3(52, 52) = A3(52, 52) - v(103); % source1:GLCP_01:xg1p#111000(7)
%>>> xg3p#111#
A3(53, 53) = v(331) + v(290) + v(290) + v(330) + v(291) + v(100) + v(232) + v(329); % drain :TPI_r_01:F6PA_r_02:F6PA_r_01:TKT2_r_01:FBA_r_01:GAPD_01:TALA_01:TKT1_r_01 
A3(53, 54) = A3(53, 54) - v(75); % source1:EDA_01:xg6p#000111(56)
A3(53, 40) = A3(53, 40) - v(327); % source1:TALA_r_01:xf6p#000111(56)
A3(53, 1) = A3(53, 1) - v(296); % source1:GAPD_r_01:x13dpg#111(7)
A3(53, 102) = A3(53, 102) - v(238); % source1:TKT1_01:xxu5pD#00111(28)
A3(53, 43) = A3(53, 43) - v(80); % source1:FBA_01:xfdp#000111(56)
A3(53, 102) = A3(53, 102) - v(239); % source1:TKT2_01:xxu5pD#00111(28)
A3(53, 37) = A3(53, 37) - v(240); % source1:TPI_01:xdhap#111(7)
A3(53, 84) = A3(53, 84) - v(245); % source1:TRPS3_01:xr5p#00111(28)
A3(53, 40) = A3(53, 40) - v(79); % source1:F6PA_02:xf6p#000111(56)
A3(53, 40) = A3(53, 40) - v(79); % source1:F6PA_01:xf6p#000111(56)
A3(53, 84) = A3(53, 84) - v(243); % source1:TRPS1_01:xr5p#00111(28)
%>>> xg6p#000111#
A3(54, 54) = v(99) + v(314) + v(188); % drain :G6PDH2r_01:PGMT_r_01:PGI_01 
A3(54, 50) = A3(54, 50) - v(128); % source1:HEX1_01:xg1p#000111(56)
A3(54, 54) = A3(54, 54) - v(295); % source1:G6PDH2r_r_01:xg6p#000111(56)
A3(54, 40) = A3(54, 40) - v(311); % source1:PGI_r_01:xf6p#000111(56)
B3(54,:) = B3(54,:) + xglcDe.x000111' * v(105); % source1:GLCpts_01:xglcDe#000111(56)
A3(54, 50) = A3(54, 50) - v(192); % source1:PGMT_01:xg1p#000111(56)
%>>> xg6p#001110#
A3(55, 55) = v(99) + v(314) + v(188); % drain :G6PDH2r_01:PGMT_r_01:PGI_01 
A3(55, 51) = A3(55, 51) - v(128); % source1:HEX1_01:xg1p#001110(28)
A3(55, 55) = A3(55, 55) - v(295); % source1:G6PDH2r_r_01:xg6p#001110(28)
A3(55, 41) = A3(55, 41) - v(311); % source1:PGI_r_01:xf6p#001110(28)
B3(55,:) = B3(55,:) + xglcDe.x001110' * v(105); % source1:GLCpts_01:xglcDe#001110(28)
A3(55, 51) = A3(55, 51) - v(192); % source1:PGMT_01:xg1p#001110(28)
%>>> xg6p#111000#
A3(56, 56) = v(99) + v(314) + v(188); % drain :G6PDH2r_01:PGMT_r_01:PGI_01 
A3(56, 52) = A3(56, 52) - v(128); % source1:HEX1_01:xg1p#111000(7)
A3(56, 56) = A3(56, 56) - v(295); % source1:G6PDH2r_r_01:xg6p#111000(7)
A3(56, 42) = A3(56, 42) - v(311); % source1:PGI_r_01:xf6p#111000(7)
B3(56,:) = B3(56,:) + xglcDe.x111000' * v(105); % source1:GLCpts_01:xglcDe#111000(7)
A3(56, 52) = A3(56, 52) - v(192); % source1:PGMT_01:xg1p#111000(7)
%>>> xglu5sa#00111#
A3(57, 57) = v(97); % drain :G5SADs_01 
A3(57, 16) = A3(57, 16) - v(157); % source1:NACODA_01:xacg5sa#0011100(28)
A3(57, 61) = A3(57, 61) - v(98); % source1:COMBO34_01:xgluL#00111(28)
%>>> xglu5sa#01110#
A3(58, 58) = v(97); % drain :G5SADs_01 
A3(58, 17) = A3(58, 17) - v(157); % source1:NACODA_01:xacg5sa#0111000(14)
A3(58, 62) = A3(58, 62) - v(98); % source1:COMBO34_01:xgluL#01110(14)
%>>> xglu5sa#11001#
A3(59, 59) = v(97); % drain :G5SADs_01 
A3(59, 18) = A3(59, 18) - v(157); % source1:NACODA_01:xacg5sa#1100100(19)
A3(59, 63) = A3(59, 63) - v(98); % source1:COMBO34_01:xgluL#11001(19)
%>>> xglu5sa#11100#
A3(60, 60) = v(97); % drain :G5SADs_01 
A3(60, 19) = A3(60, 19) - v(157); % source1:NACODA_01:xacg5sa#1110000(7)
A3(60, 64) = A3(60, 64) - v(98); % source1:COMBO34_01:xgluL#11100(7)
%>>> xgluL#00111#
A3(61, 61) = v(333) + v(315) + v(274) + v(98) + v(24) + v(322) + v(147) + v(334) + v(333) + v(302) + v(187) + 0.25*v(1) + v(315) + v(315) + v(107) + v(249) + v(333) + v(279) + v(106) + v(283) + v(108) + v(333) + v(315); % drain :TYRTA_r_04:PHETA1_r_03:ACOTA_r_01:COMBO34_01:COMBO3_01:SDPTA_r_01:LEUTAi_01:VALTA_r_01:TYRTA_r_02:ILETA_r_01:COMBO47_01:BiomassEcoliGALUi_01:PHETA1_r_02:PHETA1_r_04:GLUDC_01:UNK3_01:TYRTA_r_01:ALATAL_r_01:GLNS_01:ASPTA_r_01:GLUDy_01:TYRTA_r_03:PHETA1_r_01 
A3(61, 61) = A3(61, 61) - v(124); % source1:GMPS2_01:xgluL#00111(28)
A3(61, 20) = A3(61, 20) - v(297); % source1:GLUDy_r_01:xakg#00111(28)
A3(61, 20) = A3(61, 20) - v(247); % source1:TYRTA_04:xakg#00111(28)
A3(61, 20) = A3(61, 20) - v(247); % source1:TYRTA_02:xakg#00111(28)
A3(61, 20) = A3(61, 20) - v(250); % source1:VALTA_01:xakg#00111(28)
A3(61, 20) = A3(61, 20) - 2*v(110); % source1:GLUSy_01:xakg#00111(28)
A3(61, 61) = A3(61, 61) - v(266); % source1:PEPTIDOSYN_02:xgluL#00111(28)
A3(61, 61) = A3(61, 61) - 2*v(265); % source1:LPSSYN_01:xgluL#00111(28)
A3(61, 61) = A3(61, 61) - 2*v(256); % source1:IMPSYN2_02:xgluL#00111(28)
A3(61, 63) = A3(61, 63) - 2*v(255); % source1:IMPSYN1_01:xgluL#11001(19)
A3(61, 20) = A3(61, 20) - v(247); % source1:TYRTA_03:xakg#00111(28)
A3(61, 20) = A3(61, 20) - v(193); % source1:PHETA1_01:xakg#00111(28)
A3(61, 20) = A3(61, 20) - v(30); % source1:ACOTA_01:xakg#00111(28)
A3(61, 20) = A3(61, 20) - v(22); % source1:COMBO2_01:xakg#00111(28)
A3(61, 61) = A3(61, 61) - v(266); % source1:PEPTIDOSYN_01:xgluL#00111(28)
A3(61, 20) = A3(61, 20) - v(51); % source1:ASPTA_01:xakg#00111(28)
A3(61, 20) = A3(61, 20) - v(21); % source1:ABTA_01:xakg#00111(28)
A3(61, 20) = A3(61, 20) - v(193); % source1:PHETA1_03:xakg#00111(28)
A3(61, 61) = A3(61, 61) - 2*v(255); % source1:IMPSYN1_02:xgluL#00111(28)
A3(61, 61) = A3(61, 61) - v(109); % source1:GLUN_01:xgluL#00111(28)
A3(61, 20) = A3(61, 20) - v(136); % source1:ILETA_01:xakg#00111(28)
A3(61, 61) = A3(61, 61) - 2*v(110); % source1:GLUSy_02:xgluL#00111(28)
A3(61, 2) = A3(61, 2) - v(182); % source1:P5CD_01:x1pyr5c#00111(28)
A3(61, 20) = A3(61, 20) - v(215); % source1:SDPTA_01:xakg#00111(28)
A3(61, 61) = A3(61, 61) - v(48); % source1:ASNS1_01:xgluL#00111(28)
A3(61, 61) = A3(61, 61) - v(254); % source1:CTPSYN_01:xgluL#00111(28)
A3(61, 20) = A3(61, 20) - v(41); % source1:ALATAL_01:xakg#00111(28)
A3(61, 20) = A3(61, 20) - v(247); % source1:TYRTA_01:xakg#00111(28)
A3(61, 20) = A3(61, 20) - v(22); % source1:COMBO2_02:xakg#00111(28)
A3(61, 20) = A3(61, 20) - v(193); % source1:PHETA1_04:xakg#00111(28)
A3(61, 61) = A3(61, 61) - v(54); % source1:CBPS_01:xgluL#00111(28)
A3(61, 61) = A3(61, 61) - 2*v(256); % source1:IMPSYN2_01:xgluL#00111(28)
A3(61, 61) = A3(61, 61) - v(43); % source1:COMBO15_01:xgluL#00111(28)
A3(61, 20) = A3(61, 20) - v(193); % source1:PHETA1_02:xakg#00111(28)
%>>> xgluL#01110#
A3(62, 62) = v(333) + v(315) + v(274) + v(98) + v(24) + v(322) + v(147) + v(334) + v(333) + v(302) + v(187) + 0.25*v(1) + v(315) + v(315) + v(107) + v(249) + v(333) + v(279) + v(106) + v(283) + v(108) + v(333) + v(315); % drain :TYRTA_r_04:PHETA1_r_03:ACOTA_r_01:COMBO34_01:COMBO3_01:SDPTA_r_01:LEUTAi_01:VALTA_r_01:TYRTA_r_02:ILETA_r_01:COMBO47_01:BiomassEcoliGALUi_01:PHETA1_r_02:PHETA1_r_04:GLUDC_01:UNK3_01:TYRTA_r_01:ALATAL_r_01:GLNS_01:ASPTA_r_01:GLUDy_01:TYRTA_r_03:PHETA1_r_01 
A3(62, 62) = A3(62, 62) - v(124); % source1:GMPS2_01:xgluL#01110(14)
A3(62, 21) = A3(62, 21) - v(297); % source1:GLUDy_r_01:xakg#01110(14)
A3(62, 21) = A3(62, 21) - v(247); % source1:TYRTA_04:xakg#01110(14)
A3(62, 21) = A3(62, 21) - v(247); % source1:TYRTA_02:xakg#01110(14)
A3(62, 21) = A3(62, 21) - v(250); % source1:VALTA_01:xakg#01110(14)
A3(62, 21) = A3(62, 21) - 2*v(110); % source1:GLUSy_01:xakg#01110(14)
A3(62, 62) = A3(62, 62) - v(266); % source1:PEPTIDOSYN_02:xgluL#01110(14)
A3(62, 62) = A3(62, 62) - 2*v(265); % source1:LPSSYN_01:xgluL#01110(14)
A3(62, 62) = A3(62, 62) - 2*v(256); % source1:IMPSYN2_02:xgluL#01110(14)
A3(62, 64) = A3(62, 64) - 2*v(255); % source1:IMPSYN1_01:xgluL#11100(7)
A3(62, 21) = A3(62, 21) - v(247); % source1:TYRTA_03:xakg#01110(14)
A3(62, 21) = A3(62, 21) - v(193); % source1:PHETA1_01:xakg#01110(14)
A3(62, 21) = A3(62, 21) - v(30); % source1:ACOTA_01:xakg#01110(14)
A3(62, 21) = A3(62, 21) - v(22); % source1:COMBO2_01:xakg#01110(14)
A3(62, 62) = A3(62, 62) - v(266); % source1:PEPTIDOSYN_01:xgluL#01110(14)
A3(62, 21) = A3(62, 21) - v(51); % source1:ASPTA_01:xakg#01110(14)
A3(62, 21) = A3(62, 21) - v(21); % source1:ABTA_01:xakg#01110(14)
A3(62, 21) = A3(62, 21) - v(193); % source1:PHETA1_03:xakg#01110(14)
A3(62, 62) = A3(62, 62) - 2*v(255); % source1:IMPSYN1_02:xgluL#01110(14)
A3(62, 62) = A3(62, 62) - v(109); % source1:GLUN_01:xgluL#01110(14)
A3(62, 21) = A3(62, 21) - v(136); % source1:ILETA_01:xakg#01110(14)
A3(62, 62) = A3(62, 62) - 2*v(110); % source1:GLUSy_02:xgluL#01110(14)
A3(62, 3) = A3(62, 3) - v(182); % source1:P5CD_01:x1pyr5c#01110(14)
A3(62, 21) = A3(62, 21) - v(215); % source1:SDPTA_01:xakg#01110(14)
A3(62, 62) = A3(62, 62) - v(48); % source1:ASNS1_01:xgluL#01110(14)
A3(62, 62) = A3(62, 62) - v(254); % source1:CTPSYN_01:xgluL#01110(14)
A3(62, 21) = A3(62, 21) - v(41); % source1:ALATAL_01:xakg#01110(14)
A3(62, 21) = A3(62, 21) - v(247); % source1:TYRTA_01:xakg#01110(14)
A3(62, 21) = A3(62, 21) - v(22); % source1:COMBO2_02:xakg#01110(14)
A3(62, 21) = A3(62, 21) - v(193); % source1:PHETA1_04:xakg#01110(14)
A3(62, 62) = A3(62, 62) - v(54); % source1:CBPS_01:xgluL#01110(14)
A3(62, 62) = A3(62, 62) - 2*v(256); % source1:IMPSYN2_01:xgluL#01110(14)
A3(62, 62) = A3(62, 62) - v(43); % source1:COMBO15_01:xgluL#01110(14)
A3(62, 21) = A3(62, 21) - v(193); % source1:PHETA1_02:xakg#01110(14)
%>>> xgluL#11001#
A3(63, 63) = v(333) + v(315) + v(274) + v(98) + v(24) + v(322) + v(147) + v(334) + v(333) + v(302) + v(187) + 0.25*v(1) + v(315) + v(315) + v(107) + v(249) + v(333) + v(279) + v(106) + v(283) + v(108) + v(333) + v(315); % drain :TYRTA_r_04:PHETA1_r_03:ACOTA_r_01:COMBO34_01:COMBO3_01:SDPTA_r_01:LEUTAi_01:VALTA_r_01:TYRTA_r_02:ILETA_r_01:COMBO47_01:BiomassEcoliGALUi_01:PHETA1_r_02:PHETA1_r_04:GLUDC_01:UNK3_01:TYRTA_r_01:ALATAL_r_01:GLNS_01:ASPTA_r_01:GLUDy_01:TYRTA_r_03:PHETA1_r_01 
A3(63, 63) = A3(63, 63) - v(124); % source1:GMPS2_01:xgluL#11001(19)
A3(63, 22) = A3(63, 22) - v(297); % source1:GLUDy_r_01:xakg#11001(19)
A3(63, 22) = A3(63, 22) - v(247); % source1:TYRTA_04:xakg#11001(19)
A3(63, 22) = A3(63, 22) - v(247); % source1:TYRTA_02:xakg#11001(19)
A3(63, 22) = A3(63, 22) - v(250); % source1:VALTA_01:xakg#11001(19)
A3(63, 22) = A3(63, 22) - 2*v(110); % source1:GLUSy_01:xakg#11001(19)
A3(63, 63) = A3(63, 63) - v(266); % source1:PEPTIDOSYN_02:xgluL#11001(19)
A3(63, 63) = A3(63, 63) - 2*v(265); % source1:LPSSYN_01:xgluL#11001(19)
A3(63, 63) = A3(63, 63) - 2*v(256); % source1:IMPSYN2_02:xgluL#11001(19)
A3(63, 61) = A3(63, 61) - 2*v(255); % source1:IMPSYN1_01:xgluL#00111(28)
A3(63, 22) = A3(63, 22) - v(247); % source1:TYRTA_03:xakg#11001(19)
A3(63, 22) = A3(63, 22) - v(193); % source1:PHETA1_01:xakg#11001(19)
A3(63, 22) = A3(63, 22) - v(30); % source1:ACOTA_01:xakg#11001(19)
A3(63, 22) = A3(63, 22) - v(22); % source1:COMBO2_01:xakg#11001(19)
A3(63, 63) = A3(63, 63) - v(266); % source1:PEPTIDOSYN_01:xgluL#11001(19)
A3(63, 22) = A3(63, 22) - v(51); % source1:ASPTA_01:xakg#11001(19)
A3(63, 22) = A3(63, 22) - v(21); % source1:ABTA_01:xakg#11001(19)
A3(63, 22) = A3(63, 22) - v(193); % source1:PHETA1_03:xakg#11001(19)
A3(63, 63) = A3(63, 63) - 2*v(255); % source1:IMPSYN1_02:xgluL#11001(19)
A3(63, 63) = A3(63, 63) - v(109); % source1:GLUN_01:xgluL#11001(19)
A3(63, 22) = A3(63, 22) - v(136); % source1:ILETA_01:xakg#11001(19)
A3(63, 63) = A3(63, 63) - 2*v(110); % source1:GLUSy_02:xgluL#11001(19)
A3(63, 4) = A3(63, 4) - v(182); % source1:P5CD_01:x1pyr5c#11001(19)
A3(63, 22) = A3(63, 22) - v(215); % source1:SDPTA_01:xakg#11001(19)
A3(63, 63) = A3(63, 63) - v(48); % source1:ASNS1_01:xgluL#11001(19)
A3(63, 63) = A3(63, 63) - v(254); % source1:CTPSYN_01:xgluL#11001(19)
A3(63, 22) = A3(63, 22) - v(41); % source1:ALATAL_01:xakg#11001(19)
A3(63, 22) = A3(63, 22) - v(247); % source1:TYRTA_01:xakg#11001(19)
A3(63, 22) = A3(63, 22) - v(22); % source1:COMBO2_02:xakg#11001(19)
A3(63, 22) = A3(63, 22) - v(193); % source1:PHETA1_04:xakg#11001(19)
A3(63, 63) = A3(63, 63) - v(54); % source1:CBPS_01:xgluL#11001(19)
A3(63, 63) = A3(63, 63) - 2*v(256); % source1:IMPSYN2_01:xgluL#11001(19)
A3(63, 63) = A3(63, 63) - v(43); % source1:COMBO15_01:xgluL#11001(19)
A3(63, 22) = A3(63, 22) - v(193); % source1:PHETA1_02:xakg#11001(19)
%>>> xgluL#11100#
A3(64, 64) = v(333) + v(315) + v(274) + v(98) + v(24) + v(322) + v(147) + v(334) + v(333) + v(302) + v(187) + 0.25*v(1) + v(315) + v(315) + v(107) + v(249) + v(333) + v(279) + v(106) + v(283) + v(108) + v(333) + v(315); % drain :TYRTA_r_04:PHETA1_r_03:ACOTA_r_01:COMBO34_01:COMBO3_01:SDPTA_r_01:LEUTAi_01:VALTA_r_01:TYRTA_r_02:ILETA_r_01:COMBO47_01:BiomassEcoliGALUi_01:PHETA1_r_02:PHETA1_r_04:GLUDC_01:UNK3_01:TYRTA_r_01:ALATAL_r_01:GLNS_01:ASPTA_r_01:GLUDy_01:TYRTA_r_03:PHETA1_r_01 
A3(64, 64) = A3(64, 64) - v(124); % source1:GMPS2_01:xgluL#11100(7)
A3(64, 23) = A3(64, 23) - v(297); % source1:GLUDy_r_01:xakg#11100(7)
A3(64, 23) = A3(64, 23) - v(247); % source1:TYRTA_04:xakg#11100(7)
A3(64, 23) = A3(64, 23) - v(247); % source1:TYRTA_02:xakg#11100(7)
A3(64, 23) = A3(64, 23) - v(250); % source1:VALTA_01:xakg#11100(7)
A3(64, 23) = A3(64, 23) - 2*v(110); % source1:GLUSy_01:xakg#11100(7)
A3(64, 64) = A3(64, 64) - v(266); % source1:PEPTIDOSYN_02:xgluL#11100(7)
A3(64, 64) = A3(64, 64) - 2*v(265); % source1:LPSSYN_01:xgluL#11100(7)
A3(64, 64) = A3(64, 64) - 2*v(256); % source1:IMPSYN2_02:xgluL#11100(7)
A3(64, 62) = A3(64, 62) - 2*v(255); % source1:IMPSYN1_01:xgluL#01110(14)
A3(64, 23) = A3(64, 23) - v(247); % source1:TYRTA_03:xakg#11100(7)
A3(64, 23) = A3(64, 23) - v(193); % source1:PHETA1_01:xakg#11100(7)
A3(64, 23) = A3(64, 23) - v(30); % source1:ACOTA_01:xakg#11100(7)
A3(64, 23) = A3(64, 23) - v(22); % source1:COMBO2_01:xakg#11100(7)
A3(64, 64) = A3(64, 64) - v(266); % source1:PEPTIDOSYN_01:xgluL#11100(7)
A3(64, 23) = A3(64, 23) - v(51); % source1:ASPTA_01:xakg#11100(7)
A3(64, 23) = A3(64, 23) - v(21); % source1:ABTA_01:xakg#11100(7)
A3(64, 23) = A3(64, 23) - v(193); % source1:PHETA1_03:xakg#11100(7)
A3(64, 64) = A3(64, 64) - 2*v(255); % source1:IMPSYN1_02:xgluL#11100(7)
A3(64, 64) = A3(64, 64) - v(109); % source1:GLUN_01:xgluL#11100(7)
A3(64, 23) = A3(64, 23) - v(136); % source1:ILETA_01:xakg#11100(7)
A3(64, 64) = A3(64, 64) - 2*v(110); % source1:GLUSy_02:xgluL#11100(7)
A3(64, 5) = A3(64, 5) - v(182); % source1:P5CD_01:x1pyr5c#11100(7)
A3(64, 23) = A3(64, 23) - v(215); % source1:SDPTA_01:xakg#11100(7)
A3(64, 64) = A3(64, 64) - v(48); % source1:ASNS1_01:xgluL#11100(7)
A3(64, 64) = A3(64, 64) - v(254); % source1:CTPSYN_01:xgluL#11100(7)
A3(64, 23) = A3(64, 23) - v(41); % source1:ALATAL_01:xakg#11100(7)
A3(64, 23) = A3(64, 23) - v(247); % source1:TYRTA_01:xakg#11100(7)
A3(64, 23) = A3(64, 23) - v(22); % source1:COMBO2_02:xakg#11100(7)
A3(64, 23) = A3(64, 23) - v(193); % source1:PHETA1_04:xakg#11100(7)
A3(64, 64) = A3(64, 64) - v(54); % source1:CBPS_01:xgluL#11100(7)
A3(64, 64) = A3(64, 64) - 2*v(256); % source1:IMPSYN2_01:xgluL#11100(7)
A3(64, 64) = A3(64, 64) - v(43); % source1:COMBO15_01:xgluL#11100(7)
A3(64, 23) = A3(64, 23) - v(193); % source1:PHETA1_02:xakg#11100(7)
%>>> xglyc#111#
A3(65, 65) = v(121) + v(113) + v(122) + v(122) + v(113) + v(121) + v(113) + v(113) + v(121) + v(121); % drain :GLYCt_02:GLYCDx_03:GLYK_01:GLYK_02:GLYCDx_01:GLYCt_01:GLYCDx_04:GLYCDx_02:GLYCt_04:GLYCt_03 
A3(65, 67) = A3(65, 67) - v(298); % source1:GLYCt_r_01:xglyce#111(7)
A3(65, 66) = A3(65, 66) - v(270); % source1:G3PP_01:xglyc3p#111(7)
A3(65, 67) = A3(65, 67) - v(298); % source1:GLYCt_r_02:xglyce#111(7)
A3(65, 67) = A3(65, 67) - v(298); % source1:GLYCt_r_04:xglyce#111(7)
A3(65, 66) = A3(65, 66) - v(270); % source1:G3PP_02:xglyc3p#111(7)
A3(65, 66) = A3(65, 66) - v(264); % source1:CLPNSYN_02:xglyc3p#111(7)
A3(65, 67) = A3(65, 67) - v(298); % source1:GLYCt_r_03:xglyce#111(7)
A3(65, 66) = A3(65, 66) - v(264); % source1:CLPNSYN_01:xglyc3p#111(7)
%>>> xglyc3p#111#
A3(66, 66) = v(96) + v(260) + v(94) + 2*v(264) + v(270) + v(93) + v(95) + v(263) + v(270) + 2*v(264); % drain :G3PD7_01:CDPDAGSYN_01:G3PD5_01:CLPNSYN_02:G3PP_01:G3PD2_01:G3PD6_01:PGSYN_01:G3PP_02:CLPNSYN_01 
A3(66, 37) = A3(66, 37) - v(294); % source1:G3PD2_r_01:xdhap#111(7)
A3(66, 65) = A3(66, 65) - v(122); % source1:GLYK_01:xglyc#111(7)
A3(66, 65) = A3(66, 65) - v(122); % source1:GLYK_02:xglyc#111(7)
%>>> xglyce#111#
A3(67, 67) = v(298) + v(8) + v(298) + v(8) + v(298) + v(298); % drain :GLYCt_r_01:EX_glyc_01:GLYCt_r_02:EX_glyc_02:GLYCt_r_04:GLYCt_r_03 
A3(67, 65) = A3(67, 65) - v(121); % source1:GLYCt_02:xglyc#111(7)
A3(67, 65) = A3(67, 65) - v(121); % source1:GLYCt_04:xglyc#111(7)
A3(67, 65) = A3(67, 65) - v(121); % source1:GLYCt_03:xglyc#111(7)
A3(67, 65) = A3(67, 65) - v(121); % source1:GLYCt_01:xglyc#111(7)
%>>> xicit#001101#
A3(68, 68) = v(273) + v(135) + v(134) + v(135); % drain :rACONT_r_01:ICL_01:ICDHyr_01:ICL_02 
B3(68,:) = B3(68,:) + conv(x2(35,:), x1(80,:)) * v(301); % source2:ICDHyr_r_01:xakg#00110(12):xco2#1(1)
A3(68, 31) = A3(68, 31) - v(29); % source1:rACONT_01:xcit#001101(44)
%>>> xicit#001110#
A3(69, 69) = v(273) + v(135) + v(134) + v(135); % drain :rACONT_r_01:ICL_01:ICDHyr_01:ICL_02 
A3(69, 20) = A3(69, 20) - v(301); % source1:ICDHyr_r_01:xakg#00111(28)
A3(69, 32) = A3(69, 32) - v(29); % source1:rACONT_01:xcit#001110(28)
%>>> xicit#011100#
A3(70, 70) = v(273) + v(135) + v(134) + v(135); % drain :rACONT_r_01:ICL_01:ICDHyr_01:ICL_02 
A3(70, 21) = A3(70, 21) - v(301); % source1:ICDHyr_r_01:xakg#01110(14)
A3(70, 33) = A3(70, 33) - v(29); % source1:rACONT_01:xcit#011100(14)
%>>> xicit#110010#
A3(71, 71) = v(273) + v(135) + v(134) + v(135); % drain :rACONT_r_01:ICL_01:ICDHyr_01:ICL_02 
A3(71, 22) = A3(71, 22) - v(301); % source1:ICDHyr_r_01:xakg#11001(19)
A3(71, 34) = A3(71, 34) - v(29); % source1:rACONT_01:xcit#110010(19)
%>>> xicit#111000#
A3(72, 72) = v(273) + v(135) + v(134) + v(135); % drain :rACONT_r_01:ICL_01:ICDHyr_01:ICL_02 
A3(72, 23) = A3(72, 23) - v(301); % source1:ICDHyr_r_01:xakg#11100(7)
A3(72, 35) = A3(72, 35) - v(29); % source1:rACONT_01:xcit#111000(7)
%>>> xlacD#111#
A3(73, 73) = v(285) + v(146) + v(145); % drain :DLACt2_r_01:LDHD2_01:LDHD_01 
A3(73, 83) = A3(73, 83) - v(306); % source1:LDHD_r_01:xpyr#111(7)
A3(73, 37) = A3(73, 37) - v(123); % source1:COMBO38_01:xdhap#111(7)
A3(73, 73) = A3(73, 73) - v(65); % source1:DLACt2_01:xlacD#111(7)
%>>> xmalL#0111#
A3(74, 74) = v(293) + v(151) + v(149) + v(152) + v(293) + v(153) + v(150); % drain :rFUM_r_02:MDH3_01:MDH_01:ME1_01:rFUM_r_01:ME2_01:MDH2_01 
B3(74,:) = B3(74,:) + conv(x1(142,:), x2(20,:)) * v(148); % source2:MALS_01:xglx#01(2):xaccoa#11(3)
A3(74, 76) = A3(74, 76) - v(307); % source1:MDH_r_01:xoaa#0111(14)
A3(74, 47) = A3(74, 47) - v(89); % source1:rFUM_01:xfum#1110(7)
A3(74, 46) = A3(74, 46) - v(89); % source1:rFUM_02:xfum#0111(14)
%>>> xmalL#1110#
A3(75, 75) = v(293) + v(151) + v(149) + v(152) + v(293) + v(153) + v(150); % drain :rFUM_r_02:MDH3_01:MDH_01:ME1_01:rFUM_r_01:ME2_01:MDH2_01 
B3(75,:) = B3(75,:) + conv(x2(97,:), x1(36,:)) * v(148); % source2:MALS_01:xglx#11(3):xaccoa#01(2)
A3(75, 77) = A3(75, 77) - v(307); % source1:MDH_r_01:xoaa#1110(7)
A3(75, 46) = A3(75, 46) - v(89); % source1:rFUM_01:xfum#0111(14)
A3(75, 47) = A3(75, 47) - v(89); % source1:rFUM_02:xfum#1110(7)
%>>> xoaa#0111#
A3(76, 76) = v(307) + v(283) + v(58) + v(199); % drain :MDH_r_01:ASPTA_r_01:CS_01:PPCK_01 
B3(76,:) = B3(76,:) + conv(x1(80,:), x2(123,:)) * v(198); % source2:PPC_01:xco2#1(1):xpep#011(6)
A3(76, 74) = A3(76, 74) - v(151); % source1:MDH3_01:xmalL#0111(14)
A3(76, 74) = A3(76, 74) - v(149); % source1:MDH_01:xmalL#0111(14)
A3(76, 27) = A3(76, 27) - v(51); % source1:ASPTA_01:xaspL#0111(14)
A3(76, 74) = A3(76, 74) - v(150); % source1:MDH2_01:xmalL#0111(14)
%>>> xoaa#1110#
A3(77, 77) = v(307) + v(283) + v(58) + v(199); % drain :MDH_r_01:ASPTA_r_01:CS_01:PPCK_01 
A3(77, 80) = A3(77, 80) - v(198); % source1:PPC_01:xpep#111(7)
A3(77, 75) = A3(77, 75) - v(151); % source1:MDH3_01:xmalL#1110(7)
A3(77, 75) = A3(77, 75) - v(149); % source1:MDH_01:xmalL#1110(7)
A3(77, 28) = A3(77, 28) - v(51); % source1:ASPTA_01:xaspL#1110(7)
A3(77, 75) = A3(77, 75) - v(150); % source1:MDH2_01:xmalL#1110(7)
%>>> xorn#00111#
A3(78, 78) = v(181) + v(179) + v(181); % drain :ORNDC_01:OCBT_01:ORNDC_02 
A3(78, 78) = A3(78, 78) - v(310); % source1:OCBT_r_01:xorn#00111(28)
A3(78, 16) = A3(78, 16) - v(28); % source1:ACODA_01:xacg5sa#0011100(28)
%>>> xorn#01110#
A3(79, 79) = v(181) + v(179) + v(181); % drain :ORNDC_01:OCBT_01:ORNDC_02 
A3(79, 79) = A3(79, 79) - v(310); % source1:OCBT_r_01:xorn#01110(14)
A3(79, 17) = A3(79, 17) - v(28); % source1:ACODA_01:xacg5sa#0111000(14)
%>>> xpep#111#
A3(80, 80) = v(288) + v(198) + v(205) + v(207) + v(70) + v(266) + v(68) + v(266) + v(105) + 5*v(265) + v(70); % drain :ENO_r_01:PPC_01:PSCVT_01:PYK_01:DHAPT_02:PEPTIDOSYN_01:COMBO25_01:PEPTIDOSYN_02:GLCpts_01:LPSSYN_01:DHAPT_01 
A3(80, 80) = A3(80, 80) - v(317); % source1:PSCVT_r_01:xpep#111(7)
A3(80, 6) = A3(80, 6) - v(77); % source1:ENO_01:x2pg#111(7)
A3(80, 83) = A3(80, 83) - v(202); % source1:PPS_01:xpyr#111(7)
A3(80, 77) = A3(80, 77) - v(199); % source1:PPCK_01:xoaa#1110(7)
%>>> xptrc#0111#
A3(81, 81) = v(22) + v(36) + 0.035*v(1) + v(36) + v(22); % drain :COMBO2_01:COMBOSPMD_02:BiomassEcoliGALUi_01:COMBOSPMD_01:COMBO2_02 
A3(81, 79) = A3(81, 79) - v(181); % source1:ORNDC_01:xorn#01110(14)
A3(81, 78) = A3(81, 78) - v(181); % source1:ORNDC_02:xorn#00111(28)
%>>> xptrc#1110#
A3(82, 82) = v(22) + v(36) + 0.035*v(1) + v(36) + v(22); % drain :COMBO2_01:COMBOSPMD_02:BiomassEcoliGALUi_01:COMBOSPMD_01:COMBO2_02 
A3(82, 78) = A3(82, 78) - v(181); % source1:ORNDC_01:xorn#00111(28)
A3(82, 79) = A3(82, 79) - v(181); % source1:ORNDC_02:xorn#01110(14)
%>>> xpyr#111#
A3(83, 83) = v(306) + v(184) + v(25) + 2*v(27) + v(202) + v(196) + v(71) + v(279) + v(332) + v(319) + v(186); % drain :LDHD_r_01:PDH_01:COMBO4_01:COMBO5_01:PPS_01:POX_01:COMBO26_01:ALATAL_r_01:TRPAS2_r_01:PYRt2r_r_01:PFL_01 
A3(83, 80) = A3(83, 80) - v(269); % source1:THFSYN_01:xpep#111(7)
A3(83, 24) = A3(83, 24) - v(41); % source1:ALATAL_01:xalaL#111(7)
A3(83, 80) = A3(83, 80) - v(105); % source1:GLCpts_01:xpep#111(7)
A3(83, 83) = A3(83, 83) - v(208); % source1:PYRt2r_01:xpyr#111(7)
A3(83, 56) = A3(83, 56) - v(75); % source1:EDA_01:xg6p#111000(7)
A3(83, 73) = A3(83, 73) - v(145); % source1:LDHD_01:xlacD#111(7)
A3(83, 75) = A3(83, 75) - v(153); % source1:ME2_01:xmalL#1110(7)
A3(83, 80) = A3(83, 80) - v(207); % source1:PYK_01:xpep#111(7)
A3(83, 80) = A3(83, 80) - v(43); % source1:COMBO15_01:xpep#111(7)
A3(83, 80) = A3(83, 80) - v(70); % source1:DHAPT_02:xpep#111(7)
A3(83, 101) = A3(83, 101) - v(242); % source1:TRPAS2_01:xtrpL#11100000000(7)
A3(83, 91) = A3(83, 91) - v(61); % source1:COMBO22_02:xserL#111(7)
A3(83, 91) = A3(83, 91) - v(217); % source1:SERDL_01:xserL#111(7)
A3(83, 91) = A3(83, 91) - v(59); % source1:CYSDS_01:xserL#111(7)
A3(83, 75) = A3(83, 75) - v(152); % source1:ME1_01:xmalL#1110(7)
A3(83, 91) = A3(83, 91) - v(61); % source1:COMBO22_01:xserL#111(7)
A3(83, 73) = A3(83, 73) - v(146); % source1:LDHD2_01:xlacD#111(7)
A3(83, 80) = A3(83, 80) - v(70); % source1:DHAPT_01:xpep#111(7)
%>>> xr5p#00111#
A3(84, 84) = v(213) + v(204) + v(238); % drain :RPI_01:PRPPS_01:TKT1_01 
A3(84, 86) = A3(84, 86) - v(321); % source1:RPI_r_01:xru5pD#00111(28)
A3(84, 88) = A3(84, 88) - v(329); % source1:TKT1_r_01:xs7p#0000111(112)
A3(84, 84) = A3(84, 84) - v(316); % source1:PRPPS_r_01:xr5p#00111(28)
%>>> xr5p#01110#
A3(85, 85) = v(213) + v(204) + v(238); % drain :RPI_01:PRPPS_01:TKT1_01 
A3(85, 87) = A3(85, 87) - v(321); % source1:RPI_r_01:xru5pD#01110(14)
A3(85, 89) = A3(85, 89) - v(329); % source1:TKT1_r_01:xs7p#0001110(56)
A3(85, 85) = A3(85, 85) - v(316); % source1:PRPPS_r_01:xr5p#01110(14)
%>>> xru5pD#00111#
A3(86, 86) = v(321) + v(212) + 2*v(259) + 2*v(259) + 5*v(265) + 2*v(259); % drain :RPI_r_01:RPE_01:FADSYN_02:FADSYN_01:LPSSYN_01:FADSYN_03 
A3(86, 84) = A3(86, 84) - v(213); % source1:RPI_01:xr5p#00111(28)
A3(86, 54) = A3(86, 54) - v(125); % source1:GND_01:xg6p#000111(56)
A3(86, 102) = A3(86, 102) - v(320); % source1:RPE_r_01:xxu5pD#00111(28)
%>>> xru5pD#01110#
A3(87, 87) = v(321) + v(212) + 2*v(259) + 2*v(259) + 5*v(265) + 2*v(259); % drain :RPI_r_01:RPE_01:FADSYN_02:FADSYN_01:LPSSYN_01:FADSYN_03 
A3(87, 85) = A3(87, 85) - v(213); % source1:RPI_01:xr5p#01110(14)
A3(87, 55) = A3(87, 55) - v(125); % source1:GND_01:xg6p#001110(28)
A3(87, 103) = A3(87, 103) - v(320); % source1:RPE_r_01:xxu5pD#01110(14)
%>>> xs7p#0000111#
A3(88, 88) = v(329) + 3*v(265) + v(232); % drain :TKT1_r_01:LPSSYN_01:TALA_01 
A3(88, 38) = A3(88, 38) - v(327); % source1:TALA_r_01:xe4p#0111(14)
A3(88, 84) = A3(88, 84) - v(238); % source1:TKT1_01:xr5p#00111(28)
%>>> xs7p#0001110#
A3(89, 89) = v(329) + 3*v(265) + v(232); % drain :TKT1_r_01:LPSSYN_01:TALA_01 
A3(89, 39) = A3(89, 39) - v(327); % source1:TALA_r_01:xe4p#1110(7)
A3(89, 85) = A3(89, 85) - v(238); % source1:TKT1_01:xr5p#01110(14)
%>>> xs7p#1110000#
A3(90, 90) = v(329) + 3*v(265) + v(232); % drain :TKT1_r_01:LPSSYN_01:TALA_01 
A3(90, 42) = A3(90, 42) - v(327); % source1:TALA_r_01:xf6p#111000(7)
B3(90,:) = B3(90,:) + conv(x1(197,:), x2(164,:)) * v(238); % source2:TKT1_01:xr5p#10000(1):xxu5pD#11000(3)
%>>> xserL#111#
A3(91, 91) = v(217) + v(261) + v(216) + 0.205*v(1) + v(244) + v(101) + v(262) + v(243); % drain :SERDL_01:PSSYN_01:SERAT_01:BiomassEcoliGALUi_01:TRPS2_01:GHMT2_01:PESYN_01:TRPS1_01 
A3(91, 91) = A3(91, 91) - v(323); % source1:SERAT_r_01:xserL#111(7)
B3(91,:) = B3(91,:) + conv(x2(98,:), x1(173,:)) * v(335); % source2:GHMT2_r_01:xgly#11(3):xmlthf#1(1)
A3(91, 7) = A3(91, 7) - v(187); % source1:COMBO47_01:x3pg#111(7)
%>>> xsl2a6o#00000000111#
A3(92, 92) = v(322); % drain :SDPTA_r_01 
A3(92, 92) = A3(92, 92) - v(215); % source1:SDPTA_01:xsl2a6o#00000000111(1792)
A3(92, 98) = A3(92, 98) - v(71); % source1:COMBO26_01:xsuccoa#0111(14)
%>>> xsl2a6o#00000001110#
A3(93, 93) = v(322); % drain :SDPTA_r_01 
A3(93, 93) = A3(93, 93) - v(215); % source1:SDPTA_01:xsl2a6o#00000001110(896)
A3(93, 99) = A3(93, 99) - v(71); % source1:COMBO26_01:xsuccoa#1110(7)
%>>> xsucc#0111#
A3(94, 94) = v(229) + v(226) + v(228) + v(228) + v(225) + v(228) + v(225) + v(228) + v(228) + v(228) + v(228) + v(228) + v(228) + v(226) + v(228) + v(225) + v(228) + v(226) + v(228) + v(228) + v(228) + v(228) + v(228) + v(226) + v(225) + v(229); % drain :SUCOAS_02:SUCD1i_04:SUCFUMt_15:SUCFUMt_08:SUCCt2b_04:SUCFUMt_12:SUCCt2b_02:SUCFUMt_10:SUCFUMt_02:SUCFUMt_13:SUCFUMt_09:SUCFUMt_01:SUCFUMt_06:SUCD1i_03:SUCFUMt_03:SUCCt2b_03:SUCFUMt_14:SUCD1i_01:SUCFUMt_07:SUCFUMt_11:SUCFUMt_05:SUCFUMt_16:SUCFUMt_04:SUCD1i_02:SUCCt2b_01:SUCOAS_01 
A3(94, 97) = A3(94, 97) - v(325); % source1:SUCFUMt_r_11:xsucce#1110(7)
A3(94, 96) = A3(94, 96) - v(325); % source1:SUCFUMt_r_07:xsucce#0111(14)
A3(94, 46) = A3(94, 46) - v(87); % source1:FRD3_01:xfum#0111(14)
A3(94, 99) = A3(94, 99) - v(326); % source1:SUCOAS_r_01:xsuccoa#1110(7)
A3(94, 97) = A3(94, 97) - v(325); % source1:SUCFUMt_r_06:xsucce#1110(7)
A3(94, 46) = A3(94, 46) - v(87); % source1:FRD3_04:xfum#0111(14)
A3(94, 96) = A3(94, 96) - v(223); % source1:SUCCt22_03:xsucce#0111(14)
A3(94, 97) = A3(94, 97) - v(325); % source1:SUCFUMt_r_05:xsucce#1110(7)
A3(94, 93) = A3(94, 93) - v(214); % source1:SDPDS_02:xsl2a6o#00000001110(896)
A3(94, 96) = A3(94, 96) - v(325); % source1:SUCFUMt_r_16:xsucce#0111(14)
A3(94, 97) = A3(94, 97) - v(223); % source1:SUCCt22_04:xsucce#1110(7)
A3(94, 96) = A3(94, 96) - v(325); % source1:SUCFUMt_r_08:xsucce#0111(14)
A3(94, 8) = A3(94, 8) - v(221); % source1:SSALy_02:x4abut#0111(14)
A3(94, 92) = A3(94, 92) - v(214); % source1:SDPDS_03:xsl2a6o#00000000111(1792)
A3(94, 97) = A3(94, 97) - v(224); % source1:SUCCt23_04:xsucce#1110(7)
A3(94, 96) = A3(94, 96) - v(325); % source1:SUCFUMt_r_09:xsucce#0111(14)
A3(94, 96) = A3(94, 96) - v(224); % source1:SUCCt23_03:xsucce#0111(14)
A3(94, 96) = A3(94, 96) - v(222); % source1:SUCCabc_03:xsucce#0111(14)
A3(94, 97) = A3(94, 97) - v(325); % source1:SUCFUMt_r_14:xsucce#1110(7)
A3(94, 98) = A3(94, 98) - v(61); % source1:COMBO22_02:xsuccoa#0111(14)
A3(94, 96) = A3(94, 96) - v(224); % source1:SUCCt23_02:xsucce#0111(14)
A3(94, 8) = A3(94, 8) - v(220); % source1:SSALx_02:x4abut#0111(14)
A3(94, 97) = A3(94, 97) - v(325); % source1:SUCFUMt_r_04:xsucce#1110(7)
A3(94, 69) = A3(94, 69) - v(135); % source1:ICL_02:xicit#001110(28)
A3(94, 97) = A3(94, 97) - v(222); % source1:SUCCabc_04:xsucce#1110(7)
A3(94, 47) = A3(94, 47) - v(86); % source1:FRD2_03:xfum#1110(7)
A3(94, 9) = A3(94, 9) - v(221); % source1:SSALy_01:x4abut#1110(7)
A3(94, 97) = A3(94, 97) - v(223); % source1:SUCCt22_01:xsucce#1110(7)
A3(94, 96) = A3(94, 96) - v(222); % source1:SUCCabc_02:xsucce#0111(14)
A3(94, 97) = A3(94, 97) - v(224); % source1:SUCCt23_01:xsucce#1110(7)
A3(94, 96) = A3(94, 96) - v(325); % source1:SUCFUMt_r_01:xsucce#0111(14)
A3(94, 92) = A3(94, 92) - v(214); % source1:SDPDS_01:xsl2a6o#00000000111(1792)
A3(94, 97) = A3(94, 97) - v(325); % source1:SUCFUMt_r_13:xsucce#1110(7)
A3(94, 47) = A3(94, 47) - v(87); % source1:FRD3_03:xfum#1110(7)
A3(94, 9) = A3(94, 9) - v(220); % source1:SSALx_01:x4abut#1110(7)
A3(94, 96) = A3(94, 96) - v(325); % source1:SUCFUMt_r_15:xsucce#0111(14)
A3(94, 96) = A3(94, 96) - v(325); % source1:SUCFUMt_r_02:xsucce#0111(14)
A3(94, 97) = A3(94, 97) - v(222); % source1:SUCCabc_01:xsucce#1110(7)
A3(94, 97) = A3(94, 97) - v(325); % source1:SUCFUMt_r_03:xsucce#1110(7)
A3(94, 68) = A3(94, 68) - v(135); % source1:ICL_01:xicit#001101(44)
A3(94, 97) = A3(94, 97) - v(325); % source1:SUCFUMt_r_12:xsucce#1110(7)
A3(94, 93) = A3(94, 93) - v(214); % source1:SDPDS_04:xsl2a6o#00000001110(896)
A3(94, 46) = A3(94, 46) - v(86); % source1:FRD2_04:xfum#0111(14)
A3(94, 47) = A3(94, 47) - v(87); % source1:FRD3_02:xfum#1110(7)
A3(94, 98) = A3(94, 98) - v(326); % source1:SUCOAS_r_02:xsuccoa#0111(14)
A3(94, 46) = A3(94, 46) - v(86); % source1:FRD2_01:xfum#0111(14)
A3(94, 99) = A3(94, 99) - v(61); % source1:COMBO22_01:xsuccoa#1110(7)
A3(94, 96) = A3(94, 96) - v(223); % source1:SUCCt22_02:xsucce#0111(14)
A3(94, 47) = A3(94, 47) - v(86); % source1:FRD2_02:xfum#1110(7)
A3(94, 96) = A3(94, 96) - v(325); % source1:SUCFUMt_r_10:xsucce#0111(14)
%>>> xsucc#1110#
A3(95, 95) = v(229) + v(226) + v(228) + v(228) + v(225) + v(228) + v(225) + v(228) + v(228) + v(228) + v(228) + v(228) + v(228) + v(226) + v(228) + v(225) + v(228) + v(226) + v(228) + v(228) + v(228) + v(228) + v(228) + v(226) + v(225) + v(229); % drain :SUCOAS_02:SUCD1i_04:SUCFUMt_15:SUCFUMt_08:SUCCt2b_04:SUCFUMt_12:SUCCt2b_02:SUCFUMt_10:SUCFUMt_02:SUCFUMt_13:SUCFUMt_09:SUCFUMt_01:SUCFUMt_06:SUCD1i_03:SUCFUMt_03:SUCCt2b_03:SUCFUMt_14:SUCD1i_01:SUCFUMt_07:SUCFUMt_11:SUCFUMt_05:SUCFUMt_16:SUCFUMt_04:SUCD1i_02:SUCCt2b_01:SUCOAS_01 
A3(95, 96) = A3(95, 96) - v(325); % source1:SUCFUMt_r_11:xsucce#0111(14)
A3(95, 97) = A3(95, 97) - v(325); % source1:SUCFUMt_r_07:xsucce#1110(7)
A3(95, 47) = A3(95, 47) - v(87); % source1:FRD3_01:xfum#1110(7)
A3(95, 98) = A3(95, 98) - v(326); % source1:SUCOAS_r_01:xsuccoa#0111(14)
A3(95, 96) = A3(95, 96) - v(325); % source1:SUCFUMt_r_06:xsucce#0111(14)
A3(95, 47) = A3(95, 47) - v(87); % source1:FRD3_04:xfum#1110(7)
A3(95, 97) = A3(95, 97) - v(223); % source1:SUCCt22_03:xsucce#1110(7)
A3(95, 96) = A3(95, 96) - v(325); % source1:SUCFUMt_r_05:xsucce#0111(14)
A3(95, 92) = A3(95, 92) - v(214); % source1:SDPDS_02:xsl2a6o#00000000111(1792)
A3(95, 97) = A3(95, 97) - v(325); % source1:SUCFUMt_r_16:xsucce#1110(7)
A3(95, 96) = A3(95, 96) - v(223); % source1:SUCCt22_04:xsucce#0111(14)
A3(95, 97) = A3(95, 97) - v(325); % source1:SUCFUMt_r_08:xsucce#1110(7)
A3(95, 9) = A3(95, 9) - v(221); % source1:SSALy_02:x4abut#1110(7)
A3(95, 93) = A3(95, 93) - v(214); % source1:SDPDS_03:xsl2a6o#00000001110(896)
A3(95, 96) = A3(95, 96) - v(224); % source1:SUCCt23_04:xsucce#0111(14)
A3(95, 97) = A3(95, 97) - v(325); % source1:SUCFUMt_r_09:xsucce#1110(7)
A3(95, 97) = A3(95, 97) - v(224); % source1:SUCCt23_03:xsucce#1110(7)
A3(95, 97) = A3(95, 97) - v(222); % source1:SUCCabc_03:xsucce#1110(7)
A3(95, 96) = A3(95, 96) - v(325); % source1:SUCFUMt_r_14:xsucce#0111(14)
A3(95, 99) = A3(95, 99) - v(61); % source1:COMBO22_02:xsuccoa#1110(7)
A3(95, 97) = A3(95, 97) - v(224); % source1:SUCCt23_02:xsucce#1110(7)
A3(95, 9) = A3(95, 9) - v(220); % source1:SSALx_02:x4abut#1110(7)
A3(95, 96) = A3(95, 96) - v(325); % source1:SUCFUMt_r_04:xsucce#0111(14)
A3(95, 68) = A3(95, 68) - v(135); % source1:ICL_02:xicit#001101(44)
A3(95, 96) = A3(95, 96) - v(222); % source1:SUCCabc_04:xsucce#0111(14)
A3(95, 46) = A3(95, 46) - v(86); % source1:FRD2_03:xfum#0111(14)
A3(95, 8) = A3(95, 8) - v(221); % source1:SSALy_01:x4abut#0111(14)
A3(95, 96) = A3(95, 96) - v(223); % source1:SUCCt22_01:xsucce#0111(14)
A3(95, 97) = A3(95, 97) - v(222); % source1:SUCCabc_02:xsucce#1110(7)
A3(95, 96) = A3(95, 96) - v(224); % source1:SUCCt23_01:xsucce#0111(14)
A3(95, 97) = A3(95, 97) - v(325); % source1:SUCFUMt_r_01:xsucce#1110(7)
A3(95, 93) = A3(95, 93) - v(214); % source1:SDPDS_01:xsl2a6o#00000001110(896)
A3(95, 96) = A3(95, 96) - v(325); % source1:SUCFUMt_r_13:xsucce#0111(14)
A3(95, 46) = A3(95, 46) - v(87); % source1:FRD3_03:xfum#0111(14)
A3(95, 8) = A3(95, 8) - v(220); % source1:SSALx_01:x4abut#0111(14)
A3(95, 97) = A3(95, 97) - v(325); % source1:SUCFUMt_r_15:xsucce#1110(7)
A3(95, 97) = A3(95, 97) - v(325); % source1:SUCFUMt_r_02:xsucce#1110(7)
A3(95, 96) = A3(95, 96) - v(222); % source1:SUCCabc_01:xsucce#0111(14)
A3(95, 96) = A3(95, 96) - v(325); % source1:SUCFUMt_r_03:xsucce#0111(14)
A3(95, 69) = A3(95, 69) - v(135); % source1:ICL_01:xicit#001110(28)
A3(95, 96) = A3(95, 96) - v(325); % source1:SUCFUMt_r_12:xsucce#0111(14)
A3(95, 92) = A3(95, 92) - v(214); % source1:SDPDS_04:xsl2a6o#00000000111(1792)
A3(95, 47) = A3(95, 47) - v(86); % source1:FRD2_04:xfum#1110(7)
A3(95, 46) = A3(95, 46) - v(87); % source1:FRD3_02:xfum#0111(14)
A3(95, 99) = A3(95, 99) - v(326); % source1:SUCOAS_r_02:xsuccoa#1110(7)
A3(95, 47) = A3(95, 47) - v(86); % source1:FRD2_01:xfum#1110(7)
A3(95, 98) = A3(95, 98) - v(61); % source1:COMBO22_01:xsuccoa#0111(14)
A3(95, 97) = A3(95, 97) - v(223); % source1:SUCCt22_02:xsucce#1110(7)
A3(95, 46) = A3(95, 46) - v(86); % source1:FRD2_02:xfum#0111(14)
A3(95, 97) = A3(95, 97) - v(325); % source1:SUCFUMt_r_10:xsucce#1110(7)
%>>> xsucce#0111#
A3(96, 96) = v(325) + v(222) + v(325) + v(325) + v(223) + v(222) + v(224) + v(20) + v(223) + v(325) + v(325) + v(325) + v(325) + v(223) + v(325) + v(325) + v(325) + v(222) + v(224) + v(325) + v(325) + v(224) + v(325) + v(222) + v(325) + v(224) + v(223) + v(325) + v(325) + v(20); % drain :SUCFUMt_r_11:SUCCabc_04:SUCFUMt_r_07:SUCFUMt_r_06:SUCCt22_01:SUCCabc_02:SUCCt23_01:EX_succ_02:SUCCt22_03:SUCFUMt_r_05:SUCFUMt_r_01:SUCFUMt_r_16:SUCFUMt_r_13:SUCCt22_04:SUCFUMt_r_15:SUCFUMt_r_02:SUCFUMt_r_08:SUCCabc_01:SUCCt23_04:SUCFUMt_r_03:SUCFUMt_r_09:SUCCt23_03:SUCFUMt_r_12:SUCCabc_03:SUCFUMt_r_14:SUCCt23_02:SUCCt22_02:SUCFUMt_r_10:SUCFUMt_r_04:EX_succ_01 
A3(96, 94) = A3(96, 94) - v(228); % source1:SUCFUMt_15:xsucc#0111(14)
A3(96, 94) = A3(96, 94) - v(228); % source1:SUCFUMt_08:xsucc#0111(14)
A3(96, 95) = A3(96, 95) - v(225); % source1:SUCCt2b_04:xsucc#1110(7)
A3(96, 95) = A3(96, 95) - v(228); % source1:SUCFUMt_12:xsucc#1110(7)
A3(96, 94) = A3(96, 94) - v(225); % source1:SUCCt2b_02:xsucc#0111(14)
A3(96, 94) = A3(96, 94) - v(228); % source1:SUCFUMt_10:xsucc#0111(14)
A3(96, 94) = A3(96, 94) - v(228); % source1:SUCFUMt_02:xsucc#0111(14)
A3(96, 95) = A3(96, 95) - v(228); % source1:SUCFUMt_13:xsucc#1110(7)
A3(96, 94) = A3(96, 94) - v(228); % source1:SUCFUMt_09:xsucc#0111(14)
A3(96, 94) = A3(96, 94) - v(228); % source1:SUCFUMt_01:xsucc#0111(14)
A3(96, 95) = A3(96, 95) - v(228); % source1:SUCFUMt_06:xsucc#1110(7)
A3(96, 94) = A3(96, 94) - v(225); % source1:SUCCt2b_03:xsucc#0111(14)
A3(96, 95) = A3(96, 95) - v(228); % source1:SUCFUMt_03:xsucc#1110(7)
A3(96, 95) = A3(96, 95) - v(228); % source1:SUCFUMt_14:xsucc#1110(7)
A3(96, 94) = A3(96, 94) - v(228); % source1:SUCFUMt_07:xsucc#0111(14)
A3(96, 95) = A3(96, 95) - v(228); % source1:SUCFUMt_11:xsucc#1110(7)
A3(96, 95) = A3(96, 95) - v(228); % source1:SUCFUMt_05:xsucc#1110(7)
A3(96, 94) = A3(96, 94) - v(228); % source1:SUCFUMt_16:xsucc#0111(14)
A3(96, 95) = A3(96, 95) - v(228); % source1:SUCFUMt_04:xsucc#1110(7)
A3(96, 95) = A3(96, 95) - v(225); % source1:SUCCt2b_01:xsucc#1110(7)
%>>> xsucce#1110#
A3(97, 97) = v(325) + v(222) + v(325) + v(325) + v(223) + v(222) + v(224) + v(20) + v(223) + v(325) + v(325) + v(325) + v(325) + v(223) + v(325) + v(325) + v(325) + v(222) + v(224) + v(325) + v(325) + v(224) + v(325) + v(222) + v(325) + v(224) + v(223) + v(325) + v(325) + v(20); % drain :SUCFUMt_r_11:SUCCabc_04:SUCFUMt_r_07:SUCFUMt_r_06:SUCCt22_01:SUCCabc_02:SUCCt23_01:EX_succ_02:SUCCt22_03:SUCFUMt_r_05:SUCFUMt_r_01:SUCFUMt_r_16:SUCFUMt_r_13:SUCCt22_04:SUCFUMt_r_15:SUCFUMt_r_02:SUCFUMt_r_08:SUCCabc_01:SUCCt23_04:SUCFUMt_r_03:SUCFUMt_r_09:SUCCt23_03:SUCFUMt_r_12:SUCCabc_03:SUCFUMt_r_14:SUCCt23_02:SUCCt22_02:SUCFUMt_r_10:SUCFUMt_r_04:EX_succ_01 
A3(97, 95) = A3(97, 95) - v(228); % source1:SUCFUMt_15:xsucc#1110(7)
A3(97, 95) = A3(97, 95) - v(228); % source1:SUCFUMt_08:xsucc#1110(7)
A3(97, 94) = A3(97, 94) - v(225); % source1:SUCCt2b_04:xsucc#0111(14)
A3(97, 94) = A3(97, 94) - v(228); % source1:SUCFUMt_12:xsucc#0111(14)
A3(97, 95) = A3(97, 95) - v(225); % source1:SUCCt2b_02:xsucc#1110(7)
A3(97, 95) = A3(97, 95) - v(228); % source1:SUCFUMt_10:xsucc#1110(7)
A3(97, 95) = A3(97, 95) - v(228); % source1:SUCFUMt_02:xsucc#1110(7)
A3(97, 94) = A3(97, 94) - v(228); % source1:SUCFUMt_13:xsucc#0111(14)
A3(97, 95) = A3(97, 95) - v(228); % source1:SUCFUMt_09:xsucc#1110(7)
A3(97, 95) = A3(97, 95) - v(228); % source1:SUCFUMt_01:xsucc#1110(7)
A3(97, 94) = A3(97, 94) - v(228); % source1:SUCFUMt_06:xsucc#0111(14)
A3(97, 95) = A3(97, 95) - v(225); % source1:SUCCt2b_03:xsucc#1110(7)
A3(97, 94) = A3(97, 94) - v(228); % source1:SUCFUMt_03:xsucc#0111(14)
A3(97, 94) = A3(97, 94) - v(228); % source1:SUCFUMt_14:xsucc#0111(14)
A3(97, 95) = A3(97, 95) - v(228); % source1:SUCFUMt_07:xsucc#1110(7)
A3(97, 94) = A3(97, 94) - v(228); % source1:SUCFUMt_11:xsucc#0111(14)
A3(97, 94) = A3(97, 94) - v(228); % source1:SUCFUMt_05:xsucc#0111(14)
A3(97, 95) = A3(97, 95) - v(228); % source1:SUCFUMt_16:xsucc#1110(7)
A3(97, 94) = A3(97, 94) - v(228); % source1:SUCFUMt_04:xsucc#0111(14)
A3(97, 94) = A3(97, 94) - v(225); % source1:SUCCt2b_01:xsucc#0111(14)
%>>> xsuccoa#0111#
A3(98, 98) = v(326) + v(71) + v(61) + 3e-06*v(1) + v(61) + v(326); % drain :SUCOAS_r_02:COMBO26_01:COMBO22_02:BiomassEcoliGALUi_01:COMBO22_01:SUCOAS_r_01 
A3(98, 20) = A3(98, 20) - v(233); % source1:TESTAKGDH_01:xakg#00111(28)
A3(98, 94) = A3(98, 94) - v(229); % source1:SUCOAS_02:xsucc#0111(14)
A3(98, 95) = A3(98, 95) - v(229); % source1:SUCOAS_01:xsucc#1110(7)
%>>> xsuccoa#1110#
A3(99, 99) = v(326) + v(71) + v(61) + 3e-06*v(1) + v(61) + v(326); % drain :SUCOAS_r_02:COMBO26_01:COMBO22_02:BiomassEcoliGALUi_01:COMBO22_01:SUCOAS_r_01 
A3(99, 21) = A3(99, 21) - v(233); % source1:TESTAKGDH_01:xakg#01110(14)
A3(99, 95) = A3(99, 95) - v(229); % source1:SUCOAS_02:xsucc#1110(7)
A3(99, 94) = A3(99, 94) - v(229); % source1:SUCOAS_01:xsucc#0111(14)
%>>> xthrL#0111#
A3(100, 100) = v(237) + v(236) + 0.241*v(1) + v(112); % drain :THRDL_01:THRAr_01:BiomassEcoliGALUi_01:COMBO37_01 
B3(100,:) = B3(100,:) + conv(x2(157,:), x1(144,:)) * v(328); % source2:THRAr_r_01:xthrL#0011(12):xgly#01(2)
A3(100, 29) = A3(100, 29) - v(130); % source1:COMBO41_01:xaspsa#0111(14)
%>>> xtrpL#11100000000#
A3(101, 101) = v(242) + 0.054*v(1); % drain :TRPAS2_01:BiomassEcoliGALUi_01 
A3(101, 83) = A3(101, 83) - v(332); % source1:TRPAS2_r_01:xpyr#111(7)
A3(101, 91) = A3(101, 91) - v(244); % source1:TRPS2_01:xserL#111(7)
A3(101, 91) = A3(101, 91) - v(243); % source1:TRPS1_01:xserL#111(7)
%>>> xxu5pD#00111#
A3(102, 102) = v(239) + v(320) + v(238); % drain :TKT2_01:RPE_r_01:TKT1_01 
A3(102, 53) = A3(102, 53) - v(330); % source1:TKT2_r_01:xg3p#111(7)
A3(102, 86) = A3(102, 86) - v(212); % source1:RPE_01:xru5pD#00111(28)
A3(102, 53) = A3(102, 53) - v(329); % source1:TKT1_r_01:xg3p#111(7)
%>>> xxu5pD#01110#
A3(103, 103) = v(239) + v(320) + v(238); % drain :TKT2_01:RPE_r_01:TKT1_01 
B3(103,:) = B3(103,:) + conv(x2(82,:), x1(100,:)) * v(330); % source2:TKT2_r_01:xg3p#110(3):xf6p#010000(2)
A3(103, 87) = A3(103, 87) - v(212); % source1:RPE_01:xru5pD#01110(14)
B3(103,:) = B3(103,:) + conv(x2(82,:), x1(208,:)) * v(329); % source2:TKT1_r_01:xg3p#110(3):xs7p#0100000(2)
x3 = solveLin(A3, B3);  

% level: 4 of size 55
A4 = sparse(55, 55);
B4 = zeros(55, 5);
%>>> x1pyr5c#01111#
A4(1, 1) = v(182) + v(183); % drain :P5CD_01:P5CR_01 
A4(1, 31) = A4(1, 31) - v(97); % source1:G5SADs_01:xglu5sa#01111(30)
A4(1, 1) = A4(1, 1) - v(203); % source1:PROD2_01:x1pyr5c#01111(30)
%>>> x1pyr5c#11101#
A4(2, 2) = v(182) + v(183); % drain :P5CD_01:P5CR_01 
A4(2, 32) = A4(2, 32) - v(97); % source1:G5SADs_01:xglu5sa#11101(23)
A4(2, 2) = A4(2, 2) - v(203); % source1:PROD2_01:x1pyr5c#11101(23)
%>>> x2kmb#01111#
A4(3, 3) = v(249); % drain :UNK3_01 
A4(3, 19) = A4(3, 19) - v(74); % source1:DKMPPD2_01:xdkmpp#001111(60)
A4(3, 19) = A4(3, 19) - v(73); % source1:DKMPPD_01:xdkmpp#001111(60)
%>>> x3mob#01111#
A4(4, 4) = v(141) + v(334) + v(258) + v(258); % drain :IPPS_01:VALTA_r_01:COASYN_02:COASYN_01 
A4(4, 4) = A4(4, 4) - v(250); % source1:VALTA_01:x3mob#01111(30)
B4(4,:) = B4(4,:) + conv(x2(130,:), x2(130,:)) * v(69); % source2:DHAD1_01:xpyr#011(6):xpyr#011(6)
%>>> x4abut#1111#
A4(5, 5) = v(21); % drain :ABTA_01 
A4(5, 42) = A4(5, 42) - v(22); % source1:COMBO2_01:xptrc#1111(15)
A4(5, 33) = A4(5, 33) - v(107); % source1:GLUDC_01:xgluL#01111(30)
A4(5, 42) = A4(5, 42) - v(22); % source1:COMBO2_02:xptrc#1111(15)
%>>> x4pasp#1111#
A4(6, 6) = v(281) + v(282); % drain :ASAD_r_01:ASPK_r_01 
A4(6, 15) = A4(6, 15) - v(46); % source1:ASAD_01:xaspsa#1111(15)
A4(6, 14) = A4(6, 14) - v(50); % source1:ASPK_01:xaspL#1111(15)
%>>> xacg5p#0111100#
A4(7, 7) = v(277); % drain :AGPR_r_01 
A4(7, 9) = A4(7, 9) - v(39); % source1:AGPR_01:xacg5sa#0111100(30)
A4(7, 33) = A4(7, 33) - v(24); % source1:COMBO3_01:xgluL#01111(30)
%>>> xacg5p#1110100#
A4(8, 8) = v(277); % drain :AGPR_r_01 
A4(8, 10) = A4(8, 10) - v(39); % source1:AGPR_01:xacg5sa#1110100(23)
A4(8, 34) = A4(8, 34) - v(24); % source1:COMBO3_01:xgluL#11101(23)
%>>> xacg5sa#0111100#
A4(9, 9) = v(157) + v(274) + v(39); % drain :NACODA_01:ACOTA_r_01:AGPR_01 
A4(9, 7) = A4(9, 7) - v(277); % source1:AGPR_r_01:xacg5p#0111100(30)
A4(9, 9) = A4(9, 9) - v(30); % source1:ACOTA_01:xacg5sa#0111100(30)
%>>> xacg5sa#1110100#
A4(10, 10) = v(157) + v(274) + v(39); % drain :NACODA_01:ACOTA_r_01:AGPR_01 
A4(10, 8) = A4(10, 8) - v(277); % source1:AGPR_r_01:xacg5p#1110100(23)
A4(10, 10) = A4(10, 10) - v(30); % source1:ACOTA_01:xacg5sa#1110100(23)
%>>> xakg#01111#
A4(11, 11) = v(215) + v(110) + v(297) + v(247) + v(247) + v(250) + v(247) + v(41) + v(110) + v(22) + v(301) + v(193) + v(233) + v(247) + v(193) + v(30) + v(22) + v(51) + v(21) + v(193) + v(193) + v(136); % drain :SDPTA_01:GLUSy_02:GLUDy_r_01:TYRTA_04:TYRTA_02:VALTA_01:TYRTA_01:ALATAL_01:GLUSy_01:COMBO2_02:ICDHyr_r_01:PHETA1_04:TESTAKGDH_01:TYRTA_03:PHETA1_01:ACOTA_01:COMBO2_01:ASPTA_01:ABTA_01:PHETA1_02:PHETA1_03:ILETA_01 
A4(11, 33) = A4(11, 33) - v(333); % source1:TYRTA_r_04:xgluL#01111(30)
A4(11, 33) = A4(11, 33) - v(315); % source1:PHETA1_r_03:xgluL#01111(30)
A4(11, 33) = A4(11, 33) - v(274); % source1:ACOTA_r_01:xgluL#01111(30)
A4(11, 33) = A4(11, 33) - v(322); % source1:SDPTA_r_01:xgluL#01111(30)
A4(11, 33) = A4(11, 33) - v(147); % source1:LEUTAi_01:xgluL#01111(30)
A4(11, 33) = A4(11, 33) - v(334); % source1:VALTA_r_01:xgluL#01111(30)
A4(11, 33) = A4(11, 33) - v(333); % source1:TYRTA_r_02:xgluL#01111(30)
A4(11, 33) = A4(11, 33) - v(302); % source1:ILETA_r_01:xgluL#01111(30)
A4(11, 33) = A4(11, 33) - v(187); % source1:COMBO47_01:xgluL#01111(30)
A4(11, 33) = A4(11, 33) - v(315); % source1:PHETA1_r_02:xgluL#01111(30)
A4(11, 33) = A4(11, 33) - v(315); % source1:PHETA1_r_04:xgluL#01111(30)
A4(11, 33) = A4(11, 33) - v(249); % source1:UNK3_01:xgluL#01111(30)
A4(11, 33) = A4(11, 33) - v(333); % source1:TYRTA_r_01:xgluL#01111(30)
A4(11, 33) = A4(11, 33) - v(279); % source1:ALATAL_r_01:xgluL#01111(30)
A4(11, 33) = A4(11, 33) - v(251); % source1:HISSYN_01:xgluL#01111(30)
A4(11, 33) = A4(11, 33) - v(283); % source1:ASPTA_r_01:xgluL#01111(30)
A4(11, 36) = A4(11, 36) - v(134); % source1:ICDHyr_01:xicit#011110(30)
A4(11, 33) = A4(11, 33) - v(108); % source1:GLUDy_01:xgluL#01111(30)
A4(11, 33) = A4(11, 33) - v(333); % source1:TYRTA_r_03:xgluL#01111(30)
A4(11, 33) = A4(11, 33) - v(315); % source1:PHETA1_r_01:xgluL#01111(30)
%>>> xakg#11101#
A4(12, 12) = v(215) + v(110) + v(297) + v(247) + v(247) + v(250) + v(247) + v(41) + v(110) + v(22) + v(301) + v(193) + v(233) + v(247) + v(193) + v(30) + v(22) + v(51) + v(21) + v(193) + v(193) + v(136); % drain :SDPTA_01:GLUSy_02:GLUDy_r_01:TYRTA_04:TYRTA_02:VALTA_01:TYRTA_01:ALATAL_01:GLUSy_01:COMBO2_02:ICDHyr_r_01:PHETA1_04:TESTAKGDH_01:TYRTA_03:PHETA1_01:ACOTA_01:COMBO2_01:ASPTA_01:ABTA_01:PHETA1_02:PHETA1_03:ILETA_01 
A4(12, 34) = A4(12, 34) - v(333); % source1:TYRTA_r_04:xgluL#11101(23)
A4(12, 34) = A4(12, 34) - v(315); % source1:PHETA1_r_03:xgluL#11101(23)
A4(12, 34) = A4(12, 34) - v(274); % source1:ACOTA_r_01:xgluL#11101(23)
A4(12, 34) = A4(12, 34) - v(322); % source1:SDPTA_r_01:xgluL#11101(23)
A4(12, 34) = A4(12, 34) - v(147); % source1:LEUTAi_01:xgluL#11101(23)
A4(12, 34) = A4(12, 34) - v(334); % source1:VALTA_r_01:xgluL#11101(23)
A4(12, 34) = A4(12, 34) - v(333); % source1:TYRTA_r_02:xgluL#11101(23)
A4(12, 34) = A4(12, 34) - v(302); % source1:ILETA_r_01:xgluL#11101(23)
A4(12, 34) = A4(12, 34) - v(187); % source1:COMBO47_01:xgluL#11101(23)
A4(12, 34) = A4(12, 34) - v(315); % source1:PHETA1_r_02:xgluL#11101(23)
A4(12, 34) = A4(12, 34) - v(315); % source1:PHETA1_r_04:xgluL#11101(23)
A4(12, 34) = A4(12, 34) - v(249); % source1:UNK3_01:xgluL#11101(23)
A4(12, 34) = A4(12, 34) - v(333); % source1:TYRTA_r_01:xgluL#11101(23)
A4(12, 34) = A4(12, 34) - v(279); % source1:ALATAL_r_01:xgluL#11101(23)
A4(12, 34) = A4(12, 34) - v(251); % source1:HISSYN_01:xgluL#11101(23)
A4(12, 34) = A4(12, 34) - v(283); % source1:ASPTA_r_01:xgluL#11101(23)
A4(12, 37) = A4(12, 37) - v(134); % source1:ICDHyr_01:xicit#111010(23)
A4(12, 34) = A4(12, 34) - v(108); % source1:GLUDy_01:xgluL#11101(23)
A4(12, 34) = A4(12, 34) - v(333); % source1:TYRTA_r_03:xgluL#11101(23)
A4(12, 34) = A4(12, 34) - v(315); % source1:PHETA1_r_01:xgluL#11101(23)
%>>> xargsuc#0000001111#
A4(13, 13) = v(44) + v(44); % drain :ARGSL_01:ARGSL_02 
A4(13, 25) = A4(13, 25) - v(280); % source1:ARGSL_r_01:xfum#1111(15)
A4(13, 14) = A4(13, 14) - v(45); % source1:ARGSS_01:xaspL#1111(15)
A4(13, 25) = A4(13, 25) - v(280); % source1:ARGSL_r_02:xfum#1111(15)
%>>> xaspL#1111#
A4(14, 14) = v(45) + v(256) + v(38) + v(255) + v(38) + 0.229*v(1) + v(48) + v(256) + v(252) + v(50) + v(267) + v(51) + v(268) + v(253) + v(255) + v(258) + v(258); % drain :ARGSS_01:IMPSYN2_02:COMBO10_02:IMPSYN1_01:COMBO10_01:BiomassEcoliGALUi_01:ASNS1_01:IMPSYN2_01:UMPSYN1_01:ASPK_01:NADSYN1_01:ASPTA_01:NADSYN2_01:UMPSYN2_01:IMPSYN1_02:COASYN_02:COASYN_01 
A4(14, 14) = A4(14, 14) - v(47); % source1:ASNN_01:xaspL#1111(15)
A4(14, 40) = A4(14, 40) - v(283); % source1:ASPTA_r_01:xoaa#1111(15)
A4(14, 6) = A4(14, 6) - v(282); % source1:ASPK_r_01:x4pasp#1111(15)
%>>> xaspsa#1111#
A4(15, 15) = v(71) + v(46) + v(300); % drain :COMBO26_01:ASAD_01:HSDy_r_01 
A4(15, 15) = A4(15, 15) - v(129); % source1:HSDy_01:xaspsa#1111(15)
A4(15, 6) = A4(15, 6) - v(281); % source1:ASAD_r_01:x4pasp#1111(15)
%>>> xcit#001111#
A4(16, 16) = v(29); % drain :rACONT_01 
A4(16, 35) = A4(16, 35) - v(273); % source1:rACONT_r_01:xicit#001111(60)
B4(16,:) = B4(16,:) + conv(x2(20,:), x2(119,:)) * v(58); % source2:CS_01:xaccoa#11(3):xoaa#1100(3)
%>>> xcit#011110#
A4(17, 17) = v(29); % drain :rACONT_01 
A4(17, 36) = A4(17, 36) - v(273); % source1:rACONT_r_01:xicit#011110(30)
B4(17,:) = B4(17,:) + conv(x2(20,:), x2(118,:)) * v(58); % source2:CS_01:xaccoa#11(3):xoaa#0110(6)
%>>> xcit#111010#
A4(18, 18) = v(29); % drain :rACONT_01 
A4(18, 37) = A4(18, 37) - v(273); % source1:rACONT_r_01:xicit#111010(23)
B4(18,:) = B4(18,:) + conv(x1(37,:), x3(76,:)) * v(58); % source2:CS_01:xaccoa#10(1):xoaa#0111(14)
%>>> xdkmpp#001111#
A4(19, 19) = v(74) + v(73); % drain :DKMPPD2_01:DKMPPD_01 
B4(19,:) = B4(19,:) + conv(x1(170,:), x3(84,:)) * v(36); % source2:COMBOSPMD_02:xmetL#00001(16):xr5p#00111(28)
B4(19,:) = B4(19,:) + conv(x1(170,:), x3(84,:)) * v(36); % source2:COMBOSPMD_01:xmetL#00001(16):xr5p#00111(28)
%>>> xe4p#1111#
A4(20, 20) = v(239) + v(68) + v(327); % drain :TKT2_01:COMBO25_01:TALA_r_01 
A4(20, 21) = A4(20, 21) - v(330); % source1:TKT2_r_01:xf6p#001111(60)
A4(20, 47) = A4(20, 47) - v(232); % source1:TALA_01:xs7p#0001111(120)
%>>> xf6p#001111#
A4(21, 21) = v(327) + v(311) + v(330) + v(185) + 2*v(266) + v(79) + 2*v(266) + v(79) + 2*v(265); % drain :TALA_r_01:PGI_r_01:TKT2_r_01:PFK_01:PEPTIDOSYN_01:F6PA_02:PEPTIDOSYN_02:F6PA_01:LPSSYN_01 
A4(21, 20) = A4(21, 20) - v(239); % source1:TKT2_01:xe4p#1111(15)
A4(21, 23) = A4(21, 23) - v(81); % source1:FBP_01:xfdp#001111(60)
B4(21,:) = B4(21,:) + conv(x3(53,:), x1(81,:)) * v(290); % source2:F6PA_r_02:xg3p#111(7):xdha#001(4)
B4(21,:) = B4(21,:) + conv(x3(53,:), x1(83,:)) * v(290); % source2:F6PA_r_01:xg3p#111(7):xdha#100(1)
B4(21,:) = B4(21,:) + conv(x3(53,:), x1(207,:)) * v(232); % source2:TALA_01:xg3p#111(7):xs7p#0010000(4)
A4(21, 29) = A4(21, 29) - v(188); % source1:PGI_01:xg6p#001111(60)
%>>> xf6p#011110#
A4(22, 22) = v(327) + v(311) + v(330) + v(185) + 2*v(266) + v(79) + 2*v(266) + v(79) + 2*v(265); % drain :TALA_r_01:PGI_r_01:TKT2_r_01:PFK_01:PEPTIDOSYN_01:F6PA_02:PEPTIDOSYN_02:F6PA_01:LPSSYN_01 
B4(22,:) = B4(22,:) + conv(x1(242,:), x3(39,:)) * v(239); % source2:TKT2_01:xxu5pD#01000(2):xe4p#1110(7)
A4(22, 24) = A4(22, 24) - v(81); % source1:FBP_01:xfdp#011110(30)
B4(22,:) = B4(22,:) + conv(x2(82,:), x2(56,:)) * v(290); % source2:F6PA_r_02:xg3p#110(3):xdha#011(6)
B4(22,:) = B4(22,:) + conv(x2(82,:), x2(57,:)) * v(290); % source2:F6PA_r_01:xg3p#110(3):xdha#110(3)
B4(22,:) = B4(22,:) + conv(x2(82,:), x2(141,:)) * v(232); % source2:TALA_01:xg3p#110(3):xs7p#0110000(6)
A4(22, 30) = A4(22, 30) - v(188); % source1:PGI_01:xg6p#011110(30)
%>>> xfdp#001111#
A4(23, 23) = v(81) + v(80); % drain :FBP_01:FBA_01 
A4(23, 21) = A4(23, 21) - v(185); % source1:PFK_01:xf6p#001111(60)
B4(23,:) = B4(23,:) + conv(x1(84,:), x3(53,:)) * v(291); % source2:FBA_r_01:xdhap#001(4):xg3p#111(7)
%>>> xfdp#011110#
A4(24, 24) = v(81) + v(80); % drain :FBP_01:FBA_01 
A4(24, 22) = A4(24, 22) - v(185); % source1:PFK_01:xf6p#011110(30)
B4(24,:) = B4(24,:) + conv(x2(58,:), x2(82,:)) * v(291); % source2:FBA_r_01:xdhap#011(6):xg3p#110(3)
%>>> xfum#1111#
A4(25, 25) = v(325) + v(325) + v(86) + v(87) + v(325) + v(87) + v(325) + v(325) + v(325) + v(325) + v(87) + v(325) + v(325) + v(325) + v(89) + v(325) + v(325) + v(325) + v(86) + v(325) + v(87) + v(86) + v(280) + v(280) + v(86) + v(89) + v(325) + v(325); % drain :SUCFUMt_r_11:SUCFUMt_r_07:FRD2_03:FRD3_01:SUCFUMt_r_06:FRD3_04:SUCFUMt_r_05:SUCFUMt_r_01:SUCFUMt_r_16:SUCFUMt_r_13:FRD3_03:SUCFUMt_r_15:SUCFUMt_r_02:SUCFUMt_r_08:rFUM_01:SUCFUMt_r_03:SUCFUMt_r_09:SUCFUMt_r_12:FRD2_04:SUCFUMt_r_14:FRD3_02:FRD2_01:ARGSL_r_01:ARGSL_r_02:FRD2_02:rFUM_02:SUCFUMt_r_10:SUCFUMt_r_04 
A4(25, 38) = A4(25, 38) - v(293); % source1:rFUM_r_02:xmalL#1111(15)
A4(25, 50) = A4(25, 50) - v(226); % source1:SUCD1i_04:xsucc#1111(15)
A4(25, 26) = A4(25, 26) - v(228); % source1:SUCFUMt_08:xfume#1111(15)
A4(25, 14) = A4(25, 14) - v(38); % source1:COMBO10_01:xaspL#1111(15)
A4(25, 26) = A4(25, 26) - v(228); % source1:SUCFUMt_12:xfume#1111(15)
A4(25, 13) = A4(25, 13) - v(44); % source1:ARGSL_02:xargsuc#0000001111(960)
A4(25, 26) = A4(25, 26) - v(228); % source1:SUCFUMt_02:xfume#1111(15)
A4(25, 26) = A4(25, 26) - v(228); % source1:SUCFUMt_13:xfume#1111(15)
A4(25, 26) = A4(25, 26) - v(228); % source1:SUCFUMt_09:xfume#1111(15)
A4(25, 26) = A4(25, 26) - v(90); % source1:FUMt22_03:xfume#1111(15)
A4(25, 50) = A4(25, 50) - v(226); % source1:SUCD1i_03:xsucc#1111(15)
A4(25, 26) = A4(25, 26) - v(228); % source1:SUCFUMt_03:xfume#1111(15)
A4(25, 14) = A4(25, 14) - v(256); % source1:IMPSYN2_02:xaspL#1111(15)
A4(25, 14) = A4(25, 14) - v(38); % source1:COMBO10_02:xaspL#1111(15)
A4(25, 14) = A4(25, 14) - v(255); % source1:IMPSYN1_01:xaspL#1111(15)
A4(25, 26) = A4(25, 26) - v(228); % source1:SUCFUMt_07:xfume#1111(15)
A4(25, 26) = A4(25, 26) - v(228); % source1:SUCFUMt_11:xfume#1111(15)
A4(25, 26) = A4(25, 26) - v(228); % source1:SUCFUMt_05:xfume#1111(15)
A4(25, 26) = A4(25, 26) - v(228); % source1:SUCFUMt_16:xfume#1111(15)
A4(25, 26) = A4(25, 26) - v(90); % source1:FUMt22_01:xfume#1111(15)
A4(25, 14) = A4(25, 14) - v(255); % source1:IMPSYN1_02:xaspL#1111(15)
A4(25, 26) = A4(25, 26) - v(228); % source1:SUCFUMt_15:xfume#1111(15)
A4(25, 26) = A4(25, 26) - v(91); % source1:FUMt23_03:xfume#1111(15)
A4(25, 26) = A4(25, 26) - v(228); % source1:SUCFUMt_10:xfume#1111(15)
A4(25, 26) = A4(25, 26) - v(91); % source1:FUMt23_02:xfume#1111(15)
A4(25, 26) = A4(25, 26) - v(228); % source1:SUCFUMt_01:xfume#1111(15)
A4(25, 26) = A4(25, 26) - v(228); % source1:SUCFUMt_06:xfume#1111(15)
A4(25, 26) = A4(25, 26) - v(228); % source1:SUCFUMt_14:xfume#1111(15)
A4(25, 50) = A4(25, 50) - v(226); % source1:SUCD1i_01:xsucc#1111(15)
A4(25, 26) = A4(25, 26) - v(90); % source1:FUMt22_04:xfume#1111(15)
A4(25, 26) = A4(25, 26) - v(91); % source1:FUMt23_04:xfume#1111(15)
A4(25, 14) = A4(25, 14) - v(256); % source1:IMPSYN2_01:xaspL#1111(15)
A4(25, 26) = A4(25, 26) - v(91); % source1:FUMt23_01:xfume#1111(15)
A4(25, 26) = A4(25, 26) - v(90); % source1:FUMt22_02:xfume#1111(15)
A4(25, 13) = A4(25, 13) - v(44); % source1:ARGSL_01:xargsuc#0000001111(960)
A4(25, 38) = A4(25, 38) - v(293); % source1:rFUM_r_01:xmalL#1111(15)
A4(25, 26) = A4(25, 26) - v(228); % source1:SUCFUMt_04:xfume#1111(15)
A4(25, 50) = A4(25, 50) - v(226); % source1:SUCD1i_02:xsucc#1111(15)
%>>> xfume#1111#
A4(26, 26) = v(228) + v(228) + v(228) + v(91) + v(228) + v(228) + v(91) + v(228) + v(228) + v(228) + v(228) + v(90) + v(228) + v(6) + v(228) + v(90) + v(228) + v(91) + v(90) + v(91) + v(6) + v(228) + v(228) + v(228) + v(90) + v(228); % drain :SUCFUMt_15:SUCFUMt_08:SUCFUMt_12:FUMt23_03:SUCFUMt_10:SUCFUMt_02:FUMt23_02:SUCFUMt_13:SUCFUMt_09:SUCFUMt_01:SUCFUMt_06:FUMt22_03:SUCFUMt_03:EX_fum_01:SUCFUMt_14:FUMt22_04:SUCFUMt_07:FUMt23_04:FUMt22_02:FUMt23_01:EX_fum_02:SUCFUMt_11:SUCFUMt_05:SUCFUMt_16:FUMt22_01:SUCFUMt_04 
A4(26, 25) = A4(26, 25) - v(325); % source1:SUCFUMt_r_11:xfum#1111(15)
A4(26, 25) = A4(26, 25) - v(325); % source1:SUCFUMt_r_07:xfum#1111(15)
A4(26, 25) = A4(26, 25) - v(325); % source1:SUCFUMt_r_06:xfum#1111(15)
A4(26, 25) = A4(26, 25) - v(325); % source1:SUCFUMt_r_01:xfum#1111(15)
A4(26, 25) = A4(26, 25) - v(325); % source1:SUCFUMt_r_05:xfum#1111(15)
A4(26, 25) = A4(26, 25) - v(325); % source1:SUCFUMt_r_16:xfum#1111(15)
A4(26, 25) = A4(26, 25) - v(325); % source1:SUCFUMt_r_13:xfum#1111(15)
A4(26, 25) = A4(26, 25) - v(325); % source1:SUCFUMt_r_02:xfum#1111(15)
A4(26, 25) = A4(26, 25) - v(325); % source1:SUCFUMt_r_15:xfum#1111(15)
A4(26, 25) = A4(26, 25) - v(325); % source1:SUCFUMt_r_08:xfum#1111(15)
A4(26, 25) = A4(26, 25) - v(325); % source1:SUCFUMt_r_03:xfum#1111(15)
A4(26, 25) = A4(26, 25) - v(325); % source1:SUCFUMt_r_09:xfum#1111(15)
A4(26, 25) = A4(26, 25) - v(325); % source1:SUCFUMt_r_12:xfum#1111(15)
A4(26, 25) = A4(26, 25) - v(325); % source1:SUCFUMt_r_14:xfum#1111(15)
A4(26, 25) = A4(26, 25) - v(325); % source1:SUCFUMt_r_10:xfum#1111(15)
A4(26, 25) = A4(26, 25) - v(325); % source1:SUCFUMt_r_04:xfum#1111(15)
%>>> xg1p#001111#
A4(27, 27) = v(104) + 0.003*v(1) + v(92) + 2*v(265) + v(192); % drain :COMBO36_01:BiomassEcoliGALUi_01:G1PP_01:LPSSYN_01:PGMT_01 
A4(27, 29) = A4(27, 29) - v(314); % source1:PGMT_r_01:xg6p#001111(60)
A4(27, 27) = A4(27, 27) - v(103); % source1:GLCP_01:xg1p#001111(60)
%>>> xg1p#011110#
A4(28, 28) = v(104) + 0.003*v(1) + v(92) + 2*v(265) + v(192); % drain :COMBO36_01:BiomassEcoliGALUi_01:G1PP_01:LPSSYN_01:PGMT_01 
A4(28, 30) = A4(28, 30) - v(314); % source1:PGMT_r_01:xg6p#011110(30)
A4(28, 28) = A4(28, 28) - v(103); % source1:GLCP_01:xg1p#011110(30)
%>>> xg6p#001111#
A4(29, 29) = v(99) + v(314) + v(188); % drain :G6PDH2r_01:PGMT_r_01:PGI_01 
A4(29, 27) = A4(29, 27) - v(128); % source1:HEX1_01:xg1p#001111(60)
A4(29, 29) = A4(29, 29) - v(295); % source1:G6PDH2r_r_01:xg6p#001111(60)
A4(29, 21) = A4(29, 21) - v(311); % source1:PGI_r_01:xf6p#001111(60)
B4(29,:) = B4(29,:) + xglcDe.x001111' * v(105); % source1:GLCpts_01:xglcDe#001111(60)
A4(29, 27) = A4(29, 27) - v(192); % source1:PGMT_01:xg1p#001111(60)
%>>> xg6p#011110#
A4(30, 30) = v(99) + v(314) + v(188); % drain :G6PDH2r_01:PGMT_r_01:PGI_01 
A4(30, 28) = A4(30, 28) - v(128); % source1:HEX1_01:xg1p#011110(30)
A4(30, 30) = A4(30, 30) - v(295); % source1:G6PDH2r_r_01:xg6p#011110(30)
A4(30, 22) = A4(30, 22) - v(311); % source1:PGI_r_01:xf6p#011110(30)
B4(30,:) = B4(30,:) + xglcDe.x011110' * v(105); % source1:GLCpts_01:xglcDe#011110(30)
A4(30, 28) = A4(30, 28) - v(192); % source1:PGMT_01:xg1p#011110(30)
%>>> xglu5sa#01111#
A4(31, 31) = v(97); % drain :G5SADs_01 
A4(31, 9) = A4(31, 9) - v(157); % source1:NACODA_01:xacg5sa#0111100(30)
A4(31, 33) = A4(31, 33) - v(98); % source1:COMBO34_01:xgluL#01111(30)
%>>> xglu5sa#11101#
A4(32, 32) = v(97); % drain :G5SADs_01 
A4(32, 10) = A4(32, 10) - v(157); % source1:NACODA_01:xacg5sa#1110100(23)
A4(32, 34) = A4(32, 34) - v(98); % source1:COMBO34_01:xgluL#11101(23)
%>>> xgluL#01111#
A4(33, 33) = v(333) + v(315) + v(274) + v(98) + v(24) + v(322) + v(147) + v(334) + v(333) + v(302) + v(187) + 0.25*v(1) + v(315) + v(315) + v(107) + v(249) + v(333) + v(279) + v(106) + v(283) + v(108) + v(333) + v(315); % drain :TYRTA_r_04:PHETA1_r_03:ACOTA_r_01:COMBO34_01:COMBO3_01:SDPTA_r_01:LEUTAi_01:VALTA_r_01:TYRTA_r_02:ILETA_r_01:COMBO47_01:BiomassEcoliGALUi_01:PHETA1_r_02:PHETA1_r_04:GLUDC_01:UNK3_01:TYRTA_r_01:ALATAL_r_01:GLNS_01:ASPTA_r_01:GLUDy_01:TYRTA_r_03:PHETA1_r_01 
A4(33, 33) = A4(33, 33) - v(124); % source1:GMPS2_01:xgluL#01111(30)
A4(33, 11) = A4(33, 11) - v(297); % source1:GLUDy_r_01:xakg#01111(30)
A4(33, 11) = A4(33, 11) - v(247); % source1:TYRTA_04:xakg#01111(30)
A4(33, 11) = A4(33, 11) - v(247); % source1:TYRTA_02:xakg#01111(30)
A4(33, 11) = A4(33, 11) - v(250); % source1:VALTA_01:xakg#01111(30)
A4(33, 11) = A4(33, 11) - 2*v(110); % source1:GLUSy_01:xakg#01111(30)
A4(33, 33) = A4(33, 33) - v(266); % source1:PEPTIDOSYN_02:xgluL#01111(30)
A4(33, 33) = A4(33, 33) - 2*v(265); % source1:LPSSYN_01:xgluL#01111(30)
A4(33, 33) = A4(33, 33) - 2*v(256); % source1:IMPSYN2_02:xgluL#01111(30)
A4(33, 34) = A4(33, 34) - 2*v(255); % source1:IMPSYN1_01:xgluL#11101(23)
A4(33, 11) = A4(33, 11) - v(247); % source1:TYRTA_03:xakg#01111(30)
A4(33, 11) = A4(33, 11) - v(193); % source1:PHETA1_01:xakg#01111(30)
A4(33, 11) = A4(33, 11) - v(30); % source1:ACOTA_01:xakg#01111(30)
A4(33, 11) = A4(33, 11) - v(22); % source1:COMBO2_01:xakg#01111(30)
A4(33, 33) = A4(33, 33) - v(266); % source1:PEPTIDOSYN_01:xgluL#01111(30)
A4(33, 11) = A4(33, 11) - v(51); % source1:ASPTA_01:xakg#01111(30)
A4(33, 11) = A4(33, 11) - v(21); % source1:ABTA_01:xakg#01111(30)
A4(33, 11) = A4(33, 11) - v(193); % source1:PHETA1_03:xakg#01111(30)
A4(33, 33) = A4(33, 33) - 2*v(255); % source1:IMPSYN1_02:xgluL#01111(30)
A4(33, 33) = A4(33, 33) - v(109); % source1:GLUN_01:xgluL#01111(30)
A4(33, 11) = A4(33, 11) - v(136); % source1:ILETA_01:xakg#01111(30)
A4(33, 33) = A4(33, 33) - 2*v(110); % source1:GLUSy_02:xgluL#01111(30)
A4(33, 1) = A4(33, 1) - v(182); % source1:P5CD_01:x1pyr5c#01111(30)
A4(33, 11) = A4(33, 11) - v(215); % source1:SDPTA_01:xakg#01111(30)
A4(33, 33) = A4(33, 33) - v(48); % source1:ASNS1_01:xgluL#01111(30)
A4(33, 33) = A4(33, 33) - v(254); % source1:CTPSYN_01:xgluL#01111(30)
A4(33, 11) = A4(33, 11) - v(41); % source1:ALATAL_01:xakg#01111(30)
A4(33, 11) = A4(33, 11) - v(247); % source1:TYRTA_01:xakg#01111(30)
A4(33, 11) = A4(33, 11) - v(22); % source1:COMBO2_02:xakg#01111(30)
A4(33, 11) = A4(33, 11) - v(193); % source1:PHETA1_04:xakg#01111(30)
A4(33, 33) = A4(33, 33) - v(54); % source1:CBPS_01:xgluL#01111(30)
A4(33, 33) = A4(33, 33) - 2*v(256); % source1:IMPSYN2_01:xgluL#01111(30)
A4(33, 33) = A4(33, 33) - v(43); % source1:COMBO15_01:xgluL#01111(30)
A4(33, 11) = A4(33, 11) - v(193); % source1:PHETA1_02:xakg#01111(30)
%>>> xgluL#11101#
A4(34, 34) = v(333) + v(315) + v(274) + v(98) + v(24) + v(322) + v(147) + v(334) + v(333) + v(302) + v(187) + 0.25*v(1) + v(315) + v(315) + v(107) + v(249) + v(333) + v(279) + v(106) + v(283) + v(108) + v(333) + v(315); % drain :TYRTA_r_04:PHETA1_r_03:ACOTA_r_01:COMBO34_01:COMBO3_01:SDPTA_r_01:LEUTAi_01:VALTA_r_01:TYRTA_r_02:ILETA_r_01:COMBO47_01:BiomassEcoliGALUi_01:PHETA1_r_02:PHETA1_r_04:GLUDC_01:UNK3_01:TYRTA_r_01:ALATAL_r_01:GLNS_01:ASPTA_r_01:GLUDy_01:TYRTA_r_03:PHETA1_r_01 
A4(34, 34) = A4(34, 34) - v(124); % source1:GMPS2_01:xgluL#11101(23)
A4(34, 12) = A4(34, 12) - v(297); % source1:GLUDy_r_01:xakg#11101(23)
A4(34, 12) = A4(34, 12) - v(247); % source1:TYRTA_04:xakg#11101(23)
A4(34, 12) = A4(34, 12) - v(247); % source1:TYRTA_02:xakg#11101(23)
A4(34, 12) = A4(34, 12) - v(250); % source1:VALTA_01:xakg#11101(23)
A4(34, 12) = A4(34, 12) - 2*v(110); % source1:GLUSy_01:xakg#11101(23)
A4(34, 34) = A4(34, 34) - v(266); % source1:PEPTIDOSYN_02:xgluL#11101(23)
A4(34, 34) = A4(34, 34) - 2*v(265); % source1:LPSSYN_01:xgluL#11101(23)
A4(34, 34) = A4(34, 34) - 2*v(256); % source1:IMPSYN2_02:xgluL#11101(23)
A4(34, 33) = A4(34, 33) - 2*v(255); % source1:IMPSYN1_01:xgluL#01111(30)
A4(34, 12) = A4(34, 12) - v(247); % source1:TYRTA_03:xakg#11101(23)
A4(34, 12) = A4(34, 12) - v(193); % source1:PHETA1_01:xakg#11101(23)
A4(34, 12) = A4(34, 12) - v(30); % source1:ACOTA_01:xakg#11101(23)
A4(34, 12) = A4(34, 12) - v(22); % source1:COMBO2_01:xakg#11101(23)
A4(34, 34) = A4(34, 34) - v(266); % source1:PEPTIDOSYN_01:xgluL#11101(23)
A4(34, 12) = A4(34, 12) - v(51); % source1:ASPTA_01:xakg#11101(23)
A4(34, 12) = A4(34, 12) - v(21); % source1:ABTA_01:xakg#11101(23)
A4(34, 12) = A4(34, 12) - v(193); % source1:PHETA1_03:xakg#11101(23)
A4(34, 34) = A4(34, 34) - 2*v(255); % source1:IMPSYN1_02:xgluL#11101(23)
A4(34, 34) = A4(34, 34) - v(109); % source1:GLUN_01:xgluL#11101(23)
A4(34, 12) = A4(34, 12) - v(136); % source1:ILETA_01:xakg#11101(23)
A4(34, 34) = A4(34, 34) - 2*v(110); % source1:GLUSy_02:xgluL#11101(23)
A4(34, 2) = A4(34, 2) - v(182); % source1:P5CD_01:x1pyr5c#11101(23)
A4(34, 12) = A4(34, 12) - v(215); % source1:SDPTA_01:xakg#11101(23)
A4(34, 34) = A4(34, 34) - v(48); % source1:ASNS1_01:xgluL#11101(23)
A4(34, 34) = A4(34, 34) - v(254); % source1:CTPSYN_01:xgluL#11101(23)
A4(34, 12) = A4(34, 12) - v(41); % source1:ALATAL_01:xakg#11101(23)
A4(34, 12) = A4(34, 12) - v(247); % source1:TYRTA_01:xakg#11101(23)
A4(34, 12) = A4(34, 12) - v(22); % source1:COMBO2_02:xakg#11101(23)
A4(34, 12) = A4(34, 12) - v(193); % source1:PHETA1_04:xakg#11101(23)
A4(34, 34) = A4(34, 34) - v(54); % source1:CBPS_01:xgluL#11101(23)
A4(34, 34) = A4(34, 34) - 2*v(256); % source1:IMPSYN2_01:xgluL#11101(23)
A4(34, 34) = A4(34, 34) - v(43); % source1:COMBO15_01:xgluL#11101(23)
A4(34, 12) = A4(34, 12) - v(193); % source1:PHETA1_02:xakg#11101(23)
%>>> xicit#001111#
A4(35, 35) = v(273) + v(135) + v(134) + v(135); % drain :rACONT_r_01:ICL_01:ICDHyr_01:ICL_02 
B4(35,:) = B4(35,:) + conv(x3(20,:), x1(80,:)) * v(301); % source2:ICDHyr_r_01:xakg#00111(28):xco2#1(1)
A4(35, 16) = A4(35, 16) - v(29); % source1:rACONT_01:xcit#001111(60)
%>>> xicit#011110#
A4(36, 36) = v(273) + v(135) + v(134) + v(135); % drain :rACONT_r_01:ICL_01:ICDHyr_01:ICL_02 
A4(36, 11) = A4(36, 11) - v(301); % source1:ICDHyr_r_01:xakg#01111(30)
A4(36, 17) = A4(36, 17) - v(29); % source1:rACONT_01:xcit#011110(30)
%>>> xicit#111010#
A4(37, 37) = v(273) + v(135) + v(134) + v(135); % drain :rACONT_r_01:ICL_01:ICDHyr_01:ICL_02 
A4(37, 12) = A4(37, 12) - v(301); % source1:ICDHyr_r_01:xakg#11101(23)
A4(37, 18) = A4(37, 18) - v(29); % source1:rACONT_01:xcit#111010(23)
%>>> xmalL#1111#
A4(38, 38) = v(293) + v(151) + v(149) + v(152) + v(293) + v(153) + v(150); % drain :rFUM_r_02:MDH3_01:MDH_01:ME1_01:rFUM_r_01:ME2_01:MDH2_01 
B4(38,:) = B4(38,:) + conv(x2(97,:), x2(20,:)) * v(148); % source2:MALS_01:xglx#11(3):xaccoa#11(3)
A4(38, 40) = A4(38, 40) - v(307); % source1:MDH_r_01:xoaa#1111(15)
A4(38, 25) = A4(38, 25) - v(89); % source1:rFUM_01:xfum#1111(15)
A4(38, 25) = A4(38, 25) - v(89); % source1:rFUM_02:xfum#1111(15)
%>>> xmetL#01111#
A4(39, 39) = v(36) + 0.146*v(1) + v(36); % drain :COMBOSPMD_02:BiomassEcoliGALUi_01:COMBOSPMD_01 
B4(39,:) = B4(39,:) + conv(x3(29,:), x1(173,:)) * v(61); % source2:COMBO22_02:xaspsa#0111(14):xmlthf#1(1)
B4(39,:) = B4(39,:) + conv(x3(29,:), x1(173,:)) * v(61); % source2:COMBO22_01:xaspsa#0111(14):xmlthf#1(1)
A4(39, 3) = A4(39, 3) - v(249); % source1:UNK3_01:x2kmb#01111(30)
%>>> xoaa#1111#
A4(40, 40) = v(307) + v(283) + v(58) + v(199); % drain :MDH_r_01:ASPTA_r_01:CS_01:PPCK_01 
B4(40,:) = B4(40,:) + conv(x1(80,:), x3(80,:)) * v(198); % source2:PPC_01:xco2#1(1):xpep#111(7)
A4(40, 38) = A4(40, 38) - v(151); % source1:MDH3_01:xmalL#1111(15)
A4(40, 38) = A4(40, 38) - v(149); % source1:MDH_01:xmalL#1111(15)
A4(40, 14) = A4(40, 14) - v(51); % source1:ASPTA_01:xaspL#1111(15)
A4(40, 38) = A4(40, 38) - v(150); % source1:MDH2_01:xmalL#1111(15)
%>>> xorn#01111#
A4(41, 41) = v(181) + v(179) + v(181); % drain :ORNDC_01:OCBT_01:ORNDC_02 
A4(41, 41) = A4(41, 41) - v(310); % source1:OCBT_r_01:xorn#01111(30)
A4(41, 9) = A4(41, 9) - v(28); % source1:ACODA_01:xacg5sa#0111100(30)
%>>> xptrc#1111#
A4(42, 42) = v(22) + v(36) + 0.035*v(1) + v(36) + v(22); % drain :COMBO2_01:COMBOSPMD_02:BiomassEcoliGALUi_01:COMBOSPMD_01:COMBO2_02 
A4(42, 41) = A4(42, 41) - v(181); % source1:ORNDC_01:xorn#01111(30)
A4(42, 41) = A4(42, 41) - v(181); % source1:ORNDC_02:xorn#01111(30)
%>>> xr5p#01111#
A4(43, 43) = v(213) + v(204) + v(238); % drain :RPI_01:PRPPS_01:TKT1_01 
A4(43, 45) = A4(43, 45) - v(321); % source1:RPI_r_01:xru5pD#01111(30)
A4(43, 47) = A4(43, 47) - v(329); % source1:TKT1_r_01:xs7p#0001111(120)
A4(43, 43) = A4(43, 43) - v(316); % source1:PRPPS_r_01:xr5p#01111(30)
%>>> xr5p#11110#
A4(44, 44) = v(213) + v(204) + v(238); % drain :RPI_01:PRPPS_01:TKT1_01 
A4(44, 46) = A4(44, 46) - v(321); % source1:RPI_r_01:xru5pD#11110(15)
A4(44, 48) = A4(44, 48) - v(329); % source1:TKT1_r_01:xs7p#0011110(60)
A4(44, 44) = A4(44, 44) - v(316); % source1:PRPPS_r_01:xr5p#11110(15)
%>>> xru5pD#01111#
A4(45, 45) = v(321) + v(212) + 2*v(259) + 2*v(259) + 5*v(265) + 2*v(259); % drain :RPI_r_01:RPE_01:FADSYN_02:FADSYN_01:LPSSYN_01:FADSYN_03 
A4(45, 43) = A4(45, 43) - v(213); % source1:RPI_01:xr5p#01111(30)
A4(45, 29) = A4(45, 29) - v(125); % source1:GND_01:xg6p#001111(60)
A4(45, 54) = A4(45, 54) - v(320); % source1:RPE_r_01:xxu5pD#01111(30)
%>>> xru5pD#11110#
A4(46, 46) = v(321) + v(212) + 2*v(259) + 2*v(259) + 5*v(265) + 2*v(259); % drain :RPI_r_01:RPE_01:FADSYN_02:FADSYN_01:LPSSYN_01:FADSYN_03 
A4(46, 44) = A4(46, 44) - v(213); % source1:RPI_01:xr5p#11110(15)
A4(46, 30) = A4(46, 30) - v(125); % source1:GND_01:xg6p#011110(30)
A4(46, 55) = A4(46, 55) - v(320); % source1:RPE_r_01:xxu5pD#11110(15)
%>>> xs7p#0001111#
A4(47, 47) = v(329) + 3*v(265) + v(232); % drain :TKT1_r_01:LPSSYN_01:TALA_01 
A4(47, 20) = A4(47, 20) - v(327); % source1:TALA_r_01:xe4p#1111(15)
A4(47, 43) = A4(47, 43) - v(238); % source1:TKT1_01:xr5p#01111(30)
%>>> xs7p#0011110#
A4(48, 48) = v(329) + 3*v(265) + v(232); % drain :TKT1_r_01:LPSSYN_01:TALA_01 
B4(48,:) = B4(48,:) + conv(x3(39,:), x1(99,:)) * v(327); % source2:TALA_r_01:xe4p#1110(7):xf6p#001000(4)
A4(48, 44) = A4(48, 44) - v(238); % source1:TKT1_01:xr5p#11110(15)
%>>> xsl2a6o#00000001111#
A4(49, 49) = v(322); % drain :SDPTA_r_01 
A4(49, 49) = A4(49, 49) - v(215); % source1:SDPTA_01:xsl2a6o#00000001111(1920)
A4(49, 52) = A4(49, 52) - v(71); % source1:COMBO26_01:xsuccoa#1111(15)
%>>> xsucc#1111#
A4(50, 50) = v(229) + v(226) + v(228) + v(228) + v(225) + v(228) + v(225) + v(228) + v(228) + v(228) + v(228) + v(228) + v(228) + v(226) + v(228) + v(225) + v(228) + v(226) + v(228) + v(228) + v(228) + v(228) + v(228) + v(226) + v(225) + v(229); % drain :SUCOAS_02:SUCD1i_04:SUCFUMt_15:SUCFUMt_08:SUCCt2b_04:SUCFUMt_12:SUCCt2b_02:SUCFUMt_10:SUCFUMt_02:SUCFUMt_13:SUCFUMt_09:SUCFUMt_01:SUCFUMt_06:SUCD1i_03:SUCFUMt_03:SUCCt2b_03:SUCFUMt_14:SUCD1i_01:SUCFUMt_07:SUCFUMt_11:SUCFUMt_05:SUCFUMt_16:SUCFUMt_04:SUCD1i_02:SUCCt2b_01:SUCOAS_01 
A4(50, 51) = A4(50, 51) - v(325); % source1:SUCFUMt_r_11:xsucce#1111(15)
A4(50, 51) = A4(50, 51) - v(325); % source1:SUCFUMt_r_07:xsucce#1111(15)
A4(50, 25) = A4(50, 25) - v(87); % source1:FRD3_01:xfum#1111(15)
A4(50, 52) = A4(50, 52) - v(326); % source1:SUCOAS_r_01:xsuccoa#1111(15)
A4(50, 51) = A4(50, 51) - v(325); % source1:SUCFUMt_r_06:xsucce#1111(15)
A4(50, 25) = A4(50, 25) - v(87); % source1:FRD3_04:xfum#1111(15)
A4(50, 51) = A4(50, 51) - v(223); % source1:SUCCt22_03:xsucce#1111(15)
A4(50, 51) = A4(50, 51) - v(325); % source1:SUCFUMt_r_05:xsucce#1111(15)
A4(50, 49) = A4(50, 49) - v(214); % source1:SDPDS_02:xsl2a6o#00000001111(1920)
A4(50, 51) = A4(50, 51) - v(325); % source1:SUCFUMt_r_16:xsucce#1111(15)
A4(50, 51) = A4(50, 51) - v(223); % source1:SUCCt22_04:xsucce#1111(15)
A4(50, 51) = A4(50, 51) - v(325); % source1:SUCFUMt_r_08:xsucce#1111(15)
A4(50, 5) = A4(50, 5) - v(221); % source1:SSALy_02:x4abut#1111(15)
A4(50, 49) = A4(50, 49) - v(214); % source1:SDPDS_03:xsl2a6o#00000001111(1920)
A4(50, 51) = A4(50, 51) - v(224); % source1:SUCCt23_04:xsucce#1111(15)
A4(50, 51) = A4(50, 51) - v(325); % source1:SUCFUMt_r_09:xsucce#1111(15)
A4(50, 51) = A4(50, 51) - v(224); % source1:SUCCt23_03:xsucce#1111(15)
A4(50, 51) = A4(50, 51) - v(222); % source1:SUCCabc_03:xsucce#1111(15)
A4(50, 51) = A4(50, 51) - v(325); % source1:SUCFUMt_r_14:xsucce#1111(15)
A4(50, 52) = A4(50, 52) - v(61); % source1:COMBO22_02:xsuccoa#1111(15)
A4(50, 51) = A4(50, 51) - v(224); % source1:SUCCt23_02:xsucce#1111(15)
A4(50, 5) = A4(50, 5) - v(220); % source1:SSALx_02:x4abut#1111(15)
A4(50, 51) = A4(50, 51) - v(325); % source1:SUCFUMt_r_04:xsucce#1111(15)
A4(50, 35) = A4(50, 35) - v(135); % source1:ICL_02:xicit#001111(60)
A4(50, 51) = A4(50, 51) - v(222); % source1:SUCCabc_04:xsucce#1111(15)
A4(50, 25) = A4(50, 25) - v(86); % source1:FRD2_03:xfum#1111(15)
A4(50, 5) = A4(50, 5) - v(221); % source1:SSALy_01:x4abut#1111(15)
A4(50, 51) = A4(50, 51) - v(223); % source1:SUCCt22_01:xsucce#1111(15)
A4(50, 51) = A4(50, 51) - v(222); % source1:SUCCabc_02:xsucce#1111(15)
A4(50, 51) = A4(50, 51) - v(224); % source1:SUCCt23_01:xsucce#1111(15)
A4(50, 51) = A4(50, 51) - v(325); % source1:SUCFUMt_r_01:xsucce#1111(15)
A4(50, 49) = A4(50, 49) - v(214); % source1:SDPDS_01:xsl2a6o#00000001111(1920)
A4(50, 51) = A4(50, 51) - v(325); % source1:SUCFUMt_r_13:xsucce#1111(15)
A4(50, 25) = A4(50, 25) - v(87); % source1:FRD3_03:xfum#1111(15)
A4(50, 5) = A4(50, 5) - v(220); % source1:SSALx_01:x4abut#1111(15)
A4(50, 51) = A4(50, 51) - v(325); % source1:SUCFUMt_r_15:xsucce#1111(15)
A4(50, 51) = A4(50, 51) - v(325); % source1:SUCFUMt_r_02:xsucce#1111(15)
A4(50, 51) = A4(50, 51) - v(222); % source1:SUCCabc_01:xsucce#1111(15)
A4(50, 51) = A4(50, 51) - v(325); % source1:SUCFUMt_r_03:xsucce#1111(15)
A4(50, 35) = A4(50, 35) - v(135); % source1:ICL_01:xicit#001111(60)
A4(50, 51) = A4(50, 51) - v(325); % source1:SUCFUMt_r_12:xsucce#1111(15)
A4(50, 49) = A4(50, 49) - v(214); % source1:SDPDS_04:xsl2a6o#00000001111(1920)
A4(50, 25) = A4(50, 25) - v(86); % source1:FRD2_04:xfum#1111(15)
A4(50, 25) = A4(50, 25) - v(87); % source1:FRD3_02:xfum#1111(15)
A4(50, 52) = A4(50, 52) - v(326); % source1:SUCOAS_r_02:xsuccoa#1111(15)
A4(50, 25) = A4(50, 25) - v(86); % source1:FRD2_01:xfum#1111(15)
A4(50, 52) = A4(50, 52) - v(61); % source1:COMBO22_01:xsuccoa#1111(15)
A4(50, 51) = A4(50, 51) - v(223); % source1:SUCCt22_02:xsucce#1111(15)
A4(50, 25) = A4(50, 25) - v(86); % source1:FRD2_02:xfum#1111(15)
A4(50, 51) = A4(50, 51) - v(325); % source1:SUCFUMt_r_10:xsucce#1111(15)
%>>> xsucce#1111#
A4(51, 51) = v(325) + v(222) + v(325) + v(325) + v(223) + v(222) + v(224) + v(20) + v(223) + v(325) + v(325) + v(325) + v(325) + v(223) + v(325) + v(325) + v(325) + v(222) + v(224) + v(325) + v(325) + v(224) + v(325) + v(222) + v(325) + v(224) + v(223) + v(325) + v(325) + v(20); % drain :SUCFUMt_r_11:SUCCabc_04:SUCFUMt_r_07:SUCFUMt_r_06:SUCCt22_01:SUCCabc_02:SUCCt23_01:EX_succ_02:SUCCt22_03:SUCFUMt_r_05:SUCFUMt_r_01:SUCFUMt_r_16:SUCFUMt_r_13:SUCCt22_04:SUCFUMt_r_15:SUCFUMt_r_02:SUCFUMt_r_08:SUCCabc_01:SUCCt23_04:SUCFUMt_r_03:SUCFUMt_r_09:SUCCt23_03:SUCFUMt_r_12:SUCCabc_03:SUCFUMt_r_14:SUCCt23_02:SUCCt22_02:SUCFUMt_r_10:SUCFUMt_r_04:EX_succ_01 
A4(51, 50) = A4(51, 50) - v(228); % source1:SUCFUMt_15:xsucc#1111(15)
A4(51, 50) = A4(51, 50) - v(228); % source1:SUCFUMt_08:xsucc#1111(15)
A4(51, 50) = A4(51, 50) - v(225); % source1:SUCCt2b_04:xsucc#1111(15)
A4(51, 50) = A4(51, 50) - v(228); % source1:SUCFUMt_12:xsucc#1111(15)
A4(51, 50) = A4(51, 50) - v(225); % source1:SUCCt2b_02:xsucc#1111(15)
A4(51, 50) = A4(51, 50) - v(228); % source1:SUCFUMt_10:xsucc#1111(15)
A4(51, 50) = A4(51, 50) - v(228); % source1:SUCFUMt_02:xsucc#1111(15)
A4(51, 50) = A4(51, 50) - v(228); % source1:SUCFUMt_13:xsucc#1111(15)
A4(51, 50) = A4(51, 50) - v(228); % source1:SUCFUMt_09:xsucc#1111(15)
A4(51, 50) = A4(51, 50) - v(228); % source1:SUCFUMt_01:xsucc#1111(15)
A4(51, 50) = A4(51, 50) - v(228); % source1:SUCFUMt_06:xsucc#1111(15)
A4(51, 50) = A4(51, 50) - v(225); % source1:SUCCt2b_03:xsucc#1111(15)
A4(51, 50) = A4(51, 50) - v(228); % source1:SUCFUMt_03:xsucc#1111(15)
A4(51, 50) = A4(51, 50) - v(228); % source1:SUCFUMt_14:xsucc#1111(15)
A4(51, 50) = A4(51, 50) - v(228); % source1:SUCFUMt_07:xsucc#1111(15)
A4(51, 50) = A4(51, 50) - v(228); % source1:SUCFUMt_11:xsucc#1111(15)
A4(51, 50) = A4(51, 50) - v(228); % source1:SUCFUMt_05:xsucc#1111(15)
A4(51, 50) = A4(51, 50) - v(228); % source1:SUCFUMt_16:xsucc#1111(15)
A4(51, 50) = A4(51, 50) - v(228); % source1:SUCFUMt_04:xsucc#1111(15)
A4(51, 50) = A4(51, 50) - v(225); % source1:SUCCt2b_01:xsucc#1111(15)
%>>> xsuccoa#1111#
A4(52, 52) = v(326) + v(71) + v(61) + 3e-06*v(1) + v(61) + v(326); % drain :SUCOAS_r_02:COMBO26_01:COMBO22_02:BiomassEcoliGALUi_01:COMBO22_01:SUCOAS_r_01 
A4(52, 11) = A4(52, 11) - v(233); % source1:TESTAKGDH_01:xakg#01111(30)
A4(52, 50) = A4(52, 50) - v(229); % source1:SUCOAS_02:xsucc#1111(15)
A4(52, 50) = A4(52, 50) - v(229); % source1:SUCOAS_01:xsucc#1111(15)
%>>> xthrL#1111#
A4(53, 53) = v(237) + v(236) + 0.241*v(1) + v(112); % drain :THRDL_01:THRAr_01:BiomassEcoliGALUi_01:COMBO37_01 
B4(53,:) = B4(53,:) + conv(x2(157,:), x2(98,:)) * v(328); % source2:THRAr_r_01:xthrL#0011(12):xgly#11(3)
A4(53, 15) = A4(53, 15) - v(130); % source1:COMBO41_01:xaspsa#1111(15)
%>>> xxu5pD#01111#
A4(54, 54) = v(239) + v(320) + v(238); % drain :TKT2_01:RPE_r_01:TKT1_01 
B4(54,:) = B4(54,:) + conv(x3(53,:), x1(100,:)) * v(330); % source2:TKT2_r_01:xg3p#111(7):xf6p#010000(2)
A4(54, 45) = A4(54, 45) - v(212); % source1:RPE_01:xru5pD#01111(30)
B4(54,:) = B4(54,:) + conv(x3(53,:), x1(208,:)) * v(329); % source2:TKT1_r_01:xg3p#111(7):xs7p#0100000(2)
%>>> xxu5pD#11110#
A4(55, 55) = v(239) + v(320) + v(238); % drain :TKT2_01:RPE_r_01:TKT1_01 
B4(55,:) = B4(55,:) + conv(x2(82,:), x2(66,:)) * v(330); % source2:TKT2_r_01:xg3p#110(3):xf6p#110000(3)
A4(55, 46) = A4(55, 46) - v(212); % source1:RPE_01:xru5pD#11110(15)
B4(55,:) = B4(55,:) + conv(x2(82,:), x2(142,:)) * v(329); % source2:TKT1_r_01:xg3p#110(3):xs7p#1100000(3)
x4 = solveLin(A4, B4);  

% level: 5 of size 27
A5 = sparse(27, 27);
B5 = zeros(27, 6);
%>>> x1pyr5c#11111#
A5(1, 1) = v(182) + v(183); % drain :P5CD_01:P5CR_01 
A5(1, 18) = A5(1, 18) - v(97); % source1:G5SADs_01:xglu5sa#11111(31)
A5(1, 1) = A5(1, 1) - v(203); % source1:PROD2_01:x1pyr5c#11111(31)
%>>> x26dapLL#0111110#
A5(2, 2) = v(67) + v(67) + v(67) + v(67); % drain :DAPE_03:DAPE_02:DAPE_04:DAPE_01 
A5(2, 3) = A5(2, 3) - v(286); % source1:DAPE_r_04:x26dapM#0111110(62)
A5(2, 3) = A5(2, 3) - v(286); % source1:DAPE_r_02:x26dapM#0111110(62)
A5(2, 26) = A5(2, 26) - v(214); % source1:SDPDS_03:xsl2a6o#01111100000(62)
A5(2, 26) = A5(2, 26) - v(214); % source1:SDPDS_01:xsl2a6o#01111100000(62)
A5(2, 3) = A5(2, 3) - v(286); % source1:DAPE_r_01:x26dapM#0111110(62)
A5(2, 26) = A5(2, 26) - v(214); % source1:SDPDS_02:xsl2a6o#01111100000(62)
A5(2, 3) = A5(2, 3) - v(286); % source1:DAPE_r_03:x26dapM#0111110(62)
A5(2, 26) = A5(2, 26) - v(214); % source1:SDPDS_04:xsl2a6o#01111100000(62)
%>>> x26dapM#0111110#
A5(3, 3) = v(66) + v(286) + v(286) + v(66) + v(286) + v(266) + v(266) + v(286); % drain :DAPDC_01:DAPE_r_02:DAPE_r_01:DAPDC_02:DAPE_r_04:PEPTIDOSYN_01:PEPTIDOSYN_02:DAPE_r_03 
A5(3, 2) = A5(3, 2) - v(67); % source1:DAPE_03:x26dapLL#0111110(62)
A5(3, 2) = A5(3, 2) - v(67); % source1:DAPE_02:x26dapLL#0111110(62)
A5(3, 2) = A5(3, 2) - v(67); % source1:DAPE_04:x26dapLL#0111110(62)
A5(3, 2) = A5(3, 2) - v(67); % source1:DAPE_01:x26dapLL#0111110(62)
%>>> x2ippm#0111101#
A5(4, 4) = v(140) + v(303); % drain :IPPMIb_01:IPPMIa_r_01 
A5(4, 4) = A5(4, 4) - v(139); % source1:IPPMIa_01:x2ippm#0111101(94)
A5(4, 6) = A5(4, 6) - v(304); % source1:IPPMIb_r_01:x3c3hmp#0111101(94)
%>>> x2kmb#11111#
A5(5, 5) = v(249); % drain :UNK3_01 
A5(5, 13) = A5(5, 13) - v(74); % source1:DKMPPD2_01:xdkmpp#011111(62)
A5(5, 13) = A5(5, 13) - v(73); % source1:DKMPPD_01:xdkmpp#011111(62)
%>>> x3c3hmp#0111101#
A5(6, 6) = v(304); % drain :IPPMIb_r_01 
B5(6,:) = B5(6,:) + conv(x1(36,:), x4(4,:)) * v(141); % source2:IPPS_01:xaccoa#01(2):x3mob#01111(30)
A5(6, 4) = A5(6, 4) - v(140); % source1:IPPMIb_01:x2ippm#0111101(94)
%>>> x3mob#11111#
A5(7, 7) = v(141) + v(334) + v(258) + v(258); % drain :IPPS_01:VALTA_r_01:COASYN_02:COASYN_01 
A5(7, 7) = A5(7, 7) - v(250); % source1:VALTA_01:x3mob#11111(31)
B5(7,:) = B5(7,:) + conv(x2(130,:), x3(83,:)) * v(69); % source2:DHAD1_01:xpyr#011(6):xpyr#111(7)
%>>> x3mop#011111#
A5(8, 8) = v(302); % drain :ILETA_r_01 
B5(8,:) = B5(8,:) + conv(x3(100,:), x2(130,:)) * v(25); % source2:COMBO4_01:xthrL#0111(14):xpyr#011(6)
A5(8, 8) = A5(8, 8) - v(136); % source1:ILETA_01:x3mop#011111(62)
%>>> xacg5p#1111100#
A5(9, 9) = v(277); % drain :AGPR_r_01 
A5(9, 10) = A5(9, 10) - v(39); % source1:AGPR_01:xacg5sa#1111100(31)
A5(9, 19) = A5(9, 19) - v(24); % source1:COMBO3_01:xgluL#11111(31)
%>>> xacg5sa#1111100#
A5(10, 10) = v(157) + v(274) + v(39); % drain :NACODA_01:ACOTA_r_01:AGPR_01 
A5(10, 9) = A5(10, 9) - v(277); % source1:AGPR_r_01:xacg5p#1111100(31)
A5(10, 10) = A5(10, 10) - v(30); % source1:ACOTA_01:xacg5sa#1111100(31)
%>>> xakg#11111#
A5(11, 11) = v(215) + v(110) + v(297) + v(247) + v(247) + v(250) + v(247) + v(41) + v(110) + v(22) + v(301) + v(193) + v(233) + v(247) + v(193) + v(30) + v(22) + v(51) + v(21) + v(193) + v(193) + v(136); % drain :SDPTA_01:GLUSy_02:GLUDy_r_01:TYRTA_04:TYRTA_02:VALTA_01:TYRTA_01:ALATAL_01:GLUSy_01:COMBO2_02:ICDHyr_r_01:PHETA1_04:TESTAKGDH_01:TYRTA_03:PHETA1_01:ACOTA_01:COMBO2_01:ASPTA_01:ABTA_01:PHETA1_02:PHETA1_03:ILETA_01 
A5(11, 19) = A5(11, 19) - v(333); % source1:TYRTA_r_04:xgluL#11111(31)
A5(11, 19) = A5(11, 19) - v(315); % source1:PHETA1_r_03:xgluL#11111(31)
A5(11, 19) = A5(11, 19) - v(274); % source1:ACOTA_r_01:xgluL#11111(31)
A5(11, 19) = A5(11, 19) - v(322); % source1:SDPTA_r_01:xgluL#11111(31)
A5(11, 19) = A5(11, 19) - v(147); % source1:LEUTAi_01:xgluL#11111(31)
A5(11, 19) = A5(11, 19) - v(334); % source1:VALTA_r_01:xgluL#11111(31)
A5(11, 19) = A5(11, 19) - v(333); % source1:TYRTA_r_02:xgluL#11111(31)
A5(11, 19) = A5(11, 19) - v(302); % source1:ILETA_r_01:xgluL#11111(31)
A5(11, 19) = A5(11, 19) - v(187); % source1:COMBO47_01:xgluL#11111(31)
A5(11, 19) = A5(11, 19) - v(315); % source1:PHETA1_r_02:xgluL#11111(31)
A5(11, 19) = A5(11, 19) - v(315); % source1:PHETA1_r_04:xgluL#11111(31)
A5(11, 19) = A5(11, 19) - v(249); % source1:UNK3_01:xgluL#11111(31)
A5(11, 19) = A5(11, 19) - v(333); % source1:TYRTA_r_01:xgluL#11111(31)
A5(11, 19) = A5(11, 19) - v(279); % source1:ALATAL_r_01:xgluL#11111(31)
A5(11, 19) = A5(11, 19) - v(251); % source1:HISSYN_01:xgluL#11111(31)
A5(11, 19) = A5(11, 19) - v(283); % source1:ASPTA_r_01:xgluL#11111(31)
A5(11, 20) = A5(11, 20) - v(134); % source1:ICDHyr_01:xicit#111110(31)
A5(11, 19) = A5(11, 19) - v(108); % source1:GLUDy_01:xgluL#11111(31)
A5(11, 19) = A5(11, 19) - v(333); % source1:TYRTA_r_03:xgluL#11111(31)
A5(11, 19) = A5(11, 19) - v(315); % source1:PHETA1_r_01:xgluL#11111(31)
%>>> xcit#111110#
A5(12, 12) = v(29); % drain :rACONT_01 
A5(12, 20) = A5(12, 20) - v(273); % source1:rACONT_r_01:xicit#111110(31)
B5(12,:) = B5(12,:) + conv(x2(20,:), x3(76,:)) * v(58); % source2:CS_01:xaccoa#11(3):xoaa#0111(14)
%>>> xdkmpp#011111#
A5(13, 13) = v(74) + v(73); % drain :DKMPPD2_01:DKMPPD_01 
B5(13,:) = B5(13,:) + conv(x1(170,:), x4(43,:)) * v(36); % source2:COMBOSPMD_02:xmetL#00001(16):xr5p#01111(30)
B5(13,:) = B5(13,:) + conv(x1(170,:), x4(43,:)) * v(36); % source2:COMBOSPMD_01:xmetL#00001(16):xr5p#01111(30)
%>>> xf6p#011111#
A5(14, 14) = v(327) + v(311) + v(330) + v(185) + 2*v(266) + v(79) + 2*v(266) + v(79) + 2*v(265); % drain :TALA_r_01:PGI_r_01:TKT2_r_01:PFK_01:PEPTIDOSYN_01:F6PA_02:PEPTIDOSYN_02:F6PA_01:LPSSYN_01 
B5(14,:) = B5(14,:) + conv(x1(242,:), x4(20,:)) * v(239); % source2:TKT2_01:xxu5pD#01000(2):xe4p#1111(15)
A5(14, 15) = A5(14, 15) - v(81); % source1:FBP_01:xfdp#011111(62)
B5(14,:) = B5(14,:) + conv(x3(53,:), x2(56,:)) * v(290); % source2:F6PA_r_02:xg3p#111(7):xdha#011(6)
B5(14,:) = B5(14,:) + conv(x3(53,:), x2(57,:)) * v(290); % source2:F6PA_r_01:xg3p#111(7):xdha#110(3)
B5(14,:) = B5(14,:) + conv(x3(53,:), x2(141,:)) * v(232); % source2:TALA_01:xg3p#111(7):xs7p#0110000(6)
A5(14, 17) = A5(14, 17) - v(188); % source1:PGI_01:xg6p#011111(62)
%>>> xfdp#011111#
A5(15, 15) = v(81) + v(80); % drain :FBP_01:FBA_01 
A5(15, 14) = A5(15, 14) - v(185); % source1:PFK_01:xf6p#011111(62)
B5(15,:) = B5(15,:) + conv(x2(58,:), x3(53,:)) * v(291); % source2:FBA_r_01:xdhap#011(6):xg3p#111(7)
%>>> xg1p#011111#
A5(16, 16) = v(104) + 0.003*v(1) + v(92) + 2*v(265) + v(192); % drain :COMBO36_01:BiomassEcoliGALUi_01:G1PP_01:LPSSYN_01:PGMT_01 
A5(16, 17) = A5(16, 17) - v(314); % source1:PGMT_r_01:xg6p#011111(62)
A5(16, 16) = A5(16, 16) - v(103); % source1:GLCP_01:xg1p#011111(62)
%>>> xg6p#011111#
A5(17, 17) = v(99) + v(314) + v(188); % drain :G6PDH2r_01:PGMT_r_01:PGI_01 
A5(17, 16) = A5(17, 16) - v(128); % source1:HEX1_01:xg1p#011111(62)
A5(17, 17) = A5(17, 17) - v(295); % source1:G6PDH2r_r_01:xg6p#011111(62)
A5(17, 14) = A5(17, 14) - v(311); % source1:PGI_r_01:xf6p#011111(62)
B5(17,:) = B5(17,:) + xglcDe.x011111' * v(105); % source1:GLCpts_01:xglcDe#011111(62)
A5(17, 16) = A5(17, 16) - v(192); % source1:PGMT_01:xg1p#011111(62)
%>>> xglu5sa#11111#
A5(18, 18) = v(97); % drain :G5SADs_01 
A5(18, 10) = A5(18, 10) - v(157); % source1:NACODA_01:xacg5sa#1111100(31)
A5(18, 19) = A5(18, 19) - v(98); % source1:COMBO34_01:xgluL#11111(31)
%>>> xgluL#11111#
A5(19, 19) = v(333) + v(315) + v(274) + v(98) + v(24) + v(322) + v(147) + v(334) + v(333) + v(302) + v(187) + 0.25*v(1) + v(315) + v(315) + v(107) + v(249) + v(333) + v(279) + v(106) + v(283) + v(108) + v(333) + v(315); % drain :TYRTA_r_04:PHETA1_r_03:ACOTA_r_01:COMBO34_01:COMBO3_01:SDPTA_r_01:LEUTAi_01:VALTA_r_01:TYRTA_r_02:ILETA_r_01:COMBO47_01:BiomassEcoliGALUi_01:PHETA1_r_02:PHETA1_r_04:GLUDC_01:UNK3_01:TYRTA_r_01:ALATAL_r_01:GLNS_01:ASPTA_r_01:GLUDy_01:TYRTA_r_03:PHETA1_r_01 
A5(19, 19) = A5(19, 19) - v(124); % source1:GMPS2_01:xgluL#11111(31)
A5(19, 11) = A5(19, 11) - v(297); % source1:GLUDy_r_01:xakg#11111(31)
A5(19, 11) = A5(19, 11) - v(247); % source1:TYRTA_04:xakg#11111(31)
A5(19, 11) = A5(19, 11) - v(247); % source1:TYRTA_02:xakg#11111(31)
A5(19, 11) = A5(19, 11) - v(250); % source1:VALTA_01:xakg#11111(31)
A5(19, 11) = A5(19, 11) - 2*v(110); % source1:GLUSy_01:xakg#11111(31)
A5(19, 19) = A5(19, 19) - v(266); % source1:PEPTIDOSYN_02:xgluL#11111(31)
A5(19, 19) = A5(19, 19) - 2*v(265); % source1:LPSSYN_01:xgluL#11111(31)
A5(19, 19) = A5(19, 19) - 2*v(256); % source1:IMPSYN2_02:xgluL#11111(31)
A5(19, 19) = A5(19, 19) - 2*v(255); % source1:IMPSYN1_01:xgluL#11111(31)
A5(19, 11) = A5(19, 11) - v(247); % source1:TYRTA_03:xakg#11111(31)
A5(19, 11) = A5(19, 11) - v(193); % source1:PHETA1_01:xakg#11111(31)
A5(19, 11) = A5(19, 11) - v(30); % source1:ACOTA_01:xakg#11111(31)
A5(19, 11) = A5(19, 11) - v(22); % source1:COMBO2_01:xakg#11111(31)
A5(19, 19) = A5(19, 19) - v(266); % source1:PEPTIDOSYN_01:xgluL#11111(31)
A5(19, 11) = A5(19, 11) - v(51); % source1:ASPTA_01:xakg#11111(31)
A5(19, 11) = A5(19, 11) - v(21); % source1:ABTA_01:xakg#11111(31)
A5(19, 11) = A5(19, 11) - v(193); % source1:PHETA1_03:xakg#11111(31)
A5(19, 19) = A5(19, 19) - 2*v(255); % source1:IMPSYN1_02:xgluL#11111(31)
A5(19, 19) = A5(19, 19) - v(109); % source1:GLUN_01:xgluL#11111(31)
A5(19, 11) = A5(19, 11) - v(136); % source1:ILETA_01:xakg#11111(31)
A5(19, 19) = A5(19, 19) - 2*v(110); % source1:GLUSy_02:xgluL#11111(31)
A5(19, 1) = A5(19, 1) - v(182); % source1:P5CD_01:x1pyr5c#11111(31)
A5(19, 11) = A5(19, 11) - v(215); % source1:SDPTA_01:xakg#11111(31)
A5(19, 19) = A5(19, 19) - v(48); % source1:ASNS1_01:xgluL#11111(31)
A5(19, 19) = A5(19, 19) - v(254); % source1:CTPSYN_01:xgluL#11111(31)
A5(19, 11) = A5(19, 11) - v(41); % source1:ALATAL_01:xakg#11111(31)
A5(19, 11) = A5(19, 11) - v(247); % source1:TYRTA_01:xakg#11111(31)
A5(19, 11) = A5(19, 11) - v(22); % source1:COMBO2_02:xakg#11111(31)
A5(19, 11) = A5(19, 11) - v(193); % source1:PHETA1_04:xakg#11111(31)
A5(19, 19) = A5(19, 19) - v(54); % source1:CBPS_01:xgluL#11111(31)
A5(19, 19) = A5(19, 19) - 2*v(256); % source1:IMPSYN2_01:xgluL#11111(31)
A5(19, 19) = A5(19, 19) - v(43); % source1:COMBO15_01:xgluL#11111(31)
A5(19, 11) = A5(19, 11) - v(193); % source1:PHETA1_02:xakg#11111(31)
%>>> xicit#111110#
A5(20, 20) = v(273) + v(135) + v(134) + v(135); % drain :rACONT_r_01:ICL_01:ICDHyr_01:ICL_02 
A5(20, 11) = A5(20, 11) - v(301); % source1:ICDHyr_r_01:xakg#11111(31)
A5(20, 12) = A5(20, 12) - v(29); % source1:rACONT_01:xcit#111110(31)
%>>> xlysL#011111#
A5(21, 21) = 0.326*v(1); % drain :BiomassEcoliGALUi_01 
A5(21, 3) = A5(21, 3) - v(66); % source1:DAPDC_01:x26dapM#0111110(62)
A5(21, 3) = A5(21, 3) - v(66); % source1:DAPDC_02:x26dapM#0111110(62)
%>>> xmetL#11111#
A5(22, 22) = v(36) + 0.146*v(1) + v(36); % drain :COMBOSPMD_02:BiomassEcoliGALUi_01:COMBOSPMD_01 
B5(22,:) = B5(22,:) + conv(x4(15,:), x1(173,:)) * v(61); % source2:COMBO22_02:xaspsa#1111(15):xmlthf#1(1)
B5(22,:) = B5(22,:) + conv(x4(15,:), x1(173,:)) * v(61); % source2:COMBO22_01:xaspsa#1111(15):xmlthf#1(1)
A5(22, 5) = A5(22, 5) - v(249); % source1:UNK3_01:x2kmb#11111(31)
%>>> xr5p#11111#
A5(23, 23) = v(213) + v(204) + v(238); % drain :RPI_01:PRPPS_01:TKT1_01 
A5(23, 24) = A5(23, 24) - v(321); % source1:RPI_r_01:xru5pD#11111(31)
A5(23, 25) = A5(23, 25) - v(329); % source1:TKT1_r_01:xs7p#0011111(124)
A5(23, 23) = A5(23, 23) - v(316); % source1:PRPPS_r_01:xr5p#11111(31)
%>>> xru5pD#11111#
A5(24, 24) = v(321) + v(212) + 2*v(259) + 2*v(259) + 5*v(265) + 2*v(259); % drain :RPI_r_01:RPE_01:FADSYN_02:FADSYN_01:LPSSYN_01:FADSYN_03 
A5(24, 23) = A5(24, 23) - v(213); % source1:RPI_01:xr5p#11111(31)
A5(24, 17) = A5(24, 17) - v(125); % source1:GND_01:xg6p#011111(62)
A5(24, 27) = A5(24, 27) - v(320); % source1:RPE_r_01:xxu5pD#11111(31)
%>>> xs7p#0011111#
A5(25, 25) = v(329) + 3*v(265) + v(232); % drain :TKT1_r_01:LPSSYN_01:TALA_01 
B5(25,:) = B5(25,:) + conv(x4(20,:), x1(99,:)) * v(327); % source2:TALA_r_01:xe4p#1111(15):xf6p#001000(4)
A5(25, 23) = A5(25, 23) - v(238); % source1:TKT1_01:xr5p#11111(31)
%>>> xsl2a6o#01111100000#
A5(26, 26) = v(322); % drain :SDPTA_r_01 
A5(26, 26) = A5(26, 26) - v(215); % source1:SDPTA_01:xsl2a6o#01111100000(62)
B5(26,:) = B5(26,:) + conv(x2(130,:), x3(29,:)) * v(71); % source2:COMBO26_01:xpyr#011(6):xaspsa#0111(14)
%>>> xxu5pD#11111#
A5(27, 27) = v(239) + v(320) + v(238); % drain :TKT2_01:RPE_r_01:TKT1_01 
B5(27,:) = B5(27,:) + conv(x3(53,:), x2(66,:)) * v(330); % source2:TKT2_r_01:xg3p#111(7):xf6p#110000(3)
A5(27, 24) = A5(27, 24) - v(212); % source1:RPE_01:xru5pD#11111(31)
B5(27,:) = B5(27,:) + conv(x3(53,:), x2(142,:)) * v(329); % source2:TKT1_r_01:xg3p#111(7):xs7p#1100000(3)
x5 = solveLin(A5, B5);  

% level: 6 of size 10
A6 = sparse(10, 10);
B6 = zeros(10, 7);
%>>> x26dapLL#0111111#
A6(1, 1) = v(67) + v(67) + v(67) + v(67); % drain :DAPE_03:DAPE_02:DAPE_04:DAPE_01 
A6(1, 4) = A6(1, 4) - v(286); % source1:DAPE_r_04:x26dapM#1111110(63)
A6(1, 3) = A6(1, 3) - v(286); % source1:DAPE_r_02:x26dapM#0111111(126)
A6(1, 9) = A6(1, 9) - v(214); % source1:SDPDS_03:xsl2a6o#01111110000(126)
A6(1, 10) = A6(1, 10) - v(214); % source1:SDPDS_01:xsl2a6o#11111100000(63)
A6(1, 4) = A6(1, 4) - v(286); % source1:DAPE_r_01:x26dapM#1111110(63)
A6(1, 10) = A6(1, 10) - v(214); % source1:SDPDS_02:xsl2a6o#11111100000(63)
A6(1, 3) = A6(1, 3) - v(286); % source1:DAPE_r_03:x26dapM#0111111(126)
A6(1, 9) = A6(1, 9) - v(214); % source1:SDPDS_04:xsl2a6o#01111110000(126)
%>>> x26dapLL#1111110#
A6(2, 2) = v(67) + v(67) + v(67) + v(67); % drain :DAPE_03:DAPE_02:DAPE_04:DAPE_01 
A6(2, 3) = A6(2, 3) - v(286); % source1:DAPE_r_04:x26dapM#0111111(126)
A6(2, 4) = A6(2, 4) - v(286); % source1:DAPE_r_02:x26dapM#1111110(63)
A6(2, 10) = A6(2, 10) - v(214); % source1:SDPDS_03:xsl2a6o#11111100000(63)
A6(2, 9) = A6(2, 9) - v(214); % source1:SDPDS_01:xsl2a6o#01111110000(126)
A6(2, 3) = A6(2, 3) - v(286); % source1:DAPE_r_01:x26dapM#0111111(126)
A6(2, 9) = A6(2, 9) - v(214); % source1:SDPDS_02:xsl2a6o#01111110000(126)
A6(2, 4) = A6(2, 4) - v(286); % source1:DAPE_r_03:x26dapM#1111110(63)
A6(2, 10) = A6(2, 10) - v(214); % source1:SDPDS_04:xsl2a6o#11111100000(63)
%>>> x26dapM#0111111#
A6(3, 3) = v(66) + v(286) + v(286) + v(66) + v(286) + v(266) + v(266) + v(286); % drain :DAPDC_01:DAPE_r_02:DAPE_r_01:DAPDC_02:DAPE_r_04:PEPTIDOSYN_01:PEPTIDOSYN_02:DAPE_r_03 
A6(3, 1) = A6(3, 1) - v(67); % source1:DAPE_03:x26dapLL#0111111(126)
A6(3, 1) = A6(3, 1) - v(67); % source1:DAPE_02:x26dapLL#0111111(126)
A6(3, 2) = A6(3, 2) - v(67); % source1:DAPE_04:x26dapLL#1111110(63)
A6(3, 2) = A6(3, 2) - v(67); % source1:DAPE_01:x26dapLL#1111110(63)
%>>> x26dapM#1111110#
A6(4, 4) = v(66) + v(286) + v(286) + v(66) + v(286) + v(266) + v(266) + v(286); % drain :DAPDC_01:DAPE_r_02:DAPE_r_01:DAPDC_02:DAPE_r_04:PEPTIDOSYN_01:PEPTIDOSYN_02:DAPE_r_03 
A6(4, 2) = A6(4, 2) - v(67); % source1:DAPE_03:x26dapLL#1111110(63)
A6(4, 2) = A6(4, 2) - v(67); % source1:DAPE_02:x26dapLL#1111110(63)
A6(4, 1) = A6(4, 1) - v(67); % source1:DAPE_04:x26dapLL#0111111(126)
A6(4, 1) = A6(4, 1) - v(67); % source1:DAPE_01:x26dapLL#0111111(126)
%>>> x3dhq#0111111#
A6(5, 5) = v(72); % drain :DHQD_01 
B6(5,:) = B6(5,:) + conv(x4(20,:), x2(123,:)) * v(68); % source2:COMBO25_01:xe4p#1111(15):xpep#011(6)
A6(5, 6) = A6(5, 6) - v(287); % source1:DHQD_r_01:x3dhsk#0111111(126)
%>>> x3dhsk#0111111#
A6(6, 6) = v(218) + v(287); % drain :SHK3Dr_01:DHQD_r_01 
A6(6, 5) = A6(6, 5) - v(72); % source1:DHQD_01:x3dhq#0111111(126)
A6(6, 6) = A6(6, 6) - v(324); % source1:SHK3Dr_r_01:x3dhsk#0111111(126)
%>>> xlysL#111111#
A6(7, 7) = 0.326*v(1); % drain :BiomassEcoliGALUi_01 
A6(7, 3) = A6(7, 3) - v(66); % source1:DAPDC_01:x26dapM#0111111(126)
A6(7, 4) = A6(7, 4) - v(66); % source1:DAPDC_02:x26dapM#1111110(63)
%>>> xskm5p#0111111#
A6(8, 8) = v(205); % drain :PSCVT_01 
A6(8, 8) = A6(8, 8) - v(317); % source1:PSCVT_r_01:xskm5p#0111111(126)
A6(8, 6) = A6(8, 6) - v(219); % source1:SHKK_01:x3dhsk#0111111(126)
%>>> xsl2a6o#01111110000#
A6(9, 9) = v(322); % drain :SDPTA_r_01 
A6(9, 9) = A6(9, 9) - v(215); % source1:SDPTA_01:xsl2a6o#01111110000(126)
B6(9,:) = B6(9,:) + conv(x3(83,:), x3(29,:)) * v(71); % source2:COMBO26_01:xpyr#111(7):xaspsa#0111(14)
%>>> xsl2a6o#11111100000#
A6(10, 10) = v(322); % drain :SDPTA_r_01 
A6(10, 10) = A6(10, 10) - v(215); % source1:SDPTA_01:xsl2a6o#11111100000(63)
B6(10,:) = B6(10,:) + conv(x2(130,:), x4(15,:)) * v(71); % source2:COMBO26_01:xpyr#011(6):xaspsa#1111(15)
x6 = solveLin(A6, B6);  

% level: 7 of size 0

% level: 8 of size 4
A8 = sparse(4, 4);
B8 = zeros(4, 9);
%>>> x34hpp#011111111#
A8(1, 1) = v(333) + v(333) + v(333) + v(333); % drain :TYRTA_r_04:TYRTA_r_02:TYRTA_r_01:TYRTA_r_03 
B8(1,:) = B8(1,:) + conv(x2(123,:), x6(8,:)) * v(200); % source2:PPND_01:xpep#011(6):xskm5p#0111111(126)
A8(1, 4) = A8(1, 4) - v(247); % source1:TYRTA_01:xtyrL#011111111(510)
A8(1, 4) = A8(1, 4) - v(247); % source1:TYRTA_03:xtyrL#011111111(510)
A8(1, 4) = A8(1, 4) - v(247); % source1:TYRTA_04:xtyrL#011111111(510)
A8(1, 4) = A8(1, 4) - v(247); % source1:TYRTA_02:xtyrL#011111111(510)
B8(1,:) = B8(1,:) + conv(x2(123,:), x6(8,:)) * v(200); % source2:PPND_02:xpep#011(6):xskm5p#0111111(126)
%>>> xpheL#011111111#
A8(2, 2) = v(193) + 0.176*v(1) + v(193) + v(193) + v(193); % drain :PHETA1_04:BiomassEcoliGALUi_01:PHETA1_02:PHETA1_03:PHETA1_01 
A8(2, 3) = A8(2, 3) - v(315); % source1:PHETA1_r_02:xphpyr#011111111(510)
A8(2, 3) = A8(2, 3) - v(315); % source1:PHETA1_r_04:xphpyr#011111111(510)
A8(2, 3) = A8(2, 3) - v(315); % source1:PHETA1_r_03:xphpyr#011111111(510)
A8(2, 3) = A8(2, 3) - v(315); % source1:PHETA1_r_01:xphpyr#011111111(510)
%>>> xphpyr#011111111#
A8(3, 3) = v(315) + v(315) + v(315) + v(315); % drain :PHETA1_r_02:PHETA1_r_04:PHETA1_r_03:PHETA1_r_01 
B8(3,:) = B8(3,:) + conv(x2(123,:), x6(8,:)) * v(201); % source2:PPNDH_02:xpep#011(6):xskm5p#0111111(126)
A8(3, 2) = A8(3, 2) - v(193); % source1:PHETA1_04:xpheL#011111111(510)
A8(3, 2) = A8(3, 2) - v(193); % source1:PHETA1_02:xpheL#011111111(510)
A8(3, 2) = A8(3, 2) - v(193); % source1:PHETA1_03:xpheL#011111111(510)
A8(3, 2) = A8(3, 2) - v(193); % source1:PHETA1_01:xpheL#011111111(510)
B8(3,:) = B8(3,:) + conv(x2(123,:), x6(8,:)) * v(201); % source2:PPNDH_01:xpep#011(6):xskm5p#0111111(126)
%>>> xtyrL#011111111#
A8(4, 4) = v(247) + 0.131*v(1) + v(247) + v(247) + v(247); % drain :TYRTA_01:BiomassEcoliGALUi_01:TYRTA_03:TYRTA_04:TYRTA_02 
A8(4, 1) = A8(4, 1) - v(333); % source1:TYRTA_r_04:x34hpp#011111111(510)
A8(4, 1) = A8(4, 1) - v(333); % source1:TYRTA_r_02:x34hpp#011111111(510)
A8(4, 1) = A8(4, 1) - v(333); % source1:TYRTA_r_01:x34hpp#011111111(510)
A8(4, 1) = A8(4, 1) - v(333); % source1:TYRTA_r_03:x34hpp#011111111(510)
x8 = solveLin(A8, B8);  

% level: 9 of size 4
A9 = sparse(4, 4);
B9 = zeros(4, 10);
%>>> x34hpp#111111111#
A9(1, 1) = v(333) + v(333) + v(333) + v(333); % drain :TYRTA_r_04:TYRTA_r_02:TYRTA_r_01:TYRTA_r_03 
B9(1,:) = B9(1,:) + conv(x3(80,:), x6(8,:)) * v(200); % source2:PPND_01:xpep#111(7):xskm5p#0111111(126)
A9(1, 4) = A9(1, 4) - v(247); % source1:TYRTA_01:xtyrL#111111111(511)
A9(1, 4) = A9(1, 4) - v(247); % source1:TYRTA_03:xtyrL#111111111(511)
A9(1, 4) = A9(1, 4) - v(247); % source1:TYRTA_04:xtyrL#111111111(511)
A9(1, 4) = A9(1, 4) - v(247); % source1:TYRTA_02:xtyrL#111111111(511)
B9(1,:) = B9(1,:) + conv(x3(80,:), x6(8,:)) * v(200); % source2:PPND_02:xpep#111(7):xskm5p#0111111(126)
%>>> xpheL#111111111#
A9(2, 2) = v(193) + 0.176*v(1) + v(193) + v(193) + v(193); % drain :PHETA1_04:BiomassEcoliGALUi_01:PHETA1_02:PHETA1_03:PHETA1_01 
A9(2, 3) = A9(2, 3) - v(315); % source1:PHETA1_r_02:xphpyr#111111111(511)
A9(2, 3) = A9(2, 3) - v(315); % source1:PHETA1_r_04:xphpyr#111111111(511)
A9(2, 3) = A9(2, 3) - v(315); % source1:PHETA1_r_03:xphpyr#111111111(511)
A9(2, 3) = A9(2, 3) - v(315); % source1:PHETA1_r_01:xphpyr#111111111(511)
%>>> xphpyr#111111111#
A9(3, 3) = v(315) + v(315) + v(315) + v(315); % drain :PHETA1_r_02:PHETA1_r_04:PHETA1_r_03:PHETA1_r_01 
B9(3,:) = B9(3,:) + conv(x3(80,:), x6(8,:)) * v(201); % source2:PPNDH_02:xpep#111(7):xskm5p#0111111(126)
A9(3, 2) = A9(3, 2) - v(193); % source1:PHETA1_04:xpheL#111111111(511)
A9(3, 2) = A9(3, 2) - v(193); % source1:PHETA1_02:xpheL#111111111(511)
A9(3, 2) = A9(3, 2) - v(193); % source1:PHETA1_03:xpheL#111111111(511)
A9(3, 2) = A9(3, 2) - v(193); % source1:PHETA1_01:xpheL#111111111(511)
B9(3,:) = B9(3,:) + conv(x3(80,:), x6(8,:)) * v(201); % source2:PPNDH_01:xpep#111(7):xskm5p#0111111(126)
%>>> xtyrL#111111111#
A9(4, 4) = v(247) + 0.131*v(1) + v(247) + v(247) + v(247); % drain :TYRTA_01:BiomassEcoliGALUi_01:TYRTA_03:TYRTA_04:TYRTA_02 
A9(4, 1) = A9(4, 1) - v(333); % source1:TYRTA_r_04:x34hpp#111111111(511)
A9(4, 1) = A9(4, 1) - v(333); % source1:TYRTA_r_02:x34hpp#111111111(511)
A9(4, 1) = A9(4, 1) - v(333); % source1:TYRTA_r_01:x34hpp#111111111(511)
A9(4, 1) = A9(4, 1) - v(333); % source1:TYRTA_r_03:x34hpp#111111111(511)
x9 = solveLin(A9, B9);  


% Assign outputs
output.xalaL011 = x2(39,:)';
output.xalaL111 = x3(24,:)';
output.xasnL0111 = x3(27,:)';
output.xasnL1100 = x2(46,:)';
output.xasnL1111 = x4(14,:)';
output.xaspL0111 = x3(27,:)';
output.xaspL1100 = x2(46,:)';
output.xaspL1111 = x4(14,:)';
output.xglnL01111 = x4(33,:)';
output.xglnL11111 = x5(19,:)';
output.xgluL01111 = x4(33,:)';
output.xgluL11111 = x5(19,:)';
output.xgly01 = x1(144,:)';
output.xgly11 = x2(98,:)';
output.xhisL011111 = conv(x1(172,:),x4(44,:))';
output.xhisL111111 = conv(x1(172,:),x5(23,:))';
output.xileL011111 = x5(8,:)';
output.xleuL011111 = x5(4,:)';
output.xlysL011111 = x5(21,:)';
output.xlysL111111 = x6(7,:)';
output.xmetL01111 = x4(39,:)';
output.xmetL11111 = x5(22,:)';
output.xpheL011111111 = x8(2,:)';
output.xpheL110000000 = x2(125,:)';
output.xpheL111111111 = x9(2,:)';
output.xproL01111 = x4(1,:)';
output.xserL011 = x2(143,:)';
output.xserL110 = x2(144,:)';
output.xserL111 = x3(91,:)';
output.xthrL0111 = x3(100,:)';
output.xthrL1111 = x4(53,:)';
output.xtyrL011111111 = x8(4,:)';
output.xtyrL110000000 = x2(161,:)';
output.xtyrL111111111 = x9(4,:)';
output.xvalL01111 = x4(4,:)';
output.xvalL11111 = x5(7,:)';
