clc
clear




% -------------------------------------- Outside The Loop -------------------------
%% User File Loc
%UserFileLoc='/Users/keanu/Dropbox (AIenergy)/ElectricVehicles/?ï¿½ï¿½?ï¿½ï¿½?ï¿½ï¿½?ï¿½ï¿½?ï¿½ï¿½?ï¿½ï¿½?ï¿½ï¿½?ï¿½ï¿½ ?ï¿½ï¿½?ï¿½ï¿½?ï¿½ï¿½?ï¿½ï¿½ ???ï¿½ï¿½?ï¿½ï¿½?ï¿½ï¿½?ï¿½ï¿½/Code Real/Data';
%UserFileLoc='/Users/keanu/Dropbox (AIenergy)/ElectricVehicles/?„‹?…²?„‹?…§?†«?„‰?…¥?†¼ ?„Œ?…µ?„‰?…® ???…¨?„‰?…¡?†«/Code Real/Data';
UserFileLoc='C:\Users\s_dragon0942\Desktop\flex\Data';


%% Internal file names
Para.Ren='FiveMinuteRenewable.xlsx';
Para.RestRen='RestRenewable.mat';
Para.Dem='Demand.xlsx';
Para.Gen='Generator.xlsx';   % 'GeneratorSimple.xlsx';
Para.TranLoss='TransmissionLoss.xlsx';
Para.MORDispatch='MOR_Dispatch.xlsx';
Para.TransLossWeight='TransLossDays.xlsx';
Para.UC='UC2018.xlsx';
Para.SI=5;



%% Get File Names
OriginalData=DataReader(Para,UserFileLoc);



%% Read Files
OriginalData.myDataRead();



%% Get averaged or weighted transmission loss data for each generator
OriginalData.myTranLossAverage();



%% Modify the generator Data
OriginalData.myGenDataModify();




%% UC Information Expansion
OriginalData.myUCexpansion();


% -------------------------------------- Outside The Loop -------------------------

















% -------------------------------------- Inside The Loop -------------------------
%% Simulation Conditions < Inside the Loop Simulation
Para.DispatchMethod='Stack';   % Stack, UC
Para.FlexCalcMethod='Stack';
Para.HZ=60;


Para.TargetYear=2018;


Para.SolarPenent=100;  % Percentage
Para.WindPenent=100;  % Percentage
Para.RestRenPenent=100;  % Percentage
Para.SolarSceGenMethod='Scale';
Para.WindSceGenMethod='Scale';
Para.RestRenSceGenMethod='Scale';
Para.CurtailMethod='PeakReductionPercent';%PeakReduction PeakReductionPercent RampReduction
Para.CurtailPercent=10;  % Percentage 
Para.Curtailramp = 2; %Mw/min
Para.CurMaxPeak = 3000; %MW

% System Option
Para.MarginalRampDetail=0;
Para.NofMarginal=1;
Para.MUTMDT=0;

% Reserve
Para.ReservePercent=10;
Para.UpRegAmount=0;
Para.DownRegAmount=0;



%% Net Load Generatio
NetLoadSet=NetLoadSampling(Para,OriginalData);



%%
NetLoadSet.myNetLoadSampling(Para);





%% Test
%NetLoadSet.NetLoadSet=NetLoadSet.NetLoadSet(1:10,:);
%NetLoadSet.NetLoadSet.NetLoad=randi([2000, 4000],size(NetLoadSet.NetLoadSet.NetLoad,1));




%% Test1
%% Prepare the flexibility calculation
Flexibility=FlexCal(OriginalData, NetLoadSet, Para);



%% Marginal + Flexibility
tic;
%[DownFlex, UpFlex]=Flexibility.myStackMargFlexCal();


% MUT MDT consideration
[DownFlex, UpFlex]=Flexibility.myUCMargFlexCal();

bb



%% Test2
[MarginalTable]=Flexibility.myStackMarginalCal();
[DownFlex2, UpFlex2]=Flexibility.OnOffFlexCal();


%% Add Battery
[FlexTable]=Flexibility.myBattFlexAdd();


%% Net Load Ramping Calculation
Flexibility.myNetLoadRampCal();

toc;



%% PFD Cal
[UpPFD, DownPFD] = Flexibility.myPFDCal();




%% IRRE Cal




bb















































%% By receiving user inputs, initiate the coding.
%Preprocess=Preprocessing(Dispatch, HZ, UserFileLoc, TargetYear, RegAmount, RenewPer);







bb




% 
% %% Simulation Case
% Case = readtable('SimulationCaseList.xlsx');
% 
% 
% 
% 
% %% Running
% for c=1:1:10
% 
% Result=FlexTest(Case, c);
% 
% end
% 


