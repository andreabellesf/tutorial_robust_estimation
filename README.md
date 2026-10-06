tutorial_robust_estimation/
│
├── main.m                      % Main script
│
├── config/
│   └── config.m                % All user-configurable parameters
│
├── data/
│   └── opensky_2022_neustrelitz_satellite_positions_enu.mat
│
├── src/
│   ├── filters/
│   │   ├── runEKF.m
│   │   ├── runEKF.m
│   │   └── ...
│   │
│   ├── montecarlo/
│   │   ├── generateMonteCarloRealization.m
│   │   ├── runMonteCarlo.m
│   │   └── runMonteCarloRealization.m
│   ├── metrics/
│   │
│   │   ├── computeMetrics.m
│   │   ├── computeErrors.m
│   │   ├── computeConsistency.m
│   │   └── ...
│   ├── scenario/
│   │
│   │   ├── generateScenario.m
│   │   ├── generateTrajectory.m
│   │   └── generateGnssObservables.m
│   ├── plotting/
│   │
│   │   ├── plotScenario.m
│   │   ├── plotMonteCarlo.m
│   │   ├── plotMetrics.m
│   │   └── ...
│   │
│   └── utilities/
│       └── ...
│   
└── results/
    ├── figures/
    └── ...
