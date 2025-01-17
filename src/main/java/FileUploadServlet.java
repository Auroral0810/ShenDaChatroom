/**
 * 文件上传和消息发送Servlet
 * 用于处理文件上传和消息发送的请求
 */

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Paths;
import java.security.Security;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

/**
 * 文件上传Servlet类
 * 处理文件上传和消息发送的请求
 */
@WebServlet("/FileUploadServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,  // 2MB - 超过此大小的文件将被写入磁盘
        maxFileSize = 1024 * 1024 * 60,       // 60MB - 单个文件的最大大小
        maxRequestSize = 1024 * 1024 * 60     // 60MB - 整个请求的最大大小
)
public class FileUploadServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /** 数据库连接配置 */
    private static final String DB_URL = "jdbc:sqlserver://10.211.55.7:1433;databaseName=webChat;";
    private static final String DB_USER = "sa";
    private static final String DB_PASSWORD = "123456";

    /**
     * 处理POST请求的主方法
     * @param request HTTP请求对象
     * @param response HTTP响应对象
     * @throws ServletException Servlet异常
     * @throws IOException IO异常
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        // 获取用户会话信息
        HttpSession session = request.getSession(false);
        String user = (session != null) ? (String) session.getAttribute("user") : null;

        // 检查用户是否已登录
        if (user == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().println("用户未登录！");
            return;
        }

        // 根据action参数决定处理方式
        String action = request.getParameter("action");
        if ("uploadFile".equals(action)) {
            handleFileUpload(request, response, user);
        } else {
            handleMessageSend(request, response, user);
        }
    }

    /**
     * 处理文件上传的方法
     * @param request HTTP请求对象
     * @param response HTTP响应对象
     * @param user 当前用户名
     * @throws ServletException Servlet异常
     * @throws IOException IO异常
     */
    private void handleFileUpload(HttpServletRequest request, HttpServletResponse response, String user)
            throws ServletException, IOException {
        try {
            // 获取上传的文件
            Part filePart = request.getPart("uploadedFile");
            if (filePart == null || filePart.getSize() <= 0) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().println("未选择文件！");
                return;
            }

            // 获取文件信息
            String fileName = getFileName(filePart);
            String fileType = filePart.getContentType();
            long fileSize = filePart.getSize();

            // 定义允许的文件类型
            String[] allowedTypes = {
                    "image/png", "image/jpeg", "application/pdf", "application/msword",
                    "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                    "application/vnd.ms-excel", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                    "text/csv", "text/plain", "application/x-python-code",
                    "application/vnd.ms-powerpoint", "application/vnd.openxmlformats-officedocument.presentationml.presentation",
                    "application/zip", "application/x-rar-compressed", "image/gif", "video/mp4"
            };

            // 验证文件类型
            boolean isAllowed = Arrays.asList(allowedTypes).contains(fileType);
            if (!isAllowed) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().println("不支持的文件类型！");
                return;
            }

            // 验证文件大小
            long maxSize = 60 * 1024 * 1024; // 60MB
            if (fileSize > maxSize) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().println("文件大小超过60MB限制！");
                return;
            }

            // 读取文件内容
            InputStream fileContent = filePart.getInputStream();
            byte[] fileData = fileContent.readAllBytes();

            // 将文件保存到数据库
            try (Connection connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {
                String sql = "INSERT INTO Message(username, message, date, receiver, file_data, file_name, file_type) VALUES (?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement pstmt = connection.prepareStatement(sql);
                pstmt.setString(1, user);
                pstmt.setString(2, ""); // 消息为空
                pstmt.setString(3, new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date()));
                pstmt.setString(4, "everyone");
                pstmt.setBytes(5, fileData);
                pstmt.setString(6, fileName);
                pstmt.setString(7, fileType);

                int rows = pstmt.executeUpdate();
                if (rows > 0) {
                    response.setStatus(HttpServletResponse.SC_OK);
                    response.getWriter().println("文件上传成功");
                } else {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    response.getWriter().println("文件上传失败");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().println("发生错误：" + e.getMessage());
        }
    }

    /**
     * 从Part对象中提取文件名
     * @param part 包含文件信息的Part对象
     * @return 提取的文件名
     */
    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        for (String content : contentDisp.split(";")) {
            if (content.trim().startsWith("filename")) {
                return Paths.get(content.substring(content.indexOf("=") + 1).trim().replace("\"", "")).getFileName().toString();
            }
        }
        return null;
    }

    /**
     * 处理消息发送的方法
     * @param request HTTP请求对象
     * @param response HTTP响应对象
     * @param user 当前用户名
     * @throws ServletException Servlet异常
     * @throws IOException IO异常
     */
    private void handleMessageSend(HttpServletRequest request, HttpServletResponse response, String user)
            throws ServletException, IOException {
        Connection connection = null;
        PreparedStatement pstmt = null;
        String statusMessage = "";
        String statusClass = "";

        try {
            // 获取表单数据
            String messageType = request.getParameter("messageType");
            String privateRecipient = request.getParameter("privateRecipient");
            String message = request.getParameter("message");

            messageType = (messageType != null) ? messageType.trim() : null;
            privateRecipient = (privateRecipient != null) ? privateRecipient.trim() : null;
            message = (message != null) ? message.trim() : null;

            // 处理文件上传
            Part filePart = request.getPart("uploadedFile");
            byte[] fileData = null;
            String fileName = null;
            String fileType = null;

            if (filePart != null && filePart.getSize() > 0) {
                fileName = getFileName(filePart);
                fileType = filePart.getContentType();
                InputStream inputStream = filePart.getInputStream();
                fileData = inputStream.readAllBytes();

                // 定义允许的文件类型
                String[] allowedTypes = {
                        "image/png",  // PNG
                        "image/jpeg", // JPEG
                        "application/pdf", // PDF
                        "application/msword", // Word .doc
                        "application/vnd.openxmlformats-officedocument.wordprocessingml.document", // Word .docx
                        "application/vnd.ms-excel", // Excel .xls
                        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", // Excel .xlsx
                        "text/csv", // CSV
                        "text/plain", // TXT
                        "application/x-python-code", // Python .py
                        "application/vnd.ms-powerpoint", // PowerPoint .ppt
                        "application/vnd.openxmlformats-officedocument.presentationml.presentation", // PowerPoint .pptx
                        "application/zip", // ZIP
                        "application/x-rar-compressed", // RAR
                        "image/gif", // GIF
                        "video/mp4" // MP4
                };

                // 验证文件类型
                boolean isAllowed = false;
                for (String type : allowedTypes) {
                    if (type.equalsIgnoreCase(fileType)) {
                        isAllowed = true;
                        break;
                    }
                }

                if (!isAllowed) {
                    statusMessage = "不支持的文件类型！";
                    statusClass = "error";
                    request.setAttribute("statusMessage", statusMessage);
                    request.setAttribute("statusClass", statusClass);
                    if ("YYF222090140".equals(user)) {
                        request.getRequestDispatcher("WebChat_AdminSendMsg.jsp").forward(request, response);
                    } else {
                        request.getRequestDispatcher("WebChat_SendMsg.jsp").forward(request, response);
                    }
                    return;
                }

                // 验证文件大小
                long maxSize = 60 * 1024 * 1024; // 60MB
                if (fileData.length > maxSize) {
                    statusMessage = "文件大小超过60MB限制！";
                    statusClass = "error";
                    request.setAttribute("statusMessage", statusMessage);
                    request.setAttribute("statusClass", statusClass);
                    if ("YYF222090140".equals(user)) {
                        request.getRequestDispatcher("WebChat_AdminSendMsg.jsp").forward(request, response);
                    } else {
                        request.getRequestDispatcher("WebChat_SendMsg.jsp").forward(request, response);
                    }
                    return;
                }
            }

            // 配置数据库连接
            Security.setProperty("jdk.tls.disabledAlgorithms", "");
            System.setProperty("https.protocols", "TLSv1");
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

            connection = DriverManager.getConnection(DB_URL +
                            "encrypt=true;trustServerCertificate=true;sslProtocol=TLSv1;" +
                            "disableStatementPooling=true;cancelQueryTimeout=0;socketTimeout=120",
                    DB_USER, DB_PASSWORD);

            // 过滤敏感词
            if (message != null && !message.isEmpty()) {
                message = filterSensitiveWords(connection, message);
            }

            // 验证消息和文件是否都为空
            if ((message == null || message.isEmpty()) && fileData == null) {
                statusMessage = "消息和文件不能同时为空！";
                statusClass = "error";
                request.setAttribute("statusMessage", statusMessage);
                request.setAttribute("statusClass", statusClass);
                if ("YYF222090140".equals(user)) {
                    request.getRequestDispatcher("WebChat_AdminSendMsg.jsp").forward(request, response);
                } else {
                    request.getRequestDispatcher("WebChat_SendMsg.jsp").forward(request, response);
                }
                return;
            }

            // 准备消息数据
            SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            String currentDate = df.format(new Date());
            String receiver = "private".equals(messageType) ? privateRecipient : "everyone";

            // 插入消息到数据库
            String sql = "INSERT INTO Message(username, message, date, receiver, file_data, file_name, file_type) VALUES (?, ?, ?, ?, ?, ?, ?)";
            pstmt = connection.prepareStatement(sql);
            pstmt.setString(1, user);
            pstmt.setString(2, (message != null) ? message : "");
            pstmt.setString(3, currentDate);
            pstmt.setString(4, receiver);
            if (fileData != null) {
                pstmt.setBytes(5, fileData);
                pstmt.setString(6, fileName);
                pstmt.setString(7, fileType);
            } else {
                pstmt.setNull(5, java.sql.Types.BLOB);
                pstmt.setNull(6, java.sql.Types.VARCHAR);
                pstmt.setNull(7, java.sql.Types.VARCHAR);
            }

            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                statusMessage = "消息发送成功 <img src='" + request.getContextPath() + "/image/success.png' alt='Success' class='upload-success-icon'>";
                statusClass = "success";
            } else {
                statusMessage = "消息发送失败";
                statusClass = "error";
            }

        } catch (Exception e) {
            e.printStackTrace();
            statusMessage = "发生错误：" + e.getMessage();
            statusClass = "error";
        } finally {
            // 关闭数据库连接
            if (pstmt != null) {
                try {
                    pstmt.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            if (connection != null) {
                try {
                    connection.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }

        // 设置状态消息并转发到JSP页面
        request.setAttribute("statusMessage", statusMessage);
        request.setAttribute("statusClass", statusClass);
        if ("YYF222090140".equals(user)) {
            request.getRequestDispatcher("WebChat_AdminSendMsg.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("WebChat_SendMsg.jsp").forward(request, response);
        }
    }

    /**
     * 过滤敏感词的方法
     * @param conn 数据库连接
     * @param message 原始消息
     * @return 过滤后的消息
     * @throws SQLException SQL异常
     */
    private String filterSensitiveWords(Connection conn, String message) throws SQLException {
        List<String> sensitiveWords = new ArrayList<String>();
        String query = "SELECT word FROM SensitiveWords";
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            // 从数据库获取敏感词列表
            stmt = conn.prepareStatement(query);
            rs = stmt.executeQuery();

            while (rs.next()) {
                sensitiveWords.add(rs.getString("word"));
            }
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { }
            if (stmt != null) try { stmt.close(); } catch (SQLException e) { }
        }

        // 替换敏感词
        boolean flag = false;
        for (String word : sensitiveWords) {
            if (message.contains(word)) {
                flag = true;
                StringBuilder replacement = new StringBuilder();
                for (int i = 0; i < word.length(); i++) {
                    replacement.append("*");
                }
                message = message.trim();
                message = message.replace(word, replacement.toString());
            }
        }
        if (flag) {
            message += "<span style='font-size: small; color: red;'>（请文明用语！）</span>";
        }
        return message;
    }
}
