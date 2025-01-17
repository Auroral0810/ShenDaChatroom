<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" import="java.util.*,java.sql.*,java.net.URLEncoder"%>
<%@ page import="java.security.Security" %>
<%@ page import="java.util.Base64" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="refresh" content="10">
    <title>审大聊天室 - 消息列表</title>
    <!--<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">-->
    <link href="./static/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.10.5/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        /* 保持原有的CSS样式不变 */
        html, body {
            height: 100%;
            margin: 0;
            padding: 0;
            background-color: #f4f6f9;
            font-family: Arial, sans-serif;
        }

        .header {
            background-color: #343a40;
            color: white;
            padding: 15px 20px;
            text-align: center;
            font-size: 1.5em;
            font-weight: bold;
            border-bottom: 2px solid #dee2e6;
        }
        .chat-container {
            display: flex;
            flex-direction: row;
            height: calc(100vh - 60px); /* Subtracting header height */
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            box-sizing: border-box;
        }
        .user-list {
            width: 18%;
            border-right: 2px solid #dee2e6;
            padding-right: 15px;
            overflow-y: auto;
            background-color: #ffffff;
            border-radius: 8px;
        }
        .user-list::-webkit-scrollbar {
            width: 8px;
        }
        .user-list::-webkit-scrollbar-track {
            background: #f1f1f1;
        }
        .user-list::-webkit-scrollbar-thumb {
            background: #888;
            border-radius: 4px;
        }
        .user-list::-webkit-scrollbar-thumb:hover {
            background: #555;
        }
        .user-item {
            padding: 10px;
            margin-bottom: 10px;
            background-color: #ffffff;
            border-radius: 5px;
            cursor: pointer;
            transition: background-color 0.3s, border-left 0.3s;
            border-left: 4px solid transparent;
        }
        .user-item:hover, .user-item.active {
            background-color: #e9ecef;
            border-left: 4px solid #007bff;
        }
        .user-item.public-chat {
            border-left: 4px solid #28a745; /* Green border for public chat */
        }
        .user-item.public-chat.active {
            background-color: #e9ecef;
            border-left: 4px solid #28a745;
        }
        .message-list {
            flex-grow: 1;
            overflow-y: auto;
            padding-left: 15px;
            display: flex;
            flex-direction: column;
            gap: 15px;
            background-color: #ffffff;
            border-radius: 8px;
            padding: 20px;
            box-sizing: border-box;
            border: 2px solid #dee2e6;
        }
        .message-list::-webkit-scrollbar {
            width: 8px;
        }
        .message-list::-webkit-scrollbar-track {
            background: #f1f1f1;
        }
        .message-list::-webkit-scrollbar-thumb {
            background: #888;
            border-radius: 4px;
        }
        .message-list::-webkit-scrollbar-thumb:hover {
            background: #555;
        }
        .message-item {
            display: flex;
            align-items: flex-start;
            gap: 10px;
        }
        .avatar {
            width: 40px;
            height: 40px;
            background-color: #6c757d;
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            font-size: 1.2em;
            flex-shrink: 0;
        }
        .message-content {
            /* Fixed width for message boxes */
            max-width: 500px;
            /* Alternatively, use max-width if you want some flexibility:
            max-width: 300px;
            */
            display: flex;
            flex-direction: column;
        }
        .message-text {
            background-color: #f8f9fa;
            padding: 10px 15px;
            border-radius: 15px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            color: #34495e;
            word-wrap: break-word; /* Ensure text wraps within fixed width */
            /* Optional: add overflow handling
            overflow-wrap: break-word;
            */
        }
        .message-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 5px;
        }
        .message-sender {
            font-weight: bold;
            color: #2c3e50;
        }
        .message-time {
            font-size: 0.75em;
            color: #7f8c8d;
            margin-top: 3px;
            align-self: flex-end;
        }
        /* Current user's message style */
        .current-user-message {
            flex-direction: row-reverse;
        }
        .current-user-message .avatar {
            background-color: #007bff;
        }
        .current-user-message .message-content {
            align-items: flex-end;
        }
        .current-user-message .message-text {
            background-color: #d1ecf1;
        }
        /* Other users' message style */
        .other-user-message .avatar {
            background-color: #6c757d;
        }
        .file-preview img {
            max-width: 100%;
            height: auto;
            border-radius: 5px;
            cursor: pointer; /* 鼠标悬停变为手型 */
        }
        .file-download-link {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            background-color: #28a745;
            color: white;
            padding: 5px 10px;
            border-radius: 5px;
            text-decoration: none;
            font-size: 0.9em;
            margin-top: 5px;
        }
        .file-download-link:hover {
            background-color: #218838;
        }
        .file-download-link i {
            font-size: 1.2em;
        }

        /* 图片放大弹窗样式 */
        .image-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.8);
            justify-content: center;
            align-items: center;
            z-index: 1000;
        }
        .image-modal img {
            max-width: 90%;
            max-height: 90%;
            border-radius: 10px;
        }
        .image-modal-close {
            position: absolute;
            top: 20px;
            right: 20px;
            color: white;
            font-size: 2em;
            cursor: pointer;
        }
        /* Responsive adjustments */
        @media (max-width: 768px) {
            .chat-container {
                flex-direction: column;
            }
            .user-list {
                width: 100%;
                border-right: none;
                border-bottom: 2px solid #dee2e6;
                padding-right: 0;
                padding-bottom: 15px;
            }
            .message-content {
                width: 100%;
                max-width: 100%;
            }
        }
        /* 文件下载按钮样式 */
        .file-download-link {
            margin-top: 5px;
            text-decoration: none;
            color: #007bff;
            font-size: 0.9em;
        }
        .file-download-link:hover {
            text-decoration: underline;
        }
        .file-preview img {
            max-width: 100%;
            height: auto;
            border-radius: 5px;
            margin-top: 5px;
        }
        .file-download-button {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            background-color: #28a745; /* Green background */
            color: white;
            padding: 5px 10px;
            border-radius: 5px;
            text-decoration: none;
            font-size: 0.9em;
            margin-top: 5px;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        .file-download-button:hover {
            background-color: #218838; /* Darker green on hover */
        }
        .file-download-button i {
            font-size: 1.2em;
        }

    </style>
</head>

<body>
<!-- Page Header -->
<div class="header">
    审大聊天室
</div>
<div class="chat-container">
    <!-- User List -->
    <div class="user-list">
        <%
            String currentUsername = (String) session.getAttribute("user");
            String selectedUser = request.getParameter("selectedUser"); // Get selected user
            if (selectedUser == null && currentUsername != null) {
                // Default selection logic (optional)
                // Currently, user needs to manually select
            }

            Connection connection = null;
            try {
                Security.setProperty("jdk.tls.disabledAlgorithms", "");
                System.setProperty("https.protocols", "TLSv1");
                Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

                connection = DriverManager.getConnection(
                        "jdbc:sqlserver://10.211.55.7:1433;databaseName=webChat;" +
                                "encrypt=true;" +
                                "trustServerCertificate=true;" +
                                "sslProtocol=TLSv1;" +
                                "disableStatementPooling=true;" +
                                "cancelQueryTimeout=0;" +
                                "socketTimeout=120",
                        "sa",
                        "123456");

                // Query chat partners from Login table
                String userListSql = "SELECT DISTINCT username FROM Login WHERE username != ?";

                PreparedStatement userListStmt = connection.prepareStatement(userListSql);
                userListStmt.setString(1, currentUsername);
                ResultSet userRs = userListStmt.executeQuery();

                // Store chat partners
                List<String> chatPartners = new ArrayList<>();
                while(userRs.next()) {
                    String chatPartner = userRs.getString("username");
                    if (chatPartner == null || chatPartner.equalsIgnoreCase("everyone") || chatPartner.equals(currentUsername)) {
                        continue; // Skip 'everyone', null, and self
                    }
                    chatPartners.add(chatPartner);
                }
                userRs.close();
                userListStmt.close();

                // Sort chat partners
                Collections.sort(chatPartners, String.CASE_INSENSITIVE_ORDER);

                // Add "Public Chat" option
        %>
        <!-- Public Chat Option -->
        <div class="user-item <%= ("everyone".equals(selectedUser)) ? "active public-chat" : "" %>">
            <a href="?selectedUser=everyone" style="text-decoration: none; color: inherit;">
                <div class="d-flex align-items-center">
                    <div class="avatar" style="background-color: #28a745;">
                        公
                    </div>
                    <div class="ms-2">公屏</div>
                </div>
            </a>
        </div>
        <hr>
        <!-- Chat Partners List -->
        <%
            for(String chatPartner : chatPartners) {
        %>
        <div class="user-item <%= (chatPartner.equals(selectedUser)) ? "active" : "" %>">
            <a href="?selectedUser=<%= URLEncoder.encode(chatPartner, "UTF-8") %>" style="text-decoration: none; color: inherit;">
                <div class="d-flex align-items-center">
                    <div class="avatar">
                        <%= (chatPartner != null && chatPartner.length() > 0) ? chatPartner.substring(0, 1).toUpperCase() : "?" %>
                    </div>
                    <div class="ms-2"><%= chatPartner %></div>
                </div>
            </a>
        </div>
        <%
            }
        } catch(Exception e) {
            e.printStackTrace();
        %>
        <p>网络繁忙，请多刷新几次。</p>
        <%
            } finally {
                if(connection != null) {
                    try {
                        connection.close();
                    } catch(SQLException e) {
                        e.printStackTrace();
                    }
                }
            }
        %>
    </div>

    <!-- Message List -->
    <div class="message-list">
        <%
            if (currentUsername == null) {
        %>
        <p>请先登录。</p>
        <%
        } else {
            Connection conn = null;
            try {
                Security.setProperty("jdk.tls.disabledAlgorithms", "");
                System.setProperty("https.protocols", "TLSv1");
                Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

                conn = DriverManager.getConnection(
                        "jdbc:sqlserver://10.211.55.7:1433;databaseName=webChat;" +
                                "encrypt=true;" +
                                "trustServerCertificate=true;" +
                                "sslProtocol=TLSv1;" +
                                "disableStatementPooling=true;" +
                                "cancelQueryTimeout=0;" +
                                "socketTimeout=120",
                        "sa",
                        "123456");

                String sql;
                PreparedStatement pstmt;

                if (selectedUser != null && !selectedUser.isEmpty()) {
                    if ("everyone".equals(selectedUser)) {
                        // Query public messages
                        sql = "SELECT message_id, username, message, date, receiver, file_data, file_name, file_type FROM Message " +
                                "WHERE receiver = 'everyone' " +
                                "ORDER BY date ASC";
                        pstmt = conn.prepareStatement(sql, ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
                    } else {
                        // Query private chat messages
                        sql = "SELECT message_id, username, message, date, receiver, file_data, file_name, file_type FROM Message " +
                                "WHERE (username = ? AND receiver = ?) OR (username = ? AND receiver = ?) " +
                                "ORDER BY date ASC";
                        pstmt = conn.prepareStatement(sql, ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
                        pstmt.setString(1, currentUsername);
                        pstmt.setString(2, selectedUser);
                        pstmt.setString(3, selectedUser);
                        pstmt.setString(4, currentUsername);
                    }
                } else {
                    // Default to public chat if no user is selected
                    selectedUser = "everyone";
                    sql = "SELECT message_id, username, message, date, receiver, file_data, file_name, file_type FROM Message " +
                            "WHERE receiver = 'everyone' " +
                            "ORDER BY date ASC";
                    pstmt = conn.prepareStatement(sql, ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
                }

                ResultSet rs = pstmt.executeQuery();

                while(rs.next()) {
                    int messageId = rs.getInt("message_id");
                    String username = rs.getString("username");
                    String message = rs.getString("message");
                    String date = rs.getString("date");
                    String receiver = rs.getString("receiver");
                    byte[] fileData = rs.getBytes("file_data");
                    String fileName = rs.getString("file_name");
                    String fileType = rs.getString("file_type");

                    boolean isCurrentUser = false;
                    boolean isMessageFromSelectedUser = false;

                    if ("everyone".equals(selectedUser)) {
                        // Public message
                        isCurrentUser = username != null && username.equals(currentUsername);
                    } else {
                        // Private message
                        if (username != null && username.equals(currentUsername) && receiver.equals(selectedUser)) {
                            isCurrentUser = true;
                        }
                        if (username != null && username.equals(selectedUser) && receiver.equals(currentUsername)) {
                            isMessageFromSelectedUser = true;
                        }
                    }

                    // Determine if the message should be displayed
                    boolean shouldDisplay = false;
                    if ("everyone".equals(selectedUser)) {
                        shouldDisplay = true; // Show all public messages
                    } else {
                        shouldDisplay = isCurrentUser || isMessageFromSelectedUser;
                    }

                    if (shouldDisplay) {
        %>
        <div class="message-item <%= isCurrentUser ? "current-user-message" : "other-user-message" %>">
            <div class="avatar">
                <%=(username != null && username.length() > 0) ? username.substring(0, 1).toUpperCase() : "?"%>
            </div>
            <div class="message-content">
                <div class="message-header">
                    <span class="message-sender"><%= username %></span>
                </div>
                <% if (message != null && !message.trim().isEmpty()) { %>
                <div class="message-text"><%= message %></div>
                <% } %>

                <%
                    if (fileData != null && fileData.length > 0 && fileName != null && !fileName.isEmpty()) {
                        String lowerFileType = fileType.toLowerCase();
                        if (lowerFileType.startsWith("image/")) {
                            // 显示图片并提供下载按钮
                            String base64Image = Base64.getEncoder().encodeToString(fileData);
                %>
                <div class="file-preview">
                    <img src="data:<%= fileType %>;base64,<%= base64Image %>" alt="<%= fileName %>"
                         onclick="showImageModal(this.src)">
                    <a href="DownloadFileServlet?messageId=<%= messageId %>" class="file-download-link" download>
                        <i class="bi bi-download"></i>
                    </a>
                </div>

                <%
                } else {
                    // 下载其他类型文件
                %>
                <a href="DownloadFileServlet?messageId=<%= messageId %>" class="file-download-link" download>
                    <i class="bi bi-download"></i> <%= fileName %>
                </a>
                <%
                        }
                    }
                %>


                <div class="message-time"><%= date %></div>
            </div>
        </div>
        <%
                }
            }
            rs.close();
            pstmt.close();
        } catch (Exception e) {
            e.printStackTrace();
        %>
        <p>网络繁忙，请多刷新几次。</p>
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
</div>
<script src="./static/js/bootstrap.bundle.min.js"></script>
<!-- <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script> -->
<script>
    window.onload = function() {
        var messageList = document.querySelector('.message-list');
        messageList.scrollTop = messageList.scrollHeight;
    }
</script>

<!-- 图片放大弹窗 -->
<div class="image-modal" id="imageModal">
    <span class="image-modal-close" onclick="closeImageModal()">&times;</span>
    <img id="modalImage" src="" alt="Preview">
</div>

<script>
    // 显示图片放大弹窗
    function showImageModal(src) {
        var modal = document.getElementById('imageModal');
        var modalImage = document.getElementById('modalImage');
        modalImage.src = src;
        modal.style.display = 'flex';
    }

    // 关闭图片放大弹窗
    function closeImageModal() {
        var modal = document.getElementById('imageModal');
        modal.style.display = 'none';
    }
</script>
</body>
</html>
