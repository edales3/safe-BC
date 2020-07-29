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
forget=[];
curr_merg=[];
new_to_add=[];
figure()

for i=1:length(Frames)
    
    %extract all the info about vehicles in that frame and in that area
    frameData = trajectories(trajectories(:,2)==Frames(i) & ...
        trajectories(:,6)>=sectionLimits(1) & ...
        trajectories(:,6)<=sectionLimits(2),:);
        
        if isempty(frameData)
          continue; 
        end
        
        
    %save data about the actual human-driven car, that will be modified
    %in the dataset by the action of the controller.
    %It will be added again after calculation of controller action
    old_to_add = new_to_add;
    to_add=[];
    frame_next = trajectories(( trajectories(:,2)==Frames(i+1) & ...
    trajectories(:,6)>=sectionLimits(1) & ...
    trajectories(:,6)<=sectionLimits(2)),:);
    for o = 1:size(frame_next,1)
        if (ismember(frame_next(o,1),merging))
            to_add = [to_add; frame_next(o,:)];
        end
    end
    new_to_add = to_add;
        
    
    % Individuate merging vehicles
    new_curr_merg = frameData(ismember(frameData(:,1),merging) & (frameData(:,5)>57.15 & ~ismember(frameData(:,1),forget)),:);
    
    frameData_front = frameData;
    
    
    % Delete all the cars that already merged
    for k=1:size(curr_merg,1)
        if ~any(new_curr_merg(:,1)==curr_merg(k,1))
            forget = [forget, curr_merg(k,1)];
        end
    end
    to_delete=[];
    del_front=[];
    for h=1:size(frameData,1)
        if any(forget==frameData(h,1))
            to_delete = [to_delete, h];
        end
        if any(merging == frameData(h,1))
            del_front = [del_front, h];
        end
    end
    
    if length(to_delete)>0
        frameData(to_delete,:)=[];
    end
    
    curr_merg = new_curr_merg;
    [num_merg, q] = size(curr_merg);
    
    % Plot only if a merging is happening
    if isempty(curr_merg)
        continue
    end

    if not(isempty(curr_merg))
        for c = 1:num_merg
            
            %Individuate back and front car
            back = frameData_front((frameData_front(:,6)<=curr_merg(c,6) &...
                frameData_front(:,5)>49 & frameData_front(:,5)<59 & ...
                frameData_front(:,1)~=curr_merg(c,1)),:);
            [long_pos,max_ind] = max(back(:,6));
            
            front = frameData_front((frameData_front(:,6)>=curr_merg(c,6) & frameData_front(:,5)>49 ...
                & frameData_front(:,5)<59 & frameData_front(:,1)~=curr_merg(c,1)),:);
            [null,min_ind] = min(front(:,6));
            
            % generate artificial front and back car to cover
            % cases at the beginning and end of the recordings
            if length(front)<1
                min_ind = 1;
                front = [0 0 0 0 55 1500 0 0 17 7 0 40 0 0 0 0 0 0];
            end
            if length(back)<1
                max_ind = 1;
                back = [0 0 0 0 55 200 0 0 17 7 0 40 0 0 0 0 0 0];
            end
            
            %Get controller output 
            inc = get_disp(curr_merg(c,:),back(max_ind,:),front(min_ind,:));
            lat_inc=inc(1);
            long_inc=inc(2);
            
            % Get position at previous step
            old_pos = frameData((frameData(:,1)==curr_merg(c,1)),5:6);
            
            % Set color to blue
            frameData(frameData(:,1)==curr_merg(c,1),11) = 5.5;
            
            % Apply control action
            if trajectories((trajectories(:,1)==curr_merg(c,1) & trajectories(:,2)==Frames(i+1)),5:6)            
              trajectories((trajectories(:,1)==curr_merg(c,1) & trajectories(:,2)==Frames(i+1)),5:6)=[old_pos(1) + lat_inc, old_pos(2) + long_inc];
            end
        end
    end
    
    % Add data about the actual human-driven car, to plot its shadow
    if size(old_to_add,1)>0
        old_to_add(:,11)=100;
        frameData = [frameData; old_to_add];
    end
    
    % Get needed fields
    lateralPos = frameData(:,5);
    longitudePos = frameData(:,6);
    id = num2str(frameData(:,1));
    len = frameData(:,9);
    width = frameData(:,10);
    class = frameData(:,11);
    
    % Construct vehicle bounding boxes
    boundingBoxArr = [longitudePos-len lateralPos-width/2 len width];

    % Set title
    title(strcat('Controller simulation - frame: ', num2str(Frames(i))))
  
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
    

    % Plot vehicle colors
    % Yellow -> Regular, Blue -> merging, Light blue -> shadow of the real car
    for j=1:length(boundingBoxArr(:,1))
        hold on
        if (class(j) == 5.5)
            rectangle('Position', boundingBoxArr(j,:), 'FaceColor', [0 0.6 1])
        elseif (class(j) == 100)
            rectangle('Position', boundingBoxArr(j,:), 'FaceColor', [0 1 1,0.4], 'EdgeColor',[0 0 0,0.6])
        else
            rectangle('Position', boundingBoxArr(j,:), 'FaceColor', [1 1 0])
        end
    end

    % Add vehicle id to each vehicle
    %text(longitudePos-2*len/3,lateralPos,id, 'color', 'b', 'Margin', 0.1, 'FontSize',7, 'clipping','on')

    xlim(xLimit)
    ylim(yLimit)
    xlabel('Longitude (feet)')
    ylabel('Lateral (feet)')
    set(gca,'Ydir','reverse')
    %grid on
    
    pause(0.000000001)
    %pause
    clf('reset')

end