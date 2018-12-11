function [exectime, data] = DIESEL_c( segment, data )
% funcion que ejecuta la logica del bloque True Time Kernel.
ex = 0; % variable auxiliar para poner el tiempo de ejecucion.
 switch segment 
	case 1 % primer segemento. 
		 % se hacen las lecturas de las entradas del ttkernel 
		V = ttAnalogIn(1); % corriente medida del convertidor 
		I = ttAnalogIn(2); % Tension medida del convertidor 
		p_set = ttAnalogIn(3); % set point de potencia actica del mpc 
		q_set = ttAnalogIn(4); % set point de potencia reactiva del mpc 

		
%code generation ->I_shift
		persistent U_I_shift;
		if isempty(U_I_shift)
			U_I_shift = zeros(1, 2);
		end
		persistent Y_I_shift;
		if isempty(Y_I_shift)
			Y_I_shift = zeros(1, 1);
		end
		U_I_shift = [I U_I_shift(1:end-1)];
		Ibet = U_I_shift(1) - (1166837127216645*U_I_shift(2))/1125899906842624 + (1084962686468603*Y_I_shift(1))/1125899906842624;
		Y_I_shift = [Ibet Y_I_shift(1:end-1)];

		
%code generation ->V_shift
		persistent U_V_shift;
		if isempty(U_V_shift)
			U_V_shift = zeros(1, 2);
		end
		persistent Y_V_shift;
		if isempty(Y_V_shift)
			Y_V_shift = zeros(1, 1);
		end
		U_V_shift = [V U_V_shift(1:end-1)];
		Vbet = U_V_shift(1) - (1166837127216645*U_V_shift(2))/1125899906842624 + (1084962686468603*Y_V_shift(1))/1125899906842624;
		Y_V_shift = [Vbet Y_V_shift(1:end-1)];

		[iar_x ibet_x] = Iref_calculation(V, Vbet, p_set, q_set);
		e_i = iar_x - I;
		
%code generation ->diesel
		persistent U_diesel;
		if isempty(U_diesel)
			U_diesel = zeros(1, 3);
		end
		persistent Y_diesel;
		if isempty(Y_diesel)
			Y_diesel = zeros(1, 2);
		end
		U_diesel = [e_i U_diesel(1:end-1)];
		Dd = (5793407944122229*U_diesel(1))/288230376151711744 - (2877383227746769*U_diesel(2))/72057594037927936 + (1431077150805859*U_diesel(3))/72057594037927936 + (8991807590778559*Y_diesel(1))/4503599627370496 - (4494601429313211*Y_diesel(2))/4503599627370496;
		Y_diesel = [Dd Y_diesel(1:end-1)];

		data.d = Dd;
		[data.Po data.Qo] = PQ_calculation(V, Vbet, I, Ibet);

		ex = data.exectime;
	case 2
		% se ponen las salidas en el DAC.
		ttAnalogOut(1, data.d);
		ttAnalogOut(2, data.Po);
		ttAnalogOut(3, data.Qo);
		ex = -1;
		end
		% se pone el tiempo de ejecucion. Es un requisito indispensable
		% del bloque true time.
		exectime=ex;
	end

function [Ia, Ib] = Iref_calculation(Va, Vb, p, q)
%#codegen 
% divide by zero protection
if(abs((Va^2+Vb^2))<=1000*eps(0))
	det = 1/eps(0);
else
	det = 1/(Va^2+Vb^2); % constante auxiliar
end
%det = 1/(Va^2+Vb^2);
Mat = det*[Va Vb; Vb -Va];
Iab = Mat*[2*p;2*q];
Iaaux = Iab(1);
Ibaux = Iab(2);
ilim=1e3;
if(Iaaux>ilim)
	Iaaux=ilim;
end
if(Iaaux<-ilim)
	Iaaux =-ilim;
end
if(isnan(Iaaux))
	Iaaux=0;
end
%-----------------
if(Ibaux>ilim)
	Ibaux=ilim;
end
if(Ibaux<-ilim)
	Ibaux =-ilim;
end
if(isnan(Ibaux))
	Ibaux=0;
end
%-----------------
Ia = Iaaux;
Ib = Ibaux;
end


function [p, q] = PQ_calculation(va, vb, ia, ib)
% Esta funcion calcula la potencia activa y reactiva instantanea
% para el caso mnosofasico. En la revision de 2 papers he observado
% que una manera de extender la teoria de potencia al caso monofasico
% es asumiendo la tension o corriente de una fase como la componente
% alpha y hacer un desfase de 90 grados para obtener una version
% artificial de beta.
paux=va*ia+vb*ib;
if(paux > 20e4)
	paux = 20e4;
end
if(paux < -20e4)
	paux = -20e-4;
end
p = paux/2; % potencia activa instantanea
qaux = vb*ia-va*ib;
if(qaux>20e4)
	qaux=20e4;
end
if(qaux<-20e4)
	qaux=-20e4;
end
q = qaux/2; % potencia reactiva instantanea
end
