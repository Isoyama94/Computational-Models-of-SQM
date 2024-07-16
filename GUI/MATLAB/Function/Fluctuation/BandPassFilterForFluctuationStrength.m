function [NBPk]=BandPassFilterForFluctuationStrength(Npk,Fs,H0,Lf,Hf,Setting)
K = length(Setting.ERBNnumber);
[~,n] = size(Npk);

%% Make band-pass filter
[b1,a1] = butter(2,Lf/(Fs/2),'low');
[b2,a2] = butter(2,Hf/(Fs/2),'high');

e0 = Npk-(H0*ones(1,n));

NBPk = zeros(K,n);
switch Setting.Parallel
    case 'ON'
        parfor k = 1:K
            NBPk(k,:) = filter(conv(b1,b2),conv(a1,a2),e0(k,:));
        end
    case 'OFF'
        for k = 1:K
            NBPk(k,:) = filter(conv(b1,b2),conv(a1,a2),e0(k,:));
        end
end
if 1 == strcmp(Setting.Figshow,'ON')
    [h,w]=freqz(conv(b1,b2),conv(a1,a2),Fs);
    f=w*Fs/(2*pi);
    figure('Name','Band-pass filter of fluctuation strength','NumberTitle','off')
    semilogx(f,20*log10(abs(h))-max(20*log10(abs(h))),'Linewidth',3);
    ylim([-10 3])
    ylabel('Filter gain [dB]')
    xlabel('Frequency [Hz]')
    set(gca,'FontSize',20,'FontName','Times');
end
end