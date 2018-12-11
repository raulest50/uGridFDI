clear all;
clc;
Vsal=120;
Psal=500;
Isal=Psal/Vsal;
Ra1=Vsal/Isal;
Ca1=1e-3;
La1=7e-3;
alphacero=5;
eta=1000;

% clear 
% close all
% clc
% Ra=[85 80 75 70 65 60 55 50 45 40 35 30 25 20];
% Ea=[20 30 40 50 60 70 80 90 100 110 120 130 140 150];
Ra=[85 80 75 70 65 60 55 50 45 40 35 30 25 20]*10^3;
Ea=[20 30 40 50 60 70 80 90 100 110 120 130 140 150];
CI=[0;0];
o=0;
for i=1:length(Ra)
    
    R=Ra(i);
    E=Ea(i);
    
    C=1*10^(-6);
    L=25*10^(-3);   %2 %25*10^(-3);    a menor valor de inductancia los picos no son tan altos
    %Variables linealizadas
    ref=240*sqrt(2); 
    %E=12;
    X2ss=240*sqrt(2);
    Uss=E/X2ss;
    X1ss=X2ss/(Uss*R);
    %Representacion del sistema linealizado
    Al=[0 -Uss/L; Uss/C -1/(R*C)];
    Bl=[-X2ss/L; X1ss/C];
    Cl=[0 1];

    %Controlador
    Alaa=[Al zeros(2,1) ;-Cl 0];
    Blaa=[Bl;0];
    pda=[-50 -51 -500];

    %coder.extrinsic('place'); 
    
    k=place(Alaa,Blaa,pda);
    Kp=k(1,1:2);
    Ki=k(1,3);
    %sim('controladoresv2015');
    
    [t,x]=sim('convertidorboostbuenov2015');
    CI=x(end,1:2);
    
    if i==1
        s=salida;
    end
    
    for j=1:length(salida)
        if o==0
%             tiempo=t;
            s2=salida;
        else
%             tiempo(j+o)=2*j+t(j);
            s2(j+o)=salida(j);        
        end
    end
    
    o=i*313;
    
%     if i==1
%         sal=zeros(6,length(salida));
%     end
%     sal(i)=salida
    
end

figure
plot(s)
%hold on
figure
plot(s2(1:length(s)))
figure
%tiempo=0:2/(length(t)-1):2;
% 2.9041e+03
tiempo=0:2*length(Ra)/(length(s2)-1):2*length(Ra);
plot(tiempo,s2)



close all
clc

R1=1%100
L1=4.5e-3%1
C1=1.1e-6%50e-6
R2=1%100
L2=4.5e-3%1
C2=C1%50e-6

R=Ra1%1000
RL=100
L=1
C=Ca1%50e-6

Vabc=170
I2=3
I1=1.17
F=60
La=3e-3


% Ap= [-1/(R*C)   1/C        0    -1/C      1/C        0
%        -1/L1      -R1/L1   1/L1    0          0         0
%           0          -1/C1      0       0          0         0
%           1/L          0          0    -RL/L      0         0
%        -1/L2          0          0       0     -R2/L2   1/L2
%            0            0          0       0     -1/C2       0]
Ap= [-(RL+R)/L1 1/L1 -R/L1 0
    -1/C1       0      0   0
    -R/L2       0  -(R+R2)/L2 1/L2
    0           0      -1/C2    0]
Bp = [    0      0
         
         1/C1   0
            0     0
       
            0    1/C2]
Cp = [    1     0
            0     0
            
            0    1
            0     0]'
%         Cp = [    R     0
%             0     0
%             
%             R    1
%             0     0]'

Dp = zeros(2,2)
CSTR = ss(Ap,Bp,Cp,Dp);
CSTR.InputName = {'Iu1', 'Iu2'};
CSTR.OutputName = {'I1','I2'};
CSTR.StateName = {'I1', 'V1', 'I2','V2'};


%  Design MPC Controller

%   MPCOBJ = mpc(PLANT,TS,P,M) specifies the control horizon, M. M is
%   either an integer (<= P) or a vector of blocking factors such that
%   sum(M) <= P.
%   MODELS.Plant = plant model (LTI or IDMODEL)
%         .Disturbance = model describing the input disturbances.
%                           This model is assumed to be driven by unit
%                          variance white noise.
%            .Noise = model describing the plant output measurement noise.
%                           This model is assumed to be driven by unit
%                          variance white noise.
%            .Nominal = structure specifying the plant nominal conditions
%                             (e.g., at which the plant was linearized).

% Create the controller object with sampling period, prediction and control horizons:
plant=CSTR
Ts =0.1;
p = 3;
m = 1;
mpcobj = mpc(plant, Ts, p, m);

% Specify actuator saturation limits as MV constraints.
mpcobj.MV = struct('Min',{-20;-20},'Max',{20;20},'RateMin',{-100;-100});
% Simulate Using Simulink®

% To run this example, Simulink® is required.
if ~mpcchecktoolboxinstalled('simulink')
    disp('Simulink(R) is required to run this example.')
    return
end

% Simulate closed-loop control of the linear plant model in Simulink. Controller "mpcobj" is specified in the block dialog.
% mdl = 'mpc_CSTR';
% open_system(mdl);
% sim(mdl);
%Continuo
%Representacion del sistema linealizado
    Al=[0 -Uss/L; Uss/C -1/(R*C)];
    Bl=[-X2ss/L; X1ss/C];
    Cl=[0 1];

    %Controlador
    Alaa=[Al zeros(2,1) ;-Cl 0];
    Blaa=[Bl;0];
    pda=[-50 -51 -500];

    %coder.extrinsic('place'); 
    
    k=place(Alaa,Blaa,pda);
    Kp=k(1,1:2);
    Ki=k(1,3);

%Discreto
Ts=0.01;
[adis,bdis,cdis,ddis]=c2dm(Al,Bl,Cl,0,Ts,'Tustin')
pd=[-50 -51];
pddis=[exp(pd(1,1)*Ts),exp(pd(1,2)*Ts)]
aadis=[adis zeros(2,1);-cdis 1]
badis=[bdis;0]
pdadis=[pddis exp(-500*Ts)]
kdis=acker(adis,bdis,pddis)
ktdis=place(aadis,badis,pdadis)%acker(aadis,badis,pdadis)
kpdis=ktdis(1,1:2)
kidis=ktdis(1,3)

figure
step(ss(Al,Bl,Cl,0))
figure

step(ss(adis,bdis,cdis,ddis,Ts))

close all



%Discretizacion del motor Diesel
tf1=tf([1 0.653],[1 0]);
tf2=tf(1,[0.2 1]);





