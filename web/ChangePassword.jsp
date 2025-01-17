<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*,java.util.*" %>
<%@ page import="java.security.Security" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>修改用户密码</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
  <style>
    body {
      margin: 0;
      padding: 0;
      background: linear-gradient(to bottom right, #8e9eab, #eef2f3);
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      padding:40px 20px;
    }

    .card-container {
      background: rgba(255,255,255,0.85);
      backdrop-filter: blur(10px);
      border-radius: 16px;
      box-shadow: 0 10px 30px rgba(0,0,0,0.1);
      padding: 30px;
      max-width: 600px;
      width: 100%;
    }

    h2 {
      font-weight: 600;
      color: #2c3e50;
      margin-bottom: 20px;
      text-align: center;
    }

    .form-label {
      font-weight: 500;
      color: #2c3e50;
    }

    .user-list {
      max-height: 200px;
      overflow-y: auto;
      background: #ffffffcc;
      backdrop-filter: blur(8px);
      padding: 10px;
      border-radius: 8px;
      margin-bottom: 20px;
      box-shadow: 0 2px 15px rgba(0,0,0,0.07);
    }

    .user-list table {
      width:100%;
      border-collapse:collapse;
    }
    .user-list table th, .user-list table td {
      padding:8px;
      border-bottom:1px solid #ddd;
      color:#333;
    }
    .user-list table tr:hover {
      background:#f0f2f5;
      cursor:pointer;
    }

    .btn-primary {
      border-radius:20px;
      font-weight:500;
      background-color:#3498db;
      border:none;
    }

    .alert-info {
      background: #e8f7ff;
      color: #2c3e50;
      border: none;
      border-radius: 8px;
      margin-top: 15px;
    }
    .select-msg {
      font-size: 0.9em;
      color: #555;
    }
  </style>
</head>
<body>

<%
  request.setCharacterEncoding("UTF-8");

  String action = request.getParameter("action");
  String message = null;

  // 当管理员选择用户并提交新密码时
  String selectedUser = request.getParameter("selectedUser");
  String newPassword = request.getParameter("newPassword");
  String confirmPassword = request.getParameter("confirmPassword");

  Security.setProperty("jdk.tls.disabledAlgorithms", "");
  System.setProperty("https.protocols", "TLSv1");
  Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

  if ("update".equals(action)) {
    if (selectedUser == null || selectedUser.trim().isEmpty()) {
      message = "请先选择要修改密码的用户！";
    } else if (newPassword == null || newPassword.trim().isEmpty() || confirmPassword == null || confirmPassword.trim().isEmpty()) {
      message = "请填写新密码和确认密码！";
    } else if (!newPassword.equals(confirmPassword)) {
      message = "两次密码输入不一致，请重新输入！";
    } else {
      // 同时更新UserInfo和Login表中的password
      Connection conn = null;
      PreparedStatement pstmtInfo = null;
      PreparedStatement pstmtLogin = null;
      try {
        conn = DriverManager.getConnection(
                "jdbc:sqlserver://10.211.55.7:1433;databaseName=webChat;" +
                        "encrypt=true;trustServerCertificate=true;sslProtocol=TLSv1;" +
                        "disableStatementPooling=true;cancelQueryTimeout=0;socketTimeout=120",
                "sa", "123456");

        // 更新UserInfo表中的password
        String sqlInfo = "UPDATE webChat.dbo.UserInfo SET password=? WHERE username=?";
        pstmtInfo = conn.prepareStatement(sqlInfo);
        pstmtInfo.setString(1, newPassword.trim());
        pstmtInfo.setString(2, selectedUser.trim());
        int rowsInfo = pstmtInfo.executeUpdate();

        // 更新Login表中的password
        String sqlLogin = "UPDATE webChat.dbo.Login SET password=? WHERE username=?";
        pstmtLogin = conn.prepareStatement(sqlLogin);
        pstmtLogin.setString(1, newPassword.trim());
        pstmtLogin.setString(2, selectedUser.trim());
        int rowsLogin = pstmtLogin.executeUpdate();

        if (rowsInfo > 0 && rowsLogin > 0) {
          message = "密码更新成功！";
        } else {
          message = "密码更新失败，请确认用户是否存在。";
        }

      } catch (Exception e) {
        e.printStackTrace();
        message = "发生错误：" + e.getMessage();
      } finally {
        if (pstmtInfo != null) try {pstmtInfo.close();} catch(SQLException e){}
        if (pstmtLogin != null) try {pstmtLogin.close();} catch(SQLException e){}
        if (conn != null) try {conn.close();} catch(SQLException e){}
      }
    }
  }
%>

<div class="card-container">
  <h2>修改用户密码</h2>
  <hr>

  <!-- 显示用户列表，用于选择要修改密码的用户 -->
  <div class="mb-3">
    <h5 class="mb-2">选择用户</h5>
    <p class="select-msg">点击下表中的用户名以选择要修改密码的用户</p>
    <div class="user-list">
      <table>
        <thead>
        <tr>
          <th>用户名</th>
          <th>姓名</th>
        </tr>
        </thead>
        <tbody>
        <%
          // 从UserInfo表中获取用户列表
          Connection listConn = null;
          Statement listStmt = null;
          ResultSet listRs = null;
          String currentSelected = selectedUser != null ? selectedUser.trim() : "";
          try {
            listConn = DriverManager.getConnection(
                    "jdbc:sqlserver://10.211.55.7:1433;databaseName=webChat;" +
                            "encrypt=true;trustServerCertificate=true;sslProtocol=TLSv1;" +
                            "disableStatementPooling=true;cancelQueryTimeout=0;socketTimeout=120",
                    "sa", "123456");

            String listSql = "SELECT username, person_name FROM webChat.dbo.UserInfo ORDER BY username ASC";
            listStmt = listConn.createStatement();
            listRs = listStmt.executeQuery(listSql);
            while (listRs.next()) {
              String uname = listRs.getString("username");
              String pname = listRs.getString("person_name");
        %>
        <tr onclick="selectUser('<%= uname %>')"
            style="<%= (currentSelected.equals(uname)) ? "background-color:#e9ecef;" : "" %>">
          <td><%= uname %></td>
          <td><%= (pname != null) ? pname : "" %></td>
        </tr>
        <%
          }
        } catch(Exception e) {
          e.printStackTrace();
        %>
        <tr><td colspan="2" style="color:red;">加载用户列表时出错：<%= e.getMessage() %></td></tr>
        <%
          } finally {
            if (listRs != null) try {listRs.close();} catch(SQLException ee){}
            if (listStmt != null) try {listStmt.close();} catch(SQLException ee){}
            if (listConn != null) try {listConn.close();} catch(SQLException ee){}
          }
        %>
        </tbody>
      </table>
    </div>
  </div>

  <!-- 修改密码的表单 -->
  <form method="post" action="">
    <input type="hidden" name="selectedUser" value="<%= selectedUser != null ? selectedUser : "" %>">
    <div class="mb-3">
      <label class="form-label">选定用户：</label>
      <input type="text" class="form-control" value="<%= selectedUser != null ? selectedUser : "未选择" %>" disabled>
    </div>

    <div class="mb-3">
      <label class="form-label">新密码</label>
      <input type="password" class="form-control" name="newPassword">
    </div>

    <div class="mb-3">
      <label class="form-label">确认新密码</label>
      <input type="password" class="form-control" name="confirmPassword">
    </div>

    <div class="mb-3">
      <button type="submit" class="btn btn-primary" name="action" value="update"
              <%= (selectedUser == null || selectedUser.trim().isEmpty()) ? "disabled" : "" %>>
        更新密码
      </button>
    </div>
  </form>

  <% if (message != null) { %>
  <div class="alert alert-info"><%= message %></div>
  <% } %>
</div>

<script>
  function selectUser(username) {
    var form = document.createElement('form');
    form.method = 'GET';
    form.action = '';
    var input = document.createElement('input');
    input.type = 'hidden';
    input.name = 'selectedUser';
    input.value = username;
    form.appendChild(input);
    document.body.appendChild(form);
    form.submit();
  }
</script>

</body>
</html>
