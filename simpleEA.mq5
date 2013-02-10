//+------------------------------------------------------------------+
//|                                                     simpleEA.mq5 |
//|                                         Copyright © 2012, tijo45 |
//|                                                 tijo45@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, tijo45"
#property link      "tijo45@gmail.com"
#property version   "1.00"
#include <Trade\Trade.mqh>
#include <Expert\Trailing\TrailingFixedPips.mqh>
#define              N           5            // number of bars for calculation of the average bar size

CTrade trX;
CTrailingFixedPips fixed;
//---
input int inputStopLoss=0,inputTakeProfit=0;
double lot;
input string n1="Settings Stohactic";
input int K=8,D=3,S=3;
int digits;
input string n2="Settings MA's";
input int fastPeriod=5,slowPeriod=8;
input string n3="Settings Momentum";
input int period=10;
input string n4="Settings QQE Alert v3";
input int                  InpSF=50;                         // Smoothing Factor
input int                  InpAlertLevel=50;                // Alert level
input ENUM_APPLIED_PRICE   InpAppliedPrice=PRICE_CLOSE;     // Applied price
input int            TP     =10;
input int            SL     =10;
//---
int handleFastMovingAverage,handleSlowMovingAverage,heikenAshi,handleMomentum,handleAlert,handleStochastic,handleADX; // handles for indicators
int hourStoch;
//---
int OnInit()
  {
  
   handleFastMovingAverage=iMA(_Symbol,PERIOD_CURRENT,fastPeriod,0,MODE_EMA,PRICE_CLOSE); // record of handles
   handleSlowMovingAverage=iMA(_Symbol,PERIOD_CURRENT,slowPeriod,0,MODE_EMA,PRICE_OPEN);// record of handles
   heikenAshi=iCustom(_Symbol,PERIOD_H1,"Heiken_Ashi");// record of handles
   handleMomentum=iMomentum(_Symbol,PERIOD_CURRENT,period,PRICE_CLOSE);// record of handles
   handleAlert=iCustom(_Symbol,PERIOD_CURRENT,"QQE_Alert_v3",InpSF,InpAlertLevel,InpAppliedPrice);// record of handles
   handleStochastic=iStochastic(_Symbol,PERIOD_CURRENT,K,D,S,MODE_SMA,STO_LOWHIGH);// record of handles
   handleADX=iADX(_Symbol,PERIOD_H1,14);// record of handles
   
   return(0);
  }
//---
void OnTick()
  {
   lot = NormalizeDouble(((AccountInfoDouble(ACCOUNT_BALANCE) + AccountInfoDouble(ACCOUNT_PROFIT)) * .02)/100,1); // figure out lot size
   static int checkOpenCondition,checkCloseCondition,bar,bar2, trend = trend();
   MqlTick currentTick;
   SymbolInfoTick(_Symbol,currentTick);
   if(bar!=Bars(_Symbol,PERIOD_CURRENT)) // Verification of the conditions for the opening and closing goes 1 time in every bar
     {
      bar=Bars(_Symbol,PERIOD_CURRENT);
      checkOpenCondition=checkOpenCondition();checkCloseCondition=checkCloseCondition(); trend = trend();// check conditions
     }
   if(PositionSelect(_Symbol))
     {
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         if(checkCloseCondition==1 && trend==1){trX.PositionClose(_Symbol);} // if open buy and close buy conditions is, close buy

        }
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         if(checkCloseCondition==2 && trend==2){trX.PositionClose(_Symbol);}// if open sell and close sell conditions is, close sell

        }
     }
   else
     {
      if(bar2!=Bars(_Symbol,PERIOD_CURRENT))  // if no positions
        {
         if(checkOpenCondition==2 && trend == 2 ){buy();bar2=Bars(_Symbol,PERIOD_CURRENT);} // if is conditions for buy, open buy
         if(checkOpenCondition==1 && trend == 1 ){sell();bar2=Bars(_Symbol,PERIOD_CURRENT);}// if is conditions for sell, open sell

        }
     }
     
       //TrailingTake();
       //TrailingStop();
     
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void buy() // general description of the functions to open buy
  {
   int x=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   double SL=0,TP=0; bool sss=0,bbb=0;
   MqlTick currentTick;
   SymbolInfoTick(_Symbol,currentTick);
   if(inputStopLoss<=0)SL=0;else{if(inputStopLoss<x){SL=currentTick.bid-x*_Point;}else{SL=currentTick.bid-inputStopLoss*_Point;}}
   if(inputTakeProfit<=0)TP=0;else{if(inputTakeProfit<x){TP=currentTick.bid+x*_Point;}else{TP=currentTick.bid+inputTakeProfit*_Point;}}
   trX.PositionOpen(_Symbol,ORDER_TYPE_BUY,lot,NormalizeDouble(currentTick.ask,_Digits),0,0);
   if(SL>0 || TP>0)
     {
      Sleep(2000);
      while(true)
        {
         bbb=0;sss=0;
         if(PositionSelect(_Symbol))
           {
            Sleep(200);
            if(PositionGetDouble(POSITION_SL)==0&&SL>0){trX.PositionModify(_Symbol,NormalizeDouble(SL,_Digits),PositionGetDouble(POSITION_TP));SL-=10*_Point;continue;}
            if(PositionGetDouble(POSITION_TP)==0&&TP>0){trX.PositionModify(_Symbol,PositionGetDouble(POSITION_SL),NormalizeDouble(TP,_Digits));TP+=10*_Point;continue;}
            if(PositionGetDouble(POSITION_SL)>0||SL==0)sss=1;
            if(PositionGetDouble(POSITION_TP)>0||TP==0)bbb=1;
            if(bbb && sss)return;

           }
         else return;
        }

     }
  }
//----
void sell()// general description of the functions to open sell
  {
   bool bbb=0,sss=0;
   int x=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);

   double SL=0,TP=0;
   MqlTick currentTick;
   SymbolInfoTick(_Symbol,currentTick);
   if(inputStopLoss<=0)SL=0;else{if(inputStopLoss<x){SL=currentTick.ask+x*_Point;}else{SL=currentTick.ask+inputStopLoss*_Point;}}
   if(inputTakeProfit<=0)TP=0;else{if(inputTakeProfit<x){TP=currentTick.ask-x*_Point;}else{TP=currentTick.ask-inputTakeProfit*_Point;}}
   trX.PositionOpen(_Symbol,ORDER_TYPE_SELL,lot,NormalizeDouble(currentTick.bid,_Digits),0,0);
   if(SL>0 || TP>0)
     {
      Sleep(2000);
      while(true)
        {
         bbb=0;sss=0;
         if(PositionSelect(_Symbol))
           {
            Sleep(200);
            if(PositionGetDouble(POSITION_SL)==0&&SL>0){trX.PositionModify(_Symbol,NormalizeDouble(SL,_Digits),PositionGetDouble(POSITION_TP));SL+=10*_Point;continue;}
            if(PositionGetDouble(POSITION_TP)==0&&TP>0){trX.PositionModify(_Symbol,PositionGetDouble(POSITION_SL),NormalizeDouble(TP,_Digits));TP-=10*_Point;continue;}
            if(PositionGetDouble(POSITION_SL)>0||SL==0)sss=1;
            if(PositionGetDouble(POSITION_TP)>0||TP==0)bbb=1;
            if(bbb && sss)return;

           }
         else return;
        }

     }
  }
  
  
//-- Check condition of trend
int trend()
{
double adx[4], adx_min[4], adx_plus[4]; 
ArraySetAsSeries(adx, true); 
ArraySetAsSeries(adx_min, true);
ArraySetAsSeries(adx_plus, true);

CopyBuffer(handleADX,0,1,4,adx);
CopyBuffer(handleADX,2,1,4,adx_min);
CopyBuffer(handleADX,1,1,4,adx_plus);

Print("ADX1: " + adx[0]);
Print("adx_min: " + adx_min[0]);
Print("adx_plus: " + adx_plus[0]);


//if(adx[0] < 30) return 1;
if(adx_min[0] < adx_plus[0] && adx[0] < 30) return 2;
if(adx_min[0] > adx_plus[0] && adx[0] < 30) return 1;

return 0;

}  
//---


//2 is buy
//1 is sell
int checkOpenCondition()
  {
double mm[2],stm[1],sts[1],fastMovingAverage[1],slowMovingAverage[1]; 
CopyBuffer(handleMomentum,0,1,2,mm);
CopyBuffer(handleStochastic,0,1,1,stm);
CopyBuffer(handleStochastic,1,1,1,sts);
CopyBuffer(handleFastMovingAverage,0,1,1,fastMovingAverage);
CopyBuffer(handleSlowMovingAverage,0,1,1,slowMovingAverage);
int alertSignal=alertSignal();
 printf("mm[0]>" + mm[0]);
 printf("mm[1]>" + mm[1]); 
  if(heikenAshi()==2 && fastMovingAverage[0]>slowMovingAverage[0] && alertSignal==2 && stm[0]<30 )return(2);
  if(heikenAshi()==1 && fastMovingAverage[0]<slowMovingAverage[0] && alertSignal==1 && stm[0]>60 )return(1);
   return(0);
  }
  
  
  
int checkCloseCondition()
{
int alertSignal=alertSignal(); 
double fastMovingAverage[1],slowMovingAverage[1];
int trend = trend();
int heikenAshi = heikenAshi();
CopyBuffer(handleFastMovingAverage,0,1,1,fastMovingAverage);
CopyBuffer(handleSlowMovingAverage,0,1,1,slowMovingAverage);

   if(fastMovingAverage[0]<slowMovingAverage[0] && heikenAshi == 2 && trend == 2)return(1);
   if(fastMovingAverage[0]>slowMovingAverage[0] && heikenAshi == 1 && trend == 1)return(2);
return(0);
}


//---
int heikenAshi() // this func define color H-ASHI
{
 double red11[3],whi11[3];
 CopyBuffer(heikenAshi,0,1,3,red11);
 CopyBuffer(heikenAshi,3,1,3,whi11);

      
    if(red11[0]>whi11[0])
          return(1);
    if(red11[0]<whi11[0])
          return(2);
   return(0);
}
//---
int alertSignal() // denide signal for QQE Alert v3
{
double up[],dw[];
ArraySetAsSeries(up,1);ArraySetAsSeries(dw,1);
CopyBuffer(handleAlert,0,1,500,up);
CopyBuffer(handleAlert,1,1,500,dw);
for(int i=0;i<500;i++)
  {
  if(up[i]!=0&&up[i]!=EMPTY_VALUE)return(2); // buy
  if(dw[i]!=0&&dw[i]!=EMPTY_VALUE)return(1); // sell
  }
 return(0);
}
//---

//+------------------------------------------------------------------+
//| TrailingStop - moves the take profit                             |
//+------------------------------------------------------------------+
void TrailingTake()
  {
   double ArrayHigh[N];
   double ArrayLow[N];
   CopyHigh(Symbol(),Period(),0,N,ArrayHigh);
   CopyLow(Symbol(),Period(),0,N,ArrayLow);
   double LastHeight=0; //ArrayHigh[0]-ArrayLow[0];
   double LastPrice=SymbolInfoDouble(Symbol(),SYMBOL_LAST);
   for(int i=0; i<N; i++) LastHeight=LastHeight+ArrayHigh[i]-ArrayLow[i];
   LastHeight=LastHeight/N;

   if(PositionSelect(Symbol()))
     {
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         if(MathAbs(-LastPrice+PositionGetDouble(POSITION_TP))>LastHeight*TP/100*1.01)
           {
            //--- preparing a request
            MqlTradeRequest request;
            ZeroMemory(request);
            //--- placing an immediate order
            request.action=TRADE_ACTION_SLTP;
            //--- instrument
            request.symbol=Symbol();
            //--- Stop Loss is not specified
            request.sl= PositionGetDouble(POSITION_SL);
            Print("new TAKE PROFIT" + NormalizeDouble(LastPrice+LastHeight*TP/100,_Digits));
            Print("new LastPrice" + LastPrice);
            
            request.tp=NormalizeDouble(LastPrice+LastHeight*TP/100,_Digits);

            MqlTradeResult result;
            ZeroMemory(result);
            MqlTradeCheckResult CheckResult;
            //--- sending the order
            if(OrderCheck(request,CheckResult)) {OrderSend(request,result);}
            //--- printing the server response to the log  
            else
              {
               Print(CheckResult.retcode,"  -error ");
               Print(__FUNCTION__,":",CheckResult.comment);
              };
           }
        };
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
         if(MathAbs(-PositionGetDouble(POSITION_TP)+LastPrice)>LastHeight*TP/100*1.01)
           {
            //--- preparing a request
            MqlTradeRequest request;
            ZeroMemory(request);
            //--- placing an immediate order
            request.action=TRADE_ACTION_SLTP;
            //--- instrument
            request.symbol=Symbol();
            //--- Stop Loss is not specified
            request.sl= PositionGetDouble(POSITION_SL);
            Print("new TAKE PROFIT" + NormalizeDouble(LastPrice-LastHeight*TP/100,_Digits));
            Print("new LastPrice" + LastPrice);
            
            request.tp=NormalizeDouble(LastPrice-LastHeight*TP/100,_Digits);

            MqlTradeResult result;
            ZeroMemory(result);
            MqlTradeCheckResult CheckResult;
            //--- sending the order
            if(OrderCheck(request,CheckResult)) {OrderSend(request,result);}
            //--- printing the server response to the log  
            else
              {
               Print(CheckResult.retcode,"  -error ");
               Print(__FUNCTION__,":",CheckResult.comment);
              };
           }
     }
   return;
  }
  
  void TrailingStop()
  {
   double ArrayHigh[N];
   double ArrayLow[N];
   CopyHigh(Symbol(),Period(),0,N,ArrayHigh);
   CopyLow(Symbol(),Period(),0,N,ArrayLow);
   double LastHeight=0;
   double LastPrice=SymbolInfoDouble(Symbol(),SYMBOL_LAST);
   for(int i=0; i<N; i++) LastHeight=LastHeight+ArrayHigh[i]-ArrayLow[i];
//--- calculating the average size of the last N bars
   LastHeight=LastHeight/N;

   if(PositionSelect(Symbol()))
     {
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         if(MathAbs(LastPrice-PositionGetDouble(POSITION_SL))>LastHeight*SL/100*1.01)
           {
            //--- preparing a request
            MqlTradeRequest request;
            ZeroMemory(request);
            //--- placing an immediate order
            request.action=TRADE_ACTION_SLTP;
            //--- instrument
            request.symbol=Symbol();
            //--- Stop Loss
            Print("new STOP LOSS" + NormalizeDouble(LastPrice-LastHeight*SL/100,_Digits));
            Print("new LastPrice" + LastPrice);
             
            request.sl=NormalizeDouble(LastPrice-LastHeight,_Digits);
            //--- Take Profit is not specified
            request.tp=PositionGetDouble(POSITION_TP);

            MqlTradeResult result;
            ZeroMemory(result);
            MqlTradeCheckResult CheckResult;
            //--- sending the order
            if(OrderCheck(request,CheckResult)) {OrderSend(request,result);}
            else
              {
               //--- printing the server response to the log  
               Print(CheckResult.retcode,"  -error ");
               Print(request.sl,"  ",LastPrice,"  buy  ",LastHeight);
               Print(__FUNCTION__,":",CheckResult.comment);
              };
           }
        };
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
         if(MathAbs(PositionGetDouble(POSITION_SL)-LastPrice)>LastHeight*SL/100*1.01)
           {
            //--- preparing a request
            MqlTradeRequest request;
            ZeroMemory(request);
            //--- placing an immediate order
            request.action=TRADE_ACTION_SLTP;
            //--- instrument
            request.symbol=Symbol();
            //--- Stop Loss
            Print("new STOP LOSS" + NormalizeDouble(LastPrice+LastHeight*SL/100,_Digits));
            Print("new LastPrice" + LastPrice);
            request.sl=NormalizeDouble(LastPrice+LastHeight/100,_Digits);
            //--- Take Profit is not specified
            request.tp= PositionGetDouble(POSITION_TP);

            MqlTradeResult result;
            ZeroMemory(result);
            MqlTradeCheckResult CheckResult;
            //--- sending the order
            if(OrderCheck(request,CheckResult)) {OrderSend(request,result);}
            else
              {
               //--- printing the server response to the log  
               Print(CheckResult.retcode,"  -error ");
               Print(request.sl,"  ",LastPrice,"  sell  ",LastHeight);
               Print(__FUNCTION__,":",CheckResult.comment);
              };
           }
     }
   return;
  }

