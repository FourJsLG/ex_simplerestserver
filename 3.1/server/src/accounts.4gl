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

#+  DB CRUD operations library functions
#+

IMPORT util
IMPORT FGL global
IMPORT FGL logs

# Using officestore demo compiled schema for this web service example
SCHEMA officestore  

# Account data type for web service
TYPE accountType RECORD LIKE account.*
DEFINE m_accounts DYNAMIC ARRAY OF accountType

#+ Method: getAllAccounts
#+ Retrieves all accounts from data source
#+
#+ @code
#+ CALL accounts.getAllAccounts() RETURNING retcode, thisresponse
#+
#+ @param NONE
#+
#+ @returnType SMALLINT
#+ @return retcode : return code (200 or else)
#+ @returnType STRING
#+ @return thisresponse: JSON response or NULL

FUNCTION getAllAccounts()

    DEFINE i INTEGER 
    DEFINE thiscode SMALLINT
    DEFINE thisresponse STRING

    CALL m_accounts.clear()
    DECLARE curs CURSOR FOR SELECT * FROM account
    LET i = 1
    FOREACH curs INTO m_accounts[i].*
        LET i = i+1
    END FOREACH

    IF SQLCA.SQLCODE = 0 
    THEN
      LET thiscode = HTTP_OK
      LET thisresponse = getJSONEncoding()
    ELSE
      LET thiscode = HTTP_BAD_REQUEST
      LET thisresponse = NULL
    END IF

    RETURN thiscode, thisresponse
    
END FUNCTION

#+ Method: getAccountById(id)
#+ Retrieves account for specific ID from data source
#+
#+ @code
#+ CALL accounts.queryAccountById(thisid) RETURNING retcode, thisresponse
#+
#+ @param id : valid resource id (smith, 1, ABC, ...)
#+
#+ @returnType SMALLINT
#+ @return retcode : return code (200 or else)
#+ @returnType STRING
#+ @return thisresponse: JSON response or NULL

FUNCTION queryAccountById(id)

    DEFINE id VARCHAR(10)
    DEFINE i INT
    DEFINE thiscode SMALLINT
    DEFINE thisresponse STRING

    CALL m_accounts.clear()
    DECLARE acctbyid CURSOR FOR SELECT * FROM account WHERE userid = id 
    LET i = 1
    FOREACH acctbyid INTO m_accounts[i].*
        LET i = i+1
    END FOREACH

    IF SQLCA.SQLCODE = 0 
    THEN
      LET thiscode = HTTP_OK
      LET thisresponse = getJSONEncoding()
    ELSE
      LET thiscode = HTTP_BAD_REQUEST
      LET thisresponse = NULL
    END IF

    RETURN thiscode, thisresponse
    
END FUNCTION

#+ Method: insertAccount(thisData STRING)
#+ Creates account for specific ID from data source
#+
#+ @code
#+ CALL accounts.insertAccount("blahblah") RETURNING retcode, thisresponse
#+
#+ @param thisData : row to insert in JSON format coming from client program
#+
#+ @returnType SMALLINT
#+ @return retcode : return code (200 or else)
#+ @returnType STRING
#+ @return thisresponse: JSON response or NULL

FUNCTION insertAccount(thisData)
    DEFINE thisData    STRING
    DEFINE thisAccount accountType
    DEFINE parseObject util.JSONObject
    DEFINE stat INT
    DEFINE thiscode SMALLINT
    DEFINE thisresponse STRING
    
    LET parseObject = util.JSONObject.parse(thisData)  --> Parse JSON string
    CALL parseObject.toFGL(thisAccount)                --> Put JSON into FGL

    WHENEVER ERROR CONTINUE
    PREPARE acctins FROM
        "INSERT INTO account VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
        EXECUTE acctins USING thisAccount.userid,
                          thisAccount.email,
                          thisAccount.firstname,
                          thisAccount.lastname,
                          thisAccount.acstatus,
                          thisAccount.addr1,
                          thisAccount.addr2,
                          thisAccount.city,
                          thisAccount.state,
                          thisAccount.zip,
                          thisAccount.country,
                          thisAccount.phone,
                          thisAccount.langpref,
                          thisAccount.favcategory,
                          thisAccount.mylistopt,
                          thisAccount.mylistopt,
                          thisAccount.sourceapp

    LET stat = SQLCA.SQLCODE
    FREE acctins
    WHENEVER ERROR STOP
    
    IF stat = 0 
    THEN
      LET thiscode = HTTP_OK
      LET thisresponse = "Row Inserted !" # TODO: needs to be JSON formatted ?
    ELSE
      LET thiscode = HTTP_BAD_REQUEST
      LET thisresponse = NULL
    END IF

    RETURN thiscode, thisresponse
    
END FUNCTION

#+ Method: updateAccountById(id STRING)
#+ Updates account for specific ID in data source
#+
#+ @code
#+ CALL accounts.updateAccountsById(thisid) RETURNING retcode, thisresponse
#+
#+ @param thisData : row(s) to update in JSON format coming from client program
#+
#+ @returnType SMALLINT
#+ @return retcode : return code (200 or else)
#+ @returnType STRING
#+ @return thisresponse: JSON response or NULL
#+ TODO: return stat (number of rows updated) as well ?

FUNCTION updateAccountsById(thisData)
    DEFINE thisData    STRING
    DEFINE thisAccount accountType
    DEFINE parseObject util.JSONObject
    DEFINE stat, rows_updated INT
    DEFINE thiscode SMALLINT
    DEFINE thisresponse STRING
    
    LET parseObject = util.JSONObject.parse(thisData)  
    CALL parseObject.toFGL(thisAccount)

    # For brevity, only updating first and last name...it could be all fields
    PREPARE acctupdt FROM
        "UPDATE account SET firstname = ?, lastname = ? WHERE userid = ?" 
    EXECUTE acctupdt USING thisAccount.firstname, 
                           thisAccount.lastname,
                           thisAccount.userid

    # Return the number of rows processed to report success status                           
    LET stat = SQLCA.SQLCODE
    LET rows_updated = SQLCA.SQLERRD[3]
    FREE acctupdt

    IF stat = 0 
    THEN
      LET thiscode = HTTP_OK
      LET thisresponse = rows_updated || "rows updated !" # TODO: needs to be JSON formatted ?
    ELSE
      LET thiscode = HTTP_BAD_REQUEST
      LET thisresponse = NULL
    END IF

    RETURN thiscode, thisresponse
    
END FUNCTION

#+ Method: deleteAccountById(id)
#+ Deletes account for specific ID from data source
#+
#+ @code
#+ CALL accounts.deleteAccountById(thisid) RETURNING retcode, thisresponse
#+
#+ @param id : valid resource id (smith, 1, ABC, ...)
#+
#+ @returnType SMALLINT
#+ @return retcode : return code (200 or else)
#+ @returnType STRING
#+ @return thisresponse: JSON response or NULL

FUNCTION deleteAccountById(id)
    DEFINE id STRING
    DEFINE thiscode SMALLINT
    DEFINE thisresponse STRING

    WHENEVER ERROR CONTINUE
    DELETE FROM account WHERE userid = id 

    IF SQLCA.SQLCODE = 0 
    THEN
      LET thiscode = HTTP_OK
      LET thisresponse = "Row Deleted !" # TODO: needs to be JSON formatted ?
    ELSE
      LET thiscode = HTTP_BAD_REQUEST
      LET thisresponse = NULL
    END IF
    WHENEVER ERROR CONTINUE
    
    RETURN thiscode, thisresponse 
    
END FUNCTION

#+ Method: init()
#+ Initializes the account array
#+
#+ @code
#+ 
#+ @param NONE
#+
#+ @returnType NONE
#+ @return NONE

FUNCTION init()
    CALL m_accounts.clear()
END FUNCTION

#+ Method: getJSONEncoding()
#+ Encodes the current(modular) object as JSON string
#+
#+ @code
#+ LET thisresponse = getJSONEncoding()
#+
#+ @param NONE
#+
#+ @returnType STRING
#+ @return : JSON encoded string

FUNCTION getJSONEncoding()
    RETURN util.JSON.stringify(m_accounts)
END FUNCTION