function [xPred,PPred] = predict(x, P, dt, cfg)

[F,Q] = dynamicModelFilter(dt, cfg);

xPred = F * x;
PPred = F * P * F' + Q;

end