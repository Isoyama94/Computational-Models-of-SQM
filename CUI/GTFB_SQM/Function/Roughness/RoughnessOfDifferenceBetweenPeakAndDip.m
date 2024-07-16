function dLr = RoughnessOfDifferenceBetweenPeakAndDip(Npk,NBPk,Fs,H0,Setting)
K = length(Setting.ERBNnumber);
[~,n] = size(Npk);

%% Calculation of Caliblation
maxi = max(LT(Npk));
calib = LT(Npk)./maxi;
calib(isnan(calib)) = 0;

dLr = zeros(K,n);
for k = 1:K
    Env = LPFilter(abs(hilbert(NBPk(k,:)-mean(NBPk(k,:)))),7,Fs);

    UpperEnv = Env+H0(k);
    UpperEnv(UpperEnv<0)=0.0;
    LrUpper = LT(UpperEnv);

    LowerEnv = -1*Env+H0(k);
    LowerEnv(LowerEnv<0)=0.0;
    LrLower = LT(LowerEnv);

    dLr(k,:) = (LrUpper-LrLower).*calib(k,:);
end
dLr(dLr<0) = 0.0;
if 1 == strcmp(Setting.Figshow,'ON')
    figure('Name','dL of roughness','NumberTitle','off')
    plot(Setting.ERBNnumber,mean(dLr,2,'omitnan'),'LineWidth',3)
    ylabel("dL_R")
    xlabel('ERB_N-number [Cam]')
    set(gca,'FontSize',20,'FontName','Times')
end
end