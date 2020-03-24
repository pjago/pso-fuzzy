%Attempts to connect with plant or model, in that order
%[stop, read, write] = inicializacom(COM)
%[stop, read, write] = inicializacom(COM, Gz)
function [stop, read, write, plant] = inicializacom(COM, SYS, varargin)
    global SerPIC    
    if nargin >= 3
        Gz = varargin{1};
    else 
        Gz = 0;
    end
    try
        out = instrfind('Port', COM);
        if ~isempty(out)
            fclose(out);
            delete(out);
        end
        SerPIC = serial(COM);
        set(SerPIC,'BaudRate', 9600, 'DataBits', 8, 'Parity', 'none','StopBits', 1, 'FlowControl', 'none');
        fopen(SerPIC);
        s = SerPIC;
        s.RecordDetail = 'verbose';
        s.RecordName = 'comlog.txt';
        record(s, 'off');
        if isa(SYS, 'char')
            if strcmp(SYS, 'velocidade')
                read   = @() recebe_velocidade();
                write  = @(duty) set_pwm(duty);
                stop   = @() finaliza();
                plant = 'velocidade';
            elseif strcmp(SYS, 'temperatura')
                read   = @() recebe_temperatura();
                write  = @(duty) set_temp(duty);
                stop   = @() finaliza();
                plant = 'temperatura';
            end
            read();
            write(0);            
        else
            throw('segundo parâmetro deve ser uma string indicando o sistema! (velocidade ou temperatura)')
        end
    catch ME1
        if isa(Gz, 'tf') || isa(Gz, 'zpk') || isa(Gz, 'ss')
            Gz = tf(Gz);
            errors = textscan(ME1.message, '%[^\n]', 1);
%             disp([errors{end}{:} 10]);
%             disp(['Using transfer function model.' 10])
            read   = @() readsim(Gz); 
            write  = @(duty) writesim(duty);
            stop   = 0;
            plant  = '';
        else
%             disp(ME1)
        end
    end
end