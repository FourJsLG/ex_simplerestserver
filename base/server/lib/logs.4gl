#
# FOURJS_START_COPYRIGHT(U,2015)
# Property of Four Js*
# (c) Copyright Four Js 2015, 2017. All Rights Reserved.
# * Trademark of Four Js Development Tools Europe Ltd
#   in the United States and elsewhere
# 
# Four Js and its suppliers do not warrant or guarantee that these samples
# are accurate and suitable for your purposes. Their inclusion is purely for
# information purposes only.
# FOURJS_END_COPYRIGHT
#

#+  Generic Logging Library
#+  - Create Log file if doesn't exist
#+  - Adds simple practical info with type (Error, Message, ...)
#+

IMPORT COM
IMPORT XML
IMPORT os

PUBLIC CONSTANT C_LOG_ERROR     = 1
PUBLIC CONSTANT C_LOG_DEBUG     = 2
PUBLIC CONSTANT C_LOG_MSG       = 3
PUBLIC CONSTANT C_LOG_ACCESS    = 4
PUBLIC CONSTANT C_LOG_SQLERROR  = 5

PRIVATE DEFINE pid  INTEGER
PRIVATE DEFINE level STRING 

#+ Checks path recursively
#+
#+ @code
#+ DEFINE path STRING
#+ DEFINE dirname STRING, r INT
#+ IF NOT mkdir_recursive(fullpath) THEN
#+
#+ @param path: path to check
#+
#+ @returnType BOOLEAN
#+ @return os.Path.mkdir(path) If path exists or not and is valid
#+

PRIVATE FUNCTION mkdir_recursive(path)
    DEFINE path STRING
    DEFINE dirname STRING, r INT
    
    IF os.Path.exists(path) THEN
       RETURN TRUE
    END IF
    LET dirname = os.Path.dirname(path)
    IF dirname == path THEN
      RETURN TRUE # no dirname to extract anymore
    END IF
    LET r = mkdir_recursive(dirname)
    IF NOT r THEN
       RETURN r
    END IF
    RETURN os.Path.mkdir(path)
END FUNCTION

#+ Initialize Log File
#+
#+ @code
#+ DEFINE  f     STRING
#+ DEFINE  path  STRING 
#+  DEFINE  lvl   STRING 
#+  DEFINE  fullpath  STRING
#+  CALL logs.LOG_INIT("DEBUG",".","SimpleRESTServer.log")  
#+
#+ @param lvl debug level
#+ @param path valid path where log needs to be created (or if exist, logs need to be added to)
#+ @param f logfile name
#+
#+ @returnType
#+ @return
#+

PUBLIC FUNCTION LOG_INIT(lvl, path, f)
  DEFINE  f     STRING
  DEFINE  path  STRING 
  DEFINE  lvl   STRING 
  DEFINE  fullpath  STRING
  LET pid = fgl_getpid()
  LET level = lvl
  IF path IS NOT NULL THEN
    LET fullpath = path || "/log"
    IF NOT mkdir_recursive(fullpath) THEN
        DISPLAY "ERROR: Unable to create log file in ",fullpath
        EXIT PROGRAM(1)
    END IF
    CALL startlog(fullpath||"/"||f)
  ELSE
    CALL startlog(f)
  END IF
   CALL errorlog("MSG  : "||pid||" - [Logs] \"INIT\" done")
END FUNCTION

#+ Log an Event in File
#+
#+ @code
#+ DEFINE cat  INTEGER
#+ DEFINE  ev  STRING
#+ DEFINE  class STRING 
#+ DEFINE  msg STRING  
#+ CALL logs.LOG_EVENT(logs.C_LOG_MSG,"Server","Main","Started")
#+
#+ @param cat LOG category
#+ By default : error and access messages are logged
#+ MSG : logs also messages
#+ DEBUG : logs everything
#+
#+ @param class library/4gl module name
#+ @param ev function name
#+ @param msg additional log message
#+
#+ @returnType
#+ @return
#+

PUBLIC FUNCTION LOG_EVENT(cat,class,ev,msg)
  DEFINE cat  INTEGER
  DEFINE  ev  STRING
  DEFINE  class STRING 
  DEFINE  msg STRING  
  IF msg IS NULL THEN
    LET msg = "(null)"
  END IF
  CASE cat
    WHEN C_LOG_ERROR
      CALL errorlog("ERROR  : "||pid||" - ["||class||"] \""||ev||"\" "||msg)
    WHEN C_LOG_DEBUG
      IF level=="DEBUG" THEN
        CALL errorlog("DEBUG  : "||pid||" - ["||class||"] \""||ev||"\" "||msg)
      END IF
    WHEN C_LOG_SQLERROR
      CALL errorlog("SQLERR : "||pid||" - ["||class||"] \""||ev||"\" "||msg)
    WHEN C_LOG_MSG
      IF level=="MSG" OR level=="DEBUG" THEN 
        CALL errorlog("MSGLOG : "||pid||" - ["||class||"] \""||ev||"\" "||msg)
      END IF 
    WHEN C_LOG_ACCESS
      CALL errorlog("ACCESS : "||pid||" - ["||class||"] \""||ev||"\" "||msg)
  END CASE  
END FUNCTION
  

  
