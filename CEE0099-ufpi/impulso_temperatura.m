clc
clear
format shortg
addpath(genpath('src'))
global t y r e u pwm k SerPIC

% Adicione o nome de variáveis que queira salvar
salvar = {'t', 'y', 'r', 'e', 'u', 'pwm', 'ping', 'T'};
T = 1.0;            %tempo de amostragem
n = 100;            %número de amostras
o = 3;              %início de amostragem
t = (0:(n-1))*T;    %vetor de tempo

%% I/O

%caso não ache a planta, o programa simula pela função de transferência Gz
z = tf('z', T, 'variable', 'z^-1');
Gz = z^-1*(0.09142 + 0.2228*z^-1)/(1 - 0.6893*z^-1 - 0.108*z^-2);

%ajuste a COM e o baud rate em Gerenciador de Dispositivos
[termina, leitura, escrita, planta] = inicializacom('COM5', 'temperatura', Gz);
% [termina, leitura, escrita, planta] = inicializacom('COM3', 'velocidade', Gz);
SerPIC.Timeout = 1;

%% CONFIGURAÇÃO

pasta = ~isempty(planta)*'pratica' + isempty(planta)*'teorica';
salvar_em = ['teste/' pasta];

%ESTADO INCIAL
[r, y, e, u, pwm, de] = deal(zeros(n, 1)); 
e_min = -50;
e_max = 50;
de_min = -2;
de_max = 2;
u_min = 0;
u_max = 100;

ping = nan(n, 1);
t0 = tic;
kp=0.8;td=0.0;ti=1.1;

%calcula o numerador dos controladores PD, PI, PID
gd   = @(kp, td) [kp*td/T -kp*2*td/T kp*td/T];
gpi  = @(kp, ti) [kp*(1 + T/(2*ti)) -kp*(1 - T/(2*ti))];
gpid = @(kp, td, ti) [kp*(1 + T/(2*ti) + td/T) -kp*(1 + 2*td/T - T/(2*ti)) kp*td/T];
ke = flip(gpid(kp,td,ti));
ku = 1.0;

%Configuração fuzzy
a=newfis('tipper');
a=addvar(a,'input','erro',[-50 50]);
a=addmf(a,'input',1,'poor','trapmf',[-50 -50 -10 0]);
a=addmf(a,'input',1,'good','trimf',[-15 0 15]);
a=addmf(a,'input',1,'excellent','trapmf',[0 10 50 50]);
a=addvar(a,'input','rate',[-2 2]);
a=addmf(a,'input',2,'rancid','trimf',[-2 -2 0]);
a=addmf(a,'input',2,'delicious','trimf',[-2 0 2]);
a=addmf(a,'input',2,'delicious','trimf',[0 2 2]);
a=addvar(a,'output','velocidade',[0 50]);
a=addmf(a,'output',1,'cheap','trapmf',[0 0 5.5 6.3]);
a=addmf(a,'output',1,'average','trimf',[13 16.5 17.5]);
a=addmf(a,'output',1,'generous','trimf',[45 50 50]);

ruleList=[ ...
2 0 2 (0.25) 1
3 0 3 (1) 1
3 1 3 (0.3) 1
1 3 1 (0.3) 1
3 2 3 (1) 1
1 2 1 (1) 1
1 0 1 (1) 1
1 1 1 (1) 1];

a=addrule(a,ruleList);
showfis(a);
showrule(a);



%% LOOP DE CONTROLE

for k = 3:n
    %LEITURA
    time = tic;
    y(k) = leitura();

    %REFERÊNCIA E ERRO
    r(k) = 40;
    e(k) = r(k) - y(k);
    de(k) = (e(k) - e(k-1))/T;
    
    %SATURAÇÃO ERRO
    if e(k) > e_max
        e(k) = e_max;
    elseif e(k) < e_min
        e(k) = e_min;
    end
    
    %SATURAÇÃO RATE
    if de(k) > de_max
        de(k) = de_max;
    elseif de(k) < de_min
        de(k) = de_min;
    end
    
    %CONTROLE
    
    %Fuzzy:
    u(k)  = evalfis([e(k) de(k)], a); % Output calculation, input = [ 1 2]
    %PID
    %u(k) = ku*u(k-1) + ke*e(k-2:k);

    %SATURAÇÃO
    if u(k) > 100
        pwm(k) = 100;
    elseif u(k) < 0
        pwm(k) = 0;
    else
        pwm(k) = u(k);
    end
    
    %ESCRITA
    escrita(pwm(k));
    ping(k) = toc(time);
    
    %DELAY
    if isa(termina, 'function_handle')
        while toc(time) < T
        end
    end
end
termina();
fprintf('Tempo: %f segundos\n\n', toc(t0) - toc(time));

%% PLOT & SALVE

fig = plotudo(t(o:k), y, r, e, u, pwm, 0, 0, 0);
if ~exist(salvar_em, 'dir')
    mkdir(salvar_em);
end
date = datestr(datetime('now'));
date(date == '-' | date == ':') = '_';
path = [salvar_em '/' date];
save([path '.mat'], salvar{:})
saveas(fig, [path '.fig'])
disp(['Plant: ' salvar_em ' Saved at: ' path])
