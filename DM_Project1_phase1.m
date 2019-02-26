format shortG;
folders_myo = "MyoData/";
folders_gT = "groundTruth/";

file_path = "MyoData/user09/fork/"
file_path_gt = "groundTruth/user9/fork/"

 sensor_files = dir(file_path + "*.*");
 gt_files = dir(file_path_gt + "*.txt");
 
 for k=1:length(sensor_files)
     if contains(sensor_files(k).name,"IMU")
          calc(sensor_files(k).name,gt_files(1).name,"IMU")
     elseif contains(sensor_files(k).name,"EMG")
          calc(sensor_files(k).name,gt_files(1).name,"EMG")
     end
 end

function calc(file_myo,file_gt,sensor)
    disp(file_myo)
    res_mat = [];
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
              res_mat = [res_mat;f_data(t,:),0]; % 0 for non-eating
          elseif t >= s_t(l) && t <= e_t(l)
              res_mat = [res_mat;f_data(t,:),1]; % 1 for eating
          end
      end
      cursor = floor(e_t(l));
    end
    
    [sep_e_mat, sep_non_e_mat] = separate_classes(res_mat(:,2:10));
%     
%     calc_fft(sep_e_mat, sep_non_e_mat, sensor);
%     calc_dct(sep_e_mat, sep_non_e_mat, sensor);
%     calc_rms(sep_e_mat, sep_non_e_mat, sensor);
%     calc_std(res_mat(:,2:10), sensor);
%     calc_mean(res_mat(:,2:10), sensor);
    
    [e_mat_ext, non_e_mat_ext] = separate_extracted_features(sep_e_mat, sep_non_e_mat, sensor);
    calc_pca(e_mat_ext,sensor);  
%     after_pca(sep_e_mat)

end

function [sep_e_mat, sep_non_e_mat] = separate_classes(mat)
    disp(size(mat))
    sep_e_mat = [];
    sep_non_e_mat = [];
    
     for l = 1:size(mat)
         if mat(l,9) == 1
             sep_e_mat = [sep_e_mat;mat(l,1:8)];
         else
             sep_non_e_mat = [sep_non_e_mat;mat(l,1:8)];
         end
     end

    disp(size(sep_e_mat));
    disp(size(sep_non_e_mat));
end

function calc_fft(sep_e_mat, sep_non_e_mat, sensor)
    imu_names = {'Orientation X'; 'Orientation Y'; 'Orientation Z'; 'Orientation W'; 'Accelerometer X'; 'Accelerometer Y'; 'Accelerometer Z'; 'Gyroscope X'; 'Gyroscope Y'; 'Gyroscope Z'};
    emg_names = {'EMG1'; 'EMG2'; 'EMG3'; 'EMG4'; 'EMG5'; 'EMG6'; 'EMG7'; 'EMG8'};
    
    [rows,cols] = size(sep_e_mat)
    
    for k = 1:cols
        x = sep_e_mat(:,k);
        x = real(fft(x));
        %red color for eating action
        f = figure();
        plot(x(20:end,:), 'color', [0 0 1]);
        hold on

        y = sep_non_e_mat(:,k);
        y = real(fft(y));
        %blue color for non-eating action
        plot(y(20:end,:), 'color', [1 0 0]);
        
        legend({'eating', 'non-eating'}, 'Location','northeast');
        xlabel('Frequency');
        ylabel('FFT values');
        xlim([20 250]);
        
        if sensor == "IMU"
            title(imu_names(k));
            saveas(f, strcat('imu_',k,'.png'));
        elseif sensor == "EMG"
            title(emg_names(k));
            saveas(f, strcat('emg_',k,'.png'));
        end
    end
end

function calc_dct(sep_e_mat, sep_non_e_mat, sensor)
    imu_names = {'Orientation X'; 'Orientation Y'; 'Orientation Z'; 'Orientation W'; 'Accelerometer X'; 'Accelerometer Y'; 'Accelerometer Z'; 'Gyroscope X'; 'Gyroscope Y'; 'Gyroscope Z'};
    emg_names = {'EMG1'; 'EMG2'; 'EMG3'; 'EMG4'; 'EMG5'; 'EMG6'; 'EMG7'; 'EMG8'};
    
    [rows,cols] = size(sep_e_mat)
    
    for k = 1:cols
        x = sep_e_mat(:,k);
        x = real(dct(x));
        %red color for eating action
        f = figure();
        plot(x(20:end,:), 'color', [0 0 1]);
        hold on

        y = sep_non_e_mat(:,k);
        y = real(dct(y));
        %blue color for non-eating action
        plot(y(20:end,:), 'color', [1 0 0]);
        
        legend({'eating', 'non-eating'}, 'Location','northeast');
        xlabel('Frequency');
        ylabel('DCT values');
        xlim([20 250]);
        
        if sensor == "IMU"
            title(imu_names(k));
            saveas(f, strcat('imu_',k,'.png'));
        elseif sensor == "EMG"
            title(emg_names(k));
            saveas(f, strcat('emg_',k,'.png'));
        end
    end
end

function calc_rms(mat,sensor)
    flag = mat(1, end);
    temp_arr = [];
    sep_e_mat = [];
    sep_non_e_mat = [];
    
    for l = 1:length(mat(:,1))
        if(mat(l, end) ~= flag)
            %function used
            temp_arr = rms(temp_arr, 1);
            if(flag == 1)
                sep_e_mat = [sep_e_mat; temp_arr];
            else
                sep_non_e_mat = [sep_non_e_mat; temp_arr];
            end
            flag = mat(l, end);
            temp_arr = [];
        else
            temp_arr = [temp_arr ; mat(l, :)];
        end
    end

    for k = 1:cols
        x = sep_e_mat(:,k);
        y = sep_non_e_mat(:,k);
        f = figure();
        plot(x, 'color', [1 0 0]);
        hold on

        plot(y, 'color', [0 1 0]);
        xlabel('activities');
        ylabel('RMS values');
        legend({'eating', 'non-eating'}, 'Location','northeast');

        if sensor == "EMG"
            title('RMS on EMG');
            saveas(f, 'emg-rms.png');
        elseif sensor == "IMU"
            title('RMS on IMU');
            saveas(f,'imu-rms.png');
        end
    end
end

function calc_std(mat, sensor)
    flag = mat(1, end);
    temp_arr = [];
    sep_e_mat = [];
    sep_non_e_mat = [];
    
    for l = 1:length(mat(:,1))
        if(mat(l, end) ~= flag)
            %function used
            temp_arr = std(temp_arr, 1);
            if(flag == 1)
                sep_e_mat = [sep_e_mat; temp_arr];
            else
                sep_non_e_mat = [sep_non_e_mat; temp_arr];
            end
            flag = mat(l, end);
            temp_arr = [];
        else
            temp_arr = [temp_arr ; mat(l, :)];
        end
    end
    
    imu_names = {'Orientation X'; 'Orientation Y'; 'Orientation Z'; 'Orientation W'; 'Accelerometer X'; 'Accelerometer Y'; 'Accelerometer Z'; 'Gyroscope X'; 'Gyroscope Y'; 'Gyroscope Z'};
    emg_names = {'EMG1'; 'EMG2'; 'EMG3'; 'EMG4'; 'EMG5'; 'EMG6'; 'EMG7'; 'EMG8'};

    [rows,cols] = size(sep_e_mat);
    
    for k = 1:cols
        x = sep_e_mat(:,k);
        y = sep_non_e_mat(:,k);
        f = figure();
        plot(x, 'color', [1 0 0]);
        hold on
        
        plot(y, 'color', [0 0 1]);
        xlabel('Activities') ;
        ylabel('STD values');
        legend({'eating', 'non-eating'}, 'Location','northeast');
        
        if sensor == "IMU"
            title(imu_names(k));
            saveas(f, strcat('imu_',k,'.png'));
        elseif sensor == "EMG"
            title(emg_names(k));
            saveas(f, strcat('emg_',k,'.png'));
        end
    end
end

function calc_mean(mat, sensor) 
    imu_names = {'Orientation X'; 'Orientation Y'; 'Orientation Z'; 'Orientation W'; 'Accelerometer X'; 'Accelerometer Y'; 'Accelerometer Z'; 'Gyroscope X'; 'Gyroscope Y'; 'Gyroscope Z'};
    emg_names = {'EMG1'; 'EMG2'; 'EMG3'; 'EMG4'; 'EMG5'; 'EMG6'; 'EMG7'; 'EMG8'};
    
    flag = mat(1, end);
    temp_arr = [];
    sep_e_mat = [];
    sep_non_e_mat = [];
    
    for l = 1:length(mat(:,1))
        if(mat(l, end) ~= flag)
            %function used
            temp_arr = mean(temp_arr, 1);
            if(flag == 1)
                sep_e_mat = [sep_e_mat; temp_arr];
            else
                sep_non_e_mat = [sep_non_e_mat; temp_arr];
            end
            flag = mat(l, end);
            temp_arr = [];
        else
            temp_arr = [temp_arr ; mat(l, :)];
        end
    end
    
    [rows,cols] = size(sep_e_mat)
    
    for k = 1:cols
        x = sep_e_mat(:,k);
        plot(x, 'color', [1 0 0]);
        hold on
        
        y = sep_non_e_mat(:,k);
        plot(y, 'color', [0 0 1]);
        f = figure();
     
        xlabel('activities');
        ylabel('mean values');
        legend({'eating', 'non-eating'}, 'Location','northeast');
        if sensor == "IMU"
            title(imu_names(k));
            saveas(f, strcat('imu_',k,'.png'));
        elseif sensor == "EMG"
            title(emg_names(k));
            saveas(f, strcat('emg_',k,'.png'));
        end
    end
end

function [e_mat_ext, non_e_mat_ext] = separate_extracted_features(sep_e_mat, sep_non_e_mat, sensor)
    if sensor == "EMG"
        disp(sensor)
        e_mat_ext = sep_e_mat(:,[1 3 5 6]);
        non_e_mat_ext = sep_non_e_mat(:,[1 3 5 6]);
    end
    if sensor == "IMU"
        disp(sensor)
        e_mat_ext = sep_e_mat(:,[1 2 6 7 8]);
        non_e_mat_ext = sep_non_e_mat(:,[1 2 6 7 8]);
    end
end

function calc_pca(mat, sensor)

    emg_AxisNames = ["d1","d2","d3","d4"];
    imu_AxisNames = ["Orientation X","Orientation Y","Accelerometer Y","Accelerometer Z","Gyroscope X"];
    
    if sensor == "IMU"
        numberOfPCAComponents = 5;
    elseif sensor == "EMG"
        numberOfPCAComponents = 4;
    end
    
    [coeff,score] = pca(mat);
    [vec,values] = eig(coeff);
    pcaFeatureMatrix = mat * coeff;
    [rows,col] = size(pcaFeatureMatrix);
    for n=1:rows
        plot(pcaFeatureMatrix(n,1:numberOfPCAComponents));
        hold on;
    end
    fx = figure();
    if sensor == "EMG"
        title(sensor+"-PCA");
        saveas(fx, strcat('emg_pca.png'));
    elseif sensor == "IMU"
        title(sensor+"-PCA");
        saveas(fx, strcat('imu_pca.png'));
    end

    plot(pcaFeatureMatrix);
    hold on;
    
    xlabel('PCA Components');
    ylabel('Values for the PCA Components');
   
    if sensor == "IMU"
        biplot(coeff(:,1:3),'scores',score(:,1:3),'varlabels',imu_AxisNames);
        title("3d-PCA");
        f = figure();
    end
end

function before_pca(mat)
   [coeff,score,l,t,e] = pca(mat);
   disp("Vaues " + e)
end
