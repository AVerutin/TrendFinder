//+------------------------------------------------------------------+
//|                                                   FileLogger.mqh |
//|                                           Copyright 2021, AlexV. |
//|                                       mailto://alexbroot@mail.ru |
//+------------------------------------------------------------------+
#include "Types.mqh"

#property copyright "Copyright 2021, AlexV."
#property link      "mailto://alexbroot@mail.ru"
#property version   "1.00"
#property strict
class FileLogger
{
private:
   string m_fileName;
   string m_unitName;
   int m_fileHandler;
   
   void AddMessage(string, ENUM_LOG_TYPE);

public:
   FileLogger();
   FileLogger(string);
  ~FileLogger();
  void Debug(string);
  void Error(string);
  void Warning(string);
  void Information(string);
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
FileLogger::FileLogger()
{
   string filePath = TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL4\\Files\\"; //FileLogger\\"; 
   string fileName = TimeToString(TimeCurrent(), TIME_DATE);
   StringReplace(fileName, ".", "-");
   
   m_fileName = filePath + fileName + ".txt";
   m_fileHandler = FileOpen(m_fileName, FILE_READ|FILE_WRITE|FILE_TXT, ';', CP_UTF8);

   m_unitName = "Main";
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
FileLogger::FileLogger(string unitName)
{
   string filePath = TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL4\\Files\\"; // FileLogger\\"; 
   string fileName = TimeToString(TimeCurrent(), TIME_DATE);
   StringReplace(fileName, ".", "-");
   
   m_fileName = filePath + fileName + ".txt";
   int len = StringLen(m_fileName);
   m_fileHandler = FileOpen(m_fileName, FILE_READ|FILE_WRITE|FILE_TXT, ';', CP_UTF8);

   m_unitName = unitName;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
FileLogger::~FileLogger()
{
   if (m_fileHandler != INVALID_HANDLE)
      FileClose(m_fileHandler);
}
//+------------------------------------------------------------------+

void FileLogger::AddMessage(string msg, ENUM_LOG_TYPE msgType)
{
   datetime now = TimeCurrent();
   string time = TimeToString(now, TIME_DATE|TIME_SECONDS);
   string type = "UWN";
   
   switch (msgType)
   {
      case LOG_DEBUG : { type = "DEB"; break; }
      case LOG_INFORMATION : { type = "INF"; break; }
      case LOG_WARNING : { type = "WRN"; break; }
      case LOG_ERROR: { type = "ERR"; break; }
   }
   
   string out = "[" + time + "] " + "{ " + type + " " + m_unitName + " } : " + msg + "\n";

   if (m_fileHandler != INVALID_HANDLE)
   {
      FileWriteString(m_fileHandler, msg);
   }
}

void FileLogger::Debug(string msg)
{
   AddMessage(msg, LOG_DEBUG);
}

void FileLogger::Error(string msg)
{
   AddMessage(msg, LOG_ERROR);
}

void FileLogger::Warning(string msg)
{
   AddMessage(msg, LOG_WARNING);
}

void FileLogger::Information(string msg)
{
   AddMessage(msg, LOG_INFORMATION);
}
