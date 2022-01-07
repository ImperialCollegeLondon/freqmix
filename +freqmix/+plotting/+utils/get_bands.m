
function [freq_bands, band_size, band_id] = get_bands(bands)
%GET_BANDS delta, theta, alpha, beta, low gamma, gamma

freq_bands = [];

if any(strcmp(bands,'delta'))
   freq_bands = [freq_bands;[1 4]];
end

if any(strcmp(bands,'theta'))
   freq_bands = [freq_bands;[4 8]];
end

if any(strcmp(bands,'alpha'))
   freq_bands = [freq_bands;[8 12]];
end

if any(strcmp(bands,'beta'))
   freq_bands = [freq_bands;[12 30]];
end

if any(strcmp(bands,'low gamma'))
   freq_bands = [freq_bands;[30 70]];
end

if any(strcmp(bands,'gamma'))
   freq_bands = [freq_bands;[70 1000]];
end

band_size = freq_bands(:,2) - freq_bands(:,1);              

band_id = bands;

end