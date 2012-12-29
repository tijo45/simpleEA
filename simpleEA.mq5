//+------------------------------------------------------------------+
//|                                                     simpleEA.mq5 |
//|                                       Copyright © 2012, _Techno_ |
//|                                            niko@pingwin.uvttk.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, _Techno_"
#property link      "niko@pingwin.uvttk.ru"
#property version   "1.00"
#include <Trade\Trade.mqh>
#include <Expert\Trailing\TrailingFixedPips.mqh>
#define              N           5            // number of bars for calculation of the average bar size

CTrade trX;
CTrailingFixedPips fixed;
//---
input int Sl=0,Tp=0;
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
input int            TP     =500;
input int            SL     =500;
//---
int hfma,hsma,ha,hm,hqq,hst; // handles for indicators
int hourStoch;
//---
int OnInit()
  {
  
   hfma=iMA(_Symbol,PERIOD_CURRENT,fastPeriod,0,MODE_EMA,PRICE_CLOSE); // record of handles
   hsma=iMA(_Symbol,PERIOD_CURRENT,slowPeriod,0,MODE_EMA,PRICE_OPEN);// record of handles
   ha=iCustom(_Symbol,PERIOD_CURRENT,"Heiken_Ashi");// record of handles
   hm=iMomentum(_Symbol,PERIOD_CURRENT,period,PRICE_CLOSE);// record of handles
   hqq=iCustom(_Symbol,PERIOD_CURRENT,"QQE_Alert_v3",InpSF,InpAlertLevel,InpAppliedPrice);// record of handles
   hst=iStochastic(_Symbol,PERIOD_CURRENT,K,D,S,MODE_SMA,STO_LOWHIGH);// record of handles
   hourStoch=iStochastic(_Symbol,PERIOD_CURRENT,K,D,S,MODE_SMA,STO_LOWHIGH);// record of handles\
   hqq=iCustom(_Symbol,PERIOD_CURRENT,"QQE_Alert_v3",InpSF,InpAlertLevel,InpAppliedPrice);// record of handles
   return(0);
  }
//---
void OnTick()
  {
   lot = NormalizeDouble(((AccountInfoDouble(ACCOUNT_BALANCE) + AccountInfoDouble(ACCOUNT_PROFIT)) * .02)/100,1);
   static int ss,cc,bar,bar2;
   MqlTick qq;
   SymbolInfoTick(_Symbol,qq);
   if(bar!=Bars(_Symbol,PERIOD_CURRENT)) // Verification of the conditions for the opening and closing goes 1 time in every bar
     {
      bar=Bars(_Symbol,PERIOD_CURRENT);
      ss=ss();cc=cc(); // check conditions
     }
   if(PositionSelect(_Symbol))
     {
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         if(cc==1){trX.PositionClose(_Symbol);} // if open buy and close buy conditions is, close buy

        }
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         if(cc==2){trX.PositionClose(_Symbol);}// if open sell and close sell conditions is, close sell

        }
     }
   else
     {
      if(bar2!=Bars(_Symbol,PERIOD_CURRENT))  // if no positions
        {
         if(ss==2){buy();bar2=Bars(_Symbol,PERIOD_CURRENT);} // if is conditions for buy, open buy
         if(ss==1){sell();bar2=Bars(_Symbol,PERIOD_CURRENT);}// if is conditions for sell, open sell

        }
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void buy() // general description of the functions to open buy
  {
   int x=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   double SL=0,TP=0; bool sss=0,bbb=0;
   MqlTick qq;
   SymbolInfoTick(_Symbol,qq);
   if(Sl<=0)SL=0;else{if(Sl<x){SL=qq.bid-x*_Point;}else{SL=qq.bid-Sl*_Point;}}
   if(Tp<=0)TP=0;else{if(Tp<x){TP=qq.bid+x*_Point;}else{TP=qq.bid+Tp*_Point;}}
   trX.PositionOpen(_Symbol,ORDER_TYPE_BUY,lot,NormalizeDouble(qq.ask,_Digits),0,0);
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
   MqlTick qq;
   SymbolInfoTick(_Symbol,qq);
   if(Sl<=0)SL=0;else{if(Sl<x){SL=qq.ask+x*_Point;}else{SL=qq.ask+Sl*_Point;}}
   if(Tp<=0)TP=0;else{if(Tp<x){TP=qq.ask-x*_Point;}else{TP=qq.ask-Tp*_Point;}}
   trX.PositionOpen(_Symbol,ORDER_TYPE_SELL,lot,NormalizeDouble(qq.bid,_Digits),0,0);
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
//---
int ss() //// general description of the signal
  {
double mm[3],stm[3],sts[3],fma1[3],sma1[3]; 
CopyBuffer(hm,0,1,3,mm);
CopyBuffer(hst,0,1,3,stm);
CopyBuffer(hst,1,1,3,sts);
CopyBuffer(hfma,0,1,3,fma1);
CopyBuffer(hsma,0,1,3,sma1);
int qq=qq();
  if(ha()==2&&fma1[0]>sma1[0]&&mm[0]>100&&qq==2&&stm[0]>sts[0])
    if(ha()==2&&fma1[1]>sma1[1]&&mm[1]>100&&qq==2&&stm[1]>sts[1])
      if(ha()==2&&fma1[2]>sma1[2]&&mm[2]>100&&qq==2&&stm[2]>sts[2])  
        return(2); // signal BUY
  
  
  if(ha()==1&&fma1[0]<sma1[0]&&mm[0]<100&&qq==1&&stm[0]<sts[0])
    if(ha()==1&&fma1[1]<sma1[1]&&mm[1]<100&&qq==1&&stm[1]<sts[1])
      if(ha()==1&&fma1[2]<sma1[2]&&mm[2]<100&&qq==1&&stm[2]<sts[2])
        return(1); // signal SELL
   return(0);
  }
//---
int cc() // general description of the close position
{
int qq=qq(); double fma1[1],sma1[1],sts[];
//CopyBuffer(hfma,0,1,1,fma1);
//CopyBuffer(hsma,0,1,1,sma1);
CopyBuffer(hst,0,0,4,sts);


   if(qq==1&&fma1[0]<sma1[0])return(1); // close buy
   if(qq==2&&fma1[0]>sma1[0])return(2); // close sell
   
   //--- moving the trailing stop
     TrailingTake();
     TrailingStop();

return(0);
}
//---
int ha() // this func define color H-ASHI
{
 double red11[3],whi11[3];
 CopyBuffer(ha,0,1,3,red11);
 CopyBuffer(ha,3,1,3,whi11);

      
    if(red11[0]>whi11[0])
      if(red11[1]>whi11[1])
        if(red11[2]>whi11[2])
          return(1);
    if(red11[0]<whi11[0])
      if(red11[1]<whi11[1])
        if(red11[2]<whi11[2])
          return(2);
   return(0);
}
//---
int qq() // denide signal for QQE Alert v3
{
double up[],dw[];
ArraySetAsSeries(up,1);ArraySetAsSeries(dw,1);
CopyBuffer(hqq,0,1,500,up);
CopyBuffer(hqq,1,1,500,dw);
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
             
            request.sl=NormalizeDouble(LastPrice-LastHeight*SL/100,_Digits);
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
            request.sl=NormalizeDouble(LastPrice+LastHeight*SL/100,_Digits);
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

