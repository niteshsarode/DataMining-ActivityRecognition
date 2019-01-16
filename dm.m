format shortg;
folders_myo = dir("MyoData/");
folders_gT = dir("groundTruth/");
mat = zeros(9);
e_mat = {};
for j=1:length(folders_myo)
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
                  for l=1:length(tf_data)
                      s = first_sample + s_t(l);
                      e = first_sample + e_t(l);
                      for t=1:length(f_data)
                          if f_data(t,1) > s && f_data(t,1) < e
                              disp(f_data(t,:));
                              e_mat = [e_mat;f_data(t,:)];                              
                          end
                      end
                  end
              end
         end
     end
end
disp(e_mat)