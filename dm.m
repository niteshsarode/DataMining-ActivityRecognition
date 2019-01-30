format shortG;
folders_myo = dir("MyoData/");
folders_gT = dir("groundTruth/");

for j=3:3
    disp(folders_myo(j).name)
    if contains(folders_myo(j).name,"user")
         files = dir("MyoData/"+folders_myo(j).name+"/fork/*.*");
         files_gt = dir("groundTruth/user9/fork/*.txt");
         for k=1:length(files)
             if contains(files(k).name,"EMG")
                  calc(files(k).name,files_gt(1).name)
              end
         end
     end
end

function calc(file_myo,file_gt)
    disp(file_myo)
    x_ticks = [];
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
    flag = f_data(1,end);
%     disp(flag)
    for l=1:length(tf_data)
      for t=cursor:e_t(l)
          if t < s_t(l)
              e_mat = [e_mat;f_data(t,:),0]; % 0 for non-eating
          elseif t >= s_t(l) && t <= e_t(l)
              e_mat = [e_mat;f_data(t,:),1]; % 1 for eating
          end
          if(f_data(t,end) ~= flag)
              x_ticks = [x_ticks f_data(t, 1)];
              flag = f_data(t,end);
          end
      end
      cursor = floor(e_t(l));
    end
    
    %fft function call
    calcFFT(e_mat(:,2:9))
    
    %Mean function for the matrix
    f_mean(e_mat(:, 2:9));
    
    %sum function for the matrix
    f_sum(e_mat(:, 2:9));
    
    %RMS along the column of the matrix
    f_rms(e_mat(:, 2:9));
end            

function calcFFT(mat)
    X = fftshift(fft(mat(1:50, :)));
    pxx = pwelch(X);
    plot(pxx)
end

function f_sum(mat)
    flag = mat(1, end);
    temp_arr = [];
    final_mat = [];
    for l = 1:length(mat(:,1))
        if(mat(l, end) ~= flag)
            %function used
            temp_arr = sum(temp_arr, 1);
            flag = mat(l, end);
            final_mat = [final_mat; temp_arr];
            temp_arr = [];
        else
            temp_arr = [temp_arr ; mat(l, :)];
        end
    end
    disp(length(final_mat(:, 1)));
    plot(final_mat(1:50, :));
    xticks(0:1:816);
end

function f_mean(mat)
    flag = mat(1, end);
    temp_arr = [];
    final_mat = [];
    for l = 1:length(mat(:,1))
        if(mat(l, end) ~= flag)
            %function used
            temp_arr = mean(temp_arr, 1);
            flag = mat(l, end);
            final_mat = [final_mat; temp_arr];
            temp_arr = [];
        else
            temp_arr = [temp_arr ; mat(l, :)];
        end
    end
    disp(length(final_mat(:, 1)));
    plot(final_mat(1:50, :));
    xticks(0:1:816);
end

function f_rms(mat)
    flag = mat(1, end);
    temp_arr = [];
    final_mat = [];
    for l = 1:length(mat(:,1))
        if(mat(l, end) ~= flag)
            %function used
            temp_arr = rms(temp_arr, 1);
            flag = mat(l, end);
            final_mat = [final_mat; temp_arr];
            temp_arr = [];
        else
            temp_arr = [temp_arr ; mat(l, :)];
        end
    end
    disp(length(final_mat(:, 1)));
    plot(final_mat(1:25, :));
    xticks(0:1:816);
end
