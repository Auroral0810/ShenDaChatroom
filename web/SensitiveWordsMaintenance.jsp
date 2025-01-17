<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.sql.*,java.util.*" %>
<%@ page import="java.security.Security" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>敏感词维护</title>
  <!-- 引入Bootstrap CSS -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
  <style>
    body {
      margin: 0;
      padding: 0;
      /* 渐变背景 */
      background: linear-gradient(to bottom right, #8e9eab, #eef2f3);
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      min-height: 100vh;
    }
    .container-main {
      display: flex;
      flex-direction: column;
      align-items: center;
      padding: 40px 20px;
    }
    .content-card {
      background: rgba(255,255,255,0.8);
      backdrop-filter: blur(10px);
      border-radius: 16px;
      box-shadow: 0 10px 30px rgba(0,0,0,0.1);
      padding: 30px;
      max-width: 800px;
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
    .message {
      margin-top: 15px;
    }
    .word-list {
      max-height: 300px;
      overflow-y: auto;
      margin-bottom: 20px;
      background: #fff;
      border-radius: 8px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.05);
    }
    .word-list table {
      width: 100%;
      margin: 0;
      border-collapse: collapse;
    }
    .word-list table th {
      background: #f7f7f7;
      position: sticky;
      top: 0;
      z-index: 10;
    }
    .word-list table th, .word-list table td {
      padding: 12px;
      border-bottom: 1px solid #ddd;
      color: #333;
    }
    .word-list table tr:hover {
      background: #f0f2f5;
    }
    .add-form, .edit-form {
      background: #ffffffcc;
      backdrop-filter: blur(8px);
      padding: 20px;
      border-radius: 10px;
      box-shadow: 0 2px 15px rgba(0,0,0,0.07);
      margin-bottom: 20px;
    }
    .btn-primary, .btn-danger, .btn-success, .btn-warning {
      border-radius: 20px;
      font-weight: 500;
    }
    .btn-primary { background-color: #3498db; border:none; }
    .btn-danger { background-color: #e74c3c; border:none; }
    .btn-success { background-color: #27ae60; border:none; }
    .btn-warning { background-color: #f39c12; border:none; }

    .alert-info {
      background: #e8f7ff;
      color: #2c3e50;
      border: none;
      border-radius: 8px;
    }
  </style>
</head>
<body>
<%
  request.setCharacterEncoding("UTF-8");

  String action = request.getParameter("action");
  String message = null;

  // 添加、编辑时使用的参数
  String newWord = request.getParameter("newWord"); // 新增或修改后的敏感词
  String oldWord = request.getParameter("oldWord"); // 编辑时原来的敏感词

  Security.setProperty("jdk.tls.disabledAlgorithms", "");
  System.setProperty("https.protocols", "TLSv1");
  Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

  // 根据action执行相应操作
  if ("add".equals(action)) {
    // 添加新敏感词
    if (newWord != null && !newWord.trim().isEmpty()) {
      Connection conn = null;
      PreparedStatement pstmt = null;
      try {
        conn = DriverManager.getConnection(
                "jdbc:sqlserver://10.211.55.7:1433;databaseName=webChat;" +
                        "encrypt=true;trustServerCertificate=true;sslProtocol=TLSv1;" +
                        "disableStatementPooling=true;cancelQueryTimeout=0;socketTimeout=120",
                "sa", "123456");

        String sql = "INSERT INTO webChat.dbo.SensitiveWords (word) VALUES (?)";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, newWord.trim());

        int rows = pstmt.executeUpdate();
        if (rows > 0) {
          message = "敏感词添加成功！";
        } else {
          message = "敏感词添加失败！";
        }

      } catch (Exception e) {
        e.printStackTrace();
        message = "发生错误：" + e.getMessage();
      } finally {
        if (pstmt != null) try {pstmt.close();} catch(SQLException e){}
        if (conn != null) try {conn.close();} catch(SQLException e){}
      }
    } else {
      message = "请输入要添加的敏感词！";
    }

  } else if ("delete".equals(action)) {
    // 删除敏感词
    oldWord = request.getParameter("oldWord");
    if (oldWord != null && !oldWord.trim().isEmpty()) {
      Connection conn = null;
      PreparedStatement pstmt = null;
      try {
        conn = DriverManager.getConnection(
                "jdbc:sqlserver://10.211.55.7:1433;databaseName=webChat;" +
                        "encrypt=true;trustServerCertificate=true;sslProtocol=TLSv1;" +
                        "disableStatementPooling=true;cancelQueryTimeout=0;socketTimeout=120",
                "sa", "123456");

        String sql = "DELETE FROM webChat.dbo.SensitiveWords WHERE word=?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, oldWord.trim());

        int rows = pstmt.executeUpdate();
        if (rows > 0) {
          message = "敏感词删除成功！";
        } else {
          message = "敏感词删除失败，未找到该词。";
        }

      } catch (Exception e) {
        e.printStackTrace();
        message = "发生错误：" + e.getMessage();
      } finally {
        if (pstmt != null) try {pstmt.close();} catch(SQLException e){}
        if (conn != null) try {conn.close();} catch(SQLException e){}
      }
    } else {
      message = "未指定要删除的敏感词！";
    }

  } else if ("edit".equals(action)) {
    // 只是显示编辑表单，不更新
  } else if ("update".equals(action)) {
    // 更新敏感词
    oldWord = request.getParameter("oldWord");
    if (oldWord != null && !oldWord.trim().isEmpty() && newWord != null && !newWord.trim().isEmpty()) {
      Connection conn = null;
      PreparedStatement pstmt = null;
      try {
        conn = DriverManager.getConnection(
                "jdbc:sqlserver://10.211.55.7:1433;databaseName=webChat;" +
                        "encrypt=true;trustServerCertificate=true;sslProtocol=TLSv1;" +
                        "disableStatementPooling=true;cancelQueryTimeout=0;socketTimeout=120",
                "sa", "123456");

        String sql = "UPDATE webChat.dbo.SensitiveWords SET word=? WHERE word=?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, newWord.trim());
        pstmt.setString(2, oldWord.trim());

        int rows = pstmt.executeUpdate();
        if (rows > 0) {
          message = "敏感词更新成功！";
        } else {
          message = "敏感词更新失败，未找到原词。";
        }

      } catch (Exception e) {
        e.printStackTrace();
        message = "发生错误：" + e.getMessage();
      } finally {
        if (pstmt != null) try {pstmt.close();} catch(SQLException e){}
        if (conn != null) try {conn.close();} catch(SQLException e){}
      }
    } else {
      message = "请填写完整信息！";
    }
  }

  // 判断是否处于编辑状态
  String editWord = null;
  if ("edit".equals(action)) {
    editWord = request.getParameter("oldWord");
  }
%>
<div class="container-main">
  <div class="content-card">
    <h2>敏感词维护</h2>
    <hr>

    <!-- 添加新敏感词表单 -->
    <div class="add-form mb-4">
      <h5 class="mb-3">添加新敏感词</h5>
      <form method="post" action="">
        <div class="input-group">
          <input type="text" class="form-control" name="newWord" placeholder="输入新敏感词">
          <button type="submit" class="btn btn-success" name="action" value="add">添加</button>
        </div>
      </form>
    </div>

    <h5 class="mb-3">现有敏感词列表</h5>
    <div class="word-list mb-4">
      <table class="table table-sm align-middle">
        <thead>
        <tr>
          <th>敏感词</th>
          <th style="width:200px;">操作</th>
        </tr>
        </thead>
        <tbody>
        <%
          Connection listConn = null;
          Statement listStmt = null;
          ResultSet listRs = null;
          try {
            listConn = DriverManager.getConnection(
                    "jdbc:sqlserver://10.211.55.7:1433;databaseName=webChat;" +
                            "encrypt=true;trustServerCertificate=true;sslProtocol=TLSv1;" +
                            "disableStatementPooling=true;cancelQueryTimeout=0;socketTimeout=120",
                    "sa", "123456");

            String listSql = "SELECT word FROM webChat.dbo.SensitiveWords ORDER BY word ASC";
            listStmt = listConn.createStatement();
            listRs = listStmt.executeQuery(listSql);
            while (listRs.next()) {
              String w = listRs.getString("word");
        %>
        <tr>
          <td><%= w %></td>
          <td>
            <a href="?action=edit&oldWord=<%= w %>" class="btn btn-sm btn-primary">编辑</a>
            <a href="?action=delete&oldWord=<%= w %>" class="btn btn-sm btn-danger"
               onclick="return confirm('确定删除该敏感词吗？');">删除</a>
          </td>
        </tr>
        <%
          }
        } catch (Exception e) {
          e.printStackTrace();
        %>
        <tr><td colspan="2" class="text-danger">加载敏感词列表时出错：<%= e.getMessage() %></td></tr>
        <%
          } finally {
            if (listRs != null) try {listRs.close();} catch(SQLException e){}
            if (listStmt != null) try {listStmt.close();} catch(SQLException e){}
            if (listConn != null) try {listConn.close();} catch(SQLException e){}
          }
        %>
        </tbody>
      </table>
    </div>

    <% if (editWord != null && !editWord.trim().isEmpty()) { %>
    <!-- 编辑敏感词表单 -->
    <div class="edit-form">
      <h5 class="mb-3">编辑敏感词「<%= editWord %>」</h5>
      <form method="post" action="">
        <input type="hidden" name="oldWord" value="<%= editWord %>">
        <div class="input-group">
          <input type="text" class="form-control" name="newWord" placeholder="新的敏感词" required>
          <button type="submit" class="btn btn-warning" name="action" value="update">更新</button>
        </div>
      </form>
    </div>
    <% } %>

    <% if (message != null) { %>
    <div class="alert alert-info message"><%= message %></div>
    <% } %>
  </div>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
