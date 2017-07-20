IMPORT util
IMPORT XML
IMPORT com

CONSTANT _SERVICEURL="http://localhost:6398/ws/r/ex_simplerestserver/accounts"
--CONSTANT _SERVICEURL="http://localhost:6398/ws/r/SimpleREST/accounts"

TYPE accountType RECORD
    userid CHAR(80),
    email CHAR(80),
    lastname CHAR(80),
    firstname CHAR(80),
    acstatus CHAR(2),
    addr1 CHAR(80),
    addr2 CHAR(40),
    city CHAR(80),
    state CHAR(80),
    zip CHAR(20),
    country CHAR(80),
    phone CHAR(80),
    langpref CHAR(80),
    favcategory CHAR(10),
    mylistopt INTEGER,
    banneropt INTEGER,
    sourceapp CHAR(3)
END RECORD

DEFINE cust_rec accountType
DEFINE arr DYNAMIC ARRAY OF accountType
DEFINE obj util.JSONObject
DEFINE ja util.JSONArray

DEFINE testid,  msg_status STRING

# Flow
# Query All => How many ?
# Insert New
# Query All => How many ? +1
# QueryId on this new row
# Update newly created row
# QueryId => What changed ?
# Delete newly created row
# QueryId => Not found
# Query All => How Many ? Same as initial

MAIN

   CLOSE WINDOW SCREEN
   OPEN WINDOW w1 WITH FORM "ex_simplerestclienttester"

   MENU
     ON ACTION start
       CALL start_client_test()
     ON ACTION EXIT
      EXIT MENU 
   END MENU

   CLOSE WINDOW w1
   
END MAIN

FUNCTION start_client_test()

  DEFINE err STRING
  
  #1
  LET msg_status = "Test #1 : Query All => How many rows ? : " || get_customer_count() || "\n"
  DISPLAY msg_status TO lb_txtedt
  
  #2
  LET testid = "jones"
  CALL fillCustomerData()

  LET err = postCustomer()

  IF err IS NULL THEN
    LET msg_status = msg_status || "Test #2 : Insert New Id => " || testid || "\n"
  ELSE
    LET msg_status = msg_status || "Test #2 : Insert New Id => " || err || "\n"
  END IF
  DISPLAY msg_status TO lb_txtedt

  #3
  LET msg_status = msg_status || "Test #3 : Query All, How many rows ? (+1) => " || get_customer_count() || "\n"
  DISPLAY msg_status TO lb_txtedt
  
{
LABEL label4_1: label4_1, TEXT="Query All => How many ? +1 : ";
LABEL label5_1: label5_1, TEXT="QueryId on this new row : ";
LABEL label6_1: label6_1, TEXT="Update newly created row : ";
LABEL label7_1: label7_1, TEXT="QueryId => What changed ? : ";
LABEL label8_1: label8_1, TEXT="Delete newly created row : ";
LABEL label9_1: label9_1, TEXT="QueryId => Not found : ";
LABEL label10_1: label10_1, TEXT="Query All => How Many ? Same as initial : ";

  CALL ("label2_1")
  {
  
  CALL post_customer(testid)
  
  CALL get_customer_count("label4_1")
  
  CALL get_customer_id(testid)
  
  LET testid = "parker"
  CALL put_customer(testid)
  
  CALL get_customer_id(testid)
  
  CALL del_customer(testid)
  
  CALL get_customer_id(testid)
  
  CALL get_customer_count("label10_1")
}

END FUNCTION

FUNCTION get_customer_count()

    DEFINE field STRING
    
    DEFINE err, result STRING,
           req com.HTTPRequest,
           resp com.HTTPResponse,
           code, toto INTEGER

    TRY
      LET req = com.HTTPRequest.Create(_SERVICEURL)
    
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
    
    RETURN arr.getLength()

END FUNCTION --get_customer_count()

FUNCTION postCustomer()
    DEFINE err, result STRING,
           req com.HTTPRequest,
           resp com.HTTPResponse,
           code INTEGER

    TRY
         # Create a JSON object with data
         LET obj = util.JSONObject.fromFGL(cust_rec)

         LET req = com.HTTPRequest.Create(_SERVICEURL || "/" || testid)
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

     RETURN err
     
END FUNCTION --postCustomer()

FUNCTION fillCustomerData()
    LET cust_rec.userid = testid
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

{
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



}