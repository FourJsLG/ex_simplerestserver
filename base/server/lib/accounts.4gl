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
#+ LET HTTP_CODE=ProcessRestAccounts(requestMethod, res_table, res_id)
#+
#+ @param requestMethod : valid request (GET, POST, PUT, DELETE)
#+ @param res_table : valid resource table (accounts, items, ...)
#+ @param res_id : valid resource id (smith, 1, ABC, ...)
#+
#+ @returnType SMALLINT
#+ @return HTTP_CODE: code to be sent with request response
#+

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

################################################################################
#
# Method: getAccountById(id)
#
# Description: Retrieves account for specific ID from data source
#
#
FUNCTION queryAccountById()

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

################################################################################
#
# Method: insertAccount(thisData STRING)
#
# Description: Creates account for specific ID from data source
#
FUNCTION insertAccount(thisData)
    DEFINE thisData    STRING
    DEFINE thisAccount accountType
    DEFINE parseObject util.JSONObject
    DEFINE stat INT
    DEFINE thiscode SMALLINT
    DEFINE thisresponse STRING
    
    LET parseObject = util.JSONObject.parse(thisData)  --> Parse JSON string
    CALL parseObject.toFGL(thisAccount)                --> Put JSON into FGL

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

################################################################################
#
# Method: updateAccountById(id STRING)
#
# Description: Updates account for specific ID in data source
#
# Return: stat (number of rows updated)
#
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

################################################################################
#
# Method: deleteAccountById(id)
#
# Description: Deletes account for specific ID from data source
#
#
FUNCTION deleteAccountById(id)
    DEFINE id VARCHAR(10)
    DEFINE thiscode SMALLINT
    DEFINE thisresponse STRING
    
    DELETE FROM account WHERE userid = id 

    IF SQLCA.SQLCODE = 0 
    THEN
      LET thiscode = HTTP_OK
      LET thisresponse = "Row Deleted !" # TODO: needs to be JSON formatted ?
    ELSE
      LET thiscode = HTTP_BAD_REQUEST
      LET thisresponse = NULL
    END IF

    RETURN thiscode, thisresponse 
    
END FUNCTION

################################################################################
#
# Method: init()
#
# Description: Initializes the account array
#
FUNCTION init()
    CALL m_accounts.clear()
END FUNCTION

################################################################################
#
# Method: getJSONEncoding()
#
# Description: Encodes the current(modular) object as JSON string
#
# Returns: JSON encoded string
#
FUNCTION getJSONEncoding()
    RETURN util.JSON.stringify(m_accounts)
END FUNCTION