clc, clear all, close all

%Load data
load('traj_0750.mat')
load('merging_0750.mat')
trajectories = m;

% Define section limits (can be adjusted)
sectionLimits = [200 1400];

safe_dist = 0;

% Limits of x-y axis
xLimit = [sectionLimits(1)-5 sectionLimits(2)+5];
yLimit = [-170 250];

Frames = unique(trajectories(:,2));

%% 

collect_demo = [];
for i=1:length(Frames)
    
    %extract all the info about vehicles in that frame and in that area
    frameData = trajectories(trajectories(:,2)==Frames(i) & ...
        trajectories(:,6)>=sectionLimits(1) & ...
        trajectories(:,6)<=sectionLimits(2),:);
        
    if isempty(frameData)
       continue; 
    end

    % Get needed fields
    lateralPos = frameData(:,5);
    longitudePos = frameData(:,6);
    id = num2str(frameData(:,1));
    len = frameData(:,9);
    width = frameData(:,10);
    class = frameData(:,11);

    clear y
    %curr_merg = frameData(ismember(frameData(:,1),merging) & (frameData(:,5)==7 | frameData(:,14)==6),:);
    curr_merg = frameData(ismember(frameData(:,1),merging) & (frameData(:,5)>57.15),:);
    [num_merg, q] = size(curr_merg);
    
    % plot only when a merging is occurring
    if isempty(curr_merg)
        continue
    end

    % Collect info about yielding car
    if not(isempty(curr_merg))
        for c = 1:num_merg
            yield = frameData(frameData(:,6)>=curr_merg(c,6)-safe_dist & frameData(:,6)<=curr_merg(c,6) & frameData(:,14)==5,:);
            [long_pos,max_ind] = max(yield(:,6));
            y(c).id = yield(max_ind,1);
            y(c).pos = long_pos;
            y(c).vel = yield(max_ind,12);
            if isempty(yield)
                y(c).int = [];
            else
                y(c).int = intention_estimate(yield(max_ind,13));
            end
            if yield(max_ind,17) == 0
                y(c).frontgap = 1000;
            elseif isempty(yield)
                    y(c).frontgap = 1000;
            else
                y(c).frontgap = yield(max_ind,17);
            end
            class(frameData(:,1)==curr_merg(c,1)) = 5.5;
        end
    end
    
    % Construct vehicle bounding boxes
    boundingBoxArr = [longitudePos-len lateralPos-width/2 len width];

    % Set title
    title(strcat('NGSIM dataset simulation - frame: ', num2str(Frames(i))))
  
    % Plot road boundaries
    line(xLimit,[0 0],'Color','blue','LineStyle','-')
    line(xLimit,[13 13],'Color','black','LineStyle','-.')
    line(xLimit,[12*2 12*2],'Color','black','LineStyle','-.')
    line(xLimit,[12*3 12*3],'Color','black','LineStyle','-.')
    line(xLimit,[12*4 12*4],'Color','black','LineStyle','-.')
    line([470 sectionLimits(2)+5],[12*5 12*5],'Color','black','LineStyle','-.')
    line([sectionLimits(1)-5 540],[12*5 12*5],'Color','blue','LineStyle','-')
    line([370.5 540],[72+10-12 72-12 ],'Color','cyan','LineStyle','-')
    line([370.5 540],[72+10 72 ],'Color','cyan','LineStyle','-')
    line([540 sectionLimits(2)+5],[72 72],'Color','blue','LineStyle','-')
    line([1344.5 1344.5],[60 72],'Color','red','LineStyle','-','LineWidth',1)
    

    % Plot vehicle bounding boxes according to vehicle class
    % Red -> Motorcycle, Yellow-> Auto, Green-> Truck
    for j=1:length(boundingBoxArr(:,1))
        hold on
        if(class(j) == 1)
            rectangle('Position', boundingBoxArr(j,:), 'FaceColor', [1 0 0])
        elseif (class(j) == 2)
            rectangle('Position', boundingBoxArr(j,:), 'FaceColor', [1 1 0])
        elseif (class(j) == 5.5)
            rectangle('Position', boundingBoxArr(j,:), 'FaceColor', [0 1 1])
        else
            rectangle('Position', boundingBoxArr(j,:), 'FaceColor', [0 1 0])
        end
    end

    % Add vehicle id to each vehicle
    text(longitudePos-2*len/3,lateralPos,id, 'color', 'b', 'Margin', 0.1, 'FontSize',7, 'clipping','on')

    
    % Print infro about ego and yielding car
    if not(isempty(curr_merg))
         for c = 1:num_merg
            oly = trajectories((trajectories(:,1)==curr_merg(c,1) & trajectories(:,2)==Frames(i-1)),5:6);
            if isempty(oly)
                oly = [0, 0];
            end

            merg_stri = "EGO vehicle %d: %d\nPosition:%5.2f\nVelocity:%5.2f"; %\n Merged: %s
            merg_str = sprintf(merg_stri,c,curr_merg(c,1),curr_merg(c,6),curr_merg(c,12));  % ,yesorno);
            annotation('textbox',[c*0.21-0.08 0.18 0.5 0.2],'String',merg_str,'FitBoxToText','on')
            
            yield_stri = "YIELDING car %d: %d\nPosition:%5.2f\nVelocity:%5.2f\nIntention:%s\nFront gap:%5.2f";
            yield_str = sprintf(yield_stri,c,y(c).id,y(c).pos,y(c).vel,y(c).int,y(c).frontgap);
            annotation('textbox',[c*0.21-0.08 0.10 0.5 0.2],'String',yield_str,'FitBoxToText','on')
            
            collect_demo = [collect_demo; [y(c).frontgap, oly(1) - curr_merg(c,5), oly(2) - curr_merg(c,6)]];
         end
    end
    
    
    % Create custom legend for vehicle classes
    h = zeros(3, 1);
    h(1) = plot(NaN,NaN,'sr', 'MarkerFaceColor',[1,0,0]);
    h(2) = plot(NaN,NaN,'sy', 'MarkerFaceColor',[1,1,0]);
    h(3) = plot(NaN,NaN,'sg', 'MarkerFaceColor',[0,1,0]);
    lgd = legend(h, 'Motorcycle','Auto','Truck', 'Location','northeast');
    set(lgd,'FontSize',14)

    xlim(xLimit)
    ylim(yLimit)
    xlabel('Longitude (feet)')
    ylabel('Lateral (feet)')
    set(gca,'Ydir','reverse')
    grid on
    pause(0.0000001)
    %pause
    clf('reset')

end
    
function int = intention_estimate(acc)

    if acc >= -11.20 & acc <= -4.80
        int = 'hd'; %high deceleration
    
    elseif acc >= -4.79 & acc <= -0.60
        int = 'ld'; %low deceleration
        
    elseif acc >= -0.59 & acc <= 0.59
        int = 'c'; %constant speed
    
    elseif acc >= 0.60 & acc <= 4.79
        int = 'la'; %low acceleration
        
    elseif acc >= 4.80 & acc <= 11.20
        int = 'ha'; %high acceleration
    end 
end