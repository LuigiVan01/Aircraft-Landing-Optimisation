close all
clear all
clc

%% Model parameters
M = 22e3;
m = 130;
J = 100e3;
k_f = 6.73e5;
k_r = 1.59e4;            % modified: different (smaller) value for the front stiffness
% k_r = 6.73e5;
c = 4066;
c_w = 1.43e5;
L = 10;
S = 1/2*10^2;
Lf = 7.76;
Lr = 1.94;
T_max = 6e4;
theta_max = 10/180*pi;   % modified
Brake_max = 4e5;         
Fa_max = 1e5;

th = [M J m k_f k_r c c_w S L Lr Lf T_max theta_max Brake_max Fa_max]';
g = 9.81;

d = 0;

%% Control problem parameters Ground
Ts          =   0.01;                        % Sampling time
Tend_gr     =   15;                          % Time horizon
N_gr        =   Tend_gr/Ts;                  % Prediction steps

ds_T        = 500;
ds_L        = 150;
ds_D        = 150;
ds_B        = 75;
ds_Far      = 15;
ds_Faf      = 15;
ds_u_gr = [ds_T, ds_L, ds_D, ds_B, ds_Far, ds_Faf]';     % Downsampling the Ground inputs

nu_gr       =   6;

%% Control problem parameters Flight
Tend_fl     =   15;                          % Time horizon
N_fl        =   Tend_fl/Ts;                  % Prediction steps

ds_T        = 50;
ds_L        = 50;
ds_D        = 100;
ds_theta    = 25;
ds_u_fl = [ds_T, ds_L, ds_D, ds_theta]';     % Downsampling the inputs

nu_fl       =   4;

%% Plot of the States

Ts  = 0.01;
Tend = Tend_fl + Tend_gr;
Ntot = Tend/Ts;
nz = 6;

load('Result_Flight.mat');
load('Result_Ground.mat');

ground.sim(1,:) = ground.sim(1,:) + flight.sim(1,end);

z = [flight.sim(1:nz,:), ground.sim(1:nz,2:end)];
z_d = [flight.sim(nz+1:2*nz,:), ground.sim(nz+1:2*nz,2:end)];

time = 0:Ts:Tend;

figure(1)
hold on
plot(time,z(1,:));
plot(time,z_d(1,:));
xlabel('Time [s]','Interpreter','latex','FontSize',13);
grid 
legend('$X$','$\dot{X}$','Interpreter','latex','FontSize',13);
title('Longitudinal position and velocity','Interpreter','latex','FontSize',13);
hold off


figure(2)
hold on
plot(time,z(2,:));
plot(time,z_d(2,:));
xlabel('Time [s]','Interpreter','latex','FontSize',13);
grid 
legend('$\dot{X}$','$\ddot{X}$','Interpreter','latex','FontSize',13);
title('Longitudinal speed and acceleration','Interpreter','latex','FontSize',13)
hold off

figure(3)
hold on
plot(time,z(3,:));
plot(time,z_d(3,:));
xlabel('Time [s]','Interpreter','latex','FontSize',13);
grid 
legend('$Z$','$\dot{Z}$','Interpreter','latex','FontSize',13);
title('Vertical position and velocity','Interpreter','latex','FontSize',13)
hold off

figure(4)
hold on
% plot(time,z(4,:),'b','DisplayName','speed');
plot(time,z_d(4,:));
grid 
title('Vertical acceleration','Interpreter','latex','FontSize',13)
xlabel('Time [s]','Interpreter','latex','FontSize',13);
ylabel('$\ddot{Z}$ [$m/s^{2}$]','Interpreter','latex','FontSize',13);
hold off

figure(5)
hold on
plot(time,180/pi*z(5,:),'DisplayName','position');
% plot(time,180/pi*z_d(5,:));
grid 
title('Pitch angle','Interpreter','latex','FontSize',13)
xlabel('Time [s]','Interpreter','latex','FontSize',13);
ylabel('$\theta$ [deg]','Interpreter','latex','FontSize',13)
hold off

figure(6)
hold on
% plot(time,180/pi*z(6,:),'b','DisplayName','speed');
plot(time,180/pi*z_d(6,:));
grid 
title('Pitch acceleration','Interpreter','latex','FontSize',13)
xlabel('Time [s]','Interpreter','latex','FontSize',13);
ylabel('$\ddot{\theta}$ [$deg/s^{2}$]','Interpreter','latex','FontSize',13);
hold off

figure(7)
plot(z(1,:), z(3,:));
grid
title('Trajectory','Interpreter','latex','FontSize',13)
xlabel('X [m]','Interpreter','latex','FontSize',13);
ylabel('Y [m]','Interpreter','latex','FontSize',13);

%% Plots of the Inputs

T_real = zeros(Ntot,1);
L_real = zeros(Ntot,1);
D_real = zeros(Ntot,1);
B_real = zeros(Ntot,1);
th_real = zeros(Ntot,1);
Far_real = zeros(Ntot,1);
Faf_real = zeros(Ntot,1);

% Input "extension"
fin = 0;
for i = 1:length(flight.T)
    T_real(fin+1:fin+ds_u_fl(1,1),1) = repmat(flight.T(i,1),ds_u_fl(1,1),1);
    fin = fin + ds_u_fl(1,1);
end
for i = 1:length(ground.T)
    T_real(fin+1:fin+ds_u_gr(1,1),1) = repmat(ground.T(i,1),ds_u_gr(1,1),1);
    fin = fin + ds_u_gr(1,1);
end

fin = 0;
for i = 1:length(flight.L)
    L_real(fin+1:fin+ds_u_fl(2,1),1) = repmat(flight.L(i,1),ds_u_fl(2,1),1);
    fin = fin + ds_u_fl(2,1);
end
for i = 1:length(ground.L)
    L_real(fin+1:fin+ds_u_gr(2,1),1) = repmat(ground.L(i,1),ds_u_gr(2,1),1);
    fin = fin + ds_u_gr(2,1);
end

fin = 0;
for i = 1:length(flight.D)
    D_real(fin+1:fin+ds_u_fl(3,1),1) = repmat(flight.D(i,1),ds_u_fl(3,1),1);
    fin = fin + ds_u_fl(3,1);
end
for i = 1:length(ground.D)
    D_real(fin+1:fin+ds_u_gr(3,1),1) = repmat(ground.D(i,1),ds_u_gr(3,1),1);
    fin = fin + ds_u_gr(3,1);
end

fin = 0;
for i = 1:length(flight.Theta_ref)
    th_real(fin+1:fin+ds_u_fl(4,1),1) = repmat(flight.Theta_ref(i,1),ds_u_fl(4,1),1);
    fin = fin + ds_u_fl(4,1);
end

fin = N_fl;
for i = 1:length(ground.B)
    B_real(fin+1:fin+ds_u_gr(4,1),1) = repmat(ground.B(i,1),ds_u_gr(4,1),1);
    fin = fin + ds_u_gr(4,1);
end

fin = N_fl;
for i = 1:length(ground.Far)
    Far_real(fin+1:fin+ds_u_gr(5,1),1) = repmat(ground.Far(i,1),ds_u_gr(5,1),1);
    fin = fin + ds_u_gr(5,1);
end

fin = N_fl;
for i = 1:length(ground.Faf)
    Faf_real(fin+1:fin+ds_u_gr(6,1),1) = repmat(ground.Faf(i,1),ds_u_gr(6,1),1);
    fin = fin + ds_u_gr(6,1);
end

figure(8)
plot(time(1:end-1),T_max*T_real);
grid
title('Thrust','Interpreter','latex','FontSize',13);
xlabel('Time [s]','Interpreter','latex','FontSize',13);
ylabel('$T$ [N]','Interpreter','latex','FontSize',13);

figure(9)
plot(time(1:end-1),L_real);
grid
title('Lift Coefficient','Interpreter','latex','FontSize',13);
xlabel('Time [s]','Interpreter','latex','FontSize',13);
ylabel('$u_L$','Interpreter','latex','FontSize',13);

figure(10)
plot(time(1:end-1),D_real);
grid
title('Drag Coefficient','Interpreter','latex','FontSize',13);
xlabel('Time [s]','Interpreter','latex','FontSize',13);
ylabel('$u_D$','Interpreter','latex','FontSize',13);

figure(11)
plot(time(1:end-1),theta_max/pi*180*th_real);
grid
title('Pitch reference','Interpreter','latex','FontSize',13);
xlabel('Time [s]','Interpreter','latex','FontSize',13);
ylabel('$\theta_in$ [deg]','Interpreter','latex','FontSize',13);

figure(12)
plot(time(1:end-1),Brake_max*B_real);
grid
title('Brake Force','Interpreter','latex','FontSize',13);
xlabel('Time [s]','Interpreter','latex','FontSize',13);
ylabel('$F_B$ [N]','Interpreter','latex','FontSize',13);

figure(13)
plot(time(1:end-1),Fa_max*Faf_real);
grid
title('Rear Active suspension Force','Interpreter','latex','FontSize',13);
xlabel('Time [s]','Interpreter','latex','FontSize',13);
ylabel('$F_{Ar}$ [N]','Interpreter','latex','FontSize',13);

figure(14)
plot(time(1:end-1),Fa_max*Faf_real);
grid
title('Front Active suspension Force','Interpreter','latex','FontSize',13);
xlabel('Time [s]','Interpreter','latex','FontSize',13);
ylabel('$F_{Afr}$ [N]','Interpreter','latex','FontSize',13);

%% Other Plots

Lift_force = [flight.Fl, ground.Fl];
Drag_force = [flight.Fd, ground.Fd];
alpha = flight.alpha;
v_rel = flight.v_rel;
Rear_elastic_force = ground.Fs_r;
Front_elastic_force = ground.Fs_fr;

figure(15)
plot(time(1:end-1),Lift_force);
grid
title('Lift Force',"Interpreter","Latex");
xlabel('Time',"Interpreter","Latex");

figure(16)
plot(time(1:end-1),Drag_force);
grid
title('Drag Force',"Interpreter","Latex");
xlabel('Time',"Interpreter","Latex");

figure(17)
plot(time(1:1500),180/pi*alpha);
grid
title('Alpha',"Interpreter","Latex");
xlabel('Time',"Interpreter","Latex");

figure(18)
plot(time(1:1500),v_rel);
grid
title('Relative speed',"Interpreter","Latex");
xlabel('Time',"Interpreter","Latex");

figure(19)
plot(time(1501:end-1),Rear_elastic_force);
grid
title('Rear Elastic Force',"Interpreter","Latex");
xlabel('Time',"Interpreter","Latex");

figure(20)
plot(time(1501:end-1),Front_elastic_force);
grid
title('Front Elastic Force',"Interpreter","Latex");
xlabel('Time',"Interpreter","Latex");


%% Animation
for i=1/Ts:5:Tend/Ts
    figure(21)
     plot([z(1,i)-Lr*cos(z(5,i)) z(1,i)+Lf*cos(z(5,i))],...
        [z(3,i)-Lr*sin(z(5,i)) z(3,i)+Lf*sin(z(5,i))],'-k*', 'linewidth',1);
     grid
     title(['Time: ' num2str((i-1)*Ts) ' s'])
     axis([z(1,i)-2 z(1,i)+8.5 z(3,i)-3 z(3,i)+3]);
     pause(1e-3);      
end