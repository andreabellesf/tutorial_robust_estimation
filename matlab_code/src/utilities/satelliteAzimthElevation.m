
function [elevation, azimuth] = satelliteAzimthElevation(svPos, userPos)
% satelliteAzimthElevation -- Computes GNSS satellite azimuth and elevation.
%
% DESCRIPTION:
%   Computes the azimuth and elevation angles of GNSS satellites
%   relative to the receiver using ECEF coordinates (WGS84).
%   Satellite line-of-sight vectors are transformed into the
%   local East-North-Up (ENU) reference frame.
%
% INPUTS:
%   svPos   : Nx3 satellite ECEF positions [m]
%   userPos : 1x3 or 3x1 receiver ECEF position [m]
%
% OUTPUTS:
%   az      : Nx1 satellite azimuth angles [rad], [0,360)
%   el      : Nx1 satellite elevation angles [rad], [-90,90]
%
% NOTES:
%   - Both positions must be expressed in ECEF coordinates.
%   - Azimuth is measured clockwise from geographic north.
%   - Elevation is positive above the local horizon.
%   - No additional toolboxes required.

    %% 1. Input preparation

    userPos = userPos(:)';

    if size(svPos,2) ~= 3 || numel(userPos) ~= 3
        error('Invalid input dimensions.');
    end

    %% 2. Convert receiver ECEF to geodetic coordinates

    a = 6378137.0;                 % WGS84 semi-major axis [m]
    e2 = 6.6943799901413165e-3;   % WGS84 eccentricity squared

    x = userPos(1);
    y = userPos(2);
    z = userPos(3);

    lon = atan2(y,x);
    p = hypot(x,y);

    if p == 0 && z == 0
        error('Receiver position cannot be at the Earth center.');
    end

    % Iterative geodetic latitude estimation
    lat = atan2(z, p*(1-e2));

    for k = 1:10
        N = a / sqrt(1-e2*sin(lat)^2);
        lat = atan2(z+e2*N*sin(lat),p);
    end

    %% 3. ECEF to ENU rotation matrix

    R = [-sin(lon),            cos(lon),           0;
         -sin(lat)*cos(lon),  -sin(lat)*sin(lon), cos(lat);
          cos(lat)*cos(lon),   cos(lat)*sin(lon), sin(lat)];

    %% 4. Satellite line-of-sight vectors

    d = svPos - userPos;

    %% 5. Transform line-of-sight to ENU

    enu = (R*d')';

    E = enu(:,1);
    N = enu(:,2);
    U = enu(:,3);

    %% 6. Calculate azimuth and elevation

    azimuth = mod(atan2(E,N),2*pi);

    elevation = atan2(U,hypot(E,N));

end
