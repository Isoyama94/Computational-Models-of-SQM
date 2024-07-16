function [yt] = BandPassFilterForRoughness(xt,Fs,H0,Setting)
if nargin<1, help BandPassFilterForRoughness, return; end 
if nargin<2, Fs=1000; end
if nargin<5, Setting.Figshow='OFF'; Setting.OpData='Ap'; end
%%
K = length(Setting.ERBNnumber);
t = ((0:length(xt)-1)/Fs)';
T = length(xt)/Fs*1000; % ms
xt = xt-H0;

[~,Order,Alpha,Beta,PeakFreq,Width,~]=GCRoughnessParameters(Setting);
Fc = PeakFreq./(1+exp(-((Setting.ERBNnumber-Alpha)./Beta)));

BandWidth = Fc*Width;
filt_len = length(xt);

%% Make fir gammatone filterbank
gt = (t*ones(1,K)).^(Order-1).*exp(-2.*pi.*(t*BandWidth)).*cos(2*pi.*t*Fc);
GT_amp = 1./max(abs(fft(gt)),[],1);
gtfb = ones(filt_len,1)*GT_amp.*gt;

%% Filtering
[yt] = fft_filter(xt,gtfb,filt_len,K);

%%
switch Setting.Figshow
    case 'ON'
        figure('Name','Cross-correlation of fluctuation strength','NumberTitle','off')
        plot(0:1/(T/1000):Fs-1/(T/1000),10*log10(abs(fft(gtfb).^2)),'LineWidth',3)
        ylabel('Filter gain [dB]')
        xlabel('Frequency [Hz]')
        set(gca,'FontSize',20,'FontName','Times')
        xlim([0 Fs/2])
    case 'OFF'
        return
end
end

function [yt] = fft_filter(xt,gtfb,filt_len,K)
for k = 1:K
    rext = cat(1,zeros(filt_len,1),xt(k,:)');
    regt = cat(1,zeros(filt_len,1),gtfb(:,k));
    Xf = fft(rext);
    GTf = fft(regt);
    yt_ori = ifft(Xf.*GTf);
    yt(k,:) = yt_ori(1:filt_len,:);
end
end