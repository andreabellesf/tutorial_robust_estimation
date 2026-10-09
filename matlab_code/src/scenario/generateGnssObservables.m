function gnss = generateGnssObservables(truth, cfg)

%% Load GNSS ephemeris 
fileName = fullfile(cfg.paths.gnssData, cfg.filename.gnssData.ecef);
data_ecef = load(fileName);

fileName = fullfile(cfg.paths.gnssData, cfg.filename.gnssData.enu);
data_enu = load(fileName);

fileName = fullfile(cfg.paths.gnssData, cfg.filename.gnssData.satelliteInformation);
data = load(fileName);

%% Generate GNSS observations
nSatellites = size( data_enu.satellite_positions, 2 );
trueRho = nan(nSatellites, cfg.simulation.nEpochs);

for t=1:cfg.simulation.nEpochs
    trueRho(:, t) = vecnorm( data_enu.satellite_positions(1:3,:) - repmat( truth.position(1:3,t), 1, nSatellites), 2, 1 ) .';
end

%% Obtain satellite IDs and indexes
satelliteId = [];
satelliteIdGPS = [];
satelliteIdGAL = [];

satelliteIdx = [];
satelliteIdxGPS = [];
satelliteIdxGAL = [];

if cfg.gnss.enabledGPS
    satelliteIdGPS = data.SatelliteInformation(1).GPS.PRN; 
    satelliteId = [satelliteId; satelliteIdGPS];  

    satelliteIdxGPS = 1:numel(satelliteIdGPS);
    satelliteIdx = [satelliteIdx; satelliteIdxGPS(:)];  

end

if cfg.gnss.enabledGAL
    satelliteIdGAL = data.SatelliteInformation(1).GAL.PRN;
    satelliteId = [satelliteId; satelliteIdGAL];

    satelliteIdxGAL = satelliteIdx(end)+1:satelliteIdx(end)+numel(satelliteIdGAL);
    satelliteIdx = [satelliteIdx; satelliteIdxGAL(:)];  
end

%% Store satellite-related info and ideal measurements
gnss.idealPseudorange = trueRho;
gnss.satellitePosition.ENU = data_enu.satellite_positions;
gnss.satellitePosition.ECEF = data_ecef.satellite_positions;
gnss.satelliteId.all = satelliteId;
gnss.satelliteId.GPS = satelliteIdGPS;
gnss.satelliteId.GAL = satelliteIdGAL;
gnss.satelliteIdx.all = satelliteIdx;
gnss.satelliteIdx.GPS = satelliteIdxGPS(:);
gnss.satelliteIdx.GAL = satelliteIdxGAL(:);
gnss.nSatellites = nSatellites;
gnss.satelliteInformation = data.SatelliteInformation; 

end