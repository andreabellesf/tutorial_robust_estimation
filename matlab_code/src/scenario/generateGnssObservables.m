function gnss = generateGnssObservables(truth, cfg)

nEpochs = cfg.simulation.nEpochs;
nCons = cfg.simulation.nCons;

%% Load GNSS ephemeris 
fileName_satellitePositions = fullfile(cfg.paths.gnssData.synthetic, cfg.filename.gnssData.synthetic.satellitePositions);
load(fileName_satellitePositions);

fileName_satelliteInfo = fullfile(cfg.paths.gnssData.synthetic, cfg.filename.gnssData.synthetic.satelliteInfo);
load(fileName_satelliteInfo);

%% Generate GNSS observations
nSatellites = size( satellite_positions, 2 );
satelliteIds = SatelliteInformation(1).indexes; 
satelliteIdx = [];
if cfg.simulation.enableGPS
    tmp = ismember(satelliteIds, SatelliteInformation(1).GPS.indexes); 
    satelliteIdx = [satelliteIdx tmp];
end
if cfg.simulation.enableGAL
    tmp = ismember(satelliteIds, SatelliteInformation(1).GAL.indexes); 
    satelliteIdx = [satelliteIdx tmp];
end
satelliteIdx = logical(satelliteIdx);

% True distance between receiver and satellites
trueRho = nan(nSatellites, nEpochs);

% True receiver's clock offset(s)
trueClkOffset = nan(nCons, nEpochs);

% True pseudorange (ideal)
truePseudorange = nan(nSatellites, nEpochs);

% For loop for time evolution 
for t=1:cfg.simulation.nEpochs
    trueRho(:, t) = vecnorm( satellite_positions(1:3,:) - repmat( truth.position(1:3,t), 1, nSatellites), 2, 1 ) .';
    
    if t==1
        trueClkOffset(:, t) = cfg.trajectory.initClkSigma * randn(nCons,1);
    else
        trueClkOffset(:, t) = trueClkOffset(:, t-1) + cfg.trajectory.clkSigma * cfg.simulation.dt * randn(nCons,1);
    end

    for iCons = 1:nCons
        idx = satelliteIdx(:, iCons);
        truePseudorange(idx, t) = trueRho(idx, t) + trueClkOffset(iCons, t); 
    end


    
end

%% Store satellite-related info and ideal measurements
gnss.idealPseudorange = trueRho;
gnss.satellitePosition = satellite_positions.';
gnss.nSatellites = nSatellites;
gnss.satelliteIdx = satelliteIdx;

end