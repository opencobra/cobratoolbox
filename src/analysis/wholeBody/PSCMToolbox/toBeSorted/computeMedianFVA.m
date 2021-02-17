
figure
subplot(1,2,1)
bar(sort(maxFluxU-minFluxU));
title('Unconstrained model');
xlabel('Reactions (rank ordered)')
ylabel('Flux span (mmol/day/person')
subplot(1,2,2)
bar(sort(maxFlux-minFlux));
title('Physiologically constrained model');
xlabel('Reactions (rank ordered)')
ylabel('Flux span (mmol/day/person')

MeU = median(maxFluxU-minFluxU);
Me = median(maxFlux-minFlux);



MU = mean(maxFluxU-minFluxU);
M = mean(maxFlux-minFlux);
StU = std(maxFluxU-minFluxU);
St = std(maxFlux-minFlux);