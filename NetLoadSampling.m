classdef NetLoadSampling  < handle
        
    properties
        
        %% User Input
        % ---------------------------------------------
        SI
        HZ
        TargetYear
        % ---------------------------------------------
                
        
        
        %% Heritages
        % ---------------------------------------------------------------------------
        Demand
        Ren
        RestRen
        % ---------------------------------------------------------------------------
        
        
       
        
        %% Calculated Data
        % ---------------------------------------------------------------------------
        NetLoadSet
        % ---------------------------------------------------------------------------
        
    end
    
    
    
    methods
                
        %% File Name Reading
        % ---------------------------------------------------------------------------
        function obj = NetLoadSampling(Para,OriginalData)
            
            obj.SI=Para.SI;
            obj.HZ=Para.HZ;
            obj.TargetYear=Para.TargetYear;
            
            obj.Demand=OriginalData.Demand;
            obj.Ren=OriginalData.Ren;
            obj.RestRen=OriginalData.RestRen;
            
        end
        % ---------------------------------------------------------------------------
        
        
        
        
        
        
        
        %% Sample the net load
        % ---------------------------------------------------------------------------
        function obj=myNetLoadSampling(obj,Para)
                        
            % Demand scenario
            DemandScenario=myRenewDemandGen(obj);
            
            % Renewable energy scenarios                       
            RestRenScenario=myRestRenScenGen(obj,Para);
            
            % Generate wind power scenarios
            WindScenario=myWindScenGen(obj,Para);
            
            % Generate solar power scenarios
            SolarScenario=mySolarScenGen(obj,Para);
            
            %% Renewable Energy Curtailment
            RenScenario=WindScenario+SolarScenario+RestRenScenario;
            
            
            CultrailedRen=myCurtailment(obj,RenScenario,Para);
            
                      
            % Generate Net Load Set            
            obj.NetLoadSet=myTimeGen(obj);     % get time information            
            obj.NetLoadSet.DemandScenario=DemandScenario;
            obj.NetLoadSet.RenScenario=RenScenario;
            obj.NetLoadSet.CultrailedRen=CultrailedRen;
            obj.NetLoadSet.NetLoad=DemandScenario - RenScenario;
            obj.NetLoadSet.WindScenario=WindScenario;
            obj.NetLoadSet.SolarScenario=SolarScenario;
            obj.NetLoadSet.RestRenScenario=RestRenScenario;
            
        end
        % ---------------------------------------------------------------------------
        
        
        
        
        %% Curtail renewable energy
        % ---------------------------------------------
        function CultrailedRen = myCurtailment(obj,RenScenario,Para)
                        
            if strcmp(Para.CurtailMethod,'PeakReduction')
                L = length(RenScenario);
                CultrailedRen=RenScenario; 
                for i = 1:L
                    if RenScenario(i) > Para.CurMaxPeak
                        CultrailedRen(i) = Para.CurMaxPeak;
                    end
                end    
            elseif strcmp(Para.CurtailMethod,'PeakReductionPercent')
                L = length(RenScenario);
                CultrailedRen=RenScenario; 
                for i = 1:L
                    if RenScenario(i) > (1-0.01*Para.CurtailPercent)*max(RenScenario)
                        CultrailedRen(i) = (1-0.01*Para.CurtailPercent)*max(RenScenario);
                    end
                end 
            elseif strcmp(Para.CurtailMethod,'RampReduction')
                L = length(RenScenario);
                CultrailedRen=RenScenario;
                for i = 2:L
                    if RenScenario(i)-RenScenario(i-1)>Para.Curtailramp*5
                        CultrailedRen(i) = CultrailedRen(i-1)+Para.Curtailramp*5;
                    else
                        if CultrailedRen(i-1)<RenScenario(i-1)
                            if  RenScenario(i)<CultrailedRen(i-1)+Para.Curtailramp*5
                                CultrailedRen(i) = RenScenario(i);
                            else
                               CultrailedRen(i) = CultrailedRen(i-1)+Para.Curtailramp*5;  
                            end
                        else
                            CultrailedRen(i) =  RenScenario(i);
                        end
                    end
                        
                end
            end    
        end
        % ---------------------------------------------
        
        
        
        
        
        
        
        %% Generate demand scenarios
        % -------------------------------------------------------------------------------
        function DemandScenario=myRenewDemandGen(obj)
            
            % Interpolate demand at every 5 minutes                      
            Target=strcat('x',num2str(obj.TargetYear));
            SelectedDemand=obj.Demand(:,{Target});
            SingleRawDemand=interp(SelectedDemand{:,1} , 60/obj.SI );
            
            % Temporarily just the same
            DemandScenario=SingleRawDemand;
            
        end
        % -------------------------------------------------------------------------------
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        %% Generate solar scenarios
        % -------------------------------------------------------------------------------
        function SolarScenario=mySolarScenGen(obj,Para)
            % Input has already 5 minutes SI
            
            if strcmp(Para.SolarSceGenMethod,'Scale')
                
                SolarScenario=obj.Ren.Solar_power * Para.SolarPenent / 100;
                
            elseif strcmp(Para.SolarSceGenMethod,'PSD')
                
                SolarScenario=obj.Ren.solar_power;
            end
            
        end
        % -------------------------------------------------------------------------------
        
        
        
        
        
        
        
        %% Generate Wind scenarios
        % -------------------------------------------------------------------------------
        function WindScenario=myWindScenGen(obj,Para)
            % Input has already 5 minutes SI
            
            if strcmp(Para.WindSceGenMethod,'Scale')
                WindScenario=obj.Ren.Wind_power * Para.WindPenent / 100;
                
            elseif strcmp(Para.WindSceGenMethod,'PSD')
                WindScenario=obj.Ren.wind_power;
                
            end
            
        end
        % -------------------------------------------------------------------------------
        
        
        
        
        
        
        
        %% Interpolate rest renewable energy at every 5 minutes
        % ---------------------------------------------
        function SingleRawRestRen=myRestRenInterp(obj)
            
            SingleRawRestRen=interp(obj.RestRen, 60/obj.SI );
            
        end
        % ---------------------------------------------
        
        
        
        
        %% Generate Rest Renewable Energy scenarios
        % ---------------------------------------------
        function RestRenScenario=myRestRenScenGen(obj,Para)
            
            % Interpolate the rest renewable energy
            SingleRawRestRen=myRestRenInterp(obj);
            
            % Generate scenarios
            if strcmp(Para.RestRenSceGenMethod,'Scale')
                RestRenScenario=SingleRawRestRen * Para.RestRenPenent / 100;
                
            elseif strcmp(Para.RestRenSceGenMethod,'PSD')
                RestRenScenario=SingleRawRestRen;
                
            end
            
        end
        % ---------------------------------------------
        
        
        
        
        
        
        
        
        %% Generate Time Information
        % ---------------------------------------------
        function Time=myTimeGen(obj)
            
            Time=obj.Ren(:,{'Year','Month','Day','Minute'});
            
        end
        % ---------------------------------------------

        
        
        
        
    end
    
end






