function [signals] = generate_synthetic_signal(params)
%See 'decomposition_testing.m'
%   Example usage and visualization:

% params.Fs = 1250;
% params.dt = 1/params.Fs;
% params.t = params.dt:params.dt:0.2;
% params.ctl_pts_t    = linspace(params.t(1),params.t(end),2);
% params.IF_low       = ones(size(params.ctl_pts_t))*30;
% params.IF_high      = ones(size(params.ctl_pts_t))*100;
% params.IA_low       = ones(size(params.ctl_pts_t))*0.2;
% params.IA_high      = ones(size(params.ctl_pts_t))*2;;
% 
% params.n_signals = 5;
% weights = rand(5,5);
% x = my_random_signal(params);
% figure;
% for i=1:5
%     [cwtOut,f] = cwt(x(i,:),1250,'VoicesPerOctave',24,'TimeBandwidth',120);
%     subplot(2,5,i); h=pcolor(1:size(cwtOut,2),f,abs(cwtOut)); set(h,'edgecolor','none'); 
%     ylim([max(10,min(f)) 200]); colormap(parula);freezeColors;    
%     [cwtOut,f] = cwt(weights(i,:)*x,1250,'VoicesPerOctave',24,'TimeBandwidth',120);
%     subplot(2,5,i+5); h=pcolor(1:size(cwtOut,2),f,abs(cwtOut)); set(h,'edgecolor','none'); 
%     ylim([max(10,min(f)) 200]); colormap(parula);freezeColors;
% end



ctl_pts_t = params.ctl_pts_t;
dt = params.dt;
Fs = params.Fs;
t = params.t;

signals = zeros(params.n_signals,length(t));
for j=1:params.n_signals;
    IF = rand(1,length(params.IF_high)).*(params.IF_high - params.IF_low) + params.IF_low;
    IA = rand(1,length(params.IF_high)).*(params.IA_high - params.IA_low) + params.IA_low;
    IF_full = spline(ctl_pts_t,IF,t);
    IA_full = spline(ctl_pts_t,IA,t);
    phi = zeros(1,length(t));
    for i=2:length(t)
        phi(i) = phi(i-1) + 2*pi*IF_full(i)*dt;
    end
    signals(j,:) = IA_full.*sin(phi);

end

