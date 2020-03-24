function finaliza()
    global SerPIC
    flushoutput(SerPIC);
    fclose(SerPIC);
    delete(SerPIC);
    delete(instrfind);
end