function [exectime, data] = calc(segment, data)
% funcion que ejecuta la logica del bloque True Time Kernel.
ex=0;
switch segment
    case 1
        % se ahce lectura de la entrada del bloque
        y = ttAnalogIn(1);
        ex = data.exectime;
        data.u = sin(y*2*pi*2);
    case 2
        ttAnalogOut(1, data.u);
        ex = -1;
end
exectime=ex;
end