function [xPred,PPred] = predict(x, P, F, Q)

xPred = F * x;
PPred = F * P * F' + Q;

end