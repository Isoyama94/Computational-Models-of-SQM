%
%   GTRoughnessModel: Calculation of roughness from specific loudness
%   Function [Rt,R,Rpk,dLr,ik] = GTRoughnessModel(Nd,Fs0,Setting)
%   Input:   Npk0:         Specific loudness [sone/ERB]
%            Fs0:          Sampling frequency [Hz]
%            Setting:      Setting.Figshow = 'ON' or 'OFF'
%                          Setting.Op = 'Ap'
%
%   Output:  Rt:           Time [sec]
%            R:            Roughness [vacil]
%            Rpk:          Specific roughness [asper/ERB]
%            dLr:          Instant loudness [dB]
%            ik:           Corralation
%
%   Author:  Takuto ISOYAMA
%   Created: 10 Oct. 2022
%   Modified: 10 Apr. 2024
%
%   Reference [1] T. Isoyama, and S. Kidani, M. Unoki, ``Computational models 
%                 of auditory sensation important for sound quality on basis of 
%                 either gammatone or gammachirp auditory filterbank,''
%                 Applied Acoustics, Vol. 218, 2024. 
%                 DOI: https://doi.org/10.1016/j.apacoust.2024.109914
%   Copyright (c) 2022-2024, Unoki-Lab. JAIST
%
function [Rt,R,Rpk,dLr,ik] = GTRoughnessModel(Npk0,Fs0,Setting)
%% Initial Setup
Fs = 1000;

%% Down sampling 44100 -> 1000
Npk = resample(Npk0,Fs,Fs0,'Dimension',2);
Npk(0>Npk) = 0.0;
Rt = (0:length(Npk)-1)/Fs;

%% Band pass filtering
H0 = mean(Npk,2);
NBPk = BandPassFilterForRoughness(Npk,Fs,H0,Setting);

%%  Calculated instant loudness
dLr = RoughnessOfDifferenceBetweenPeakAndDip(Npk,NBPk,Fs,H0,Setting);

%% Cross-correlation
[ik] = CalculationOfCrossCorrelationForRougness(NBPk,Fs,Setting);

%% Waighting function
[QR,~,~,~,~,~,gr]=GTRoughnessParameters(Setting);
gzi = sqrt(csaps(gr(1,:)', gr(2,:)', 1,Setting.ERBNnumber));

%% Calculated specific roughness Rpk
Rpk = CalculationOfSpecificRoughness(QR,dLr,gzi,ik,Setting);

%% Calculated roughness R
Rpk(Rpk<=0) = 0;
R = abs(sum(Rpk,'omitnan')*0.1);
end