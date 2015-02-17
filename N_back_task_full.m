function N_back_task_full(s_number, dif_lvl, trials)

%this task presents the subject with visual stimuli one by one, and asks
%the subject to identify whether the stimulus is equivalent to the stimulus
%presented n steps before (n = 2,3,4,5)
string_s_number = num2str(s_number);
string_dif_lvl = num2str(dif_lvl);

%Here screen is opened just for changing the SyncTest preferences
Screen('Preferences', 'SkipSyncTests', 1); %forgo syncTests
Screen('Preference', 'VBLTimestampingMode', -1);

%retrieve the color vector
dif_lvl_str = num2str(dif_lvl);
color_inpt = cell(trials,1);
for i = 1:trials
    i_num = num2str(i);
fid = ['color_distributions\n_back_color_distributions_' dif_lvl_str '_' i_num '.txt'];
color_vector = fopen(fid,'rt');
for j = 1:3
    fgetl(color_vector);
end
[inpt_dta, inpt_cnt] = fscanf(color_vector, '%d',[4,inf]);
color_inpt{i,1} = transpose(inpt_dta);
end
% inpt_dta provides the input data

%retrieveing center-pixels for this screen // maybe this is redundant
%?????? No need to close screen again...?!

[m_win, myRect] = Screen('OpenWindow', 0);

%storing center-pixels
[c_x, c_y] = RectCenter(myRect);

%defining rectangle coordinates
c_sq = [0 0 0 0];
l_sq = c_x - 100;
r_sq = c_x + 100;
d_sq = c_y + 100;
u_sq = c_y - 100;

c_sq(1,1) = l_sq;
c_sq(1,2) = u_sq;
c_sq(1,3) = r_sq;
c_sq(1,4) = d_sq;

% define the relevant color and store them into rows of an array
yellow = [255 255 0];
magenta = [255 0 255];
cyan = [0 255 255];
red = [255 0 0];
green = [0 255 0];
blue = [0 0 255];
white = [255 255 255];

color_array = randn(7,3);

color_array(1, :) = yellow;
color_array(2, :) = magenta;
color_array(3, :) = cyan;
color_array(4, :) = red;
color_array(5, :) = green;
color_array(6, :) = blue;
color_array(7, :) = white;

% get the fixation cross on the screen 
Screen('FillRect', m_win, [0 0 0]);
DrawFormattedText(m_win, '+' ,'center', 'center', [255 255 255]);
Screen(m_win,'Flip');
HideCursor;
WaitSecs(3);

Screen('FillRect', m_win, [0 0 0]);
Screen(m_win, 'Flip');
WaitSecs(2);

%Open file and write layout for output file
f_name =['n_back_data\nback_' string_s_number '.txt'];
f_curr = fopen(f_name,'a+t');
fprintf(f_curr, '%53s \n\n', 'N-Back Task Data for one Subject and one Difficulty Level');
fprintf(f_curr, '%20s %3.0f\n','Subject_Number: ', s_number);
fprintf(f_curr, '%10s %10s %10s %10s %10s %10s \n','Level', 'Trial', 'Stimulus_Nr', 'Match' , 'Lure' , 'Correct');

%%DEFINING A TRIAL

% We randomize the difficulty levels 
dif_lvls = 2:dif_lvl;
random_positions = randperm(length(dif_lvls));
for i = 1:length(dif_lvls)
    temp(i) = dif_lvls(random_positions(i));
end

dif_lvls = temp;

for level = dif_lvls
    level_str = num2str(level);
    color_inpt = cell(trials,1);
for i = 1:trials
    i_num = num2str(i);
fid = ['color_distributions\n_back_color_distributions_' level_str '_' i_num '.txt'];
color_vector = fopen(fid,'rt');
for j = 1:3
    fgetl(color_vector);
end
[inpt_dta, inpt_cnt] = fscanf(color_vector, '%d',[4,inf]);
color_inpt{i,1} = transpose(inpt_dta);
end

begin_level_text = ['Beginning of Level: ' level_str];
    DrawFormattedText(m_win, begin_level_text ,'center', 'center', [255 255 255]);
    Screen(m_win, 'Flip');
    WaitSecs(3);
    Screen('FillRect', m_win, [0 0 0]);
    Screen(m_win, 'Flip');
    WaitSecs(2);
    
for trial = 1:trials
    %initialize relevant matrix from cells for current trial
    current_mat = color_inpt{trial,1};
    string_trial = num2str(trial);
    
    %start up screen to not overwhelm people
    begin_trial_text = ['Beginning of Trial: ' string_trial '\n \n' level_str '-Back' ];
    DrawFormattedText(m_win, begin_trial_text ,'center', 'center', [255 255 255]);
    Screen(m_win, 'Flip');
    WaitSecs(3);
    Screen('FillRect', m_win, [0 0 0]);
    Screen(m_win, 'Flip');
    WaitSecs(2);
    
for i = 1:(36+level)
%getting input data for the relevant stimulus nr from array filled from
%file above
stimulus_nr = current_mat(i,1);
color = current_mat(i,2);
match = current_mat(i,3);
lure = current_mat(i,4);

%initializing variables for each run in the for loop
answered = 0;

%writing the first three data points for the trial into the file
fprintf(f_curr, '%10.0f %10.0f %10.0f %10.0f %10.0f', level, trial, stimulus_nr, match , lure);

%Putting square on the screen
Screen('FillRect', m_win, [0 0 0]);
Screen('FillRect', m_win, color_array(color,:), c_sq);
Screen(m_win, 'Flip');

%while loop whithin which keyboard strokes are tested
start_time = GetSecs;
changed_to_black = 0;
while GetSecs <= (start_time + 2.5);
    
[keyIsDown,secs, key_pressed] = KbCheck;
%storing keyIsDown information into "answered" variable
if keyIsDown
    answered = 1;
end
    
if changed_to_black == 0 && GetSecs >= (start_time + 0.5)
Screen('FillRect', m_win, [0 0 0]);
Screen(m_win, 'Flip');
changed_to_black = 1;
end
end




% Get the six cases that can occur and write to file wether subject was right 
if answered == 1 && lure == 1 && match == 0
    correct = 0;
    fprintf(f_curr, '%10.0f \n', correct);
end
if answered == 1 && lure == 0 && match == 1
    correct = 1;
    fprintf(f_curr, '%10.0f \n', correct);
end
if answered == 1 && lure == 0 && match == 0
    correct = 0;
    fprintf(f_curr, '%10.0f \n', correct);
end
if answered == 0 && lure == 1 && match == 0
    correct = 1;
    fprintf(f_curr, '%10.0f \n', correct);
end
if answered == 0 && lure == 0 && match == 1
    correct = 0;
    fprintf(f_curr, '%10.0f \n', correct);
end
if answered == 0 && lure == 0 && match == 0
    correct = 1;
    fprintf(f_curr, '%10.0f \n', correct);
end
end
    
    end_trial_text = ['END of Trial: ' string_trial];
    DrawFormattedText(m_win, end_trial_text ,'center', 'center', [255 255 255]);
    Screen(m_win, 'Flip');
    WaitSecs(3);
    
    Screen('FillRect', m_win, [0 0 0]);
    Screen(m_win, 'Flip');
    WaitSecs(3);
    
    press_kb_text = 'Press any key if you are ready to continue';
    DrawFormattedText(m_win, press_kb_text ,'center', 'center', [255 255 255]);
    Screen(m_win, 'Flip');
    
    [secs, keycode] = KbWait([],2,[]);
    
end
%Message indicating end of difficulty level
end_text = ['END of difficulty Lvl: ' level_str];
DrawFormattedText(m_win, end_text ,'center', 'center', [255 255 255]);
Screen(m_win, 'Flip');
WaitSecs(3);
Screen('FillRect', m_win, [0 0 0]);
Screen(m_win, 'Flip');
WaitSecs(2);
%TEST END
end
finish_text = ['Thank you the task is finished!'];
DrawFormattedText(m_win, finish_text ,'center', 'center', [255 255 255]);
Screen(m_win, 'Flip');
WaitSecs(3);
Screen('CloseAll');
fclose('all');
end
%catch
     %closing the application in case of error during main task
%    ShowCursor;
%    Screen('CloseAll')
%    rethrow(ERR)
