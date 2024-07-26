clc; clear all; close all;
% removing 2 seconds from the begining of each epoch
% each epoch contains 9 seconds
% sampling rate = 250 Hz
% each epoch has 2250 samples
% then 2*250=500 samples will remove

% load(['EEG.mat'])
EEG.datanew(:,:,:) = EEG.data(:,501:2250,:);
EEG.data = EEG.datanew;
EEG.pnts = 1750;
EEG.times(1:500) = [];
