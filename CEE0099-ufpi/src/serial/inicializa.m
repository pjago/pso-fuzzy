function inicializa(porta)
    global SerPIC
    SerPIC = serial(porta);
    set(SerPIC,'BaudRate', 9600, 'DataBits', 8, 'Parity', 'none','StopBits', 1, 'FlowControl', 'none');
    fopen(SerPIC);
end