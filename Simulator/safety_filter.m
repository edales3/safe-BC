function inc = safety_filter(inc,ego,front,back,d_front,d_back)
% Set thresholds
thr_emer = 3.3;
thr_dist = 5.5;
thr_gap = 37;

% apply control only after the on-ramp
if ego(6)>550
    
    % emergency control --> abort merging
    if (d_front < thr_emer)
            inc(1) = - inc(1)/ (-(-d_front/(thr_dist+2) + 1) + 0.8);
            inc(1) = abs( inc(1) / (d_front/thr_emer));
            return
    end
    
    % if the gap is not wide enough --> pause merging 
    if ((front(6)-back(6)-front(9) < thr_gap)&front(12)>20) 
        if (ego(5)-back(5)-ego(10)/2-back(10)/2<3) | (ego(5)-front(5)-ego(10)/2-front(10)/2<3)
            inc(1) = 0;
            return
        end
    end
    
    % if too close to front car and aligned to it --> pause lateral
    % movement and slow down longitudinal one
    if ((front(6)-front(9)-ego(6)<0)&(ego(5)-front(5)-ego(10)/2-front(10)/2<3))
          if ego(5)-front(5)-ego(10)/2-front(10)/2<1.56
              inc(1) = -inc(1) / ((ego(5)-front(5)-ego(10)/2-front(10)/2)/(1.56));
          else
              inc = [0 inc(2)*0.83];
          end
          return
    % if too close to back car and aligned to it --> pause lateral
    % movement and speed up longitudinal one
    elseif ((ego(6)-ego(9)-back(6)<-1)&(ego(5)-back(5)-ego(10)/2-back(10)/2<3))
            if ego(5)-back(5)-ego(10)/2-back(10)/2<1.5
              inc(1) = -inc(1) / ((ego(5)-back(5)-ego(10)/2-back(10)/2)/(1.5));
            else
              inc = [0, inc(2)*1.17];
            end
            return
    end

    % if too close to back car but not aligned to it --> speed up
    if (d_back < thr_dist)
            inc(2) = inc(2) * (0.4*(-min(d_back)/thr_dist + 1) + 1.4);
    end

    % if too close to front car but not aligned to it --> slow down
    if (d_front < thr_dist+2)&(ego(5)-front(5)<4)
            inc(1) = inc(1) * (-(-min(d_front)/(thr_dist+2) + 1) + 0.8);
            if ego(5)<61.4
                inc(2) = inc(2) * (-(-min(d_front)/(thr_dist+2) + 1) + 0.8);
            end
    end
    
    % if already merged but getting to close to front cas --> slow down
    % longitudinal component
    if (d_front < thr_dist+6.5)
        if front(5) - ego(5) > 0.4       
            inc(2) = inc(2) * (-(-min(d_front)/(thr_dist+6.5) + 1) + 0.9);
        end
    end

end

end

