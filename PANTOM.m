

clear all
fnam = input('Enter the ECG file name :','s');
fid = fopen(fnam);
ecg = fscanf(fid,'%f ');
sze = size(ecg,1);
necg = ecg/max(ecg);
p0 = necg;
fs = 200;
t= [1:length(p0)]/fs;

%%%%%%%%%%%%%NOTCH%%%%%%%%%%%%%
% define notch filter coefficient arrays a and b
OmegaZero = 2 * pi * (60 / 200);
z1 = cos(OmegaZero) + 1i * sin(OmegaZero);
z2 = cos(-OmegaZero) + 1i * sin(-OmegaZero);
b_notch = [1 -z1+-z2 z1*z2]/(1-z1+-z2+z1*z2);%normalized by dividing
% H(z) = Gain * (b(1) + b(2)z^-1 + b(3)z^-2)
% H(z=1) = Gain * (b(1) + b(2)1 + b(3)1) = 1
a_notch = [1 0 0];
%p0 = filter(b_notch,a_notch,p0);

%bp = filter(band_pass,p0)
b_low = zeros(1,13);
b_low(1) = (1/32); b_low(7) = -(2/32); b_low(13) = (1/32);
a_low  = [1 -2 1];
b_high = zeros(1,33); 
b_high(1) = -(1/32); b_high(17) = 1; b_high(18) = -1; b_high(33) = (1/32);
a_high = [1 -1];

b = conv(b_low,b_high);
a = conv(a_low,a_high);
bp = filter(b,a,p0);


b_der = [2 1 0 -1 -2]/8;
a_der = [1];
der = filter(b_der,a_der,bp);
%%% Squaring %%%
square = der.^2;


%%% Moving window integral %%% 滑动
a_int = 1;
b_int= ones(1,30)/30;
integral = filter(b_int,a_int,square);


%%%%%% Blanking %%%%%%%%
signal = integral;
peaks=[];Pindex = 0;
window = 30;
for i = window:(length(signal)-window+1)
    current_sample  = signal(i);
    range  = i-(window-1):i+(window-1);
    maximum  = max(signal(range));
    if(current_sample>=maximum)
        Pindex = Pindex+1;
        peaks(Pindex) = i;
    end
end

peak=peaks/128;
rr=diff(peaks,1);
plot(rr/128)






