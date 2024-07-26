base_dir = 'E:\Elnaz\Term4\thesis\EEG\preprocessing\';
dirData = dir(strcat(base_dir,'*.edf'));
for i = 1:length(dirData)
    if i==5
        continue;
    end
    EEG.etc.eeglabvers = '2022.0'; % this tracks which version of EEGLAB is being used, you may ignore it
    EEG = pop_biosig(strcat(dirData(i).folder,'\',dirData(i).name));
    EEG.setname=strcat('s',num2str(i));
    EEG = eeg_checkset( EEG );
    EEG = pop_select( EEG, 'channel',{'Fp1','Fp2','F7','F3','Fz','F4','F8','T3','C3','Cz','C4','T4','T5','P3','Pz','P4','T6','O1','O2'});
    EEG = eeg_checkset( EEG );
    EEG=pop_chanedit(EEG, 'lookup','D:\\software\\EEG\\eeglab_current\\eeglab2022.0\\plugins\\dipfit\\standard_BEM\\elec\\standard_1005.elc','load',{'D:\\software\\EEG\\eeglab_current\\eeglab2022.0\\sample_locs\\Standard-10-20-Cap19.locs','filetype','autodetect'});
    EEG = eeg_checkset( EEG );
    EEG = pop_resample( EEG, 250);
    EEG.setname=strcat('s',num2str(i));
    EEG = eeg_checkset( EEG );
    %EEG = pop_select( EEG, 'point',[1 75000] );
    %EEG = eeg_checkset( EEG );
    EEG = pop_eegfiltnew(EEG, 'locutoff',1,'hicutoff',40);
    EEG = eeg_checkset( EEG );
    EEG = fullRankAveRef(EEG);
    EEG = eeg_checkset( EEG );
    EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion','off','ChannelCriterion','off','LineNoiseCriterion','off','Highpass','on','BurstCriterion',20,'WindowCriterion',0.25,'BurstRejection','on','Distance','Euclidian','WindowCriterionTolerances',[-Inf 7] );
    EEG = eeg_checkset( EEG );
    %EEG = pop_select( EEG, 'time',[0 180] );
    %EEG = eeg_checkset( EEG );
    EEG = fullRankAveRef(EEG);
    EEG = eeg_checkset( EEG );
    EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','off');
    EEG = eeg_checkset( EEG );
    EEG = pop_iclabel(EEG, 'default');
    EEG = eeg_checkset( EEG );
    EEG = pop_icflag(EEG, [NaN NaN;0.9 1;0.7 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]);
    EEG = eeg_checkset( EEG );
    EEG = pop_subcomp( EEG, [], 0);
    EEG.setname=strcat('s',num2str(i));
    EEG = eeg_checkset( EEG );
    EEG = pre_prepData(EEG,'SignalType','Channels');
    EEG = eeg_checkset( EEG );
    EEG.CAT.MODEL = est_fitMVAR(EEG,'Algorithm','ARfit','WindowLength',5,'WindowStepSize',1,'TaperFunction','hann');
    %EEG = pop_est_validateMVAR(EEG,0);
    %EEG.CAT.MODEL.winStartTimes = winStartTimes;
    EEG = eeg_checkset( EEG );
    EEG.CAT.Conn = est_mvarConnectivity(EEG,EEG.CAT.MODEL,'connmethods',{'dDTF','GPDC','iCoh'});
    if i<=9
        filename=strcat(base_dir,'Connectivity2\','S0',num2str(i),'_Connectivity');
    else
        filename=strcat(base_dir,'Connectivity2\','S',num2str(i),'_Connectivity');
    end
    save(filename,'EEG')
end