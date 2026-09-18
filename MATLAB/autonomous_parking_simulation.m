clc;
clear;
close all;

%% =========================================================
% AUTONOMOUS PARKING USING DISTANCE & BOUNDARY DETECTION
% VERSION 2
%
% Vehicle:
% Length   = 4.5 m
% Width    = 1.8 m
% Wheelbase = 2.7 m
%
% Parking maneuver:
% 1. Approach
% 2. Turn 90 degrees
% 3. Enter parking slot
% 4. Stop
% 5. Verify parking
%% =========================================================


%% =========================================================
% 1. VEHICLE PARAMETERS
%% =========================================================

vehicle.length = 4.5;
vehicle.width = 1.8;
vehicle.wheelbase = 2.7;

vehicle.maxSteering = deg2rad(30);


%% =========================================================
% 2. PARKING ENVIRONMENT
%% =========================================================

env.x_min = 0;
env.x_max = 30;

env.y_min = 0;
env.y_max = 15;


%% =========================================================
% TARGET PARKING SLOT
%% =========================================================

slot.x = 18;
slot.y = 6;

slot.width = 2.5;
slot.length = 5.0;


%% =========================================================
% OBSTACLE VEHICLE
%% =========================================================

obstacle.x = 18;
obstacle.y = 12;

obstacle.width = 2.5;
obstacle.length = 3.0;


%% =========================================================
% 3. INITIAL VEHICLE STATE
%% =========================================================

x = 5;
y = 3;

theta = 0;


%% =========================================================
% SIMULATION PARAMETERS
%% =========================================================

dt = 0.02;

simulationTime = 40;

time = 0:dt:simulationTime;


%% =========================================================
% STATE MACHINE
%% =========================================================

state = 1;

% State 1 = APPROACH
% State 2 = TURN
% State 3 = PARK
% State 4 = PARKED
% State 5 = EMERGENCY STOP


%% =========================================================
% TURN PARAMETERS
%% =========================================================

turnRadius = 1.0;

turnCenterX = 17;

turnCenterY = 4;

turnAngle = -pi/2;


%% =========================================================
% CREATE FIGURE
%% =========================================================

figure( ...
    'Name','Autonomous Parking System V2', ...
    'NumberTitle','off');

hold on;

grid on;

axis equal;

xlim([-1 31]);
ylim([-1 16]);

xlabel('X Position (m)');
ylabel('Y Position (m)');

title( ...
    'AUTONOMOUS PARKING USING DISTANCE & BOUNDARY DETECTION');


%% =========================================================
% PARKING LOT
%% =========================================================

rectangle( ...
    'Position',[ ...
    env.x_min ...
    env.y_min ...
    env.x_max-env.x_min ...
    env.y_max-env.y_min], ...
    'EdgeColor','k', ...
    'LineWidth',2);


%% =========================================================
% TARGET PARKING SLOT
%% =========================================================

rectangle( ...
    'Position',[ ...
    slot.x-slot.width/2 ...
    slot.y-slot.length/2 ...
    slot.width ...
    slot.length], ...
    'EdgeColor','g', ...
    'LineWidth',3);


text( ...
    slot.x, ...
    slot.y, ...
    'TARGET PARKING SLOT', ...
    'HorizontalAlignment','center', ...
    'FontWeight','bold');


%% =========================================================
% OBSTACLE
%% =========================================================

rectangle( ...
    'Position',[ ...
    obstacle.x-obstacle.width/2 ...
    obstacle.y-obstacle.length/2 ...
    obstacle.width ...
    obstacle.length], ...
    'FaceColor',[0.6 0.6 0.6], ...
    'EdgeColor','k', ...
    'LineWidth',1.5);


text( ...
    obstacle.x, ...
    obstacle.y, ...
    'OBSTACLE', ...
    'HorizontalAlignment','center', ...
    'FontWeight','bold');


%% =========================================================
% CAR
%% =========================================================

car = patch( ...
    [0 0 0 0], ...
    [0 0 0 0], ...
    'b', ...
    'EdgeColor','k', ...
    'LineWidth',2);


%% =========================================================
% CAR LABEL
%% =========================================================

carLabel = text( ...
    x, ...
    y, ...
    'OUR CAR', ...
    'HorizontalAlignment','center', ...
    'FontWeight','bold');


%% =========================================================
% TRAJECTORY
%% =========================================================

trajectoryX = [];
trajectoryY = [];

trajectory = plot( ...
    NaN, ...
    NaN, ...
    'b--', ...
    'LineWidth',1.5);


%% =========================================================
% SENSOR GRAPHICS
%% =========================================================

frontSensor = plot( ...
    NaN,NaN, ...
    'r-', ...
    'LineWidth',2);

rearSensor = plot( ...
    NaN,NaN, ...
    'm-', ...
    'LineWidth',2);

leftSensor = plot( ...
    NaN,NaN, ...
    'c-', ...
    'LineWidth',2);

rightSensor = plot( ...
    NaN,NaN, ...
    'y-', ...
    'LineWidth',2);


%% =========================================================
% INFORMATION PANEL
%% =========================================================

info = text( ...
    1, ...
    14, ...
    '', ...
    'FontSize',10, ...
    'VerticalAlignment','top');


%% =========================================================
% PARKING STATUS
%% =========================================================

status = text( ...
    1, ...
    10, ...
    '', ...
    'FontSize',13, ...
    'FontWeight','bold');


%% =========================================================
% MAIN SIMULATION
%% =========================================================

for k = 1:length(time)


    %% =====================================================
    % SENSOR MODEL
    %% =====================================================

    frontDistance = env.y_max - y;

    rearDistance = y - env.y_min;

    leftDistance = x - env.x_min;

    rightDistance = env.x_max - x;


    %% =====================================================
    % OBSTACLE DISTANCES
    %% =====================================================

    obstacleLeft = ...
        obstacle.x - obstacle.width/2;

    obstacleRight = ...
        obstacle.x + obstacle.width/2;

    obstacleBottom = ...
        obstacle.y - obstacle.length/2;

    obstacleTop = ...
        obstacle.y + obstacle.length/2;


    %% FRONT OBSTACLE DETECTION

    if x >= obstacleLeft && ...
       x <= obstacleRight && ...
       obstacleBottom > y

        frontDistance = min( ...
            frontDistance, ...
            obstacleBottom-y);

    end


    %% REAR OBSTACLE DETECTION

    if x >= obstacleLeft && ...
       x <= obstacleRight && ...
       obstacleTop < y

        rearDistance = min( ...
            rearDistance, ...
            y-obstacleTop);

    end


    %% LEFT OBSTACLE DETECTION

    if y >= obstacleBottom && ...
       y <= obstacleTop && ...
       obstacleRight < x

        leftDistance = min( ...
            leftDistance, ...
            x-obstacleRight);

    end


    %% RIGHT OBSTACLE DETECTION

    if y >= obstacleBottom && ...
       y <= obstacleTop && ...
       obstacleLeft > x

        rightDistance = min( ...
            rightDistance, ...
            obstacleLeft-x);

    end


    %% =====================================================
    % SAFETY LIMIT
    %% =====================================================

    safeDistance = 0.6;

    minimumDistance = min([ ...
        frontDistance ...
        rearDistance ...
        leftDistance ...
        rightDistance]);


    %% =====================================================
    % EMERGENCY STOP
    %% =====================================================

    if minimumDistance < safeDistance && ...
       state ~= 4

        state = 5;

    end


    %% =====================================================
    % STATE 1 — APPROACH
    %% =====================================================

    if state == 1


        status.String = ...
            'STATE: APPROACHING PARKING SLOT';


        speed = 0.8;

        steering = 0;


        %% Drive to x = 17 m

        if x >= 17

            state = 2;

        end


    %% =====================================================
    % STATE 2 — 90 DEGREE TURN
    %% =====================================================

    elseif state == 2


        status.String = ...
            'STATE: ALIGNING / TURNING';


        %% Constant-radius left turn

        speed = 0.25;

        steering = ...
            atan(vehicle.wheelbase/turnRadius);


        %% Vehicle model

        x = x + ...
            speed*cos(theta)*dt;

        y = y + ...
            speed*sin(theta)*dt;

        theta = theta + ...
            (speed/vehicle.wheelbase)* ...
            tan(steering)*dt;


        %% Stop turning at approximately 90 degrees

        if theta >= pi/2

            theta = pi/2;

            state = 3;

        end


    %% =====================================================
    % STATE 3 — ENTER PARKING SLOT
    %% =====================================================

    elseif state == 3


        status.String = ...
            'STATE: ENTERING PARKING SLOT';


        speed = 0.4;

        steering = 0;


        %% Vehicle model

        x = x + ...
            speed*cos(theta)*dt;

        y = y + ...
            speed*sin(theta)*dt;


        %% Parking target reached

        if y >= slot.y

            state = 4;

        end


    %% =====================================================
    % STATE 4 — PARKED
    %% =====================================================

    elseif state == 4


        speed = 0;

        steering = 0;

        status.String = ...
            '✓ PARKING COMPLETE';


    %% =====================================================
    % STATE 5 — EMERGENCY STOP
    %% =====================================================

    elseif state == 5


        speed = 0;

        steering = 0;

        status.String = ...
            '⚠ EMERGENCY STOP - OBSTACLE DETECTED';

    end


    %% =====================================================
    % APPROACH VEHICLE MODEL
    %% =====================================================

    if state == 1

        x = x + ...
            speed*cos(theta)*dt;

        y = y + ...
            speed*sin(theta)*dt;

    end


    %% =====================================================
    % UPDATE TRAJECTORY
    %% =====================================================

    trajectoryX(end+1) = x;

    trajectoryY(end+1) = y;

    set( ...
        trajectory, ...
        'XData',trajectoryX, ...
        'YData',trajectoryY);


    %% =====================================================
    % CAR GEOMETRY
    %% =====================================================

    L = vehicle.length;

    W = vehicle.width;


    corners = [ ...
        L/2   W/2;
        L/2  -W/2;
       -L/2  -W/2;
       -L/2   W/2];


    %% Rotation matrix

    R = [ ...
        cos(theta) -sin(theta);
        sin(theta)  cos(theta)];


    rotatedCorners = ...
        (R*corners')';


    carX = rotatedCorners(:,1)+x;

    carY = rotatedCorners(:,2)+y;


    set( ...
        car, ...
        'XData',carX, ...
        'YData',carY);


    set( ...
        carLabel, ...
        'Position',[x y]);


    %% =====================================================
    % SENSOR RAYS
    %% =====================================================

    sensorLength = 5;


    %% Front

    set( ...
        frontSensor, ...
        'XData',[x ...
                 x+sensorLength*cos(theta)], ...
        'YData',[y ...
                 y+sensorLength*sin(theta)]);


    %% Rear

    set( ...
        rearSensor, ...
        'XData',[x ...
                 x-sensorLength*cos(theta)], ...
        'YData',[y ...
                 y-sensorLength*sin(theta)]);


    %% Left

    set( ...
        leftSensor, ...
        'XData',[x ...
                 x-sensorLength*sin(theta)], ...
        'YData',[y ...
                 y+sensorLength*cos(theta)]);


    %% Right

    set( ...
        rightSensor, ...
        'XData',[x ...
                 x+sensorLength*sin(theta)], ...
        'YData',[y ...
                 y-sensorLength*cos(theta)]);


    %% =====================================================
    % INFORMATION DISPLAY
    %% =====================================================

    stateNames = { ...
        'APPROACH', ...
        'TURN', ...
        'PARK', ...
        'PARKED', ...
        'EMERGENCY STOP'};


    info.String = sprintf( ...
        ['SYSTEM DATA\n\n' ...
         'State: %s\n\n' ...
         'X = %.2f m\n' ...
         'Y = %.2f m\n' ...
         'Heading = %.1f deg\n\n' ...
         'Front = %.2f m\n' ...
         'Rear  = %.2f m\n' ...
         'Left  = %.2f m\n' ...
         'Right = %.2f m\n\n' ...
         'Speed = %.2f m/s\n' ...
         'Steering = %.1f deg'], ...
         stateNames{state}, ...
         x, ...
         y, ...
         rad2deg(theta), ...
         frontDistance, ...
         rearDistance, ...
         leftDistance, ...
         rightDistance, ...
         speed, ...
         rad2deg(steering));


    %% =====================================================
    % PARKING VERIFICATION
    %% =====================================================

    if state == 4


        positionError = ...
            sqrt((x-slot.x)^2 + ...
                 (y-slot.y)^2);


        headingError = ...
            abs(rad2deg(theta-pi/2));


        %% Check if vehicle is safely parked

        if positionError < 0.3 && ...
           headingError < 5

            status.String = ...
                '✓ PARKING COMPLETE - VEHICLE SAFE';


        end

    end


    %% =====================================================
    % UPDATE FIGURE
    %% =====================================================

    drawnow;

    pause(0.01);


    %% Stop simulation after parking

    if state == 4

        pause(2);

        break;

    end


    %% Stop after emergency

    if state == 5

        pause(2);

        break;

    end

end


%% =========================================================
% FINAL RESULT
%% =========================================================

fprintf('\n');
fprintf('=============================================\n');
fprintf('       AUTONOMOUS PARKING RESULT\n');
fprintf('=============================================\n');

fprintf('Final X position  : %.2f m\n',x);
fprintf('Final Y position  : %.2f m\n',y);

fprintf('Final heading     : %.2f degrees\n', ...
    rad2deg(theta));

fprintf('Target X          : %.2f m\n',slot.x);
fprintf('Target Y          : %.2f m\n',slot.y);

fprintf('Position error    : %.2f m\n', ...
    sqrt((x-slot.x)^2 + (y-slot.y)^2));

fprintf('=============================================\n');