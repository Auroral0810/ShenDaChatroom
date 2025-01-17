<%@ page language="java" contentType="text/html; charset=UTF-8"
     pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" 
"http://www.w3.org/TR/html4/loose.dtd">
<html><head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Web聊天---主页</title></head>
<%
       String currentUsername = (String) session.getAttribute("user");
       if (currentUsername == null) {
              response.sendRedirect("Loginbysql.jsp");
              return;
       }
%>
<frameset rows="65%,*">
       <frame src="WebChat_ListMsg.jsp">      
       <frame src="WebChat_SendMsg.jsp">
</frameset>
</html>
