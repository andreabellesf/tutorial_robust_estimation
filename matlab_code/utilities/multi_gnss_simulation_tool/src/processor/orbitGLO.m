function [SatGLO_all]=orbitGLO(eph,indexR,Time_index,tetaG0)
% orbitGLO Computes the orbits of Glonass satellites.
%% Parameters
pi=3.1415926535898;
omegae=0.7292115e-4;%[rad/s]
%% Computing Position
[n,~]=size(indexR);  
for k=1:n
    
     if indexR(k,2)~=0
         te=((eph(indexR(k,2),6)*3600+eph(indexR(k,2),7)*60+eph(indexR(k,2),8)));
         tetaGe=tetaG0+(omegae)*(te);
         x=eph(indexR(k,2),12);
         vx=eph(indexR(k,2),13);
         ax=eph(indexR(k,2),14);
         yy=eph(indexR(k,2),16);
         vy=eph(indexR(k,2),17);
         ay=eph(indexR(k,2),18);
         z=eph(indexR(k,2),20);
         vz=eph(indexR(k,2),21);
         az=eph(indexR(k,2),22);
         [x1,y1,z1,vx1,vy1,vz1,Axsm,Aysm,Azsm]=Pz2In(tetaGe,x,yy,z,vx,vy,vz,ax,ay,az);
         t=Time_index-te;
         [~,sol]=ode45(@(t,y)odefun(t,y,Axsm,Aysm,Azsm),[0 t],[x1,y1,z1,vx1,vy1,vz1]);
         X1=sol(end,1);
         Y1=sol(end,2);
         Z1=sol(end,3);        
         [XX,YY,ZZ]=In2Pz(tetaG0,X1,Y1,Z1,Time_index);
         SatGLO_all(1,k)=XX*1000;%Pz90  [m]
         SatGLO_all(2,k)=YY*1000;%Pz90  [m]
         SatGLO_all(3,k)=ZZ*1000;%Pz90  [m]
     end
end
