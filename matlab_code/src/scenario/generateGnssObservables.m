function gnss = generateGnssObservables(truth, cfg)

%% Load GNSS ephemeris 
fileName = fullfile(cfg.paths.gnssData, cfg.filename.gnssData);
data = load(fileName);

%% Generate GNSS observations
nSatellites = size( data.satellite_positions, 2 );
trueRho = nan(nSatellites, cfg.simulation.nEpochs);

for t=1:cfg.simulation.nEpochs
    trueRho(:, t) = vecnorm( data.satellite_positions(1:3,:) - repmat( truth.position(1:3,t), 1, nSatellites), 2, 1 ) .';
end

%% Store satellite-related info and ideal measurements
gnss.idealPseudorange = trueRho;
gnss.satellitePosition = data.satellite_positions;
gnss.nSatellites = nSatellites;

end