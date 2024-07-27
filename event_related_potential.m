% plot ERPs and topographical maps
% compute the ERP of each channel
% ERP is the time-domain average across all trials at each time point

erp = mean(EEG.data,3);

%% pick a channel and plot ERP
ch = 'fp1';
figure(); clf;
plot(EEG.times,erp( strcmpi({EEG.chanlocs.labels},ch) ,:),'b','linew',1.2);
set(gca,'xlim',[-500 2000]); hold on; 
plot([0 0],get(gca,'ylim'),'k--','linew',1);
plot(get(gca,'xlim'),[0 0],'k--','linew',1);
xlabel('Time (ms)'); ylabel('Activity (\muV)');
title([ 'ERP image of channel ' num2str(ch) ]);

% plot ERP of all channels
figure(); clf;
plot(EEG.times,erp);
set(gca,'xlim',[-1000 2000]); hold on; 
plot([0 0],get(gca,'ylim'),'k--','linew',1);
plot(get(gca,'xlim'),[0 0],'k--','linew',1);
xlabel('Time (ms)'); ylabel('Activity (\muV)');
title('ERP image of all channel');

%% plot topographical maps

time2plot = 100; % in msec
% convert time in ms to time in indices
[~,tidx] = min(abs(EEG.times-time2plot));
figure(); clf;
topoplotIndie(erp(:,tidx),EEG.chanlocs);
title([ 'ERP from ' num2str(time2plot) ' ms' ]);
colorbar;
set(gca,'clim',[-4 4]); % colorbar range

%% Another way
% plot ERP from channel F3

figure(), clf;
chan = 4;
plot(EEG.times,squeeze(mean(EEG.data(chan,:,:),3)))
hold on;
plot(get(gca,'xlim'),[0 0],'k--'); % X-Axis with black dashed
plot([0 0],get(gca,'ylim'),'k--'); % Y-Axis with black dashed
xlabel('Time (s)'); ylabel('Activity (\muV)');
title('ERP of electrode F3');
set(gca,'xlim',[-1000 2000]);

%% plot depth-by-time image of ERP

figure(); clf;
contourf(EEG.times,1:32,squeeze(mean(EEG.data,3)),'linecolor','none');
set(gca,'xlim',[-1000 2000]);
xlabel('Time (sec.)');
ylabel('Cortical depth');
