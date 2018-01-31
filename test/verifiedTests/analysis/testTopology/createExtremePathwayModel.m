function model = createExtremePathwayModel()
% creates a Network for extreme Pathway testing
% USAGE:
%    model = createExtremePathwayModel()
%
% OUTPUTS: 
%
%    model:     A Model for extreme pathway testing. 
%
%
% NOTE:
% Test problem from
%     Extreme Pathway Lengths and Reaction Participation in Genome-Scale Metabolic Networks
%     Jason A. Papin, Nathan D. Price and Bernhard Ø. Palsson
%    
%    R1:	A 	<=>	B 
%    R2:	2 B 	<=>	C + F 
%    R3:	2 B + G 	<=>	D + F 
%    R4:	D 	<=>	E + G 
%    R5:	C + G 	<=>	D 
%    R6:	C 	<=>	E 
%    R7:		<=>	A 
%    R8:	E 	<=>	
%    R9:	F 	<=>	
%  
mets = {'A','B','C','D','E','F','G'};
rxns = {'R1','R2','R3','R4','R5','R6','R7','R8','R9'};

S = [-1,  0,  0,  0,  0,  0, 1,  0,  0;
    1, -2, -2,  0,  0,  0, 0,  0,  0;
    0,  1,  0,  0, -1, -1, 0,  0,  0;
    0,  0,  1, -1,  1,  0, 0,  0,  0;
    0,  0,  0,  1,  0,  1, 0, -1,  0;
    0,  1,  1,  0,  0,  0, 0,  0, -1;
    0,  0, -1,  1, -1,  0, 0,  0,  0];

warning off

model = createModel();
for i = 1:numel(rxns)
    model = addReaction(model,rxns{i},'metaboliteList',mets,'stoichCoeffList',S(:,i));
end

