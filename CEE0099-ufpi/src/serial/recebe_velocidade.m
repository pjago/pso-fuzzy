function velocidade = recebe_velocidade
    global SerPIC
    fprintf(SerPIC,'%c','w');
    ler = fscanf(SerPIC,'%s');
    velocidade = str2double(ler);
    if velocidade > 100
        fprintf(SerPIC,'%c','w');
        ler = fscanf(SerPIC,'%s');
        velocidade = str2double(ler);
    end
    flushoutput(SerPIC);
    if(velocidade > 100) % Checagem de erro
        fprintf(SerPIC,'%c','w');
        ler = fscanf(SerPIC,'%s');
        velocidade = str2double(ler);
        if velocidade > 100
            fprintf(SerPIC,'%c','w');
            ler = fscanf(SerPIC,'%s');
            velocidade = str2double(ler);
        end
        flushoutput(SerPIC);
    end
    if(velocidade < 0) %Checagem de erro
        fprintf(SerPIC,'%c','w');
        ler = fscanf(SerPIC,'%s');
        velocidade = str2double(ler);
        if velocidade > 100
            fprintf(SerPIC,'%c','w');
            ler = fscanf(SerPIC,'%s');
            velocidade = str2double(ler);
        end
        flushoutput(SerPIC);
    end
end