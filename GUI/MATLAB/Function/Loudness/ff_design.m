function fir_eq=ff_design(fs,Setting)

Hz = [ 0.,...
      20.,    25.,   31.5,   40.,    50.,    63.,   80.,  100.,  125.,   160.,  200.,   250.,   315.,   400.,  500.,  630.,...
     750.,   800., 1000.,  1250.,  1500.,  1600., 2000., 2500., 3000.,  3150., 4000.,  5000.,  6000.,  6300., 8000., 9000.,...
     10000., 11200.,12500., 14000., 15000., 16000.,20000.];

Midear=[ 55.0,...
      43.6,   34.9,  27.9,   22.4,   19.0,  16.6,  14.5,  12.5,  11.13,   9.71,  8.42,   7.2,    6.1,   4.7,   3.7,   3.0,...
       2.7,    2.6,   2.6,    2.7,    3.7,   4.6,   8.5,  10.8,   7.3,    6.7,   5.7,    5.7,    7.6,   8.4,  11.3,  10.6,...
       9.9,   11.9,  13.9,   16.0,   17.3,  17.8,  20.0];

Ff_ed= [0.0,...
        0.0,    0.0,   0.0,    0.0,    0.0,    0.0,   0.0,   0.0,   0.1,    0.3,   0.5,    0.9,    1.4,    1.6,   1.7,   2.5,...
        2.7,    2.6,   2.6,    3.2,    5.2,    6.6,  12.0,  16.8,  15.3,   15.2,  14.2,   10.7,    7.1,    6.4,   1.8,  -0.9,...
       -1.6,    1.9,   4.9,    2.0,   -2.0,    2.5,   2.5];

Diffuse= [0.0,...
        0.0,    0.0,   0.0,    0.0,    0.0,    0.0,   0.0,   0.0,   0.1,    0.3,   0.4,    0.5,    1.0,    1.6,   1.7,   2.2,...
        2.7,    2.9,   3.8,    5.3,    6.8,    7.2,  10.2,  14.9,  14.5,   14.4,  12.7,   10.8,    8.9,    8.7,   8.5,   6.2,...
        5.0,    4.5,   4.0,    3.3,    2.6,    2.0,   2.0];

ntaps = 1+2*(round(fs/24));
nFFT = 2.^(nextpow2(ntaps) + 1);

switch Setting.Field
    case 'Free'
        dBcorrn = Ff_ed - Midear;
    case 'Diffuse'
        dBcorrn = Diffuse - Midear;
end

deltaf  = (fs)/nFFT;
linf = 0:deltaf:fs/2;

if Hz(end) < fs/2  %% handle interpolation of high fs data
    dBcorrn_linf = interp1([Hz fs/2],[dBcorrn dBcorrn(end)],linf,'linear');  %%%% corrn on linear frequency spacing
else
    dBcorrn_linf = interp1(Hz,dBcorrn,linf,'linear');  %%%% corrn on linear frequency spacing
end
dBcorrn_linf = fillmissing(dBcorrn_linf,'constant',-39.6);
[smth_b,smth_a] = butter(4,.5); %% smooth to control roughness
eq_linf = filtfilt(smth_b,smth_a,dBcorrn_linf);
fir_eq = fir2(ntaps+1,linf./(fs/2),10.^(eq_linf/20.)); 
end