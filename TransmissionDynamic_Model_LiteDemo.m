%% Transmission Dynamic Model - Lite Demo Version
% Version 1.3 STSPOON
%
% 'Zombie' virus simulator - Demo

close all; clear all; clc; format long e;

set(gcf,'units','normalized','position',[.1,.1,.8,.8]);
set(0,'defaultaxesfontsize',15);
set(0,'defaulttextfontsize',15);
set(0,'defaultlinelinewidth',3);

% Another slick way to control graphics (play with it).
fprintf('The room is 10x10 and there is a zombie in it!\n\n');
fprintf('Star = people; red square = zombie; green square = dead/recovered zombie.\n\n');
time = 0;

%% Input parameter for zombies and people.
number_of_people = ...
input('How many people are in the room (at least 1, try 200).\n');
speed_of_zombie = ...
input('The speed of zombie patient (at least 0.1, try 1).\n');
speed_of_people = ...
input('The speed of people (at least 0.1, try 1).\n');
infection_range = ...
input('The infection range of zombie virus (at least 0.1, try 1).\n');
recover_time = ...
input('The recovery time for this zombie virus [days] (at least 1, try 99).\n');
death_rate = ...
input('The death rate for this zombie virus [%] (at least 0.1, try 5).\n');
total_number_start=number_of_people+1; %input number of people plus first zombie.
zombies = [10*rand(1,2),time];
rotten_zombies = [];
recover_zombies = [];
number_of_zombies = 1;
number_of_recovered = 1;
number_of_death = 1;
people = zeros(number_of_people,2);
for i_people = 1:number_of_people
people(i_people,:) = 10*rand(1,2);
end

%% Make initial graph.
plot(people(:,1),people(:,2),'bp','markerfacecolor','b','markersize',12,'linewidth',1);
title(['Time = ',num2str(time),' days']);
hold on;
plot(zombies(:,1),zombies(:,2),'rs','markerfacecolor','r','markersize',14,'linewidth',1);
%whitebg([0,0,0]);
drawnow;
hold off;
clc;
fprintf('Go to the figure and press <space> to let the infection begin!\n\n');
pause();
clc;

%% Begin zombie machine.
stop = 'n';
safety_exit = 0;
infected = [];
while stop == 'n'
if safety_exit > 5
break;
end
safety_exit = safety_exit + 1;
time = time + 1;

for i_auto=1:10000
%% Make them walk a little.
people = people + speed_of_people*[0.1*rand(number_of_people,2)-.05];
zombies = zombies + [speed_of_zombie*[0.2*rand(number_of_zombies,2)-.1],[ones(number_of_zombies,1)]];
%% Make them stay in [0,10]x[0,10] by bouncing off walls.
for i_people = 1:number_of_people
if people(i_people,1) < 0
people(i_people,1) = -1*people(i_people,1);
elseif people(i_people,1) > 10
people(i_people,1) = 20 - people(i_people,1);
end
if people(i_people,2) < 0
people(i_people,2) = -1*people(i_people,2);
elseif people(i_people,2) > 10
people(i_people,2) = 20 - people(i_people,2);
end
end
for i_zombie = 1:number_of_zombies
if zombies(i_zombie,1) < 0
zombies(i_zombie,1) = -1*zombies(i_zombie,1);
elseif zombies(i_zombie,1) > 10
zombies(i_zombie,1) = 20 - zombies(i_zombie,1);
end
if zombies(i_zombie,2) < 0
zombies(i_zombie,2) = -1*zombies(i_zombie,2);
elseif zombies(i_zombie,2) > 10
zombies(i_zombie,2) = 20 - zombies(i_zombie,2);
end
end
%% Find who is too close to zombie.
for i_people = 1:number_of_people
for i_zombie = 1:number_of_zombies
if sqrt((people(i_people,1)-zombies(i_zombie,1)).^2 + (people(i_people,2)-zombies(i_zombie,2)).^2) < (infection_range * 0.6)
infected(end+1) = i_people;
break;
end
end
end

%% Change infected people from 'people' to 'zombies'.
if size(infected,2) > 0
infected = fliplr(infected);
for i_infected=1:size(infected,2)
zombies(end+1,:) = [[people(infected(i_infected),:)],[0]];
people(infected(i_infected),:) = [];
end
number_of_zombies = size(zombies,1);
number_of_people = size(people,1);
infected = [];
end

%% Change 'zombies' to 'rotten_zombies' if they are around too long.
for i_rotten=number_of_zombies:-1:1
if zombies(i_rotten,3) > recover_time
rotten_zombies(end+1,:) = zombies(i_rotten,1:2);
zombies(i_rotten,:) = [];
dead_rand = rand(1);
if dead_rand<=1-(death_rate/100)
    %recover_zombies(end+1,:) = zombies(i_rotten,1:2);
    number_of_recovered = number_of_recovered + 1;
else
    number_of_death = number_of_death + 1;
end
end
end
number_of_zombies = size(zombies,1);
%% Count Number of people, zombie and rotten zombie
alltime_number(time,1)=number_of_zombies;
alltime_number(time,2)=total_number_start-number_of_people-number_of_zombies-number_of_recovered;
alltime_number(time,3)=total_number_start-number_of_people-number_of_zombies-number_of_death;
alltime_number(time,4)=number_of_people;

%% Quit if no people left (not using now for recover/dead rate calculation).
if size(people,1) == 0
%disp(['Complete bloodbath in ',num2str(time),' days.']);
%figure(2)
%bar(alltime_number,'Stacked')
%xlabel('Time [days]')
%ylabel('Number of people')
%ylim([0 total_number_start])
%legend({'Active cases','Recovered/dead','Healthy people'},'Location','NorthWest')

%return;

end

%% Quit if no zombies left.
if size(zombies,1) == 0
disp(['People survive after ',num2str(time),' days!']);
figure(2)
bar(alltime_number,'Stacked','EdgeColor','none')
xlabel('Time [days]')
ylabel('Number of people')
ylim([0 total_number_start])
legend({'Active cases','Dead','Recovered','Healthy people'},'Location','NorthWest')

return;
end

%% Update graph of room.
time = time + 1;
plot(people(:,1),people(:,2),'bp','markerfacecolor','b','markersize',12,'linewidth',1);
%title(['Time = ',num2str(time),' days']);
if number_of_people > 0
hold on;
end
plot(zombies(:,1),zombies(:,2),'rs','markerfacecolor','r','markersize',14,'linewidth',1);
if size(rotten_zombies,1) > 0
hold on
plot(rotten_zombies(:,1),rotten_zombies(:,2),'x','Color',[0 0.7 0],'markerfacecolor',[0 0.7 0],'markersize',14,'linewidth',2);
end
%whitebg([0,0,0]);
title(['Time = ',num2str(time),' days']);
drawnow;
hold off;
pause(.001);
end
clc;
figure(2)
bar(alltime_number,'Stacked','EdgeColor','none')
xlabel('Time [days]')
ylabel('Number of people')
ylim([0 total_number_start])
legend({'Active cases','dead','Recovered','Healthy people'},'Location','NorthWest')

stop = input('Stop attack? (Y/n).\n','s');
end


