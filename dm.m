format long;

folders_myo = dir("MyoData/");
folders_gT = dir("groundTruth/");
e_mat = {};
ne_mat = {};
for j=3:length(folders_myo)
    disp(folders_myo(j).name)
      if contains(folders_myo(j).name,"user")
          files = dir("MyoData/"+folders_myo(j).name+"/fork/*.*");
          files_gt = dir("groundTruth/"+folders_gT(j).name+"/fork/*.*");
          for k=1:length(files)
               if contains(files(k).name,"EMG")
                   FileNames = files(k).name;
                   f_data = csvread("MyoData/"+folders_myo(j).name+"/fork/"+files(k).name);
                   tf_data = csvread("groundTruth/"+folders_gT(j).name+"/fork/"+files_gt(k).name);
                   start_time = {};
                   end_time = {};
                   for l=1:length(tf_data)
                       start_time = [start_time;(round(tf_data(l,1)/30,3)*1000)];
                       end_time = [end_time;(round(tf_data(l,2)/30,3)*1000)];
                   end
                   first_sample = f_data(1,1);
                   s_t = cell2mat(start_time);
                   e_t = cell2mat(end_time);
                   cursor = 1;
                   for l=1:length(tf_data)
                       s = first_sample + s_t(l);
                       e = first_sample + e_t(l);
                       for t=cursor:length(f_data)
                           if f_data(t,1) >= s && f_data(t,1) <= e
                               e_mat = [e_mat;f_data(t,:)];  
                               cursor = t;
                           end
                           if f_data(t,1) < s
                               ne_mat = [ne_mat;f_data(t,:)];
                           end
                           if f_data(t,1) > e
                               break
                           end
                       end
                   end
               end
          end
      end
end

%  e_mat conatins eating samples and ne_mat conatins non-eating samples.

mat = cell2mat(e_mat);
disp(class(mat));

mat(:, 1) = []; %deleted the timestamp from the matrix

%Fourier transform
y = fft(mat, [], 2);
% power spectral density of the FFT
pxx = pwelch(y);
plot(pxx)
ylim([0 500])
legend('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h') %for 8 attributes  EMG 1, EMG 2, EMG 3, EMG 4, EMG 5, EMG 6, EMG 7, and EMG 8.
