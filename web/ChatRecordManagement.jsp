<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*,java.util.*,java.io.*,java.net.URLEncoder" %>
<%@ page import="java.security.Security" %>
<%
  request.setCharacterEncoding("UTF-8");
  Security.setProperty("jdk.tls.disabledAlgorithms", "");
  System.setProperty("https.protocols", "TLSv1");

  String currentUsername = (String) session.getAttribute("user");

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
      String includeSensitive = request.getParameter("includeSensitive");

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

      // 如果点击了“查询带敏感词的记录”，增加对消息内容的检查
      if ("true".equals(includeSensitive)) {
        sb.append(" AND message LIKE ?");
        params.add("%<span style='font-size: small; color: red;'>（请文明用语！）</span>"); // 替换为实际的敏感词
      }

      String whereClause = sb.toString().isEmpty() ? "1=1" : sb.toString();
      String query = "SELECT message_id, username, message, receiver, date, file_name FROM Message WHERE " + whereClause + " ORDER BY date DESC";

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
      session.setAttribute("selectedRecords", request.getParameterValues("selectedRecords"));

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
<%

  String action = request.getParameter("action");
  String messageInfo = null;

  // 删除操作
  if ("delete".equals(action)) {
    String messageIdParam = request.getParameter("messageId");
    if (messageIdParam != null && !messageIdParam.isEmpty()) {
      int messageId;
      try {
        messageId = Integer.parseInt(messageIdParam);
      } catch (NumberFormatException e) {
        messageInfo = "无效的消息ID格式！";
        messageId = -1;
      }

      if (messageId != -1) {
        Connection dConn = null;
        PreparedStatement dStmt = null;
        try {
          Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
          dConn = DriverManager.getConnection(
                  "jdbc:sqlserver://10.211.55.7:1433;databaseName=webChat;" +
                          "encrypt=true;trustServerCertificate=true;sslProtocol=TLSv1;" +
                          "disableStatementPooling=true;cancelQueryTimeout=0;socketTimeout=120",
                  "sa", "123456");
          String delSql = "DELETE FROM Message WHERE message_id = ?";
          dStmt = dConn.prepareStatement(delSql);
          dStmt.setInt(1, messageId);
          int rows = dStmt.executeUpdate();
          if (rows > 0) {
            messageInfo = "删除成功！";
            // 页面刷新
            response.sendRedirect(request.getRequestURI());
            return; // 确保后续代码不再执行
          } else {
            messageInfo = "删除失败，未找到该记录。";
          }
        } catch(Exception e) {
          e.printStackTrace();
          messageInfo = "删除时发生错误：" + e.getMessage();
        } finally {
          if (dStmt != null) try { dStmt.close(); } catch (SQLException e){}
          if (dConn != null) try { dConn.close(); } catch (SQLException e){}
        }
      }
    }
  }
%>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>聊天记录管理</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
  <style>
    /* 重置默认样式 */
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    body {
      font-family: 'Poppins', sans-serif;
      margin: 0;
      padding: 0;
      background: linear-gradient(to bottom right, #86A8E7, #91EAE4);
      color: #333;
      background-attachment: fixed;
      min-height:100vh;
    }

    .container-main {
      max-width: 1100px;
      margin: 40px auto;
      background: rgba(255,255,255,0.85);
      backdrop-filter: blur(10px);
      border-radius: 12px;
      padding: 20px 30px;
      box-shadow: 0 10px 30px rgba(0,0,0,0.1);
    }

    header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-bottom: 20px;
    }

    header h2 {
      font-weight: 600;
      margin: 0;
      color: #2c3e50;
    }

    .return-button button {
      background: #e74c3c;
      color: #fff;
      border: none;
      padding: 8px 14px;
      border-radius: 6px;
      font-weight: 500;
      cursor: pointer;
      transition: background 0.3s;
    }

    .return-button button:hover {
      background: #c0392b;
    }

    form.search-form {
      margin-bottom: 20px;
      display: flex;
      flex-wrap: wrap;
      gap: 15px 20px;
      align-items: center;
    }

    form.search-form label {
      font-weight: 500;
      margin-right: 6px;
      color: #333;
    }

    form.search-form select,
    form.search-form input[type="date"],
    form.search-form button[type="submit"] {
      padding: 6px 12px;
      border: 1px solid #ccc;
      border-radius: 6px;
      font-size: 14px;
    }

    .btn-search {
      background: #3498db;
      color: #fff;
      border: none;
      font-weight: 500;
      cursor: pointer;
      transition: background 0.3s;
    }

    .btn-search:hover {
      background: #2980b9;
    }

    .btn-sensitive {
      background: #f39c12;
      color:#fff;
      border:none;
      padding:6px 12px;
      border-radius:6px;
      font-weight:500;
      cursor:pointer;
      transition: background 0.3s;
    }

    .btn-sensitive:hover {
      background:#d35400;
    }

    table {
      width: 100%;
      border-collapse: collapse;
      margin-top: 20px;
      border-radius: 8px;
      overflow: hidden;
      font-size:14px;
    }

    th, td {
      border: 1px solid #ddd;
      padding: 12px 10px;
      text-align: left;
      background: #fff;
    }

    th {
      background-color: #f5f5f5;
      font-weight: 600;
    }

    #selectAllLabel {
      cursor: pointer;
      user-select: none;
      font-weight: 500;
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

    td[colspan="7"] {
      background: #fafafa;
      color: #999;
      text-align:center;
    }

    .no-result {
      text-align:center;
      color:#999;
      font-size:14px;
      padding:20px 0;
    }

    .msg {
      margin-top:10px;
      color:#2980b9;
      font-weight:500;
    }

    /* 统一删除按钮样式 */
    .btn-delete {
      background:#e74c3c;
      border:none;
      color:#fff;
      padding:6px 10px;
      border-radius:6px;
      cursor:pointer;
      font-size:13px;
      margin-right:5px;
      transition: background 0.3s;
    }

    .btn-delete:hover {
      background:#c0392b;
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

    function confirmDelete() {
      return confirm("确定要删除这条记录吗？");
    }

    function checkExport() {
      const checkboxes = document.querySelectorAll('input[name="selectedRecords"]:checked');
      if (checkboxes.length === 0) {
        alert("请至少选择一条记录进行导出！");
        return false;
      }
      return true;
    }
  </script>
</head>
<body>
<div class="container-main">
  <header>
    <h2>聊天记录管理</h2>

  </header>

  <%
    String sender = request.getParameter("sender");
    String startDate = request.getParameter("startDate");
    String endDate = request.getParameter("endDate");
    String includeSensitive = request.getParameter("includeSensitive");
  %>

  <!-- 搜索表单 -->
  <form method="post" action="" class="search-form">
    <div>
      <label>聊天对象:</label>
      <select name="sender">
        <option value="">所有用户</option>
        <%
          Connection lConn = null;
          try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            lConn = DriverManager.getConnection(
                    "jdbc:sqlserver://10.211.55.7:1433;databaseName=webChat;" +
                            "encrypt=true;trustServerCertificate=true;sslProtocol=TLSv1;" +
                            "disableStatementPooling=true;cancelQueryTimeout=0;socketTimeout=120",
                    "sa", "123456");
            Statement lStmt = lConn.createStatement();
            ResultSet lRs = lStmt.executeQuery("SELECT username FROM Login ORDER BY username ASC");
            while (lRs.next()) {
              String uname = lRs.getString("username");
        %>
        <option value="<%= uname %>" <%= (uname.equals(sender))?"selected":"" %>><%= uname %></option>
        <%
            }
            lRs.close();
            lStmt.close();
          } catch(Exception e) {
            e.printStackTrace();
          } finally {
            if (lConn != null) try {lConn.close();} catch(SQLException ex){}
          }
        %>
      </select>
    </div>

    <div>
      <label>起始日期:</label>
      <input type="date" name="startDate" value="<%= (startDate!=null?startDate:"") %>">
    </div>

    <div>
      <label>结束日期:</label>
      <input type="date" name="endDate" value="<%= (endDate!=null?endDate:"") %>">
    </div>

    <div>
      <button type="submit" name="action" value="search" class="btn-search">搜索</button>
      <button type="submit" name="includeSensitive" value="true" class="btn-sensitive">查询带敏感词的记录</button>
    </div>
  </form>


  <% if (messageInfo != null) { %>
  <div class="msg"><%= messageInfo %></div>
  <% } %>

  <%
    boolean performQuery = request.getMethod().equalsIgnoreCase("POST") && !"delete".equals(action) && !"update".equals(action)
            && exportType == null;

    if (!performQuery && (action == null) && exportType == null) {
      // 初次加载或非POST请求时，显示所有记录
      performQuery = true;
    }

    if (performQuery) {
      Connection conn = null;
      try {
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        conn = DriverManager.getConnection(
                "jdbc:sqlserver://10.211.55.7:1433;databaseName=webChat;" +
                        "encrypt=true;trustServerCertificate=true;sslProtocol=TLSv1;" +
                        "disableStatementPooling=true;cancelQueryTimeout=0;socketTimeout=120",
                "sa", "123456");

        List<String> queryConditions = new ArrayList<>();
        List<Object> params = new ArrayList<>();

        // 用户逻辑修改：
        if (sender != null && !sender.isEmpty()) {
          queryConditions.add("(username = ? OR receiver = ? OR receiver = 'everyone')");
          params.add(sender);
          params.add(sender);
        }

        if (startDate != null && !startDate.isEmpty()) {
          queryConditions.add("date >= ?");
          params.add(startDate);
        }

        if (endDate != null && !endDate.isEmpty()) {
          queryConditions.add("date <= ?");
          params.add(endDate);
        }

        // 如果点击了“查询带敏感词的记录”，增加对消息内容的检查
        if ("true".equals(includeSensitive)) {
          queryConditions.add("message LIKE ?");
          params.add("%<span style='font-size: small; color: red;'>（请文明用语！）</span>"); // 替换为实际的敏感词
        }

        String whereClause = queryConditions.isEmpty() ? "1=1" : String.join(" AND ", queryConditions);
        String query = "SELECT message_id, username, message, receiver, date, file_name FROM Message WHERE " + whereClause + " ORDER BY date DESC";

        PreparedStatement pstmt = conn.prepareStatement(query);
        for (int i = 0; i < params.size(); i++) {
          pstmt.setObject(i + 1, params.get(i));
        }

        ResultSet rs = pstmt.executeQuery();
  %>
  <form method="post" action="ExportRecord.jsp">
    <!-- 保持搜索参数 -->
    <input type="hidden" name="sender" value="<%= (sender!=null?sender:"") %>">
    <input type="hidden" name="startDate" value="<%= (startDate!=null?startDate:"") %>">
    <input type="hidden" name="endDate" value="<%= (endDate!=null?endDate:"") %>">
    <input type="hidden" name="includeSensitive" value="<%= (includeSensitive != null ? includeSensitive : "") %>">

    <table>
      <thead>
      <tr>
        <th>
          <input type="checkbox" id="selectAll">
          <label for="selectAll" id="selectAllLabel">全选</label>
        </th>
        <th>发送人</th>
        <th>接收人</th>
        <th>消息</th>
        <th>附件</th> <!-- 新增附件列 -->
        <th>日期</th>
        <th>操作</th>
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
          String msg = rs.getString("message");
          String date = rs.getString("date");
          String fileName = rs.getString("file_name");
      %>
      <tr>
        <td style="text-align:center;">
          <input type="checkbox" name="selectedRecords"
                 value="<%= username + "|" + receiver + "|" + msg + "|" + date + "|" + fileName %>">
        </td>
        <td><%= username %></td>
        <td><%= receiver %></td>
        <td>
          <div class="message-cell">
            <%
              if (msg.length() > 90) { // 18字符 * 5行 = 90字符
                String shortMessage = msg.substring(0, 90);
            %>
            <%= shortMessage %>...
            <button type="button" class="toggle-button" id="toggle-<%= displayMessageId %>" onclick="toggleMessage('<%= displayMessageId %>')">查看更多</button>
            <div class="full-message" id="<%= displayMessageId %>"><%= msg %></div>
            <%
              } else {
                out.print(msg);
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
        <td>
          <form method="post" action="" style="display:inline;" onsubmit="return confirmDelete();">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="messageId" value="<%= messageId %>">
            <button type="submit" class="btn-delete">删除</button>
          </form>
        </td>
      </tr>
      <% } %>
      <% if (!hasResults) { %>
      <tr>
        <td colspan="7" class="no-result">没有查询到聊天记录</td>
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

  </script>
  <%
    rs.close();
    pstmt.close();
  } catch (Exception e) {
    e.printStackTrace();
  %>
  <p style="color:red;">查询时出错：<%= e.getMessage() %></p>
  <%
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
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
