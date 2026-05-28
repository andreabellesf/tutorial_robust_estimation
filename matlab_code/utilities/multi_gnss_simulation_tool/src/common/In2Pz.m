function [X,Y,Z]=In2Pz(tetaG0,x,y,z,time)
% In2Pz Transform ECI coordinates to ECEF(Pz90.02)
%   trasformale coordinate inerziali in Pz90 attenzione a t che corrisponde la
%   tempo trascorso da mezzanotte Greeenwich a tin cui stiamo calcolando la
%   posizione dei satelliti

rot=0.7292115e-4;
tetaG=tetaG0+rot*(time);
X=x*cos(tetaG)+y*sin(tetaG);
Y=-x*sin(tetaG)+y*cos(tetaG);
Z=z;
end