format shortG;
folders_myo = dir("MyoData/");
folders_gT = dir("groundTruth/");
% for j=3:4
%     disp(folders_myo(j).name)
%     if contains(folders_myo(j).name,"user")
 files = dir("MyoData/user40/fork/*.*");
 files_gt = dir("groundTruth/user40/fork/*.txt");
 for k=1:length(files)
     if contains(files(k).name,"IMU")
          calc(files(k).name,files_gt(1).name,"IMU")
     elseif contains(files(k).name,"EMG")
          calc(files(k).name,files_gt(1).name,"EMG")
     end
 end
%      end
% end

function calc(file_myo,file_gt,sensor)
    disp(file_myo)
    e_mat = [];
    f_data = csvread("MyoData/user40/fork/"+file_myo);
    tf_data = csvread("groundTruth/user40/fork/"+file_gt);
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
    
    [sep_e_mat, sep_non_e_mat] = separate_classes(e_mat(:,2:10));
    [e_mat_ext, non_e_mat_ext] = separate_extracted_features(sep_e_mat, sep_non_e_mat, sensor);
    calc_pca(e_mat_ext,sensor);
    calc_pca(non_e_mat_ext,sensor);
    
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
    if sensor == "IMU"
        numberOfPCAComponents = 5
    elseif sensor == "EMG"
        numberOfPCAComponents = 4
    end
    [coeff,score] = pca(mat);
    pcaFeatureMatrix = mat * coeff;
    [rows,col] = size(pcaFeatureMatrix);
    for n=1:rows
        plot(pcaFeatureMatrix(n,1:numberOfPCAComponents));
        hold on;
    end
    title(sensor);
    figure();
    xlabel('PCA Components');
    ylabel('Values for the PCA Components');
    hold off
    biplot(coeff(:,1:3),'scores',score(:,1:3));
    title(sensor);
    figure();
end


