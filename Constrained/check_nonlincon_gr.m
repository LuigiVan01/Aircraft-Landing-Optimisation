function [f] = check_nonlincon_gr(X,n_free,nu,nz,d,Ts,Tend,ds_u,Q,R,x_ref,th)

% Parameters
N = Tend/Ts;

z0 = [0;X(1,1);0;X(2,1);X(3,1);X(4,1)];
U  = X(n_free+1:end);

ds_T = ds_u(1,1);
ds_L = ds_u(2,1);
ds_D = ds_u(3,1);
ds_B = ds_u(4,1);
ds_Far = ds_u(5,1);
ds_Faf = ds_u(6,1);

tol = 1;

% Input sequence decomposition
fin = 0;
T = U(fin+1:fin+N/ds_T,1);
fin = fin + N/ds_T;
L = U(fin+1:fin+N/ds_L,1);
fin = fin + N/ds_L;
D = U(fin+1:fin+N/ds_D,1);
fin = fin + N/ds_D;
B = U(fin+1:fin+N/ds_B,1);
fin = fin + N/ds_B;
Far = U(fin+1:fin+N/ds_Far,1);
fin = fin + N/ds_Far;
Faf = U(fin+1:fin+N/ds_Faf,1);

% initialization of the cost function vector

F = [zeros(nz*(N+1),1);
     R*Far;
     R*Faf];
 
 % simulation
zsim = zeros(nz*(N+1),1);
zsim(1:nz,1) = z0;
zd = zeros(nz*(N+1),1);
ztemp = z0;
u_now = [T(1,1); L(1,1); D(1,1); B(1,1); Far(1,1); Faf(1,1)];
cont = zeros(nu,1);
index = ones(nu,1);
 
 for ind = 2:N+1
     cont = cont + ones(nu,1); 
     % input allocation
     if cont(1,1) == ds_T+1
         index(1,1) = index(1,1) + 1;
         u_now(1,1) = T(index(1,1),1);
         cont(1,1) = 0;
     end
     
     if cont(2,1) == ds_L+1
         index(2,1) = index(2,1) + 1;
         u_now(2,1) = L(index(2,1),1);
         cont(2,1) = 0;
     end
     
     if cont(3,1) == ds_D+1
         index(3,1) = index(3,1) + 1;
         u_now(3,1) = D(index(3,1),1);
         cont(3,1) = 0;
     end
     
     if cont(4,1) == ds_B+1
         index(4,1) = index(4,1) + 1;
         u_now(4,1) = B(index(4,1),1);
         cont(4,1) = 0;
     end
     
     if cont(5,1) == ds_Far+1
         index(5,1) = index(5,1) + 1;
         u_now(5,1) = Far(index(5,1),1);
         cont(5,1) = 0;
     end
     
     if cont(6,1) == ds_Faf+1
         index(6,1) = index(6,1) + 1;
         u_now(6,1) = Faf(index(6,1),1);
         cont(6,1) = 0;
     end
     
     % simulation
     [zdot]                              =   ground2(0,ztemp,...
                                                    u_now,d,th);
     zprime                              =   ztemp + Ts/2*zdot;
     ztemp                               =   ztemp+Ts*ground2(0,zprime,...
                                                u_now,d,th);
     zsim((ind-1)*nz+1:ind*nz,1)         =   ztemp;
     zd((ind-1)*nz+1:ind*nz,1)           = zdot;
     
     % Update the cost function
     F((ind-2)*nz+1:(ind-1)*nz,1)          =   Q*zdot/sqrt(N);
 end

% nonlinear equalities
ceq = [zdot...
%        ;zsim(end-3,1)...
%        ;zsim(end-1,1)...
       ];
   
% ceq = [];

% nonlinear inequalities
c = [-zsim(end-5,1) + x_ref(1,1);
    zsim(end-5,1) - x_ref(2,1)];

% c = [-ztemp(1,1) + x_ref(1,1);
%     ztemp(1,1) - x_ref(2,1);
%     zdot + tol*ones(nz,1);
%     -zdot + tol*ones(nz,1)];


f = [0; ceq];
% f = F'*F;

end