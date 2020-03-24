function temperatura = recebe_temperatura
    global SerPIC
    fprintf(SerPIC,'%c','t');
    ler_temp = fscanf(SerPIC,'%s');
    temperatura = str2double(ler_temp);
    if temperatura > 150
        fprintf(SerPIC,'%c','t');
        ler_temp = fscanf(SerPIC,'%s');
        temperatura = str2double(ler_temp);
    end
    flushoutput(SerPIC);
    if(temperatura > 100) % Checagem de erro
        fprintf(SerPIC,'%c','t');
        ler_temp = fscanf(SerPIC,'%s');
        temperatura = str2double(ler_temp);
        if temperatura > 150
            fprintf(SerPIC,'%c','t');
            ler_temp = fscanf(SerPIC,'%s');
            temperatura = str2double(ler_temp);
        end
        flushoutput(SerPIC);
    end
    if(temperatura < 0) %Checagem de erro
        fprintf(SerPIC,'%c','t');
        ler_temp = fscanf(SerPIC,'%s');
        temperatura = str2double(ler_temp);
        if temperatura > 150
            fprintf(SerPIC,'%c','t');
            ler_temp = fscanf(SerPIC,'%s');
            temperatura = str2double(ler_temp);
        end
        flushoutput(SerPIC);
    end    
end