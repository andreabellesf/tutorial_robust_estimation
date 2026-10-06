function [error, errorPos, errorVel] = computeEstimationErrors(xEst, xTrue, idx)

error = xEst - xTrue;
errorPos = error(idx.pos, :);
errorVel = error(idx.vel, :);

end