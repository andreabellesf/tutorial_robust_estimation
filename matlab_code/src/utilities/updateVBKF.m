function [x,P,residuals] = updateVBKF(xPred, PPred, y, satPos, nObs, clkMatrix, cfg)

% initialization of variables
nx = length(xPred);
ny = length(y);

% Save in memory all results
x_old_old=xPred;
P_old_old=PPred;

% Make sure measurement vector is a column
y = y(:);

% Initialization of the hyper-parameters
tau=1;
% % % e0=0.95;
% % % f0=0.05;

ti=1;
% convergence_threshold=1e-9;

% ---- 2. VB iteration parameters ------------------------------------
maxIter = 30;   % Prevent an unbounded iteration loop.
tol = 1e-9;
minSat = 6;     % Original code falls back when <=5 paired sats remain.

% Independent Beta priors for code and phase (both 0.95/0.05 originally).
priorE=0.95*ones(ny,1);
priorF=0.05*ones(ny,1);

% Initialization of the vector which indicate whether measurements are or
% not outliers
z_i=ones(1,length(y));




while (tau>convergence_threshold)
    ind=find(z_i>(1-1e-3));           % Index for code observation
    if(ti>=3)                                           % Increase threshold to further improve correct detection
        ind=find(z_i>(1-1e-4));
    end
    int = ind;
    if(ti==1)                                           % Initialize index
        ind_org=[int int+length(z_i)/2];
        %                 ind_org=int;
    end
    if(length(int)<=5)
        % Update of the mean
        [x_new_new, P_new_new]= cubature_measurement_update_dm( x, P, H, y, R );
        x_old_old=x_new_new;
        P_old_old=P_new_new;
        indicator=0;
        break
    else
        ind=[int int+length(z_i)/2];
        diag_R_=diag(R);
        R_ind=diag(diag_R_(ind));
        H_ind=H(ind,:);
        z_i_ind=z_i(ind);
        y_ind=y(ind);
        hx_ind=hx(ind);
        [x_new_new, P_new_new]=cubature_measurement_update_dm( x, P, H_ind, y_ind, R_ind./z_i_ind );
        %                 [x_new_new, P_new_new]=cubature_measurement_update(obj,H_ind,R_ind./z_i_ind,...
        %                     y_ind,svPos, indPivot,nSat,ind);
        for i=1:length(z_i)/2                            % Seperate code and phase hyperparameter because of different accuracies
            e_C(i)=e0_C+z_i(i);
            f_C(i)=f0_C+1-z_i(i);
        end
        for i=1:length(z_i)/2
            e_L(i)=e0_L+z_i(i);
            f_L(i)=f0_L+1-z_i(i);
        end
        % Hyper-Parameter Update
        [~,~,~,B_t]=cubature_Bt_update_dm(x_new_new,P_new_new,y, H);
        %                 [~,~,~,B_t]=cubature_Bt_update(x_new_new,P_new_new,y_ind,obj,svPos,indPivot,nSat,ind);
        indicator=1;
        b_hat_diag=diag(B_t);
        R_ind_diag=diag(R_ind);
        t=1;
        for i=int
            %                     pi_t_L=psi(e_L(i))-psi(e_L(i)+f_L(i)+1);
            %                     pi_1_t_L=psi(f_L(i)+1)-psi(e_L(i)+f_L(i)+1);
            pi_t_L=psi(e_L(i))-psi(e_L(i)+f_L(i));
            pi_1_t_L=psi(f_L(i))-psi(e_L(i)+f_L(i));
            P_1=exp(pi_t_L-0.5*trace(b_hat_diag(t)/(R_ind_diag(t))));
            P_0=exp(pi_1_t_L);
            z_i_ind(t)=(P_1)/(P_1+P_0);
            t=t+1;
        end
        for i=int
            pi_t_C=psi(e_C(i))-psi(e_C(i)+f_C(i));
            pi_1_t_C=psi(f_C(i))-psi(e_C(i)+f_C(i));
            P_1=exp(pi_t_C-0.5*trace(b_hat_diag(t)/(R_ind_diag(t))));
            P_0=exp(pi_1_t_C);
            z_i_ind(t)=(P_1)/(P_1+P_0);
            t=t+1;
        end
        if(ti>1)
            tau=norm(x_new_new-x_old_old)/norm(x_old_old);
        end
        x_old_old=x_new_new;
        P_old_old=P_new_new;
        ti=ti+1;
        z_i(ind)=z_i_ind;
    end
end
if(indicator)                                             % Make sure enough satellites for PVT solution
    %             index=[1:6 , int+6];
    %             xNew = x_old_old(index);
    %             PNew = P_old_old(index,index);
    xNew = x_old_old;
    PNew = P_old_old;
else
    xNew = x_old_old;
    PNew = P_old_old;
    int=1:length(z_i)/2;
end




[hx,H,R] = observationModel(xPred, satPos, nObs, clkMatrix, cfg);

residuals = y - hx;

S = H * PPred * H' + R;
K = PPred * H' / S;

x = xPred + K * residuals;

I = eye(nx);
P = (I - K * H) * PPred;

end







% Prediction
F = eye(6+n);
F(1:3, 4:6) = eye(3);
Q = blkdiag( Qvel, Qamb*eye(n) );
G = [ [eye(3)*dt^2/2; eye(3)*dt; zeros(n,3)], [ zeros(3,n); zeros(3,n); eye(n)*dt ] ];
PVikf( :, :, iTime)  = F * PVikf( :, :, iTime-1) * F' + G*Q*G';
xVikf( : ,iTime) = F*xVikf( : ,iTime-1);
% Correction
[ xVikf( :, iTime), PVikf( :, :, iTime),  auxZ ] = RobustKF_independent_dm( xVikf( :, iTime), PVikf( :, :, iTime), y, R, H  );







function [ xNew, PNew, int ] = RobustKF_independent_dm( x, P, y, R, H )
%% Initialization

x_old_old=x;
P_old_old=P;
hx = H*x;
tau=1;
shreshold=1e-9;
e0_L=0.95;
f0_L=0.05;
e0_C=0.95;
f0_C=0.05;
ti=1;
z_i=ones(1,length(y));

%% VBKF
while (tau>shreshold)
    ind1=find(z_i(1:length(z_i)/2)>(1-1e-3));           % Index for code observation
    ind2=find(z_i(length(z_i)/2+1:end)>(1-1e-3));       % Index for phase observation
    if(ti>=3)                                           % Increase threshold to further improve correct detection
        ind1=find(z_i(1:length(z_i)/2)>(1-1e-4));
        ind2=find(z_i(length(z_i)/2+1:end)>(1-1e-4));
    end
    [int,~,~]   = intersect(ind1,ind2);                 % Identify satellites with clean code and phase observation
    if(ti==1)                                           % Initialize index
        ind_org=[int int+length(z_i)/2];
        %                 int_org=int;
    end
    if(length(int)<=5)
        % Update of the mean
        [x_new_new, P_new_new]= cubature_measurement_update_dm( x, P, H, y, R );
        x_old_old=x_new_new;
        P_old_old=P_new_new;
        indicator=0;
        break
    else
        ind=[int int+length(z_i)/2];
        diag_R_=diag(R);
        R_ind=diag(diag_R_(ind));
        H_ind=H(ind,:);
        z_i_ind=z_i(ind);
        y_ind=y(ind);
        hx_ind=hx(ind);
        [x_new_new, P_new_new]=cubature_measurement_update_dm( x, P, H_ind, y_ind, R_ind./z_i_ind );
        %                 [x_new_new, P_new_new]=cubature_measurement_update(obj,H_ind,R_ind./z_i_ind,...
        %                     y_ind,svPos, indPivot,nSat,ind);
        for i=1:length(z_i)/2                            % Seperate code and phase hyperparameter because of different accuracies
            e_C(i)=e0_C+z_i(i);
            f_C(i)=f0_C+1-z_i(i);
        end
        for i=1:length(z_i)/2
            e_L(i)=e0_L+z_i(i);
            f_L(i)=f0_L+1-z_i(i);
        end
        % Hyper-Parameter Update
        [~,~,~,B_t]=cubature_Bt_update_dm(x_new_new,P_new_new,y, H);
        %                 [~,~,~,B_t]=cubature_Bt_update(x_new_new,P_new_new,y_ind,obj,svPos,indPivot,nSat,ind);
        indicator=1;
        b_hat_diag=diag(B_t);
        R_ind_diag=diag(R_ind);
        t=1;
        for i=int
            %                     pi_t_L=psi(e_L(i))-psi(e_L(i)+f_L(i)+1);
            %                     pi_1_t_L=psi(f_L(i)+1)-psi(e_L(i)+f_L(i)+1);
            pi_t_L=psi(e_L(i))-psi(e_L(i)+f_L(i));
            pi_1_t_L=psi(f_L(i))-psi(e_L(i)+f_L(i));
            P_1=exp(pi_t_L-0.5*trace(b_hat_diag(t)/(R_ind_diag(t))));
            P_0=exp(pi_1_t_L);
            z_i_ind(t)=(P_1)/(P_1+P_0);
            t=t+1;
        end
        for i=int
            pi_t_C=psi(e_C(i))-psi(e_C(i)+f_C(i));
            pi_1_t_C=psi(f_C(i))-psi(e_C(i)+f_C(i));
            P_1=exp(pi_t_C-0.5*trace(b_hat_diag(t)/(R_ind_diag(t))));
            P_0=exp(pi_1_t_C);
            z_i_ind(t)=(P_1)/(P_1+P_0);
            t=t+1;
        end
        if(ti>1)
            tau=norm(x_new_new-x_old_old)/norm(x_old_old);
        end
        x_old_old=x_new_new;
        P_old_old=P_new_new;
        ti=ti+1;
        z_i(ind)=z_i_ind;
    end
end
if(indicator)                                             % Make sure enough satellites for PVT solution
    %             index=[1:6 , int+6];
    %             xNew = x_old_old(index);
    %             PNew = P_old_old(index,index);
    xNew = x_old_old;
    PNew = P_old_old;
else
    xNew = x_old_old;
    PNew = P_old_old;
    int=1:length(z_i)/2;
end
end




function [xNew, PNew]=cubature_measurement_update_dm( x, P, H, y, R_ind )

mu=x;
var=P;

S=chol(var,'lower');
Sr=chol(R_ind,'lower');

n=length(mu);
univec1=eye(n);
univec2=-eye(n);
univec=sqrt(n).*[univec1 univec2];

mumatrix=repmat(mu,1,2*n);
samp=mumatrix+S*univec;

hx = H*mu;
hx_mu=0;
x_mu=0;
hx_var=[];
x_var=[];

for i=1:2*n
    h_x_new_new = H*samp(:,i);
    hx_mu=hx_mu+h_x_new_new./(2*n);
    x_mu=x_mu+samp(:,i)./(2*n);
end
for i=1:2*n
    h_x_new_new = H*samp(:,i);
    hx_var=[hx_var (h_x_new_new-hx_mu)./sqrt(2*n)];
    x_var=[x_var (samp(:,i)-x_mu)./sqrt(2*n)];
end

[~,hx_S]=qr([hx_var Sr]');
hx_S=hx_S';
P_xz=x_var*hx_var';
Wk=(P_xz/hx_S')/hx_S;

xNew=mu+Wk*(y-hx_mu);
[~,S_new_new]=qr([x_var-Wk*hx_var Wk*Sr]');
S_new_new=S_new_new';
PNew=S_new_new*S_new_new';
end


function [samp,samp_mean,samp_var,B_t]=cubature_Bt_update_dm(mu,var,y, H)
S=chol(var+1e-10*eye(size(var)),'lower');
n=length(mu);
univec1=eye(n);
univec2=-eye(n);
univec=sqrt(n).*[univec1 univec2];
mumatrix=repmat(mu,1,2*n);
samp=mumatrix+S*univec;
B_t=0;
for i=1:2*n
    x=samp(:,i);
    h_x_new_new = H*x;
    B_t=B_t+(y-h_x_new_new)*(y-h_x_new_new)';
end
B_t=B_t./(2*n);
samp_mean=mean(samp,2);
samp_var=0;
for i=1:2*n
    samp_var=samp_var+(samp(:,i)-samp_mean)*(samp(:,i)-samp_mean)';
end
samp_var=samp_var./(2*n);

end