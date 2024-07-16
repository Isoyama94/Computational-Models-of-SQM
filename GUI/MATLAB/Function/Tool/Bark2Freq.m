% This function is Bark to Frequency
% [hz] = Bark2Freq(bark)
% 
% Input:    bark            : bark scale (Default: 1)
% Output    hz              : Frequency [Hz]
% 
% Author:  Takuto ISOYAMA
% Created: 9 Apr. 2024 
% Copyright: (c) 20024 unoki-Lab. JAIST
%
function [hz] = Bark2Freq(bark)
hz = zeros(length(bark),1);
for count = 1:length(bark)
    if bark(count) <2
        new_bark = (bark(count)-0.3)/0.85;
        hz(count,1) = 1960.*((new_bark+0.53)./(26.27-new_bark));
    elseif bark(count)>=2 && 20.1>=bark(count)
        new_bark = bark(count);
        hz(count,1) = 1960.*((new_bark+0.53)./(26.27-new_bark));
    else
        new_bark = (bark(count)+4.422)/1.22;
        hz(count,1) = 1960.*((new_bark+0.53)./(26.27-new_bark));
    end
end
end