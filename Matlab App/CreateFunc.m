classdef CreateFunc
    properties
        points
        axis
    end
    
    methods
        function createFunc = CreateFunc(type,ax )
%             points = [0,0,0];

            createFunc.axis = ax;
            switch type
                case GestureType.CIRCLE
                    points = createFunc.circle(ax);
                case GestureType.SQUARE
                    points = createFunc.square(ax);
                case GestureType.TRIANGLE
                    points = createFunc.triangle(ax);
            end
            createFunc.points = points;
            createFunc.axis = ax;
        end

        function createFunc = extendFunc(createFunc,type,points3)
            switch type
                case GestureType.TRANSLATION
                    createFunc.points  = CreateFunc.translate527(points3,5,createFunc.axis)
                case GestureType.ROTATE
                    createFunc.points  = CreateFunc.rotate527(points3,5,createFunc.axis)
                case GestureType.EXTRUDE
                    createFunc.points = CreateFunc.rotate527(points3,5,createFunc.axis)
            end
            
        end
    end
    
    methods (Static)
        function points = circle(ax)
            
            resolution = 80;
            xc = cos(linspace(0,2*pi, resolution));
            yc = sin(linspace(0,2*pi, resolution));
            zc = zeros(1, 80);
            points(:,:,1) = [xc', yc', zc'];
            hold on
            plot3(ax,xc, yc, zc, 'b-', 'LineWidth', 3);
            hold off
        end
        function points = triangle(ax)
            x1=0-.5;
            x2=2-1.5;
            y1=0-.5;
            y2=1-.5;
            x = [x1, x2, x1, x1, x1];
            y = [y1, y1, y2, y2, y1];
            z = zeros(1, length(x));
            hold on
            plot3(ax,x, y, z, 'b-', 'LineWidth', 3);
            hold off
            points = [x',y',z'];
        end
        function points2 = translate527(points3, x, y,ax)
            [resolution, height2, dimension] = size(points3);
            height = dimension;
            points = points3(:,:,1);
            for j = 1:height
                for i = 1: resolution
                    xt = x;
                    yt = y;
                    zt = j-1;
                    rotation = rotx(0);
                    transformer = [[rotation; 0 0 0], [xt; yt; zt; 1]];
                    points2(i, :,j) = (transformer* [points(i,:),1]')';
                end
                hold on
                plot3(ax,points2(:,1,j), points2(:,2,j), points2(:,3,j))
                hold off
            end
        end
        function points = square(ax)
            x1=0-.5;
            x2=1-.5;
            y1=0-.5;
            y2=1-.5;
            x = [x1, x2, x2, x1, x1];
            y = [y1, y1, y2, y2, y1];
            z = zeros(1, length(x));
            hold on
            plot3(ax,x, y, z, 'b-', 'LineWidth', 3);
            hold off
            points = [x',y',z'];
        end
        function points2 = rotate527(points3, degree,ax)
            [resolution, height2, dimension] = size(points3);
            height = dimension;
            points = points3(:,:,1);
            for j = 1:height
                for i = 1: resolution
                    xt = 0;
                    yt = 0;
                    zt = j-1;
                    rotation = rotz(degree);
                    transformer = [[rotation; 0 0 0], [xt; yt; zt; 1]];
                    points2(i, :,j) = (transformer* [points(i,:),1]')';
                end
                hold on
                plot3(ax,points2(:,1,j), points2(:,2,j), points2(:,3,j))
                hold off
            end
        end
        function points2 = extrude527(points3, height,ax)
            [resolution, height2, dimension] = size(points3);
            height = round(height);
            points = points3(:,:,1);
            for j = 1:height
                for i = 1: resolution
                    xt = 0;
                    yt = 0;
                    zt = j;
                    rotation = rotx(0);
                    transformer = [[rotation; 0 0 0], [xt; yt; zt; 1]];
                    points2(i, :,j) = (transformer* [points(i,:),1]')';
                end
                hold on
                plot3(ax,points2(:,1,j), points2(:,2,j), points2(:,3,j))
                hold off
            end
            
        end
    end
end