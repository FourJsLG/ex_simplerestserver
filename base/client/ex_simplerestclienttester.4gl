IMPORT util
IMPORT XML
IMPORT com

SCHEMA officestore

DEFINE cust_rec RECORD LIKE account.*
DEFINE obj util.JSONObject

TYPE accountType RECORD LIKE account.*
DEFINE arr DYNAMIC ARRAY OF accountType
DEFINE ja util.JSONArray

# Query All
# Insert
# QueryId
# Update
# QueryId
# Delete
# QueryId => Not found
# Query ALl => Same as initial

MAIN

   CALL fillCustomerData()

   MENU
   ON ACTION put
      LET cust_rec.userid = "smith"
      LET cust_rec.email = "lg@4js.com"
      CALL putCustomer()
   ON ACTION noput
      LET cust_rec.userid = "foo"
      CALL putCustomer()
   ON ACTION post
      LET cust_rec.userid = "fourjs"
      CALL postCustomer()
   ON ACTION delete
      LET cust_rec.userid = "fourjs"
      CALL deleteCustomer()
   ON ACTION getfile
     LET cust_rec.userid = "smith"
     CALL getThisFile()
   ON ACTION EXIT
      EXIT MENU 
   END MENU

   ## Run tests after you execute the actions above directly on the browser, for POST/DELETE for example:
   ## http://localhost:8090/ws/r/simplerestserver/accounts/fourjs

END MAIN

FUNCTION putCustomer()
    DEFINE err, result STRING,
           req com.HTTPRequest,
           resp com.HTTPResponse,
           code INTEGER

    TRY
         # Create a JSON object with data
         LET obj = util.JSONObject.fromFGL(cust_rec)

         LET req = com.HTTPRequest.Create("http://localhost:8090/ws/r/simplerestserver/accounts")
         CALL req.setConnectionTimeout(10)
         CALL req.setTimeout(60)
         CALL req.setCharset("UTF-8")

         CALL req.setMethod("PUT")
         CALL req.setHeader("Content-Type","application/json")  --> different for xml request
         CALL req.doTextRequest(obj.toString())

         LET resp=req.getResponse()
         LET code = resp.getStatusCode()
         IF code>=200 AND code<=299 THEN
            LET result = resp.getTextResponse()
            LET err = NULL
         ELSE
            LET err = SFMT("(%1) : HTTP request status description: %2 ", code, resp.getStatusDescription())
         END IF
     CATCH
        LET err = SFMT("HTTP request error: STATUS=%1 (%2)",STATUS,SQLCA.SQLERRM)
     END TRY
END FUNCTION 

FUNCTION postCustomer()
    DEFINE err, result STRING,
           req com.HTTPRequest,
           resp com.HTTPResponse,
           code INTEGER

    TRY
         # Create a JSON object with data
         LET obj = util.JSONObject.fromFGL(cust_rec)

         LET req = com.HTTPRequest.Create("http://localhost:8090/ws/r/simplerestserver/accounts")
         CALL req.setConnectionTimeout(10)
         CALL req.setTimeout(60)
         CALL req.setCharset("UTF-8")

         CALL req.setMethod("POST")
         CALL req.setHeader("Content-Type","application/json")  --> different for xml request
         CALL req.doTextRequest(obj.toString())

         LET resp=req.getResponse()
         LET code = resp.getStatusCode()
         IF code>=200 AND code<=299 THEN
            LET result = resp.getTextResponse()
            LET err = NULL
         ELSE
            LET err = SFMT("(%1) : HTTP request status description: %2 ", code, resp.getStatusDescription())
         END IF
     CATCH
        LET err = SFMT("HTTP request error: STATUS=%1 (%2)",STATUS,SQLCA.SQLERRM)
     END TRY
END FUNCTION

FUNCTION deleteCustomer()
    DEFINE resrce, err, result STRING,
           req com.HTTPRequest,
           resp com.HTTPResponse,
           code INTEGER

    TRY
         LET resrce = "http://localhost:8090/ws/r/simplerestserver/accounts/"||cust_rec.userid CLIPPED
         LET req = com.HTTPRequest.Create(resrce)
         CALL req.setConnectionTimeout(10)
         CALL req.setTimeout(60)
         CALL req.setCharset("UTF-8")

         CALL req.setMethod("DELETE")
         CALL req.setHeader("Content-Type","application/json")  --> different for xml request
         CALL req.doRequest()

         LET resp=req.getResponse()
         LET code = resp.getStatusCode()
         IF code>=200 AND code<=299 THEN
            LET result = resp.getTextResponse()
            LET err = NULL
         ELSE
            LET err = SFMT("(%1) : HTTP request status description: %2 ", code, resp.getStatusDescription())
         END IF
     CATCH
        LET err = SFMT("HTTP request error: STATUS=%1 (%2)",STATUS,SQLCA.SQLERRM)
     END TRY
END FUNCTION 

FUNCTION fillCustomerData()
    LET cust_rec.userid = "smith"
    LET cust_rec.lastname = "Smith"
    LET cust_rec.firstname = "Charles"
    LET cust_rec.addr1 = "123 Easy St"
    LET cust_rec.city = "Anywhere"
    LET cust_rec.state = "FL"
    LET cust_rec.zip = "75038"
    LET cust_rec.phone = "+1 999 123 4567"
    LET cust_rec.langpref = "Piglatin"
    LET cust_rec.favcategory = "SUPPLIES"
    LET cust_rec.mylistopt = "1"
    LET cust_rec.banneropt = "1"
    LET cust_rec.country = "US"
    LET cust_rec.email = "foo@yoowho.com"
    LET cust_rec.sourceapp = "WEB"
END FUNCTION

FUNCTION getThisFile()

    DEFINE err, result STRING,
           req com.HTTPRequest,
           resp com.HTTPResponse,
           code INTEGER

    TRY

         LET req = com.HTTPRequest.Create("http://localhost:8090/ws/r/simplerestserver/accounts/" || cust_rec.userid)
         CALL req.setConnectionTimeout(10)
         CALL req.setTimeout(60)
         CALL req.setCharset("UTF-8")

         CALL req.setMethod("GET")
         CALL req.setHeader("Content-Type","application/json")  --> different for xml request
         CALL req.doRequest()

         LET resp=req.getResponse()
         LET code = resp.getStatusCode()
         IF code>=200 AND code<=299 THEN
            LET result = resp.getTextResponse()
            LET err = NULL
         ELSE
            LET err = SFMT("(%1) : HTTP request status description: %2 ", code, resp.getStatusDescription())
         END IF
     CATCH
        LET err = SFMT("HTTP request error: STATUS=%1 (%2)",STATUS,SQLCA.SQLERRM)
     END TRY

    LET ja = util.JSONArray.parse(result)
    CALL ja.toFGL(arr)
    DISPLAY arr[1].email
    CALL arr[1].filename.writeFile(fgl_getpid() || '.pdf')

END FUNCTION--getThisFile()