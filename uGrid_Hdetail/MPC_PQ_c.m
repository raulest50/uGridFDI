function [exectime, data] = MPC_PQ_c( segment, data )

% funcion que ejecuta la logica del bloque True Time Kernel.
ex = 0; % variable auxiliar para poner el tiempo de ejecucion.
 switch segment 
	case 1 % primer segemento. 
        
		
        data.pbio = ttAnalogIn(1);
        data.qbio = ttAnalogIn(2);
        
        data.pdie = ttAnalogIn(3);
        data.qdie = ttAnalogIn(4);
        
		ex = data.exectime;
	case 2
		% se ponen las salidas en el DAC.
		ttAnalogOut(1, data.pbio);
        ttAnalogOut(2, data.qbio);
        ttAnalogOut(3, data.pdie);
		ttAnalogOut(4, data.qdie);
		ex = -1;
		end
		% se pone el tiempo de ejecucion. Es un requisito indispensable
		% del bloque true time.
		exectime=ex;
end


    












% 
% Nu = 100; % horizonte de control.
%         
%         % BIOGENERADOR
%         
%         persistent Du_BIO; % deltas de u 
%         persistent out_BIO; % salida actual del conrolador MPC.
% 
%         if isempty(Du_BIO) % inicializacion de los deltas de uu
%             Du = zeros(2*Nu, 1);
%         end
% 
%         if isempty(out_BIO) % inicializaion de la salida del controlador MPC
%             out = [0; 0];
%         end
% 
% 
%         du_BIO = [qp_BIO(1), qp_BIO(Nu+1)];
%         Du_BIO = [du_BIO(1); Du(1:Nu-1); du_BIO(2); Du(Nu+1:end-1)];% actualizar historial deltas de u.
%         out_BIO = [ out(1)+du_BIO(1); out(2)+du_BIO(2) ]; %calcular salida del controlador.
% 
%         data.out_BIO = out_BIO;
%         data.duv_BIO = Du_BIO;
% 
%         % DIESEL
%         
%         persistent Du_DIESEL; % deltas de u 
%         persistent out_DIESEL; % salida actual del conrolador MPC.
% 
%         if isempty(Du_DIESEL) % inicializacion de los deltas de uu
%             Du = zeros(2*Nu, 1);
%         end
% 
%         if isempty(out_DIESEL) % inicializaion de la salida del controlador MPC
%             out = [0; 0];
%         end
% 
% 
%         du_DIESEL = [qp_DIESEL(1), qp_DIESEL(Nu+1)];
%         Du_DIESEL = [du_DIESEL(1); Du(1:Nu-1); du_DIESEL(2); Du(Nu+1:end-1)];% actualizar historial deltas de u.
%         out_DIESEL = [ out(1)+du_DIESEL(1); out(2)+du_DIESEL(2) ]; %calcular salida del controlador.
% 
%         data.out_DIESEL = out_DIESEL;
%         data.duv_DIESEL = Du_DIESEL;




