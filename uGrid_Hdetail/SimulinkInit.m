% este script es ejecutado al momento de ejecutar el modelo de simulink de
% la microgrid de esta carpeta.
% En la seccion de configuracion de simulink, En la pestaña de callBacks se
% configuran los scripts que se desean ejectar al incio, durante o al
% final de la simulacion.

% se cargan las matrices dinamicas del MPC DMC.
load('DMC_matrices');

% se carga la libreria de true time.
run('truetime-2.0\init_truetime');

load('modeloElectrico');
load('modeloDiesel_dotros')

