clc
clear
close all
addpath(genpath('../../CEE0099-ufpi'));
global t y r e de u du up pwm fir SerPIC

%% par�metros do especialista fuzzy
% utilizar dois fuzzy n�o funcionou bem... (melhor ignorar o erro de regime, e resolver via feedfoward)
% params.mf = ...
%  {{{'input', 'erro', [-50 50], [-0.2 0.2], {'trapmf', 'trimf', 'trapmf'}}
%    {'input', 'rate', [-600 600], [-0.2 0.2], {'trapmf', 'trimf', 'trapmf'}}
%    {'output', 'saida_transitoria', [-100 100], [-0.2 0.2], {'trimf', 'trimf', 'trimf'}}}
%   {{'input', 'referencia', [20 50], [-0.2 0.2], {'trapmf', 'trimf', 'trapmf'}}
%    {'output', 'saida_permanente', [20 100], [-0.2 0.2], {'trimf', 'trimf', 'trimf'}}}};
% a = [];

%% tanque de n�vel
params.mf = ...
 {{{'input', 'erro', [-5 5], [-0.5 0.5], {'trapmf', 'trimf', 'trapmf'}}
   {'input', 'rate', [-2 2], [-0.5 0.5], {'trapmf', 'trimf', 'trapmf'}}
   {'output', 'saida_permanente', [0 10], [-0.5 0.5], {'trimf', 'trimf', 'trimf'}}}
 };
params.limits = struct();
params.limits.saida_sistema = struct('min', 0, 'max', 10);

%% velocidade
% params.mf = ...
%  {{{'input', 'erro', [-30 30], [-0.5 0.5], {'trapmf', 'trimf', 'trapmf'}} % degrau m�ximo
%    {'input', 'rate', [-150 150], [-0.5 0.5], {'trapmf', 'trimf', 'trapmf'}} % degrau m�ximo / 8*T
%    {'output', 'saida_transitoria', [-100 100], [-0.5 0.5], {'trimf', 'trimf', 'trimf'}}}
%  };

%% simetrias para reduzir a dimens�o da part�cula do pso
params.msimetrico = 0; % membership simetry
params.wsimetrico = 0; % weights simetry
a = [];

%% c�lculo do universo de discurso de fun��es triangulares
i = 1;
for k = 1:length(params.mf) % conjunto fuzzy
    fuzzmf = params.mf{k};
    for j = 1:length(fuzzmf) % entradas e sa�das
        [~, ~, x_limits, v_limits, mf] = fuzzmf{j}{:};
        universo_discurso = peak2peak(x_limits);
        universo_triangulo = universo_discurso*5/6;
        universo_ponto = universo_discurso/5;
        x_max = min(x_limits);
        for ii = i + (0:length(mf)-1)*3
            for iii = ii:(ii + 2) % pontos das fun��es de pertin�ncia
                a(iii).min = x_max - (ii ~= i && iii == ii)*(2*universo_ponto);
                a(iii).max = a(iii).min + universo_ponto;
                a(iii).minVelocity = min(v_limits)*(a(iii).max - a(iii).min);
                a(iii).maxVelocity = max(v_limits)*(a(iii).max - a(iii).min);
                x_max = a(iii).max;
            end
        end
        i = iii + 1;
    end
end
%% corrigindo o universo de discurso para os trap�zios
i = 1;
aux = [];
for k = 1:length(params.mf)
    fuzzmf = params.mf{k};
    for j = 1:length(fuzzmf)
        [~, ~, x_limits, v_limits, mf] = fuzzmf{j}{:};
        if strcmp(mf{1}, 'trapmf')
            ax.min = a(i).min;
            ax.max = a(i+1).max;
            ax.minVelocity = min(v_limits)*(ax.max - ax.min);
            ax.maxVelocity = max(v_limits)*(ax.max - ax.min);
            if params.msimetrico
                aux = [aux ax a(i+2:i+3)];
            else
                aux = [aux ax a(i+2:i+6)];
                assert(strcmp(mf{end}, 'trapmf'), 'fun��es extremo devem ser do mesmo tipo!');
                ax.min = a(i+7).min;
                ax.max = a(i+8).max;
                ax.minVelocity = min(v_limits)*(ax.max - ax.min);
                ax.maxVelocity = max(v_limits)*(ax.max - ax.min);
                aux = [aux ax];
            end
        else
            if params.msimetrico
                aux = [aux a(i:i+3)];
            else
                aux = [aux a(i:i+8)];
            end
        end
        i = i + 9;
    end
end
a = aux;
i = length(a) + 1;

%% pesos das regras fuzzy
if params.wsimetrico
    nw = sum(2.^cellfun(@(x) length(x), params.mf));
    rules = unique(nchoosek(repmat(1:2, [1 3]), 3), 'rows');
    rules(:,4) = 0;
    rules(:,5) = 1;
    params.exclude = [2 2 1; 2 2 2; 2 2 3];
    params.reverse = [1 1 1; 1 2 1; 1 2 2; 1 3 1; 2 2 2; 3 1 3; 3 2 2; 3 2 3; 3 3 3];    
    rules(1,5) = 0.5; % (�nfase no erro)
    rules(3,5) = 0.5; % (�nfase no erro)
else
    nw = sum(3.^cellfun(@(x) length(x), params.mf));
    rules = unique(nchoosek(repmat(1:3, [1 3]), 3), 'rows');
    rules(:,4) = 0;
    rules(:,5) = 1;
end
p = 1;
for i = i:(i+nw-1)
    a(i).min = rules(p,4);
    a(i).max = rules(p,5);
    a(i).maxVelocity = 0.3*(a(i).max - a(i).min);
    a(i).minVelocity = 0.3*(a(i).min - a(i).max);
    p = p + 1;
end

problem.limits = a;

%% Par�metros do PSO
% Constriction Coeficients - Clerk and Kennedy(2002)
phi1 = 2.05;
phi2 = 2.05;
phi = phi1+phi2;
kappa = 1;
chi = 2*kappa/abs(2-phi - sqrt(phi^2 - 4*phi));

%3, 50; 15, 4000
params.plotar = 0;      %plotar entre cada intera��o?
params.MaxIt = 5;        %Maximum Number of Iterations;
params.nPop = 10000;           %Swarm Size
params.w = chi;               %Inercia Coefficient;
params.wdamp = 0.5;        %Damping Ratio of Inertia Coefficient 
params.c1 = chi*phi1;              %Personal Acceleration Coefficient;
params.c2 = chi*phi2;              %Social Accelleration Coefficient
params.ShowIterInfo = true; %Show iteration flag

%% tanque de n�vel vitim
params.n = 83;
params.T = 1.0;
z = tf('z', params.T, 'variable', 'z^-1');
params.Gz = 0.08*z^-1/(1 - z^-1);
params.sistema = 'nivel';
params.referencia(1:params.n) = [6*ones(43, 1); zeros(40, 1)];
params.K = Inf;
params.D = -4;

%% velocidade li�o
% params.n = 43;
% params.T = 0.05;
% z = tf('z', params.T, 'variable', 'z^-1');
% params.Gz = z^-1*(0.01028 + 0.04649*z^-1)/(1 - 0.7939*z^-1 - 0.09379*z^-2);
% params.sistema = 'velocidade';
% params.K = dcgain(params.Gz);
% params.referencia(1:params.n) = 20;

%% velocidade pjago
% params.n = 103;
% params.T = 0.114;
% z = tf('z', params.T, 'variable', 'z^-1');
% params.Gz = z^-1*(0.09142 + 0.2228*z^-1)/(1 - 0.6893*z^-1 - 0.108*z^-2);
% params.sistema = 'velocidade';
% params.K = dcgain(params.Gz);
% params.referencia(1:params.n) = 30;

%% treino com refer�ncia vari�vel
% params.n = 300;
% for i=1:params.n
%     if i<=params.n/4
%         params.referencia(i) = 20;
%     elseif i>params.n/4 && i<=params.n/2
%         params.referencia(i) = 40;
%     elseif i>params.n/2 && i<=params.n*3/4
%          params.referencia(i) = 20;
%     elseif i>params.n*3/4 && i<=params.n
%             params.referencia(i) = 30;
%     end
% end

%% Calling PSO
warning('off', 'fuzzy:general:warnEvalfis_NoRuleFired');
problem.CostFunction = @(particula) objfunc(script_planta(particula, params), 'IAE');
out = PSO(problem, params);
BestSol= out.BestSol;
BestCosts = out.BestCost; %3259.1
pop = out.pop;
pos = out.BestSol;
warning('on', 'fuzzy:general:warnEvalfis_NoRuleFired');

%% Best Solution
figure
params.plotar = 1;
% params.n = 300;
for i=1:params.n
    if i<=params.n/4
        params.referencia(i) = 20;
    elseif i>params.n/4 && i<=params.n/2
        params.referencia(i) = 40;
    elseif i>params.n/2 && i<=params.n*3/4
         params.referencia(i) = 20;
    elseif i>params.n*3/4 && i<=params.n
            params.referencia(i) = 30;
    end
end

% params.n = 300;
% for i=1:params.n
%     if i<=params.n/4
%         params.referencia(i) = 3;
%     elseif i>params.n/4 && i<=params.n/2
%         params.referencia(i) = 5;
%     elseif i>params.n/2 && i<=params.n*3/4
%          params.referencia(i) = 7;
%     elseif i>params.n*3/4 && i<=params.n
%             params.referencia(i) = 5;
%     end
% end

if exist('fis', 'var')
    script_planta(fis, params);
else
    [resultado, fis] = script_planta(BestSol(1).Position, params);
end

%% PLOT
for i = 1:length(fis)
    figure
    II = length(params.mf{i}) - 1;
    for ii = 1:II
        [x, mf] = plotmf(fis(i), 'input', ii);
        subplot(II, 1, ii)
        plot(x, mf)
        xlabel(params.mf{i}{ii}{2})
    end
    figure
    II = 1;
    [x, mf] = plotmf(fis(i), 'output', 1);
    subplot(II, 1, 1)
    plot(x, mf)
    xlabel(params.mf{i}{ii+1}{2})
end
save('fuzzy.mat')
