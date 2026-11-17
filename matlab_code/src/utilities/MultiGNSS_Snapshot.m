function varargout = MultiGNSS_Snapshot( varargin )
%**************************************************************************
%function varargout = MultiGNSS_Snapshot( varargin )
%
% Date: 06.08.2018
% DLR - Institute of Communications and Navigation
% Daniel Arias Medina
%
% Calculate the position using GNSS observations in a single point
% positioning manner.
% Minimal inputs:
%  - pseudorange
%  - SV_position
%
%  Properties:
%    R_matrix
%    GNSS_type
%    subset
%    initial_position
%    max_iterations
%    error_tolerance
%    condition_check
%
% Output Parameters:
%   Position
%   Clockoffset
%   Residuals
%   P
%   G
%
% Reference:
%       - GNSS Data processing: Volume I: Fundamentals and Algorithms, from
%       Jaume Sant Subirana, edited by ESA.
%
%**************************************************************************

% Default parameters
pseudorange = varargin{1};
SV_position = varargin{2};

nSatellites = length(pseudorange);
R_matrix = eye( nSatellites );
GNSS_type = nSatellites;
subset = [1:1:nSatellites];
initial_position = [0;0;0];
max_iterations = 100;
error_tolerance = 10^-6;
condition_check = 1000;
% Handle input arguments
if nargin > 2
    pseudorange = varargin{1};
    SV_position = varargin{2};
    for idx = 1:length(varargin)
        if ischar( varargin{idx} )
            switch lower(varargin{idx})
                case 'r_matrix'
                    R_matrix = varargin{idx+1};
                case 'gnss_type'
                    GNSS_type = varargin{idx+1};
                case 'subset'
                    subset = varargin{idx+1};
                case 'initial_position'
                    initial_position = varargin{idx+1};
                case 'max_iterations'
                    max_iterations = varargin{idx+1};
                case 'error_tolerance'
                    error_tolerance = varargin{idx+1};
                case 'condition_check'
                    condition_check = varargin{idx+1};
                otherwise
                    error(['Unrecognized variable: ' varargin{idx}])
            end
        end
    end
elseif nargin<2
    error('Wrong number of inputss')
end
              




% Initialization of the variables
GNSS_type(GNSS_type==0) = [];
Number_of_constellation = length(GNSS_type);
G          = zeros(nSatellites,3+Number_of_constellation);
for i = 1:Number_of_constellation
    if i==1
        G(1:GNSS_type(i),3+i)         = 1;
    else
        G( sum(GNSS_type(1:i-1))+1 : sum(GNSS_type(1:i)), 3+i)         = 1;
    end
end
y              = zeros(nSatellites,1);
d = zeros(nSatellites,1);
iteration        = 0;
position_change = error_tolerance + 1;
Position = initial_position;
CLKoffset = zeros(Number_of_constellation,1);
P = zeros( 3 + Number_of_constellation );
residuals = zeros(nSatellites);
reliable = 1;
% Iterative LS method to estimate position
is_not_nan_condition = ~any(isnan(Position)) && ~any(isnan(pseudorange)) && ~any(isnan(SV_position(:))) && ~any(isnan(R_matrix(:))) ;
if nSatellites >= 3+Number_of_constellation && is_not_nan_condition
    while iteration < max_iterations && position_change > error_tolerance
        iteration = iteration + 1;
        for iSV = 1:nSatellites
            d(iSV) = sqrt( (Position(1)-SV_position(iSV,1))^2 + (Position(2)-SV_position(iSV,2))^2 + (Position(3)-SV_position(iSV,3))^2 ); % Distance from the satellites to the iteratively-changing target position
            y(iSV) = pseudorange(iSV) - d(iSV) - CLKoffset'*G(iSV,4:end)'; % Difference between the pseudorange (including corrections) and the previous distance
            G(iSV,1:3) = [ (Position(1)-SV_position(iSV,1))/d(iSV), (Position(2)-SV_position(iSV,2))/d(iSV), (Position(3)-SV_position(iSV,3))/d(iSV)]; % Construction of the G measurement matrix
        end
        % G_used = G(subset,:);
        G_used = G;
        if cond(G_used) < condition_check
            %Least square method
            estimatedState = (G_used' * inv(R_matrix) * G_used) \ G_used' * inv(R_matrix) * y;
            oldPosition = Position;
            Position   = Position + estimatedState(1:3);
            CLKoffset  = CLKoffset + estimatedState(4:end);
            P   = inv(G_used' * inv(R_matrix) * G_used);
            position_change = norm(oldPosition - Position);
            residuals = pseudorange - d - [CLKoffset'*G_used(:,4:end)']';
        else
            warning('Condition check failed')
            Position = NaN(3,1);
            CLKoffset = NaN;
            P = NaN(Number_of_constellation+1);
            residuals = NaN(nSatellites,1);
            reliable = 0;
            break;
        end  
    end
    
else
    warning('Not enough satellites!')
    Position = NaN(3,1);
    CLKoffset = NaN(Number_of_constellation,1);
    P = NaN(Number_of_constellation+1);
    residuals = NaN(nSatellites,1);
    reliable = 0;
end


if nargout == 1
    varargout{1} = Position;
elseif nargout == 2
    varargout{1} = Position;
    varargout{2} = CLKoffset;
elseif nargout == 3
    varargout{1} = Position;
    varargout{2} = CLKoffset;
    varargout{3} = residuals;
elseif nargout == 4
    varargout{1} = Position;
    varargout{2} = CLKoffset;
    varargout{3} = residuals;
    varargout{4} = P;
elseif nargout == 5
    varargout{1} = Position;
    varargout{2} = CLKoffset;
    varargout{3} = residuals;
    varargout{4} = P;
    varargout{5} = G;
elseif nargout == 6
    varargout{1} = Position;
    varargout{2} = CLKoffset;
    varargout{3} = residuals;
    varargout{4} = P;
    varargout{5} = G;
    varargout{6} = reliable;
else
    varargout = [];
end

end