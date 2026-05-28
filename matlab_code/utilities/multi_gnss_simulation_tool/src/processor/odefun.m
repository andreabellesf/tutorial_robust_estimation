function dydt = odefun(t,y,Axsm,Aysm,Azsm)
% odefun Implements integration of Ordinary differential equation (ODE)
% needed to comupute Glonass satellites orbits.
%% Parameters
ae=6738.136;%[Km]
mu=398600.44;%[Km^3/s^2]
C20=-1082.63e-6;%
%% Functions
dydt=zeros(6,1);
dydt(1)=y(4);
dydt(2)=y(5);
dydt(3)=y(6);
dydt(4)= -(mu/(y(1)^2+y(2)^2+y(3)^2))*(y(1)/(sqrt(y(1)^2+y(2)^2+y(3)^2)))+3/2*C20*(mu/(y(1)^2+y(2)^2+y(3)^2))*(y(1)/(sqrt(y(1)^2+y(2)^2+y(3)^2)))*(ae/sqrt(y(1)^2+y(2)^2+y(3)^2))^2*(1-5*(y(3)/sqrt(y(1)^2+y(2)^2+y(3)^2))^2)+Axsm;
dydt(5)= -(mu/(y(1)^2+y(2)^2+y(3)^2))*(y(2)/(sqrt(y(1)^2+y(2)^2+y(3)^2)))+3/2*C20*(mu/(y(1)^2+y(2)^2+y(3)^2))*(y(2)/(sqrt(y(1)^2+y(2)^2+y(3)^2)))*(ae/sqrt(y(1)^2+y(2)^2+y(3)^2))^2*(1-5*(y(3)/sqrt(y(1)^2+y(2)^2+y(3)^2))^2)+Aysm;
dydt(6)= -(mu/(y(1)^2+y(2)^2+y(3)^2))*(y(3)/(sqrt(y(1)^2+y(2)^2+y(3)^2)))+3/2*C20*(mu/(y(1)^2+y(2)^2+y(3)^2))*(y(3)/(sqrt(y(1)^2+y(2)^2+y(3)^2)))*(ae/sqrt(y(1)^2+y(2)^2+y(3)^2))^2*(3-5*(y(3)/sqrt(y(1)^2+y(2)^2+y(3)^2))^2)+Azsm;