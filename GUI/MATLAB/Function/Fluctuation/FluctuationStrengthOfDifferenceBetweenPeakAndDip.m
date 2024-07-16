function dLf = FluctuationStrengthOfDifferenceBetweenPeakAndDip(Npk,NBPk,Fs,H0,Setting)
[K,n] = size(Npk);

%% Calculation of Caliblation
maxi = max(LT(Npk));
calib = LT(Npk)./maxi;
calib(isnan(calib)) = 0;

dLf = zeros(K,n);
for k = 1:K
    Env = LPFilter(abs(hilbert(NBPk(k,:)-mean(NBPk(k,:)))),0.4,Fs);

    UpperEnv = Env+H0(k);
    UpperEnv(UpperEnv<0)=0.0;
    LfUpper = LT(UpperEnv);

    LowerEnv = -1*Env+H0(k);
    LowerEnv(LowerEnv<0)=0.0;
    LfLower = LT(LowerEnv);

    dLf(k,:) = (LfUpper-LfLower).*calib(k,:);
end
dLf(dLf<0) = 0.0;
if 1 == strcmp(Setting.Figshow,'ON')
    figure('Name','dL of fluctuation strength','NumberTitle','off')
    plot(Setting.ERBNnumber,mean(dLf,2,'omitnan'),'LineWidth',3)
    ylabel("dL_F")
    xlabel('ERB_N-number [Cam]')
    set(gca,'FontSize',20,'FontName','Times')
end
end