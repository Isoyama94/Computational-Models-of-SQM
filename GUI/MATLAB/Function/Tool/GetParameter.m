function [Para] = GetParameter(ParaData,ParameterName,Default)
N = length(ParaData);
if mod(N,2) == 1
    msg = 'Set the parameters correctly.';
    error(msg)
end

Flag = 0;
for i = 1:2:N
    if strcmp(ParameterName,char(ParaData(i))) == 1
        if ischar(ParaData(i+1)) == 1
            Para = char(ParaData(i+1));
            Flag = 1;
        else
            Para = cell2mat(ParaData(i+1));
            Flag = 1;
        end
    end
end
if Flag ~= 1
    Para = Default;
end
end