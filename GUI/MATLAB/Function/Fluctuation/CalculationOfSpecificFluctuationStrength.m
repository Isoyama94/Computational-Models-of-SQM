function Fpk = CalculationOfSpecificFluctuationStrength(QF,dLf,ik,pm,pk,Setting)
K = length(Setting.ERBNnumber);
[~,n] = size(dLf);

ikt = ik*ones(1,n);
Fpk = zeros(K,n);
for k = 1:10
    Fpk(k,:) = QF*dLf(k,:).^pm.*ikt(k,:).^pk;
end
for k = 11:K-10
    Fpk(k,:) = QF*dLf(k,:).^pm.*abs(ikt(k-10,:).*ikt(k,:)).^pk;
end
for k = 0:9
    Fpk(K-k,:) = QF*dLf(K-k,:).^pm.*ikt(K-k-10,:).^pk;
end
if 1 == strcmp(Setting.Figshow,'ON')
    figure('Name','Calculation of specific fluctuation strength','NumberTitle','off')
    plot(Setting.ERBNnumber,mean(Fpk,2,'omitnan'),'LineWidth',3)
    ylabel('Cross correlation')
    xlabel('ERB_N-number [Cam]')
    set(gca,'FontSize',20,'FontName','Times')
end
end