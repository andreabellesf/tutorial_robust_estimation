function [Az, El, D] = topocent_custom(Xr, Xs)

% SYNTAX:
%   [Az, El, D] = topocent_custom(Xr, Xs);
%
% INPUT:
%   Xr = receiver coordinates (X,Y,Z)
%   Xs = satellite coordinates (X,Y,Z)
%
% OUTPUT:
%   D = rover-satellite distance
%   Az = satellite azimuth
%   El = satellite elevation
%
% DESCRIPTION:
%   Computation of satellite distance, azimuth and elevation with respect to
%   the receiver.

%----------------------------------------------------------------------------------------------
%                           goGPS v0.4.3
%
% Copyright (C) Kai Borre
% Kai Borre 09-26-97
%
% Adapted by Mirko Reguzzoni, Eugenio Realini, 2009
%----------------------------------------------------------------------------------------------
%
% Further adapted (2023) to allow multi-epoch references


%conversion from geocentric cartesian to geodetic coordinates
[phi, lam] = cart2geod(Xr(:,1), Xr(:,2), Xr(:,3));

%computation of topocentric coordinates
cl = cos(lam); sl = sin(lam);
cb = cos(phi); sb = sin(phi);

num_ep = size(cl,1);
local_vector = zeros( 3, num_ep );
for j = 1:num_ep
F = [-sl(j) -sb(j)*cl(j) cb(j)*cl(j);
      cl(j) -sb(j)*sl(j) cb(j)*sl(j);
         0         cb(j)       sb(j)];
local_vector(:,j) = F' * ( Xs(j,:) - Xr(j,:) )';
end
E = local_vector(1,:)';
N = local_vector(2,:)';
U = local_vector(3,:)';
hor_dis = sqrt(E.^2 + N.^2);

if hor_dis < 1.e-20
   %azimuth computation
   Az = 0;
   %elevation computation
   El = 90;
else
   %azimuth computation
   Az = atan2(E,N)/pi*180;
   %elevation computation
   El = atan2(U,hor_dis)/pi*180;
end

tmp = Az;
idx = (tmp < 0);
tmp(idx) = tmp(idx) + 360;

i = find(Az < 0);
Az(i) = Az(i)+360;

%receiver-satellite distance
D = sqrt(sum((Xs-Xr).^2 ,2));
