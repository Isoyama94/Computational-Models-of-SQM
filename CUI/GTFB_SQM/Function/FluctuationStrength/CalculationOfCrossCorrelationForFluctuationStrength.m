function [ik] = CalculationOfCrossCorrelationForFluctuationStrength(NBPk,Fs,Setting)
K = length(Setting.ERBNnumber);

amount=0.02*Fs;
AA = NBPk./max(abs(NBPk'))';
ik = zeros(K,1);
for k = 1:K-10
    ik(k) = max(xcorr(AA(k,:), AA(k+10,:), amount, 'normalized'));
end
if 1 == strcmp(Setting.Figshow,'ON')
    figure('Name','Cross-correlation of fluctuation strength','NumberTitle','off')
    plot(Setting.ERBNnumber,ik,'LineWidth',3)
    ylabel('Cross correlation')
    xlabel('ERB_N-number [Cam]')
    set(gca,'FontSize',20,'FontName','Times')
end
end