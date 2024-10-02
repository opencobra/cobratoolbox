function [knockouts] = milpOEReinserts(model, data, K, toDel, minP, numKO, timeLimit, printLevel)

if nargin < 7
    timeLimit = inf;
end
if nargin < 8
    printLevel = 0;
end
%%
switch toDel
    case 0
        rxns = findRxnIDs(model, data.mainActive);
        rxns = ismember(model.rxns,[model.rxns(K);model.rxns(rxns)]);
        reactions = model.rxns(~rxns);

        % MILP

        [r,c] = size(model.S);

        model.C_chemical=zeros(c,1);
        model.C_chemical(minP.proID)=1;

        yInd=[];
        notYInd=[];
        reactionIDs = findRxnIDs(model, reactions);

        for i=1:c
            if find(reactionIDs == i)
                yInd(end+1)=i;
                continue;
            else
                notYInd(end+1)=i;
            end
        end

        notYInd=sort(notYInd)';
        yInd=sort(yInd)';
        
        ySize=size(yInd,1);
        I = eye(c);
        A=[model.S;-model.S;I(notYInd,:);-I(notYInd,:); I(yInd,:); -I(yInd,:)];

        [aSizeRow, vSize]=size(A);
        reinserts=zeros(c,1);
        reinserts(yInd)=1;

        Ay1=diag(reinserts); %ub
        Ay1=Ay1*diag(model.ub);

        Ay2=diag(reinserts); %lb
        Ay2=Ay2*diag(model.lb);

        z1=find(Ay1);
        z2=find(Ay2);
        zSize=size([z1;z2],1);

        Ay= [zeros(2*r+2*(vSize-ySize),ySize);
            -Ay1(yInd,yInd);
            Ay2(yInd,yInd);
            ];

        B = [zeros(2*r,1);
            model.ub(notYInd);
            -model.lb(notYInd);
            zeros(2*(ySize),1);
            ];

        C=model.c;

        [A_w,Ay_w ,B_w,C_w, ~, ~, wSize] = seperateTransposeJoinOE(-A,-Ay,-B,-C,ySize,1,c,1000,zSize); %max(model.ub) 1000
        
        awSizeRow=size(A_w,1);

        Cjoined=[model.C_chemical; zeros(wSize+zSize,1); zeros(ySize,1)];

        A2=-[
            -C', -C_w';
            A, sparse(aSizeRow, wSize+zSize);
            sparse(awSizeRow, vSize), A_w];

        Ay2=-[
            zeros(1, ySize);
            Ay;
            Ay_w];

        C2=Cjoined(1:vSize+wSize+zSize,:);

        B2=-[
            0;
            B;
            B_w;
            ];

        z3=find(Ay2);
        zSizeOptKnock2=size(z3,1);

        [A2_w,Ay2_w,B2_w,C2_w,lb2_w,ub2_w,uSize]=seperateTransposeJoinOE(A2,Ay2,B2,C2,ySize,1,vSize+wSize+zSize,1000,zSizeOptKnock2); %max(model.ub) 1000

        [A2_wRow, A2_wCol]=size(A2_w);
        [ARow, ACol]=size(A);

        A3=[
            A2_w, sparse(A2_wRow,ACol), Ay2_w;                      %dual constraints
            zeros(1,uSize+zSizeOptKnock2+vSize),  -ones(1,ySize);   %y sum constraints
            sparse(ARow,uSize+zSizeOptKnock2), A, Ay;               %feasibility conatraint
            ];

        B3=[
            B2_w;
            numKO-ySize;
            B;
            ];

        C3=[C2_w;
            zeros(ACol,1);
            zeros(ySize,1);
            ];

        tmpL=lb2_w(1:uSize+zSizeOptKnock2);
        tmpH=ub2_w(1:uSize+zSizeOptKnock2);
        ysUpperBound=ones(ySize,1);
        lb3=[tmpL; model.lb; zeros(ySize,1)];
        ub3=[tmpH; model.ub; ysUpperBound];
        intVars=A2_wCol+ACol+1:A2_wCol+ACol+ySize;

        MILP.c = C3;
        MILP.osense = -1; % max
        MILP.A = sparse(A3);
        MILP.b = B3;
        MILP.lb = lb3; MILP.ub = ub3;
        MILP.x0 = [];
        MILP.vartype = char(ones(1,length(C3)).*double('C'));
        MILP.vartype(intVars) = 'B';
        MILP.csense = char(ones(1,length(B3)).*double('L'));
        
        milpSol = solveCobraMILP(MILP, 'timeLimit', timeLimit, 'printLevel', printLevel);

        %% add only found reactions

        rxns = reactions(milpSol.int == 1);
        knockouts = reactions(milpSol.int ~= 1);
        numel(rxns)
        numel(knockouts)
        %debug
        [irrev,~,~,~] = convertToIrreversible(model);
        addEnv(irrev, irrev.rxns(minP.bioID), irrev.rxns(minP.proID), knockouts, 'r');
        print('debug');
    case 1
        %Genes
    case 2
        %Enzymes
end