function varargout = finalProjectApp(varargin)
% FINALPROJECTAPP MATLAB code for finalProjectApp.fig
%      FINALPROJECTAPP, by itself, creates a new FINALPROJECTAPP or raises the existing
%      singleton*.
%
%      H = FINALPROJECTAPP returns the handle to a new FINALPROJECTAPP or the handle to
%      the existing singleton*.
%
%      FINALPROJECTAPP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FINALPROJECTAPP.M with the given input arguments.
%
%      FINALPROJECTAPP('Property','Value',...) creates a new FINALPROJECTAPP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before finalProjectApp_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to finalProjectApp_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help finalProjectApp

% Last Modified by GUIDE v2.5 21-May-2022 03:59:33

% Begin initialization code - DO NOT EDIT
global server
global drawing
global dataBuffer
global index
global detectionFrames
global points
global weights
global ghandles
global serverOn
global state
global client
% points = zeros(2000,3);
% dataBuffer = []
% weights = {load('weighted_mean_R.mat'),load('weighted_mean_L.mat')}
% b = repmat(struct('x',1), 2000, 1 );

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @finalProjectApp_OpeningFcn, ...
    'gui_OutputFcn',  @finalProjectApp_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before finalProjectApp is made visible.
function finalProjectApp_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to finalProjectApp (see VARARGIN)

% Choose default command line output for finalProjectApp
handles.output = hObject;
global ghandles
global serverOn
ghandles = handles;
serverOn = false;
global dataBuffer
global index
global detectionFrames
global points
global weights
global state
global client
global fig
detectionFrames = 0;
index = 1;
points = zeros(2000,3);
weights = {load('weighted_mean_R.mat'),load('weighted_mean_L.mat')}
state = State(0);
% dataBuffer = []
% Update handles structure
guidata(hObject, handles);
fig(1) = gcf;

% axes(fig(1));
% global plots;
ghandles = handles;
%  axis([0 1 0 1])
% ghandles.get(axes1)
%  set(fig(1),'XTick',[],'Ytick',[],'Box','on')
% UIWAIT makes finalProjectApp wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = finalProjectApp_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in serverButton.
function serverButton_Callback(hObject, eventdata, handles)
% hObject    handle to serverButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global serverOn
global server
global dataBuffer
global fig
% if ~serverOn
try
    %     clear server
    server = tcpserver("127.0.0.5", 8911);
    configureTerminator(server,0x13); %""
    configureCallback(server, "terminator", @dataReceived);
    %     serverOn = true;
catch
    disp("Seems the server is already on");
end
% else
%     serverOn = false;
% clear server
% end
% --- Executes on button press in clientButton.
function clientButton_Callback(hObject, eventdata, handles)
% hObject    handle to clientButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global client
try
    client  = tcpclient("127.0.0.13",8693);
    %     configureCallback(client,"byte", 10,@dataWaitingToSend);
catch
    disp("Client already open");
end
% !ping 127.0.0.13

function dataReceived(obj,event)
global dataBuffer
global index
global points
global ghandles
global client
if index >= 2000
    index = 1;
%     clf;
end

%     set(ghandles.output,'string', strcat("data received at", string(i)))
% read the data in from the tcp server
try
    data = readline(obj);
    % decode it from string to structs
    HandData = jsondecode(data);
catch
    disp("no data retrieved");
    return;
end
% now, if the data buffer hasn't gotten anything in it yet
% place something inside
if size(dataBuffer,1) < 1
    n(1,index) = HandData;
    dataBuffer = n;
else %
    dataBuffer(1,index) = HandData;
end
StateMachine(HandData);

function StateMachine(HandData)
global state
% Neutral
% Rotate
% Extrude
% Scale
% Object creation
% Poly Object Creation
% class_names = {'circles'; 'delete'; 'extrude'; 'geometry'; 'rotate'; 'scale'; 'square'; 'translation'; 'triangles'};
%     class_label = [0; 1; 2; 3; 4; 5; 6; 7; 8];

global lastPoint
global count
global client
global index
global drawingManager
global fig
%     t = tcpclient("127.0.0.13",8693);
% The idea is that this will cycle through states checking current data and
% analyzing what best to do based on the situation. It's a bunch of toggle
% switches effectively.
switch state
    case State.NEUTRAL
        %         disp('Neutral State')
        if DoWeSeeTheHand(HandData)
            %             Processes the incoming data and classifies it, if anything
            %             can be clasified
            if index < 50
                disp("Entering Neutral State");
                
                return
            end
            [choice1, vote ]= Data_Processing();
            %             toss out the votes for classes we don't care about
            %             vote([1,3,6,8]) = NaN;
            %             now sort such that the best will be at the start of the index
            %             [~,bestVotes] = sort(vote,'descend');
            %             best = bestVotes(1);
            %             then cycle into a thing to check if it's any of these, if it
            %             isn't we just ignore it entirely
            vote;
            %             vote(8) = 0;
            %             [~,choice1] = max(vote);
            %             GestureType(choice1)
            if choice1 == GestureType.CIRCLE
                state = State.CREATE;
                disp("Entered Creation");
                %             elseif choice1 == GestureType.GEOMETRY
                %                 state = State.POLY_CREATE;
            end
            %             the last point seen is stored for the other states to use,
            %             just in case!
            pt = HandData.Fingers(2).TipPosition;
            lastPoint = [pt.x,pt.y,pt.z];
            count  = 1;
        end
        return
    case State.ROTATE %ROTATE STATE
        if DoWeSeeTheHand(HandData)
            disp("Entering Neutral State");
            
            state = State.NEUTRAL ;
        end
        %         This section compares the distance betwen the  current point, and
        %         the last, relative to the direction vector This is important so
        %         an rotation can be extracted
        count  = count + 1;
        % %         Also note, we only check the rotation every 5 frames of data
        % but we check the "do we see hand" thing every single frame. This will
        % reduce unwanted rotation
        if count > 5
            count = 1;
            c_pt = HandData.Fingers(2).TipPosition;
            currentPoint = [c_pt.x,c_pt.y, c_pt.z];
            leftIndDir = HandData.Fingers(2).Direction ;
            centralAxis = [leftIndDir.x, leftIndDir.y,leftIndDir.z];
            point1 = centralAxis - lastPoint ;
            point2 = centralAxis - currentPoint ;
            CosTheta = max(min(dot(point1,point2)/(norm(point1)*norm(point2)),1),-1);
            relativeAngle = real(acosd(CosTheta));
            %             relativeQuat = vrrotvec(point2, point1);
            %             relativeAngle = quat2eul(relativeQuat,'XYZ');
            %         Notice, the key here is that we are sending this relative-angle
            %         data to blender without checking for a hand being up. This makes
            %         it so that
            lastPoint = currentPoint;
            drawingManager.extendFunc(GestureType.SCALE,relativeAngle);
            
            %             message = jsonencode(struct('type', 'rotate', 'value',relativeAngle));
            %             writeline(t,message)
        end
        return
    case State.TRANSLATE
        if DoWeSeeTheHand(HandData)
            disp("Entering Neutral State");
            
            state = State.NEUTRAL ;
            return
        end
        count  = count + 1;
        
        if count > 5
            count = 1;
            c_pt = HandData.Fingers(2).TipPosition;
            currentPoint = [c_pt.x,c_pt.y, c_pt.z];
            leftIndDir = HandData(1).Fingers(2).Direction ;
            centralAxis = [leftIndDir.x, leftIndDir.y,leftIndDir.z];
            point1 = centralAxis - lastPoint ;
            point2 = centralAxis - currentPoint ;
            nextPoint = point2 - point1;
            drawingManager.extendFunc(GestureType.TRANSLATION,nextPoint)
            
            lastPoint = currentPoint;
            %             message = jsonencode(struct('type', 'grab', 'value',nextPoint));
            %             writeline(client,(message))
        end
        return
        %         disp('Grab State')
%     case State.SCALE
%         %         disp('Scale State')
%         if DoWeSeeTheHand(HandData)
%             disp("Entering Neutral State");
%             
%             state = State.NEUTRAL ;
%         end
%         if count > 5
%             count = 1;
%             c_pt = HandData.Fingers(2).TipPosition;
%             currentPoint = [c_pt.x,c_pt.y, c_pt.z];
%             leftIndDir = HandData.Fingers(2).Direction  ;
%             centralAxis = [leftIndDir.x, leftIndDir.y,leftIndDir.z];
%             point1 = centralAxis - lastPoint ;
%             point2 = centralAxis - currentPoint ;
%             nextPoint = point2 - point1;
%             nextPoint = nextPoint / 10;
%             lastPoint = currentPoint;
%             drawingManager.extendFunc(GestureType.SCALE,nextPoint)
%             %             message = jsonencode(struct('type', 'scale', 'value',nextPoint));
%             %             writeline(client,(message))
%         end
%         return
    case State.CREATE
        %         state = State.NEUTRAL;
        %         disp('Create Object State')
        if DoWeSeeTheHand(HandData)
            if index < 50
                return
            end
            [choice1, vote ] = Data_Processing();
            if vote == -1
                disp("wha...");
            end
            
            %             toss out the votes for classes we don't care about
            %             vote([2,3,4,5,6,8,10]) = NaN;
            %             now sort such that the best will be at the start of the index
            %             [~,bestVotes] = sort(vote,'descend');
            %             best = bestVotes(1);
            GestureType(choice1)
            if std(vote) < 45
                
                state = State.NEUTRAL;
                return
            end
            
            switch choice1
                case GestureType.CIRCLE
                    disp("Creating Circle");
                    drawingManager = CreateFunc(choice1,axes(fig))
                    %                 a = struct('type', 'sphere', 'value',[1,1,1])
                    %                 message = jsonencode(a);
                    %                 %                 echotcpip("on",client.Port)
                    %                 write(client,(message))
                    %                 state = State.NEUTRAL;
                case  GestureType.TRIANGLE
                    disp("Creating Triangle");
                    drawingManager = CreateFunc(choice1,axes(fig))
                    %                 message = jsonencode(struct('type', 'triangle', 'value',[1,1,1]));
                    %                 writeline(client,(message))
                    %                 state = State.NEUTRAL;
                case  GestureType.SQUARE
                    disp("Creating Square");
                    drawingManager = CreateFunc(choice1,axes(fig))
                    %                 state = State.NEUTRAL;
                    %                 message = jsonencode(struct('type', 'cube', 'value',[1,1,1]));
                    %                 writeline(client,(message))
                case  GestureType.EXTRUDE
                    disp("Entering Extrude");
                    state = State.EXTRUDE;
%                 case  GestureType.SCALE
%                     disp("Entering Scale");
%                     state = State.SCALE;
                case  GestureType.TRANSLATION
                    disp("Entering Translation");
                    state = State.TRANSLATE;
                case  GestureType.ROTATE
                    disp("Entering Rotate");
                    state = State.ROTATE;
                otherwise
                    disp("Entering Neutral State");
                    state = State.NEUTRAL
            end
            
            
        end
        %     case State.POLY_CREATE
        %         if DoWeSeeTheHand(HandData)
        %             if index >= 200
        %                 buf = dataBuffer(1:index)
        %                 anyLeftHands = arrayfun(@(x) x.IsLeft, [buf]);
        %                 anyRightHands = arrayfun(@(x) ~x.IsLeft, [buf]);
        %                 anyClosedHands = sum(arrayfun(@(x) x.IsExtended , [buf.Fingers]),1) < 4;
        %                 Left = buf(anyLeftHands & anyClosedHands);
        %                 Right = buf(anyRightHands & anyClosedHands);
        %
        %                 %     closed = segmentedData.Right.Closed;
        %                 %     Right = segmentedData.Right.Closed(1,1);
        %                 %     Left = segmentedData.Left.Closed(1,1);
        %                 gesture = Gesture(Left,Right);
        % %                 processedData  = Gesture.saveObj(gesture);
        %                 gesture
        %             end
        %
        %             if index < 50
        %                 return
        %             end
        %             [choice1, vote ] = Data_Processing();
        %             %             toss out the votes for classes we don't care about
        % %             vote([1,3,4,5,6,7,8,9]) = NaN;
        %             %             now sort such that the best will be at the start of the index
        % %             [~,bestVotes] = sort(vote,'descend');
        % %             best = bestVotes(1);
        %             %             if best == GestureType.REDO
        %             %                 writeline(client,"redo")
        %             if choice1 == GestureType.UNDO
        %                 writeline(client,"undo")
        %             else
        %                 %                 message = jsonencode(struct('type', 'poly', 'value', newPoint, 'Finalize', 'Y'));
        %                 %                 writeline(client,(message))
        %
        %                 state = State.NEUTRAL;
        %             end
        %
        %         end
        %         if count > 3
        %             count = 1;
        %             [pt1,pt2,pt3,pt4,pt5] = HandData.Fingers(:).TipPosition
        %             finger(1:5,end+1) =[pt1,pt2,pt3,pt4,pt5]
        %             newPoint = currentPoint - lastPoint;
        % %             message = jsonencode(struct('type', 'poly', 'value', newPoint, 'Finalize', 'N'));
        % %             writeline(client,(message))
        %         end
        %         count = count + 1;
    otherwise
        
        disp('How did you have a state that does not exist?')
end

function  ISeeTheHand = DoWeSeeTheHand(HandData)
global dataBuffer
global detectionFrames
global index
ISeeTheHand = 0;
minimum_threshold_for_gesture_check= 30; 

%     increase index
index = index + 1;
%     If it's the right hand, check if it's the bat signal
if ~HandData.IsLeft
    [thu, ind,mid,rin, pin] = HandData.Fingers.IsExtended;
    if (thu+ind+mid+rin+pin) == 5
        detectionFrames  = detectionFrames + 1;
        if detectionFrames >= minimum_threshold_for_gesture_check
%             cla;
            detectionFrames = 0;
            %             index = 1;
            ISeeTheHand = 1;
            %                Segment, package, process, predict
            index  = index - minimum_threshold_for_gesture_check;
            
        end
    else
        detectionFrames = 0;
    end
end
function rotMat = getRotationMatrix(directionVec)
x = leftIndDir.x; y= leftIndDir.y; z =leftIndDir.z;
mag = sqrt(x^2+y^2+z^2)
alpha = acos(x/mag); beta = acos(y / mag); gamma = acos(z/mag);
ca = cos(alpha); sa = sin(alpha);
cb = cos(beta); sb = sin(beta);
cg = cos(gamma); sg = sin(gamma);

rotMat = [...
    ca*cb*cg - sa*sg, -ca*cb*sg-sa*cg, ca*sb
    sa*cb*cg + ca*sg, -sa*cb*sg+ca*cg, sa*sb
    -sb*cg, sb*sg, cb];


function [class1,vote] = Data_Processing()
global dataBuffer
global index
global weights
global ghandles
global detectionFrames
global server
try
    flush(server);
catch
    disp("tried to flush the server");
end
% try
%     -1 here is because the index was increased before this point, so
%     it'll be out of range

buf = dataBuffer(1,1:index-1);

% First segment the data
%     segmentedData = segmentHandData(1,1,buf);
%     buf = struct2cell(buf);
%     buf = reshape(buf, size(buf,1),size(buf,3));
anyLeftHands = arrayfun(@(x) x.IsLeft, [buf]);
anyRightHands = arrayfun(@(x) ~x.IsLeft, [buf]);
anyClosedHands = sum(arrayfun(@(x) x.IsExtended , [buf.Fingers]),1) < 4;
Left = buf(anyLeftHands & anyClosedHands);
Right = buf(anyRightHands & anyClosedHands);

%     closed = segmentedData.Right.Closed;
%     Right = segmentedData.Right.Closed(1,1);
%     Left = segmentedData.Left.Closed(1,1);
gesture = Gesture(Left,Right,1);
processedData  = Gesture.saveObj(gesture);
% then process it and extract features
%     processedData = ProcessData(segmentedData);
% then pass it along the classifier
class1 = "bob";
[class1,vote] = classification(processedData,...
    weights{1, 1}.Mean_Data_R,weights{1, 2}.Mean_Data_L);
index = 1;

GestureType(class1)
dataBuffer(:) = [];
% catch
%     vote = -1;
%     disp("data processing didn't go as planned, try again.")
%     detectionFrames = 0;
% end
% outputText = strcat("Most likely ", class1, " but may be ", class2)
% set(ghandles.output,'string', outputText)
function relAngle = getRelAngle(u,v)
CosTheta = max(min(dot(u,v)/(norm(u)*norm(v)),1),-1);
relAngle = real(acos(CosTheta));




function dataWaitingToSend(obj,event)

try
    writeline(obj,"Hello");
    obj.Terminator
    readline(obj)
catch
    disp("oof")
end
