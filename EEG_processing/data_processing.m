%% EEG data processing 2017/06/25
clear, close all;


%% load EEG data(csv)

filepath = 'EEGdata\';

list=dir(['EEGdata\*.csv']); % get all EEG data file
files = struct2cell(list);
filename_all = files(1,:); % get all the file name
file_sort = sort_nat(filename_all,'ascend'); % sort the file
filename = char(file_sort(end)); % select the last file

full_path = [filepath filename];
load_data = xlsread(full_path,1);
for i=1:8
    data(:,i) = load_data(:,i+1);
end

EEGdata = data(~any(isnan(data),2),:);


%% data pre-processing

stdev = std(EEGdata);
avg = mean(EEGdata)

% remove the outlier
for i=1:8
    [x1, y1] = find(EEGdata(:,i)>(avg(1,i)+3*stdev(1,i))); 
    if numel(x1)~=0
        for index=numel(x1):-1:1
        EEGdata(x1(index,1),:) = [];
        end
    end
    
    [x2, y2] = find(EEGdata(:,i)<(avg(1,i)-3*stdev(1,i)));
    if numel(x2)~=0
        for index=numel(x2):-1:1
        EEGdata(x2(index,1),:) = [];
        end
    end
end

%% bandpass filter & time-frequency analysis (CWT, morlet wavelet)

samplerate = 1000; % in Hz
passband = [1 60];   % pass band of bandpass filter, in Hz
forder = 6;     % filter order
fstep = 0.5;   % frequency step for wavelet

EEGdata_time = EEGdata'; % transpose the matrix

for i=1:8
    filtered_data = filter_2sIIR(EEGdata_time(i,:),passband,samplerate,forder,'bandpass')
    
    spec_alpha = tfa_morlet(filtered_data, samplerate, 8, 15, fstep);
    alpha_freq(1,i) = mean(spec_alpha(:)); % alpha average
    alpha_freq(1,i+8) = max(spec_alpha(:)); % max alpha value
    alpha_freq(1,i+16) = min(spec_alpha(:)); % min alpha value
    
    spec_beta = tfa_morlet(filtered_data, samplerate, 15, 30, fstep);
    beta_freq(1,i) = mean(spec_beta(:)); % beta average
    beta_freq(1,i+8) = max(spec_beta(:)); % max beta value
    beta_freq(1,i+16) = min(spec_beta(:)); % min beta value
    
    spec_delta = tfa_morlet(filtered_data, samplerate, 1, 4, fstep);
    delta_freq(1,i) = mean(spec_delta(:)); % delta average
    delta_freq(1,i+8) = max(spec_delta(:)); % max delta value
    delta_freq(1,i+16) = min(spec_delta(:)); % min delta value
    
    spec_gamma = tfa_morlet(filtered_data, samplerate, 30, 60, fstep);
    gamma_freq(1,i) = mean(spec_gamma(:)); % gamma average
    gamma_freq(1,i+8) = max(spec_gamma(:)); % max gamma value
    gamma_freq(1,i+16) = min(spec_gamma(:)); % min gamma value
    
    spec_theta = tfa_morlet(filtered_data, samplerate, 4, 8, fstep);
    theta_freq(1,i) = mean(spec_theta(:)); % theta average
    theta_freq(1,i+8) = max(spec_theta(:)); % max theta value
    theta_freq(1,i+16) = min(spec_theta(:)); % min theta value
end

result = [alpha_freq beta_freq delta_freq gamma_freq theta_freq];

%% PCA


%% export data(.arff)

arffwrite('test_arff',result,'testset\');

