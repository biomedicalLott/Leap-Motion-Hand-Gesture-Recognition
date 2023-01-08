classdef GestureType < uint16
    %GESTURETYPE Summary of this class goes here
    %   Detailed explanation goes here
    enumeration
        CIRCLE(1),
%         DELETE(2),
        EXTRUDE(2), 
        POLY_CREATE(3),
        ROTATE(4),
        SCALE(5),
        SQUARE(6), 
        TRANSLATION(7),
        TRIANGLE(8), 
%         REDO(8)
    end
end

