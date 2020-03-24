function set_temp(duty)
    global SerPIC
    flushinput(SerPIC);
    fprintf(SerPIC,'%c','b');
    if duty<0
        duty = 0;
    end
    duty = int16((250)*(duty/100));
    dutyy = num2str(duty);
    fprintf(SerPIC, '%s\r', dutyy);
end