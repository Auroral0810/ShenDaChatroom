<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.security.Security" %>

<%
  // 获取当前用户
  String currentUsername = (String) session.getAttribute("user");
  if (currentUsername == null) {
    response.sendRedirect("Loginbysql.jsp");
    return;
  }

  // 处理导出请求
  String exportType = request.getParameter("exportType");
  if (exportType != null) {
    Connection conn = null;
    try {
      Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
      conn = DriverManager.getConnection(
              "jdbc:sqlserver://10.211.55.7:1433;databaseName=webChat;" +
                      "encrypt=true;trustServerCertificate=true;sslProtocol=TLSv1;" +
                      "disableStatementPooling=true;cancelQueryTimeout=0;socketTimeout=120",
              "sa", "123456");

      String sender = request.getParameter("sender");
      String startDate = request.getParameter("startDate");
      String endDate = request.getParameter("endDate");

      StringBuilder sb = new StringBuilder();
      List<Object> params = new ArrayList<>();

      // 根据用户选择的sender动态构建查询条件
      if (sender != null && !sender.isEmpty()) {
        // 有选择聊天对象
        sb.append("((username = ? AND (receiver = ? OR receiver = 'everyone')) OR (username = ? AND (receiver = ? OR receiver = 'everyone')))");
        params.add(sender);
        params.add(currentUsername);
        params.add(currentUsername);
        params.add(sender);
      } else {
        // 未选择聊天对象，显示与当前用户相关的所有消息
        sb.append("((username <> ? AND (receiver = ? OR receiver = 'everyone')) OR (username = ? AND receiver = 'everyone'))");
        params.add(currentUsername);
        params.add(currentUsername);
        params.add(currentUsername);
      }

      // 日期过滤
      if (startDate != null && !startDate.isEmpty()) {
        sb.append(" AND date >= ?");
        params.add(startDate);
      }
      if (endDate != null && !endDate.isEmpty()) {
        sb.append(" AND date <= ?");
        params.add(endDate);
      }

      // 包含 message_id
      String query = "SELECT message_id, username, message, receiver, date, file_name FROM Message WHERE " + sb.toString() + " ORDER BY date DESC";

      PreparedStatement pstmt = conn.prepareStatement(query);
      for (int i = 0; i < params.size(); i++) {
        pstmt.setObject(i + 1, params.get(i));
      }

      ResultSet rs = pstmt.executeQuery();

      // 将结果存储在 session 中以便在 ExportRecord.jsp 中导出
      List<Map<String, String>> chatHistory = new ArrayList<>();
      while (rs.next()) {
        Map<String, String> record = new HashMap<>();
        record.put("message_id", String.valueOf(rs.getInt("message_id")));
        record.put("username", rs.getString("username"));
        record.put("message", rs.getString("message"));
        record.put("receiver", rs.getString("receiver"));
        record.put("date", rs.getString("date"));
        record.put("file_name", rs.getString("file_name"));
        chatHistory.add(record);
      }

      session.setAttribute("chatHistoryExport", chatHistory);
      session.setAttribute("exportType", exportType);

      rs.close();
      pstmt.close();

      response.sendRedirect("ExportRecord.jsp");
      return;
    } catch(Exception e) {
      e.printStackTrace();
    } finally {
      if(conn != null) {
        try { conn.close(); } catch(SQLException e) { e.printStackTrace(); }
      }
    }
  }
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>聊天记录查询</title>
  <!-- 引入Google字体 -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet">
  <style>
    /* 重置默认样式 */
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    body {
      font-family: 'Poppins', sans-serif;
      background: linear-gradient(to bottom right, #A7C7E7, #C2E59C);
      color: #333;
      background-attachment: fixed;
      min-height: 100vh;
      display: flex;
      justify-content: center;
      align-items: center;
      padding: 20px;
    }

    .container {
      width: 100%;
      max-width: 1200px;
      background: rgba(255, 255, 255, 0.95);
      backdrop-filter: blur(15px);
      border-radius: 15px;
      padding: 40px;
      box-shadow: 0 20px 50px rgba(0,0,0,0.1);
    }

    header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-bottom: 30px;
    }

    header h2 {
      font-weight: 600;
      font-size: 2rem;
      color: #333;
    }

    .button-group form button {
      background: #FF7F50;
      color: #fff;
      border: none;
      padding: 10px 25px;
      border-radius: 25px;
      font-weight: 600;
      cursor: pointer;
      transition: background 0.3s, transform 0.2s;
      font-size: 16px;
      box-shadow: 0 5px 15px rgba(0,0,0,0.1);
    }

    .button-group form button:hover {
      background: #e67348;
      transform: translateY(-2px);
    }

    .search-form {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
      gap: 25px;
      align-items: end;
      margin-bottom: 30px;
    }

    .search-form > div {
      display: flex;
      flex-direction: column;
    }

    .search-form label {
      font-weight: 500;
      margin-bottom: 8px;
      color: #333;
      font-size: 16px;
    }

    .search-form select, .search-form input[type="date"] {
      padding: 10px 15px;
      border: 1.5px solid #ccc;
      border-radius: 8px;
      font-size: 16px;
      transition: border-color 0.3s, box-shadow 0.3s;
    }

    .search-form select:focus, .search-form input[type="date"]:focus {
      border-color: #4A90E2;
      box-shadow: 0 0 8px rgba(74, 144, 226, 0.3);
      outline: none;
    }

    .search-button-container button {
      background: #4A90E2;
      color: #fff;
      border: none;
      padding: 12px 30px;
      border-radius: 30px;
      font-weight: 600;
      cursor: pointer;
      transition: background 0.3s, transform 0.2s;
      font-size: 16px;
      box-shadow: 0 5px 15px rgba(0,0,0,0.1);
    }

    .search-button-container button:hover {
      background: #357ABD;
      transform: translateY(-2px);
    }

    table {
      width: 100%;
      border-collapse: collapse;
      margin-top: 20px;
      border-radius: 10px;
      overflow: hidden;
      box-shadow: 0 10px 25px rgba(0,0,0,0.05);
      font-size: 16px;
    }

    th, td {
      padding: 15px 20px;
      text-align: left;
      border-bottom: 1px solid #eee;
      vertical-align: top;
    }

    th {
      background-color: #E8F1FB;
      font-weight: 600;
      color: #333;
      position: sticky;
      top: 0;
      z-index: 1;
    }

    tbody tr:hover {
      background-color: #f9f9f9;
    }

    #selectAllLabel {
      cursor: pointer;
      user-select: none;
      font-weight: 500;
      margin-left: 8px;
      font-size: 16px;
      color: #333;
    }

    .export-buttons {
      margin-top: 25px;
      display: flex;
      flex-wrap: wrap;
      gap: 15px;
    }

    .export-buttons button {
      background: #2196f3;
      color: #fff;
      border: none;
      padding: 12px 25px;
      border-radius: 25px;
      font-weight: 600;
      cursor: pointer;
      transition: background 0.3s, transform 0.2s;
      font-size: 16px;
      box-shadow: 0 5px 15px rgba(0,0,0,0.1);
      flex: 1 1 auto;
      min-width: 150px;
      text-align: center;
    }

    .export-buttons button:hover {
      background: #1976d2;
      transform: translateY(-2px);
    }

    td[colspan="6"] {
      background: #fafafa;
      color: #999;
      text-align: center;
      padding: 20px;
      font-size: 16px;
    }

    .message-cell {
      max-width: 324px; /* 18字符 * 18px/字符估算 */
      font-size: 14px;
      line-height: 1.5;
      max-height: calc(1.5em * 5); /* 5行 */
      overflow: hidden;
      position: relative;
    }

    .toggle-button {
      background: none;
      border: none;
      color: #4A90E2;
      cursor: pointer;
      padding: 0;
      font-size: 14px;
      margin-top: 5px;
    }

    .full-message {
      display: none;
      margin-top: 10px;
      font-size: 14px;
      line-height: 1.5;
      white-space: pre-wrap;
      background-color: #f1f1f1;
      padding: 10px;
      border-radius: 5px;
    }

    .attachment-cell a {
      display: inline-block;
      max-width: 150px; /* 限制附件名称显示宽度（15个字符） */
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
      text-decoration: none;
      color: #4A90E2;
      position: relative;
    }

    .attachment-cell a .dropdown-content {
      display: none;
      position: absolute;
      background-color: #f9f9f9;
      min-width: 160px;
      box-shadow: 0px 8px 16px 0px rgba(0,0,0,0.2);
      padding: 12px 16px;
      z-index: 1;
      white-space: normal;
      word-wrap: break-word;
    }

    .attachment-cell a:hover .dropdown-content {
      display: block;
    }
    /* 增大选择框的尺寸 */
    input[type="checkbox"] {
      width: 20px;
      height: 20px;
      transform: scale(1.2);
      cursor: pointer;
    }
    @media (max-width: 768px) {
      header h2 {
        font-size: 1.75rem;
      }

      .search-form {
        grid-template-columns: 1fr;
      }

      .search-button-container {
        width: 100%;
      }

      .export-buttons {
        flex-direction: column;
        align-items: stretch;
      }

      .export-buttons button {
        width: 100%;
      }

      .message-cell {
        max-width: 100%; /* 在小屏幕上扩展宽度 */
      }

      .attachment-cell a {
        max-width: 100%; /* 在小屏幕上扩展宽度 */
      }
    }
  </style>
  <script>
    function toggleMessage(id) {
      var fullMessage = document.getElementById(id);
      var toggleBtn = document.getElementById("toggle-" + id);
      if (fullMessage.style.display === "none" || fullMessage.style.display === "") {
        fullMessage.style.display = "block";
        toggleBtn.innerText = "收起";
      } else {
        fullMessage.style.display = "none";
        toggleBtn.innerText = "查看更多";
      }
    }
  </script>
</head>
<body>
<div class="container">
  <header>
    <h2>聊天记录查询</h2>
    <div class="button-group">
      <form action="<%= "YYF222090140".equals(currentUsername) ? "AdminChat.jsp" : "Chat.jsp" %>" method="get">
        <button type="submit">返回聊天室</button>
      </form>
    </div>
  </header>

  <form method="post" action="" class="search-form">
    <div>
      <label for="sender">聊天对象:</label>
      <select name="sender" id="sender">
        <option value="">所有用户</option>
        <%
          Connection userConn = null;
          try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            userConn = DriverManager.getConnection(
                    "jdbc:sqlserver://10.211.55.7:1433;databaseName=webChat;" +
                            "encrypt=true;trustServerCertificate=true;sslProtocol=TLSv1;" +
                            "disableStatementPooling=true;cancelQueryTimeout=0;socketTimeout=120",
                    "sa", "123456");

            String userQuery = "SELECT DISTINCT " +
                    "CASE WHEN username = ? THEN receiver ELSE username END AS chatUser " +
                    "FROM Message " +
                    "WHERE (username = ? OR receiver = ?) AND username != receiver " +
                    "ORDER BY chatUser";
            PreparedStatement userStmt = userConn.prepareStatement(userQuery);
            userStmt.setString(1, currentUsername);
            userStmt.setString(2, currentUsername);
            userStmt.setString(3, currentUsername);
            ResultSet userRs = userStmt.executeQuery();

            while (userRs.next()) {
              String chatUser = userRs.getString("chatUser");
        %>
        <option value="<%= chatUser %>" <%= (chatUser.equals(request.getParameter("sender")) ? "selected" : "") %>><%= chatUser %></option>
        <%
            }
            userRs.close();
            userStmt.close();
          } catch (Exception e) {
            e.printStackTrace();
          } finally {
            if (userConn != null) {
              try {
                userConn.close();
              } catch (SQLException e) {
                e.printStackTrace();
              }
            }
          }
        %>
      </select>
    </div>

    <div>
      <label for="startDate">起始日期:</label>
      <input type="date" name="startDate" id="startDate"
             value="<%= request.getParameter("startDate") != null ? request.getParameter("startDate") : "" %>">
    </div>

    <div>
      <label for="endDate">结束日期:</label>
      <input type="date" name="endDate" id="endDate"
             value="<%= request.getParameter("endDate") != null ? request.getParameter("endDate") : "" %>">
    </div>

    <div class="search-button-container">
      <button type="submit">搜索</button>
    </div>
  </form>
  <%
    // 显示查询结果
    if (request.getMethod().equalsIgnoreCase("POST") && exportType == null) {
      Connection conn = null;
      try {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        conn = DriverManager.getConnection(
                "jdbc:sqlserver://10.211.55.7:1433;databaseName=webChat;" +
                        "encrypt=true;trustServerCertificate=true;sslProtocol=TLSv1;" +
                        "disableStatementPooling=true;cancelQueryTimeout=0;socketTimeout=120",
                "sa", "123456");

        String sender = request.getParameter("sender");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");

        StringBuilder sb = new StringBuilder();
        List<Object> params = new ArrayList<>();

        if (sender != null && !sender.isEmpty()) {
          // 有聊天对象选择
          sb.append("((username = ? AND (receiver = ? OR receiver = 'everyone')) OR (username = ? AND (receiver = ? OR receiver = 'everyone')))");
          params.add(sender);
          params.add(currentUsername);
          params.add(currentUsername);
          params.add(sender);
        } else {
          // 未选择聊天对象
          sb.append("((username <> ? AND (receiver = ? OR receiver = 'everyone')) OR (username = ?))");
          params.add(currentUsername);
          params.add(currentUsername);
          params.add(currentUsername);
        }

        if (startDate != null && !startDate.isEmpty()) {
          sb.append(" AND date >= ?");
          params.add(startDate);
        }

        if (endDate != null && !endDate.isEmpty()) {
          sb.append(" AND date <= ?");
          params.add(endDate);
        }

        // 包含 message_id
        String query = "SELECT message_id, username, message, receiver, date, file_name FROM Message WHERE " + sb.toString() + " ORDER BY date DESC";

        PreparedStatement pstmt = conn.prepareStatement(query);
        for (int i = 0; i < params.size(); i++) {
          pstmt.setObject(i + 1, params.get(i));
        }

        ResultSet rs = pstmt.executeQuery();
  %>
  <form method="post" action="ExportRecord.jsp">
    <table>
      <thead>
      <tr>
        <th style="width:80px; text-align:center;">
          <input type="checkbox" id="selectAll">
          <label for="selectAll" id="selectAllLabel">全选</label>
        </th>
        <th>发送人</th>
        <th>接收人</th>
        <th>消息</th>
        <th>附件</th> <!-- 新增附件列 -->
        <th>日期</th>
      </tr>
      </thead>
      <tbody>
      <%
        boolean hasResults = false;
        int displayMessageId = 0; // 用于前端展示的唯一ID
        while (rs.next()) {
          hasResults = true;
          displayMessageId++;
          int messageId = rs.getInt("message_id");
          String username = rs.getString("username");
          String receiver = rs.getString("receiver");
          String message = rs.getString("message");
          String date = rs.getString("date");
          String fileName = rs.getString("file_name");
      %>
      <tr>
        <td style="text-align:center;">
          <input type="checkbox" name="selectedRecords"
                 value="<%= username + "|" + receiver + "|" + message + "|" + date + "|" + fileName %>">
        </td>
        <td><%= username %></td>
        <td><%= receiver %></td>
        <td>
          <div class="message-cell">
            <%
              if (message.length() > 90) { // 18字符 * 5行 = 90字符
                String shortMessage = message.substring(0, 90);
            %>
            <%= shortMessage %>...
            <button type="button" class="toggle-button" id="toggle-<%= displayMessageId %>" onclick="toggleMessage('<%= displayMessageId %>')">查看更多</button>
            <div class="full-message" id="<%= displayMessageId %>"><%= message %></div>
            <%
              } else {
                out.print(message);
              }
            %>
          </div>
        </td>
        <td class="attachment-cell">
          <%
            if (fileName != null && !fileName.isEmpty()) {
              String displayName = fileName.length() > 15 ? fileName.substring(0, 15) + "..." : fileName;
          %>
          <a href="DownloadFileServlet?messageId=<%= messageId %>"
             target="_blank"
             title="<%= fileName %>">
            <%= displayName %>
            <% if(fileName.length() > 15) { %>
            <span class="dropdown-content"><%= fileName %></span>
            <% } %>
          </a>
          <%
          } else {
          %>
          -
          <%
            }
          %>
        </td>
        <td><%= date %></td>
      </tr>
      <% } %>
      <% if (!hasResults) { %>
      <tr>
        <td colspan="6">没有查询到聊天记录</td>
      </tr>
      <% } %>
      </tbody>
    </table>
    <div class="export-buttons">
      <button type="submit" name="exportType" value="txt">导出 TXT</button>
      <button type="submit" name="exportType" value="csv">导出 CSV</button>
      <button type="submit" name="exportType" value="excel">导出 Excel</button>
    </div>
  </form>

  <script>
    document.getElementById('selectAll').addEventListener('change', function() {
      const checkboxes = document.querySelectorAll('input[name="selectedRecords"]');
      checkboxes.forEach(checkbox => {
        checkbox.checked = this.checked;
      });
    });

    function toggleMessage(id) {
      var fullMessage = document.getElementById(id);
      var toggleBtn = document.getElementById("toggle-" + id);
      if (fullMessage.style.display === "none" || fullMessage.style.display === "") {
        fullMessage.style.display = "block";
        toggleBtn.innerText = "收起";
      } else {
        fullMessage.style.display = "none";
        toggleBtn.innerText = "查看更多";
      }
    }
  </script>

  <%
        rs.close();
        pstmt.close();
      } catch (Exception e) {
        e.printStackTrace();
      } finally {
        if (conn != null) {
          try {
            conn.close();
          } catch (SQLException e) {
            e.printStackTrace();
          }
        }
      }
    }
  %>
</div>
</body>
</html>
