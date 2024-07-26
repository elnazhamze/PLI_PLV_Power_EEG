% Comuting Power, PLI, and PLV of EEG data for Attentive trials

clc; clear all; close all;
path='E:\Elnaz\Term4\eeg_paper\results\connectivity\data';
filename = dir(path);
r = 3;
load([path '\' filename(r).name])

%% Labeling
ep=EEG.epoch;
rt=zeros(size(ep,2),2);
for trial=1:size(ep,2)
    ad51=find(cell2mat(ep(trial).eventtype)==251);
    ad52=find(cell2mat(ep(trial).eventtype)==252);
    ad53=find(cell2mat(ep(trial).eventtype)==253);
    tmp=cell2mat(ep(trial).eventinit_time);
    if ~isempty(ad51) & ~isempty(ad53) & (ad53(1)>ad51(1))
        rt(trial,1)=tmp(ad53(1))-tmp(ad51(1));
    end
    if ~isempty(ad52) & ~isempty(ad53) & (ad53(1)>ad52(1))
        rt(trial,2)=tmp(ad53(1))-tmp(ad52(1));
    end
end
for trial=1:size(ep,2)
    if rt(trial,1:2)==0
        RT(trial)=0;
    elseif rt(trial,1)==0 &  rt(trial,2)~=0
        RT(trial)=rt(trial,2);
    elseif rt(trial,1)~=0 &  rt(trial,2)==0
        RT(trial)=rt(trial,1);
    elseif rt(trial,1:2)~=0
        RT(trial)=mean(rt(trial,1:2));
    end
end
RT=RT.';
for trial=1:size(ep,2)
    if (RT(trial)==0)
        lbl(trial)=0;
    elseif (RT(trial)<0.62)
        lbl(trial)=1;
    elseif (RT(trial)>1.5)
        lbl(trial)=-1;
    end
end
lbl=lbl.';
if (size(lbl,1)~=EEG.trials)
    lbl(size(lbl,1):EEG.trials)=0;
end

%% Number of trials
attentive_trial=find(lbl==-1);
inattentive_trial=find(lbl==1);
 
%% Creating Our Wavelets
wtime = -1:1/EEG.srate:1;
% convolution parameters
nData = EEG.pnts*EEG.trials;
nWave = length(wtime);
nConv = nData + nWave - 1;
halfW = floor(nWave/2);
% frequency bands in Hz
mycenter(1)=2.5; mybandwidth(1)=1.5; % delta band: 1-4 Hz
mycenter(2)=6; mybandwidth(2)=2; % theta band: 4-8 Hz
mycenter(3)=10; mybandwidth(3)=2; % alpha band: 8-12 Hz
mycenter(4)=21; mybandwidth(4)=9; % beta band: 12-30 Hz
mycenter(5)=40; mybandwidth(5)=10; % gamma band: 30-50 Hz
whatsmytext(1)="Delta Band";
whatsmytext(2)="Theta Band";
whatsmytext(3)="Alpha Band";
whatsmytext(4)="Beta Band";
whatsmytext(5)="Gamma Band";

for i=1:5
    [cmwX(i,:)]=givemewavelet(mycenter(i),mybandwidth(i),wtime,nConv);
end

%% Applying Laplacian on Previous EEG Data
EEG.lap = laplacian_perrinX(EEG.data,[EEG.chanlocs.X],[EEG.chanlocs.Y],[EEG.chanlocs.Z]);

%% Removing 2-seconds from the beginning of each epoch
EEG.datanew(:,:,:)=EEG.lap(:,501:2250,:);
EEG.lap=EEG.datanew;
EEG.pnts=1750;
EEG.times(1:500)=[];

%% Mean of Attentive Trials of each session
for j=1:size(attentive_trial,1)
    trial=attentive_trial(j);
    attentive{j,1}=mean(EEG.lap(:,:,trial),3);
end
attentive_avg=mean(cat(3, attentive{:}),3);
% load('E:\Elnaz\Term4\eeg_paper\results\connectivity\Attentive.mat')
Attentive{r-2,1}=attentive_avg; % save it

% Mean of all sessions over attentive trials
Attentive_all=mean(cat(3, Attentive{:}),3);

%% Power of Attentive trials
load('E:\Elnaz\Term4\eeg_paper\results\connectivity\Attentive_all.mat')
% Delta=1-4; Theta=4-8; Alpha=8-12; Beta=12-30; Gamma=30-50;
fs=250;
for chani=1:30
    [~,flo,fhi,powertmp]=obw(Attentive_all(chani,:),fs,[1 4]);
    power(chani)=powertmp/0.99;
end
figure(); clf;
topoplot(power,EEG.chanlocs,'maplimits','maxmin','colormap','jet');
title('Power of The Attentive Trials In Delta Band','FontSize',15,'FontName','Times New Roman');
cH = colorbar;
set(cH,'FontSize',15,'FontWeight','bold','FontName','Times New Roman');

%% Compute all-to-all PLI, Laplacian
load('E:\Elnaz\Term4\eeg_paper\results\connectivity\Attentive_all.mat')

numfilt=1; % number of frequency bands (1:5)
dataX = fft(reshape(Attentive_all,EEG.nbchan,[]) ,nConv,2 );
% convolution
as = ifft( bsxfun(@times,dataX,cmwX(numfilt,:)) ,[],2);
as = as(:,halfW:end-halfW-1);
as = reshape( as,size(EEG.data));
% get angles
allphases = angle(as);

% compute all-to-all PLI for attentive trials
for chani = 1:EEG.nbchan
    for chanj = chani+1:EEG.nbchan
        % Euler-format phase differences
        cdd = exp( 1i*(allphases(chani,:) - allphases(chanj,:)) );
        % compute PLI for this channel pair
        plitmp = abs(mean(sign(imag(cdd(:)))));
        % enter into matrix!
        pliall_lap(chani,chanj)=plitmp;
        pliall_lap(chanj,chani)=plitmp;
    end
end

%% Compute all-to-all PLV, Laplacian
load('E:\Elnaz\Term4\eeg_paper\results\connectivity\Attentive_all.mat')

numfilt=1; % number of frequency bands (1:5)
dataX = fft(reshape(Attentive_all,EEG.nbchan,[]) ,nConv,2 ); % convolution
as = ifft( bsxfun(@times,dataX,cmwX(numfilt,:)) ,[],2);
as = as(:,halfW:end-halfW-1);
as = reshape( as,size(EEG.data));
% get angles
allphases = angle(as);

% Compute all-to-all PLV for Attentive trials
for chani = 1:EEG.nbchan
    for chanj = chani+1:EEG.nbchan
        % Euler-format phase differences
        cdd = exp( 1i*(allphases(chani,:) - allphases(chanj,:)) ); % compute PLI for this channel pair
        plvtmp = mean(abs(mean(cdd))); % enter into matrix!
        plvall_lap(chani,chanj) = plvtmp;
        plvall_lap(chanj,chani) = plvtmp;
    end
end

