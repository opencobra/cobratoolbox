function types = classifyMoieties(L,S_tot)

types = cell(size(L,1),1);

isTypeC = ~any(L*S_tot,2); % Type C moieties are conserved in the open network
isSecondary = any(L(isTypeC,:),1); % Secondary metabolites are in type C moieties
isTypeA = ~any(L(:,isSecondary),2); % Type A moieties only include primary metabolites
isTypeB = ~isTypeA & ~isTypeC; % All other moieties are type B moieties

types(isTypeA) = {'A'};
types(isTypeB) = {'B'};
types(isTypeC) = {'C'};

types = [types{:}]';

