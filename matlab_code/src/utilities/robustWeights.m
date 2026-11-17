function w = robustWeights(u,method,tuning)
    switch method
        case 'Huber'
            c = tuning.cHuber;
            a = abs(u);
            w = ones(size(u));
            ii = a>c;
            w(ii) = c./a(ii);
        case 'Tukey'
            q = u./tuning.cTukey;
            w = zeros(size(u));
            ii = abs(q)<=1;
            w(ii) = (1-q(ii).^2).^2;
        otherwise
            error('Unknown method: %s',method);
    end
end