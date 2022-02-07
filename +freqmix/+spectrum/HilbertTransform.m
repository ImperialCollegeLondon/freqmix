function spec = HilbertTransform(data, tVal, freqs, varargin)
% Added the ability to scale teh wavelet width with frequency, define wavelet as 'WAVELETSPEC',{'morlet',widths} 

  if size(data,1)==numel(data)
    data = data';
  end
  
  if size(data,1)>size(data,2)
      data = data';
  end
      
  
  numChans = size(data,1);
  numSamps = size(data,2);
  
  if any(strcmp(varargin,'SAVE'))
    fileName = varargin{find(strcmp(varargin,'SAVE'))+1};
    if ~strcmp(fileName((end-3):end),'.wls')
      fileName = [fileName '.wls'];
    end
    saveYes = true;
  else
    saveYes = false;
  end
  
  if any(strcmp(varargin,'CHANNELNAME'))
    channelNames = varargin{find(strcmp(varargin,'CHANNELNAME'))+1};
    if ischar(channelNames)
      channelNames = {channelNames};
    end
    if length(channelNames) ~= numChans
      error('The wrong number of channel names were specified');
    end
  else
    for j = 1:numChans
      channelNames{j} = ['Ch' num2str(j)];
    end
  end
  
 
  if any(strcmp(varargin, 'SUBSAMPLE'))
    subFactor = varargin{find(strcmp(varargin,'SUBSAMPLE'))+1};
    retInds = 1:subFactor:numSamps;
  else
    retInds = 1:numSamps;
  end
  
  if length(tVal) == 1
    spec.Times = (0:(numSamps-1))*tVal;
    spec.Times = spec.Times(retInds);
    tStep = tVal;
  elseif length(data) == length(tVal)
    spec.Times = tVal(retInds);
    tStep = median(diff(tVal));
  else
    error('Time improperly specified');
  end
  
  if saveYes
    sampleTimes = spec.Times;
    Spectrum = 1i*ones(1,numel(retInds),numChans);%numel(freqs),numel(spec.Times));
    waveletParams = {wType wParams};
    save(fileName,'sampleTimes', 'freqs', 'Spectrum', 'channelNames', ...
      'waveletParams', '-v7.3');
    clear sampleTimes Spectrum waveletParams spec;
    mfObj = matfile(fileName, 'Writable',true);
    spec = fileName;
  else
    spec.Freqs = freqs;
    spec.Spectrum = 1i*ones(numel(spec.Freqs),numel(retInds),numChans);
    spec.ChannelNames = channelNames;
  end
  

  delta_f = ((freqs(2)-freqs(1)) / 2);
  for j = 1:length(freqs)
    currFreq = freqs(j);
    
    filtered_data = bandpass(data,[currFreq-delta_f currFreq+delta_f],1/tVal, 'steepness',0.95);
    temp = hilbert(filtered_data);

    
    if numChans == 1
      if saveYes
        mfObj.Spectrum(j,:) = temp(retInds);
      else
        spec.Spectrum(j,:) = temp(retInds);
      end
    else
      for k = 1:numChans
        if saveYes
          mfObj.Spectrum(j,:,k) = temp(retInds);
        else
          spec.Spectrum(j,:,k) = temp(retInds);
        end
      end
    end
  end
    