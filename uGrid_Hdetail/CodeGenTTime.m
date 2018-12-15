
% Este script hace la inicializacion del modelo de la microred
% con el mas alto nivel de detalle.
% 
% primero se parte de los parametros de los controladores en su version
% continua. Estos se pasan Z deacuerdo al tiempo de muestreo deseado por
% el usuario. Luego se transforman las funciones de transferencia en Z
% a sus correspondientes ecuaciones de diferencias ya implementadas como
% matalab function (se trata de code generation).
% cuando las funciones se generan no es necesario modificar elementos del
% modelo mediante la funcion de matlab set_param, ya que toda la configura
% cion necesria para los bloques true time kernel queda definida por un
% par de archivos, los que son generados en este script para cada bloque.


% proporcional y resonante en un mismo cociente
% % % % % % % % % % % % % % % % % % % % % % % % % % % %
%            Kp s^2 + s (Kp wa + Ki ) + Kp w0         %
%  H(s) =  -------------------------------------      % 
%                  s^2  +  s wa  +  w0^2              %
% % % % % % % % % % % % % % % % % % % % % % % % % % % %

% primero se construyen los controladores respectivos en dominio
% continuo.

w0 = 2*pi*60; % frecuencia de la red, que es comun para todos.
Ts=1e-4; % tiempo de muestreo de los controladores discretos.

%
% %
% % % % % %              % % % % % % %  
%   Generacion funciones en Z        %
% % % % % %              % % % % % % % 
% %
%

%%%%%%%%%%%%%%%%%%%%%%%
% PR BIO, TF en Z
%%%%%%%%
Kb = 2/100; % parte proporcional del control resonante
wab = 20; % ancho de campana para el convertidor bio
Kib = 2; % ganancia integral bio.
Hb_s = tf([ Kb (Kb*wab + Kib) Kb*w0^2], [1 wab w0^2]); % control continuo bio
Hb_z = c2d(Hb_s, Ts,'foh'); % control bio en z.


%%%%%%%%%%%%%%%%%%%%%%%
% PR DIESEL, TF en Z
%%%%%%%%
Kd = 2/100; % parte proporcional del control resonante
wad = 20; % ancho de campana para el convertidor bio
Kid = 2; % ganancia integral bio.
Hd_s = tf([ Kb (Kb*wab + Kib) Kb*w0^2], [1 wab w0^2]); % control continuo diesel.
Hd_z = c2d(Hb_s, Ts,'foh'); % control diesel en z.


%%%%%%%%%%%%%%%%%%%%%%%
% DESFASE 90 GRADOS TF en Z
%%%%%%%%
Hsf_z = c2d(tf([2.7e-3 -1], [2.7e-3 1]), Ts);

%
% %
% % % % % % % %                     % % % % % % % % % % 
%    GENERACION CODIGO - ECUACIONES EN DIFERENCIAS    % 
% % % % % % % %                     % % % % % % % % % %
% %
%


% declaracion de variables
token_fname = '$Fn'; % token para reemplazar nombre de la funcion.
token_ftarget = '$Ftar';
Bio_ifname = 'BIO_init';
Bio_fname = 'BIO_c'; % nombre de la funcion de control del bio.
Diesel_ifname = 'DIESEL_init';
Diesel_fname = 'DIESEL_c'; % nombre de la funcion de control del diesel.

token_st_time = '$STT'; % para reemplazar el tiempo de arranque del control
token_Ts = '$Ts'; % para reemplazar el tiempo de muestreo del controlador.

% tokens para reemplazar los argumentos de la funcion que calcula la
% referencia de corriente y la funcion que hace el calculo de la potencia
% instantanea.
token_var1 = '$Var1$';
token_var2 = '$Var2$';
token_var3 = '$Var3$';
token_var4 = '$Var4$';

% primero se generan las funciones de init de los true time kernel.
F_init_base = ...
    ['function [ output_args ] = $Fn( input_args )\n'...
    'ttInitKernel(''prioFP'') \n' ...
    'data.exectime = 1e-6; %% se inicializa porque true time lo requiere pero no se usa \n' ...
    'starttime = $STT; %% tiempo de arranque del controlador \n' ...
    'period = $Ts; %% periodo de muestreo \n' ...
    'ttCreatePeriodicTask(''ctrl_task'', starttime, period, ''$Ftar'', data)\n' ...
    'end'];


% cabecera comun a las funciones de control de diesel y bio.
F_header = ...
    ['function [exectime, data] = $Fn( segment, data )\n' ...
    '%% funcion que ejecuta la logica del bloque True Time Kernel.' ... 
    '\nex = 0; %% variable auxiliar para poner el tiempo de ejecucion.' ...
    '\n switch segment \n' ...
    '\tcase 1 %% primer segemento. \n' ...
    '\t\t %% se hacen las lecturas de las entradas del ttkernel \n' ...
    '\t\tV = ttAnalogIn(1); %% corriente medida del convertidor \n' ...
    '\t\tI = ttAnalogIn(2); %% Tension medida del convertidor \n' ...
    '\t\tp_set = ttAnalogIn(3); %% set point de potencia actica del mpc \n' ... 
    '\t\tq_set = ttAnalogIn(4); %% set point de potencia reactiva del mpc \n'];

% finalizacion de la seccion de la funcion de control
% despues de esta porcion de codigo sigue la definicion de las
% funciones locales.
F_ending = ...
    ['\t\tex = data.exectime;\n'...
     '\tcase 2\n' ...
     '\t\t%% se ponen las salidas en el DAC.\n' ...
     '\t\tttAnalogOut(1, data.d);\n' ...
     '\t\tttAnalogOut(2, data.Po);\n' ...
     '\t\tttAnalogOut(3, data.Qo);\n' ...
     '\t\tex = -1;\n' ...
     '\t\tend\n' ...
     '\t\t%% se pone el tiempo de ejecucion. Es un requisito indispensable\n' ...
     '\t\t%% del bloque true time.\n' ...
     '\t\texectime=ex;\n' ...
     '\tend'];


% string para definir la funcion local que calcula la corriente de 
% referencia.
I_ref_function = ...
    ['\n\nfunction [Ia, Ib] = Iref_calculation(Va, Vb, p, q)\n' ...
    '%%#codegen \n' ...
    '%% divide by zero protection\n' ...
    'if(abs((Va^2+Vb^2))<=1000*eps(0))\n' ...
    '\tdet = 1/eps(0);\n' ...
    'else\n' ...
    '\tdet = 1/(Va^2+Vb^2); %% constante auxiliar\n' ...
    'end\n' ...
    '%%det = 1/(Va^2+Vb^2);\n' ...
    'Mat = det*[Va Vb; Vb -Va];\n' ...
    'Iab = Mat*[2*p;2*q];\n' ...
    'Iaaux = Iab(1);\n' ...
    'Ibaux = Iab(2);\n' ...
    'ilim=1e3;\n' ...
    'if(Iaaux>ilim)\n' ...
    '\tIaaux=ilim;\n' ...
    'end\n' ...
    'if(Iaaux<-ilim)\n' ...
    '\tIaaux =-ilim;\n' ...
    'end\n' ...
    'if(isnan(Iaaux))\n' ...
    '\tIaaux=0;\n' ...
    'end\n' ...
    '%%-----------------\n' ...
    'if(Ibaux>ilim)\n' ...
    '\tIbaux=ilim;\n' ...
    'end\n' ...
    'if(Ibaux<-ilim)\n' ...
    '\tIbaux =-ilim;\n' ...
    'end\n' ...
    'if(isnan(Ibaux))\n' ...
    '\tIbaux=0;\n' ...
    'end\n' ...
    '%%-----------------\n' ...
    'Ia = Iaaux;\n' ...
    'Ib = Ibaux;\n' ...
    'end\n'];

% string con la funcion que hace el calculo de la potencia instantanea
% para el caso monofasico.
Pq_calculation = ...      % va  vb   ia  ib
    ['\n\nfunction [p, q] = PQ_calculation(va, vb, ia, ib)\n' ...
    '%% Esta funcion calcula la potencia activa y reactiva instantanea\n' ...
    '%% para el caso mnosofasico. En la revision de 2 papers he observado\n' ...
    '%% que una manera de extender la teoria de potencia al caso monofasico\n' ...
    '%% es asumiendo la tension o corriente de una fase como la componente\n' ...
    '%% alpha y hacer un desfase de 90 grados para obtener una version\n' ...
    '%% artificial de beta.\n' ...
    'paux=va*ia+vb*ib;\n' ...
    'if(paux > 20e4)\n' ...
    '\tpaux = 20e4;\n' ...
    'end\n' ...
    'if(paux < -20e4)\n' ...
    '\tpaux = -20e-4;\n' ...
    'end\n' ...
    'p = paux/2; %% potencia activa instantanea\n' ...
    'qaux = vb*ia-va*ib;\n' ...
    'if(qaux>20e4)\n' ...
    '\tqaux=20e4;\n' ...
    'end\n' ...
    'if(qaux<-20e4)\n' ...
    '\tqaux=-20e4;\n' ...
    'end\n' ...
    'q = qaux/2; %% potencia reactiva instantanea\n' ...
    'end\n'];


%%%%%%%%%%%%%%%%%%%%%%%%%
% CREACION init bio:
%%%%%%%%%%
%
BIO_initFcn = strrep(F_init_base, token_fname, Bio_ifname);
BIO_initFcn = strrep(BIO_initFcn, token_st_time, num2str(.3));
BIO_initFcn = strrep(BIO_initFcn, token_Ts, num2str(Ts));
BIO_initFcn = strrep(BIO_initFcn, token_ftarget, Bio_fname);
file_bio_init = fopen([Bio_ifname '.m'], 'w+');
fprintf(file_bio_init, BIO_initFcn);
fclose(file_bio_init);

%%%%%%%%%%%%%%%%%%%%%%%%%
% CREACION control bio:
%%%%%%%%%%
%
F_cBIO = strrep(F_header, token_fname, Bio_fname);

% se calcula el desfase de 90 grados de I y de V.
F_cBIO = [F_cBIO '\n' write_Equation(Hsf_z, 'I_shift', 2, 'I', 'Ibet')];
F_cBIO = [F_cBIO '\n' write_Equation(Hsf_z, 'V_shift', 2, 'V', 'Vbet')];

% se calcula la referencia de corriente para cumplir con el set point de
% potencia del mpc
F_cBIO = [F_cBIO '\n' '\t\t[iar_x ibet_x] = Iref_calculation(V, Vbet, p_set, q_set);'];
F_cBIO = [F_cBIO '\n' '\t\te_i = iar_x - I;']; % se calcula el error de corriente

% se calcula la accion de control
F_cBIO = [F_cBIO '\n' write_Equation(Hb_z, 'bio', 2, 'e_i', 'Dd')];

% se pone la accion de control en la variable de salida.
F_cBIO = [F_cBIO '\n' '\t\tdata.d = Dd;'];

% se hace el calculo de la potencia instantanea.
F_cBIO = [F_cBIO '\n' '\t\t[data.Po data.Qo] = PQ_calculation(V, Vbet, I, Ibet);'];

% se escriben las funciones locales de la funcion de control.
F_cBIO = [F_cBIO '\n\n' F_ending I_ref_function Pq_calculation];

file_BIO_c = fopen([Bio_fname '.m'], 'w+');
fprintf(file_BIO_c, F_cBIO);
fclose(file_BIO_c);

%%%%%%%%%%%%%%%%%%%%%%%%%
% CREACION init diesel:
%%%%%%%%%%
%
DIESEL_initFcn = strrep(F_init_base, token_fname, Diesel_ifname);
DIESEL_initFcn = strrep(DIESEL_initFcn, token_st_time, num2str(.3));
DIESEL_initFcn = strrep(DIESEL_initFcn, token_Ts, num2str(Ts));
DIESEL_initFcn = strrep(DIESEL_initFcn, token_ftarget, Diesel_fname);
file_diesel_init = fopen([Diesel_ifname '.m'], 'w+');
fprintf(file_diesel_init, DIESEL_initFcn);
fclose(file_diesel_init);

%%%%%%%%%%%%%%%%%%%%%%%%%
% CREACION control diesel:
%%%%%%%%%%
%
F_cDIESEL = strrep(F_header, token_fname, Diesel_fname);

F_cDIESEL = [F_cDIESEL '\n' write_Equation(Hsf_z, 'I_shift', 2, 'I', 'Ibet')];
F_cDIESEL = [F_cDIESEL '\n' write_Equation(Hsf_z, 'V_shift', 2, 'V', 'Vbet')];
                                              
F_cDIESEL = [F_cDIESEL '\n' '\t\t[iar_x ibet_x] = Iref_calculation(V, Vbet, p_set, q_set);'];
F_cDIESEL = [F_cDIESEL '\n' '\t\te_i = iar_x - I;']; % se calcula el error de corriente

F_cDIESEL = [F_cDIESEL '\n' write_Equation(Hd_z, 'diesel', 2, 'e_i', 'Dd')];

% se pone la accion de control en la variable de salida.
F_cDIESEL = [F_cDIESEL '\n' '\t\tdata.d = Dd;'];

% se hace el calculo de la potencia instantanea.
F_cDIESEL = [F_cDIESEL '\n' '\t\t[data.Po data.Qo] = PQ_calculation(V, Vbet, I, Ibet);'];

% se escriben las funciones locales de la funcion de control.
F_cDIESEL = [F_cDIESEL '\n\n' F_ending I_ref_function Pq_calculation];

file_DIESEL_c = fopen([Diesel_fname '.m'], 'w+');
fprintf(file_DIESEL_c, F_cDIESEL);
fclose(file_DIESEL_c);

% se limpian todas las variables creadas en la generacion de codigo.
clearvars;



            % % % % % % % % % % % % % % % % % % % % % % % % % % 
            %       CREACION MATRICEZ DINAMICAS DEL MPC       %
            % % % % % % % % % % % % % % % % % % % % % % % % % % 

load('DMC_matrices');

% se limpian todas las variables usadas en la creacion mpcobj
clearvars -except G GF; % excepto mpcobj.


            % % % % % % % % % % % % % % % % % % % %
            %   DEFINICION DE FUNCIONES LOCALES   %
            % % % % % % % % % % % % % % % % % % % %

% funcion local a la cual se le ingresa una transfer function en z
% y entrega en string el codigo en matlab que la implementa.
% 
% Hz es la funcion de transferencia en z que se convertira en ecuacion
% de diferencias.
% tag es un string que se agrega a las variables del codigo generado
% para distinguir cada variable de manera unica en caso de que 
% se use multiples veces esta funcion para un mismo m-file
% 
% indentLevel es un entero que indica el nivel de identacion del 
% codigo que se desea generar con esta funcion. este ultimo parametro
% solo se usa con motivos de tener maor orden y estetica en el codigo
% pero no afecta la logica del mismo.
function y = write_Equation(Hz, tag, indentLevel, in_name, out_name)
    ind = repmat('\t', 1, indentLevel);
    % nombres de las variables en el codigo a generar.
    U_name = ['U_' tag];
    Y_name = ['Y_' tag];
    
    Num = Hz.Numerator{1};
    Den = Hz.Denominator{1};
    
    nn = length(Num);
    nd = length(Den);
    
    % se obtinene la ecuacion en diferencias.
    YsymName = [Y_name '(x)'];
    UsymName = [U_name '(x)'];
    syms('x');
    syms(YsymName);
    syms(UsymName);
    
    y = eval( ['getFVector(' Y_name ', x+1, nd)'] );
    u = eval( ['getFVector(' U_name ', x, nn)'] );
    eqy = (sum(u.*Num)-sum(y(2:end).*Den(2:end)))/Den(1);
    eqy_char = strrep(char(eqy), 'x - ', '');
    
    r = [ind '\n%%code generation ->' tag '\n'];
    % variable persistente vector U (entradas).
    r = [r ind 'persistent ' U_name ';\n'];
    r = [r ind 'if isempty(' U_name ')\n'];
    r = [r ind '\t' U_name ' = zeros(1, ' num2str(nn) ');\n'];
    r = [r ind 'end\n'];
    % variable persistente vector de salidas Y.
    r = [r ind 'persistent ' Y_name ';\n'];
    r = [r ind 'if isempty(' Y_name ')\n'];
    r = [r ind '\t' Y_name ' = zeros(1, ' num2str(nd-1) ');\n'];
    r = [r ind 'end\n'];
    r = [r ind U_name ' = [' in_name ' ' U_name '(1:end-1)];\n']; % desplazamiento entradas
    r = [r ind out_name ' = ' eqy_char ';\n']; % calcula salida actual.
    % desplazamiento vector de salidas.
    r = [r ind Y_name ' = [' out_name ' ' Y_name '(1:end-1)];\n'];
    y = r;
end

%funcion local que crea un vector simbolico de una funcion dada
function y = getFVector(v, x, n)
    r = sym(zeros(1, n));
    r(1) = v(x-1);
    for i=2:1:n
        r(i) = v(x-i);
    end
    y = r;
end

% funcion local para hacer identacion de un string.
% solo cumple fines esteticos y de orden del codigo pero no de
% funcionalidad.
function y = Indentation(s, N)
    indent = repmat('\t', 1, N);
    r0 = strsplit(s, '\\n');
    r1 = strcat([indent '\n'], r0);
    y = strjoin(r1);
end
