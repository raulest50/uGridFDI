% normalmente cuando se usa una variable persistente
% esta se limpia de memoria cundo se termina la simulacion. sin embargo
% cuando se usa la libreria de truetime, al finalizar la simulacion
% las variables persistentes se mantienen en memoria. por esto es necesa
% limpiarlas manualmente usando el comando clear.
% 
% para automatizar este proceso de limpieza de las variables persistentes
% se crea este script el cual se llama de manera automatica desde simulink
% al terminar la simulacion.
% 
% para configurar un llamado automatico de un script desde simulink:
% archivo > model properties > model properties. pestaña callbacks
% en stopFcn se pone la funcion que se desea que se ejecute al final 
% de la simulacion.


clear DIESEL_c;
clear BIO_c;
clear MPC_PQ_c;