format shortG;
folders_myo = dir("MyoData/");
folders_gT = dir("groundTruth/");
for j=3:4
    disp(folders_myo(j).name)
    if contains(folders_myo(j).name,"user")
         files = dir("MyoData/"+folders_myo(j).name+"/fork/*.*");
         files_gt = dir("groundTruth/user9/fork/*.txt");
         for k=1:length(files)
             if contains(files(k).name,"EMG")  % || contains(files(k).name,"IMU")
                  calc(files(k).name,files_gt(1).name)
              end
         end
     end
end

function calc(file_myo,file_gt)
    disp(file_myo)
    e_mat = [];
    f_data = csvread("MyoData/user09/fork/"+file_myo);
    tf_data = csvread("groundTruth/user9/fork/"+file_gt);
    s_t = [];
    e_t = [];
    for l=1:length(tf_data)
      s_t = [s_t;(round(tf_data(l,1)/30,3)*50)];
      e_t = [e_t;(round(tf_data(l,2)/30,3)*50)];
    end
    cursor = 1;
    for l=1:length(tf_data)
      for t=cursor:e_t(l)
          if t < s_t(l)
              e_mat = [e_mat;f_data(t,:),0]; % 0 for non-eating
          elseif t >= s_t(l) && t <= e_t(l)
              e_mat = [e_mat;f_data(t,:),1]; % 1 for eating
          end
      end
      cursor = floor(e_t(l));
    end
    calcFFT(e_mat(:,2:9))
end                  

function calcFFT(mat)
    disp(length(mat))
    X = fftshift(fft(mat));
    pxx = pwelch(X);
    plot(pxx)
end
