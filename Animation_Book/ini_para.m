%clear all;

global S Sn g mu13 mu20 mu32
global Te nb_te Tsimu

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   initialisation des hauteurs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Sampling period 
nb_te=0;
Te=1;                            % step time
Tsimu = 4000;                    % simulation time

%Initial level value
level_1_ini=0.4;
level_3_ini=0.3;
level_2_ini=0.2;

%Operating point for the level
level_1_ptf=0.4;
level_3_ptf=0.3;
level_2_ptf=0.2;

%Operating point for the flow rate
flow_rate_1_ptf=0.35e-4;
flow_rate_2_ptf=0.375e-4;

%Tank Section
S=0.0154;  
%Connection Section
Sn=5e-5;
%Gravity
g=9.81;
%Outflow cofficients
mu13=0.5;mu20=0.675;mu32=0.5;

%maximum and minimum flow rate
q_min=0;
q_max=1.5e-4;

%maximum and minimum level
h_min=0;
h_max=0.62;

%simulation period to solve differential equation
Tsimulation=1;

% Gain matrices for closed loop 
K1=[21.6 3 -5;2.9 19 -4]*10e-4;
K2=[-0.95 -0.32;-0.3 -0.91]*10e-4;