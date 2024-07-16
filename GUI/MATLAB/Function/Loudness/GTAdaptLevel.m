
function [out,factor] = GTAdaptLevel(in, level, Setting)

[~, cols] = size(in);
rmsSig = sqrt(sum(in.^2,2)/cols);

if 1 == strcmp(Setting.SPLmode,'ALLRMS')
    factor = 10.^((level+3)/20 - log10(rmsSig));
elseif 1 == strcmp(Setting.SPLmode,'Signal')
    factor = 10.^((level+3)/20)*sqrt(2);
else
    msg = 'Error: chose Setting.SPLmode "ALLRMS" or "Signal"';
    error(msg)
end

out = factor*in;
end