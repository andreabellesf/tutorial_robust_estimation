function text = formatElapsedTime(seconds)
%FORMATELAPSEDTIME Convert seconds to HH:MM:SS format.

    if ~isfinite(seconds) || seconds < 0
        text = '--:--:--';
        return;
    end

    hours = floor(seconds/3600);
    minutes = floor(mod(seconds,3600)/60);
    secs = mod(seconds,60);

    text = sprintf('%02d:%02d:%05.2f',hours,minutes,secs);
end