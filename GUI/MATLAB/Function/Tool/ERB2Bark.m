function [Bark] = ERB2Bark(Cam)
    [Frs,~]=ERB2Freq(Cam);
    [Bark, ~] = Freq2CB(Frs);
end