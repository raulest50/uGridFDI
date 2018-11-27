function [exectime, data] = calc(segment, data)
% funcion que ejecuta la logica del bloque True Time Kernel.
ex=0;
switch segment
    case 1
        % se leen las entradas
        input(1) = ttAnalogIn(1); % measure signal
        input(2) = ttAnalogIn(2); % setpoint signal
        % se invoca el subsystem con el controlador para calcular u(n)
        output = ttCallBlockSystem(2, input, 'ZController');
        
        data.u = output(1);
        ex = output(2);
        
    case 2 % fin de ejecucion, se ponen los valores en el DAc
        ttAnalogOut(1, data.u);
        ex = -1; % segmento final.
end
exectime=ex;
end

