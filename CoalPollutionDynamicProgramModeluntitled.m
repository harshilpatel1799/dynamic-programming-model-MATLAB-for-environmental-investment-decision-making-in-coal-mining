%{ 
AUTHOR: Harshil Patel
This dynamic programming model is based on and solves the simplfied problem
statement and formumantion presented in "Survey of a Dynamic Programming
Model for Environmental Investment Decision-Making in Coal Mining".

%}
clear;
clc;
format long;
%% CHOOSE POLLUTANT TO DECIDE TREATMENT CAPACITY EXPANSION -> SOLVE DYNAMIC PROGRAMMING MODEL
% The pollutants will be defined by index j, where pollutant 
%j=1 for methane, j=2 for mine-water, j=3 for fly-ash and dust, j=4 SO2, j=5 for coal gangue. 
j = input('Enter Pollutant to solve (j=1 for methane,j=2 for mine-water, j=3 for fly-ash and dust, j=4 SO2, j=5 for coal gangue): ');

%% DECISION STAGES:
%The decision-making on investment in pollutant treatment capacity expansion has dynamic stages that the decisions, 
%and state variables are represented. The intervals of pollution treatment capacity expansion projects are on an annual basis, 
%which divides the stages by years. The investment timeline is considered over six years from 2016 to 2021, so 
%index t is represents a given stage for each given year, where:
t=[1 2 3 4 5 6];
stgCount=size(t,2);

%% STATE VARIABLES:
%State variable, Stj is the treatment capacity of pollutant j in metric tons at beginning of state t.
%State variable, Etj is the estimated pollution emissions of pollutant j in metric tons in state t.
%State variable, Pt is the penalty cost in USD ($) per metric tons of any pollutant j emission in metric tons at state t.
%Preallocate these state varaibles as arrays for each stage
St=zeros(size(t));
Et=zeros(size(t));
Pt=zeros(size(t));

%% PARAMETERS
%there are two parameters in consideration. 
% First: As the objective contrubution function value is being presented as,
% present value for each stage, the discount rate (r) is 6%.
r=0.045;

% Second: We need the project investment cost ($) per newly added treatment
% capacity by metric ton, (Ij) for each pollutant type for the objective
% contrubution function value. The data is presented in Table 1 within the
% report. 
Ij=[16492.98 7413.37 17989.78 11014.15 17326.10];
I=0;

if j == 1
    I=Ij(1); 
elseif j==2
    I=Ij(2);
elseif j==3
    I=Ij(3);
elseif j==4
    I=Ij(4);
elseif j==5
    I=Ij(5);
end

%% Decision at Every Stage & Contraints. 
%THE decision to be made at every stage is to determine the optimal exapnsion amount 
%of treatment capacity of pollutant j in metric tons-reprented by Xt. This a primary factor in the investment cost
%along with the purpose of keeping coal pollution j penalty costs to the minimum.
%Preallocate
Xt=zeros(size(t));

% BUT THE DECISION IS CONTRAINED IN EACH STAGE BY THE FOLLOWING: 
% (1) Reduction in capacity is not possible
% (2) to simply the model formuation, increase in treament capacity (Xt) can only be values of 0.05 in change model formuation,
% (3) Change in pollution treatment capacity (Xt) as to be less than 25% of current treatment capacity (St)

%Build out function that gives all feasible decisions at Stage t given variable St to simply backward reduction algorthim
%see function file feasibleDecisions.m

%% STATE TRANSITION FUNCTIONS
% S (t+1)= St + Xt
% St in stage 1 is predefined (see report)
S1j=[0.40 0.70 0.80 0.20 1.00];
if j == 1
    St(1)=S1j(1);
elseif j==2
    St(1)=S1j(2);
elseif j==3
    St(1)=S1j(3);
elseif j==4
    St(1)=S1j(4);
elseif j==5
    St(1)=S1j(5);
end
% E(t) and P(t) are based off Table 2 and Table 3 in the report and change
% depending on current stage and pollutant type
Etj=[0.47 0.63 0.76 0.85 0.9 1.05;1 1.4 1.8 2.2 2.9 3.5;1 1.2 1.4 1.55 1.65 1.78;0.3 0.41 0.5 0.63 0.75 0.88;1.4 1.75 2.1 2.45 2.7 2.9];
if j == 1
    Et=Etj(1,:);
elseif j==2
    Et=Etj(2,:);
elseif j==3
    Et=Etj(3,:);
elseif j==4
    Et=Etj(4,:);
elseif j==5
    Et=Etj(5,:);
end
Pt=[1412.09 2118.14 4236.27 6636.82 7766.50 9178.59];
%% OBJECTIVE VALUE CONTRIBUTION FUNCTION
% Dt(St,Pt,Et,r,I,Xt,t) = (LOt+PNt)/(1+r)^t
%see function file costFunction.m
%objective value contrubution for investment costs and penalty cost
investPlusPenaltyCost=zeros(stgCount,1)';
%% STORE BACKWARD RECURSION TABLEs
backwardRecursionTable=[];
%% BACKWARD RECURSION
for i = stgCount:-1:1 %STAGE
    currentStateStPossibleValues=possibleStateValues(St(1),i);
    XtSt=zeros(size(currentStateStPossibleValues,2),1)';
    VtSt=zeros(size(currentStateStPossibleValues,2),1)';
    for h = 1:size(currentStateStPossibleValues,2) %STATE VAR St
        currentState=currentStateStPossibleValues(h);
        feasibleDecisionsForCurrentStateSt=feasibleDecisions(currentState);
        cost=zeros(size(feasibleDecisionsForCurrentStateSt,2),1)';
        for k = 1:size(feasibleDecisionsForCurrentStateSt,2) %POSSIBLE FEASIBLE DECISIONS
            currentDecision=feasibleDecisionsForCurrentStateSt(k);
            if i==stgCount % FOR IF ON LAST STAGE
                cost(k)=costFunction(currentState,Pt(i),Et(i),r,I,currentDecision,i); %Objective-contribution computed 
            else % USE COST TO FUNCTION
                stateCost=costFunction(currentState,Pt(i),Et(i),r,I,currentDecision,i);
                newState1=currentState+currentDecision+0.01;
                newState2=currentState+currentDecision-0.01;
                nextStage=i+1;
                %DUE TO DATA TYPE STORGE WE HAVE INDEX ON APPROXIMATE VALUE
                costtogoIndex=find(nextStage==backwardRecursionTable(:,1) & newState1>backwardRecursionTable(:,2) & newState2<backwardRecursionTable(:,2));
                costtogoValue=backwardRecursionTable(costtogoIndex,4);
                cost(k)=stateCost+costtogoValue; %Cost-to-go determined and stored properly  
            end            
        end
        [VtSt(h),index]=min(cost); %STORE OPTIMAL OBJECTIVE VALUE FOR COST-TO-GO VALUE FOR EACH STAGE
        XtSt(h)=feasibleDecisionsForCurrentStateSt(index);
        row=[i currentState XtSt(h) VtSt(h)]; %Store into tables
        backwardRecursionTable=[backwardRecursionTable; row];
    end 
end

%% FORWARD RECURSION
for i=1:stgCount
    if i==1
        St(i)=St(1);
        objectiveFunctionValue=backwardRecursionTable(size(backwardRecursionTable,1),4);
        Xt(i)=backwardRecursionTable(size(backwardRecursionTable,1),3);
        investPlusPenaltyCost(i)=costFunction(St(i),Pt(i),Et(i),r,I,Xt(i),i);
    else
        St(i)=St(i-1)+Xt(i-1);
        st1=St(i)+0.01;st2=St(i)-0.01;
        %DUE TO DATA TYPE STORGE WE HAVE INDEX ON APPROXIMATE VALUE
        stateIndex=find(i==backwardRecursionTable(:,1) & st1>backwardRecursionTable(:,2) & st2<backwardRecursionTable(:,2));
        Xt(i)=backwardRecursionTable(stateIndex,3);
        investPlusPenaltyCost(i)=costFunction(St(i),Pt(i),Et(i),r,I,Xt(i),i);
    end
end
clc
%% OUTPUTS
%STAGE 7 BEGINNING POLLUTION J TREATMENT CAPACITY AFTER 6 YEARS
disp("STAGE 7/2022 BEGINNING POLLUTION J TREATMENT CAPACITY AFTER 6 YEARS: ");
disp(St(stgCount)+Xt(stgCount));
% TOTAL INVESTMENT PLUS PENALTY COST:
disp("TOTAL INVESTMENT PLUS PENALTY COST: $ ");
disp(objectiveFunctionValue);
% COSTS PER YEAR/STAGE IN USD ($)
disp("COSTS IN YEAR/STAGE IN USD ($): ");
disp(investPlusPenaltyCost);
% HOW MUCH TO INCRESE POLUTTION TREATMENT CAPACITY IN METRIC TONS PER YEAR/STAGE
disp("DECISION POLICY: HOW MUCH TO INCREASE POLLUTION TREATMENT CAPACITY IN METRIC TONS IN YEAR/STAGE t: ");
disp("units: metric ton");
disp(Xt);
