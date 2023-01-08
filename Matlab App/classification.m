function [class, vote] = classification(gesturePack,Mean_Data_R,Mean_Data_L)
    class_names = {'circles'; 'extrude'; 'geometry'; 'rotate'; 'scale'; 'square'; 'translation'; 'triangles'};
    class_label = [0: length(class_names)-1];
    n_gesture = length(class_label);
    
%     load("weighted_mean_R.mat")
%     load("weighted_mean_L.mat")
    
    [n_feature_R, n_class_R] = size(Mean_Data_R);

Pair_check = triu(ones(n_class_R),1);

    i_count = 1;
    j_count = 1;
    for i = 1:n_class_R
        for j = 1:n_class_R
            if Pair_check(i,j) == 1 
                Data_pair_R(:, i_count) = [Mean_Data_R(:,i); Mean_Data_R(:,j)];
                Data_pair_L(:, i_count) = [Mean_Data_L(:,i); Mean_Data_L(:,j)];
                class_pair(:, i_count) = [class_label(i), class_label(j)];
                i_count = i_count + 1;
            end
        end
    end
    
    sample = 1;
    F_palm_R = gesturePack(sample).Hands.Right.CollectiveFeatures(1:13*6);
    F_palm_L = gesturePack(sample).Hands.Left.CollectiveFeatures(1:13*6);
    F_State_R = gesturePack(sample).Hands.Right.CollectiveFeatures(190:195);
    F_State_L = gesturePack(sample).Hands.Left.CollectiveFeatures(190:195);
    FR = [F_palm_R;F_State_R];
    FL = [F_palm_L;F_State_L];
    [n_sample2, n_pair] = size(Data_pair_R);

    vote1 = zeros(1,n_class_R);
    vote2 = zeros(1,n_class_R);
    for pair_id = 1:n_pair
        class1 = class_pair(1, pair_id);
        class2 = class_pair(2, pair_id);
        for feature_id = 1:n_feature_R
            m1R = Data_pair_R(feature_id, pair_id);
            m2R = Data_pair_R(feature_id + n_feature_R, pair_id);
            m1L = Data_pair_L(feature_id, pair_id);
            m2L = Data_pair_L(feature_id + n_feature_R, pair_id);
            x1 = FR(feature_id);
            x2 = FL(feature_id);
            label1 = sign(abs(x1-m1R)-abs(x1-m2R));
            label2 = sign(abs(x2-m1L)-abs(x2-m2L));
            if label1 == -1
                class = class1;
                vote1(class+1) = vote1(class+1) + 1;
            else
                class = class2;
                vote1(class+1) = vote1(class+1) + 1;
            end

            if label2 == -1
                class = class1;
                vote2(class+1) = vote2(class+1) + 1;
            else
                class = class2;
                vote2(class+1) = vote2(class+1) + 1;
            end
        end
    end
vote = vote1;
%     Left_Hand_check = mean(gesturePack(1).Hands.Left.CollectiveFeatures);
%     Right_Hand_check = mean(gesturePack(1).Hands.Right.CollectiveFeatures);
% % 
%     if Left_Hand_check == 0
%         filter = [1; 0; 1; 0; 0; 1; 1; 1];
%         vote = vote1 .* filter';
%     elseif Right_Hand_check == 0
% 
%         filter = [0; 0; 0; 0; 0; 0; 0; 0];
%         vote = vote2 .* filter';
% 
%     else
%         filter = [0; 1; 0; 1; 1; 0; 0; 0];
%         vote = (vote1+vote2) .* filter';
%     end

    [~,class_id] = max(vote);

    class = class_id;

%     disp(['Activate: ' class_names{class}])

end

