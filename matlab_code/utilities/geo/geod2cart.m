function [X,Y,Z] = geod2cart (phi, lam, h, a, f)

% SYNTAX:
%   [X,Y,Z] = geod2cart (phi, lam, h, a, f);
%
% INPUT:
%   phi     = geodetic latitude                  [rad]
%   lam     = geodetic longitude                 [rad]
%   h       = ellipsoid height                   [m]

%
% OUTPUT:
%   X       = X cartesian coordinate
%   Y       = Y cartesian coordinate
%   Z       = Z cartesian coordinate
%
% DESCRIPTION:
%   Conversion from geodetic to geocentric cartesian coordinates.

%----------------------------------------------------------------------------------------------
%                           goGPS v0.4.3
%
% Copyright (C) 2009-2014 Mirko Reguzzoni, Eugenio Realini
%----------------------------------------------------------------------------------------------
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%----------------------------------------------------------------------------------------------
%global a_GPS e_GPS
if nargin == 3
    a = goGNSS.ELL_A_GPS;
    f = goGNSS.ELL_F_GPS;
end

e = sqrt(1-(1-f)^2);
N = a ./ sqrt(1 - e^2 * sin(phi).^2);
e2 = 1 - (1 - f)^2;

X = (N + h) .* cos(lam) .* cos(phi);
Y = (N + h) .* sin(lam) .* cos(phi);
Z = (N * (1 - e2) + h) .* sin(phi);