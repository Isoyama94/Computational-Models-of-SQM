function [QR,Order,Alpha,Beta,PeakFreq,Width,gr]=GCRoughnessParameters(Setting)
switch Setting.Op
    case 'Ap'
        QR = 1/323.125261595004;
        Order = 3;
        Alpha = 4.58;
        Beta = 1.47983;
        PeakFreq = 69.25;
        Width = 1.5767;
        gr = [0 4.05 6.9 10.8 15.6 21.2 27.1 33.3;...
            [0 1.4053 2.1017 1.5755 0.90258 0.38433 0.19828 0.15188]];
    case 'INTERNOISE'
        QR = 0.00281207730962940;
        Order = 3;
        Alpha = 4.58;
        Beta = 1.47983;
        PeakFreq = 69.25;
        Width = 1.5767;
        gr = [0 4.05 6.9 10.8 15.6 21.2 27.1 33.3;...
            [0 1.4053 2.1017 1.5755 0.90258 0.38433 0.19828 0.15188]];
end
end