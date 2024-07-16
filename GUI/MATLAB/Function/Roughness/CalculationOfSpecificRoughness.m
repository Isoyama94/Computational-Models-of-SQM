function Rpk = CalculationOfSpecificRoughness(QR,dLr,gzi,ik,Setting)
K = length(Setting.ERBNnumber);
[~,n] = size(dLr);

gzi = gzi'*ones(1,n);
ikt = ik*ones(1,n);
Rpk = zeros(K,n);
for k = 1:10
    Rpk(k,:) = QR*(gzi(k,:).^2.*dLr(k,:).^2.*ikt(k,:).^2);
end
for k = 11:K-10
    Rpk(k,:) = QR*(gzi(k,:).^2.*dLr(k,:).^2.*(ikt(k-10,:).*ikt(k,:)).^2);
end
for k = 0:9
    Rpk(K-k,:) = QR*(gzi(K-k,:).^2.*dLr(K-k,:).^2.*ikt(K-k-10,:).^2);
end
if 1 == strcmp(Setting.Figshow,'ON')
    figure('Name','Calculation of specific roughness','NumberTitle','off')
    plot(Setting.ERBNnumber,mean(Rpk,2,'omitnan'),'LineWidth',3)
    ylabel('Specific roughness [aspar/ERB]')
    xlabel('ERB_N-number [Cam]')
    set(gca,'FontSize',20,'FontName','Times')
end
end