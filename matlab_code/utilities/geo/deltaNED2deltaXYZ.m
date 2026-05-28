function dNED2dXYZ = deltaNED2deltaXYZ(pos)
% SYNTAX:
%   dNED2dXYZ = deltaNED2deltaXYZ(pos);
%
% INPUT:
%   pos: X Y Z of the position
%
% OUTPUT:
%   dNED2dXYZ: the matrix to convert delta NED to delta XYZ
%
% DESCRIPTION:
%   Conversion from delta NED coordinates to delta XYZ coordinates.
%
% Author: Xiangdong An
% Date  : 10.04.2023
%
% Reference:
%    Sanz, J., Juan, J. M., & Hernández-Pajares, M. (2013). GNSS Data Processing, Volume I: Fundamentals and Algorithms.
%    (B.2.1 From ENU to ECEF Coordinates)

[lat, lon, height, ~] = cart2geod(pos(1), pos(2), pos(3));
posBlh = [lat; lon; height];

dNED2dXYZ = zeros(3);
dNED2dXYZ(1, 1) = -cos(posBlh(2)) * sin(posBlh(1));
dNED2dXYZ(2, 1) = -sin(posBlh(2)) * sin(posBlh(1));
dNED2dXYZ(3, 1) =  cos(posBlh(1));
dNED2dXYZ(1, 2) = -sin(posBlh(2));
dNED2dXYZ(2, 2) =  cos(posBlh(2));
dNED2dXYZ(3, 2) =  0.0;
dNED2dXYZ(1, 3) = -cos(posBlh(2)) * cos(posBlh(1));
dNED2dXYZ(2, 3) = -sin(posBlh(2)) * cos(posBlh(1));
dNED2dXYZ(3, 3) = -sin(posBlh(1));
end