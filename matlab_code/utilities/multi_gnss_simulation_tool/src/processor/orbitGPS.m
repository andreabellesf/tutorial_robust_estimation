function [SatGPS_all]=orbitGPS(eph,indexG,Time_index)
% orbitGPS Computes the orbits of GPS satellites.

%% Parameters
pi=3.1415926535898;
OMEGApe= 7.2921151467e-5;% [rad/s]
mu=3.986005e14;%m^3/s^2
[n,~]=size(indexG);
%% Computing Position
for k=1:n
    if indexG(k,2)~=0
    a=(eph(indexG(k,2),19))^2;%m
    mean_motion=sqrt(mu/a^3)+(eph(indexG(k,2),14));
    tk=Time_index-((eph(indexG(k,2),6)*3600+eph(indexG(k,2),7)*60+eph(indexG(k,2),8)));%Fa la differenza tra il tempo in cui vogliamo ottenera la nuova posizione del satellite e quella in cui si registra l'osservazione (non considero il toe vero)
    Mk=eph(indexG(k,2),15)+mean_motion*tk;
    ecc=eph(indexG(k,2),17);
    f=@(x)x-ecc.*sin(x)-Mk;
    [Ek,~,~]=bisection(f,-(abs(Mk)+1),abs(Mk)+1,1e-18,200);
    senovk=(sqrt(1-ecc^2)*sin(Ek))/(1-ecc*cos(Ek));
    cosenovk=(cos(Ek)-ecc)/(1-ecc*cos(Ek));
    vk=atan2(senovk,cosenovk);
    Ek=acos((ecc+cos(vk))/(1+ecc*cos(vk)));
    phik=vk+eph(indexG(k,2),26);
    phik=rem(phik+2*pi,2*pi);
    Cus=eph(indexG(k,2),18);
    Cuc=eph(indexG(k,2),16);
    duk=Cus*sin(2*phik)+Cuc*cos(2*phik);
    Crs=eph(indexG(k,2),13);
    Crc=eph(indexG(k,2),25);
    drk=Crs*sin(2*phik)+Crc*cos(2*phik);
    Cis=eph(indexG(k,2),23);
    Cic=eph(indexG(k,2),21);
    dik=Cis*sin(2*phik)+Cic*cos(2*phik);
    uk=phik+duk;
    rk=a*(1-ecc*cos(Ek))+drk;
    IDOT=eph(indexG(k,2),28);
    ik=eph(indexG(k,2),24)+dik+(IDOT)*tk;
    xk1=rk*cos(uk);
    yk1=rk*sin(uk);
    OMEGA0=eph(indexG(k,2),22);
    OMEGAp=eph(indexG(k,2),27);
    OMEGApe= 7.2921151467e-5;
    OMEGAk=OMEGA0+(OMEGAp-OMEGApe)*tk-OMEGApe*eph(indexG(k,2),20);
    SatGPS_all(1,k)=xk1*cos(OMEGAk)-yk1*cos(ik)*sin(OMEGAk);%ECEF%[m]
    SatGPS_all(2,k)=xk1*sin(OMEGAk)+yk1*cos(ik)*cos(OMEGAk);%ECEF%[m]
    SatGPS_all(3,k)=yk1*sin(ik);%ECEF%[m]
    end
end
%%
