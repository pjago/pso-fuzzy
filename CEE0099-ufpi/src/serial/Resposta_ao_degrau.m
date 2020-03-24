%Código de Resposta ao Degrau em Malha Aberta
%Autor: Gabryel Figueiredo Soares

global SerPIC
clc; %Limpar o Workspace - INICIO
clear;    %Deletar todas as variáveis no Workspace
Ts = 150e-3;  %Determinação do período de amostragem
set_pwm(0); %zerar PWM

Qde_amostras = 400; %Quantidade de amostras do gráfico
% REF = 100; % Referência em 100% de PWM
% pwm = REF;
figure(3);
for k=1:Qde_amostras
    tt = clock; % Armazenar o tempo de início de cada amostra
    saida(k) = recebe_velocidade; %Recebe o valor medido de armazena
    if(saida(k)>100) % Checagem de erro
        saida(k) = recebe_velocidade;
    end
    if(saida(k)<0) %Checagem de erro
        saida(k) = recebe_velocidade;
    end
     if k <0.25*Qde_amostras  %Primeiro patamar
         ref(k) = 100;
         set_pwm(ref(k))
     end
      if k >=0.25*Qde_amostras && k <0.5*Qde_amostras%Segundo patamar
         ref(k) = 50;
         set_pwm(ref(k))
      end
      if k >=0.5*Qde_amostras && k <0.75*Qde_amostras%Segundo patamar
         ref(k) = 75;
         set_pwm(ref(k))
      end
     if k >=0.75*Qde_amostras
         ref(k) = 25;
         set_pwm(ref(k))
      end
    while etime(clock, tt) < Ts   
        %não fazer nada enquanto o tempo de amostragem não terminar
    end
end
set_pwm(0);
    Tempo = ([1:Qde_amostras]*Ts - Ts); %Calcula o tempo total da simulação
    plot(Tempo,saida,'b','LineWidth',2); %Gera o gráfico Tempo x Saída
    hold on;
    grid on
%     plot(Tempo,ref,'r','LineWidth',2); %Gera o gráfico Tempo x Referência
    xlabel('Tempo (s)');
    ylabel('Velocidade (RPS)');
%%
%Código de Resposta ao Degrau em Malha Aberta
%Autor: Gabryel Figueiredo Soares
clear;
global SerPIC
clc; %Limpar o Workspace - INICIO
clear;    %Deletar todas as variáveis no Workspace
Ts = 500e-3;  %Determinação do período de amostragem
set_temp(0); %zerar PWM

Qde_amostras = 2000; %Quantidade de amostras do gráfico
% REF = 100; % Referência em 100% de PWM
% pwm = REF;
figure(4);
for k=1:Qde_amostras
    tt = clock; % Armazenar o tempo de início de cada amostra
    saida(k) = recebe_temperatura; %Recebe o valor medido de armazena
    if(saida(k)>100) % Checagem de erro
        saida(k) = recebe_temperatura;
    end
    if(saida(k)<0) %Checagem de erro
        saida(k) = recebe_temperatura;
    end
     if k <0.25*Qde_amostras  %Primeiro patamar
         ref(k) = 100;
         set_temp(ref(k))
     end
      if k >=0.25*Qde_amostras && k <0.5*Qde_amostras%Segundo patamar
         ref(k) = 50;
         set_temp(ref(k))
      end
      if k >=0.5*Qde_amostras && k <0.75*Qde_amostras%Segundo patamar
         ref(k) = 75;
         set_temp(ref(k))
      end
     if k >=0.75*Qde_amostras
         ref(k) = 0;
         set_temp(ref(k))
      end
    while etime(clock, tt) < Ts   
        %não fazer nada enquanto o tempo de amostragem não terminar
    end
end
set_temp(0);
    Tempo = ([1:Qde_amostras]*Ts - Ts); %Calcula o tempo total da simulação
    plot(Tempo,saida,'b','LineWidth',2); %Gera o gráfico Tempo x Saída
    hold on;
    grid on
     plot(Tempo,ref,'r','LineWidth',2); %Gera o gráfico Tempo x Referência
    xlabel('Tempo (s)');
    ylabel('Temperatura (°C)');
