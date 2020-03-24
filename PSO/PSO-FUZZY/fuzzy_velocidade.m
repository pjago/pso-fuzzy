function output=fuzzy_velocidade(erro,rate)

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

output = evalfis([erro rate], a); % Output calculation, input = [ 1 2]

%%
[x,mf] = plotmf(a,'input',1);
subplot(2,1,1)
plot(x,mf)
xlabel('input 1 (gaussmf)')
[x,mf] = plotmf(a,'input',2);
subplot(2,1,2)
plot(x,mf)
xlabel('input 2 (trimf)')
figure
[x,mf] = plotmf(a,'output',1);
plot(x,mf)
xlabel('out 1 (trimf)')