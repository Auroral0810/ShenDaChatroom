<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.sql.* , java.util.Date" %>
<%@ page import="java.security.Security" %>
<%
    String username = request.getParameter("username");
    String password = request.getParameter("password");

    String errorMessage = null;

    Integer errorCount = (Integer) session.getAttribute("errorCount");
    Long lockTime = (Long) session.getAttribute("lockTime");

    if (errorCount == null) {
        errorCount = 0;
    }

    // 检查账户是否被锁定
    if (lockTime != null) {
        long elapsed = System.currentTimeMillis() - lockTime;
        if (elapsed > 900000) {  // 锁定时间超过 15 分钟
            errorCount = 0;
            session.removeAttribute("lockTime");
            session.setAttribute("errorCount", errorCount);
        } else {
            long remainingTime = 900000 - elapsed;
            long seconds = remainingTime / 1000;
            long minutes = seconds / 60;
            seconds = seconds % 60;
            errorMessage = "账户被锁定，请等待 " + minutes + " 分 " + seconds + " 秒 后再试。";
        }
    }

    // 如果账户没有被锁定，继续进行用户名和密码验证
    if (errorMessage == null) {
        if (username != null && password != null) {
            if (username.trim().isEmpty()) {
                errorMessage = "用户名不能为空";
            } else if (password.trim().isEmpty()) {
                errorMessage = "密码不能为空";
            } else {
                // 使用 SQL Server JDBC 驱动
                Security.setProperty("jdk.tls.disabledAlgorithms", "");
                System.setProperty("https.protocols", "TLSv1");
                Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

                Connection conn = DriverManager.getConnection(
                        "jdbc:sqlserver://10.211.55.7:1433;databaseName=webChat;" +
                                "encrypt=true;" +
                                "trustServerCertificate=true;" +
                                "sslProtocol=TLSv1;" +
                                "disableStatementPooling=true;" +
                                "cancelQueryTimeout=0;" +
                                "socketTimeout=120",
                        "sa",
                        "123456");

                // 建立连接
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT * FROM webChat.dbo.Login WHERE username='" + username + "' AND password='" + password + "'");
                ResultSetMetaData rsmd = rs.getMetaData(); //创建ResultSetMetaData对象
                // 检查是否有匹配的结果
                if (rs.next()) {
                    session.setAttribute("errorCount", 0);
                    session.removeAttribute("lockTime");
                    rs.close(); //关闭ResultSet对象
                    stmt.close(); //关闭Statement对象
                    conn.close(); //关闭数据库连接对象
                    session.setAttribute("user", username);
                    // 判断是否为管理员账号
                    if ("YYF222090140".equals(username)) {
                        response.sendRedirect("AdminChat.jsp");
                    } else {
                        response.sendRedirect("Chat.jsp");
                    }
                    return;
                } else {
                    errorCount++;
                    session.setAttribute("errorCount", errorCount);
                    if (errorCount >= 3) {
                        session.setAttribute("lockTime", System.currentTimeMillis());  // 错误次数过多，设置锁定时间
                        errorMessage = "密码错误，尝试次数过多，请等待 15 分钟后再试。";
                    } else {
                        errorMessage = "密码错误，还有 " + (3 - errorCount) + " 次机会";
                    }
                }
                rs.close(); //关闭ResultSet对象
                stmt.close(); //关闭Statement对象
                conn.close(); //关闭数据库连接对象
            }
        }
    }
%>

<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>登录界面</title>
    <style>
        /* 背景渐变效果 */
        body {
            background: linear-gradient(45deg, #6a82fb, #fc5c7d);
            background-size: 400% 400%;
            animation: gradientBG 10s ease infinite;
            font-family: 'Roboto', Arial, sans-serif;
            color: #fff;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }

        @keyframes gradientBG {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }

        /* 半透明背景层 */
        .overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.6);
        }

        /* 登录框样式 */
        .form-container {
            position: relative;
            z-index: 2;
            background: rgba(255, 255, 255, 0.2);
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 15px 30px rgba(0, 0, 0, 0.3);
            width: 100%;
            max-width: 450px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            backdrop-filter: blur(5px);
        }

        h2 {
            font-size: 36px;
            margin-bottom: 20px;
            color: #fff;
            text-align: center;
        }

        label {
            display: block;
            font-size: 18px;
            margin-bottom: 8px;
            color: #fff;
        }

        input[type="text"], input[type="password"] {
            width: 100%;
            padding: 14px;
            margin-bottom: 20px;
            border: none;
            border-radius: 25px;
            background: rgba(255, 255, 255, 0.3);
            color: #fff;
            font-size: 16px;
            transition: background 0.3s ease;
        }

        input[type="text"]:focus, input[type="password"]:focus {
            background: rgba(255, 255, 255, 0.5);
            outline: none;
        }

        .button-group {
            display: flex;
            justify-content: space-between;
            align-items: center;
            width: 100%;
        }

        input[type="submit"], input[type="reset"], input[type="button"] {
            padding: 14px 30px;
            font-size: 16px;
            border: none;
            border-radius: 25px;
            cursor: pointer;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            display: inline-block;
        }

        input[type="submit"] {
            background-color: #28a745;
            color: white;
        }

        input[type="submit"]:hover {
            background-color: #218838;
            transform: scale(1.1);
            box-shadow: 0px 4px 20px rgba(0, 0, 0, 0.1);
        }

        input[type="reset"] {
            background-color: #dc3545;
            color: white;
        }

        input[type="reset"]:hover {
            background-color: #c82333;
            transform: scale(1.1);
            box-shadow: 0px 4px 20px rgba(0, 0, 0, 0.1);
        }

        input[type="button"] {
            background-color: #007bff;
            color: white;
        }

        input[type="button"]:hover {
            background-color: #0069d9;
            transform: scale(1.1);
            box-shadow: 0px 4px 20px rgba(0, 0, 0, 0.1);
        }

        /* 错误提示样式 */
        .error-message {
            background-color: rgba(220, 53, 69, 0.9);
            color: #fff;
            padding: 12px 25px;
            border-radius: 10px;
            margin-top: 20px;
            text-align: center;
            animation: fadeIn 0.5s ease-in-out;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* 图片和按钮排版 */
        .image-container {
            margin-top: 20px;
            text-align: center;
        }

        .image-container img {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            margin-top: 10px;
        }
    </style>
</head>
<body>

<div class="overlay"></div>

<div class="form-container">
    <h2>登录</h2>
    <form method="post" action="Loginbysql.jsp">
        <label for="username">用户名：</label>
        <input type="text" id="username" name="username" placeholder="请输入用户名" required>

        <label for="password">密码：</label>
        <input type="password" id="password" name="password" placeholder="请输入密码" required>

        <div class="button-group">
            <input type="submit" value="登录">
            <input type="reset" value="重置">
            <input type="button" value="注册" onclick="window.location.href='RegisterToSql.jsp'">
        </div>
    </form>


    <%
        if (errorMessage != null) {
            out.println("<div class='error-message'>" + errorMessage + "</div>");
        }
    %>
</div>

</body>
</html>
