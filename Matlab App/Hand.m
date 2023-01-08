classdef Hand
    %HAND Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        HandData
        %holds xyz information
        points =struct('palm',[],'palmNorm',[],'palmVel',[],'palmDir',[],...
            'thumb',[],'index', [], 'mid',[], 'ring', [], 'pinky',[]);
        %Holds time information
        time = struct('palm', [],'thumb', [],'index', [],'ring',[], 'pinky',[]);
        pinch = struct('Strength', [], 'Distance', []);
        grab = struct('Strength', [], 'Angle', []);
        rotations =struct('palm', [],'thumb', [],'index', [],'ring',[], 'pinky',[]);
        extendedState = []; % 5 for each data point
        isLeft = []; %array of 0s or 1s
        isOpen = []; %array of 0s or 1s
        Points2D = struct('palm',[],'palmNorm',[],'palmVel',[],'palmDir',[],...
            'thumb',[],'index',[],'mid',[],'ring',[],'pinky',[]);
        RelativeTipDistance = struct('thumb',[],'index',[],'mid',[],'ring',[]);
        RubineFeatures = struct('palm',[],'thumb',[],'index',[],'mid',[],'ring',[],'pinky',[]);
        RelativeTipFeatures = struct('thumb',[],'index',[],'mid',[],'ring',[],'pinky',[]);
        CollectiveFeatures = zeros(195,1);
        listOfLabels = {}
        
    end
    
    methods
        function handObj = Hand(data)
            %HAND Safely stores the data for later, this step only
            %stores data, it doesn't process it actual processing
            
            if exist('data','var')
                % third parameter does not exist, so default it to something
                handObj = handObj.storeData(data);
                handObj.HandData = data;
            else
                handObj.HandData = {};
            end
            
        end
        function handObj = extractFeatures(handObj)
            if ~isempty(handObj.points.palm)
                %             Step 1 - reduce dimensionality to go from 3D to 2D
                %                 I chose method 1, method 2 is PCA
                handObj = handObj.reduceDimensionality(1);
                %                 This gets the distances of tips to one another
                handObj = handObj.getTipDistance();
                %                 These will find the rubine features for all of the tips
                handObj.RubineFeatures.palm = ...
                    handObj.getRubineFeatures(handObj.Points2D.palm, handObj.time.palm);
                
                handObj.RubineFeatures.thumb = ...
                    handObj.getRubineFeatures(handObj.Points2D.thumb, handObj.time.thumb);
                handObj.RubineFeatures.index = ...
                    handObj.getRubineFeatures(handObj.Points2D.index, handObj.time.index);
                handObj.RubineFeatures.mid = ...
                    handObj.getRubineFeatures(handObj.Points2D.mid, handObj.time.mid);
                handObj.RubineFeatures.ring = ...
                    handObj.getRubineFeatures(handObj.Points2D.ring, handObj.time.ring);
                handObj.RubineFeatures.pinky = ...
                    handObj.getRubineFeatures(handObj.Points2D.pinky, handObj.time.pinky);
                %                 Combines all the features together into one point
                handObj.CollectiveFeatures = handObj.combineFeatures();
                
            end
        end
        function handObj = updateFeatures(handObj)
            if ~isempty(handObj.points.palm)
                handObj = handObj.getTipDistance();
                %                 These will find the rubine features for all of the tips
                handObj.RubineFeatures.palm = ...
                    handObj.getRubineFeatures(handObj.Points2D.palm, handObj.time.palm);
                
                handObj.RubineFeatures.thumb = ...
                    handObj.getRubineFeatures(handObj.Points2D.thumb, handObj.time.thumb);
                handObj.RubineFeatures.index = ...
                    handObj.getRubineFeatures(handObj.Points2D.index, handObj.time.index);
                handObj.RubineFeatures.mid = ...
                    handObj.getRubineFeatures(handObj.Points2D.mid, handObj.time.mid);
                handObj.RubineFeatures.ring = ...
                    handObj.getRubineFeatures(handObj.Points2D.ring, handObj.time.ring);
                handObj.RubineFeatures.pinky = ...
                    handObj.getRubineFeatures(handObj.Points2D.pinky, handObj.time.pinky);
                %                 Combines all the features together into one point
                handObj.CollectiveFeatures = handObj.combineFeatures();
            end
        end
        function f = combineFeatures(handObj)
            fset1 = handObj.RubineFeatures;
            %                 1:13 = palm
            % 14:78 = simple rubine on tips going from thumb to pinky in 13 increments
            79+110
            fset2 = handObj.RelativeTipFeatures;
            %             relative tip features
            %             11x4 comparison of digit to one of the other digits
            %               so thumb to index, thumb to mid, thumb to ring,
            %               thumb to pink
            %             79:90 thumb to index
            %             298:305
            f0 = mean(handObj.isLeft);
            f1 = mean(handObj.isOpen);
            
            f2 = mean(mean(handObj.extendedState,2) > 3);
            f3 = max(handObj.pinch.Strength);
            f4 = max(handObj.pinch.Distance);
            f5 = max(handObj.grab.Strength);
            f6 = max(handObj.grab.Angle);
            f = [fset1.palm; fset1.thumb; fset1.index; fset1.mid;...
                fset1.ring; fset1.pinky; fset2.thumb(:); fset2.index(:);...
                fset2.mid(:);fset2.ring(:);fset2.pinky(:);...
                f0;f1;f2;f3;f4;f5;f6];
            
            
        end
        
        function  features  = getRubineFeatures(handObj, points, time)
            x = points(:,1); y = points(:,2); t = mean(time,2);
            %             there may be missing data points for time, so i fill them in
            tMin = min(t(t>0));
            t = t - tMin;
            t(t<0) = NaN;
            t = fillmissing(t,'movmedian',6);
            
            dx = x(2:end) - x(1:end-1);
            dy = y(2:end) - y(1:end-1);
            dt = t(2:end) - t(1:end-1);
            euDist = sqrt(dx.^2+dy.^2);
            xMax = max(x); xMin = min(x); yMax = max(y); yMin = min(y);
            center = [0;0];
            center(1) = (xMax - xMin)/2; center(2) = (yMax - yMin)/2;
            theta = atan2(dy,dx);
            
            %             theta = atan2((center(2) - y(1)),...
            %                 (center(1)-x(1)));
            f1 = acos((x(3) - x(1)) / sqrt( ...
                (x(3) - x(1)).^2 + ...
                (y(3) - y(1)).^2));
            f2 = asin((y(3) - y(1)) / sqrt( ...
                (x(3) - x(1)).^2 +...
                (y(3) - y(1)).^2));
            f3 = sqrt((xMax - xMin).^2 + (yMax - yMin).^2);
            f4 = atan2((yMax - yMin) , (xMax - xMin));
            f5 = sqrt((x(end-1) - x(1)).^2 +...
                (y(end-1) - y(1)).^2);
            f6 = acos((x(end-1) - x(1))./f5);
            f7 = asin((y(end-1) - y(1))./f5);
            f8 = sum(euDist);
            f9 = sum(theta(1:end-2));
            f10 = sum(abs(theta(1:end-2)));
            f11 = sum(theta(1:end-2).^2);
            f12 = max((dx(1:end-2).^2 + ...
                dy(1:end-2).^2)./dt(1:end-2).^2);
            f13 = t(end-1) - t(2);
            features = real([f1;f2;f3;f4;f5;f6;f7;f8;f9;f10;f11;f12;f13]);
            features(isnan(features)) = 0;
            features(isinf(features)) = 0;
        end
        function handObj = getTipDistance(handObj)
            %             Step 1, concatenate all of the data into a 3D array
            fingertips = cat(3,handObj.Points2D.thumb,handObj.Points2D.index,...
                handObj.Points2D.mid,handObj.Points2D.ring,handObj.Points2D.pinky);
            %             Finds the relative distance of each digit from
            %             the others
            thumb = (fingertips(:,:,1) - fingertips(:,:,[2 3 4 5]));
            index = (fingertips(:,:,2) - fingertips(:,:,[3 4 5]));
            mid =(fingertips(:,:,3) - fingertips(:,:,[4 5]));
            ring = (fingertips(:,:,4) - fingertips(:,:,5));
            %             pinky = (fingertips(:,:,5) - fingertips(:,:,[1 2 3 4]));
            len = length(ring);
            %             Here, it stores a reshaped (2D) distance vector of len by 4
            handObj.RelativeTipDistance.thumb = reshape(sqrt(sum(thumb.^2,2)),[len,4]);
            handObj.RelativeTipDistance.index = reshape(sqrt(sum(index.^2,2)),[len,3]);
            handObj.RelativeTipDistance.mid = reshape(sqrt(sum(mid.^2,2)),[len,2]);
            handObj.RelativeTipDistance.ring = reshape(sqrt(sum(ring.^2,2)),[len,1]);
            %             handObj.RelativeTipDistance.pinky = reshape(sqrt(sum(pinky.^2,2)),[len,4]);
            %             This will actually get all of the tip features though, this
            %             stuf is where the magic happens
            handObj.RelativeTipFeatures.thumb =...
                handObj.getRelFeatures(thumb,handObj.RelativeTipDistance.thumb,4);
            handObj.RelativeTipFeatures.index =...
                handObj.getRelFeatures(index,handObj.RelativeTipDistance.index,3);
            handObj.RelativeTipFeatures.mid =...
                handObj.getRelFeatures(mid,handObj.RelativeTipDistance.mid,2);
            handObj.RelativeTipFeatures.ring =...
                handObj.getRelFeatures(ring,handObj.RelativeTipDistance.ring,1);
            %             handObj.RelativeTipFeatures.pinky =...
            %                 handObj.getRelFeatures(pinky,handObj.RelativeTipDistance.pinky);
            
            
        end
        function f = getRelFeatures(handObj, tipxyDist,tipDist, width)
            %             This is baiscally just rubine but for larger arrays
            % I reshape at first to make sure it's 2D
            maxXY = reshape(max(tipxyDist),[2,width]); minXY = reshape(min(tipxyDist),[2,width]);
            %             Force the center to be real, just in case
            %             centerXY = real(maxXY - minXY)/2;
            
            len = length(tipDist);
            %             Reshape the x and y extractions to make sure they're 2D
            x = reshape(tipxyDist(:,1,:), [len,width]);
            y = reshape(tipxyDist(:,2,:), [len,width]);
            %             Get theta
            dx = x(2:end,:) - x(1:end-1,:);
            dy = y(2:end,:) - y(1:end-1,:);
            theta = atan2(dy,dx);
            
            %             theta = atan2(centerXY(2,:)- y,centerXY(1,:) - x);
            %             Then get all the feature vectors which will be 11 x 4
            f1 = acos((x(3,:)-x(1,:))./sqrt((x(3,:)-x(1,:)) + (y(3,:) - y(1,:)).^2));
            f2 = asin((y(3,:)-y(1,:))./sqrt((x(3,:)-x(1,:)) + (y(3,:) - y(1,:)).^2));
            f3 = sqrt(sum((maxXY - minXY).^2));
            f4 = atan2((maxXY(2,:) - minXY(2,:)) , (maxXY(1,:) - minXY(1,:)));
            f5 = sqrt((x(end-1,:) - x(2,:)).^2 +...
                (y(end-1,:) - y(2,:)).^2);
            f6 = acos((x(end-1,:) - x(2,:))./f5);
            f7 = asin((y(end-1,:) - y(2,:))./f5);
            f8 = sum(tipDist(1:end-1,:));
            f9 = sum(theta(1:end-1,:));
            f10 = sum(abs(theta(1:end-1,:)));
            f11 = sum(theta(1:end-1,:).^2);
            %             I skip time thiings bcause that's already in the other
            %             rubine feature
            try
                f = real([f1;f2;f3;f4;f5;f6;f7;f8;f9;f10;f11]);
            catch
                error("higher dimensional features weren't the right fit, something went wrong")
            end
        end
        function  handObj = reduceDimensionality(handObj, method)
            if ~exist('method','var')
                method = 1;
            end
            
            if method == 1 %MDScale, idk what it is but it reduces dimensionality
                handObj.Points2D.palm = handObj.mdScale(handObj.points.palm);
                handObj.Points2D.palmNorm = handObj.mdScale(handObj.points.palmNorm);
                handObj.Points2D.palmVel= handObj.mdScale(handObj.points.palmVel);
                handObj.Points2D.palmDir = handObj.mdScale(handObj.points.palmDir);
                handObj.Points2D.thumb = handObj.mdScale(handObj.points.thumb);
                handObj.Points2D.index = handObj.mdScale(handObj.points.index);
                handObj.Points2D.mid = handObj.mdScale(handObj.points.mid);
                handObj.Points2D.ring= handObj.mdScale(handObj.points.ring);
                handObj.Points2D.pinky = handObj.mdScale(handObj.points.pinky);
            end
            if method == 2%PCA reduces to 2D
                handObj.Points2D.palm = handObj.pcaReduction(handObj.points.palm);
                handObj.Points2D.palmNorm = handObj.pcaReduction(handObj.points.palmNorm);
                handObj.Points2D.palmDir = handObj.pcaReduction(handObj.points.palmDir);
                handObj.Points2D.thumb = handObj.pcaReduction(handObj.points.thumb);
                handObj.Points2D.index = handObj.pcaReduction(handObj.points.index);
                handObj.Points2D.mid = handObj.pcaReduction(handObj.points.mid);
                handObj.Points2D.ring= handObj.pcaReduction(handObj.points.ring);
                handObj.Points2D.pinky = handObj.pcaReduction(handObj.points.pinky);
            end
            
        end
        
        function result = mdScale(handObj, data)
           try 
            disparities = pdist(data);
           catch
               print("mdScale's pdist caused something to go haywire");
           end
            try
                result = mdscale(disparities,2);
            catch
                try
                    result = mdscale(disparities,2,'Start','random');
                catch
                    try
                        result = handObj.pcaReduction(data);
                    catch
                        print("dude, mDscale in Hand is out of ideas.");
                    end
                end
            end
            
        end
        function result = pcaReduction(handObj,data)
            [coeff, score] = pca(data);
            centered = score * coeff';
            result = centered(:,1:2)./centered(:,3);
        end
        
        function handObj = storeData(handObj,handData)
            if iscell(handData)
                Hands = handData{1,1};
            else
                Hands = handData;
            end
            
            % pre-made arrays for data
            vis = zeros(length(Hands(1)),1);
            maybe = zeros(length(Hands(1)),5);
            xyz = zeros(length(Hands(1)),3);
            wxyz = zeros(length(Hands(1)),4);
            wxyz2 = zeros(length(Hands(1)),4,length(Hands(1)));
            % Instantiate
            %           3d points
            points = struct('palm',xyz,'palmNorm',xyz,'palmVel',xyz,'palmDir',xyz,...
                'thumb',xyz,'index', xyz, 'mid', xyz, 'ring', xyz, 'pinky',xyz);
            rotations = struct('palm', wxyz,'thumb', wxyz2,'index', wxyz2,'ring',wxyz2, 'pinky',wxyz2);
            time = struct('palm', vis,'thumb', vis,'index', vis,'ring',vis, 'pinky',vis);
            pinch = struct('Strength', vis, 'Distance', vis);
            grab = struct('Strength', vis, 'Angle', vis);
            %             Which fingers are extended
            extendedState = maybe;
            isLeft = vis; %Is it left handed
            isOpen = vis; %Is it open
            %           Loop to take in and store all of the data
            
            for i = 1:length(Hands)
                fingers = Hands(i).Fingers;
                %                 Get positions
                palm = Hands(i).PalmPosition; palmNorm = Hands(i).PalmNormal;
                palmVel = Hands(i).PalmVelocity; palmDir = Hands(i).Direction;
                [thumb,index,mid,ring,pinky] = fingers.TipPosition;
                % Extrac all the positions of tip, and palm stuff
                points.palm(i,:) = extractPos(palm);
                points.palmNorm(i,:) = extractPos(palmNorm);
                points.palmVel(i,:) = extractPos(palmVel);
                points.palmDir(i,:) = extractPos(palmDir);
                points.thumb(i,:) = extractPos(thumb);
                points.index(i,:)= extractPos(index);
                points.mid(i,:) = extractPos(mid);
                points.ring(i,:) = extractPos(ring);
                points.pinky(i,:) = extractPos(pinky);
                %                 I'm keeping the rotations in quaternion form for
                %                 simplicity
                [thumb,index,mid,ring,pinky] = fingers.bones;
                
                %                 This will store all the rotations, nothing we have uses
                %                 these probably, but why not?
                rotations.palm(i,1:4)= extractRot(Hands(i).Rotation);
                rotations.thumb(i,1:4,1:4) = extractBoneRot(thumb.Rotation);
                rotations.index(i,1:4,1:4) = extractBoneRot(index.Rotation);
                rotations.mid(i,1:4,1:4) = extractBoneRot(mid.Rotation);
                rotations.ring(i,1:4,1:4) = extractBoneRot(ring.Rotation);
                rotations.pinky(i,1:4,1:4) = extractBoneRot(pinky.Rotation);
                %     we use this to find out if the hand is open or closed
                %     at that moment
                extendedState(i,1:5) = getFingerState(fingers.IsExtended);
                %                 Time stuff
                time.palm(i,:) = Hands(i).TimeVisible;
                [time.thumb(i,:),time.index(i,:), time.mid(i,:),...
                    time.ring(i,:),time.pinky(i,:)]...
                    = fingers.TimeVisible;
                %                 pinch and grab stuff
                pinch.Strength(i,:) = Hands(i).PinchStrength;
                pinch.Distance(i,:) = Hands(i).PinchDistance;
                grab.Strength(i,:) = Hands(i).GrabStrength;
                grab.Angle(i,:) = Hands(i).GrabAngle;
                %                 is left and is open, It'll be good for reading in later
                isLeft(i,:) = Hands(i).IsLeft;
                isOpen(i,:) = sum(extendedState(i,:)) >3;
                
            end
            handObj.points = points;
            handObj.rotations = rotations;
            handObj.time = time;
            handObj.pinch = pinch;
            handObj.grab = grab;
            handObj.isLeft = isLeft;
            handObj.isOpen = isOpen;
            handObj.extendedState = extendedState;
            
            function state = getFingerState(thumb,index,mid,ring,pinky)
                state = [thumb,index,mid,ring,pinky];
            end
            function xyzPos = extractPos(pos)
                xyzPos = [pos.x, pos.y, pos.z];
            end
            function extractedQuat = extractBoneRot(meta, prox, inter, dist)
                extractedQuat = zeros(4);
                extractedQuat(1,:) =  extractRot(meta);
                extractedQuat(2,:) = extractRot(prox);
                extractedQuat(3,:) = extractRot(inter);
                extractedQuat(4,:) = extractRot(dist);
                
            end
            function quat = extractRot(rot)
                quat = [rot.x, rot.y, rot.z, rot.w];
            end
        end
    end
    methods (Static)
        function saveStruct = saveObj(obj)
            saveStruct.HandData = obj.HandData;
            saveStruct.points = obj.points;
            saveStruct.time = obj.time;
            saveStruct.pinch = obj.pinch;
            saveStruct.grab = obj.grab;
            saveStruct.rotations = obj.rotations;
            saveStruct.extendedState = obj.extendedState;
            saveStruct.isOpen = obj.isOpen;
            saveStruct.isLeft = obj.isLeft;
            saveStruct.Points2D = obj.Points2D;
            saveStruct.RelativeTipDistance = obj.RelativeTipDistance ;
            saveStruct.RubineFeatures = obj.RubineFeatures;
            saveStruct.CollectiveFeatures = obj.CollectiveFeatures;
        end
        function obj = loadObj(saveStruct)
            obj = Hand();
            obj.points = saveStruct.points;
            obj.time = saveStruct.time;
            obj.pinch = saveStruct.pinch;
            obj.grab = saveStruct.grab;
            obj.rotations = saveStruct.rotations;
            obj.extendedState = saveStruct.extendedState;
            obj.isLeft = saveStruct.isLeft;
            obj.isOpen = saveStruct.isOpen;
            %             if exist('saveStruct.Points2D')
            obj.Points2D = saveStruct.Points2D;
            obj.RelativeTipDistance = saveStruct.RelativeTipDistance ;
            obj.RubineFeatures = saveStruct.RubineFeatures;
            obj.CollectiveFeatures = saveStruct.CollectiveFeatures;
            %             end
        end
    end
end

