function [] = plot_mixing(mixing, varargin)
%PLOT_MIXING Plotting of frequency mixing

import freqmix.plotting.*

% parse arguments
cfg = freqmix.config.config_plotting;
mixing_ids = 1;
for argidx = 1:2:length(varargin)
   switch varargin{argidx}
       case 'config'
           cfg = varargin{argidx+1};
       case 'mixing_ids'
           mixing_ids = varargin{argidx+1} ;
       case 'folder'
           cfg.folder = varargin{argidx+1};
   end
end   



% if table then plot entire scan
if isequal(class(mixing), 'table')
   plot_scan(mixing, cfg);
end

% if cell array then plot boxplots comparing groups
if isequal(class(mixing), 'cell')
    plot_specific_mixing(mixing, mixing_ids, cfg);
end


end

