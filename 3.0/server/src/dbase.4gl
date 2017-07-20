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

#+  Database Connect/Disconnect library functions
#+

PRIVATE CONSTANT C_DATABASE = "officestore"

#+ Connect and initialize OpenID database
#+ NOTE: add database customization here
#+
#+ @code
#+ CALL dbase.DBConnect()
#+
#+ @param
#+
#+ @returnType BOOLEAN
#+ @return TRUE/FALSE
#+

PUBLIC FUNCTION DBConnect()
  # Connect to DB
  TRY
    CONNECT TO C_DATABASE # USER "username" USING "password"
  CATCH
    RETURN FALSE 
  END TRY

  RETURN TRUE
END FUNCTION

#+ Release and disconnect database
#+ NOTE: add database customization here
#+
#+ @code
#+ CALL dbase.DBDisconnect()
#+
#+ @param
#+
#+ @returnType
#+ @return
#+

PUBLIC FUNCTION DBDisconnect()

  # Disconnect DB
  DISCONNECT C_DATABASE
  
END FUNCTION