
function [out,Amp] = GCAdaptLevel(in, level, Setting)
if 1 == strcmp(Setting.SPLmode,'ALLRMS')
    Amp60dBSPL = 200*1/rms(in);
    Amp = Amp60dBSPL*10^((level-60)/20);
elseif 1 == strcmp(Setting.SPLmode,'Signal')
    Amp = 200*10^((level-60)/20)*sqrt(2);
else
    msg = 'Error: chose Setting.SPLmode "ALLRMS" or "Signal"';
    error(msg)
end

out = in*Amp;
end