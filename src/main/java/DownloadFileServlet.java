import java.io.IOException;
import java.io.OutputStream;
import java.security.Security;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

/**
 * 文件下载Servlet
 * 用于处理文件下载请求，从数据库中获取文件并提供下载
 */
@WebServlet("/DownloadFileServlet")
public class DownloadFileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /** 数据库连接URL */
    private static final String DB_URL = "jdbc:sqlserver://10.211.55.7:1433;databaseName=webChat;";
    /** 数据库用户名 */
    private static final String DB_USER = "sa";
    /** 数据库密码 */
    private static final String DB_PASSWORD = "123456";

    /**
     * 处理GET请求的方法
     * @param request HTTP请求对象
     * @param response HTTP响应对象
     * @throws ServletException Servlet异常
     * @throws IOException IO异常
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 获取messageId参数
        String messageIdParam = request.getParameter("messageId");
        if (messageIdParam == null || messageIdParam.isEmpty()) {
            response.getWriter().println("<p class='status-message error'>无效的文件ID！</p>");
            return;
        }

        // 将字符串参数转换为整数
        int messageId;
        try {
            messageId = Integer.parseInt(messageIdParam);
        } catch (NumberFormatException e) {
            response.getWriter().println("<p class='status-message error'>无效的文件ID格式！</p>");
            return;
        }

        // 数据库连接相关变量
        Connection connection = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            // 配置TLS安全设置
            Security.setProperty("jdk.tls.disabledAlgorithms", "");
            System.setProperty("https.protocols", "TLSv1");
            // 加载SQL Server驱动
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

            // 建立数据库连接
            connection = DriverManager.getConnection(DB_URL +
                            "encrypt=true;trustServerCertificate=true;sslProtocol=TLSv1;" +
                            "disableStatementPooling=true;cancelQueryTimeout=0;socketTimeout=120",
                    DB_USER, DB_PASSWORD);

            // 准备SQL查询
            String sql = "SELECT file_data, file_name, file_type FROM Message WHERE message_id = ?";
            pstmt = connection.prepareStatement(sql);
            pstmt.setInt(1, messageId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                // 获取文件信息
                byte[] fileData = rs.getBytes("file_data");
                String fileName = rs.getString("file_name");
                String fileType = rs.getString("file_type");

                // 检查文件数据是否存在
                if (fileData == null || fileData.length == 0) {
                    response.getWriter().println("<p class='status-message error'>文件不存在或已被删除！</p>");
                    return;
                }

                // 设置响应头
                response.setContentType(fileType);
                response.setHeader("Content-Disposition", "attachment;filename=\"" + java.net.URLEncoder.encode(fileName, "UTF-8") + "\"");

                // 写出文件数据到响应流
                OutputStream os = response.getOutputStream();
                os.write(fileData);
                os.flush();
                os.close();
            } else {
                response.getWriter().println("<p class='status-message error'>未找到对应的文件！</p>");
            }

        } catch (ClassNotFoundException | SQLException e) {
            // 异常处理
            e.printStackTrace();
            response.getWriter().println("<p class='status-message error'>发生错误：" + e.getMessage() + "</p>");
        } finally {
            // 关闭数据库资源
            if (rs != null) try { rs.close(); } catch (SQLException e) { }
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { }
            if (connection != null) try { connection.close(); } catch (SQLException e) { }
        }
    }
}
