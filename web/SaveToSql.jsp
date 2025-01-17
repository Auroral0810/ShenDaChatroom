<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ page import="java.io.*,java.util.*, javax.servlet.*, java.sql.*" %>
<%@ page import="java.security.Security" %>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>注册处理界面</title>
</head>
<body>
<%!
    // 辅助方法：清理数据并处理空值
    private String trimAndNullIfEmpty(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        return value.trim();
    }
%>
<%
    // 设置请求的字符编码为UTF-8
    request.setCharacterEncoding("UTF-8");

    // 获取表单数据
    String username = trimAndNullIfEmpty(request.getParameter("usrname"));
    String password = trimAndNullIfEmpty(request.getParameter("pass"));
    String gender = trimAndNullIfEmpty(request.getParameter("gender"));
    String person_name = trimAndNullIfEmpty(request.getParameter("person_name"));
    // 使用隐藏字段获取省市区的文本值
    String province = trimAndNullIfEmpty(request.getParameter("provinceText"));
    String city = trimAndNullIfEmpty(request.getParameter("cityText"));
    String district = trimAndNullIfEmpty(request.getParameter("districtText"));
    String tel = trimAndNullIfEmpty(request.getParameter("tel"));
    String postcode = trimAndNullIfEmpty(request.getParameter("postcode"));
    String bpcode = trimAndNullIfEmpty(request.getParameter("bpcode"));
    String fax = trimAndNullIfEmpty(request.getParameter("fax"));
    String hand = trimAndNullIfEmpty(request.getParameter("hand"));
    String IDcard = trimAndNullIfEmpty(request.getParameter("IDcard"));
    String email = trimAndNullIfEmpty(request.getParameter("email"));
    String homepg = trimAndNullIfEmpty(request.getParameter("homepg"));
    String quest = trimAndNullIfEmpty(request.getParameter("quest"));
    String answ = trimAndNullIfEmpty(request.getParameter("answ"));

    Connection conn = null;
    Statement stmt = null;

    try {
        // 配置安全属性
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

        // 创建SQL语句
        System.out.println("Creating statement...");
        stmt = conn.createStatement();

        // 构建插入UserInfo表的语句
        String userInfoSql = "INSERT INTO webChat.dbo.UserInfo (username, password, gender, person_name, province_city_district, tel, postcode, bpcode, fax, hand, IDcard, email, homepg, quest, answ) VALUES ('"
                + username + "', '" + password + "', '" + gender + "', '" + person_name + "', '"
                + (province != null ? province : "")
                + (city != null ? city : "")
                + (district != null ? district : "") + "', '"
                + tel + "', '" + postcode + "', '" + bpcode + "', '" + fax + "', '" + hand + "', '"
                + IDcard + "', '"
                + email + "', '" + homepg + "', '" + quest + "', '" + answ + "')";

        // 构建插入Login表的语句
        String loginSql = "INSERT INTO webChat.dbo.Login (username, password) VALUES ('" + username + "', '" + password + "')";

        // 执行更新
        int rowsAffectedUserInfo = 0;
        int rowsAffectedLogin = 0;

        // 先执行UserInfo表的插入
        if (username != null && password != null) {
            rowsAffectedUserInfo = stmt.executeUpdate(userInfoSql);
        }

        // 然后执行Login表的插入
        if (rowsAffectedUserInfo > 0) {
            rowsAffectedLogin = stmt.executeUpdate(loginSql);
        }

        // 检查是否两个表都成功插入
        if (rowsAffectedUserInfo > 0 && rowsAffectedLogin > 0) {
            response.sendRedirect("Loginbysql.jsp");
        } else {
            out.println("<script>alert('Failed to insert data into one or both tables.');</script>");
        }
    } catch (SQLException se) {
        // 处理JDBC错误
        se.printStackTrace();
    } catch (Exception e) {
        // 处理Class.forName错误和其他异常
        e.printStackTrace();
    } finally {
        // 关闭资源
        try {
            if (stmt != null) {
                stmt.close();
            }
        } catch (SQLException se2) {
            // 忽略关闭语句时的异常
        }
        try {
            if (conn != null) {
                conn.close();
            }
        } catch (SQLException se) {
            se.printStackTrace();
        }
    }
%>
</body>
</html>
