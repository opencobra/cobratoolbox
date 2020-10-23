function [model] = setSimulationConstraints(model)
% This function sets the remaining simulation constraints that I identified during the
% debugging
% This function needs to be applied to GF and MyWB< models that have been created with GF
% before Dec 2017.
%
% function [model] = setSimulationConstraints(model)
%
% INPUT
% model     model structure (whole body metabolic model)
%
% OUTPUT
% model     model structure with updated constraints as defined in this file 
%
% Ines Thiele Dec 2017

warning off;
model = changeRxnBounds(model,'Liver_EX_4abut[bdL]_[bd]',0,'u');
model = changeRxnBounds(model,'Liver_EX_tym[bdL]_[bd]',0,'u');
model = changeRxnBounds(model,'Liver_EX_i[bdL]_[bd]',0,'u');
model = changeRxnBounds(model,'Liver_EX_ca2[bdL]_[bd]',0,'u');
model = changeRxnBounds(model,'Liver_EX_na1[bdL]_[bd]',0,'u');
model = changeRxnBounds(model,'Liver_EX_h[bdL]_[bd]',0,'u');


model = changeRxnBounds(model,'Colon_EX_o2[luC]_[luLI]',0,'l');
model = changeRxnBounds(model,'Colon_EX_strch2[luC]_[luLI]',0,'l');
model = changeRxnBounds(model,'Colon_EX_coke[luC]_[luLI]',0,'b');
model = changeRxnBounds(model,'sIEC_EX_strch1[luI]_[luSI]',0,'b');
model = changeRxnBounds(model,'sIEC_EX_strch2[luI]_[luSI]',0,'b');

R = (find(~cellfun(@isempty,strfind(model.rxns, 'BileDuct_EX_'))));
model.ub(R) = 0;
% needed to allow pancreas to maintain
model = changeRxnBounds(model,'BileDuct_EX_Rtotal[bd]_[luSI]',15,'u');
model = changeRxnBounds(model,'BileDuct_EX_Rtotal2[bd]_[luSI]',10,'u');
model = changeRxnBounds(model,'BileDuct_EX_pchol_hs[bd]_[luSI]',10,'u');
model = changeRxnBounds(model,'BileDuct_EX_tag_hs[bd]_[luSI]',10,'u');
model = changeRxnBounds(model,'BileDuct_EX_pe_hs[bd]_[luSI]',10,'u');
model = changeRxnBounds(model,'BileDuct_EX_mag_hs[bd]_[luSI]',10,'u');
model = changeRxnBounds(model,'BileDuct_EX_dag_hs[bd]_[luSI]',10,'u');

model = changeRxnBounds(model,'BileDuct_EX_3dhcdchol[bd]_[luSI]',1000,'u');
model = changeRxnBounds(model,'BileDuct_EX_3dhchol[bd]_[luSI]',1000,'u');
model = changeRxnBounds(model,'BileDuct_EX_3dhdchol[bd]_[luSI]',1000,'u');
%model = changeRxnBounds(model,'BileDuct_EX_ca3s[bd]_[luSI]',1000,'u');
model = changeRxnBounds(model,'BileDuct_EX_cdca24g[bd]_[luSI]',1000,'u');
%model = changeRxnBounds(model,'BileDuct_EX_dca3s[bd]_[luSI]',1000,'u');
%model = changeRxnBounds(model,'BileDuct_EX_gca3s[bd]_[luSI]',1000,'u');
%model = changeRxnBounds(model,'BileDuct_EX_gcdca3s[bd]_[luSI]',1000,'u');
%model = changeRxnBounds(model,'BileDuct_EX_gdca3s[bd]_[luSI]',1000,'u');
%model = changeRxnBounds(model,'BileDuct_EX_gudca3s[bd]_[luSI]',1000,'u');
%model = changeRxnBounds(model,'BileDuct_EX_tca3s[bd]_[luSI]',1000,'u');
%model = changeRxnBounds(model,'BileDuct_EX_tcdca3s[bd]_[luSI]',1000,'u');
%model = changeRxnBounds(model,'BileDuct_EX_tdca3s[bd]_[luSI]',1000,'u');
model = changeRxnBounds(model,'BileDuct_EX_thyochol[bd]_[luSI]',1000,'u');
%model = changeRxnBounds(model,'BileDuct_EX_tudca3s[bd]_[luSI]',1000,'u');
%model = changeRxnBounds(model,'BileDuct_EX_udca3s[bd]_[luSI]',1000,'u');

model = changeRxnBounds(model,'Scord_EX_glc_D(e)_[csf]',0,'u');
model = changeRxnBounds(model,'Brain_EX_glc_D(e)_[csf]',-400,'u');
% 
% % set upper bound to 0
% U = {'Liver_sink_hdca(c)'
%     'Liver_sink_lnlc(c)'
%     'Liver_sink_lnlccoa(c)'
%     'Liver_sink_lnlncacoa(c)'
%     'Liver_sink_lnlncgcoa(c)'
%     'Liver_sink_odecoa(c)'
%     'Liver_sink_pmtcoa(c)'
%     'Liver_sink_stcoa(c)'
%     'Liver_sink_tag_hs(c)'
%     'Liver_sink_tmndnc(c)'
%     'Liver_sink_tmndnccoa(c)'
% %     'Muscle_EX_dag_hs(e)_[bc]'
% %     'Muscle_EX_acetone(e)_[bc]'
%     };
% model.ub(find(ismember(model.rxns,U))) = 0;
% % L = {'Muscle_EX_hco3(e)_[bc]'
% % %     'Muscle_EX_glyald(e)_[bc]'
% % %     'Muscle_EX_for(e)_[bc]'
% % %     'Muscle_EX_pyr(e)_[bc]'
% %  %   'Muscle_EX_k(e)_[bc]'
% %     'Muscle_EX_h2o2(e)_[bc]'
% %     };
% % model.lb(find(ismember(model.rxns,L))) = 0;
% % 
% %UE={'Muscle_EX_ala_L(e)_[bc]'};
% % model.ub(find(ismember(model.rxns,UE))) = 1000000;
% 
