function [ output_args ] = MPC_PQ_init( input_args )
ttInitKernel('prioFP') 
data.exectime = 1e-6; % se inicializa porque true time lo requiere pero no se usa 
starttime = 0.1; % tiempo de arranque del controlador 
period = 1e-3; % periodo de muestreo del MPC (lazo nivel 2 de control de potencia)
ttCreatePeriodicTask('ctrl_task', starttime, period, 'MPC_PQ_c', data)
end

