function w = robustWeights(u,method,tuning)
    switch method
        case 'Gaussian'
            w = ones(size(u));
        case 'Huber'
            c = tuning.Huber;
            a = abs(u);
            w = ones(size(u));
            ii = a>c;
            w(ii) = c./a(ii);
        case 'Tukey'
            q = u./tuning.Tukey;
            w = zeros(size(u));
            ii = abs(q)<=1;
            w(ii) = (1-q(ii).^2).^2;
        case 'Cauchy'
            q = u./tuning.Cauchy;
            w = 1./(1+q.^2);
        case 'Welsch'
            q = u./tuning.Welsch;
            w = exp(-q.^2);
        case 'GemanMcClure'
            q = u./tuning.GemanMcClure;
            w = 1./(1+q.^2).^2;
        otherwise
            error('Unknown method: %s',method);
    end
end