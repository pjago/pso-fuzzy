% DADOS DA PLANTA
%% Velocidade
%O per�odo de amostragem da velocidade � 50e-3
yest(k)= 0.8067 *yest(k-1) + 0.1122 *yest(k-2) + 0.0648*e_est(k-1) - 0.02273*e_est(k-2);

%% Temperatura
%O per�odo de amostragem da temperatura � 10 segundos
yest(k)= 0.9906 *yest(k-1) - 0.04783 *yest(k-2) + 0.1904*ref(k-1) - 0.04783*ref(k-2);





