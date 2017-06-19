#+ ReST Web Service Server:
#+ - Publication of the resources
#+ - Handle the REST protocol
#+ - Not fully modularized for simplicity and quick code read
#+

IMPORT com
IMPORT util
IMPORT FGL global
IMPORT FGL logs
IMPORT FGL dbase
IMPORT FGL accounts

# Module variables definitions
DEFINE request com.HTTPServiceRequest
DEFINE http_code SMALLINT
DEFINE http_response STRING

#+ Main Function
#+
#+ Starts the Service
#+ Waits for incoming request
#+ Starts proper Business Logic based on Method Type in Request Header or Sends error message
#+
#+ @code
#+
#+ @param
#+

MAIN

    # Initialize log
    CALL logs.LOG_INIT(_LOGLEVEL,".","SimpleRESTServer.log")  
    
    CALL logs.LOG_EVENT(logs.C_LOG_MSG,"Server","Main","Started")
    CALL com.WebServiceEngine.Start()
    
    IF NOT dbase.DBConnect() THEN
      CALL logs.LOG_EVENT(logs.C_LOG_ERROR,"Server","Database","unable to connect")
      EXIT PROGRAM (1)
    END IF

    CALL logs.LOG_EVENT(logs.C_LOG_MSG,"Server","Main","The server is listening...")

    LET http_code = 0
    LET http_response = NULL

    WHILE TRUE
      # Process each incoming requests (infinite loop)
      LET request = com.WebServiceEngine.getHTTPServiceRequest(-1)

      CALL logs.LOG_EVENT(logs.C_LOG_MSG,"Server","Main","Processing request...")

      CALL MarshallRequest()

      IF int_flag<>0 THEN
        LET int_flag=0
        EXIT WHILE
      END IF 
    END WHILE

    # Close database
    CALL dbase.DBDisconnect()
    CALL logs.LOG_EVENT(logs.C_LOG_MSG,"Server","Main","Stopped")  
    
END MAIN

#+ retrieves all parameters of a request and triages it to be processed by BDL business logic functions
#+
#+ @code
#+ DEFINE request com.HTTPServiceRequest
#+ CALL MarshallRequest(req)
#+
#+ Example of allowed or not allowed URLs (as an example):
#+ GET <BASE_URL>/_SERVICENAME/accounts => Allowed: query all accounts
#+ GET <BASE_URL>/_SERVICENAME/accounts/smith => Allowed: query a specific account
#+ POST <BASE_URL>/_SERVICENAME/accounts => Allowed: create a new account
#+ POST <BASE_URL>/_SERVICENAME/accounts/smith => Not Allowed: don't need a reference in URL for the new account info
#+ PUT <BASE_URL>/_SERVICENAME/accounts => Not Allowed: can't update all accounts as one operation
#+ PUT <BASE_URL>/_SERVICENAME/accounts/smith => Allowed: update a specific account
#+ DELETE <BASE_URL>/_SERVICENAME/accounts => Not Allowed: can't delete all accounts as one operation
#+ DELETE<BASE_URL>/_SERVICENAME/accounts/smith => Allowed: delete a specific account
#+
#+ @param request: incoming request
#+
#+ @returnType
#+ @return
#+

FUNCTION MarshallRequest()

   DEFINE requestTokenizer base.StringTokenizer
   DEFINE requestMethod STRING
   DEFINE url STRING
   DEFINE res_table, res_id, query_params STRING

   # Get the type of method
   LET requestMethod = request.getMethod()

   #Validate method
   IF requestMethod != "GET" AND requestMethod != "PUT" AND requestMethod != "POST" AND requestMethod != "DELETE"
   THEN
     LET http_code = HTTP_NOT_FOUND
   ELSE
     # Get the REST resources parameters => res_table, res_id, query parameters
     LET url = request.getUrl()

     LET requestTokenizer = base.StringTokenizer.create(url, "/?")

     LET res_table = NULL
     LET res_id = NULL
   
     WHILE requestTokenizer.hasMoreTokens()
       IF requestTokenizer.nextToken() = _SERVICENAME THEN
         IF requestTokenizer.hasMoreTokens() THEN
           # Retrieve Resource Table Name
           LET res_table = requestTokenizer.nextToken()
           IF requestTokenizer.hasMoreTokens() THEN
             # Retrieve Resource Id
             LET res_id = requestTokenizer.nextToken()
               IF requestTokenizer.hasMoreTokens() THEN
                 # Get Query Parameters after the ? delimiter
                 # Those are ignored in this sample code but can be further marshalled if needed in your specs
                 LET query_params = requestTokenizer.nextToken()
               END IF
           END IF
         END IF 
       END IF
     END WHILE

     CASE res_table
       WHEN "accounts"
       CALL ProcessRestAccounts(requestMethod, res_id) RETURNING http_code, http_response

       WHEN "items"
         #LET http_code = ProcessRestItems(requestMethod, res_table, res_id)

       OTHERWISE
         LET http_code=HTTP_NOT_IMPLEMENTED
     END CASE
  
   END IF

   CALL send_response()
  
END FUNCTION

#+ retrieves all parameters of a request and triages it to be processed by BDL business logic functions
#+
#+ @code
#+ LET HTTP_CODE=ProcessRestAccounts(requestMethod, res_table, res_id)
#+
#+ @param requestMethod : valid request (GET, POST, PUT, DELETE)
#+ @param res_table : valid resource table (accounts, items, ...)
#+ @param res_id : valid resource id (smith, 1, ABC, ...)
#+
#+ @returnType SMALLINT
#+ @return HTTP_CODE: code to be sent with request response
#+

FUNCTION ProcessRestAccounts(thismethod, thisid)

  DEFINE thismethod, thisid STRING
  DEFINE retcode SMALLINT
  DEFINE thisresponse STRING

  LET thisresponse = NULL

  CASE thismethod
    WHEN "GET"
      IF thisid IS NULL THEN
        CALL accounts.getAllAccounts() RETURNING retcode, thisresponse
      ELSE
        CALL accounts.queryAccountById() RETURNING retcode, thisresponse
      END IF

    WHEN "POST"
      IF thisid IS NULL THEN
        CALL accounts.insertAccount("blahblah") RETURNING retcode, thisresponse
      ELSE
        LET retcode=HTTP_BAD_REQUEST
      END IF

    WHEN "PUT"
      IF thisid IS NULL THEN
        LET retcode=400
      ELSE
        CALL accounts.updateAccountsById(thisid) RETURNING retcode, thisresponse
      END IF

    WHEN "DELETE"
      IF thisid IS NULL THEN
        LET retcode=400
      ELSE
        CALL accounts.deleteAccountById(thisid) RETURNING retcode, thisresponse
      END IF

    OTHERWISE
      LET retcode = 500 #This piece of code should never be run !
   END CASE
   
  RETURN retcode, thisresponse
  
END FUNCTION

FUNCTION send_response()

  CASE http_code
      WHEN HTTP_OK
        IF http_response IS NULL THEN
          CALL request.sendResponse(200,"Something went wrong, response is NULL")
        ELSE 
          CALL request.sendTextResponse(200,"Ok", http_response)
        END IF
      WHEN 400
        CALL request.sendResponse(400,"Bad Request")
      WHEN 404
        CALL request.sendResponse(404,"Unknown Request")
      WHEN 501
        CALL request.sendResponse(501,"Not implemented")
      OTHERWISE 
        CALL request.sendResponse(500, "Internal Server Error")
  END CASE

END FUNCTION



