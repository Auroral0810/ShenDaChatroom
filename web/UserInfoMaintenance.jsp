<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" import="java.util.*,java.sql.*"%>
<%@ page import="java.security.Security" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>用户信息维护</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <style>
        body {
            background-color: #f4f6f9;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 20px;
        }
        .container {
            background: #ffffff;
            border-radius: 8px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
            padding: 20px;
        }
        .user-list {
            max-height: 300px;
            overflow-y: auto;
            margin-bottom: 20px;
        }
        .user-list table {
            width: 100%;
        }
        .user-list table th, .user-list table td {
            padding: 8px;
            border-bottom: 1px solid #ddd;
        }

        .form-label {
            font-weight: 500;
        }

        .message {
            margin-top: 15px;
        }
    </style>
</head>
<body>
<div class="container">
    <h2>用户信息维护</h2>
    <hr>
    <%

        request.setCharacterEncoding("UTF-8");
        String selectedUser = request.getParameter("selectedUser");
        String action = request.getParameter("action");
        String message = null;

        // 获取表单提交的用户信息字段（不包含password）
        String gender = request.getParameter("gender");
        String dname = request.getParameter("dname");
        String province_city_district = request.getParameter("province_city_district");
        String person_name = request.getParameter("person_name");
        String tel = request.getParameter("tel");
        String postcode = request.getParameter("postcode");
        String bpcode = request.getParameter("bpcode");
        String fax = request.getParameter("fax");
        String hand = request.getParameter("hand");
        String IDcard = request.getParameter("IDcard");
        String email = request.getParameter("email");
        String homepg = request.getParameter("homepg");
        String quest = request.getParameter("quest");
        String answ = request.getParameter("answ");

        // 当管理员提交更新时（不更新密码）
        if ("update".equals(action)) {
            selectedUser = request.getParameter("username");
            Connection updateConn = null;
            PreparedStatement updatePstmt = null;
            try {
                Security.setProperty("jdk.tls.disabledAlgorithms", "");
                System.setProperty("https.protocols", "TLSv1");
                Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
                updateConn = DriverManager.getConnection(
                        "jdbc:sqlserver://10.211.55.7:1433;databaseName=webChat;" +
                                "encrypt=true;trustServerCertificate=true;sslProtocol=TLSv1;" +
                                "disableStatementPooling=true;cancelQueryTimeout=0;socketTimeout=120",
                        "sa", "123456");

                // 不修改password字段，只更新其他字段
                String updateSql = "UPDATE webChat.dbo.UserInfo SET gender=?, dname=?, province_city_district=?," +
                        " person_name=?, tel=?, postcode=?, bpcode=?, fax=?, hand=?, IDcard=?, email=?," +
                        " homepg=?, quest=?, answ=? WHERE username=?";
                updatePstmt = updateConn.prepareStatement(updateSql);
                updatePstmt.setString(1, gender);
                updatePstmt.setString(2, dname);
                updatePstmt.setString(3, province_city_district);
                updatePstmt.setString(4, person_name);
                updatePstmt.setString(5, tel);
                updatePstmt.setString(6, postcode);
                updatePstmt.setString(7, bpcode);
                updatePstmt.setString(8, fax);
                updatePstmt.setString(9, hand);
                updatePstmt.setString(10, IDcard);
                updatePstmt.setString(11, email);
                updatePstmt.setString(12, homepg);
                updatePstmt.setString(13, quest);
                updatePstmt.setString(14, answ);
                updatePstmt.setString(15, selectedUser);

                int rows = updatePstmt.executeUpdate();
                if (rows > 0) {
                    message = "用户信息更新成功！";
                } else {
                    message = "用户信息更新失败，请确认用户是否存在。";
                }

            } catch (Exception e) {
                e.printStackTrace();
                message = "发生错误：" + e.getMessage();
            } finally {
                if (updatePstmt != null) {
                    try { updatePstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                }
                if (updateConn != null) {
                    try { updateConn.close(); } catch (SQLException e) { e.printStackTrace(); }
                }
            }
        }

        // 定义变量用于显示在表单中的信息（不包含password）
        String db_gender = "";
        String db_dname = "";
        String db_province_city_district = "";
        String db_person_name = "";
        String db_tel = "";
        String db_postcode = "";
        String db_bpcode = "";
        String db_fax = "";
        String db_hand = "";
        String db_IDcard = "";
        String db_email = "";
        String db_homepg = "";
        String db_quest = "";
        String db_answ = "";

        // 如果选择了用户或刚更新完用户信息，则加载用户信息（不加载password字段）
        if (selectedUser != null && !selectedUser.isEmpty()) {
            Connection userConn = null;
            PreparedStatement userPstmt = null;
            ResultSet userRs = null;
            try {
                Security.setProperty("jdk.tls.disabledAlgorithms", "");
                System.setProperty("https.protocols", "TLSv1");
                Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
                userConn = DriverManager.getConnection(
                        "jdbc:sqlserver://10.211.55.7:1433;databaseName=webChat;" +
                                "encrypt=true;trustServerCertificate=true;sslProtocol=TLSv1;" +
                                "disableStatementPooling=true;cancelQueryTimeout=0;socketTimeout=120",
                        "sa", "123456");

                String userSql = "SELECT username, gender, dname, province_city_district, person_name," +
                        " tel, postcode, bpcode, fax, hand, IDcard, email, homepg, quest, answ" +
                        " FROM webChat.dbo.UserInfo WHERE username=?";
                userPstmt = userConn.prepareStatement(userSql);
                userPstmt.setString(1, selectedUser);
                userRs = userPstmt.executeQuery();

                if (userRs.next()) {
                    db_gender = userRs.getString("gender");
                    db_dname = userRs.getString("dname");
                    db_province_city_district = userRs.getString("province_city_district");
                    db_person_name = userRs.getString("person_name");
                    db_tel = userRs.getString("tel");
                    db_postcode = userRs.getString("postcode");
                    db_bpcode = userRs.getString("bpcode");
                    db_fax = userRs.getString("fax");
                    db_hand = userRs.getString("hand");
                    db_IDcard = userRs.getString("IDcard");
                    db_email = userRs.getString("email");
                    db_homepg = userRs.getString("homepg");
                    db_quest = userRs.getString("quest");
                    db_answ = userRs.getString("answ");
                }

            } catch (Exception e) {
                e.printStackTrace();
                message = "加载用户信息时出错：" + e.getMessage();
            } finally {
                if (userRs != null) {
                    try { userRs.close(); } catch (SQLException e) { e.printStackTrace(); }
                }
                if (userPstmt != null) {
                    try { userPstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                }
                if (userConn != null) {
                    try { userConn.close(); } catch (SQLException e) { e.printStackTrace(); }
                }
            }
        }

    %>

    <div class="row">
        <div class="col-md-4">
            <h5>用户列表</h5>
            <div class="user-list border rounded p-2">
                <%
                    // 显示用户列表
                    Connection listConn = null;
                    Statement listStmt = null;
                    ResultSet listRs = null;
                    try {
                        Security.setProperty("jdk.tls.disabledAlgorithms", "");
                        System.setProperty("https.protocols", "TLSv1");
                        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
                        listConn = DriverManager.getConnection(
                                "jdbc:sqlserver://10.211.55.7:1433;databaseName=webChat;" +
                                        "encrypt=true;trustServerCertificate=true;sslProtocol=TLSv1;" +
                                        "disableStatementPooling=true;cancelQueryTimeout=0;socketTimeout=120",
                                "sa", "123456");

                        String listSql = "SELECT username, person_name FROM webChat.dbo.UserInfo ORDER BY username ASC";
                        listStmt = listConn.createStatement();
                        listRs = listStmt.executeQuery(listSql);
                %>
                <table class="table table-sm table-hover">
                    <thead>
                    <tr>
                        <th>用户名</th>
                        <th>姓名</th>
                    </tr>
                    </thead>
                    <tbody>
                    <%
                        while (listRs.next()) {
                            String uName = listRs.getString("username");
                            String pName = listRs.getString("person_name");
                    %>
                    <tr onclick="selectUser('<%= uName %>')"
                        style="cursor: pointer;<%= (selectedUser != null && selectedUser.equals(uName)) ? "background-color:#e9ecef;" : "" %>">
                        <td><%= uName %></td>
                        <td><%= pName != null ? pName : "" %></td>
                    </tr>
                    <%
                        }
                    %>
                    </tbody>
                </table>
                <%
                    } catch(Exception e) {
                        e.printStackTrace();
                    } finally {
                        if (listRs != null) try { listRs.close(); } catch (SQLException e) {}
                        if (listStmt != null) try { listStmt.close(); } catch (SQLException e) {}
                        if (listConn != null) try { listConn.close(); } catch (SQLException e) {}
                    }
                %>
            </div>
        </div>

        <div class="col-md-8">
            <h5>用户详情与编辑（不包括密码修改）</h5>
            <form method="post" action="">
                <input type="hidden" name="username" value="<%= selectedUser != null ? selectedUser : "" %>">

                <div class="mb-3">
                    <label class="form-label">用户名(不可更改)</label>
                    <input type="text" class="form-control" value="<%= selectedUser != null ? selectedUser : "" %>" disabled>
                </div>
                <div class="mb-3">
                    <label class="form-label">性别(gender)</label>
                    <input type="text" class="form-control" name="gender" value="<%= db_gender != null ? db_gender : "" %>" placeholder="M/F等">
                </div>
                <div class="mb-3">
                    <label class="form-label">显示名称(dname)</label>
                    <input type="text" class="form-control" name="dname" value="<%= db_dname != null ? db_dname : "" %>">
                </div>
                <div class="mb-3">
                    <label class="form-label">省市区(province_city_district)</label>
                    <input type="text" class="form-control" name="province_city_district" value="<%= db_province_city_district != null ? db_province_city_district : "" %>">
                </div>
                <div class="mb-3">
                    <label class="form-label">姓名(person_name)</label>
                    <input type="text" class="form-control" name="person_name" value="<%= db_person_name != null ? db_person_name : "" %>">
                </div>
                <div class="mb-3">
                    <label class="form-label">电话(tel)</label>
                    <input type="text" class="form-control" name="tel" value="<%= db_tel != null ? db_tel : "" %>">
                </div>
                <div class="mb-3">
                    <label class="form-label">邮编(postcode)</label>
                    <input type="text" class="form-control" name="postcode" value="<%= db_postcode != null ? db_postcode : "" %>">
                </div>
                <div class="mb-3">
                    <label class="form-label">bpcode</label>
                    <input type="text" class="form-control" name="bpcode" value="<%= db_bpcode != null ? db_bpcode : "" %>">
                </div>
                <div class="mb-3">
                    <label class="form-label">传真(fax)</label>
                    <input type="text" class="form-control" name="fax" value="<%= db_fax != null ? db_fax : "" %>">
                </div>
                <div class="mb-3">
                    <label class="form-label">手机(hand)</label>
                    <input type="text" class="form-control" name="hand" value="<%= db_hand != null ? db_hand : "" %>">
                </div>
                <div class="mb-3">
                    <label class="form-label">身份证(IDcard)</label>
                    <input type="text" class="form-control" name="IDcard" value="<%= db_IDcard != null ? db_IDcard : "" %>">
                </div>
                <div class="mb-3">
                    <label class="form-label">邮箱(email)</label>
                    <input type="text" class="form-control" name="email" value="<%= db_email != null ? db_email : "" %>">
                </div>
                <div class="mb-3">
                    <label class="form-label">主页(homepg)</label>
                    <input type="text" class="form-control" name="homepg" value="<%= db_homepg != null ? db_homepg : "" %>">
                </div>
                <div class="mb-3">
                    <label class="form-label">密保问题(quest)</label>
                    <input type="text" class="form-control" name="quest" value="<%= db_quest != null ? db_quest : "" %>">
                </div>
                <div class="mb-3">
                    <label class="form-label">密保答案(answ)</label>
                    <input type="text" class="form-control" name="answ" value="<%= db_answ != null ? db_answ : "" %>">
                </div>

                <div class="mb-3">
                    <% if (selectedUser == null || selectedUser.isEmpty()) { %>
                    <p class="text-muted">请选择一个用户进行编辑。</p>
                    <% } else { %>
                    <button type="submit" class="btn btn-primary" name="action" value="update">更新用户信息</button>
                    <% } %>
                </div>
            </form>
            <% if (message != null) { %>
            <div class="alert alert-info message"><%= message %></div>
            <% } %>
        </div>
    </div>
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
