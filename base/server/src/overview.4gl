#+ Principles of ReSTful design:
#+   https://github.com/tfredrich/RestApiTutorial.com/raw/master/media/RESTful%20Best%20Practices-v1_2.pdf
#+ TODO: Not a full implementation by any means
#+       Many of the operations still need to have a ReST type response formulated
#+       especially when processing PUT and DELETE(to indicate succes/failure)
#+
#+ Security concerns:
#+ As RESTful Web Services work with HTTP URL Paths, it is very important to safeguard a RESTful Web Service in the same manner as a website is secured.
#+
#+ Following are the best practices to be adhered to while designing a RESTful Web Service −
#+
#+ HTTPS is a must have
#+ Validation − Validate all inputs on the server. Protect your server against SQL or NoSQL injection attacks.
#+
#+ If you can control the service consumer to be another server, you should implement a RSA public key exchange like Diffie Hellman
#+ If Web Service is accssed by end-users, implement Session Based Authentication − Use session based authentication to authenticate a user whenever a request is made to a Web Service method.
#+
#+ No Sensitive Data in the URL − Never use username, password or session token in a URL, these values should be passed to Web Service via the POST method.
#+
#+ Restriction on Method Execution − Allow restricted use of methods like GET, POST and DELETE methods. The GET method should not be able to delete data.
#+
#+ Validate Malformed XML/JSON − Check for well-formed input passed to a web service method.
#+ 
#+ Throw generic Error Messages − A web service method should use HTTP error messages like 403 to show access forbidden, etc.
#+
#+ HTTP code 
#+ 200 : OK − shows success.
#+ 201 : CREATED − when a resource is successfully created using POST or PUT request. Returns link to the newly created resource using the location header.
#+ 204 : NO CONTENT − when response body is empty. For example, a DELETE request.
#+ 304 : NOT MODIFIED − used to reduce network bandwidth usage in case of conditional GET requests. Response body should be empty. Headers should have date, location, etc.
#+ 400 : BAD REQUEST − states that an invalid input is provided. For example, validation error, missing data.
#+ 401 : UNAUTHORIZED − states that user is using invalid or wrong authentication token.
#+ 403 : FORBIDDEN − states that the user is not having access to the method being used. For example, Delete access without admin rights.
#+ 404 : NOT FOUND − states that the method is not available.
#+ 409 : CONFLICT − states conflict situation while executing the method. For example, adding duplicate entry.
#+ 500 : INTERNAL SERVER ERROR − states that the server has thrown some exception while executing the method.
#+