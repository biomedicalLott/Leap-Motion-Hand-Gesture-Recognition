classdef Gesture
    % Top level class to retrieve features from, very easy to deal with.
    % Just call the CollectiveFeatures when doing processing
    properties
        %
        Hands = struct('Left', Hand(),'Right', Hand());
        CollectiveFeatures = zeros(390,1); %array of all features
    end
    
    methods
        function Gesture = Gesture(left,right, first)
            %UNTITLED7 Construct an instance of this class
            %   Detailed explanation goes here
                if exist('left','var') && ~ isempty(left)
                    % third parameter does not exist, so default it to something
                    Gesture.Hands.Left = Hand(left);
                else
                    Gesture.Hands.Left = Hand();
                end
                if exist('right','var') && ~ isempty(right)
                    % third parameter does not exist, so default it to something
                    Gesture.Hands.Right = Hand(right);
                else
                    Gesture.Hands.Right = Hand();
                end
            if exist('first', 'var')
            Gesture = Gesture.extractFeatures();
            end
        end
        
        function Gesture = extractFeatures(Gesture)
            %             I extract features here, first i check if either hand is
            %             there, if a hand isn't I have it generat a fake hand
            if isempty(Gesture.Hands.Left)
                Gesture.Hands.Left = Hand();
            end
            if isempty(Gesture.Hands.Right)
                Gesture.Hands.Right = Hand();
            end
            %             Then, I call "Extract features" from the Hand class to
            %             extract the features from before. This way you can make
            %             changes to Hands to extract features differently without
            %             having to worry about this outside area
            Gesture.Hands.Left = Gesture.Hands.Left.extractFeatures();
            Gesture.Hands.Right= Gesture.Hands.Right.extractFeatures();
            %             I then of course combine the features into one array of left
            %             and right
            Gesture.Hands.Left.CollectiveFeatures(isinf(Gesture.Hands.Left.CollectiveFeatures)) = 0;
            Gesture.Hands.Left.CollectiveFeatures(isnan(Gesture.Hands.Left.CollectiveFeatures)) = 0;
            Gesture.Hands.Right.CollectiveFeatures(isinf(Gesture.Hands.Right.CollectiveFeatures))=0;
            Gesture.Hands.Right.CollectiveFeatures(isnan(Gesture.Hands.Right.CollectiveFeatures)) = 0;
            Gesture.CollectiveFeatures = ...
                [Gesture.Hands.Left.CollectiveFeatures;...
                Gesture.Hands.Right.CollectiveFeatures];
        end
        function Gesture = updateFeatures(Gesture)
            %             I extract features here, first i check if either hand is
            %             there, if a hand isn't I have it generat a fake hand
            if isempty(Gesture.Hands.Left) || isempty(Gesture.Hands.Left.time)
                Gesture.Hands.Left = Hand();
%                 Gesture.Hands.Left = Gesture.Hands.Left.extractFeatures();
            else
                Gesture.Hands.Left = Gesture.Hands.Left.updateFeatures();
            end
            if isempty(Gesture.Hands.Right) || isempty(Gesture.Hands.Right.time)
                Gesture.Hands.Right = Hand();
%                 Gesture.Hands.Right = Gesture.Hands.Right.extractFeatures();
            else
                Gesture.Hands.Right= Gesture.Hands.Right.updateFeatures();
                
            end
            %             Then, I call "Extract features" from the Hand class to
            %             extract the features from before. This way you can make
            %             changes to Hands to extract features differently without
            %             having to worry about this outside area
            %             I then of course combine the features into one array of left
            %             and right
            Gesture.CollectiveFeatures = ...
                [Gesture.Hands.Left.CollectiveFeatures;...
                Gesture.Hands.Right.CollectiveFeatures];        end
    end
    methods (Static)
        function saveStruct = saveObj(obj)
            %             I have these if statements to allow for no hands or both
            %             hands
            if ~isempty(obj.Hands.Left)
                Hands.Left = Hand.saveObj(obj.Hands.Left);
                
            else
                Hands.Left = Hand();
            end
            if ~isempty(obj.Hands.Right)
                Hands.Right = Hand.saveObj(obj.Hands.Right);
            else
                Hands.Right = Hand();
            end
            saveStruct.Hands = Hands;
            saveStruct.CollectiveFeatures = obj.CollectiveFeatures;
            
        end
        function obj = loadObj(saveStruct)
            %             Creates empty gesture object
            obj = Gesture();
            if ~isempty(saveStruct.Hands)
%                 obj.Hands = saveStruct.Hands;
                obj.Hands.Left = Hand.loadObj(saveStruct.Hands.Left);
                obj.Hands.Right = Hand.loadObj(saveStruct.Hands.Right);
                obj.CollectiveFeatures = saveStruct.CollectiveFeatures;
            else %For Backwards Compatibility
                if exist('saveStruct.Left','var') || ~isempty(saveStruct.Hands.Left)
                    Left = Hand.loadObj(saveStruct.Left);
                    obj.Hands.Left = Left ;
                else
                    obj.Hands.Left = Hand();
                end
                if ~isempty(saveStruct.Right)
                    Right = Hand.loadObj(saveStruct.Right);
                    obj.Hands.Right= Right;
                else
                    obj.Hands.Right = Hand();
                end
            end
%             if exist('saveStruct.Hands','var') && ~isempty(saveStruct.CollectiveFeatures)
%                 obj.CollectiveFeatures = saveStruct.CollectiveFeatures;
%             end
        end
    end
end

