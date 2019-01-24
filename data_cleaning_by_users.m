format shortG;
folders_myo = dir("MyoData/");
folders_gT = dir("groundTruth/");
for j=3:4
    e_mat = {};
    disp(folders_myo(j).name)
     if contains(folders_myo(j).name,"user")
         files = dir("MyoData/"+folders_myo(j).name+"/fork/*.*");
         files_gt = dir("groundTruth/"+folders_gT(j).name+"/fork/*.*");
         for k=1:length(files)
              if contains(files(k).name,"EMG")
                  FileNames = files(k).name;
                  f_data = csvread("MyoData/"+folders_myo(j).name+"/fork/"+files(k).name);
                  tf_data = csvread("groundTruth/"+folders_gT(j).name+"/fork/"+files_gt(k).name);
                  start_sample = {};
                  end_sample = {};
                  for l=1:length(tf_data)
                      start_sample = [start_sample;(round(tf_data(l,1)/30,3)*50)];
                      end_sample = [end_sample;(round(tf_data(l,2)/30,3)*50)];
                  end
                  s_t = cell2mat(start_sample);
                  e_t = cell2mat(end_sample);
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
              end
         end
     end
     disp(e_mat)
end
