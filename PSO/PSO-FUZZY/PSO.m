function out = PSO(problem, params)
db = struct(); % struct para debug

%% Problem Definition
CostFunction = problem.CostFunction;   %Cost function
nVar = length(problem.limits);    % Number of Unknow (Decision) Variables
VarSize = [1 nVar];          %Matrix size of Docision variables

%% Parameters of PSO
MaxIt = params.MaxIt;      %Maximum Number of Iterations;
nPop = params.nPop;        %Swarm Size
w = params.w;            %Inercia Coefficient;
wdamp = params.wdamp;     %Damping Ratio of Inertia Coefficient 
c1 = params.c1;           %Personal Acceleration Coefficient;
c2 = params.c2;           %Social Accelleration Coefficient
ShowInfo = params.ShowIterInfo ; %Flag for parameter info showing
limits = problem.limits;

%% Initialization

% The particle Template
empty_particle.Position = [];
empty_particle.Velocity = [];
empty_particle.Cost = [];
empty_particle.Best.Position = [];
empty_particle.Best.Cost = [];

%Create Population Array
particle = repmat(empty_particle,nPop,1);

%Initialize Global Best
GlobalBest.Cost = inf;

fh = figure;
an = animatedline('Marker', 'o');
xlim([0 MaxIt]);

function buttoncb(src, ~)
    if ~get(src, 'Value')
        com.mathworks.mlservices.MLExecuteServices.consoleEval('dbcont')
    end
end
ButtonH = uicontrol('Style', 'ToggleButton', 'String', 'Stop', 'Value', 0, 'Callback', @buttoncb);
hold on
if params.plotar
    fp = figure;
end
%Initialization of population
for i=1:nPop
    drawnow;
    if get(ButtonH, 'Value') == 1
        set(ButtonH, 'string', 'Run');
        keyboard;
    else
        set(ButtonH, 'string', 'Stop');
    end
    %Generation Random Solutions
    particle(i).Position = [];
    for j = 1:length(limits)
        particle(i).Position(j) = unifrnd(limits(j).min, limits(j).max);
    end
    
    %Initialize velocity:
    particle(i).Velocity = zeros(VarSize);
    
    %Evaluation
    if params.plotar
        figure(fp);
    end
    particle(i).Cost = CostFunction(particle(i).Position);
    hold on
    
    %Update the Personal Best
    particle(i).Best.Position = particle(i).Position;
    particle(i).Best.Cost = particle(i).Cost; 
    if particle(i).Best.Cost < GlobalBest.Cost
        GlobalBest = particle(i).Best;
    end
end

if  ShowInfo
    disp(['Iteration  ', num2str(0) ,'  Best Cost = ',num2str(GlobalBest.Cost)])
    fc = gcf;
    figure(fh);
    addpoints(an, 0, GlobalBest.Cost);
    drawnow;
    figure(fc);
end

BestCosts = zeros(MaxIt,1);

%% Main Loop of PSO
for it=1:MaxIt
    if params.plotar
        fp = figure;
    end  
    for i=1:nPop
        drawnow;
        if get(ButtonH, 'Value') == 1
            set(ButtonH, 'string', 'Run');
            keyboard;
        else
            set(ButtonH, 'string', 'Stop');
        end
        %Update velocity
        particle(i).Velocity = w*particle(i).Velocity ...
         + c1*rand(VarSize).*(particle(i).Best.Position - particle(i).Position)...
         + c2*rand(VarSize).*(GlobalBest.Position - particle(i).Position);
        
        %Update position then apply Upper and Lower Bound Limits
        for ii = 1:size(problem.limits,2)
                particle(i).Velocity(ii) = max(particle(i).Velocity(ii), limits(ii).minVelocity);
                particle(i).Velocity(ii) = min(particle(i).Velocity(ii), limits(ii).maxVelocity);
                particle(i).Position(ii) = particle(i).Position(ii) + particle(i).Velocity(ii);
                particle(i).Position(ii) = max(particle(i).Position(ii), limits(ii).min);
                particle(i).Position(ii) = min(particle(i).Position(ii), limits(ii).max);
        end
        
        %Evaluation
        if params.plotar
            figure(fp);
        end
        particle(i).Cost = CostFunction(particle(i).Position);
        if particle(i).Cost < particle(i).Best.Cost
            particle(i).Best.Position = particle(i).Position;
            particle(i).Best.Cost = particle(i).Cost;
            %Update the global best
            if particle(i).Best.Cost < GlobalBest.Cost
                GlobalBest = particle(i).Best;
            end
        end
    end
    
    %Store the best cost Value
    BestCosts(it) = GlobalBest.Cost;
    
    %DIsplay Iteration Information
    if  ShowInfo
        disp(['Iteration  ', num2str(it) ,'  Best Cost = ',num2str(BestCosts(it))])
        fc = gcf;
        figure(fh);
        addpoints(an, it, GlobalBest.Cost);
        drawnow;
        figure(fc);
    end
  
    %Damping Inertia coeficient
    w = w*wdamp;
      
end
    out.BestSol = GlobalBest;
    out.BestCost = BestCosts;
    out.pop = particle;
end