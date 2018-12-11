function [ output_args ] = tttest( input_args )

% funcion para realizar la inicializacion de bloque true time kernel
% se requieren 2 archivos para cada bloque ttime kernel.
% una matlab funciton para inicializar y otra matlab function
% para implementar la logica del bloque.


ttInitKernel('prioFP') % comando necesesario y debe ser llamado primero
% para la inicializacion del true time kernel block
% prioFP significa fixed-Priority scheduling.

data.exectime = 1e-6;   % control task execution time
starttime = 0.0;       % control task start time
period = .1;          % control task period

ttCreatePeriodicTask('ctrl_task', starttime, period, 'calc', data)
end

