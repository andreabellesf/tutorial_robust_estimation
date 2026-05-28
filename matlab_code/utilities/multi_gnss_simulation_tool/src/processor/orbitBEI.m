function [SatBEI_all]=orbitBEI(eph,indiceC,Time_index)
% orbitBEI Computes the orbits of Beidu satellites.

%% Parameters
pi=3.1415926535898;
mu=3.986004418e14;%costante gravitazionale [m^3/s^2]
omegae=7.2921151467e-5;%velocità angolare della terra [rad/s]
[n,~]=size(indiceC); 
%% Computing Position
for k=1:n
    if indiceC(k,2)~=0
    t0e=eph(indiceC(k,2),20); %Time in the week BST [s] 
    A=eph(indiceC(k,2),19)^2;
    n0=sqrt(mu/A^3);
    tk=Time_index-((eph(indiceC(k,2),6)*3600+eph(indiceC(k,2),7)*60+eph(indiceC(k,2),8)));
    deltan=eph(indiceC(k,2),14);
    mean_motion=n0+deltan;
    M0=eph(indiceC(k,2),15);
    M=M0+mean_motion*tk;%Mean anomaly
    ecc=eph(indiceC(k,2),17);
    f=@(x)x-ecc.*sin(x)-M;
    [E,~,~]=bisection(f,-(abs(M)+1),abs(M)+1,1e-18,200);%Eccentric anomaly
    senov=sqrt(1-ecc^2)*sin(E)/(1-ecc*cos(E));
    cosenov=(cos(E)-ecc)/(1-ecc*cos(E));
    v=atan2(senov,cosenov);%true anomaly
    omega=eph(indiceC(k,2),26);
    PHI=v+omega ;%argument of latitude
    Cus=eph(indiceC(k,2),18);
    Cuc=eph(indiceC(k,2),16);
    Crs=eph(indiceC(k,2),13);
    Crc=eph(indiceC(k,2),25);
    Cis=eph(indiceC(k,2),23);
    Cic=eph(indiceC(k,2),21);
    du=Cus*sin(2*PHI)+Cuc*cos(2*PHI);
    dr=Crs*sin(2*PHI)+Crc*cos(2*PHI);
    di=Cis*sin(2*PHI)+Cic*cos(2*PHI);
    u=PHI+du; %corrected argument of latitude  
    r=A*(1-ecc*cos(E))+dr;
    i0=eph(indiceC(k,2),24);
    idot=eph(indiceC(k,2),28);
    i=i0+di+idot*tk; %corrected inclination
    xk=r*cos(u); %position in orbital plane
    yk=r*sin(u) ;%positin in orbital plane
    if (k==1 || k==2 || k==3 || k==4 || k==5 ) % GEO satelliti
          OMEGA0=eph(indiceC(k,2),22);
          OMEGADOT=eph(indiceC(k,2),27);
          OMEGA=OMEGA0+OMEGADOT*tk-omegae*t0e;
          alpha=omegae*tk;
          beta=deg2rad(-5);
          Rx=[1 0 0;0 cos(beta) sin(beta);0 -sin(beta) cos(beta)];
          Rz=[cos(alpha) sin(alpha) 0;-sin(alpha) cos(alpha) 0;0 0 1];
          Xgk(1,k)=xk*cos(OMEGA)-yk*cos(i)*sin(OMEGA);
          Ygk(1,k)=xk*sin(OMEGA)+yk*cos(i)*cos(OMEGA);
          Zgk(1,k)=yk*sin(i);
          Position=Rz*Rx*[Xgk(1,k);Ygk(1,k);Zgk(1,k)];
          SatBEI_all(1,k)=Position(1,1);%[m]
          SatBEI_all(2,k)=Position(2,1);%[m]
          SatBEI_all(3,k)=Position(3,1);%[m]
    else % MEO satelliti
          OMEGA0=eph(indiceC(k,2),22);
          OMEGADOT=eph(indiceC(k,2),27);
          OMEGA=OMEGA0+(OMEGADOT-omegae)*tk-omegae*t0e ;
          SatBEI_all(1,k)=xk*cos(OMEGA)-yk*cos(i)*sin(OMEGA);%[m]
          SatBEI_all(2,k)=xk*sin(OMEGA)+yk*cos(i)*cos(OMEGA);%[m]
          SatBEI_all(3,k)=yk*sin(i);%[m]
    end
    end
end

