function [X,Y,Z,Vx,Vy,Vz,Axsm,Aysm,Azsm]=Pz2In(tetaGe,x,y,z,vx,vy,vz,ax,ay,az)
% PZ2In Transform ECEF(PZ90.02) coordinates to ECI

rot=0.7292115e-4;%totazione terrestre [rad/s]
X=x*cos(tetaGe)-y*sin(tetaGe);%[Km]
Y=x*sin(tetaGe)+y*cos(tetaGe);%[Km]
Z=z;%[Km]
Vx=vx*cos(tetaGe)-vy*sin(tetaGe)-rot*Y;%[Km/s]
Vy=vx*sin(tetaGe)+vy*cos(tetaGe)+rot*X;%Km/s]
Vz=vz;%[Km/s]
Axsm=ax*cos(tetaGe)-ay*sin(tetaGe);% [Km/s^2]
Aysm=ax*sin(tetaGe)+ay*cos(tetaGe);% [Km/s^2]
Azsm=az;% [Km/s^2]