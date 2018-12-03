function [exectime, data] = calc(segment, data)
% funcion que ejecuta la logica del bloque True Time Kernel.
ex=0;
switch segment
    case 1
        % se ahce lectura de la entrada del bloque
        ut = ttAnalogIn(1);
        ex = data.exectime;
        
        persistent U;
        if isempty(U)
             U = zeros(1, 3);
        end
        persistent Y;
        if isempty(Y)
             Y = zeros(1, 2);
        end
        U = [ut U(1:end-1)];
        y_1 = (3867417694454701*U(2))/36028797018963968 - (6329353517423041*U(3))/72057594037927936 + (4389385923699487*Y(1))/2251799813685248 - (1070989120431317*Y(2))/1125899906842624;
        Y = [y_1 Y(1:end-1)];
        data.u = y_1;
    case 2
        ttAnalogOut(1, data.u);
        ex = -1;
end
exectime=ex;
end


function out = DifEq(U, Y)
    out = (3867417694454701*U(2))/36028797018963968 - (6329353517423041*U(3))/72057594037927936 + (4389385923699487*Y(1))/2251799813685248 - (1070989120431317*Y(2))/1125899906842624;
end

