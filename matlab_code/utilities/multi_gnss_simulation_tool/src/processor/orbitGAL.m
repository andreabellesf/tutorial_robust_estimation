function [SatGAL_all]=orbitGAL(eph,indexE,Time_index)
% orbitGAL Computes the orbits of Galileo satellites.

%% Parameters
pi=3.1415926535898;
mu=3.986004418e14;%[m^3/s^2]
omegae=7.2921151467e-5;%v[rad/s]
[n,~]=size(indexE); 
%% Computing Position
for k=1:n
    if indexE(k,2)~=0
    t0e=eph(indexE(k,2),20); %Time in the week GAL [s] 
    A=eph(indexE(k,2),19)^2;
    n0=sqrt(mu/A^3);
    tk=Time_index-((eph(indexE(k,2),6)*3600+eph(indexE(k,2),7)*60+eph(indexE(k,2),8)));
    deltan=eph(indexE(k,2),14);
    mean_motion=n0+deltan;
    M0=eph(indexE(k,2),15);
    M=M0+mean_motion*tk;%Mean anomaly
    ecc=eph(indexE(k,2),17);
    f=@(x)x-ecc.*sin(x)-M;
    [E,~,~]=bisection(f,-(abs(M)+1),abs(M)+1,1e-18,200);%Eccentric anomaly
    senov=sqrt(1-ecc^2)*sin(E)/(1-ecc*cos(E));
    cosenov=(cos(E)-ecc)/(1-ecc*cos(E));
    v=atan2(senov,cosenov);%true anomaly
    omega=eph(indexE(k,2),26);
    PHI=v+omega ;%argument of latitude
    Cus=eph(indexE(k,2),18);
    Cuc=eph(indexE(k,2),16);
    Crs=eph(indexE(k,2),13);
    Crc=eph(indexE(k,2),25);
    Cis=eph(indexE(k,2),23);
    Cic=eph(indexE(k,2),21);
    du=Cus*sin(2*PHI)+Cuc*cos(2*PHI);
    dr=Crs*sin(2*PHI)+Crc*cos(2*PHI);
    di=Cis*sin(2*PHI)+Cic*cos(2*PHI);
    u=PHI+du; %corrected argument of latitude  
    r=A*(1-ecc*cos(E))+dr;
    i0=eph(indexE(k,2),24);
    idot=eph(indexE(k,2),28);
    i=i0+di+idot*tk ;%corrected inclination
    x1=r*cos(u) ;%position in orbital plane
    y1=r*sin(u); %positin in orbital plane
    OMEGA0=eph(indexE(k,2),22);
    OMEGADOT=eph(indexE(k,2),27);
    OMEGA=OMEGA0+(OMEGADOT-omegae)*tk-omegae*t0e; 
    SatGAL_all(1,k)=x1*cos(OMEGA)-y1*cos(i)*sin(OMEGA);%[m]
    SatGAL_all(2,k)=x1*sin(OMEGA)+y1*cos(i)*cos(OMEGA);%[m]
    SatGAL_all(3,k)=y1*sin(i);%[m]
    end
end
