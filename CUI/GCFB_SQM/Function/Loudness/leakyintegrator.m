function nvals=leakyintegrator(Sig,Fs)

lowpass_cutoff_frequency = 1200;
order = 2;

time_constant=1/(2.*pi.*lowpass_cutoff_frequency);
sr=Fs;
vals=Sig;
b=exp(-1/(sr.*time_constant));
aLPF=1./(1-b);

nvals=zeros(size(vals));
for dothis=1:order
    yn_1=0;
    for i=1:length(vals)
        xn=vals(i);
        yn= xn + b*yn_1;
        yn_1=yn;
        nvals(i)=yn;
    end
    vals=nvals./aLPF;
end

nvals=vals;