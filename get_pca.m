format shortG;
folders_myo = "MyoData/";
folders_gt = "groundTruth/";

users_myo = dir(folders_myo);
users_gt = dir(folders_gt);
    
for i=4:length(users_myo)
    path_myo = folders_myo + users_myo(i).name + "/fork/";
    path_gt = folders_gt + users_gt(i).name + "/fork/";
    sensor_files = dir(path_myo + "*.txt");
    gt_files = dir(path_gt + "*.txt");
    for k=1:length(sensor_files)
        disp(sensor_files(k).name)
        disp(gt_files(1).name)
        if contains(sensor_files(k).name,"IMU")
            calc(path_myo+sensor_files(k).name,path_gt+gt_files(1).name,"IMU")
        elseif contains(sensor_files(k).name,"EMG")
            calc(path_myo+sensor_files(k).name,path_gt+gt_files(1).name,"EMG")
        end
    end
 end

function calc(file_myo,file_gt,sensor)
    f_data = csvread(file_myo);
    tf_data = csvread(file_gt);
    s_t = [];
    e_t = [];
    for l=1:length(tf_data)
      s_t = [s_t;(round(tf_data(l,1)/30,3)*50)];
      e_t = [e_t;(round(tf_data(l,2)/30,3)*50)];
    end
    mat = [];
    for l=1:length(f_data)
        mat = [mat; f_data(l,:),0];
    end
    cursor = 1;
    for l=1:length(tf_data)
      for t=cursor:e_t(l)
          if t >= s_t(l) && t <= e_t(l)
              mat(t,:) = 1; % 1 for eating
          end
      end
      cursor = floor(e_t(l));
    end
    calc_pca(mat(:,2:10),sensor);  
end

function calc_pca(mat,sensor)
  coeff = pca(mat);
  feature_matrix = mat * coeff(:,1:5);
  disp(size(feature_matrix));
end