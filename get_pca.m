format shortG;
folders_myo = "MyoData/";
folders_gt = "groundTruth/";

users_myo = dir(folders_myo);
users_gt = dir(folders_gt);
global pr; 
pr = [];
global rc; 
rc = [];
    
for i=4:length(users_myo)
    path_myo = folders_myo + users_myo(i).name + "/fork/";
    path_gt = folders_gt + users_gt(i).name + "/fork/";
    sensor_files = dir(path_myo + "*.txt");
    gt_files = dir(path_gt + "*.txt");
    for k=1:length(sensor_files)
        disp(sensor_files(k).name)
        disp(gt_files(1).name)
        if contains(sensor_files(k).name,"IMU")
            calc(path_myo+sensor_files(k).name,path_gt+gt_files(1).name,"IMU",users_myo(i).name,pr,rc)
%         elseif contains(sensor_files(k).name,"EMG")
%             calc(path_myo+sensor_files(k).name,path_gt+gt_files(1).name,"EMG",users_myo(i).name)
        end
    end
 end

function calc(file_myo,file_gt,sensor,user,pr,rc)
    f_data = csvread(file_myo);
    tf_data = csvread(file_gt);
    s_t = [];
    e_t = [];
    for l=1:length(tf_data)
      s_t = [s_t;(round(tf_data(l,1)/30,3)*50)];
      e_t = [e_t;(round(tf_data(l,2)/30,3)*50)];
    end
    mat = [];
    zs = zeros(length(f_data),1);
    mat = horzcat(f_data,zs);
    for l=1:length(tf_data)
        mat(floor(s_t(l)):floor(e_t(l)),end) = ones(floor(e_t(l))-floor(s_t(l)) + 1,1);
    end
    disp(sum(mat(1:length(mat),end)==1));
    calc_pca(mat(:,2:10),sensor,user,pr,rc);  
end

function calc_pca(mat,sensor,user,pr,rc)
  mat = mat(randperm(size(mat,1)),:);
  class_labels = mat(:,end);
  train_data = mat(:,1:end-1);
  coeff = pca(train_data);
  feature_matrix = train_data * coeff(:,1:7);
  disp(size(feature_matrix));
  
  decision_tree(mat, class_labels,sensor,user,pr,rc);
%   svm(mat, class_labels);
%   neuralnet(mat, class_labels);
  
end

function decision_tree(feature_matrix, class_labels, sensor, user,pr,rc)
    a = 0.6*length(feature_matrix);
    
    train_data = feature_matrix(1:a,:);
    train_classes = class_labels(1:a);
    test_data = feature_matrix(a:end,:);
    test_classes = class_labels(a:end);
    
    tree = fitctree(train_data, train_classes);
    label = predict(tree, test_data);
    cmat = confusionmat(test_classes', label');
    disp(precision(cmat));
    disp(recall(cmat));
    pr = [pr;precision(cmat)];
    rc = [rc;recall(cmat)];
    figure;
    plotconfusion(test_classes', label');
    title(strcat('Confusion Matrix - ', sensor ,' - Decision Tree - ',user));
    saveas(gcf, strcat('Confusion Matrix - ', sensor ,' - Decision Tree - ',user,'.png'));
end

function svm(feature_matrix, class_labels)
    a = 0.6*length(feature_matrix);
    
    train_data = feature_matrix(1:a,:);
    train_classes = class_labels(1:a);
    test_data = feature_matrix(a:end, :);
    test_classes = class_labels(a:end);
    
    svm_res = fitcsvm(train_data, train_classes, 'Standardize', true, 'KernelFunction', 'gaussian');
    label = predict(svm_res, test_data);
    cmat = confusionmat(test_classes', label');
    disp(precision(cmat));
    disp(recall(cmat));
    plotconfusion(test_classes', label');
    title('SVM Test Set Confusion Matrix');
end

function neuralnet(feature_matrix, class_labels)
  net = patternnet(10);
  net.divideParam.trainRatio = 0.6
  net.divideParam.valRatio = 0.0
  net.divideParam.testRatio = 0.4
  [net,tr] = train(net,transpose(feature_matrix),transpose(class_labels));
end

function p = precision(cmat)
    p = cmat(1,1)/(cmat(1,1)+cmat(1,2));
end

function r = recall(cmat)
    r = cmat(1,1)/(cmat(1,1)+cmat(2,1));
end