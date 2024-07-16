function [new_bark] = Freq2Bark(Freq)
bark = ((26.81.*Freq)./(1960+Freq))-0.53;
new_bark = zeros(length(bark),1);
for count = 1:length(bark)
    if bark(count) <2
        new_bark(count) = bark(count)+0.15*(2-bark(count));
    elseif bark(count)>=2 && 20.1>=bark(count)
        new_bark(count) = bark(count);
    else
        new_bark(count) = bark(count)+0.22*(bark(count)-20.1);
    end
end
end